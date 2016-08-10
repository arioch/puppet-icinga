# == Class: icinga::plugins::elasticsearch::check_number_of_documents
#
# This defined type provides a check of number of documents. When the number
# of documents is too low then you are alerted.
#
define icinga::plugins::elasticsearch::check_number_of_documents (
  $program_name,
  $interval              = '15 minutes ago',
  $max_check_attempts    = $::icinga::max_check_attempts,
  $contact_groups        = $::environment,
  $notification_period   = $::icinga::notification_period,
  $notifications_enabled = $::icinga::notifications_enabled,
) {

  require icinga

  validate_string($interval)
  validate_string($program_name)

  if $icinga::client {

    if (!defined(Package['jq'])) {
      package { 'jq':
        ensure => installed,
      }
    }

    file { "${::icinga::plugindir}/check_number_of_documents.sh":
      ensure  => present,
      mode    => '0755',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      source  => "puppet:///modules/${module_name}/elasticsearch/check_number_of_documents.sh",
      notify  => Service[$icinga::service_client],
      require => Class['icinga::config'];
    }

    file { "${::icinga::includedir_client}/check_number_of_documents_${program_name}.cfg":
      ensure  => 'file',
      mode    => '0644',
      owner   => $::icinga::client_user,
      group   => $::icinga::client_group,
      content => "command[check_number_of_documents_${program_name}]=${::icinga::plugindir}/check_number_of_documents.sh \$ARG1$ '\$ARG2$'",
      notify  => Service[$::icinga::service_client],
    }

    @@nagios_service { "check_number_of_documents_${::fqdn}_${program_name}":
      check_command       => "check_nrpe_command_args!check_number_of_documents_${program_name}!${program_name} '${interval}'",
      service_description => "ES data - occurrence counter of program: ${program_name}",
      host_name           => $::fqdn,
      max_check_attempts  => $max_check_attempts,
      target              => "${::icinga::targetdir}/services/${::fqdn}.cfg",
    }
  }

}
