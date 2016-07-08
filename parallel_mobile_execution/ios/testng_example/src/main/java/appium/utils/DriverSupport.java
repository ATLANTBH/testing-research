package appium.utils;

import io.appium.java_client.ios.IOSDriver;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.TimeUnit;


public class DriverSupport {
    private static IOSDriver driver;

    public static IOSDriver initDriver() throws MalformedURLException {
        DesiredCapabilities capabilities = new DesiredCapabilities();
        capabilities.setCapability("platformName", "iOS");
        capabilities.setCapability("deviceName", "iPhone");
        capabilities.setCapability("udid", System.getProperty("udid"));
        capabilities.setCapability("bundleId", "com.company.app");

        URL appiumURL = new URL("http://127.0.0.1:" + System.getProperty("port") + "/wd/hub");

        driver = new IOSDriver(appiumURL, capabilities);
        driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);

        return driver;
    }
}

