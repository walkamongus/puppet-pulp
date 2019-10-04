require 'spec_helper'

describe 'pulp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        it { should contain_concat('/etc/pulp/server.conf').with_ensure('present') }
        it { should contain_concat__fragment('database_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('server_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('authentication_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('security_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('consumer_history_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('data_reaping_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('ldap_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('oauth_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('messaging_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('tasks_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('email_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('lazy_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_concat__fragment('profiling_settings').with_target('/etc/pulp/server.conf') }
        it { should contain_file('/etc/sysconfig/pulp_workers').with_ensure('file') }
        it { should contain_exec('run_pulp-gen-key-pair').with_command('/bin/pulp-gen-key-pair') }
        it { should contain_exec('run_pulp-gen-ca-certificate').with_command('/bin/pulp-gen-ca-certificate') }

        context "pulp::config class with default parameters on #{os}" do
          let(:params) {{ }}

          it { should contain_file('/etc/pki/pulp/rsa.key').with_ensure('file') }
          it { should contain_file('/etc/pulp/repo_auth.conf').with_ensure('file') }
          it { should contain_file('/etc/pulp/server/plugins.conf.d/yum_importer.json').with_ensure('file') }
          it { should contain_file('/etc/pulp/server/plugins.conf.d/iso_importer.json').with_ensure('file') }

          it { is_expected.to contain_file('/etc/httpd/conf.d/pulp.conf').with_ensure('absent') }
          it { is_expected.to contain_file('/etc/httpd/conf.d/pulp_content.conf').with_ensure('absent') }
        end

        #context "pulp::config class with custom parameters on #{os}" do
        #  let(:params) do
        #    {
	      #    }
        #  end
        #end
      end
    end
  end
end
