# == Class: icinga::plugins::checkcertexpiry
#
# This defined type provides a checkcertexpiry plugin.
#
define icinga::plugins::checkcertexpiry (
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $warning_days          = 14,
  $critical_days         = 4,
) {
    require ::icinga

    if ! defined(Package['nagios-plugins-ssl-cert']) {
      package{ 'nagios-plugins-ssl-cert':
        ensure => present,
      }
    }

    if ! defined(Sudo::Conf['ssl_cert_expity']) {
      sudo::conf{'ssl_cert_expity':
        content => "Defaults:nagios !requiretty
        nagios ALL=(ALL) NOPASSWD:/usr/lib64/nagios/plugins/check_ssl-cert\n",
      }
    }

    $cert = inline_template("<%= @name.gsub(/\/.*\//,'') %>")
    file{"${::icinga::includedir_client}/check_cert_expiry_${cert}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/check_cert_expiry.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_cert_expiry_${::fqdn}_${cert}":
      check_command         => "check_nrpe_command!check_local_cert_expiry_${cert}",
      service_description   => "Check Cert Expiry - ${cert}",
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }

  }



