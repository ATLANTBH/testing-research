const AuthForm = require('../Page-objects/AuthForm.js'),
    RegistrationForm = require('../Page-objects/RegistrationForm.js');

const authForm = new AuthForm(),
    registrationForm = new RegistrationForm();

class CompleteRegistration{

    async completeRegistrationForm(data){
        console.log('Started creating registration ...')
        
        authForm.insertValueInEmail(data.email)
            .createAccount();
        
        registrationForm.waitForCreateAccount()
            .insertFirstName(data.firstName)
            .insertLastName(data.lastName)
            .insertInIfDefined(data.company, () => {
                registrationForm.insertCompany(data.company);
            })
            .inserFirstAddress(data.address)
            .insertInIfDefined(data.address2, () => {
                registrationForm.insertSecondAddress(data.address2)
            })
            .insertCity(data.city)
    }
}

module.exports = CompleteRegistration;