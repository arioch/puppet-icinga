class icinga::plugins::checkstatsd (
	$ensure                       = present,
  $contact_groups               = $::environment,
  $max_check_attempts           = $::icinga::max_check_attempts,
  $notification_period          = $::icinga::notification_period,
  $notifications_enabled        = $::icinga::notifications_enabled,
) inherits icinga {
	
	file{"${::icinga::plugindir}/check_service.sh":
		ensure  => present,
		mode    => '0755',
		owner   => 'root',
		group   => 'root',
		source  => 'puppet:///modules/icinga/check_service.sh',
		notify  => Service[$icinga::service_client],
		require => Class['icinga::config'];
	}

	file { "${::icinga::includedir_client}/check_service.cfg":
		ensure  => file,
		mode 		=> '0644',
		owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    content => template('icinga/plugins/check_service.cfg.erb'),
    notify  => Service[$icinga::service_client],
	}
}