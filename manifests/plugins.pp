class icinga::plugins {
  if $icinga::plugins {
    icinga::plugin { $icinga::plugins:; }
  }
}

