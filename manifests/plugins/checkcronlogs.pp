# == Class: icinga::plugins::checkcronlogs
#
# This defined type provides a checkcronlogs plugin.
#
class icinga::plugins::checkcronlogs (
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
  $ignored_jobs          = hiera(ignored_jobs, undef),

) inherits icinga {


    file { "${::icinga::plugindir}/check_cron_logs.sh":
        ensure  => present,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        source  => 'puppet:///modules/icinga/check_cron_logs.sh',
        notify  => Service[$icinga::service_client],
        require => Class['icinga::config'];
    }
    file{"${::icinga::includedir_client}/check_cron_logs.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => template('icinga/plugins/cron_logs.cfg.erb'),
      notify  => Service[$::icinga::service_client],
    }



    @@nagios_service { "check_cron_logs_${::fqdn}":
      check_command         => 'check_nrpe_command!check_cron_logs',
      check_interval        => '60',
      service_description   => 'Check cron logs',
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
    sudo::conf{'cron_logs_check_conf':
    content => "Defaults:nagios !requiretty
    nagios ALL=(ALL) NOPASSWD:${::icinga::plugindir}/check_cron_logs.sh\n",
    }

  }

