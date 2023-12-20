'use strict'
const { join } = require('path')
const { getResolutionBreakPoint } = require('./mobileHelper')

const getSpecificDevice = () => {
    process.env.RESOLUTIONBREAKPOINT = getResolutionBreakPoint()
    let device
    if (process.env.RESOLUTIONBREAKPOINT == 2) device = "iPadLandscape"
    if (process.env.RESOLUTIONBREAKPOINT == 3) device = "iPad"
    if (process.env.RESOLUTIONBREAKPOINT == 4) device = "iPhone"
    if (process.env.RESOLUTIONBREAKPOINT == 1) device = "Desktop"
    return device
}

const getBaseLineFolder = () => {
    return join(process.cwd(), `./data/baselineImages/${getSpecificDevice()}`)
}

const getResultsFolder = () => {
    return join(process.cwd(), `./data/resultImages/${getSpecificDevice()}`)
}

/**
 * This method captures screenshots of entire screen and validates captured against baseline screenshots.
 * The validation is done upon the acceptable tolerance and comparison is done upon screenshot name.
 *
 * @param screenshotCaptureObjects[] - array of objects with properties:
 * @property element - If scrolls are needed, element to which the scroll is needed must be defined
 * @property screenshotName - Name of the image: property that must be defined since comparison is done upon it
 * @property tolerance - Tolerance is allowed difference when screenshots are being compared
 */

async function captureScreenshot(screenshotCaptureObjects = []) {
    for (const screenshotCaptureObject of screenshotCaptureObjects) {
         expect(
           await browser.checkScreen(screenshotCaptureObject.screenshotName, {
           saveAboveTolerance: screenshotCaptureObject.tolerance,
         })
    ).toBeLessThanOrEqual(screenshotCaptureObject.tolerance)
         if (screenshotCaptureObject.element) {
            await screenshotCaptureObject.element.scrollIntoView()
         }
    }
}
module.exports = {
    getBaseLineFolder,
    getResultsFolder,
    captureScreenshot
}
