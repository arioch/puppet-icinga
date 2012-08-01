# icinga_admins.rb
Facter.add("icinga_admins") do
  setcode do
    %x{test ! -e /etc/icinga/htpasswd.users || cut -d ':' -f 1 /etc/icinga/htpasswd.users | tr '\n' ','}.chomp
  end
end