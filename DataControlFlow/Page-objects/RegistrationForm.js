let EC = protractor.ExpectedConditions;

const BasePage = require('./BasePage.js');

class RegistrationForm extends BasePage{

    //Getters
    get createAccountTitle(){ return '.account_creation'; }
    get firstName(){ return browser.driver.findElement(by.id("firstname")); }
    get lastName(){ return browser.driver.findElement(by.id("lastname")); }
    get company(){ return browser.driver.findElement(by.id("company")); }
    get firstAddress(){ return browser.driver.findElement(by.id("address1")); }
    get secondAddress(){ return browser.driver.findElement(by.id("address2")); }
    get city(){ return browser.driver.findElement(by.id("city")); }

    //Actions
    waitForCreateAccount(){
        console.log("Waiting for registration page to load ... ");
        browser.wait(EC.presenceOf($(this.createAccountTitle)), 5000);
        return this;
    }

    insertFirstName(firstName){
        console.log(`Inserting ${firstName} in email field ... `)
        this.firstName.sendKeys(firstName);
        return this;
    }

    insertLastName(lastName){
        console.log(`Inserting ${lastName} in email field ... `)
        this.lastName.sendKeys(lastName);
        return this;
    }

    insertCompany(company){
        console.log(`Inserting ${company} in email field ... `)
        this.company.sendKeys(company);
        return this;
    }

    inserFirstAddress(firstAddress){
        console.log(`Inserting ${firstAddress} in email field ... `)
        this.firstAddress.sendKeys(firstAddress);
        return this;
    }

    insertSecondAddress(secondAddress){
        console.log(`Inserting ${secondAddress} in email field ... `)
        this.secondAddress.sendKeys(secondAddress);
        return this;
    }

    insertCity(city){
        console.log(`Inserting ${city} in email field ... `)
        this.city.sendKeys(city);
        return this;
    } 
}

module.exports = RegistrationForm;