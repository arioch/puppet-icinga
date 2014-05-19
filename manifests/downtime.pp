# == Class: icinga::downtime
#
# This class provides the ability to schedule downtime for hosts or services
#
# "hostname", "hostgroups", and "servicegroups" are mandatory and mutually exclusive.
# "service_description" is optional. If not defined a downtime for a host / hostgroup(s) / servicegroup(s) is/are scheduled. If defined it can be a single service or "all" for all services of a single host or all hosts of a hostgroup.
# "duration" is optional and must be defined if a flexible downtime is to be scheduled.
# "fixed" is optional and will be "0" if duration is defined or if it differs from start time-end time.
# "propagate" is optional and defaults to "0". If set the downtime will be propagated to child hosts of the host specified.
# "register" may be used to deactive the definition ("0"). It will have the same effect as if the definition would not exist.
# "downtime_period" is similar to the definition found in time periods meaning that any of the following should be valid:
#
define icinga::downtime(
  $author,
  $comment,
  $hostname            = undef,
  $hostgroups          = undef,
  $servicegroups       = undef,
  $service_description = undef,
  $duration            = undef,
  $downtime_period     = [],
  $fixed               = undef,
  $propagate           = '1',
  $register            = '1',
) {

  concat::fragment{$name:
    target  => "${::icinga::confdir_server}/downtime.cfg",
    order   => 10,
    content => template('icinga/common/downtime.cfg.erb'),
  }

}
