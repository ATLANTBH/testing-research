require 'spec_helper'

describe 'jenkins', :type => :module  do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }

  context 'users' do
    context 'default' do
      it { should contain_class('jenkins::users') }
    end

    context 'with testuser' do
      let(:params) {
        { :user_hash => { 'user' => {
          'email' => 'user@example.com',
          'password' => 'test'
      } } } }
      it { should contain_jenkins__user('user').with_email('user@example.com').with_password('test') }
    end

  end

end
