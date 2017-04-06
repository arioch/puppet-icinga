# == Class: icinga::plugins::checkhttps
#
# This class provides a checkhttps plugin.
#
define icinga::plugins::checkhttps (
  $vhost                 = $name,
  $port                  = 443,
  $expected_codes        = '200,301,302',
  $contact_groups        = $::environment,
  $max_check_attempts    = $::icinga::max_check_attempts,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

 require ::icinga 
 if $icinga::client {
    @@nagios_service { "check_https_${::fqdn}_${vhost}":
      check_command         => "check_http!-H ${vhost} -S -p ${port} -e ${expected_codes} --sni",
      service_description   => "check https ${vhost}",
      host_name             => $::fqdn,
      contact_groups        => $contact_groups,
      max_check_attempts    => $max_check_attempts,
      notification_period   => $notification_period,
      notifications_enabled => $notifications_enabled,
      target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}
