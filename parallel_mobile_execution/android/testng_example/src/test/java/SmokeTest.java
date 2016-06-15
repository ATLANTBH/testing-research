import appium.pageObjects.HomeScreen;
import appium.pageObjects.PlaceScreen;
import appium.utils.DriverSupport;
import io.appium.java_client.android.AndroidDriver;
import org.openqa.selenium.NoSuchElementException;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;


public class SmokeTest {
    private AndroidDriver driver;
    private HomeScreen homeScreen;
    private PlaceScreen placeScreen;

    @BeforeClass
    public void setUp() throws Exception {
        driver = DriverSupport.initDriver();
        homeScreen = new HomeScreen(driver);
        placeScreen = new PlaceScreen(driver);
    }

    @Test(priority = 1)
    public void openHomeScreen() {
        try {
            homeScreen.getSearchButton();
            Assert.assertTrue(true);
        } catch (NoSuchElementException e) {
            Assert.fail("NoSuchElementException: Search input field not found");
        }
    }

    @Test(dependsOnMethods = {"openHomeScreen"})
    public void searchForPlace() throws Exception {
        homeScreen.getSearchInput().sendKeys("Atlantbh");
        Thread.sleep(3000);

        homeScreen.tapFirstSearchResult();

        Assert.assertEquals(placeScreen.getTitle().getText(), "ATLANTBH");
    }

    @Test(dependsOnMethods = {"searchForPlace"})
    public void checkPlaceInfo() {
        Assert.assertEquals(placeScreen.getPlaceName().getText(), "Atlantbh");
        Assert.assertEquals(placeScreen.getEmail().getText(), "contact@atlantbh.com");
    }

    @AfterClass
    public void tearDown() {
        driver.quit();
    }
}
