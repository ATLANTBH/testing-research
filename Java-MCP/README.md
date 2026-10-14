# Building a Java MCP Server for Jenkins Test Runs and Jira Bugs

| Tool | Purpose |
|---|---|
| `run_api_tests` | Start an API test job in Jenkins |
| `run_ui_tests` | Start a UI test job with a browser selection |
| `get_test_status` | Look up a queued or running Jenkins build |
| `create_jira_bug` | Create a Jira Bug with optional test failure details |

# To build this project and get JAR file for MCP usage in Agent AI technologies such as Copilot or Claude use following command

-------
    `mvn clean package`

## 1. Project structure

The project uses Java 21, Maven, MCP Java SDK 2.0.1, and Java's HTTP client.

The MCP connection uses standard input and output. Jenkins and Jira are reached through HTTP requests from the Java process.

```text
MCP client / Inspector
        |
        | MCP over stdin/stdout
        v
Java MCP server
        |
        +-- Tool handlers: schemas and input validation
        +-- Services: job selection and Jira request construction
        +-- HTTP clients: authentication, requests and responses
                |
                +-- Jenkins
                +-- Jira Cloud
```

The main packages are:

```text
src/main/java/org/javamcp/
  Application.java
  clients/
    JenkinsClient.java
    JiraClient.java
  helpers/
    EnvironmentProperties.java
  models/
  services/
    TestExecutionService.java
    JiraService.java
  tools/
    RunApiTestsTool.java
    RunUiTestsTool.java
    GetTestStatusTool.java
    CreateJiraBugTool.java
    ToolResponses.java
```

Each tool validates its arguments and delegates to a service. The service determines what to do, and the HTTP client handles communication with the external system.

## 2. Configure Maven and the executable JAR

The Maven group matches the Java package:

```xml
<groupId>org.javamcp</groupId>
<artifactId>Java-MCP</artifactId>
<version>1.0-SNAPSHOT</version>

<properties>
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>
    <mcp.version>2.0.1</mcp.version>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
```

