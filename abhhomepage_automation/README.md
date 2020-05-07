# abhhomepage-automation

## What it is?
Sanity check tests for AtlantBH homepage

## Usage
There are two ways to run these tests:
#### 1. Running tests in container using docker compose (this is currently limited to tests for firefox and chrome browser)

**1. Pre-requisities:**

* Install docker
* Install docker-compose

**2. Setup:**

You can choose which tests you want to run. By default, all tests will be executed but you can specify specific test you want to execute in .env file. Just set value of TESTS_TO_RUN to specific test name. For example:
```
TESTS_TO_RUN=check_about_links.rb
```

If you are executing tests on the same node where Owl is running in containerized environment, it is necessary to add following value in the .env file:
```
OWL_NETWORK=owl_default
```
This means that containers created through our docker-compose will join to the same network where Owl containers already exist and they will be able to communicate with each other. If not, you can safely remove **networks** part from the [docker-compose](https://github.com/ATLANTBH/abhhomepage-automation/blob/master/docker-compose.yml) file

In order to execute tests against chrome or firefox, just set appropriate value in config/environment.yaml file for ```driver``` (firefox or chrome) and make sure that ```platform``` value is ```web```.

Finally, you need to setup rspec2db.yml to point to correct database

**3. Run:**

To setup complete environment and run tests use following command:
```
docker-compose up -d
```
This command will run selenium hub, two nodes: node-firefox-debug and node-chrome-debug and container that will execute abhhomepage tests. To get logs from the container in which tests will be executed, use following command:
```
docker logs -f abhhomepageautomation_abhtests_1
```
You can view execution live by using VNC viewer. By default, VNC port for chrome will be **5900**. VNC port for firefox will be **5901**

Finally, when tests have been executed, you can turn off your containerized environment using following command:
```
docker-compose down
```

**4. Debug tests execution:**

In order to debug test execution, following is needed:

Put following line where you want execution to stop so that debugger can be started:
```
require 'byebug'; byebug
```

Run tests using following command:
```
docker-compose up -d
Creating selenium-hub ... done
Creating abhhomepage-automation_firefox_1 ... done
Creating abhhomepage-automation_chrome_1  ... done
Creating abhhomepage-automation_abhtests_1 ... done
```

Use docker attach command to attach your terminal’s standard input, output, and error (or any combination of the three) to a running container:
```
docker attach abhhomepage-automation_abhtests_1
```

When test execution comes to the section where byebug is invoked, you will be able to access and control debugger.

#### 2. Running tests on the host (can run any type of tests)
To setup execution in specific browser (firefox, chrome or safari), you need to change ```driver``` value in environment.yaml configuration file and make sure that ```platform``` value is ```web```. To setup execution on specific ios/android devices set ```platform``` value to ```mobile_ios``` or ```mobile_android```  and ```orientation``` to ```portrait``` or ```landscape```.

1. Pre-requisities:
* Install rvm/ruby environment
* Install needed browsers and corresponding drivers
* Install appium for mobile test purposes
* Run bundle install
* Setup rspec2db.yml to point to correct database

2. Run:
```
bundle exec rspec spec/*
```

Going forward, preferred way of running tests will be using docker compose

If any change in Gemfile is needed, you should do it on host machine. You do not need to build new images after that, test can be run with existing ones, if there are any.
