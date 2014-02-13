class network (
  $interfaces = undef,
  $networkmanager = false,
  $network_servicename = $::network::params::network_servicename,
  $network_serviceprovider = $::network::params::network_serviceprovider,
  $nm_servicename = $::network::params::nm_servicename,
  $nm_serviceprovider = $::network::params::nm_serviceprovider,
  $network_packages = $::network::params::packages,
  $network_resource = $::network::params::network_resource,
  $hiera_merge = false,
) inherits network::params {

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

  package { $network_packages: }

  if $networkmanager_real {
    service { $nm_servicename:
      ensure   => running,
      enable   => true,
      provider => $nm_serviceprovider,
    }

    service { $network_servicename:
      ensure   => stopped,
      enable   => false,
      provider => $network_serviceprovider,
    }
  }
  else {
    service { $nm_servicename:
      ensure   => stopped,
      enable   => false,
      provider => $nm_serviceprovider,
    }

    service { $network_servicename:
      ensure   => running,
      enable   => true,
      provider => $network_serviceprovider,
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

    create_resources( $network_resource,
                      $interfaces_real,
                      { require => [ Service[$nm_servicename], Service[$network_servicename]] }
    )
  }
}
