const data = require('../Data/data.js'),
    requiredData = data.requiredData,
    CompleteRegistration = require('../Tasks/CompleteRegistration.js'),
    NavigateToAuthPage = require('../Tasks/NavigateToAuthPage');

const completeRegistration = new CompleteRegistration(),
    navigateToAuthPage = new NavigateToAuthPage();

browser.waitForAngularEnabled(false); //For non-Angular apps
browser.ignoreSynchronization = true; //For non-Angular apps
browser.manage().window().maximize(); //Browser opens in maximized screen

describe('001: Registration', () => {

    let additionalData = {
        company: "Amazon", 
        address2: "10th Street",
        email: `jdoe@gmail.com`,
        address: "9th street in the East Village"
    }

    let allData = Object.assign(requiredData, additionalData);

    beforeEach( () => {
        navigateToAuthPage.navigateToAuthPage(requiredData.pageURL);
    })

    it('001: Complete registration form (required data)', async () => {
        await completeRegistration.completeRegistrationForm(requiredData);
    });

    it('002: Complete registration form (all data)', async () => {
       await completeRegistration.completeRegistrationForm(allData);
    });
});