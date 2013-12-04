# manage RedHat style ifcfg-* interface configuration files
define network::ifcfg ( $bonding_opts = undef,
                        $bootproto = "dhcp",
                        $broadcast = undef,
                        $device = $title,
                        $dhcp_hostname = undef,
                        $dhcpv6c = undef,
                        $dhcpv6c_options = undef,
                        $dns1 = undef,
                        $dns2 = undef,
                        $ethtool_opts = undef,
                        $hotplug = undef,
                        $hwaddr = undef,
                        $ipaddr = undef,
                        $ipv6addr = undef,
                        $ipv6addr_secondaries = undef,
                        $linkdelay = undef,
                        $macaddr = undef,
                        $master = undef,
                        $netmask = undef,
                        $network = undef,
                        $nm_controlled = false,
                        $onboot = true,
                        $peerdns = undef,
                        $slave = undef,
                        $srcaddr = undef,
                        $userctl = undef,
                        $scope = undef,
                        $uuid = undef,
                        $ensure = present,
                        $type = "Ethernet",
                        $gateway = undef,
                        $ipv6init = undef ){

  if $hwaddr {
    $ifhwaddr = $hwaddr
  }
  else {
    $ifhwaddr = getvar("::macaddress_${title}")
  }

  file { "/etc/sysconfig/network-scripts/ifcfg-${title}":
    ensure => $ensure ? {
      absent => absent,
      default => present
    },
    owner => root,
    group => root,
    mode => 0644,
    content => template("$module_name/ifcfg.erb")
  }
}
