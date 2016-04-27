package appium.utils;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.pagefactory.AppiumFieldDecorator;
import org.openqa.selenium.support.PageFactory;

import java.util.concurrent.TimeUnit;

public class AbstractPage {
    private AndroidDriver driver;

    public AbstractPage() {
    }

    public AbstractPage(AndroidDriver driver) {
        this.driver = driver;
    }

    public AndroidDriver getDriver() {
        return driver;
    }

    public void initElements() {
        AppiumFieldDecorator decorator = new AppiumFieldDecorator(driver, 10, TimeUnit.SECONDS);
        PageFactory.initElements(decorator, this);
    }

}

