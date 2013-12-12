require 'spec_helper'

describe "icinga::user" do
  # create user, without password
  # ... which should fail

  let(:node) { 'icinga' }
  let(:facts) { {:operatingsystem => 'Debian', :kernel => 'Linux'} }
  let(:pre_condition) {
    "
      class { 'icinga': server => true, }
      $concat_basedir = '/tmp'
    "
  }

  let(:title) { 'dummyuser1' }
  let(:params) {
    {
      :ensure => 'present'
    }
  }

  it do
    expect {
      should create_icinga__user('dummyuser1')
    }.to raise_error(Puppet::Error)
  end
end

describe "icinga::user" do
  # create user, with password

  let(:node) { 'icinga' }
  let(:facts) { {:operatingsystem => 'Debian', :kernel => 'Linux'} }
  let(:pre_condition) {
    "
      class { 'icinga': server => true, }
      $concat_basedir = '/tmp'
    "
  }

  let(:title) { 'dummyuser2' }
  let(:params) {
    {
      :ensure   => 'present',
      :password => 'default'
    }
  }

  it do
    should create_icinga__user('dummyuser2')
  end
end

