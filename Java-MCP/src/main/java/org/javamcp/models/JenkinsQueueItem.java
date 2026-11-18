package org.javamcp.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record JenkinsQueueItem(Long id, Boolean cancelled, String why, JenkinsExecutable executable) {
}
