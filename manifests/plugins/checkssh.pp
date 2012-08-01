class icinga::plugins::checkssh (
  $sshport        = '22',
  $check_warning  = '',
  $check_critical = ''
) {
  if $icinga::client {
    @@nagios_service { "check_ssh_${::hostname}":
      check_command       => "check_ssh!-p ${sshport}",
      service_description => 'SSH',
    }
  }
}

