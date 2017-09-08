require 'spec_helper'

describe 'pulp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "pulp::install class with default parameters on #{os}" do
          let(:params) {{ }}

          ['pulp-server', 'pulp-selinux', 'python-pulp-streamer'].each do |pkg|
            it { should contain_package(pkg).with_ensure('present') }
          end

          it { should contain_package('python-gofer-qpid').with_ensure('present') }
          it { should contain_package('pulp-rpm-plugins').with_ensure('present') }
          it { should contain_user('apache').with_ensure('present') }
          it { should contain_group('apache').with_ensure('present') }
        end

        #context "pulp::install class with custom parameters on #{os}" do
        #  let(:params) do
        #    {
	      #    }
        #  end
        #end
      end
    end
  end
end
