To run UI tests on mobile/tablet and desktop resolutions on Chrome, use following command
npm run test-devices --device_name=$DEVICE_NAME --device_type=$DEVICE_TYPE --suite=$SUITE
-------
To run test on mobile resolution, it is necessary to specify additional two test parameters:
- *deviceType* parameter (value of the parameter must match the type property in the test/config/devices/devices.js data file)
- *(optional) deviceName* parameter (use an underscore as a space separator when specifying the value of this parameter)

For the purposes of this blog, baseline and resulting images are not included in this repo so each user can create baseline images on local machines and perform comparison based on the newly created screenshots.