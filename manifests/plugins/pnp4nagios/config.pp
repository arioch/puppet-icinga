class icinga::plugins::pnp4nagios::config {
  File {
    owner   => $::icinga::server_user,
    group   => $::icinga::server_group,
    require => [
      Class['icinga::install'],
      Class['icinga::plugins::pnp4nagios::install'],
    ],
    notify  => [
      Service[$::icinga::service_server],
      Service[$::icinga::service_webserver],
    ]
  }

  $confdir = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => '/etc/pnp4nagios',
    /Debian|Ubuntu/                       => '/etc/pnp4nagios',
  }

  $libdir = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => '/var/lib/pnp4nagios',
    /Debian|Ubuntu/                       => '/var/lib/pnp4nagios',
  }

  $libexec = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => '/usr/libexec/pnp4nagios',
    /Debian|Ubuntu/                       => '/usr/lib/pnp4nagios/libexec',
  }

  $logdir = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => '/var/log/pnp4nagios',
    /Debian|Ubuntu/                       => '/var/log/pnp4nagios',
  }

  $vhost = $::operatingsystem ? {
    /CentOS|RedHat|Scientific|OEL|Amazon/ => "${confdir}/apache2.conf",
    /Debian|Ubuntu/                       => "${confdir}/apache.conf",
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
