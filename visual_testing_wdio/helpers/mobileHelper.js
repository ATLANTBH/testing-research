const devicesData = require('../test/config/devices/devices')
const minimist = require('minimist'),
    minArgs = minimist(process.argv);

const getResolutionBreakPoint = () => {
    let breakPoint;
    if (minArgs.params.deviceType != undefined) {
        let devicesList = devicesData.find(({ type }) => type == minArgs.params.deviceType)
        if (minArgs.params.deviceName == undefined) {
            breakPoint = devicesList.devices[0].breakPoint;
        } else {
            let deviceName = minArgs.params.deviceName.replace(/_/g, " ")
            let device = devicesList.devices.find(({ name }) => name == deviceName)
            breakPoint = device.breakPoint;
        }
    }
    return breakPoint;
}

module.exports = {
    getResolutionBreakPoint
}
