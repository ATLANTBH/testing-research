import appium.pageObjects.HomeScreen;
import appium.utils.DriverSupport;
import io.appium.java_client.ios.IOSDriver;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class SmokeTest {
    private IOSDriver driver;
    private HomeScreen homeScreen;

    @BeforeClass
    public void setUp() throws Exception {
        driver = DriverSupport.initDriver();
        homeScreen = new HomeScreen(driver);
    }

    @Test(priority = 1)
    public void openHomeScreen() {
        try {
            homeScreen.getTile("Attractions");
            Assert.assertTrue(true);
        } catch (NoSuchElementException e) {
            Assert.fail("NoSuchElementException: Search input field not found");
        }
    }

    @Test(dependsOnMethods = {"openHomeScreen"})
    public void checkIfTilesArePresent() {
        try {
            homeScreen.getTile("Attractions");
            homeScreen.getTile("Restaurants and Cafes");
            homeScreen.getTile("Nightlife");
            homeScreen.getTile("Shopping");
            Assert.assertTrue(true);
        } catch (NoSuchElementException e) {
            Assert.fail("NoSuchElementException: Search input field not found");
        }
    }

    @Test(dependsOnMethods = {"checkIfTilesArePresent"})
    public void swipeToBottom() {
        homeScreen.swipeToBottom();
    }

    @AfterClass
    public void tearDown() {
        driver.quit();
    }
}
