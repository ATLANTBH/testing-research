package org.javamcp.models;

public record JiraBugInput(String summary, String description, String priority, String environment,
                           String failedTestName, String jenkinsBuildUrl, String stackTrace) {
}
