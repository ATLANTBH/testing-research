package org.javamcp.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record JenkinsBuild(Integer number, String url, Boolean building, String result,
                           Long duration, Long timestamp) {
}
