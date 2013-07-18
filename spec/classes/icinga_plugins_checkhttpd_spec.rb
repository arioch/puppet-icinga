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
    describe "#{os}, 32bit OS with checkhttpd plugin" do
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
          :plugins => 'checkhttpd',
        }
      }

      it { should contain_package('nagios-plugins-apache-auto') }
      it { should_not raise_error(Puppet::ParseError) }
    end

    describe "#{os}, 64bit OS with checkhttpd plugin" do
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
          :plugins => 'checkhttpd',
        }
      }

      it { should contain_package('nagios-plugins-apache-auto') }
      it { should_not raise_error(Puppet::ParseError) }
    end
  end


  ##############################################################################
  #
  # Debian-based distros
  #

  deb_distros.each do |os|
    describe "#{os}, with checkhttpd plugin" do
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
          :plugins => 'checkhttpd',
        }
      }

      it { should contain_package('nagios-plugin-check-apache-auto') }
      it { should_not raise_error(Puppet::ParseError) }
    end
  end


  ##############################################################################
  #
  # All distros
  #

  all_distros.each do |os|
    describe "#{os}, with checkhttpd plugin" do
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
          :plugins => 'checkhttpd',
        }
      }

      it { should create_class('icinga') }
      it { should include_class('icinga::config::server') }
      it { should include_class('icinga::plugins::checkhttpd') }

      it { should_not raise_error(Puppet::ParseError) }
    end
  end
end

