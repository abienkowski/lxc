require 'securerandom'

def load_current_resource
  require 'elecksee/lxc_file_config'
  
  new_resource.utsname new_resource.container if new_resource.container
  new_resource.utsname new_resource.name unless new_resource.utsname

  @lxc = ::Lxc.new(
    new_resource.utsname,
    :base_dir => node[:lxc][:container_directory],
    :dnsmasq_lease_file => node[:lxc][:dnsmasq_lease_file]
  )

  @config = ::Lxc::FileConfig.new(@lxc.container_config)

  new_resource.rootfs @lxc.rootfs.to_path unless new_resource.rootfs
  new_resource.default_bridge node[:lxc][:bridge] unless new_resource.default_bridge
  new_resource.mount @lxc.path.join('fstab').to_path unless new_resource.mount

  new_resource.cgroup(
    Chef::Mixin::DeepMerge.merge(
      Mash.new(
        'devices.deny' => 'a',
        'devices.allow' => [
          'c *:* m',
          'b *:* m',
          'c 1:3 rwm',
          'c 1:5 rwm',
          'c 5:1 rwm',
          'c 5:0 rwm',
          'c 1:9 rwm',
          'c 1:8 rwm',
          'c 136:* rwm',
          'c 5:2 rwm',
          'c 254:0 rwm',
          'c 10:229 rwm',
          'c 10:200 rwm',
          'c 1:7 rwm',
          'c 10:228 rwm',
          'c 10:232 rwm'
        ]
      ),
      new_resource.cgroup
    )
  )
end

action :create do
  _lxc = @lxc
  _config = @config
  
  directory @lxc.path.to_path do
    action :create
  end

  file "lxc update_config[#{new_resource.utsname}]" do
    path _lxc.container_config.to_path
    content _config.generate_content
    mode 0644
  end
end
