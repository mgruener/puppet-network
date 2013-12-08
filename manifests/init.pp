class network ( $interfaces = hiera_hash("${module_name}::interfaces",undef),
                $networkmanager = hiera("${module_name}::networkmanager",false)) {

  validate_bool($networkmanager)

  case $::osfamily {
    'RedHat': { package { 'net-tools': }
                $resource = "${module_name}::ifcfg"
    }
    default: { fail("${::osfamily} not supported") }
  }

  case $::operatingsystem {
    'Fedora': { $servicename = 'NetworkManager.service'
                $serviceprovider = systemd
    }
    default: {  $servicename = 'NetworkManager'
                $serviceprovider = undef
    }
  }

  if $networkmanager {
    service { $servicename:
      ensure   => running,
      enable   => true,
      provider => $serviceprovider,
    }

    service { 'network':
      ensure => stopped,
      enable => false,
    }
  }
  else {
    service { $servicename:
      ensure   => stopped,
      enable   => false,
      provider => $serviceprovider,
    }

    service { 'network':
      ensure => running,
      enable => true,
    }
  }

  if $interfaces {
    create_resources($resource,$interfaces, { require => [ Service[$servicename], Service['network']] })
  }
}
