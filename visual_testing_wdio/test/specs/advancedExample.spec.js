const
    { captureScreenshot } = require('../../helpers/imageComparisonHelper'),
    Page = require('../pageObjects/HomePage'),
    page = new Page()

const screenshotCaptureProperties = {
    landingPage: [
        {
            tolerance: 0.0,
            screenshotName: 'landingPage'
        }
    ],
    landingPageTolerance: [
        {
            tolerance: 1.0,
            screenshotName: 'landingPageTolerance'
        }
    ]
}

describe('Image comparison with advanced method usage', () => {

    it('Verify landing page is displayed as expected', async () => {
        await captureScreenshot(screenshotCaptureProperties.landingPage)
    })

    it('Verify landing page is displayed as expected with tolerance', async () => {
        await captureScreenshot(screenshotCaptureProperties.landingPageTolerance)
    })

    it('Verify landing page is displayed as expected with scrolling to second part of the page', async () => {
        const screenshotCaptureProperties = {
            landingPageScroll: [
                {
                    tolerance: 0.0,
                    screenshotName: 'landingPageTop',
                    element: page.whyUsSection
                },
                {
                    tolerance: 0.0,
                    screenshotName: 'landingPageBottom'
                }
            ]
        }
        await captureScreenshot(screenshotCaptureProperties.landingPageScroll)
    })
})
