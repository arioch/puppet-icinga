# == Class: icinga::plugins
#
# Full description of class.
#
class icinga::plugins {
  if $icinga::plugins {
    icinga::plugin { $icinga::plugins:; }
  }
}

