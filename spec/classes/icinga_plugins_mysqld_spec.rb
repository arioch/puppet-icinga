require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'icinga' do
  let(:title) { 'icinga' }
  let(:node)  { 'icinga' }

  rpm_distros = [ 'RedHat', 'CentOS', 'Scientific', 'OEL', 'Amazon' ]
  deb_distros = [ 'Debian', 'Ubuntu' ]
  all_distros = rpm_distros | deb_distros


  ##############################################################################
  #
  # RedHat-based distros
  #

  rpm_distros.each do |os|
    describe "#{os}, 32bit OS with checkmysqld plugin" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux',
          :architecture    => 'i686'
        }
      }

      let(:params) {
        {
          :client  => 'true',
          :server  => 'true',
          :plugins => 'checkmysqld',
        }
      }
  
      it do
        should contain_file('/etc/nrpe.d/mysqld_performance.cfg')
        should contain_package('nagios-plugins-mysqld')
        should_not raise_error(Puppet::ParseError)
      end
    end

    describe "#{os}, 64bit OS with checkmysqld plugin" do
      let(:facts) {
        {
          :operatingsystem => os,
          :kernel          => 'Linux',
          :architecture    => 'x86_64'
        }
      }

      let(:params) {
        {
          :client  => 'true',
          :server  => 'true',
          :plugins => 'checkmysqld',
        }
      }
  
      it do
        should contain_file('/etc/nrpe.d/mysqld_performance.cfg')
        should contain_package('nagios-plugins-mysqld')
        should_not raise_error(Puppet::ParseError)
      end
    end
  end


  ##############################################################################
  #
  # Debian-based distros
  #

  deb_distros.each do |os|
    describe "#{os}, with checkmysqld plugin" do
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
          :plugins => 'checkmysqld',
        }
      }
  
      it do
        should contain_file('/etc/nagios/nrpe.d/mysqld_performance.cfg')
        should contain_package('nagios-plugin-check-mysqld')
        should_not raise_error(Puppet::ParseError)
      end
    end
  end


  ##############################################################################
  #
  # All distros
  #

  all_distros.each do |os|
    describe "#{os}, with checkmysqld plugin" do
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
          :plugins => 'checkmysqld',
        }
      }
  
      it do
        should create_class('icinga')
        should include_class('icinga::config::server')
        should include_class('icinga::plugins::checkmysqld')

        should_not raise_error(Puppet::ParseError)
      end
    end
  end
end

