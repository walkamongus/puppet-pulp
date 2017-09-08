require 'spec_helper'

describe 'pulp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        
        it { should contain_exec('reload_systemctl_daemon').with_command('/bin/systemctl daemon-reload') }
        it { should contain_service('pulp_celerybeat').with_ensure('running') }
        it { should contain_service('pulp_resource_manager').with_ensure('running') }
        it { should contain_service('pulp_workers').with_ensure('running') }
        it { should contain_service('pulp_streamer').with_ensure('running') }

        context "pulp::service class with default parameters on #{os}" do
          let(:params) {{ }}

          it { should contain_exec('pulp-manage-db').with_command('pulp-manage-db && touch /var/tmp/pulp-manage-db.init') }
        end
      end
    end
  end
end
