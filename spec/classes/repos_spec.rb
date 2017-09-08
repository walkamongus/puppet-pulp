require 'spec_helper'

describe 'pulp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        
        context "pulp::repos class with default parameters on #{os}" do
          let(:params) {{ }}

          it do
            should contain_yumrepo('pulp-2.14-stable').with({
              'ensure'  => 'present',
              'baseurl' => 'https://repos.fedorapeople.org/repos/pulp/pulp/stable/2.14/$releasever/$basearch/'
            })
          end
        end
      end
    end
  end
end
