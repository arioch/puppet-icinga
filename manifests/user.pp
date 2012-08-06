define icinga::user (
  $ensure                        = present,
  $password                      = 'default',
  $host_notification_period      = '24x7',
  $service_notification_period   = '24x7',
  $service_notification_commands = 'notify-service-by-email',
  $host_notification_commands    = 'notify-host-by-email',
  $target                        = "${::icinga::targetdir}/contacts/contacts.cfg",
  $contact_name                  = $name,
  $email                         = "${name}@${::domain}",
  $pager                         = '32000000000'
) {
  if $::icinga::server {
    Exec {
      require => File[$::icinga::htpasswd_file],
    }

    case $ensure {
      present: {
        exec { "add icinga user ${name}":
          command => "htpasswd -b -s htpasswd.users ${name} ${password}",
          unless  => "grep -iE '^${name}:' ${::icinga::htpasswd_file}",
          cwd     => $::icinga::confdir_server,
        }
      }

      absent: {
        exec { "remove icinga user ${name}":
          command => "htpasswd -D htpasswd.users ${name}",
          onlyif  => "grep -iE '^${name}:' ${::icinga::htpasswd_file}",
          cwd     => $::icinga::confdir_server,
        }
      }

      default: {}
    }

    @@nagios_contact { "${::fqdn}-${name}":
      ensure                        => $ensure,
      contact_name                  => $contact_name,
      email                         => $email,
      pager                         => $pager,
      host_notification_period      => $host_notification_period,
      service_notification_period   => $service_notification_period,
      service_notification_commands => $service_notification_commands,
      host_notification_commands    => $host_notification_commands,
      target                        => $target,
    }
  }
}
