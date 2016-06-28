# iOS build
This is location where IOS build app needs to be located in order for Vagrant to share this directory to guest VM.
You can also modify sharing location in Vagrant file if you want to use iOS build from another location

Example from Vagrant file:
```
config.vm.synced_folder "ios_build", "/Users/Vagrant/app_mount", type: "nfs", nfs_export: false
```
