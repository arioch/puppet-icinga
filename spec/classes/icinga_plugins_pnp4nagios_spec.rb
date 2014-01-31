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

      it { should contain_class('icinga::plugins::pnp4nagios') }
      it { should contain_file('/etc/pnp4nagios/apache2-pnp4nagios.conf') }
    end
  end
end

