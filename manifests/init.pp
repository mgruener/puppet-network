class network (
  $interfaces = undef,
  $networkmanager = false,
  $hiera_merge = false,
) {

  $myclass = $module_name

  case type($hiera_merge) {
    'string': {
      validate_re($hiera_merge, '^(true|false)$', "${myclass}::hiera_merge may be either 'true' or 'false' and is set to <${hiera_merge}>.")
      $hiera_merge_real = str2bool($hiera_merge)
    }
    'boolean': {
      $hiera_merge_real = $hiera_merge
    }
    default: {
      fail("${myclass}::hiera_merge type must be true or false.")
    }
  }

  case type($networkmanager) {
    'string': {
      validate_re($networkmanager, '^(true|false)$', "${myclass}::networkmanager may be either 'true' or 'false' and is set to <${networkmanager}>.")
      $networkmanager_real = str2bool($networkmanager)
    }
    'boolean': {
      $networkmanager_real = $networkmanager
    }
    default: {
      fail("${myclass}::networkmanager type must be true or false.")
    }
  }

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

  if $networkmanager_real {
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

  if $interfaces != undef {
    if !is_hash($interfaces) {
        fail("${myclass}::interfaces must be a hash.")
    }

    if $hiera_merge_real == true {
      $interfaces_real = hiera_hash("${myclass}::interfaces",undef)
    } else {
      $interfaces_real = $interfaces
    }

    create_resources($resource,$interfaces_real, { require => [ Service[$servicename], Service['network']] })
  }
}
