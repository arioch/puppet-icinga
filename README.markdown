[![Build
Status](https://travis-ci.org/Inuits/puppet-icinga.svg)](https://travis-ci.org/Inuits/puppet-icinga)
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
      target                        => "${::icinga::targetdir}/contacts/contacts.cfg",
      can_submit_commands           => '1',
    }

### cat nodes.pp

    node client {
      class { 'icinga': }
    }
    
    node server {
      class {
        'icinga':
          server        => 'true',
          manage_repo   => 'true',
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


### PuppetDoc

Parsed PuppetDoc can be found [here](http://arioch.github.com/puppet-icinga/).


### Unit testing

    bundle exec rake


### Nagios plugin packages

Packages for RHEL based operating systems can be found at Inuits' [RPM repository]
A Debian mirror is currently not available yet. Building your own packages is very easy. You will find any necessary information on Inuits' [nagios-plugins] repository at Github.

[RPM repository]: http://repo.inuits.eu
[nagios-plugins]: https://github.com/Inuits/nagios-plugins

### Known issues

#### General

  * Needs proper testing
  * Using multiple Icinga servers with identical usernames you might run into the error below:
 
    err: Failed to apply catalog: Cannot alias Nagios_contact[icinga.example.org-someuser] 
    to ["someuser"] at /etc/puppet/environments/refactor/modules/icinga/manifests/user.pp:48;
    resource ["Nagios_contact", "someuser"] already declared


#### RedHat

  * Be aware if you wish to manage your own package repositories you're in for
  a treat. You need packages from both the RPMForge and the EPEL repository.
  However - and here's the tricky part - some of those packages conflict with
  the ones in the other repository. The easiest way is to take Icinga and it's
  dependencies from RPMForge. Nagios-plugins related packages should not be
  taken from this repository otherwise a lot of EPEL packages or plugins will
  break horribly.

  The easy way out:
    class { icinga: manage_repo => true; }

  A more advanced approach would be to set up your own repo.
  Hipsters these days seem to be fond of [Pulp] for this purpose.

  [Pulp]: https://github.com/pulp/pulp

#### Debian

  * Some plugins may or may not work
  * The PNP4Nagios plugin requires the backports repository on Squeeze.
  * The PNP4Nagios plugin will not work on anything older than Squeeze.

