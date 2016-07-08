package appium.pageObjects;

import appium.utils.AbstractPage;
import io.appium.java_client.TouchAction;
import io.appium.java_client.ios.IOSDriver;
import io.appium.java_client.ios.IOSElement;
import io.appium.java_client.pagefactory.iOSFindBy;


public class HomeScreen extends AbstractPage {
    public HomeScreen(IOSDriver driver) {
        super(driver);
        initElements();
    }

    public IOSElement getTile(String tileName) {
        return (IOSElement) getDriver().findElementByAccessibilityId(tileName);
    }

    public void swipeToBottom() {
        TouchAction touchAction = new TouchAction(getDriver());
        touchAction.press(200, 500).moveTo(50, -400).release().perform();
    }
}
