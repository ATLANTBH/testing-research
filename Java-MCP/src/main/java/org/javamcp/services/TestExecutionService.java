package org.javamcp.services;

import org.javamcp.clients.JenkinsClient;
import org.javamcp.models.JenkinsBuild;
import org.javamcp.models.JenkinsQueueItem;
import org.javamcp.models.TestExecution;
import org.javamcp.models.TestRunStatus;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class TestExecutionService {

    private final JenkinsClient jenkinsClient;

    public TestExecutionService(JenkinsClient jenkinsClient) {
        this.jenkinsClient = jenkinsClient;
    }

    public TestExecution runApiTests(String environment) throws IOException {
        return trigger(environment + " E2E API test", "");
    }

    public TestExecution runUiTests(String environment, String browser) throws IOException {
        return trigger(environment + " UI regression", "BROWSER=" + encode(browser));
    }

    private TestExecution trigger(String jobName, String parameters) throws IOException {
        return new TestExecution(jobName, jenkinsClient.triggerJob(jobName, parameters),
                "Test execution triggered successfully.");
    }

    public TestRunStatus getTestStatus(String jobName, long queueId) throws IOException {
        if (jobName == null || jobName.isBlank()) {
            throw new IllegalArgumentException("jobName is required.");
        }
        JenkinsQueueItem queue = jenkinsClient.getQueueItem(queueId);
        if (Boolean.TRUE.equals(queue.cancelled())) {
            return new TestRunStatus(jobName, queueId, null, "ABORTED", null, null, null,
                    "Test execution was cancelled in the Jenkins queue.");
        }
        if (queue.executable() == null) {
            return new TestRunStatus(jobName, queueId, null, "QUEUED", null, null, null,
                    queue.why() == null || queue.why().isBlank() ? "Waiting in the Jenkins queue." : queue.why());
        }
        JenkinsBuild build = jenkinsClient.getBuild(jobName, queue.executable().number());
        String status = Boolean.TRUE.equals(build.building()) ? "RUNNING" : switch (build.result() == null ? "" : build.result()) {
            case "SUCCESS" -> "PASSED";
            case "FAILURE" -> "FAILED";
            case "UNSTABLE" -> "UNSTABLE";
            case "ABORTED" -> "ABORTED";
            default -> "UNKNOWN";
        };
        return new TestRunStatus(jobName, queueId, build.number(), status, build.result(),
                build.url() == null ? queue.executable().url() : build.url(), build.duration(),
                "Test execution status: " + status + ".");
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
