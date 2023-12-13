const devicesData = require('../test/config/devices/devices')
const minimist = require('minimist'),
    minArgs = minimist(process.argv);

const setBrowserResolution = () => {
    let devicesList = devicesData.find(({ type }) => type == minArgs.params.deviceType)
    if (minArgs.params.deviceName == undefined) {
        if (minArgs.params.browser === 'safari') {
            browser.setWindowRect(0, 0, devicesList.devices[0].resolution.width, devicesList.devices[0].resolution.height)
        }
        if (minArgs.params.browser === 'chrome') {
            browser.setWindowRect(0, 0, devicesList.devices[0].resolution.width, devicesList.devices[0].resolution.height)
        }
    } else {
        let deviceName = minArgs.params.deviceName.replace(/_/g, " ")
        let device = devicesList.devices.find(({ name }) => name == deviceName)
        if (minArgs.params.browser === 'safari' || device.breakPoint == 3) {
            browser.setWindowRect(0, 0, device.resolution.width, device.resolution.height)
        }
        if (minArgs.params.browser === 'chrome' || device.breakPoint == 3) {
            browser.setWindowRect(0, 0, device.resolution.width, device.resolution.height)
        }
    }
}

module.exports = {
    setBrowserResolution,
}
