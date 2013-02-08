# == Class: icinga::plugins::notifyxmpp
#
# This class provides an xmpp notification plugin.
#
class icinga::plugins::notifyxmpp (
  $xmpp_client,
  $xmpp_jid,
  $xmpp_server,
  $xmpp_auth,
  $xmpp_port = '5222'
) {

  require ::icinga

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
