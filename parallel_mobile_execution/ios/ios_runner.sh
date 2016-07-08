#!/bin/bash

TEST_FRAMEWORK=$1
TEST_DIR=$2
APPIUM_SERVER_LOGS=$3
TEST_LOGS=$4
INSTRUMENTS_OUTPUT_FOLDER=$5
APP_FILE=$6
PID_DATA=()

echo "------------------- Parallel mobile test execution with Appium ------------------"
echo "[INFO] Test framework is: ${TEST_FRAMEWORK}"
echo "[INFO] Test directory is: ${TEST_DIR}"
echo "[INFO] Appium server logs will be stored at: ${APPIUM_SERVER_LOGS}"
echo "[INFO] Test logs will be stored at: ${TEST_LOGS}"

# Function for running appium server
function start_appium_server() {
  appium_main_port=$1
  appium_server_logs=$2
  udid=$3
  instruments_output=$4

  echo "[INFO] Starting Appium server instance with main port: ${appium_main_port} for udid: ${udid}..."
  appium_full_path=`which appium`
  nohup $appium_full_path -p $appium_main_port --tmp $instruments_output > "$appium_server_logs.$udid" &
}

# Function for running tests
function start_tests() {
  test_framework=$1
  test_dir=$2
  test_logs=$3
  appium_main_port=$4
  udid=$5

  echo "[INFO] Start ${test_framework} test with main port: ${appium_main_port} and udid: ${udid}..."
  case $test_framework in
    "rspec" )
      rspec_full_path=`which rspec`
      cd $test_dir
      UDID=$udid PORT=$appium_main_port $rspec_full_path spec > "$test_logs-$udid" &
      pid=$!
      PID_DATA+=($pid)
      cd -
      ;;
    "testng" )
      mvn_full_path=`which mvn`
      cd $test_dir
      $mvn_full_path -DUDID=$udid -DPORT=$appium_main_port -DTEST_OUTPUT="$test_logs-$udid" test &
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

system_profiler_path=`which system_profiler`
udids=`$system_profiler_path SPUSBDataType | grep -o "[A-Za-z0-9]\{40\}"`

for udid in $udids; do
  udid_data+=($udid)
done

echo "[INFO] Deploying app to connected devices..."

iosdeploy_full_path=`which ios-deploy`
ios_deploy_pids=()

for udid in $udids; do
  $iosdeploy_full_path --id $udid --bundle $APP_FILE 2>&1 >/dev/null &
  pid=$!
  ios_deploy_pids+=($pid)
done

# Wait for apps to be deployed
wait ${ios_deploy_pids[*]}

echo "[INFO] Number of Appium server instances that will be spawned: ${#udid_data[@]}"

appium_data=()
appium_start_port="4451"

# Populate list of appium main and bootstrap ports and start appium server instances
for (( i=0; i<${#udid_data[@]}; i++ ))
do
  p=$((appium_start_port + i))
  
  udid=${udid_data[i]}
  data="$p,$udid"
  appium_data+=($data)
  instruments_output=$INSTRUMENTS_OUTPUT_FOLDER$i

  # Start appium server
  start_appium_server $p $APPIUM_SERVER_LOGS $udid $instruments_output
  # Ensure that appium server instance is initialized
  sleep 10
done

# Run tests
for (( i=0; i<${#appium_data[@]}; i++ ))
do
  port=`echo ${appium_data[i]} | cut -d, -f1`
  udid=`echo ${appium_data[i]} | cut -d, -f2`
  start_tests $TEST_FRAMEWORK $TEST_DIR $TEST_LOGS $port $udid
done

# Wait for tests to finish
wait ${PID_DATA[*]}

# Cleanup of running appium server instances
appium_server_instances_cleanup
