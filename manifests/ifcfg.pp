# manage RedHat style ifcfg-* interface configuration files
define network::ifcfg ( $ensure = present,
                        $bonding_opts = undef,
                        $bootproto = 'dhcp',
                        $bridge = undef,
                        $broadcast = undef,
                        $delay = undef,
                        $device = $title,
                        $dhcp_hostname = undef,
                        $dhcpv6c_options = undef,
                        $dhcpv6c = undef,
                        $dns1 = undef,
                        $dns2 = undef,
                        $ethtool_opts = undef,
                        $gateway = undef,
                        $hotplug = undef,
                        $hwaddr = undef,
                        $ipaddr = undef,
                        $ipv6addr_secondaries = undef,
                        $ipv6addr = undef,
                        $ipv6init = undef,
                        $linkdelay = undef,
                        $macaddr = undef,
                        $master = undef,
                        $netmask = undef,
                        $network = undef,
                        $nm_controlled = false,
                        $onboot = true,
                        $peerdns = undef,
                        $scope = undef,
                        $slave = undef,
                        $srcaddr = undef,
                        $stp = undef,
                        $type = 'Ethernet',
                        $userctl = undef,
                        $uuid = undef, ) {

  # ignore the hwaddr parameter if the interface is a bridge
  # bridges are virtual devices that should not be configured
  # with a hardware adresse of an existing physical device
  if $type != "Bridge" {
    if $hwaddr != undef  {
      $ifhwaddr = $hwaddr
    }
    else {
       # if the hardware address of the device was not provided
       # as parameter, try to use the according fact
      $ifhwaddr = getvar("::macaddress_${title}")
    }
  }

  # do some sanity checks
  if $broadcast != undef {
    if !is_ip_address($broadcast) {
      warning("${broadcast} is not a valid broadcast addess")
    }
  }

  if $delay != undef {
    if !is_numeric($delay) {
      warning("${delay} is not a valid number")
    }
  }

  if $ifhwaddr != undef {
    if !is_mac_address($ifhwaddr) {
      warning("${ifhwaddr} is not a valid mac addess")
    }
  }

  if $ipaddr != undef {
    if !is_ip_address($ipaddr) {
      warning("${ipaddr} is not a valid ip addess")
    }
  }

  if $linkdelay != undef {
    if !is_numeric($linkdelay) {
      warning("${linkdelay} is not a valid number")
    }
  }
  if $macaddr != undef {
    if !is_mac_address($macaddr) {
      warning("${macaddr} is not a valid mac addess")
    }
  }

  if $network != undef {
    if !is_ip_address($network) {
      warning("${network} is not a valid network addess")
    }
  }

  if $srcaddr != undef {
    if !is_ip_address($srcaddr) {
      warning("${srcaddr} is not a valid ip addess")
    }
  }

  if $dhcpv6c != undef {
    validate_bool($dhcpv6c)
  }
  if $hotplug != undef {
    validate_bool($hotplug)
  }
  if $ipv6init != undef {
    validate_bool($ipv6init)
  }
  if $nm_controlled != undef {
    validate_bool($nm_controlled)
  }
  if $onboot != undef {
    validate_bool($onboot)
  }
  if $slave != undef {
    validate_bool($slave)
  }
  if $stp != undef {
    validate_bool($stp)
  }
  if $userctl != undef {
    validate_bool($userctl)
  }

  case $type {
    'Bridge': { package { 'bridge-utils':
                  ensure => present
                }
    }
    default:  {}
  }

  # map ensure to absent/file for file as there are other
  # ensure values like "running" planned
  case $ensure {
    absent:  { $file_ensure = absent }
    default: { $file_ensure = file }
  }

  file { "/etc/sysconfig/network-scripts/ifcfg-${title}":
    ensure  => $file_ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/ifcfg.erb")
  }
}
