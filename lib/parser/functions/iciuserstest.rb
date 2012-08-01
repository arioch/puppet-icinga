module Puppet::Parser::Functions
  newfunction(:iciuserstest, :type => :rvalue) do
    %x{cut -d ':' -f 1 /etc/icinga/htpasswd.users | tr '\n' ',' | sed -e 's/,$/\n/g'}.chomp
  end
end
