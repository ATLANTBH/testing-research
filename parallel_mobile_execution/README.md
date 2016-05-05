## Description

This POC shows ability to run mobile tests on multiple real Android devices in parallel. Main engine for this parallel execution is in bash script `runner.sh`. This bash script is used for running parallel mobile tests written in RSpec or TestNG in conjuction with Appium as mobile framework. This projects gives examples in both TestNG and RSpec on how to configure test scripts that could be executed in parallel

Note: Support for iOS is not currently available

## Usage

```
bash runner.sh ${TEST_FRAMEWORK} ${ABSOLUTE_PATH_TO_TESTS_DIRECTORY} ${ABSOLUTE_PATH_TO_APPIUM_SERVER_DIRECTORY} ${APPIUM_OUTPUT_LOGS} ${TEST_OUTPUT_LOGS}
```

## Testng configuration

Tests written in Java with TestNG are configured with the maven surefire plugin. The plugin should be configured to expect the following properties:
- device udid (UDID)
- device platform version (PLATFORM_VERSION)
- appium port (PORT)
- folder for surefire test reports (TEST_OUTPUT)

The device udid, device platform version and appium port are generated inside `runner.sh` script, while test output folder is passed as an argument to `runner.sh` script (see Usage).

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

## RSpec configuration

Tests written in Ruby with RSpec are configured inside spec_helper.rb file. Following method is used for configuration:

```
def desired_caps
  {
    caps: {
      platformName: "Android",
      platformVersion: ENV['PLATFORM_VERSION'],
      udid: ENV['UDID'],
      deviceName: "Android",
      app: ENV['APP_FILE'],
      appActivity: "com.atlantbh.navigator.MainActivity",
      appWaitActivity: "com.atlantbh.navigator.HomeActivity"
      },
    appium_lib: {
      debug: true,
      wait: 30,
      export_session: true,
      server_url: "http://localhost:#{ENV['PORT']}/wd/hub/"
    }
  }
end
```

Following properties need to be configured:
- device udid (UDID)
- device platform version (PLATFORM_VERSION)
- appium port (PORT)
- application file (APP_FILE)
- folder for RSpec test output (TEST_OUTPUT)

The device udid, device platform version and appium port are generated inside `runner.sh` script, while application file location needs to be set as environment variable (`export APP_FILE=PATH_TO_APK_FILE`) before running `runner.sh` script. Also, test output folder is passed as an argument to `runner.sh` script (see Usage).
