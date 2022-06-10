let EC = protractor.ExpectedConditions;

class HomePage{

    //Getters
    get loginButton(){ return browser.driver.findElement(by.className("login")); }
    get searchBar(){ return '#search_query_top'; } 

    
    //Actions
    openPageURL(url){
        console.log("Opening URL ... ");
        browser.get(url);
        return this;
    }

    waitForHomePage(){
        console.log("Waiting for home page to load ... ");
        browser.wait(EC.presenceOf($(this.searchBar)), 5000);
        return this;
    }

    clickOnSignIn(){
        console.log("Clicking on Sign in link ... ");
        this.loginButton.click();
        return this;
    }
}

module.exports = HomePage;