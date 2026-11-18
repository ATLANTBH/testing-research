package org.javamcp.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record JenkinsExecutable(
        int number,
        String url
) {
}
