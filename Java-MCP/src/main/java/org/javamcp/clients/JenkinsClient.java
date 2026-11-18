package org.javamcp.clients;

import io.modelcontextprotocol.json.McpJsonDefaults;
import org.javamcp.models.JenkinsBuild;
import org.javamcp.models.JenkinsQueueItem;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Arrays;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class JenkinsClient {

    private static final Logger LOGGER = Logger.getLogger(JenkinsClient.class.getName());

    private static final String JOB_PATH = "/job/";

    private final String baseUrl;
    private final String authorization;
    private final HttpClient httpClient;

    public JenkinsClient(String baseUrl, String username, String token) {
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.authorization = "Basic " + Base64.getEncoder()
                .encodeToString((username + ":" + token).getBytes(StandardCharsets.UTF_8));
        this.httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    }

    public long triggerJob(String jobName, String parameters) throws IOException {
        boolean hasParameters = parameters != null && !parameters.isBlank();
        HttpResponse<String> response = send(jobPath(jobName) + (hasParameters ? "/buildWithParameters" : "/build"),
                hasParameters ? parameters : "");
        checkStatus(response, "Job not found.", true);
        String location = response.headers().firstValue("Location").orElse("");
        try {
            String path = URI.create(location).getPath();
            var matcher = Pattern.compile("/queue/item/([0-9]+)/?$").matcher(path);
            if (matcher.find()) {
                long queueId = Long.parseLong(matcher.group(1));
                if (queueId > 0) {
                    return queueId;
                }
            }
        } catch (IllegalArgumentException exception) {
            // The Location header and exception message may contain sensitive information.
            LOGGER.log(Level.WARNING, "Unable to parse Jenkins queue location (HTTP {0}, exception type: {1}).",
                    new Object[]{response.statusCode(), exception.getClass().getSimpleName()});
        }
        throw new IOException("Jenkins accepted the request but returned no valid queue ID. Check Jenkins before retrying.");
    }

    public JenkinsQueueItem getQueueItem(long queueId) throws IOException {
        if (queueId <= 0) {
            throw new IllegalArgumentException("queueId must be a positive integer.");
        }
        JenkinsQueueItem item = readJson("/queue/item/" + queueId + "/api/json",
                "Queue item not found or no longer available; Jenkins may have expired it.", JenkinsQueueItem.class);
        if (item.id() == null || item.id() != queueId
                || (item.executable() != null && item.executable().number() <= 0)) {
            throw new IOException("Malformed Jenkins queue response.");
        }
        return item;
    }

    public JenkinsBuild getBuild(String jobName, int buildNumber) throws IOException {
        JenkinsBuild build = readJson(jobPath(jobName) + "/" + buildNumber + "/api/json",
                "Jenkins job or build not found.", JenkinsBuild.class);
        if (build.number() == null || build.number() != buildNumber || build.building() == null
                || build.duration() == null || build.duration() < 0 || build.timestamp() == null) {
            throw new IOException("Malformed Jenkins build response.");
        }
        return build;
    }

    private <T> T readJson(String path, String notFound, Class<T> type) throws IOException {
        HttpResponse<String> response = send(path, null);
        checkStatus(response, notFound, false);
        try {
            T value = McpJsonDefaults.getMapper().readValue(response.body(), type);
            if (value != null) {
                return value;
            }
        } catch (IOException | RuntimeException exception) {
            // Response bodies and parser messages may contain sensitive information.
            LOGGER.log(Level.WARNING, "Unable to parse Jenkins response as {0} (HTTP {1}, exception type: {2}).",
                    new Object[]{type.getSimpleName(), response.statusCode(), exception.getClass().getSimpleName()});
        }
        throw new IOException("Malformed Jenkins response.");
    }

    private HttpResponse<String> send(String path, String parameters) throws IOException {
        try {
            HttpRequest.Builder request = HttpRequest.newBuilder(URI.create(baseUrl + path))
                    .timeout(Duration.ofSeconds(30)).header("Authorization", authorization)
                    .header("Accept", "application/json");
            if (parameters == null) {
                request.GET();
            } else {
                request.header("Content-Type", "application/x-www-form-urlencoded")
                        .POST(HttpRequest.BodyPublishers.ofString(parameters));
            }
            return httpClient.send(request.build(), HttpResponse.BodyHandlers.ofString());
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IOException("Jenkins request was interrupted.");
        } catch (IOException exception) {
            throw new IOException("Unable to reach Jenkins or request timed out.");
        } catch (IllegalArgumentException exception) {
            throw new IOException("Unable to construct Jenkins request; check the Jenkins configuration.");
        }
    }

    private void checkStatus(HttpResponse<?> response, String notFound, boolean trigger) throws IOException {
        int status = response.statusCode();
        if (trigger ? status >= 200 && status < 300 : status == 200) {
            return;
        }
        if (status == 401 || status == 403) {
            throw new IOException("Jenkins authentication or authorization failed (HTTP " + status + ").");
        }
        if (status == 404) {
            throw new IOException(notFound);
        }
        throw new IOException("Jenkins returned HTTP " + status + ".");
    }

    private String jobPath(String jobName) {
        if (jobName == null || jobName.isBlank()
                || Arrays.stream(jobName.split("/", -1)).anyMatch(part -> part.isBlank() || part.equals(".") || part.equals(".."))) {
            throw new IllegalArgumentException("jobName must contain a valid Jenkins job name.");
        }
        return JOB_PATH + Arrays.stream(jobName.split("/"))
                .map(part -> URLEncoder.encode(part, StandardCharsets.UTF_8).replace("+", "%20"))
                .collect(Collectors.joining(JOB_PATH));
    }
}
