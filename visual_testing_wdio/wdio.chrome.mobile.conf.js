const { merge } = require('lodash')
const devicesData = require('./test/config/devices/devices')
const minimist = require('minimist'),
    minArgs = minimist(process.argv);
let device, devicesList = devicesData.find(({ type }) => type == minArgs.params.deviceType)
if (minArgs.params.deviceName != undefined) {
    let deviceName = minArgs.params.deviceName.replace(/_/g, " ") 
    device = devicesList.devices.find(({ name }) => name == deviceName)
} else {
    device = devicesList.devices[0]
}
const baseConfig = require('./wdio.conf.js').config

let capabilities = [
    {
        browserName: 'chrome',
        maxInstances: 5,
        'goog:chromeOptions': {
            mobileEmulation: {
                "deviceMetrics": {
                    "width": device.resolution.width,
                    "height": device.resolution.height
                }
            }
        }
    }
]

exports.config = merge({
    capabilities: capabilities,
    services: [
        ['devtools'],
        ['chromedriver', {
            hostname: '127.0.0.1',
            port: parseInt(process.env.SELENIUM_PORT) || 9515,
            logFileName: 'chromedriver.log',
            outputDir: 'test-results/ui'
        }]
    ]
}, baseConfig)
