# == Class: icinga::preinstall
#
# This class provides anything required by the installation class.
# Such as package repositories.
#
class icinga::preinstall {
  resources {
    [
      'nagios_command',
      'nagios_contact',
      'nagios_contactgroup',
      'nagios_host',
      'nagios_hostdependency',
      'nagios_hostescalation',
      'nagios_hostextinfo',
      'nagios_hostgroup',
      'nagios_service',
      'nagios_servicedependency',
      'nagios_serviceescalation',
      'nagios_serviceextinfo',
      'nagios_servicegroup',
      'nagios_timeperiod'
    ]:
    purge => true;
  }

  if $icinga::manage_repo {
    case $::operatingsystem {
      'Debian', 'Ubuntu': {
      }

      'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon': {
        $epel_mirror = $::operatingsystemrelease ? {
          /^5/    => 'https://mirrors.fedoraproject.org/metalink?repo=epel-5&arch=$basearch',
          /^6/    => 'https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch',
          default => Fail['Operating system or release version not supported.'],
        }

        $epel_gpgkey = $::operatingsystemrelease ? {
          /^5/    => 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5',
          /^6/    => 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6',
          default => Fail['Operating system or release version not supported.'],
        }

        $rpmforge_mirror = $::operatingsystemrelease ? {
          /^5/     => 'http://apt.sw.be/redhat/el5/en/mirrors-rpmforge',
          /^6/     => 'http://apt.sw.be/redhat/el6/en/mirrors-rpmforge',
          default  => Fail['Operating system or release version not supported.'],
        }

        $inuits_mirror = $::operatingsystemrelease ? {
          /^5/     => 'http://repo.inuits.eu/centos/5/os',
          /^6/     => 'http://repo.inuits.eu/pulp/centos/6/os/x86_64',
          default  => Fail['Operating system or release version not supported.'],
        }

        yumrepo { 'epel':
          descr      => 'Extra Packages for Enterprise Linux',
          mirrorlist => $epel_mirror,
          gpgkey     => $epel_gpgkey,
          enabled    => 1,
          gpgcheck   => 1;
        }

        yumrepo {
          'rpmforge':
            descr      => 'RHEL - RPMforge.net - dag',
            mirrorlist => $rpmforge_mirror,
            gpgkey     => 'http://apt.sw.be/RPM-GPG-KEY.dag.txt',
            exclude    => 'nagios-plugins-*',
            enabled    => 1,
            gpgcheck   => 1;
        }

        yumrepo {
          'inuits':
            descr    => 'Inuits repository',
            baseurl  => $inuits_mirror,
            exclude  => '!^nagios-plugins-*',
            enabled  => 1,
            gpgcheck => 0;
        }
      }

      default: {}
    }
  }
}

