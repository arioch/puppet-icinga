#!/usr/bin/ruby

if !File.exist?('/dev/zimbra/opt-snapshot')
  puts "OK, opt-snapshot doesn't exist"
  exit 0
elsif (Time.now-File.mtime('/dev/zimbra/opt-snapshot'))/3600 < 2
  puts "OK, opt-snapshot is newer than 2h"
  exit 0
elsif (Time.now-File.mtime('/dev/zimbra/opt-snapshot'))/3600 >= 2 and (Time.now-File.mtime('/dev/zimbra/opt-snapshot'))/3600 <= 4
  puts "Warning, opt-snapshot is older than 2h"
  exit 1
elsif (Time.now-File.mtime('/dev/zimbra/opt-snapshot'))/3600 > 4
  puts "Critical, opt-snapshot is older than 4h"
  exit 2
end
