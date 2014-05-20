# == Define: icinga::user
#
# This class provides the ability to manage Icinga users.
#
define icinga::user (
  $password,
  $ensure                        = present,
  $can_submit_commands           = '0',
  $contact_name                  = $name,
  $contactgroups                 = undef,
  $email                         = undef,
  $hash                          = undef,
  $pager                         = undef,
  $host_notification_commands    = $::icinga::notification_cmd_host,
  $host_notification_period      = $::icinga::notification_period,
  $host_notifications_enabled    = $::icinga::notification_host_enable,
  $host_notification_options     = $::icinga::notification_host_opts,
  $service_notification_commands = $::icinga::notification_cmd_service,
  $service_notification_period   = $::icinga::notification_period,
  $service_notifications_enabled = $::icinga::notification_service_enable,
  $service_notification_options  = $::icinga::notification_service_opts,
  $target                        = $::icinga::targetdir_contacts
) {
  $htpasswd = $::icinga::htpasswd_file
  $owner    = $::icinga::server_user
  $group    = $::icinga::server_group
  $service  = $::icinga::service_server

  if $::icinga::server {
    Exec {
      require => File[$htpasswd],
      notify  => Service[$service],
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
            command => "echo \"${name}:${hash}\" >> ${htpasswd}",
            unless  => "grep -iE '^${name}:' ${htpasswd}",
          }
        }
      }

      absent: {
        exec { "Remove Icinga user ${name}":
          command => "htpasswd -D ${htpasswd} ${name}",
          onlyif  => "grep -iE '^${name}:' ${htpasswd}",
          cwd     => $::icinga::confdir_server,
        }
      }

      default: {
        fail "Invalid value for \$icinga::user::ensure: ${ensure}."
      }
    }

    nagios_contact { $name:
      ensure                        => $ensure,
      can_submit_commands           => $can_submit_commands,
      contact_name                  => $contact_name,
      contactgroups                 => $contactgroups,
      email                         => $email,
      pager                         => $pager,
      target                        => $target,
      host_notification_commands    => $host_notification_commands,
      host_notification_period      => $host_notification_period,
      host_notifications_enabled    => $host_notifications_enabled,
      host_notification_options     => $host_notification_options,
      service_notification_commands => $service_notification_commands,
      service_notification_period   => $service_notification_period,
      service_notifications_enabled => $service_notifications_enabled,
      service_notification_options  => $service_notification_options,
    }
  }
}
