package org.javamcp.tools;

import io.modelcontextprotocol.json.McpJsonDefaults;
import io.modelcontextprotocol.spec.McpSchema;

import java.io.IOException;
import java.util.Map;

final class ToolResponses {

    private ToolResponses() {
    }

    static McpSchema.CallToolResult success(Object value) throws IOException {
        return McpSchema.CallToolResult.builder().structuredContent(value)
                .addTextContent(McpJsonDefaults.getMapper().writeValueAsString(value)).isError(false).build();
    }

    static McpSchema.CallToolResult error(Exception exception) {
        String message = exception instanceof IOException || exception instanceof IllegalArgumentException
                ? exception.getMessage() : "Unable to process the test execution request.";
        return McpSchema.CallToolResult.builder().addTextContent(message).isError(true).build();
    }

    static String requiredString(Map<String, Object> arguments, String name, String... allowed) {
        if (arguments == null || !(arguments.get(name) instanceof String value) || value.isBlank()) {
            throw new IllegalArgumentException(name + " must be a non-empty string.");
        }
        if (allowed.length > 0 && !java.util.List.of(allowed).contains(value)) {
            throw new IllegalArgumentException(name + " must be one of: " + String.join(", ", allowed) + ".");
        }
        return value;
    }
}
