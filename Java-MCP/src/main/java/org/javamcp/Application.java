package org.javamcp;

import org.javamcp.clients.JenkinsClient;
import org.javamcp.clients.JiraClient;
import org.javamcp.services.JiraService;
import org.javamcp.tools.CreateJiraBugTool;
import org.javamcp.helpers.EnvironmentProperties;
import org.javamcp.tools.RunApiTestsTool;
import org.javamcp.tools.RunUiTestsTool;
import org.javamcp.tools.GetTestStatusTool;
import org.javamcp.services.TestExecutionService;
import io.modelcontextprotocol.json.McpJsonDefaults;
import io.modelcontextprotocol.server.McpServer;
import io.modelcontextprotocol.server.McpSyncServer;
import io.modelcontextprotocol.server.transport.StdioServerTransportProvider;
import io.modelcontextprotocol.spec.McpSchema;
import java.util.concurrent.CountDownLatch;

public class Application {

    public static void main(String[] args)
            throws InterruptedException {

        /*
         * ==========================================
         * 1. LOAD CONFIGURATION
         * ==========================================
         */
        EnvironmentProperties properties = new EnvironmentProperties();

        String jenkinsUrl =
                properties.loadProp("JENKINS_URL");

        String jenkinsUser =
                properties.loadProp("JENKINS_USER");

        String jenkinsToken =
                properties.loadProp("JENKINS_TOKEN");


        /*
         * ==========================================
         * 2. CREATE JENKINS CLIENT
         * ==========================================
         */

        JenkinsClient jenkinsClient =
                new JenkinsClient(
                        jenkinsUrl,
                        jenkinsUser,
                        jenkinsToken
                );

        /*
         * ==========================================
         * 3. CREATE MCP TRANSPORT
         * ==========================================
         */

        StdioServerTransportProvider transport =
                new StdioServerTransportProvider(
                        McpJsonDefaults.getMapper()
                );


        /*
         * ==========================================
         * 4. CREATE MCP SERVER
         * ==========================================
         */

        McpSyncServer server =
                McpServer
                        .sync(transport)

                        .serverInfo(
                                "qa-automation-mcp",
                                "1.0.0"
                        )

                        .capabilities(
                                McpSchema.ServerCapabilities
                                        .builder()
                                        .tools(true)
                                        .build()
                        )

                        .build();


        /*
         * ==========================================
         * 5. CREATE MCP TOOLS
         * ==========================================
         */

        TestExecutionService service = new TestExecutionService(jenkinsClient);

        CreateJiraBugTool createJiraBugTool = new CreateJiraBugTool(environment -> {
            EnvironmentProperties jiraProperties = new EnvironmentProperties(environment);
            JiraClient jiraClient = new JiraClient(
                    jiraProperties.loadEnvOrProp("JIRA_BASE_URL"),
                    jiraProperties.loadEnvOrProp("JIRA_EMAIL"),
                    jiraProperties.loadEnvOrProp("JIRA_API_TOKEN")
            );
            return new JiraService(jiraClient, jiraProperties.loadEnvOrProp("JIRA_PROJECT_KEY"));
        });

        RunApiTestsTool runApiTestsTool =
                new RunApiTestsTool(
                        service
                );

        RunUiTestsTool runUiTestsTool =
                new RunUiTestsTool(
                        service
                );


        /*
         * ==========================================
         * 6. REGISTER MCP TOOLS
         * ==========================================
         */

        server.addTool(runApiTestsTool.create());
        server.addTool(runUiTestsTool.create());
        server.addTool(new GetTestStatusTool(service).create());
        server.addTool(createJiraBugTool.create());

        /*
         * ==========================================
         * 7. GRACEFUL SHUTDOWN
         * ==========================================
         */

        Runtime
                .getRuntime()
                .addShutdownHook(
                        new Thread(() -> {

                            System.err.println(
                                    "Stopping QA MCP server..."
                            );

                            server.close();
                        })
                );


        System.err.println(
                "QA MCP server started."
        );


        /*
         * ==========================================
         * 8. KEEP PROCESS ALIVE
         * ==========================================
         */

        new CountDownLatch(1).await();
    }
}
