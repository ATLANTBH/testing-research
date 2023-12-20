class Page {

    get navigationBar() {
        return $('#header-outer')
    }

    get whyUsSection() {
        return $('//h6[contains(text(),"WHY US")]')
    }

}

module.exports = Page
