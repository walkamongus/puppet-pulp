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

          it { is_expected.to contain_exec('pulp-manage-db-transition-to-new-touchfile')
            .with_command('touch /var/lib/pulp/pulp-manage-db.init')
            .with_before('Exec[pulp-manage-db]')
            .with_onlyif('test -f /var/tmp/pulp-manage-db.init')
          }

          it { is_expected.to contain_exec('pulp-manage-db-stop-services')
            .with_command('systemctl stop pulp_*.service')
            .with_before('Exec[pulp-manage-db]')
            .with_unless('grep -q 2.14 /var/lib/pulp/pulp-manage-db.init')
          }

          it { is_expected.to contain_exec('pulp-manage-db')
            .with_command('pulp-manage-db && echo 2.14 > /var/lib/pulp/pulp-manage-db.init')
            .with_before([
              'Service[pulp_celerybeat]',
              'Service[pulp_resource_manager]',
              'Service[pulp_workers]',
              'Service[pulp_streamer]'
            ])
            .with_unless('grep -q 2.14 /var/lib/pulp/pulp-manage-db.init')
          }

          it { is_expected.to contain_exec('reload_systemctl_daemon')
            .with_command('/bin/systemctl daemon-reload')
            .with_refreshonly(true)
            .with_before([
              'Service[pulp_celerybeat]',
              'Service[pulp_resource_manager]',
              'Service[pulp_workers]',
              'Service[pulp_streamer]'
            ])
          }
        end
      end
    end
  end
end
