require 'spec_helper'

describe 'pulp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "pulp class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('pulp::repos').that_comes_before('Class[pulp::install]') }
          it { is_expected.to contain_class('pulp::install').that_comes_before('Class[pulp::config]') }
          it { is_expected.to contain_class('pulp::config') }
          it { is_expected.to contain_class('pulp::service').that_subscribes_to('Class[pulp::config]') }
        end
      end
    end
  end
end
