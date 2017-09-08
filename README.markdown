#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with pulp](#setup)
    * [What pulp affects](#what-pulp-affects)
    * [Beginning with pulp](#beginning-with-pulp)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)

## Overview

This module installs and configures the Pulp repository management software.

## Module Description

This module specifically limits itself to the Pulp software and does not try to manage any other components that make up a Pulp server. This is to provide maximum flexibility and minimal scope.

It should be combined with web server, messaging transport, and database module to configure a working Pulp server.

## Setup

### What pulp affects

* Packages
    * pulp-server
    * pulp-selinux
    * python-pulp-streamer
    * python-gofer-(qpid|amqp)
    * pulp-*-plugins packages
    * pulp-admin-client
    * pulp-*-admin-extensions packages
    * pulp-puppet-tools
    * python-pulp-puppet-common
* Files
    * /etc/pulp/admin/admin.conf
    * /etc/pulp/admin/conf.d/puppet.conf
    * /etc/pki/pulp/rsa.key
    * /etc/pulp/repo_auth.conf
    * /etc/pulp/server/plugins.conf.d/ files
    * /etc/sysconfig/pulp_workers
* Services
    * pulp_celerybeat
    * pulp_resource_manager
    * pulp_workers
    * pulp_streamer
* Execs
    * pulp-gen-key-pair
    * pulp-gen-ca-certificate
    * pulp-manage-db
    * reloading systemctl daemon

### Beginning with pulp

You will need a working MongoDB database and your webserver user present before declaring the Pulp module. By default the module will attempt to connect to a database at the default location with the default credentials and run the pulp-manage-db command as the webserver user for database migrations.

    class { '::pulp': }

The pulp-manage-db command can be disabled:

    class { '::pulp':
      exec_pulp_manage_db => false,
    }

## Usage

Install Pulp 2.14 with the RPM plugin enabled, repo managed, OAuth disabled, and webserver user/group management disabled:

      class { '::pulp':
        version                 => '2.14',
        server_default_login    => test,
        server_default_password => testpass,
        oauth_enabled           => false,
        enable_plugins          => ['rpm'],
        manage_http_user        => false,
        manage_http_group       => false,
        manage_repo             => true,
      }

## Reference

### Parameters

All defaults can be found in the data directory files.

  * `version`: Version of Pulp to install and configure.
  * `pulp_packages_ensure`: Ensure value for the Pulp packages.
  * `gofer_package_ensure`: Ensure value for the gofer packages.
  * `enable_plugins`: Array of Pulp plugins to enable.
  * `http_user`: User the webserver runs under.
  * `manage_http_user`: Enable/disable management of the webserver user.
  * `http_group`: Group the webserver runs under.
  * `manage_http_group`: Enable/disable management of the webserver group.
  * `exec_pulp_manage_db`: Enable/Disable execution of the pulp-manage-db command.
  * `manage_repo`: Enable/disable management of the Pulp repo.
  * `repo_proxy`: Proxy used for connecting to the Pulp repo.
  * `proxy_host`: Proxy host for plugin configuration.
  * `proxy_port`: Proxy port for plugin configuration.
  * `proxy_username`: Proxy username for plugin configuration.
  * `proxy_password`: Proxy password for plugin configuration.
  * `number_workers`: Number of workers to set in /etc/sysconfig/pulp_workers.
  * `max_tasks_per_child`: Max tasks per child to set in /etc/sysconfig/pulp_workers.

#### Settings from repo_auth.conf

See https://github.com/pulp/pulp/blob/master/server/etc/pulp/repo_auth.conf

  * `repo_auth`
  * `repo_auth_repo_url_prefixes`
  * `repo_auth_verify_ssl`
  * `repo_auth_disabled_authenticators`
  * `repo_auth_cert_location`
  * `repo_auth_global_cert_location`
  * `repo_auth_protected_repo_listing_file`
  * `repo_auth_crl_location`

#### Settings from server.conf

See https://github.com/pulp/pulp/blob/master/server/etc/pulp/server.conf

##### Database section
  * `database_name`
  * `database_seeds`
  * `database_username`
  * `database_password`
  * `database_replica_set`
  * `database_ssl`
  * `database_ssl_keyfile`
  * `database_ssl_certfile`
  * `database_verify_ssl`
  * `database_ca_path`
  * `database_unsafe_autoretry`
  * `database_write_concern`

##### Server section
  * `server_server_name`
  * `server_key_url`
  * `server_ks_url`
  * `server_default_login`
  * `server_default_password`
  * `server_debugging_mode`
  * `server_log_level`
  * `server_working_directory`

##### Authentication section
  * `authentication_rsa_key`
  * `authentication_rsa_pub`

##### Security section
  * `security_cacert`
  * `security_cakey`
  * `security_ssl_ca_certificate`
  * `security_user_cert_expiration`
  * `security_consumer_cert_expiration`
  * `security_serial_number_path`

##### Consumer History section
  * `consumer_history_lifetime`

##### Data Reaping section
  * `data_reaping_reaper_interval`
  * `data_reaping_archived_calls`
  * `data_reaping_consumer_history`
  * `data_reaping_repo_sync_history`
  * `data_reaping_repo_publish_history`
  * `data_reaping_repo_group_publish_history`
  * `data_reaping_task_status_history`
  * `data_reaping_task_result_history`

##### LDAP section
  * `ldap_enabled`
  * `ldap_uri`
  * `ldap_base`
  * `ldap_tls`
  * `ldap_default_role`
  * `ldap_filter`

##### OAuth section
  * `oauth_enabled`
  * `oauth_oauth_key`
  * `oauth_oauth_secret`

##### Messaging section
  * `messaging_url`
  * `messaging_transport`
  * `messaging_auth_enabled`
  * `messaging_cacert`
  * `messaging_clientcert`
  * `messaging_topic_exchange`
  * `messaging_event_notifications_enabled`
  * `messaging_event_notification_url`

##### Tasks section
  * `tasks_broker_url`
  * `tasks_celery_require_ssl`
  * `tasks_cacert`
  * `tasks_keyfile`
  * `tasks_certfile`
  * `tasks_login_method`

##### Email section
  * `email_enabled`
  * `email_host`
  * `email_port`
  * `email_from`

##### Lazy Redirect section
  * `lazy_redirect_host`
  * `lazy_redirect_port`
  * `lazy_redirect_path`
  * `lazy_https_retrieval`
  * `lazy_download_interval`
  * `lazy_download_concurrency`

##### Profiling section
  * `profiling_enabled`
  * `profiling_directory`

