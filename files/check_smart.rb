#!/usr/bin/ruby

exitStatus = 0
msg = ""
ARGV.each { |x|
  result = `perl /usr/lib64/nagios/plugins/check_smart.pl -d #{x}`
  #puts result
  if $?.exitstatus > 0
    msg = msg + x.sub(' -i', '') + ": " + result +" "
  end
  if $?.exitstatus > exitStatus
     exitStatus = $?.exitstatus
  end
}
if exitStatus == 0
  puts "S.M.A.R.T. OK"
elsif
 puts msg
end
exit exitStatus
