# == Class: icinga::params
#
# Full description of class icinga here.
#
class icinga::params {
  $manage_repo                               = false
  $client                                    = true
  $server                                    = false
  $collect_resources                         = true
  $use_auth                                  = true
  $plugins                                   = [ 'checkpuppet' ]
  $nrpe_allowed_hosts                        = [ '127.0.0.1,', $::ipaddress ]
  $nrpe_command_timeout                      = '60'
  $nrpe_connect_timeout                      = '10'
  $nrpe_server_address                       = $::ipaddress
  $nrpe_server_port                          = '5666'
  $nrpe_allow_arguments                      = '0'
  $nrpe_enable_debug                         = '0'
  $icinga_admins                             = '*'
  $collect_hostname                          = $::fqdn
  $notification_cmd_host                     = 'notify-host-by-email'
  $notification_cmd_service                  = 'notify-service-by-email'
  $notification_period                       = '24x7'
  $notification_host_enable                  = '1'
  $notification_host_opts                    = 'd,r'
  $notification_service_enable               = '1'
  $notification_service_opts                 = 'w,u,c,r'
  $notification_interval                     = '0'
  $max_check_attempts                        = '4'
  $use_ido                                   = false
  $use_flapjackfeeder                        = false
  $parents                                   = undef
  $hostgroups                                = 'default'
  $notifications_enabled                     = '1'
  $export_resources                          = true
  $logdir_client                             = '/var/log/nrpe'
  $logdir_server                             = '/var/log/icinga'
  $set_expire_ack_by_default                 = '0'
  $service_perfdata_file                     = '/usr/local/pnp4nagios/var/service-perfdata'
  $process_service_perfdata_file             = 'process-service-perfdata-file'
  $service_perfdata_file_template            = 'DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE'
  $service_perfdata_file_processing_interval = '15'

  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      $package = $::lsbdistcodename ? {
        'squeeze' => 'pnp4nagios/squeeze-backports',
        default   => 'pnp4nagios',
      }

      $package_client_ensure     = 'present'
      $package_server_ensure     = 'present'
      $package_client            = [ 'nagios-nrpe-server', 'nagios-plugins' ]
      $package_server            = [ 'icinga', 'icinga-core', 'icinga-common', 'icinga-cgi', 'icinga-phpapi', 'nagios-nrpe-plugin' ]
      $service_client            = 'nagios-nrpe-server'
      $service_client_ensure     = 'running'
      $service_client_enable     = true
      $service_client_hasstatus  = false
      $service_client_hasrestart = true
      $service_client_pattern    = 'nrpe'
      $service_server            = 'icinga'
      $service_server_ensure     = 'running'
      $service_server_enable     = true
      $service_server_hasstatus  = true
      $service_server_hasrestart = true
      $pidfile_client            = '/var/run/nagios/nrpe.pid'
      $pidfile_server            = '/var/run/icinga/icinga.pid'
      $confdir_client            = '/etc/nagios'
      $confdir_server            = '/etc/icinga'
      $vardir_client             = '/var/lib/nagios'
      $vardir_server             = '/var/lib/icinga'
      $sharedir_server           = '/usr/share/icinga/htdocs'
      $includedir_client         = '/etc/nagios/nrpe.d'
      $usrlib                    = '/usr/lib'
      $service_webserver         = 'apache2'
      $webserver_user            = 'www-data'
      $webserver_group           = 'www-data'
      $server_user               = 'nagios'
      $server_group              = 'nagios'
      $client_user               = $server_user
      $client_group              = $server_group
      $server_cmd_group          = $server_group
      $htpasswd_file             = "${confdir_server}/htpasswd.users"
      $targetdir                 = "${confdir_server}/objects"
      $targetdir_contacts        = "${targetdir}/contacts/contacts.cfg"
      $icinga_vhost              = '/etc/icinga/apache2.conf'
      $mail_command              = '/usr/bin/mail'

