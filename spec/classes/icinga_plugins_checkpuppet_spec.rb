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
    describe "#{os}, 32bit OS with checkpuppet plugin" do
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
          :plugins => 'checkpuppet',
        }
      }

      it { should contain_file('/usr/lib/nagios/plugins/check_puppet') }
    end

    describe "#{os}, 64bit OS with checkpuppet plugin" do
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
          :plugins => 'checkpuppet',
        }
      }

      it { should contain_file('/usr/lib64/nagios/plugins/check_puppet') }
    end
  end


  ##############################################################################
  #
  # Debian-based distros
  #

  deb_distros.each do |os|
    describe "#{os}, with checkpuppet plugin" do
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
          :plugins => 'checkpuppet',
        }
      }

      it { should contain_file('/usr/lib/nagios/plugins/check_puppet') }
    end
  end


  ##############################################################################
  #
  # All distros
  #

  all_distros.each do |os|
    describe "#{os}, with checkpuppet plugin" do
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
          :plugins => 'checkpuppet',
        }
      }

      it { should create_class('icinga') }
      it { should contain_class('icinga::config::server') }
      it { should contain_class('icinga::plugins::checkpuppet') }
    end
  end
end

