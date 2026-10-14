package org.javamcp.tools;

import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.javamcp.services.TestExecutionService;

import java.util.List;
import java.util.Map;

public class RunApiTestsTool {

    private final TestExecutionService service;

    public RunApiTestsTool(TestExecutionService service) {
        this.service = service;
    }

    public McpServerFeatures.SyncToolSpecification create() {
        Map<String, Object> inputSchema = Map.of(
                "type", "object",
                "properties", Map.of("environment", Map.of("type", "string", "enum", List.of("qa", "staging"))),
                "required", List.of("environment"),
                "additionalProperties", false);
        return McpServerFeatures.SyncToolSpecification.builder()
                .tool(McpSchema.Tool.builder("run_api_tests", inputSchema)
                        .description("Triggers the Java API E2E test suite in Jenkins for the requested environment.").build())
                .callHandler((exchange, request) -> {
                    try {
                        String environment = ToolResponses.requiredString(request.arguments(), "environment", "qa", "staging");
                        return ToolResponses.success(service.runApiTests(environment));
                    } catch (Exception exception) {
                        return ToolResponses.error(exception);
                    }
                }).build();
    }
}
