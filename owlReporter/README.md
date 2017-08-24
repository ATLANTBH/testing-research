# owl Jenkins plugin

## About

This plugin is used for uploading test results in xUnit format to [owl](https://github.com/ATLANTBH/owl).

## Installation

The plugin can be built with `mvn install`, after which `target/owlReporter.hpi` is generated. This file
can be uploaded in `Manage Jenkins -> Manage Plugins -> Advanced` .

## How to use it

After installing the plugin, a post-build action (Publish test results to owl) can be added to a Jenkins job, where
information needed to upload the files needs to be provided.

## Development

All information needed to setup can be found at [wiki.jenkins.io](https://wiki.jenkins.io/display/JENKINS/Plugin+tutorial).
