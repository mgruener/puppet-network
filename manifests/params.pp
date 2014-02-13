class network::params {

  case $::osfamily {
    'RedHat': { $packages = [ 'net-tools' ]
                $network_resource = "${module_name}::ifcfg"
    }
    default: { fail("${::osfamily} not supported") }
  }

  case $::operatingsystem {
    'Fedora': { $serviceprovider = systemd
                $network_servicename = 'network'
                $network_serviceprovider = $serviceprovider
                $nm_servicename = 'NetworkManager.service'
                $nm_serviceprovider = $serviceprovider
    }
    default: {$serviceprovider = undef
              $network_servicename = 'network'
              $network_serviceprovider = $serviceprovider
              $nm_servicename = 'NetworkManager'
              $nm_serviceprovider = $serviceprovider
    }
  }
}
