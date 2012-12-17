class icinga::default::hostgroups {

  @@nagios_hostgroup{'all':
    hostgroup_name => 'all',
    alias          => 'All Servers',
    members        => '*',
  }

  @@nagios_hostgroup{'default':
    hostgroup_name => 'default',
    alias          => 'Default hostgroup',
  }

}
