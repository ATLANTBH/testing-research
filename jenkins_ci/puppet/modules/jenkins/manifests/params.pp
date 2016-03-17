# Class: jenkins::params
#
#
class jenkins::params {
  $version               = 'installed'
  $lts                   = false
  $repo                  = true
  $service_enable        = true
  $service_ensure        = 'running'
  $install_java          = true
  $swarm_version         = '1.22'
  $default_plugins_host  = 'https://updates.jenkins-ci.org'
  $port                  = '8080'
  $prefix                = ''
  $cli_tries             = 10
  $cli_try_sleep         = 10
  $package_cache_dir     = '/var/cache/jenkins_pkgs'
  $package_name          = 'jenkins'

  $manage_datadirs = true
  $localstatedir   = '/var/lib/jenkins'
  $plugin_dir      = "${localstatedir}/plugins"
  $job_dir         = "${localstatedir}/jobs"

  $manage_user  = true
  $user         = 'jenkins'
  $manage_group = true
  $group        = 'jenkins'

  case $::osfamily {
    'Debian': {
      $libdir           = '/usr/share/jenkins'
      $package_provider = 'dpkg'
      $service_provider = undef
    }
    'RedHat': {
      $libdir           = '/usr/lib/jenkins'
      $package_provider = 'rpm'
      case $::operatingsystem {
        'Fedora': {
          if versioncmp($::operatingsystemrelease, '19') >= 0 or $::operatingsystemrelease == 'Rawhide' {
            $service_provider = 'redhat'
          }
        }
        /^(RedHat|CentOS|Scientific|OracleLinux)$/: {
          if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
            $service_provider = 'redhat'
          }
        }
        default: {
          $service_provider = undef
        }
      }
    }
    default: {
      $libdir           = '/usr/lib/jenkins'
      $package_provider = false
      $service_provider = undef
    }
  }
}
