require 'spec_helper'

describe 'jenkins::user', :type => :define do
  let(:title) { 'foo' }
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'RedHat' }}

  describe 'relationships' do
    let(:params) {{ :email => 'foo@example.org', :password => 'foo' }}
    it do
      should contain_jenkins__user('foo').
        that_requires('Class[jenkins::cli_helper]')
    end
    it do
      should contain_jenkins__user('foo').
        that_comes_before('Anchor[jenkins::end]')
    end
  end
end
