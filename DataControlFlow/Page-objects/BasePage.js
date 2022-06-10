class BasePage{

    insertInIfDefined(property, callback){
        console.log(`Insert data if ${property} is defined ...`)
        if (property != null)
            callback();
        return this;
    }
}

module.exports = BasePage;