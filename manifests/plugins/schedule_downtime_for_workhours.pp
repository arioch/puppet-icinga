# == Class: icinga::plugins::schedule_downtime_for_workhours
#
# This class is kind of specific.
#
# We use aNag android app which does not have implemented feature which
# handles $notification_period at all. It means that even when you configure
# notification period to 'workhours', you will be notified in aNag app.
#
# So as a workaround, I created this class which will regularly check all
# the services and for services with 'workhours' will schedule downtime.
#
class icinga::plugins::schedule_downtime_for_workhours (
  $icinga_user = undef,
  $icinga_pass = undef,
  $icinga_url_services = 'http://localhost/icinga/cgi-bin/config.cgi?type=services&jsonoutput',
  $icinga_url_hosts = 'http://localhost/icinga/cgi-bin/config.cgi?type=hosts&jsonoutput',
  $work_dir = '/var/lib/icinga',
  $downtimes = {},
) inherits icinga {

  validate_hash($downtimes)

  file { '/usr/local/bin/get_services_with_workhours.py':
    ensure  => 'file',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template('icinga/plugins/get_services_with_workhours.py.erb'),
  }

  file { $work_dir:
    ensure => 'directory',
    mode   => '0755',
    owner  => $::icinga::server_user,
    group  => $::icinga::server_group,
  }

  cron { "${name}-cron-get-and-save-services-with-workhours":
    command => "/usr/local/bin/get_services_with_workhours.py > ${work_dir}/workhours_downtimes.cfg",
    user    => 'root',
    minute  => '54',
  }

  nagios_command {'schedule_downtime_for_workhours':
    command_line => "${::icinga::sharedir_server}/bin/sched_down.pl -c ${::icinga::confdir_server}/icinga.cfg -s ${work_dir}/workhours_downtimes.cfg \$ARG1\$",
    target       => "${::icinga::targetdir}/commands/schedule_downtime_for_workhours.cfg",
  }

  file {"${::icinga::targetdir}/commands/schedule_downtime_for_workhours.cfg":
    ensure => 'present',
    mode   => '0600',
    owner  => $::icinga::server_user,
    group  => $::icinga::server_group,
  }

  nagios_service {'schedule_downtime_for_workhours':
    check_command       => 'schedule_downtime_for_workhours!-d0',
    service_description => 'Schedule downtimes for services with workhours',
    host_name           => $::fqdn,
    target              => "/etc/icinga/objects/services/${::fqdn}.cfg",
    max_check_attempts  => '4',
  }

}
