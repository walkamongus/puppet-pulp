require_relative '../../../puppet_x/pulp/api.rb'
require 'pp'

Puppet::Type.type(:pulp_rpm_sync).provide(:api, :parent => Pulp::Api) do
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @needs_update = false
  end

  def self.instances
    response  = get_rpm_repos
    ids       = response.collect { |item| item['id'] }
    schedules = []

    ids.each do |id|
      syncs = get_yum_importer_syncs(id)
      next if syncs.empty?
      syncs.each do |sync|
        schedule = {}
        schedule[:ensure]            = :present
        schedule[:name]              = "#{sync['args'][0]}/#{sync['schedule']}"
        schedule[:repo]              = sync['args'][0]
        schedule[:enabled]           = sync['enabled']
        schedule[:failure_threshold] = sync['failure_threshold']
        schedule[:sync_schedule]     = sync['schedule']
        schedule[:override_config]   = sync['kwargs']['overrides']
        schedule[:id]                = sync['_id']

        # normalize Boolean and String values to Symbols
        schedule.each do |k, v|
          case v when 'true', 'false', true, false then
            schedule[k] = v.to_s.to_sym
          end
        end
        schedules << new(schedule)
      end
    end
    schedules
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    params = {
      :override_config   => @resource[:override_config],
      :schedule          => @resource[:sync_schedule],
      :failure_threshold => @resource[:failure_threshold],
      :enabled           => sym_to_bool(@resource[:enabled])
    }
    request(:post, "/v2/repositories/#{@resource[:repo]}/importers/yum_importer/schedules/sync/", params)
    @property_hash[:ensure] = :present
  end

  def destroy
    request(:delete, "/v2/repositories/#{@property_hash[:name]}/importers/yum_importer/schedules/sync/#{@property_hash[:id]}/")
    @property_hash.clear
  end

  def self.prefetch(resources)
    syncs = instances
    resources.each do |name, params|
      if provider = syncs.find do |sync|
                      sync.repo == params[:repo] and sync.sync_schedule == params[:sync_schedule]
                    end
        resources[name].provider = provider
      end
    end
  end

  [
    :enabled,
    :override_config,
    :sync_schedule,
    :failure_threshold
  ].each do |property|
    define_method(property.to_s + '=') do |value|
      @needs_update = true
    end
  end

  def update
    params = {
      :schedule          => @resource[:sync_schedule],
      :override_config   => @resource[:override_config],
      :failure_threshold => @resource[:failure_threshold],
      :enabled           => sym_to_bool(@resource[:enabled])
    }
    request(:put, "/v2/repositories/#{@property_hash[:repo]}/importers/yum_importer/schedules/sync/#{@property_hash[:id]}/", params)
  end

  def flush
    update if @needs_update
  end
end
