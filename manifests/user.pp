# == Define: icinga::user
#
# This class provides the ability to manage Icinga users.
#
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
  $can_submit_commands           = '0',
  $pager                         = '32000000000',
  $hash                          = undef
) {
  $htpasswd = $::icinga::htpasswd_file
  $owner    = $::icinga::server_user
  $group    = $::icinga::server_group

  if $::icinga::server {
    Exec {
      require => File[$htpasswd],
    }

    case $ensure {
      present: {
        if ! $hash {
          exec { "Add Icinga user ${name}":
            command => "htpasswd -b -s ${htpasswd} ${name} ${password}",
            unless  => "grep -iE '^${name}:' ${htpasswd}",
            cwd     => $::icinga::confdir_server,
          }
        } else {
          exec { "Add Icinga user hash ${name}":
            command => "echo \"${hash}\" >> ${htpasswd}",
            unless  => "grep -x ${hash} ${htpasswd}",
          }
        }
      }

      absent: {
        exec { "Remove Icinga user ${name}":
          command => "htpasswd -D htpasswd.users ${name}",
          onlyif  => "grep -iE '^${name}:' ${htpasswd}",
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
      can_submit_commands           => $can_submit_commands,
    }
  }
}
