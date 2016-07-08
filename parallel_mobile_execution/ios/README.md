## Description

For help on building iOS apps for testing see the [iOS Build cheatsheet](https://github.com/ATLANTBH/testing-research/wiki/iOS-Build-cheatsheet)

This POC shows ability to run mobile tests on multiple real iOS devices in parallel. Main engine for this parallel execution is in bash script `ios_runner.sh`. This script is used for installing *.app on attached devices and running parallel mobile tests written in RSpec or TestNG in conjuction with Appium as mobile framework. This projects gives examples in both TestNG and RSpec on how to configure test scripts that could be executed in parallel.

## Usage

```
bash ios_runner.sh ${TEST_FRAMEWORK} ${ABSOLUTE_PATH_TO_TESTS_DIRECTORY} ${APPIUM_OUTPUT_LOGS} ${TEST_OUTPUT_LOGS} ${INSTRUMENTS_OUTPUT} ${ABSOLUTE_PATH_TO_APP_FILE}
```

## TestNG configuration

Tests written in Java with TestNG are configured with the maven surefire plugin. The plugin should be configured to expect the following properties:
- device udid (UDID)
- appium port (PORT)
- folder for surefire test reports (TEST_OUTPUT)

The device udid and appium port are generated inside `ios_runner.sh` script, while test output folder is passed as an argument to `ios_runner.sh` script (see Usage).

```
<plugins>
	<plugin>
		<groupId>org.apache.maven.plugins</groupId>
		<artifactId>maven-surefire-plugin</artifactId>
		<version>2.19.1</version>
		<configuration>
			<reportsDirectory>${TEST_OUTPUT}</reportsDirectory>
			<suiteXmlFiles>
				<suiteXmlFile>smokeTest.xml</suiteXmlFile>
			</suiteXmlFiles>
			<systemPropertyVariables>
				<udid>${UDID}</udid>
               	<port>${PORT}</port>
         	</systemPropertyVariables>
   		</configuration>
    </plugin>
</plugins>
```

The properties are then retrieved when setting the desired capabilities of the test and initializing the IOSDriver. The app file argument is used with `ios-deploy` to install the app to the connected devices prior running the tests, while appium uses the app bundle id to run the app.

```
DesiredCapabilities capabilities = new DesiredCapabilities();
capabilities.setCapability("platformName", "iOS");
capabilities.setCapability("deviceName", "iPhone");
capabilities.setCapability("udid", System.getProperty("udid"));
capabilities.setCapability("bundleId", "com.company.app");

URL appiumURL = new URL("http://127.0.0.1:" + System.getProperty("port") + "/wd/hub");

driver = new IOSDriver(appiumURL, capabilities);
```

## RSpec configuration

Tests written in Ruby with RSpec are configured inside spec_helper.rb file. Following method is used for configuration:

```
def desired_caps
  {
    caps: {
      platformName: "iOS",
      deviceName: "iPhone",
      bundleId: "com.company.app",
      udid: ENV['UDID'],
      nativeInstrumentsLib: true
      },
    appium_lib: {
      debug: true,
      wait: 30,
      export_session: true,
      server_url: "http://127.0.0.1:#{ENV['PORT']}/wd/hub"
    }
  }
end
```

Following properties need to be configured:
- device udid (UDID)
- appium port (PORT)
- application file (APP_FILE)
- folder for RSpec test output (TEST_OUTPUT)
- folder for Instruments library output (INSTRUMENTS_OUTPUT)

The device udid and appium port are generated inside `ios_runner.sh` script. App file path, test output folder and instruments output are passed as arguments to `ios_runner.sh` script (see Usage). The app file argument is used with `ios-deploy` to install the app to the connected devices prior running the tests, while appium uses the app bundle id to run the app.