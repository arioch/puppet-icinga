#!/usr/bin/env ruby

require 'open-uri'
require 'openssl'

#on several salsa instances it wouldnt run as it fails to verify the certificate,
#therfore i need to disable checking it, and cant think of a better way of doing it with the ancient ruby version currently used(1.8.7).  

original_stderr = $stderr.clone
$stderr.reopen(File.new('/dev/null', 'w'))
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
$stderr.reopen(original_stderr)


lastLine=''
fails=[]
open(ARGV[0]).each do |line|
  if line.match(/^\s+<failure>TRUE<\/failure>\s+$/) and !lastLine.match(/\//)
    fails.push(lastLine.strip[1..-2])
  end
  lastLine=line
end
if fails != []
  puts "Items failing: "+fails.join(", ")
  exit 2
else
  puts "All items OK"
  exit 0
end
