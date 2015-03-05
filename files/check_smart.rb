#!/usr/bin/ruby

exitStatus = 0
msg = ""
ARGV.each { |x|
  result = `perl check_smart.pl -d #{x}`
  #puts result
  if $?.exitstatus > 0
     msg += result + " "
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
