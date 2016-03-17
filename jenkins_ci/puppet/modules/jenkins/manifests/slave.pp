# == Class: jenkins::slave
#
# This module setups up a swarm client for a jenkins server.  It requires the swarm plugin on the Jenkins master.
#
# https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin
#
# It allows users to add more workers to Jenkins without having to specifically add them on the Jenkins master.
#
# === Parameters
#
# [*slave_name*]
#   Specify the name of the slave.  Not required, by default it will use the fqdn.
#
# [*masterurl*]
#   Specify the URL of the master server.  Not required, the plugin will do a UDP autodiscovery. If specified, the autodiscovery will be skipped.
#
# [*autodiscoveryaddress*]
#   Use this addresss for udp-based auto-discovery (default: 255.255.255.255)
#
# [*ui_user*] & [*ui_pass*]
#   User name & password for the Jenkins UI.  Not required, but may be ncessary for your config, depending on your security model.
#
# [*version*]
#   The version of the swarm client code. Must match the pluging version on the master.  Typically it's the latest available.
#
# [*executors*]
#   Number of executors for this slave.  (How many jenkins jobs can run simultaneously on this host.)
#
# [*manage_slave_user*]
#   Should the class add a user to run the slave code?  1 is currently true
#   TODO: should be updated to use boolean.
#
# [*slave_user*]
#   Defaults to 'jenkins-slave'. Change it if you'd like..
#
# [*slave_uid*]
#   Not required.  Puppet will let your system add the user, with the new UID if necessary.
#
# [*slave_home*]
#   Defaults to '/home/jenkins-slave'.  This is where the code will be installed, and the workspace will end up.
#
# [*slave_mode*]
#   Defaults to 'normal'. Can be either 'normal' (utilize this slave as much as possible) or 'exclusive' (leave this machine for tied jobs only).
#
# [*disable_ssl_verification*]
#   Disable SSL certificate verification on Swarm clients. Not required, but is necessary if you're using a self-signed SSL cert. Defaults to false.
#
# [*labels*]
#   Not required.  Single string of whitespace-separated list of labels to be assigned for this slave.
#
# [*tool_locations*]
#   Not required.  Single string of whitespace-separated list of tool locations to be defined on this slave. A tool location is specified as 'toolName:location'.
#
# [*java_version*]
#   Specified which version of java will be used.
#
# [*description*]
#   Not required.  Description which will appear on the jenkins master UI.
#
# [*manage_client_jar*]
#   Should the class download the client jar file from the web? Defaults to true.

# === Examples
#
#  class { 'jenkins::slave':
#    masterurl => 'http://jenkins-master1.example.com:8080',
#    ui_user => 'adminuser',
#    ui_pass => 'adminpass',
#  }
#
# === Authors
#
# Matthew Barr <mbarr@mbarr.net>
#
# === Copyright
#
# Copyright 2013 Matthew Barr , but can be used for anything by anyone..
class jenkins::slave (
  $slave_name               = undef,
  $description              = undef,
  $masterurl                = undef,
  $autodiscoveryaddress     = undef,
  $ui_user                  = undef,
  $ui_pass                  = undef,
  $version                  = $jenkins::params::swarm_version,
  $executors                = 2,
  $manage_slave_user        = true,
  $slave_user               = 'jenkins-slave',
  $slave_uid                = undef,
  $slave_home               = '/home/jenkins-slave',
  $slave_mode               = 'normal',
  $disable_ssl_verification = false,
  $labels                   = undef,
  $tool_locations           = undef,
  $install_java             = $jenkins::params::install_java,
  $manage_client_jar        = true,
  $ensure                   = 'running',
  $enable                   = true,
  $source                   = undef,
) inherits jenkins::params {

  validate_string($tool_locations)

  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = $source ? {
    undef   => "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${version}/",
    default => $source,
  }
  $quoted_ui_user = shellquote($ui_user)
  $quoted_ui_pass = shellquote($ui_pass)


  if $install_java and ($::osfamily != 'Darwin') {
    # Currently the puppetlabs/java module doesn't support installing Java on
    # Darwin
    class { 'java':
      distribution => 'jdk',
    }
  }

  # customizations based on the OS family
  case $::osfamily {
    'Debian': {
      $defaults_location = '/etc/default'

      ensure_packages(['daemon'])
      Package['daemon'] -> Service['jenkins-slave']
    }
    'Darwin': {
      $defaults_location = $slave_home
    }
    default: {
      $defaults_location = '/etc/sysconfig'
    }
  }

  case $::kernel {
    'Linux': {
      $fetch_command  = "wget -O ${slave_home}/${client_jar} ${client_url}/${client_jar}"
      $service_name   = 'jenkins-slave'
      $defaults_user  = 'root'
      $defaults_group = 'root'
      $manage_user_home = true

      file { '/etc/init.d/jenkins-slave':
        ensure => 'file',
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
        source => "puppet:///modules/${module_name}/jenkins-slave.${::osfamily}",
        notify => Service['jenkins-slave'],
      }
    }
    'Darwin': {
      $fetch_command    = "curl -O ${client_url}/${client_jar}"
      $service_name     = 'org.jenkins-ci.slave.jnlp'
      $defaults_user    = 'jenkins'
      $defaults_group   = 'wheel'
      $manage_user_home = false

      file { "${slave_home}/start-slave.sh":
        ensure  => 'file',
        content => template("${module_name}/start-slave.sh.erb"),
        mode    => '0755',
        owner   => 'root',
        group   => 'wheel',
      }

      file { '/Library/LaunchDaemons/org.jenkins-ci.slave.jnlp.plist':
        ensure  => 'file',
        content => template("${module_name}/org.jenkins-ci.slave.jnlp.plist.erb"),
        mode    => '0644',
        owner   => 'root',
        group   => 'wheel',
      }

      file { '/var/log/jenkins':
        ensure => 'directory',
        owner  => $slave_user,
      }

      if $manage_slave_user {
        # osx doesn't have managehome support, so create directory
        file { $slave_home:
          ensure  => directory,
          mode    => '0755',
          owner   => $slave_user,
          require => User['jenkins-slave_user'],
        }
      }

      File['/var/log/jenkins'] ->
        File['/Library/LaunchDaemons/org.jenkins-ci.slave.jnlp.plist'] ->
          Service['jenkins-slave']
    }
    default: { }
  }

  #a Add jenkins slave user if necessary.
  if $manage_slave_user {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => $manage_user_home,
      system     => true,
      uid        => $slave_uid,
    }
  }

  file { "${defaults_location}/jenkins-slave":
    ensure  => 'file',
    mode    => '0600',
    owner   => $defaults_user,
    group   => $defaults_group,
    content => template("${module_name}/jenkins-slave-defaults.erb"),
    notify  => Service['jenkins-slave'],
  }

  if ($manage_client_jar) {
    exec { 'get_swarm_client':
      command => $fetch_command,
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
      user    => $slave_user,
      creates => "${slave_home}/${client_jar}",
      cwd     => $slave_home,
      #refreshonly  => true,
    ## needs to be fixed if you create another version..
    }
  }

  service { 'jenkins-slave':
    ensure     => $ensure,
    name       => $service_name,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  if ($manage_client_jar) {
    Exec['get_swarm_client'] ->
    Service['jenkins-slave']
  }

  if $install_java and ($::osfamily != 'Darwin') {
    Class['java'] ->
    Service['jenkins-slave']
  }
}
