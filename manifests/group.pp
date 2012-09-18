# == Define: icinga::group
#
# This class provides the ability to manage Icinga groups.
#
define icinga::group (
  $contactgroup_members,
  $ensure            = present,
  $contactgroup_name = $name,
  $target            = "${::icinga::targetdir}/contacts/groups.cfg",
  $owner             = $::icinga::server_user,
  $group             = $::icinga::server_group,
) {
  if $::icinga::server {
    file { $target:
      ensure => present,
      mode   => '0660',
      owner  => $owner,
      group  => $group,
    }

    @@nagios_contactgroup { $name:
      ensure               => $ensure,
      contactgroup_name    => $contactgroup_name,
      contactgroup_members => $contactgroup_members,
      target               => $target,
    }
  }
}

