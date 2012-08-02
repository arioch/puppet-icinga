# Sample Usage

### cat site.pp

    Nagios_service {
      host_name           => $::fqdn,
      use                 => 'generic-service',
      notification_period => '24x7',
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
      action_url          => '/pnp4nagios/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    }
    
    Nagios_contact {
      ensure                        => present,
      use                           => 'generic-contact',
      host_notification_period      => '24x7',
      service_notification_period   => '24x7',
      service_notification_commands => 'notify-service-by-email',
      host_notification_commands    => 'notify-host-by-email',
      target                        => "${::icinga::targetdir}/contacts/puppet-contacts.cfg",
    }

### cat nodes.pp

    node client {
      class { 'icinga': }
    }
    
    node server {
      class {
        'icinga':
          server        => 'true',
          managerepo    => 'true',
          icinga_admins => [ 'admin,', 'dummy1,', 'dummy2' ],
          plugins       => [ 'checkpuppet', 'pnp4nagios' ];
      }
    
      icinga::user {
        'dummy1':
          ensure   => present,
          password => 'default',
          email    => 'dummy1@example.com',
          pager    => '320000001';
    
        'dummy2':
          ensure   => present,
          password => 'default'
          email    => 'dummy2@example.com',
          pager    => '320000002';
      }
    }
    
### Inside your existing modules

    @@nagios_service { "check_tcp_123_${::fqdn}":
      check_command       => 'check_tcp!123',
      service_description => 'check_tcp',
    }


### Unit testing

    bundle exec rake


### Known issues

#### General

  * Needs proper testing

#### RedHat

  * ...

#### Debian

  * Some plugins may or may not work
  * The PNP4Nagios plugin requires the backports repository on Squeeze.
  * The PNP4Nagios plugin will not work on anything older than Squeeze.


