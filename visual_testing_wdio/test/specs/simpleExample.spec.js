const Page = require('../pageObjects/HomePage'),
    page = new Page()

describe('Visual testing with WDIO image comparison', () => {
    it('Verify landing page is displayed as expected', async () => {
        await expect(
            await browser.checkScreen('landingPage',
                {
                    /* some options */
                })
        ).toEqual(0)
    })
    it('Verify one element on page is displayed as expected', async () => {
        await expect(
            await browser.checkElement(
                await page.navigationBar,
                'elementOnPage',
                {
                    /* some options */
                }
            )
        ).toEqual(0)
    })
    it('Verify landing page is displayed as expected with given tolerance', async () => {
        await expect(
            await browser.checkScreen('landingPageWithTolerance',
                {
                    saveAboveTolerance: 1.0
                })
        ).toBeLessThanOrEqual(1.0)
    })
})
