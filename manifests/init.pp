class network ( $interfaces = hiera_hash("interfaces")) {
  case $osfamily {
    'RedHat': { package { "net-tools": }
                $resource = "${module_name}::ifcfg"
    }
  }

  if $interfaces {
    create_resources($resource,$interfaces)
  }
}
