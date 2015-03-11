#!/usr/bin/ruby

exitStatus = 0
msg = ['', '']
ARGV.each { |x|
  result = `perl /usr/lib64/nagios/plugins/check_smart.pl -d #{x}`
  if $?.exitstatus > 0
    arr = result.split('|')
    msg[0]= msg[0] + x.sub(' -i', '') + ": " + arr[0] +" "
    msg[1]= msg[1] + x.sub(' -i', '')+": " + arr[1] + " "
  end
  if $?.exitstatus > exitStatus
     exitStatus = $?.exitstatus
  end
}
if exitStatus == 0
  puts "S.M.A.R.T. OK"
elsif
 puts msg[0]+"|"+msg[1]
end
exit exitStatus

