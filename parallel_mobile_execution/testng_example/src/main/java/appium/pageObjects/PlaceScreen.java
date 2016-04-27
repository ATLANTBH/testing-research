package appium.pageObjects;


import appium.utils.AbstractPage;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.AndroidElement;
import io.appium.java_client.pagefactory.AndroidFindBy;

public class PlaceScreen extends AbstractPage {

    public PlaceScreen(AndroidDriver driver) {
        super(driver);
        initElements();
    }

    @AndroidFindBy(id = "com.atlantbh.navigator:id/profile_name")
    private AndroidElement placeName;

    @AndroidFindBy(id = "com.atlantbh.navigator:id/title")
    private AndroidElement title;

    @AndroidFindBy(id = "com.atlantbh.navigator:id/profile_address")
    private AndroidElement address;

    @AndroidFindBy(id = "com.atlantbh.navigator:id/profile_phone")
    private AndroidElement phone;

    @AndroidFindBy(id = "com.atlantbh.navigator:id/profile_email")
    private AndroidElement email;

    public AndroidElement getPlaceName() {
        return placeName;
    }

    public AndroidElement getTitle() {
        return title;
    }

    public AndroidElement getAddress() {
        return address;
    }

    public AndroidElement getPhone() {
        return phone;
    }

    public AndroidElement getEmail() {
        return email;
    }
}
