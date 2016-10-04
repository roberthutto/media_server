# Define variables for attributes
geometry         = node['vnc']['geometry'];
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";
password_file    = "#{account_home}/.vnc/passwd";



# Install desktop
package 'xfce4'

# Install VNC Server
package 'tightvncserver'

# Install browser
package 'firefox'


# Ensure user exists
user "Create user #{account_username} to be used for running VNC and the desktop" do
  action :create
  shell "/bin/bash"
  home "#{account_home}"
  manage_home true
  username "#{account_username}"
end


# Add user to the sudo group.
group "sudo" do
  members "#{account_username}"
  action :modify
  append true
end


# Ensure that the user's .vnc directory exists.
directory "Create user's .vnc directory" do
  user "#{account_username}"
  group "#{account_username}"
  action :create
  recursive true
  path "#{account_home}/.vnc"
end


# Create a vncserver service script.
template "/etc/init.d/vncserver" do
  source "VNCService.erb"
  mode "0775"
  owner "root"
  group "root"
  variables({
                :user_name	=> "#{account_username}",
                :display	=> "1",
                :geometry	=> "#{geometry}",
                :depth	=> "16"
            })
end

# Create the xstartup script
file "#{account_home}/.vnc/xstartup" do
  user "#{account_username}"
  group "#{account_username}"
  action :create
  mode "0755"
  content  "#!/bin/sh
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
startxfce4
"
end

file "#{account_home}/.vnc/passwd" do
  user "#{account_username}"
  group "#{account_username}"
  action :create
  mode "0600"
  content  node['vnc']['passwd']
end

# Enable the VNC server service
# Starting of the service needs to be done manually after the recipe is complete.
#  action [:enable, :start]
service "vncserver" do
  supports :restart => true
  ignore_failure false
  action [:enable,:start]
end

