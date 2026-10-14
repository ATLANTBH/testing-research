package org.javamcp.tools;

import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.javamcp.services.TestExecutionService;

import java.util.List;
import java.util.Map;

public class RunUiTestsTool {

    private final TestExecutionService service;

    public RunUiTestsTool(TestExecutionService service) {
        this.service = service;
    }

    public McpServerFeatures.SyncToolSpecification create() {
        Map<String, Object> inputSchema = Map.of(
                "type", "object",
                "properties", Map.of(
                        "environment", Map.of("type", "string", "enum", List.of("qa", "staging")),
                        "browser", Map.of("type", "string", "enum", List.of("chromium", "firefox"))),
                "required", List.of("environment", "browser"),
                "additionalProperties", false);
        return McpServerFeatures.SyncToolSpecification.builder()
                .tool(McpSchema.Tool.builder("run_ui_tests", inputSchema)
                        .description("Triggers the Java Playwright UI automation suite in Jenkins.").build())
                .callHandler((exchange, request) -> {
                    try {
                        String environment = ToolResponses.requiredString(request.arguments(), "environment", "qa", "staging");
                        String browser = ToolResponses.requiredString(request.arguments(), "browser", "chromium", "firefox");
                        return ToolResponses.success(service.runUiTests(environment, browser));
                    } catch (Exception exception) {
                        return ToolResponses.error(exception);
                    }
                }).build();
    }
}
