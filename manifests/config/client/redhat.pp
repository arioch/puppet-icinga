# == Class: icinga::config::client::redhat
#
# This class provides client configuration for RHEL and derivative distro's.
#
class icinga::config::client::redhat {
  File {
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
    require => Class['icinga::install'],
  }

  file {
    $::icinga::confdir_client:
      ensure  => directory,
      recurse => true;

    $::icinga::plugindir:
      ensure => directory;

    "${::icinga::confdir_client}/nrpe.cfg":
      ensure  => present,
      content => template('icinga/redhat/nrpe.cfg.erb');

    $::icinga::logdir_client:
      ensure => directory;

    $::icinga::includedir_client:
      ensure => directory;

    "${::icinga::includedir_client}/default.cfg":
      ensure  => present,
      content => template('icinga/redhat/nrpe_default.cfg.erb');
  }
}
