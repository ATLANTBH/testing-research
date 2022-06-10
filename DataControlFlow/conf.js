exports.config = {
    framework: 'jasmine',
    seleniumAddress: 'http://localhost:4444/wd/hub',
    specs: ['./Test-suites/RegistrationTest.js'],
    jasmineNodeOpts: {
      defaultTimeoutInterval: 100000
      }
  }
