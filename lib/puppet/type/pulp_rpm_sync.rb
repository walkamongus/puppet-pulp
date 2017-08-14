Puppet::Type.newtype(:pulp_rpm_sync) do
  @doc = <<-EOT
    doc
  EOT

  ensurable

  newparam(:name) do
    desc ''
  end

  newproperty(:repo, :namevar => true) do
    desc ''
  end

  newproperty(:sync_schedule, :namevar => true) do
    desc ''
  end

  newproperty(:failure_threshold) do
    desc ''
    munge { |value| Integer(value) }
    validate { |value| value =~ /^\d+$/ }
  end

  newproperty(:enabled) do
    desc ''
    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:override_config) do
    desc ''
  end

  def self.title_patterns
    [
      [
        /^((\S+)\/(\S+))$/,
        [
          [ :name ],
          [ :repo ],
          [ :sync_schedule ]
        ]
      ],
      [
        /^((.*))$/,
        [
          [ :name ],
        ]
      ],
    ]
  end
end
