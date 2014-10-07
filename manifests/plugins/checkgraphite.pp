# == Class: icinga::plugins::checkgraphite
#
# This class provides a checkgraphite plugin.
#
class icinga::plugins::checkgraphite (
  $pkgname                = 'nagios-plugins-graphite',
  $notification_period    = $::icinga::notification_period,
  $notifications_enabled  = $::icinga::notifications_enabled,
  $host_name              = $::fqdn,
  $contact_groups         = $::environment,
) {

  require icinga

  if $icinga::server {
    if ! defined(Package[$pkgname]) {
      package{$pkgname:
        ensure   => present,
      }
    }

    @@nagios_command{'check_graphite':
      ensure       => present,
      command_line => '/usr/bin/check_graphite -u \'$ARG1$\' -w $ARG2$ -c $ARG3$', 
      target       => "${::icinga::targetdir}/commands/check_graphite.cfg",
    }
  }
}
