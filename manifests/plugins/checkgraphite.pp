# == Class: icinga::plugins::checkgraphite
#
# This class provides a checkgraphite plugin.
#
class icinga::plugins::checkgraphite (
  $pkgname                = 'check_graphite',
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
) {

  require icinga

  if $icinga::server {
    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure => present,
        provider => 'gem',
      }
    }
  }
}
