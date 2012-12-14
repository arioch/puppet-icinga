class icinga::default::hostgroups {

  @@nagios_hostgroup{'all':
    hostgroup_name => 'all',
    alias          => 'All Servers',
    members        => '*',
  }

}
