class icinga::plugins::pnp4nagios::install {

  $package = $::operatingsystem ? {
    /Debian|Ubuntu/                       => 'pnp4nagios',
    /CentOS|RedHat|Scientific|OEL|Amazon/ => 'pnp4nagios',
  }

  package { $package:
    ensure => present;
  }
}

