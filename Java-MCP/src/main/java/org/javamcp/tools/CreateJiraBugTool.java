package org.javamcp.tools;

import io.modelcontextprotocol.server.McpServerFeatures;
import io.modelcontextprotocol.spec.McpSchema;
import org.javamcp.models.JiraBugInput;
import org.javamcp.services.JiraService;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

public class CreateJiraBugTool {

    private final Function<String, JiraService> serviceForEnvironment;

    public CreateJiraBugTool(JiraService service) {
        this(environment -> service);
    }

    public CreateJiraBugTool(Function<String, JiraService> serviceForEnvironment) {
        this.serviceForEnvironment = serviceForEnvironment;
    }

    public McpServerFeatures.SyncToolSpecification create() {
        Map<String, Object> inputSchema = Map.of(
                "type", "object",
                "properties", Map.of(
                        "summary", Map.of("type", "string", "minLength", 1, "maxLength", 255),
                        "description", Map.of("type", "string", "minLength", 1,
                                "description", "Plain text; converted to Jira ADF by the server."),
                        "priority", Map.of("type", "string", "description", "Jira priority name, for example High."),
                        "environment", Map.of("type", "string", "enum", List.of("qa", "staging"),
                                "default", "qa", "description", "Selects the environment configuration; defaults to qa."),
                        "failedTestName", Map.of("type", "string"),
                        "jenkinsBuildUrl", Map.of("type", "string"),
                        "stackTrace", Map.of("type", "string")),
                "required", List.of("summary", "description"),
                "additionalProperties", false);
        return McpServerFeatures.SyncToolSpecification.builder()
                .tool(McpSchema.Tool.builder().name("create_jira_bug").inputSchema(inputSchema)
                        .description("Create a Jira Cloud Bug in the configured project, optionally including test failure details.").build())
                .callHandler((exchange, request) -> {
                    try {
                        Map<String, Object> arguments = request.arguments();
                        String summary = ToolResponses.requiredString(arguments, "summary");
                        String description = ToolResponses.requiredString(arguments, "description");
                        if (summary.length() > 255) {
                            throw new IllegalArgumentException("summary must contain at most 255 characters.");
                        }
                        String environment = arguments.containsKey("environment")
                                ? ToolResponses.requiredString(arguments, "environment", "qa", "staging") : "qa";
                        JiraBugInput input = new JiraBugInput(summary, description,
                                optionalString(arguments, "priority"), optionalString(arguments, "environment"),
                                optionalString(arguments, "failedTestName"), optionalString(arguments, "jenkinsBuildUrl"),
                                optionalString(arguments, "stackTrace"));
                        return ToolResponses.success(serviceForEnvironment.apply(environment).createBug(input));
                    } catch (IOException | IllegalArgumentException exception) {
                        return ToolResponses.error(exception);
                    } catch (Exception exception) {
                        return McpSchema.CallToolResult.builder().isError(true)
                                .addTextContent("Unable to process the Jira bug creation request.").build();
                    }
                }).build();
    }

    private String optionalString(Map<String, Object> arguments, String name) {
        if (!arguments.containsKey(name)) return null;
        if (!(arguments.get(name) instanceof String value)) {
            throw new IllegalArgumentException(name + " must be a string when provided.");
        }
        return value.isBlank() ? null : value;
    }
}
