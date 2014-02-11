# == Define: icinga::group
#
# This class provides the ability to manage Icinga groups.
#
define icinga::group (
  $ensure               = present,
  $members              = undef,
  $contactgroup_members = undef,
  $contactgroup_name    = $name,
  $local                = false,
  $target               = $::icinga::targetdir_contacts
) {
  $owner = $::icinga::server_user
  $group = $::icinga::server_group

  if $::icinga::server {
    if ($local) {
      nagios_contactgroup { $name:
        ensure               => $ensure,
        contactgroup_name    => $contactgroup_name,
        contactgroup_members => $contactgroup_members,
        members              => $members,
        target               => $target,
      }
    } else {
      @@nagios_contactgroup { $name:
        ensure               => $ensure,
        contactgroup_name    => $contactgroup_name,
        contactgroup_members => $contactgroup_members,
        members              => $members,
        target               => $target,
      }
    }
  }
}

