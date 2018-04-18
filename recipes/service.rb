# use upstart on ubuntu > saucy
if 'ubuntu' == node['platform']
  if node['platform_version'].to_f >= 16.04
    service_provider = Chef::Provider::Service::Systemd
  else
    service_provider = Chef::Provider::Service::Upstart
  end
end

# this just reloads the dnsmasq rules when the template is adjusted
service 'lxc-net' do
  provider service_provider
  action [:enable, :start]
  subscribes :restart, 'file[/etc/default/lxc]'
  only_if{ node.platform_family?('debian') }
end

service 'lxc' do
  provider service_provider
  action [:enable, :start]
end

service 'lxc-apparmor' do
  service_name 'apparmor'
  action :nothing
end
