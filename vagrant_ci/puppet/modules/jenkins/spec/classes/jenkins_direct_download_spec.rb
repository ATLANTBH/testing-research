require 'spec_helper'

describe 'jenkins', :type => :module do
  let(:facts) { { :osfamily => 'RedHat', :operatingsystem => 'RedHat' } }
  let(:params) { { :direct_download => 'http://local.space/jenkins.rpm' } }

  describe 'direct_download' do

    context 'default' do
      it { should contain_package('jenkins').with_installed }
      it { should_not contain_class('jenkins::package') }
      it { should contain_class('jenkins::direct_download') }
    end

    context 'with version' do
      let(:params) { { :version => '1.2.3' } }
      it { should contain_package('jenkins').with_ensure('1.2.3') }
    end

    context 'package dir created' do
      it { should contain_file('/var/cache/jenkins_pkgs').with_ensure('directory') }
    end

    context 'staging resource created' do
      it { should contain_staging__file('jenkins.rpm').with_source('http://local.space/jenkins.rpm') }
    end

    context 'package removable' do
      let (:params) { { :version => 'absent', :direct_download => 'http://local.space/jenkins.rpm' } }
      it { should_not contain_staging__file('jenkins.rpm') }
      it { should contain_package('jenkins').with_ensure('absent') }
    end

    context 'unsupported provider fails' do
      let (:params) { { :package_provider => false, :direct_download => 'http://local.space/jenkins.rpm' } }
      it do
        expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /error during compilation/)
      end
    end
  end

end
