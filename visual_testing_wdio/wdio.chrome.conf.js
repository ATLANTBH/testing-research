const baseConfig = require('./wdio.conf.js').config
exports.config = {
    ...baseConfig,
    capabilities: [
        {
            browserName: 'chrome',
            maxInstances: 1,
            'goog:chromeOptions': {
                args: args,
            },
        },
    ],
    services: [
        ['devtools'],
        ['intercept'],
        [
            'chromedriver',
            {
                hostname: '127.0.0.1',
                port: parseInt(process.env.SELENIUM_PORT) || 9515,
                logFileName: 'chromedriver.log',
                outputDir: 'test-results/ui',
            },
        ],
    ],
}
