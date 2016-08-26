# == Define: icinga::plugins::checkhaproxy
#
# This define exports all IP addresses we want
# to check.
#
define icinga::plugins::checkhaproxy::nagios_service (
  $url_to_check = $title,
) {

  include ::icinga::plugins::checkhaproxy

  $ip_address_from_string = inline_template("<%= @url_to_check.gsub(/.*?([1-9][0-9.]*[0-9]).*/, '\\1') %>")

  @@nagios_service { "check_haproxy_${::fqdn}_${url_to_check}":
    check_command         => "check_nrpe_command_args!check_haproxy!'${url_to_check}'",
    service_description   => "HAProxy check on ${ip_address_from_string}",
    host_name             => $::fqdn,
    contact_groups        => $::icinga::plugins::checkhaproxy::contact_groups,
    notification_period   => $::icinga::plugins::checkhaproxy::notification_period,
    notifications_enabled => $::icinga::plugins::checkhaproxy::notifications_enabled,
    max_check_attempts    => $::icinga::plugins::checkhaproxy::max_check_attempts,
    target                => $::icinga::plugins::checkhaproxy::target,
  }

}
