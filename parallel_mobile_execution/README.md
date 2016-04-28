## Description

Bash script that is used for running parallel mobile tests (written in RSpec or TestNG) on real Android devices

Note: Support for iOS is not currently available

## Usage

```
bash runner.sh ${TEST_FRAMEWORK} ${ABSOLUTE_PATH_TO_TESTS_DIRECTORY} ${ABSOLUTE_PATH_TO_APPIUM_SERVER_DIRECTORY} ${APPIUM_OUTPUT_LOGS} ${TEST_OUTPUT_LOGS}
```

## Testng configuration

Tests written in java with testng are configured with the maven surefire plugin. The plugin should be configured to expect the following properties:
- device udid (UDID)
- device platform version (PLATFORM_VERSION)
- appium port (PORT)
- folder for surefire test reports (TEST_OUTPUT)

```
<plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>2.19.1</version>
        <configuration>
            <reportsDirectory>${TEST_OUTPUT}</reportsDirectory>
            <systemPropertyVariables>
                <udid>${UDID}</udid>
                <port>${PORT}</port>
                <platformVersion>${PLATFORM_VERSION}</platformVersion>
            </systemPropertyVariables>
        </configuration>
    </plugin>
    ...
</plugins>
```

The properties are then retrieved when setting the desired capabilities of the test and initializing the AndroidDriver.

```
DesiredCapabilities capabilities = new DesiredCapabilities();
capabilities.setCapability("platformVersion", System.getProperty("platformVersion"));
capabilities.setCapability("udid", System.getProperty("udid"));

URL appiumURL = new URL("http://127.0.0.1:" + System.getProperty("port") + "/wd/hub");

driver = new AndroidDriver(appiumURL, capabilities);
```
