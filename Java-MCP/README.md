# Java MCP Server for Jenkins Test Runs and Jira Bugs

A Java 21 stdio MCP server that lets MCP clients trigger Jenkins tests, check build status, and create Jira Cloud bugs.

| Tool | Purpose |
|---|---|
| `run_api_tests` | Start an API test job in Jenkins |
| `run_ui_tests` | Start a UI test job with a browser selection |
| `get_test_status` | Look up a queued or running Jenkins build |
| `create_jira_bug` | Create a Jira Bug with optional test failure details |

## Build

Install JDK 21 and Maven, then run from the project root:

```powershell
mvn clean package
```

Maven Shade packages the application and its dependencies into:

```text
target/Java-MCP-1.0-SNAPSHOT.jar
```

The entry point is `org.javamcp.Application`. The project uses MCP Java SDK 2.0.1, managed through `mcp-bom`, and Java's HTTP client. The executable integration checks require separate commands described below; `mvn test` alone does not run them.

## Project structure

```text
MCP client / Inspector
       |
       | MCP over stdin/stdout
       v
Java MCP server
       +-- Tool handlers: schemas and input validation
       +-- Services: job selection and Jira request construction
       +-- HTTP clients: authentication, requests and responses
               +-- Jenkins
               +-- Jira Cloud
```

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

## Configuration

Both Jenkins and Jira support environment variables with properties-file fallback. A nonblank environment variable takes precedence over the corresponding property. A missing or blank environment variable falls back to the file.

| Setting | Purpose | Required |
|---|---|---|
| `JENKINS_URL` | Jenkins server URL, for example `http://localhost:8090` | At startup |
| `JENKINS_USER` | Jenkins username | At startup |
| `JENKINS_TOKEN` | That user's Jenkins API token | At startup |
| `JIRA_BASE_URL` | Jira Cloud site URL, for example `https://yourcompany.atlassian.net` | When creating a bug |
| `JIRA_EMAIL` | Jira account email | When creating a bug |
| `JIRA_API_TOKEN` | Jira API token compatible with Basic authentication at the site URL | When creating a bug |
| `JIRA_PROJECT_KEY` | Target Jira project key | When creating a bug |

`EnvironmentProperties` loads classpath resources from `src/main/resources`. Its no-argument constructor selects `qa.properties`. The selected resource must exist even when all values are supplied through environment variables.

For local development, properties can contain:

```properties
JENKINS_URL=http://localhost:8090
JENKINS_USER=
JENKINS_TOKEN=
JIRA_BASE_URL=https://yourcompany.atlassian.net
JIRA_EMAIL=
JIRA_API_TOKEN=
JIRA_PROJECT_KEY=
```

Resources are bundled into the JAR. Keep real credentials out of source and packaged resources; inject them through the MCP client's environment configuration. Existing `YOUR_*` placeholders are nonblank strings and do not count as missing values; replace or clear them.

### Jenkins configuration

`Application` loads Jenkins settings once at startup using `loadRequiredEnvOrProp`. If any required value resolves to null or blank, startup fails with a message naming the setting and explaining where to configure it.

Jenkins uses the startup connection for both QA and staging. The tool's `environment` argument selects a job on that server; it does not switch Jenkins credentials or load `staging.properties`.

### Jira configuration

For each `create_jira_bug` call, the application loads `qa.properties` or `staging.properties` according to the requested environment, then applies environment-variable overrides. Omitting the environment defaults to `qa`.

Only `qa.properties` is currently included. Add `src/main/resources/staging.properties` and rebuild before using staging for Jira. Environment variable names are shared between environments, so their values override either file.

Missing Jira settings are reported when creating a bug, allowing the Jenkins tools to start without Jira configured.

## Connect an MCP client

Configure the client to launch `java` with the JAR's absolute path and supply settings through its process environment. For a client that uses an `mcpServers` configuration, the entry looks like:

```json
{
  "mcpServers": {
    "qa-automation": {
      "command": "java",
      "args": ["-jar", "C:/path/to/Java-MCP/target/Java-MCP-1.0-SNAPSHOT.jar"],
      "env": {
        "JENKINS_URL": "http://localhost:8090",
        "JENKINS_USER": "your-jenkins-user",
        "JENKINS_TOKEN": "your-jenkins-user-api-token",
        "JIRA_BASE_URL": "https://yourcompany.atlassian.net",
        "JIRA_EMAIL": "you@example.com",
        "JIRA_API_TOKEN": "your-jira-api-token",
        "JIRA_PROJECT_KEY": "MCP"
      }
    }
  }
}
```

Use the configuration structure required by your MCP client; wrappers and filenames vary. Replace the example path and values. Reconnect or restart the MCP server after changing its environment. Rebuild and reconnect after changing code or packaged properties.

For interactive inspection, with Node.js and npm installed:

```powershell
npx @modelcontextprotocol/inspector
```

Select stdio, set the command to `java`, and pass `-jar` followed by the absolute JAR path. Supply the configuration variables to the launched server, then connect and list tools.

## Jenkins credentials and job names

Use a personal API token generated for `JENKINS_USER`. A Git plugin `notifyCommit` token does not authenticate these build requests.

`TestExecutionService` defines the job names with these constants:

