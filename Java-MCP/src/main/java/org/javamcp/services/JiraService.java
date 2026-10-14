package org.javamcp.services;

import org.javamcp.clients.JiraClient;
import org.javamcp.models.CreatedJiraBug;
import org.javamcp.models.JiraBugInput;
import org.javamcp.models.JiraCreateIssueRequest;
import org.javamcp.models.JiraCreateIssueRequest.Block;
import org.javamcp.models.JiraCreateIssueRequest.Document;
import org.javamcp.models.JiraCreateIssueRequest.Fields;
import org.javamcp.models.JiraCreateIssueRequest.NamedValue;
import org.javamcp.models.JiraCreateIssueRequest.Project;
import org.javamcp.models.JiraCreateIssueRequest.Text;
import org.javamcp.models.JiraIssueResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class JiraService {

    private final JiraClient jiraClient;
    private final String projectKey;

    public JiraService(JiraClient jiraClient, String projectKey) {
        this.jiraClient = jiraClient;
        this.projectKey = projectKey;
    }

    public CreatedJiraBug createBug(JiraBugInput input) throws IOException {
        if (projectKey == null || projectKey.isBlank()) {
            throw new IOException("Configure JIRA_PROJECT_KEY before creating Jira bugs.");
        }
        if (input == null || input.summary() == null || input.summary().isBlank()
                || input.summary().length() > 255 || input.description() == null || input.description().isBlank()) {
            throw new IllegalArgumentException("A summary of 1-255 characters and a non-empty description are required.");
        }
        List<Block> content = new ArrayList<>();
        addParagraphs(content, input.description());
        addDetail(content, "Environment", input.environment());
        addDetail(content, "Failed test", input.failedTestName());
        addDetail(content, "Jenkins build", input.jenkinsBuildUrl());
        if (input.stackTrace() != null && !input.stackTrace().isBlank()) {
            addParagraphs(content, "Stack trace:");
            content.add(new Block("codeBlock", List.of(new Text("text", input.stackTrace()))));
        }
        NamedValue priority = input.priority() == null || input.priority().isBlank()
                ? null : new NamedValue(input.priority());
        JiraCreateIssueRequest request = new JiraCreateIssueRequest(new Fields(
                new Project(projectKey.strip()), new NamedValue("Bug"), input.summary(),
                new Document("doc", 1, content), priority));
        JiraIssueResponse created = jiraClient.createIssue(request);
        return new CreatedJiraBug(created.key(), created.id(), jiraClient.issueUrl(created.key()));
    }

    private void addDetail(List<Block> content, String label, String value) {
        if (value != null && !value.isBlank()) addParagraphs(content, label + ": " + value);
    }

    private void addParagraphs(List<Block> content, String text) {
        for (String line : text.split("\\R", -1)) {
            content.add(new Block("paragraph", line.isEmpty() ? List.of() : List.of(new Text("text", line))));
        }
    }
}
