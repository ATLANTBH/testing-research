# Description
___

This Vagrant box is used for starting a CI environment. It contains essential CI tools such as Java JDK, Maven, Selenium, Jenkins, Xvfb and Firefox. With this, a fully functional environement for testing and integration jobs can be easily created.

CI Vagrant Box uses Puppet for provisioning required services and components and is configurable. There are two ways of using this box:  
 
 - Using already provisioned and packed Vagrant Box 
 - Provisioning a new box

---
## Requirements

- Vagrant 1.8.1 or later

This is the only requirement for running Jenkins CI Box. Latest Vagrant version can be found on: https://www.vagrantup.com/downloads.html. 

----
# How to use  

##  Using Jenkins CI Vagrant Box

There are two ways of using Jenkins CI Vagrant box:

- Start a preconfigured, ready to use VM
- Provisioning a new Box

First approach is easier and faster, it will get the already configured CI running with just two commands. The second approach is better if additional configuration is needed for your CI environment, but requires provisioning a new Vagrant environment.

#### Plug & Play  

To start a preconfigured Jenkins CI VM, following command should be executed:   
`vagrant init atlantbh/jenkins_ci && vagrant up`  

This will start a VM with following configuration:  

 - Jenkins is running on port 8080 inside the started VM. To access it from your host machine, you'll have to add port forwarding to the generated Vagrantfile (ie. `config.vm.network "forwarded_port", guest: 8080, host: 8080`)
 
 - Git, TestNG and Slack Jenkins plugins will be installed.

Generated Vagrantfile can be further configured (for port forwarding, folder sharing etc).  

#### Provisioning a new Vagrant Box

Provisioning of the Vagrant Box is done with Puppet.

Main Puppet manifest is located in `testing-resarch/vagrant_ci/puppet/manifest/default.pp`. This manifest uses hiera data to read from jenkins.yaml file and configure the Jenkins module (port on which Jenkins will run or jenkins plugins which will be installed).
  
All required Puppet modules are located in `testing-resarch/vagrant_ci/puppet/modules`. Puppet modules used in the provisioning can also be found on Puppet Forge.

Vagrantfile is configured to use Puppet as provisioning tool, read from modules directory and set hiera yaml path.  

---
##### Steps to provision Vagrant environement
To provision a new Jenkins CI vagrant box, following steps have to be done:  

 1. Clone `atlantbh/testing-research` repository and change to vagrant_ci directory  
 2. Execute `vagrant up`, which will create a new VM and start Puppet provisioning
 
 Starting environment like this for the first time will take around 10 minutes.  

Jenkins will be runing on port 8080 and you can access it from the by opneing `localhost:8080` (Port 8080 on host has to be available when starting the Vagrant box).

After the provisioning is done, you can connect to the box using `vagrant ssh`.