```java
private static final String API_JOB_NAME_TEMPLATE = "%s E2E API test";
private static final String UI_JOB_NAME_TEMPLATE = "%s UI regression";
```

The service substitutes the validated environment using `.formatted(environment)`:

| Environment | API job | UI job |
|---|---|---|
| `qa` | `qa E2E API test` | `qa UI regression` |
| `staging` | `staging E2E API test` | `staging UI regression` |

Create Jenkins jobs with these exact names, or update the constants to match your jobs and rebuild. Configure each job to run tests against the intended environment; the name alone does not configure a test framework's target URL. Folder paths and spaces in job names are encoded by the client.

API jobs take no parameters and use an empty POST to `/build`. UI jobs use `/buildWithParameters` and send `BROWSER`. Enable **This project is parameterized** on each UI job and define a choice parameter named `BROWSER` with these values:

```text
chromium
firefox
```

The build step must pass `BROWSER` to the test framework. No `ENVIRONMENT` build parameter is sent.

Trigger results include the job name and queue ID. A queue ID is not a build number: `get_test_status` checks the queue first, then looks up the assigned build. Possible statuses are `QUEUED`, `RUNNING`, `PASSED`, `FAILED`, `UNSTABLE`, `ABORTED`, and `UNKNOWN`. Jenkins can eventually expire queue information.

## Jira bug creation

The configured account must have permission to create issues in the project, and the project must support an issue type named `Bug`. Project-specific required custom fields are not discovered automatically; Jira may reject requests that need them.

`CreateJiraBugTool` has one constructor accepting `Function<String, JiraService>`. `Application` supplies a factory that creates a service from the selected environment's configuration.

The tool requires a nonblank summary of at most 255 characters and a nonblank description. Optional inputs are `priority`, `environment`, `failedTestName`, `jenkinsBuildUrl`, and `stackTrace`.

The resolved environment is passed both to the service factory and to `JiraBugInput`. Omitting it therefore selects QA and adds `Environment: qa` to the issue description. Environment is included in the description, rather than Jira's dedicated Environment field.

Plain text and failure details are converted into Atlassian Document Format paragraphs; stack traces use a code block. Priority is a Jira priority name such as `High`; omitting it keeps Jira's default. A successful response includes `issueKey`, `issueId`, and `issueUrl`.

Bug creation is invoked separately from Jenkins execution. The server does not automatically create bugs after failed tests or deduplicate issues. Creation requests are not retried automatically; after an uncertain network result, check Jira before retrying.

## Example tool arguments

These are argument objects supplied to the named tool, not full JSON-RPC requests.

Run QA API tests with `run_api_tests`:

```json
{"environment": "qa"}
```

Run QA UI tests with `run_ui_tests`:

```json
{"environment": "qa", "browser": "chromium"}
```

Both test tools require `environment`, accepting `qa` or `staging`. UI tests also require `browser`, accepting `chromium` or `firefox`.

Check execution with `get_test_status`, using the exact job name and queue ID returned by the trigger:

```json
{"jobName": "qa E2E API test", "queueId": 42}
```

Create an issue with `create_jira_bug`:

```json
{
  "summary": "Login API returns an unexpected status",
  "description": "Expected HTTP 401 but received HTTP 500.",
  "priority": "High",
  "environment": "qa",
  "failedTestName": "LoginApiTest.invalidCredentials",
  "jenkinsBuildUrl": "http://localhost:8090/job/qa%20E2E%20API%20test/42/",
  "stackTrace": "AssertionError: expected 401 but received 500"
}
```

Use the actual Jenkins build URL; the example's build number is illustrative and must not be inferred from a queue ID.

## Logging and troubleshooting

Standard output carries MCP protocol messages. Application diagnostics go to stderr, including the default `java.util.logging` console output.

| Symptom | Check |
|---|---|
| Missing required configuration at startup | Supply the named Jenkins setting through environment variables or `qa.properties` |
| Missing environment configuration | Add the requested properties resource and rebuild, even when injecting values through environment variables |
| Jenkins HTTP 401 | Use the Jenkins user's personal API token and correct username |
| Jenkins job not found | Match job names to the constants, including the environment prefix and any folder path |
| Jenkins says the job is not parameterized | Define the UI job's `BROWSER` parameter |
| Jira reports an invalid issue type | Make `Bug` available in the configured project |
| Configuration changes have no effect | Rebuild for resource changes and restart the MCP process for environment changes |

## Local integration checks

The project contains executable Java checks using local mock HTTP servers and dummy credentials. They exercise Jenkins requests and status handling, Jira serialization and errors, and MCP tool registration. They do not verify permissions or job setup on live services.

Run from PowerShell:

```powershell
mvn -q test-compile dependency:build-classpath '-Dmdep.outputFile=target/test-classpath.txt'
if ($LASTEXITCODE -ne 0) { throw "Test compilation failed" }

$testClasspath = 'target/classes;target/test-classes;' +
    (Get-Content target/test-classpath.txt -Raw).Trim()

java -cp $testClasspath org.javamcp.JiraIntegrationTest
if ($LASTEXITCODE -ne 0) { throw "Jira checks failed" }

java -cp $testClasspath org.javamcp.TestExecutionIntegrationTest
if ($LASTEXITCODE -ne 0) { throw "Jenkins checks failed" }
```
