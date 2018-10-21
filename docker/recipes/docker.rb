#
# Cookbook:: docker
# Recipe:: docker
#
# Copyright:: 2018, The Authors, All Rights Reserved.

docker_service 'default' do
  action [:create, :start]
end


file '/etc/docker/daemon.json' do
  content '{ "insecure-registries" : [ "127.0.0.1:5000","172.28.128.21:5000" ] }'
  mode '0755'
  owner 'vagrant'
  group 'vagrant'
end