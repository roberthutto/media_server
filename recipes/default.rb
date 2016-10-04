#
# Cookbook Name:: media_server
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
execute 'apt-get-update' do
  command 'apt-get update'
  ignore_failure true
end

include_recipe 'media_server::vnc'