# == Class: icinga::plugins::checkgraphite
#
# This class provides a checkgraphite plugin.
#
class icinga::plugins::checkgraphite (
  $pkgname                = 'nagios-plugins-graphite',
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
      command_line => '$USER1$/check_graphite -u \'$ARG1$\' -w $ARG2$ -c $ARG3$',
      target       => "${::icinga::targetdir}/commands/check_graphite.cfg",
    }
  }
}
