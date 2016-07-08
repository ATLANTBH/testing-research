#!/bin/bash

TEST_FRAMEWORK=$1
TEST_DIR=$2
APPIUM_SERVER_LOGS=$3
TEST_LOGS=$4
APP_FILE_PATH=$5
PID_DATA=()

echo "------------------- Parallel mobile test execution with Appium ------------------"
echo "[INFO] Test framework is: ${TEST_FRAMEWORK}"
echo "[INFO] Test directory is: ${TEST_DIR}"
echo "[INFO] Appium server logs will be stored at: ${APPIUM_SERVER_LOGS}"
echo "[INFO] Test logs will be stored at: ${TEST_LOGS}"

# Function for running appium server
function start_appium_server() {
  appium_main_port=$1
  appium_bootstrap_port=$2
  appium_server_logs=$3
  udid=$5

  echo "[INFO] Starting Appium server instance with main port: ${appium_main_port} and bootstrap port: ${appium_bootstrap_port} for udid: ${udid}..."
  appium_full_path=`which appium`
  nohup $appium_full_path -p $appium_main_port -bp $appium_bootstrap_port -U $udid > "$appium_server_logs.$udid" &
}

# Function for running tests
function start_tests() {
  test_framework=$1
  test_dir=$2
  test_logs=$3
  appium_main_port=$4
  udid=$5
  platform_version=$6

  echo "[INFO] Start ${test_framework} test with main port: ${appium_main_port} and udid: ${udid}..."
  case $test_framework in
    "rspec" )
      rspec_full_path=`which rspec`
      cd $test_dir
      UDID=$udid PORT=$appium_main_port PLATFORM_VERSION=$platform_version APP_FILE=$APP_FILE_PATH $rspec_full_path spec > "$test_logs-$udid" &
      pid=$!
      PID_DATA+=($pid)
      cd -
      ;;
    "testng" )
      mvn_full_path=`which mvn`
      cd $test_dir
      $mvn_full_path -DUDID=$udid -DPORT=$appium_main_port -DPLATFORM_VERSION=$platform_version -DTEST_OUTPUT="$test_logs-$udid" -DAPP_FILE=$APP_FILE_PATH test &
      pid=$!
      PID_DATA+=($pid)
      cd -
      ;;
  esac
}

# Function for cleaning up running appium server instances
function appium_server_instances_cleanup() {
  pkill_full_path=`which pkill`
  $pkill_full_path -f "node"
  echo "[INFO] Waiting for appium server instances to be shut down..." && sleep 5
  ps -ef | grep [n]ode
  if [[ $? == 0 ]]; then
    echo "[ERROR] Appium server instances have not been shut down successfully!"
    exit 1
  fi
}

# Populate array of UDIDs
echo "[INFO] Getting all device UDIDs..."
udid_data=()

i=0
while [[ $i -lt 10 ]]; do
  adb_full_path=`which adb`
  devices_running=`$adb_full_path devices | grep "device not running"`
  if [[ $? == 0 ]]; then
    echo "[INFO] adb not ready. Waiting..." && sleep 5
    let i=i+1
  else
    devices_list=`$adb_full_path devices | grep -v "List of devices attached"`
    for device in $devices_list; do
      echo "[INFO] Device UDID is: ${device}"
      if [[ $device != 'unauthorized' && $device != 'device' ]]; then
        udid_data+=($device)
      fi
    done
    break
  fi
done

echo "[INFO] Number of Appium server instances that will be spawned: ${#udid_data[@]}"

appium_data=()
appium_start_port="4451"
appium_bootstrap_start_port="2251"

# Populate list of appium main and bootstrap ports and start appium server instances
for (( i=0; i<${#udid_data[@]}; i++ ))
do
  p=$((appium_start_port + i))
  bp=$((appium_bootstrap_start_port + i))
  
  # Get platform version of attached device
  platform_version=`ANDROID_SERIAL=${udid_data[i]} $adb_full_path shell getprop ro.build.version.release`

  udid=${udid_data[i]}
  data="$p,$udid,$platform_version"
  appium_data+=($data)

  # Start appium server
  start_appium_server $APPIUM_SERVER_DIR $p $bp $APPIUM_SERVER_LOGS $udid
  # Ensure that appium server instance is initialized
  sleep 10
done

# Run tests
for (( i=0; i<${#appium_data[@]}; i++ ))
do
  port=`echo ${appium_data[i]} | cut -d, -f1`
  udid=`echo ${appium_data[i]} | cut -d, -f2`
  platform_version=`echo ${appium_data[i]} | cut -d, -f3`
  start_tests $TEST_FRAMEWORK $TEST_DIR $TEST_LOGS $port $udid $platform_version
done

# Wait for tests to finish
wait ${PID_DATA[*]}

# Cleanup of running appium server instances
appium_server_instances_cleanup
