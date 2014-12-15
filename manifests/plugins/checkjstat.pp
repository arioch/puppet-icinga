# == Define: icinga::plugins::checklogstash
#
# This define provides a checklogstash plugin.
#
define icinga::plugins::checkjstat (
  $ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
  $devel_pkg                    = 'java-1.7.0-openjdk-devel',
  $process_name                 = $name,
  $warning                      = 70,
  $critical                     = 80,
) {

  require ::icinga

  if !($process_name) {
    fail('You have to define process_name')
  }

  if $icinga::client {
    if !defined(Package[$devel_pkg]) {
      package { $devel_pkg:
        ensure => present,
      }
    }

    include ::sudo
    if !defined(Sudo::Conf['nrpe-jstat']) {
      sudo::conf{'nrpe-jstat':
        content => "${::icinga::client_user} ALL=(root) NOPASSWD:/usr/bin/jstat\n",
      }
    }

    if !defined(File["${::icinga::plugindir}/check_jstat.sh"]) {
      file { "${::icinga::plugindir}/check_jstat.sh":
        ensure  => present,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        source  => 'puppet:///modules/icinga/check_jstat.sh',
        notify  => Service[$icinga::service_client],
        require => Class['icinga::config'];
      }
    }

    if !defined(File["${::icinga::includedir_client}/check_jstat.cfg"]) {
      file { "${::icinga::includedir_client}/check_jstat.cfg":
        ensure  => 'file',
        mode    => '0644',
        owner   => $::icinga::client_user,
        group   => $::icinga::client_group,
        content => "command[check_jstat]=${::icinga::plugindir}/\
check_jstat.sh -s \$ARG1$ -w \$ARG2$ -c \$ARG3$",
        notify  => Service[$::icinga::service_client],
      }
    }

    @@nagios_service { "check_jstat_of_${process_name}_${::fqdn}":
      check_command         => "check_nrpe_command_args!check_jstat!\
${process_name} ${warning} ${critical}",
      service_description   => "${process_name} - memory usage",
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      max_check_attempts    => $max_check_attempts,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }
}
