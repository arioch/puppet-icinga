#!/usr/bin/ruby

# This script is only wrapper for the original check written
# in Perl: /usr/lib64/nagios/plugins/check_smart.pl
#
# This script prepares the proper parameters for the Perl script,
# runs this script and collects a output. Then it returns proper
# valus as common NRPE check.
#
#
# This script does not require any input. It autodetects proper
# block devices and runs S.M.A.R.T. checks on them.
#

def raid_controller()

  raid_controller = ''

  # the raid_controller detection is copied over from raid puppet module (lib/facter/raidcontroller.rb)
  #
  # this script supports only "megaraid" controller
  if lspci = `/sbin/lspci`
    lspci.split(/\n/).each do |line|
      raid_controller = "sas2ircu" if line =~ /SAS2008/
      raid_controller = "megaraid" if line =~ /(MegaRAID SAS 1078|MegaSAS 9260|MegaRAID SAS 9240|MegaRAID SAS 2208|MegaRAID SAS 2008|MegaRAID SAS 2108)/
      raid_controller = "3ware" if line =~ /3ware Inc 9690SA/
      raid_controller = "aac-raid" if line =~ /Adaptec AAC-RAID/
      raid_controller = "cciss" if line =~ /Hewlett-Packard Company Smart Array G6 controllers/
      raid_controller = "areca" if line =~ /ARC-1210/
    end
  else
    puts 'UNKNOWN - /sbin/lspci: failed'
    exit 3
  end
  raid_controller
end

def megaraid_check_params()
  if File.exist?('/opt/MegaRAID/MegaCli/MegaCli64')
    device_ids = `/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep -E '^Device Id: [0-9]+'`
  else
    puts "UNKNOWN - /opt/MegaRAID/MegaCli/MegaCli64 not found. You may want to install MegaCli"
    exit 3
  end

  check_params = {}
  device_ids.gsub(/^Device Id: /,'').split("\n").each_with_index do |id, index|
    # it should not matter what device is used for the check, it just has to exist, hence /dev/sda
    check_params.merge!({ index => { 'device' => '/dev/sda', 'interface' => "sat,auto+megaraid,#{id}"}})
  end
  check_params
end

def default_check_params()
  check_params = {}

  if block_devices = `/usr/bin/facter blockdevices`
    block_devices.strip.split(',').each_with_index do |dev,index|
      check_params.merge!({ index => { 'device' => "/dev/#{dev}", 'interface' => 'auto'}})
    end
  else
    puts "UNKNOWN - I cannot get list of devices from facter. Try to run '/usr/bin/facter blockdevices'"
    exit 3
  end
  check_params
end

def do_check(check_params)
  warning = false
  critical = false
  unknown = false
  output = ''
  perf_data = ''
  number_of_devices = 0

  check_params.each do |index, params|
    number_of_devices += 1
    device = params['device']
    interface = params['interface']

    result = `perl /usr/lib64/nagios/plugins/check_smart.pl -d #{device} -i #{interface}`
    exit_status = $?.exitstatus

    output += "#{device} - #{interface}: " + result.split('|')[0] + ";  "
    perf_data += "#{device} - #{interface}: " + result.split('|')[1] + "\n"

    case exit_status
    when 0
      foo = 'bar' # don't do anything
    when 1
      warning = true
    when 2
      critical = true
    else
      unknown = true
    end

  end

  if number_of_devices == 0
    puts 'CRITICAL - no device monitored'
    exit 2
  end

  if critical
    puts output + "|" + perf_data
    exit 2
  end

  if warning
    puts output + "|" + perf_data
    exit 1
  end

  if unknown
    puts output + "|" + perf_data
    exit 3
  end

  puts "S.M.A.R.T. OK on #{number_of_devices} devices |" + perf_data
  exit 0
end



# MAIN

raid_controller = raid_controller()

if raid_controller == "megaraid"
  check_params = megaraid_check_params()
elsif raid_controller == ''
  check_params = default_check_params()
else
  puts "UNKNOWN - Raid controller '#{raid_controller} is not supported by this check"
  exit 3
end

do_check(check_params)
