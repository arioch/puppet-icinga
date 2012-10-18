# == Class: icinga::config::client::debian
#
# This class provides client configuration for Debian and derivative distro's.
#
class icinga::config::client::debian {
  if $::icinga::client {
    File {
      owner   => 'root',
      group   => 'root',
      notify  => Service[$::icinga::service_client],
      require => Class['icinga::install'],
    }

    file {
      $::icinga::confdir_client:
        ensure  => directory,
        recurse => true;

      $::icinga::plugindir:
        ensure  => directory;

      "${::icinga::confdir_client}/nrpe.cfg":
        ensure  => present,
        content => template ('icinga/debian/nrpe.cfg.erb');
    }
  }
}
