include wget
include maven
include selenium
include apt

$port=hiera("jenkins::http_port")
$plugins=hiera("jenkins::plugins")

exec { "apt-update":
  command => "/usr/bin/apt-get update"
} ->

class { "jenkins":
  config_hash => {
    'HTTP_PORT' => { 'value' => $port }
  }
} 

jenkins::plugin { $plugins: }

package { 'firefox':
  ensure  => installed,
}

package { 'xvfb':
  ensure  => installed,
}

# apt::source { 'google-chrome':
#   location  => 'http://dl.google.com/linux/chrome/deb/',
#   release   => 'stable',
#   key       => {
#     id      => '4CCA1EAF950CEE4AB83976DCA040830F7FAC5991',
#     source  => 'http://dl-ssl.google.com/linux/linux_signing_key.pub'
#   },
#   repos     => 'main',
#   include   => {
#       'src' => false
#   },
# } ->

# package { 'google-chrome-stable':
#   ensure      => installed,
#   require => Exec['apt-update']
# }