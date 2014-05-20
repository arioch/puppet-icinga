# == Define: icinga::plugins::checkmount
#
# This define provides a checkmount plugin.
#

define icinga::plugins::checkmount (
  $pkgname                = $::operatingsystem ? {
    'centos' => 'nagios-plugins-mount',
    'debian' => 'nagios-plugin-mount',
  },
  $mountpoint            = undef,
  $type                  = undef,
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::params::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  require ::icinga

  if ! defined(Package[$pkgname]) {
    package{$pkgname:
      ensure => 'present',
    }
  }

  $sanitized_mount = inline_template('<%= mountpoint.gsub(\'/\', \'_\') %>')
  if $type {
    $type_option = " -t ${type}"
  }

  file{"${::icinga::includedir_client}/mount${sanitized_mount}.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
    content => "command[check_mount${sanitized_mount}]=cd ${::icinga::plugindir}/; ./check_mount.pl -m ${mountpoint}${type_option}\n",
  }

  @@nagios_service{"check_mount_${mountpoint}_${::fqdn}":
    check_command         => "check_nrpe_command!check_mount${sanitized_mount}",
    service_description   => "Mount ${mountpoint}",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }

}
