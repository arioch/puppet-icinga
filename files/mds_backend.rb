#!/usr/bin/env ruby

require 'open-uri'
require 'openssl'

lastLine=''
fails=[]
open(ARGV[0], :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).each do |line|
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
