package org.javamcp.models;

public record TestRunStatus(
        String jobName,
        long queueId,
        Integer buildNumber,
        String status,
        String result,
        String buildUrl,
        Long durationMs,
        String message
) {
}
