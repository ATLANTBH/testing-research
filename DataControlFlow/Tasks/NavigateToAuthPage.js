const HomePage = require('../Page-objects/HomePage.js'),
    AuthForm = require('../Page-objects/AuthForm');

const homePage = new HomePage(),
    authForm = new AuthForm();

class NavigateToAuthPage{

    async navigateToAuthPage(pageUrl){
        console.log('Started navigating to auth page ...')
        homePage.openPageURL(pageUrl)
            .waitForHomePage()
            .clickOnSignIn();

        authForm.waitForAuthTitle();
    }
}

module.exports = NavigateToAuthPage;