#!/bin/bash

## Script used for provisioning of vagrant box. It does following:
## 1. Check currently attached iphone device to vagrant box (guest) and sets its UDID in spec_helper method of test
## 2. Starts appium server (if not started already)
## 3. Starts test execution on the attached device

TEST_FRAMEWORK="rspec"
TEST_DIR="/Users/Vagrant/app_mount/scripts"
APPIUM_SERVER_DIR="/Users/Vagrant/appium"
SYSTEM_PROFILER_PATH=`which system_profiler`
UDID=`$SYSTEM_PROFILER_PATH SPUSBDataType | grep -o "[A-Za-z0-9]\{40\}"`
sed -i.bak "s/udid:.*[^,]/udid: \"$UDID\"/" $TEST_DIR/spec/spec_helper.rb

# Function for running appium server
function start_appium_server() {
  appium_server_dir=$1
  echo "[INFO] Starting Appium server instance..."
  cd $appium_server_dir
  node_full_path=`which node`
  nohup $node_full_path . &
  cd -
  sleep 20
}

# Function for running tests
function start_tests() {
  test_framework=$1
  test_dir=$2
  echo "[INFO] Starting ${test_framework} tests..."
  case $test_framework in
    "rspec" )
      rspec_full_path=`which rspec`
      cd $test_dir
      $rspec_full_path spec
      cd -
      ;;
    "testng" )
      ## To Do: Support not added yet for testng framework!
      ;;
  esac
}

# Function for cleaning up running appium server instance
function stop_appium_server() {
  pkill_full_path=`which pkill`
  $pkill_full_path -f "node ."
  echo "[INFO] Waiting for appium server instance to be shut down..." && sleep 5
  ps -ef | grep [n]ode
  if [[ $? == 0 ]]; then
    echo "[ERROR] Appium server instance has not been shut down successfully!"
    exit 1
  fi
}

start_appium_server $APPIUM_SERVER_DIR
start_tests $TEST_FRAMEWORK $TEST_DIR
stop_appium_server
