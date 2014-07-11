# Class: icinga::plugins::notifytwilio
#
class icinga::plugins::notifytwilio (
  $from          = undef,
  $user_id       = undef,
  $auth_token    = undef,
  $timeout       = 5,
  $split_big_msg = 0,
  $deferred_dir  = '/tmp',
  $defer_enabled = 1,
  $max_tries     = 3,
  $msg_rewrite   = 0,
) {

  require ::icinga

  if $::icinga::server {
    file{"${::icinga::plugindir}/notify-by-twilio":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('icinga/plugins/notify-by-twilio'),
      notify  => Service[$::icinga::service_server],
      require => Class['::icinga::config'],
    }

    file { "${::icinga::confdir_server}/notify-by-twilio.conf":
      ensure  => file,
      mode    => '0644',
      owner   => 'icinga',
      group   => 'icinga',
      content => template('icinga/plugins/notify-by-twilio.conf.erb'),
    }

    package { 'perl-IO-Socket-SSL': }

    @@nagios_command{'notify-host-by-twilio':
      ensure       => present,
      command_line => '$USER1$/notify-by-twilio -m "[$NOTIFICATIONTYPE$]: $HOSTALIAS$ is $HOSTSTATE$" -- $CONTACTPAGER$',
      target       => "${::icinga::targetdir}/commands/notify-by-twilio.cfg",
    }

    @@nagios_command{'notify-service-by-twilio':
      ensure       => present,
      command_line => '$USER1$/notify-by-twilio -m "[$NOTIFICATIONTYPE$]: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$" -- $CONTACTPAGER$',
      target       => "${::icinga::targetdir}/commands/notify-by-twilio.cfg",
    }

    cron{'twilio-process-deferred-messages':
      ensure  => present,
      minute  => '*/15',
      command => "${::icinga::plugindir}/notify-by-twilio -P &>/dev/null",
    }
  }
}