The SDK version is managed through its BOM:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.modelcontextprotocol.sdk</groupId>
            <artifactId>mcp-bom</artifactId>
            <version>${mcp.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>io.modelcontextprotocol.sdk</groupId>
        <artifactId>mcp</artifactId>
    </dependency>
</dependencies>
```

To package the application with its dependencies, I added this plugin inside `build/plugins`:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.6.0</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>org.javamcp.Application</mainClass>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```

The main class must match the actual package declaration. An earlier value, `com.org.javamcp.Application`, did not match the source.

## 3. Add local configuration

For the local setup, configuration is loaded from `src/main/resources/qa.properties`:

```properties
JENKINS_URL=http://localhost:8090
JENKINS_USER=admin
JENKINS_TOKEN=YOUR_JENKINS_USER_API_TOKEN

JIRA_BASE_URL=https://yourcompany.atlassian.net
JIRA_EMAIL=YOUR_JIRA_PROJECT_EMAIL
JIRA_API_TOKEN=YOUR_JIRA_API_TOKEN
JIRA_PROJECT_KEY=YOUR_JIRA_PROJECT_KEY
```

These are local development values. Resource files are packaged into the JAR, so real credentials must not be published with the source or the built artifact.

The environment loader accepts QA or staging and opens the corresponding classpath resource:

```java
public EnvironmentProperties(String environment) {
    if (!"qa".equals(environment) && !"staging".equals(environment)) {
        throw new IllegalArgumentException(
                "environment must be one of: qa, staging.");
    }
    try (InputStream environmentalPropFile = Application.class
            .getClassLoader()
            .getResourceAsStream(environment + ".properties")) {
        if (environmentalPropFile == null) {
            throw new IllegalArgumentException(
                    "Missing environment configuration: "
                            + environment + ".properties");
        }
        this.properties.load(environmentalPropFile);
    } catch (IOException ioException) {
        throw new IllegalArgumentException(
                "Unable to load environment configuration: "
                        + environment + ".properties", ioException);
    }
}
```

The no-argument constructor defaults to QA. Jira configuration also supports nonblank environment-variable overrides:

```java
public String loadEnvOrProp(String property) {
    String value = System.getenv(property);
    return value == null || value.isBlank() ? loadProp(property) : value;
}
```

There are two distinct environment behaviors in this implementation:

- Jenkins connects to the server configured at startup from `qa.properties`. The tool's environment selects a job-name prefix on that server.
- Jira loads `qa.properties` or `staging.properties` for each request. Omitting the Jira environment selects QA.

To use staging for Jira, add `staging.properties`. The file must exist even when Jira environment-variable overrides are supplied. Those overrides use the same names for both environments, so they take precedence over either file.

## 4. Configure Jenkins credentials and jobs

Jenkins authenticates scripted build requests using the username and that user's API token. See [Jenkins scripted-client authentication](https://www.jenkins.io/doc/book/system-administration/authenticating-scripted-clients/).

I initially used a token from **Git plugin notifyCommit access tokens**. That token is intended for Git notifications, and the build requests returned HTTP 401. The working credential needs to come from the Jenkins user's personal API token settings.

Log in as the intended user, open the user menu, and select **Security** or **Configure**, depending on the Jenkins version. Generate a user API token and put it in `JENKINS_TOKEN`. The global Security page's legacy-token checkboxes are not the token-generation form.

For this project, job names follow this convention:

| Environment | API job | UI job |
|---|---|---|
| QA | `qa E2E API test` | `qa UI regression` |
| Staging | `staging E2E API test` | `staging UI regression` |

Create or rename the Jenkins jobs to match those names exactly. Configure each job's build steps to run the appropriate test suite against its environment. The prefix selects a job; it does not configure the test framework's target URL automatically.

API jobs take no parameters. For UI jobs, enable **This project is parameterized** and add a choice parameter named `BROWSER`, with one choice per line:

```text
chromium
firefox
```

The UI job's build step must pass that value into the test framework.

## 5. Route Jenkins requests by environment

The service builds the job name from the validated environment:

```java
public TestExecution runApiTests(String environment) throws IOException {
    return trigger(environment + " E2E API test", "");
}

public TestExecution runUiTests(String environment, String browser)
        throws IOException {
    return trigger(environment + " UI regression",
            "BROWSER=" + encode(browser));
}

private TestExecution trigger(String jobName, String parameters)
        throws IOException {
    return new TestExecution(
            jobName,
            jenkinsClient.triggerJob(jobName, parameters),
            "Test execution triggered successfully.");
}
```

There is no `ENVIRONMENT` build parameter. Only UI runs send `BROWSER`.

The client chooses the endpoint according to whether parameters are present:

```java
boolean hasParameters = parameters != null && !parameters.isBlank();
HttpResponse<String> response = send(
        jobPath(jobName) + (hasParameters ? "/buildWithParameters" : "/build"),
        hasParameters ? parameters : "");
```

The empty string matters: in the client's `send` method, `null` means GET, while a non-null body means POST. API jobs therefore use an empty POST to `/build`.

Job names may contain spaces or folder paths, so the client encodes each path segment:
After a successful submission, the client extracts the queue ID from Jenkins' `Location` header. The tool returns that ID together with the full job name.

For example, an illustrative result is:

```json
{
  "jobName": "qa E2E API test",
  "queueId": 42,
  "message": "Test execution triggered successfully."
}
```

A queue ID is not a build number. The status tool first queries the queue item, then looks up the build once Jenkins assigns an executable. The returned states include `QUEUED`, `RUNNING`, `PASSED`, `FAILED`, `UNSTABLE`, `ABORTED`, and `UNKNOWN`.

## 6. Define the MCP tool schema and handler

The UI tool declares the accepted environments and browsers:

The handler validates the arguments as well as publishing the schema. Successful responses include structured content and a text representation; failures use MCP's `isError` flag.

For API and UI tool definitions, I replaced the deprecated no-argument `McpSchema.Tool.builder()` with `builder(name, inputSchema)`. The Jira and status tool definitions in this snapshot still use the older overload.

## 7. Prepare Jira Cloud

The Jira integration requires an account email, an API token compatible with Basic authentication at the configured site URL, and a project key. The account needs access to the project and permission to create issues. [Atlassian's authentication documentation](https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/) explains this authentication method.

The service explicitly requests an issue type named `Bug`. That type must be available in the target project.

In a team-managed Jira space, open **Space settings → Work types**, then add **Bug**. Company-managed spaces use administrator-managed work type schemes. See [Atlassian's team-managed work type instructions](https://support.atlassian.com/jira-software-cloud/docs/set-up-issue-types-in-team-managed-projects/).

This caused one of the setup failures: authentication succeeded, but the project offered Epic, Subtask, Task, and Story without Bug. Jira rejected creation with:

```text
HTTP 400
issuetype: Specify a valid issue type
```

Adding Bug to the project resolved that issue; changing the token would not have fixed it.

## 8. Select Jira configuration per request

The tool receives a factory that creates a service for the requested environment:

```java
CreateJiraBugTool createJiraBugTool = new CreateJiraBugTool(environment -> {
    EnvironmentProperties jiraProperties =
            new EnvironmentProperties(environment);
    JiraClient jiraClient = new JiraClient(
            jiraProperties.loadEnvOrProp("JIRA_BASE_URL"),
            jiraProperties.loadEnvOrProp("JIRA_EMAIL"),
            jiraProperties.loadEnvOrProp("JIRA_API_TOKEN"));
    return new JiraService(
            jiraClient, jiraProperties.loadEnvOrProp("JIRA_PROJECT_KEY"));
});
```

Inside the handler, the environment is validated and defaults to QA:

```java
String environment = arguments.containsKey("environment")
        ? ToolResponses.requiredString(
                arguments, "environment", "qa", "staging")
        : "qa";
```

The tool requires a summary and description. Optional fields include priority, environment, failed test name, Jenkins build URL, and stack trace.

## 9. Convert the description and submit the Jira request

The service converts plain text into an Atlassian Document Format document. It adds failure context as paragraphs and stack traces as code blocks.

This excerpt constructs the issue after those blocks have been assembled:

```java
JiraCreateIssueRequest request = new JiraCreateIssueRequest(new Fields(
        new Project(projectKey.strip()),
        new NamedValue("Bug"),
        input.summary(),
        new Document("doc", 1, content),
        priority));
JiraIssueResponse created = jiraClient.createIssue(request);
return new CreatedJiraBug(
        created.key(), created.id(), jiraClient.issueUrl(created.key()));
```

The HTTP client serializes the request using the SDK's mapper and sends it to Jira:

The implementation expects HTTP 201, then validates the returned issue ID and key. It returns the issue key, ID, and browse URL to the MCP client.

## 10. Add useful logging without breaking stdio

Standard output carries MCP messages, so application diagnostics must go to stderr. I used `java.util.logging`, whose default console handler writes to stderr.

Previously ignored parsing errors now produce a warning with the operation, HTTP status, and exception type:

The client also limits the length of returned error details. Creation requests are not retried automatically: a timeout can occur after the server has already accepted the operation.

## 11. Start the MCP server and register tools

The application creates a synchronous server with the stdio transport:
Here, `service` is the previously constructed `TestExecutionService`. The application stays alive while the MCP client communicates with it.

## 12. Build and connect with Inspector

Build from the project root:

```powershell
mvn -DskipTests package
```

The executable artifact is:

```text
target/Java-MCP-1.0-SNAPSHOT.jar
```

With Node.js and npm installed, launch [MCP Inspector](https://github.com/modelcontextprotocol/inspector):

```powershell
npx @modelcontextprotocol/inspector
```

In Inspector, configure a stdio connection with:

- Command: `java`
- Arguments: `-jar C:/path/to/Java-MCP/target/Java-MCP-1.0-SNAPSHOT.jar`

Use your actual absolute path and quote it if it contains spaces. Connect and list the available tools.

The following examples are tool argument objects, not full JSON-RPC envelopes.

Start QA API tests with `run_api_tests`:

```json
{"environment": "qa"}
```

Start QA UI tests with `run_ui_tests`:

```json
{"environment": "qa", "browser": "chromium"}
```

Call `get_test_status` using the exact job name and queue ID returned by the trigger:

```json
{"jobName": "qa E2E API test", "queueId": 42}
```

Create a bug with `create_jira_bug`:

```json
{
  "summary": "Login API returns an unexpected status",
  "description": "Expected HTTP 401 but received HTTP 500.",
  "environment": "qa",
  "failedTestName": "LoginApiTest.invalidCredentials",
  "jenkinsBuildUrl": "http://localhost:8090/job/qa%20E2E%20API%20test/42/",
  "stackTrace": "AssertionError: expected 401 but received 500"
}
```

The build URL is illustrative: use the actual build URL from Jenkins, not the queue ID.

Tool calls submit real jobs and tickets when connected to real services. Start with a designated test job and a clearly labeled diagnostic issue.
