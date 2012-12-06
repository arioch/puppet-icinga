class icinga::plugins::checkmount (
  pkgname             = 'nagios-plugins-mount',
  mountpoint          = undef,
  type                = undef,
  $max_check_attempts = $::icinga::params::max_check_attempts,
) inherits ::icinga::params {

  package{$pkgname:
    ensure => 'present',
  }

  $sanitized_mount = inline_template("<%= mountpoint.gsub(\/, _) %>")
  if $type {
    $type_option = " -t ${type}"
  }

  file{"${::icinga::includedir_client}/mount${sanitized_mount}.cfg",
    ensure => 'file',
    mode   => '0644',
    owner  => $::icinga::client_user,
    group  => $::icinga::client_group,
    content => "command[check_mount_${sanitized_mount}]=${::icinga::plugindir}/check_mount.pl -m ${mountpoint}${type_option}\n",
  }

  @@nagios_service{"check_mount_${mountpoint}_${::fqdn}":
    check_command       => "check_nrpe_command!check_mount_${mountpoint}",
    service_description => "Mount ${mountpoint}",
    host_name           => $::fqdn,
    max_check_attempts  => $max_check_attempts,
    target              => "$::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}
