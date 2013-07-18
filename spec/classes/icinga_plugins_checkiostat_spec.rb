require 'spec_helper'

describe 'icinga' do
  let(:pre_condition) { '$concat_basedir = "/tmp"' }
  let(:title) { 'icinga' }
  let(:node)  { 'icinga' }

  rpm_distros = [ 'RedHat', 'CentOS' ]
  deb_distros = [ 'Debian', 'Ubuntu' ]
  all_distros = rpm_distros | deb_distros


  ##############################################################################
  #
  # RedHat-based distros
  #

  rpm_distros.each do |os|
    describe "#{os}, 32bit OS with checkiostat plugin" do
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
          :plugins => 'checkiostat',
        }
      }

      it { should contain_file('/etc/nrpe.d/iostat.cfg') }
      it { should contain_package('nagios-plugins-iostat') }
      it { should_not raise_error(Puppet::ParseError) }
    end

    describe "#{os}, 64bit OS with checkiostat plugin" do
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
          :plugins => 'checkiostat',
        }
      }

      it do
        should contain_file('/etc/nrpe.d/iostat.cfg')
        should contain_package('nagios-plugins-iostat')
        should_not raise_error(Puppet::ParseError)
      end
    end
  end


  ##############################################################################
  #
  # Debian-based distros
  #

  deb_distros.each do |os|
    describe "#{os}, with checkiostat plugin" do
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
          :plugins => 'checkiostat',
        }
      }

      it do
        should contain_file('/etc/nagios/nrpe.d/iostat.cfg')
        should contain_package('nagios-plugin-check-iostat')
        should_not raise_error(Puppet::ParseError)
      end
    end
  end


  ##############################################################################
  #
  # All distros
  #

  all_distros.each do |os|
    describe "#{os}, with checkiostat plugin" do
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
          :plugins => 'checkiostat',
        }
      }

      it do
        should create_class('icinga')
        should include_class('icinga::config::server')
        should include_class('icinga::plugins::checkiostat')

        should_not raise_error(Puppet::ParseError)
      end
    end
  end
end

