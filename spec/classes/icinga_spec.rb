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
    describe "#{os}, with parameters: /usr/lib path, 32 bit" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux'
        }
      }

      let(:params) {
        { 
          :client => 'true',
        }
      }

      it do
        should contain_file('/usr/lib/nagios/plugins')
        should_not raise_error(Puppet::ParseError)
      end
    end

    describe "#{os}, with parameters: /usr/lib path, 64 bit" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux',
          :architecture    => 'x86_64'
        }
      }

      let(:params) {
        {
          :client => 'true',
        }
      }

      it do
        should contain_file('/usr/lib64/nagios/plugins')
      end
    end
  end


  ##############################################################################
  #
  # Debian-based distros
  #

  deb_distros.each do |os|
    describe "#{os}, with parameters: /usr/lib path" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux'
        }
      }

      let(:params) {
        {
          :client => 'true',
        }
      }

      it do
        should contain_file('/usr/lib/nagios/plugins')
        should_not raise_error(Puppet::ParseError)
      end
    end
  end


  ##############################################################################
  #
  # Both RPM and Debian-based distros
  #

  all_distros.each do |os|
    describe "#{os}, w/o parameters" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux'
        }
      }

      it do
        should create_class('icinga')

        should include_class('icinga::preinstall')
        should include_class('icinga::install')
        should include_class('icinga::config')
        should include_class('icinga::config::client')
        should include_class('icinga::plugins')
        should include_class('icinga::collect')
        should include_class('icinga::service')

        should_not contain_package('icinga').with_ensure('present')
        should_not contain_service('icinga').with_ensure('running')
        should_not contain_service('icinga').with_enable('true')

        should_not raise_error(Puppet::ParseError)
      end
    end
  end
end

