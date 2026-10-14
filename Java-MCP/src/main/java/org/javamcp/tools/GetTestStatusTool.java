package org.javamcp.tools;

import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.javamcp.services.TestExecutionService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class GetTestStatusTool {

    private final TestExecutionService service;

    public GetTestStatusTool(TestExecutionService service) {
        this.service = service;
    }

    public McpServerFeatures.SyncToolSpecification create() {
        Map<String, Object> inputSchema = Map.of(
                "type", "object",
                "properties", Map.of(
                        "jobName", Map.of("type", "string", "minLength", 1),
                        "queueId", Map.of("type", "integer", "minimum", 1)),
                "required", List.of("jobName", "queueId"),
                "additionalProperties", false);
        return McpServerFeatures.SyncToolSpecification.builder()
                .tool(McpSchema.Tool.builder("get_test_status", inputSchema)
                        .description("Get the current status of a Jenkins test run previously started through this MCP server.").build())
                .callHandler((exchange, request) -> {
                    try {
                        String jobName = ToolResponses.requiredString(request.arguments(), "jobName");
                        Object value = request.arguments().get("queueId");
                        long queueId;
                        try {
                            if (!(value instanceof Number)) {
                                throw new ArithmeticException();
                            }
                            queueId = new BigDecimal(value.toString()).longValueExact();
                            if (queueId <= 0) {
                                throw new ArithmeticException();
                            }
                        } catch (ArithmeticException | NumberFormatException exception) {
                            throw new IllegalArgumentException("queueId must be a positive integer within the signed 64-bit range.");
                        }
                        return ToolResponses.success(service.getTestStatus(jobName, queueId));
                    } catch (Exception exception) {
                        return ToolResponses.error(exception);
                    }
                }
        ).build();
    }
}
