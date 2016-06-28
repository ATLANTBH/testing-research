#!/bin/bash

system_profiler_path=`which system_profiler`

UDID=`$system_profiler_path SPUSBDataType | grep "Serial Number: " | awk '{ print $3 }'`

sed -i.bak "s/udid:.*$/udid: \"$UDID\"/" spec/spec_helper.rb
