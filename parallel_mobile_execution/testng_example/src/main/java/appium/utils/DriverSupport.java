package appium.utils;

import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.concurrent.TimeUnit;


public class DriverSupport {
    private static AndroidDriver driver;

    public static AndroidDriver initDriver() throws MalformedURLException {
        DesiredCapabilities capabilities = new DesiredCapabilities();
        capabilities.setCapability("platformName", "Android");
        capabilities.setCapability("platformVersion", System.getProperty("platformVersion"));
        capabilities.setCapability("deviceName", "Android");
        capabilities.setCapability("udid", System.getProperty("udid"));
        capabilities.setCapability("app", System.getProperty("user.dir") + "/571-release.apk");
        capabilities.setCapability("appActivity", "com.atlantbh.navigator.MainActivity");
        capabilities.setCapability("appWaitActivity", "com.atlantbh.navigator.HomeActivity");

        URL appiumURL = new URL("http://127.0.0.1:" + System.getProperty("port") + "/wd/hub");

        driver = new AndroidDriver(appiumURL, capabilities);
        driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS);

        return driver;
    }
}

