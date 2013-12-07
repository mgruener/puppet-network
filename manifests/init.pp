class network ( $interfaces = hiera_hash("${module_name}::interfaces",undef)) {
  case $osfamily {
    'RedHat': { package { "net-tools": }
                $resource = "${module_name}::ifcfg"
    }
  }

  if $interfaces {
    create_resources($resource,$interfaces)
  }
}
