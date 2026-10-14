package org.javamcp.clients;

import io.modelcontextprotocol.json.McpJsonDefaults;
import org.javamcp.models.JiraCreateIssueRequest;
import org.javamcp.models.JiraIssueResponse;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class JiraClient {

    private static final Logger LOGGER = Logger.getLogger(JiraClient.class.getName());
    private static final String REDACTED = "[REDACTED]";

    private final String baseUrl;
    private final String email;
    private final String apiToken;
    private final HttpClient httpClient;

    public JiraClient(String baseUrl, String email, String apiToken) {
        this.baseUrl = baseUrl == null ? "" : baseUrl.strip().replaceAll("/+$", "");
        this.email = email;
        this.apiToken = apiToken;
        this.httpClient = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    }

    public JiraIssueResponse createIssue(JiraCreateIssueRequest issue) throws IOException {
        // Validate on invocation so missing Jira configuration does not prevent Jenkins tools starting.
        validateConfiguration();
        String authorization = authorization();
        String body;
        try {
            body = McpJsonDefaults.getMapper().writeValueAsString(issue);
        } catch (IOException | RuntimeException exception) {
            throw new IOException("Unable to serialize the Jira issue request.");
        }
        HttpResponse<String> response;
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(baseUrl + "/rest/api/3/issue"))
                    .timeout(Duration.ofSeconds(30))
                    .header("Authorization", authorization)
                    .header("Accept", "application/json")
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8)).build();
            response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IOException("Jira request was interrupted. Check Jira before retrying; the issue may have been created.");
        } catch (IOException exception) {
            throw new IOException("Unable to reach Jira or request timed out. Check Jira before retrying; the issue may have been created.");
        } catch (IllegalArgumentException exception) {
            throw new IOException("Unable to construct Jira request; check Jira configuration.");
        }
        if (response.statusCode() != 201) {
            throw new IOException(errorMessage(response));
        }
        try {
            JiraIssueResponse created = McpJsonDefaults.getMapper().readValue(response.body(), JiraIssueResponse.class);
            if (created != null && created.id() != null && created.id().matches("[0-9]+")
                    && created.key() != null && created.key().matches("[A-Za-z][A-Za-z0-9_]*-[0-9]+")) {
                return created;
            }
        } catch (IOException | RuntimeException exception) {
            // Parser diagnostics can include the response body; do not expose them.
            LOGGER.log(Level.WARNING, "Unable to parse Jira issue response (HTTP {0}, exception type: {1}).",
                    new Object[]{response.statusCode(), exception.getClass().getSimpleName()});
        }
        throw new IOException("Jira returned HTTP 201 with a malformed issue response. Check Jira before retrying; the issue may have been created.");
    }

    public String issueUrl(String issueKey) {
        return baseUrl + "/browse/" + issueKey;
    }

    private void validateConfiguration() throws IOException {
        if (baseUrl.isBlank() || email == null || email.isBlank() || apiToken == null || apiToken.isBlank()) {
            throw new IOException("Configure JIRA_BASE_URL, JIRA_EMAIL and JIRA_API_TOKEN before creating Jira bugs.");
        }
        try {
            URI uri = URI.create(baseUrl);
            if (!("https".equals(uri.getScheme()) || "http".equals(uri.getScheme()))
                    || uri.getHost() == null || uri.getRawUserInfo() != null
                    || uri.getRawQuery() != null || uri.getRawFragment() != null) {
                throw new IllegalArgumentException();
            }
        } catch (IllegalArgumentException exception) {
            throw new IOException("JIRA_BASE_URL must be an HTTP(S) site URL without credentials, query or fragment.");
        }
    }

    private String authorization() {
        return "Basic " + Base64.getEncoder()
                .encodeToString((email + ":" + apiToken).getBytes(StandardCharsets.UTF_8));
    }

    private String errorMessage(HttpResponse<String> response) {
        String guidance = switch (response.statusCode()) {
            case 400, 422 -> "Check the issue fields, project key and Bug issue type.";
            case 401 -> "Authentication failed; check Jira email and API token.";
            case 403 -> "Access denied; check project access and Create Issues permission.";
            case 404 -> "Jira endpoint or project was not found.";
            case 429 -> "Jira rate limit reached; retry later.";
            default -> "Jira could not create the issue. Check Jira before retrying.";
        };
        List<String> details = new ArrayList<>();
        try {
            Map<?, ?> error = McpJsonDefaults.getMapper().readValue(response.body(), Map.class);
            if (error != null && error.get("errorMessages") instanceof List<?> messages) {
                for (Object message : messages) {
                    if (message instanceof String text) details.add(text);
                }
            }
            if (error != null && error.get("errors") instanceof Map<?, ?> fields) {
                fields.forEach((field, message) -> {
                    if (field instanceof String && message instanceof String) {
                        details.add(field + ": " + message);
                    }
                });
            }
        } catch (IOException | RuntimeException exception) {
            // HTML, proxy responses and malformed JSON are intentionally omitted.
            LOGGER.log(Level.WARNING, "Unable to parse Jira error response (HTTP {0}, exception type: {1}).",
                    new Object[]{response.statusCode(), exception.getClass().getSimpleName()});
        }
        String detail = String.join("; ", details)
                .replace(authorization(), REDACTED)
                .replace(authorization().substring(6), REDACTED)
                .replace(apiToken, REDACTED)
                .replaceAll("[\\p{Cntrl}]", " ");
        if (detail.length() > 2000) detail = detail.substring(0, 2000) + "...";
        return "Jira returned HTTP " + response.statusCode() + ". " + guidance
                + (detail.isBlank() ? "" : " " + detail);
    }
}
