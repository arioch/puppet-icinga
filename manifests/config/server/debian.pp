# == Class: icinga::config::server::debian
#
# This class provides server configuration for Debian and derivative distro's.
#
class icinga::config::server::debian {
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

    nagios_command {
      'check_nrpe_command':
        command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
        target       => "${::icinga::targetdir}/commands/check_nrpe_command.cfg";
    }

    file {
      $::icinga::confdir_server:
        ensure => present;

      $::icinga::htpasswd_file:
        ensure => present,
        mode   => '0644';

      $::icinga::icinga_vhost:
        ensure  => present,
        content => template('icinga/debian/apache2.conf'),
        notify  => Service[$::icinga::service_webserver];

      "${::icinga::confdir_server}/objects":
        ensure => directory;

      "${::icinga::confdir_server}/objects/hosts":
        ensure  => directory,
        recurse => true;

      "${::icinga::confdir_server}/objects/commands":
        ensure  => directory,
        recurse => true;

      "${::icinga::confdir_server}/objects/services":
        ensure  => directory,
        recurse => true;

      "${::icinga::confdir_server}/objects/contacts":
        ensure  => directory,
        recurse => true;

      "${::icinga::confdir_server}/icinga.cfg":
        ensure  => present,
        content => template('icinga/debian/icinga.cfg');

      "${::icinga::confdir_server}/cgi.cfg":
        ensure  => present,
        content => template('icinga/debian/cgi.cfg');

      "${::icinga::confdir_server}/objects/generic-host_icinga.cfg":
        ensure  => present,
        content => template('icinga/debian/objects/generic-host_icinga.cfg');

      "${::icinga::confdir_server}/objects/hostgroups_icinga.cfg":
        ensure  => present,
        content => template('icinga/debian/objects/hostgroups_icinga.cfg');

      "${::icinga::sharedir_server}/images/logos":
        ensure  => directory;

      "${::icinga::sharedir_server}/images/logos/os":
        ensure  => directory,
        recurse => true,
        source  => 'puppet:///modules/icinga/img-os';
    }
  }
}
