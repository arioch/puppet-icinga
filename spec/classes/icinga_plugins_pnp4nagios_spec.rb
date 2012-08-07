require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'icinga' do
  let(:title) { 'icinga' }
  let(:node)  { 'icinga' }

  rpm_distros = [ 'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon' ]
  deb_distros = [ 'Debian', 'Ubuntu' ]
  all_distros = rpm_distros | deb_distros


  ##############################################################################
  #
  # RPM-based distros
  #

  rpm_distros.each do |os|
    describe "#{os}, with pnp4nagios plugin" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux'
        }
      }

      let(:params) {
        {
          :client  => 'true',
          :server  => 'true',
          :plugins => 'pnp4nagios',
        }
      }
  
      it do
        should include_class('icinga::plugins::pnp4nagios')
        should contain_file('/etc/pnp4nagios/apache2-pnp4nagios.conf')
        should_not raise_error(Puppet::ParseError)
      end
    end
  end
end

