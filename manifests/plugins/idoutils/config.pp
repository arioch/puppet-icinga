# == Class: icinga::plugins::idoutils::config
#
# This class provides the idoutils plugin's configuration.
#
class icinga::plugins::idoutils::config {
  File {
    require => Package[$icinga::idoutils_pkg],
    notify  => Service[$icinga::service_server],
  }

  file {
    $icinga::idoutils_confdir:
      ensure => directory;

    "${::icinga::confdir_server}/ido2db.cfg":
      ensure  => present,
      mode    => '0640',
      owner   => $icinga::server_user,
      group   => $icinga::server_group,
      content => template('icinga/plugins/idoutils/ido2db.cfg.erb');

    "${::icinga::confdir_server}/idomod.cfg":
      ensure  => present,
      content => template('icinga/plugins/idoutils/idomod.cfg');
  }
}
