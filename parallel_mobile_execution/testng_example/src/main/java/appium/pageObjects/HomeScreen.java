package appium.pageObjects;


import appium.utils.AbstractPage;
import io.appium.java_client.TouchAction;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.AndroidElement;
import io.appium.java_client.pagefactory.AndroidFindBy;
import org.openqa.selenium.Point;

public class HomeScreen extends AbstractPage {

    public HomeScreen(AndroidDriver driver) {
        super(driver);
        initElements();
    }

    @AndroidFindBy(id = "com.atlantbh.navigator:id/nav_button_search")
    private AndroidElement searchButton;

    @AndroidFindBy(id = "com.atlantbh.navigator:id/search_input_custom")
    private AndroidElement searchInput;

    public AndroidElement getSearchButton() {
        return searchButton;
    }

    public AndroidElement getSearchInput() {
        return searchInput;
    }

    public void tapFirstSearchResult() {
        AndroidElement searchIn = getSearchInput();
        Point searchPos = searchIn.getLocation();
        int height = searchIn.getSize().getHeight();
        TouchAction touchAction = new TouchAction(getDriver());
        touchAction.tap(searchPos.getX() + 100, searchPos.getY() + height + height/2).perform();
    }
}