      # IDOUTILS: TO BE REFACTORED
      $idoutils_pkg     = 'icinga-idoutils'
      $idoutils_confdir = '/etc/icinga/idoutils'
      $idoutils_service = 'ido2db'
      $idoutils_dbname  = 'icinga'
      $idoutils_dbuser  = 'icinga'
      $idoutils_dbpass  = 'icinga'

      # Plugin: Report
      $jasper_vhost              = '/etc/apache2/conf.d/jasperserver.conf'
    }

    'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon': {
      case $::architecture {
        'x86_64': { $usrlib = '/usr/lib64' }
        default:  { $usrlib = '/usr/lib'   }
      }

      # Icinga
      $package_client_ensure     = 'present'
      $package_server_ensure     = 'present'
      $package_client            = [ 'nagios-nrpe', 'nagios-plugins', 'nagios-plugins-all' ]
      $package_server            = [ 'icinga', 'icinga-doc', 'icinga-gui', 'nagios-plugins-nrpe', 'perl-Date-Calc' ]
      $service_client            = 'nrpe'
      $service_client_ensure     = 'running'
      $service_client_enable     = true
      $service_client_hasstatus  = true
      $service_client_hasrestart = true
      $service_client_pattern    = ''
      $service_server            = 'icinga'
      $service_server_ensure     = 'running'
      $service_server_enable     = true
      $service_server_hasstatus  = true
      $service_server_hasrestart = true
      $pidfile_client            = '/var/run/nagios/nrpe.pid'
      $pidfile_server            = '/var/run/icinga.pid'
      $confdir_client            = '/etc/nagios'
      $confdir_server            = '/etc/icinga'
      $vardir_client             = '/var/icinga'
      $vardir_server             = '/var/icinga'
      $sharedir_server           = '/usr/share/icinga'
      $includedir_client         = '/etc/nrpe.d'
      $service_webserver         = 'httpd'
      $webserver_user            = 'apache'
      $webserver_group           = 'apache'
      $server_user               = 'icinga'
      $server_group              = 'icinga'
      $client_user               = 'nagios'
      $client_group              = 'nagios'
      $server_cmd_group          = 'icingacmd'
      $htpasswd_file             = "${confdir_server}/htpasswd.users"
      $targetdir                 = "${confdir_server}/objects"
      $targetdir_contacts        = "${targetdir}/contacts/contacts.cfg"
      $icinga_vhost              = '/etc/icinga/apache2.conf'
      $mail_command              = '/bin/mail'

      # Plugin: Icinga Web
      $icingaweb_pkg             = [ 'icinga-web' ]
      $icingaweb_pkg_dep         = [ 'perl-Locale-PO', 'php-ldap', 'php-pear', 'php-xml', 'php-mysql' ]
      $icingaweb_confdir         = '/usr/share/icinga-web'
      $icingaweb_bindir          = "${icingaweb_confdir}/bin:${::path}"
      $icingaweb_logdir          = '/usr/share/icinga-web/log'
      $icingaweb_dbname          = 'icinga_web'
      $icingaweb_dbuser          = 'icinga_web'
      $icingaweb_dbpass          = 'icinga_web'
      $icingaweb_vhost           = '/etc/httpd/conf.d/icinga-web.conf'

      # Plugin: IDOUtils
      $idoutils_pkg              = [ 'icinga-idoutils', 'libdbi', 'libdbi-devel', 'libdbi-drivers', 'libdbi-dbd-mysql' ]
      $idoutils_confdir          = '/etc/icinga/idoutils'
      $idoutils_service          = 'ido2db'
      $idoutils_dbname           = 'icinga'
      $idoutils_dbuser           = 'icinga'
      $idoutils_dbpass           = 'icinga'

      # Plugin: Report
      $jasper_vhost              = '/etc/httpd/conf.d/jasperserver.conf'
    }

    default: {}
  }

  # Needs to be down here since $usrlib is defined in the distro specific params
  $plugindir                 = "${usrlib}/nagios/plugins"

}
