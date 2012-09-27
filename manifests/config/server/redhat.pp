# == Class: icinga::config::server::redhat
#
# This class provides server configuration for RHEL and derivative distro's.
#
class icinga::config::server::redhat {
  if $::icinga::server {
    File {
      owner   => $::icinga::server_user,
      group   => $::icinga::server_group,
      require => Class['icinga::config'],
      notify  => [
        Service[$::icinga::service_client],
        Service[$::icinga::service_server],
        Group[$::icinga::server_cmd_group]
      ],
    }

    file {
      $::icinga::icinga_vhost:
        ensure  => present,
        content => template('icinga/redhat/httpd.conf.erb'),
        notify  => Service[$::icinga::service_webserver];

      $::icinga::htpasswd_file:
        ensure => present,
        mode   => '0644';

      $::icinga::confdir_server:
        ensure  => directory,
        recurse => true,
        purge   => true;

      $::icinga::vardir_server:
        ensure => directory;

      $::icinga::logdir_server:
        ensure => directory;

      $::icinga::targetdir:
        ensure  => directory,
        recurse => true,
        purge   => true;

      "${::icinga::targetdir}/hosts":
        ensure  => directory,
        recurse => true;

      "${::icinga::targetdir}/contacts":
        ensure  => directory,
        recurse => true;

      "${::icinga::targetdir}/services":
        ensure  => directory,
        recurse => true;

      "${::icinga::targetdir}/commands":
        ensure  => directory,
        recurse => true;

      "${::icinga::confdir_server}/modules":
        ensure  => directory,
        recurse => true;

      "${::icinga::targetdir}/commands.cfg":
        ensure  => present,
        content => template('icinga/redhat/commands.cfg.erb');

      "${::icinga::targetdir}/notifications.cfg":
        ensure  => present,
        content => template('icinga/redhat/notifications.cfg.erb');

      "${::icinga::targetdir}/timeperiods.cfg":
        ensure  => present,
        content => template('icinga/redhat/timeperiods.cfg.erb');

      "${::icinga::targetdir}/templates.cfg":
        ensure  => present,
        content => template('icinga/redhat/templates.cfg.erb');

      "${::icinga::confdir_server}/cgi.cfg":
        ensure  => present,
        content => template('icinga/redhat/cgi.cfg.erb');

      "${::icinga::targetdir}/hostgroups.cfg":
        ensure  => present,
        content => template('icinga/redhat/hostgroups.cfg.erb');

      "${::icinga::targetdir}/generic-host.cfg":
        ensure  => present,
        content => template('icinga/redhat/generic-host.cfg');

      "${::icinga::targetdir}/generic-service.cfg":
        ensure  => present,
        content => template('icinga/redhat/generic-service.cfg');

      "${::icinga::confdir_server}/icinga.cfg":
        ensure  => present,
        content => template('icinga/redhat/icinga.cfg.erb');

      "${::icinga::logdir_server}/archives":
        ensure => directory;

      "${::icinga::vardir_server}/rw":
        ensure  => directory,
        group   => $::icinga::server_cmd_group;

      "${::icinga::vardir_server}/checkresults":
        ensure => directory;

      "${::icinga::confdir_server}/resource.cfg":
        ensure  => present,
        content => template('icinga/redhat/resource.cfg.erb');

      "${::icinga::sharedir_server}/images/logos":
        ensure  => directory;

      "${::icinga::sharedir_server}/images/logos/os":
        ensure  => directory,
        recurse => true,
        source  => 'puppet:///modules/icinga/img-os';
    }
  }
}
