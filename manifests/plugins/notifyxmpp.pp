# == Class: icinga::plugins::notifyxmpp
#
# This class provides an xmpp notification plugin.
#
class icinga::plugins::notifyxmpp (
  $xmpp_client = 'UNSET',
  $xmpp_jid    = 'UNSET',
  $xmpp_server = 'UNSET',
  $xmpp_auth   = 'UNSET',
  $xmpp_port   = '5222'
) {

  require ::icinga

  if $xmpp_client == 'UNSET' {
    fail('You should provide an xmpp_client but did not set the var')
  }

  if $xmpp_jid == 'UNSET' {
    fail('You should provide an xmpp_jid but did not set the var')
  }

  if $xmpp_server == 'UNSET' {
    fail('You should provide an xmpp_server but did not set the var')
  }

  if $xmpp_auth == 'UNSET' {
    fail('You should provide an xmpp_auth but did not set the var')
  }

  if $icinga::server {
    file { "${::icinga::plugindir}/notify_via_jabber":
      ensure  => present,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template ('icinga/plugins/notify_via_jabber'),
      notify  => Service[$icinga::service_server],
      require => Class['icinga::config'];
    }

    @@nagios_command{'notify-by-xmpp':
      ensure       => present,
      command_line => '$USER1$/notify_via_jabber "$NOTIFICATIONTYPE$ $HOSTNAME$ $SERVICEDESC$ $SERVICESTATE$ $SERVICEOUTPUT$ $LONGDATETIME$" $CONTACTPAGER$',
      target       => "${::icinga::targetdir}/commands/puppet-notify-by-xmpp.cfg",
    }

    @@nagios_command{'host-notify-by-xmpp':
      ensure       => present,
      command_line => '$USER1$/notify_via_jabber "Host \'$HOSTALIAS$\' is $HOSTSTATE$ - Info : $HOSTOUTPUT$" $CONTACTPAGER$',
      target       => "${::icinga::targetdir}/commands/puppet-notify-by-xmpp.cfg",
    }
  }
}
