package org.javamcp.models;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

public record JiraCreateIssueRequest(Fields fields) {

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record Fields(Project project, NamedValue issuetype, String summary,
                         Document description, NamedValue priority) {
    }

    public record Project(String key) {
    }

    public record NamedValue(String name) {
    }

    public record Document(String type, int version, List<Block> content) {
    }

    public record Block(String type, List<Text> content) {
    }

    public record Text(String type, String text) {
    }
}
