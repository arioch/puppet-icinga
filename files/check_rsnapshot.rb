#!/usr/bin/env ruby
#
# Nagios plugin which checks the previous day daily/weekly/monthly backup 
# status through the rsnapshot log file
#
# Configs::   Install ruby (>= 1.8.7), set rsnapshot logfile (see rsnapshot.conf)
#             as /var/log/rsnapshot.log and make this file executable
#
# Usage::     ./check_rsnapshot
#
# Version::   1.0 (31/01/2011)
#
# Changelog::
#             - 1.0 (31/01/2011)
#               First public release
#
# Author::    Tommaso Visconti  <tommaso.visconti@kreations.it>
# Copyright:: Copyright (c) 2011 Tommaso Visconti <tommaso.visconti@kreations.it>
# License::   GPL v.3
#             This program is free software: you can redistribute it and/or modify
#             it under the terms of the GNU General Public License as published by
#             the Free Software Foundation, either version 3 of the License, or
#             (at your option) any later version.
#            
#             This program is distributed in the hope that it will be useful,
#             but WITHOUT ANY WARRANTY; without even the implied warranty of
#             MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#             GNU General Public License for more details.
#            
#             You should have received a copy of the GNU General Public License
#             along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Extend Time class
def Time.back
    now - 3600*ARGV[2].to_i
end

class BackupChecker
    def initialize
        @@logfile = ARGV[1]
        @@gzlogfile = '/var/log/rsnapshot.log.1.gz'
        @file = File.new(@@logfile, 'r')
        @date = Time.back.strftime("%d/%b/%Y") # Format 01/Jan/2011
        @backups = 0 # N. of backups found
    end
    
    # Extract the interesting lines from log
    def extract_lines
        reg = Regexp.new('^\[' + @date + ':\d\d:\d\d:\d\d\].*\n', Regexp::MULTILINE)
        if File.exists?(@@gzlogfile)
            require 'zlib'
            gzfile = open(@@gzlogfile)
            @gz = Zlib::GzipReader.new(gzfile)
            @gz.read.match(reg).to_s.split("\n")
        end
        @file.read.match(reg).to_s.split("\n")
    end

    
    # The real work
    def parse_lines(lines)
        matches = []
        
        # N. and type of backups found
        started = {}
        started[:num] = 0
        started[:type] = []

        lines.each do |line|
            # weird regexp, but rsnapshot has very different outputs
            if m = line.match('^\[' + @date + ':\d\d:\d\d:\d\d\](\sWARNING:)? /usr/bin/rsnapshot (\w*): (.*)')
                warning = m[1] # Useless
                type = m[2]
                result = m[3]
                if result.strip == 'started'
                    started[:num] += 1
                    started[:type] << type
                else
                    ret = {}
                    ret[:type] = type
                    ret[:result] = result
                    matches << ret
                end
            end
        end
        
        @backups = started[:num]
        
        # The parsed and the started backups should be the same number, but..
        if matches.size != started[:num]
            @@log = matches.to_s
            return false
        end
        
        return matches
    end
    
    # Analyze the output to choose the right output for Nagios
    def analyze_result(type, result)
        ret = {}
        if result.match(/.*ERROR.*completed.*/) or result.match(/.*completed.*warnings.*/)
            ret[:result] = 'Backup WARNING - ' + type + ' backup (' + @date + ') message: "' + result + '"'
            ret[:value] = 1
        elsif result.match(/.*completed successfully.*/)
            ret[:result] = 'Backup OK - ' + type + ' backup (' + @date + ') message: "' + result + '"'
            ret[:value] = 0
        else
            ret[:result] = 'Backup ERROR - ' + type + ' backup (' + @date + ') message: "' + result + '"'
            ret[:value] = 2
        end
        return ret
    end
    
    # Go baby, go!
    def run
        if ret = self.parse_lines(self.extract_lines)
            if @backups == 1
                retval = analyze_result(ret[0][:type], ret[0][:result])
                #puts retval[:result]
                return [retval[:value], retval[:result]]
            else
                final_value = 0
                ret.each do |r|
                    retval = analyze_result(r[:type], r[:result])
                    final_value += retval[:value]
                end
                
                if final_value == 0
                    puts 'Backup OK - Multiple backups OK'
                    return [0,'Backup OK - Multiple backups OK']
                elsif final_value/ret.size == 2
                    puts 'Backup ERROR - Multiple backups ERROR'
                    return [2,'Backup ERROR - Multiple backups ERROR']
                elsif final_value/ret.size == 1
                    puts 'Backup WARNING - Multiple backups WARNING'
                    return [1,'Backup WARNING - Multiple backups WARNING']
                else
                    puts 'Backup WARNING - Multiple backups with different statuses'
                    return [1,'Backup WARNING - Multiple backups with different statuses']
                end
            end
        else
            puts 'Backup UNKNOWN - Backup status unknown: ' + @@log
            return 3
        end
    end
end

##check whether the backups are just being created
if File.file?('/var/run/rsnapshot.pid') or Time.now.hour <= ARGV[2].to_i
  puts "Backups are just being created."
  exit 0
end

backup = BackupChecker.new
stat=backup.run
#puts stat[0]
#puts stat[1]

##now check if backup directories exist
status=0
errors=[]
snapshot_root='/rsnapshot'
File.open(ARGV[0]).each do |line|
  if line.match(/^snapshot_root\t/)
    snapshot_root = line.split("\s")[1]
  end
  if line.match(/^backup\t/)
     #puts line.split("\s")[2]
     folder=snapshot_root+'/daily.0/'+line.split("\s")[2]
     if !File.directory?(folder)
       errors.push(folder)
     end
  end
end
if !errors.empty?
     puts stat[1].to_s+"; Backups not found:"+errors.join(", ")
     status=2
else
     puts stat[1] 
end

#puts [status, stat[0]].max

exit [status, stat[0]].max
