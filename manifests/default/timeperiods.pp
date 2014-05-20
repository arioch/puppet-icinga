# == Class: icinga::default::timeperiods
#
# This class provides default time period configuration.
#
class icinga::default::timeperiods {

  Nagios_timeperiod {
    notify => Service[$::icinga::service_server],
    target => "${::icinga::targetdir}/timeperiods.cfg",
  }

  nagios_timeperiod{'24x7':
    timeperiod_name => '24x7',
    alias           => 'Purgatory',
    monday          => '00:00-24:00',
    tuesday         => '00:00-24:00',
    wednesday       => '00:00-24:00',
    thursday        => '00:00-24:00',
    friday          => '00:00-24:00',
    saturday        => '00:00-24:00',
    sunday          => '00:00-24:00',
  }

  nagios_timeperiod{'workhours':
    timeperiod_name => 'workhours',
    alias           => 'Daily Routine',
    monday          => '09:00-18:00',
    tuesday         => '09:00-18:00',
    wednesday       => '09:00-18:00',
    thursday        => '09:00-18:00',
    friday          => '09:00-18:00',
  }

  nagios_timeperiod{'nonworkhours':
    timeperiod_name => 'nonworkhours',
    alias           => 'On Call Doody',
    monday          => '00:00-09:00,18:00-24:00',
    tuesday         => '00:00-09:00,18:00-24:00',
    wednesday       => '00:00-09:00,18:00-24:00',
    thursday        => '00:00-09:00,18:00-24:00',
    friday          => '00:00-09:00,18:00-24:00',
    saturday        => '00:00-24:00',
    sunday          => '00:00-24:00',
  }

  nagios_timeperiod{'never':
    timeperiod_name => 'never',
    alias           => 'Ignorance Is Bliss',
  }

}
