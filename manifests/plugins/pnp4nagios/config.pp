# == Class: icinga::plugins::pnp4nagios::config
#
# This class provides the pnp4nagios plugin's configuration.
#
class icinga::plugins::pnp4nagios::config {
  File {
    owner   => $::icinga::server_user,
    group   => $::icinga::server_group,
    require => [
      Class['icinga::config'],
      Class['icinga::plugins::pnp4nagios::install'],
    ],
    notify  => [
      Service[$::icinga::service_server],
      Service[$::icinga::service_webserver],
    ]
  }

  $confdir = $::operatingsystem ? {
    default => '/etc/pnp4nagios',
  }

  $libdir = $::operatingsystem ? {
    default => '/var/lib/pnp4nagios',
  }

  $logdir = $::operatingsystem ? {
    default => '/var/log/pnp4nagios',
  }

  $vhost = $::operatingsystem ? {
    default => "${confdir}/apache2-pnp4nagios.conf",
  }

  $libexec = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => '/usr/libexec/pnp4nagios',
    /Debian|Ubuntu/                       => '/usr/lib/pnp4nagios/libexec',
  }

  $htmldir = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => '/usr/share/nagios/html/pnp4nagios',
    /Debian|Ubuntu/                       => '/usr/share/pnp4nagios/html',
  }

  file {
    $confdir:
      ensure => directory;

    $libdir:
      ensure => directory;

    $logdir:
      ensure => directory;

    '/usr/local/pnp4nagios':
      ensure => directory;

    '/usr/local/pnp4nagios/var':
      ensure => directory;

    $vhost:
      ensure  => $::icinga::plugins::pnp4nagios::ensure,
      content => template('icinga/plugins/pnp4nagios/pnp4nagios.conf.erb');

    "${::icinga::targetdir}/commands-perfdata.cfg":
      ensure  => $::icinga::plugins::pnp4nagios::ensure,
      content => template('icinga/plugins/pnp4nagios/commands-perfdata.cfg.erb');
  }
}

