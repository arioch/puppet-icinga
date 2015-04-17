#!/usr/bin/env ruby

require 'open-uri'
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
