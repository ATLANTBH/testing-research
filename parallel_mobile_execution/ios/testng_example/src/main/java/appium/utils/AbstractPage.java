package appium.utils;

import io.appium.java_client.ios.IOSDriver;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import org.openqa.selenium.support.PageFactory;

import java.util.concurrent.TimeUnit;

public class AbstractPage {
    private IOSDriver driver;

    public AbstractPage() {
    }

    public AbstractPage(IOSDriver driver) {
        this.driver = driver;
    }

    public IOSDriver getDriver() {
        return driver;
    }

    public void initElements() {
        AppiumFieldDecorator decorator = new AppiumFieldDecorator(driver, 10, TimeUnit.SECONDS);
        PageFactory.initElements(decorator, this);
    }

}

