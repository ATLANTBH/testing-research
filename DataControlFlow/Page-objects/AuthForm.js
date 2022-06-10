let EC = protractor.ExpectedConditions;

class AuthForm{

    //Getters
    get authTitle(){ return '.page-heading'; }
    get emailField(){ return browser.driver.findElement(by.id("email_create")); }
    get createAccountButton(){ return browser.driver.findElement(by.id("SubmitCreate")); }

    //Actions
    waitForAuthTitle(){
        console.log("Waiting for Autorization page to load ... ");
        browser.wait(EC.presenceOf($(this.authTitle)), 5000);
        return this;
    }

    insertValueInEmail(email){
        console.log(`Inserting ${email} in email field ... `)
        this.emailField.sendKeys(email);
        return this;
    }

    createAccount(){
        console.log("Clickin on create account button ... ")
        this.createAccountButton.click();
        return this;
    }
}

module.exports = AuthForm;