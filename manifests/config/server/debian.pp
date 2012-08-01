class icinga::config::server::debian {
  if $::icinga::server {
    File {
      owner   => $::icinga::server_user,
      group   => $::icinga::server_group,
      require => Class['icinga::install'],
      notify  => [
        Service[$::icinga::service_client],
        Service[$::icinga::service_server],
        Group[$::icinga::server_cmd_group]
      ],
    }

    file {
      $::icinga::confdir_server:
        ensure => present;

      $::icinga::icinga_vhost:
        ensure  => present,
        content => template('icinga/debian/apache2.conf'),
        notify  => Service[$::icinga::service_webserver];

      $::icinga::htaccess:
        ensure => present;

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

      "${::icinga::sharedir_server}/images/logos":
        ensure  => directory;

      "${::icinga::sharedir_server}/images/logos/os":
        ensure  => directory,
        recurse => true,
        source  => 'puppet:///modules/icinga/img-os';
    }

    nagios_command {
      'check_nrpe_command':
        command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$',
        target       => "${::icinga::targetdir}/commands/puppet-check_nrpe_command.cfg";
    }
  }
}
