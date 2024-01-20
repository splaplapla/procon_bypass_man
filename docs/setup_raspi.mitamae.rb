run_command "apt-get update"

package 'rbenv' do
  action :install
end

package 'vim' do
  action :install
end

package 'git' do
  action :install
end

gem_package 'bundler' do
  action :install
end

# OTG
execute "append dtoverlay=dwc2 to /boot/config.txt" do
  not_if "grep dtoverlay=dwc2 /boot/config.txt"
  command "echo 'dtoverlay=dwc2' >> /boot/config.txt"
end

execute "append dwc2 to /etc/modules" do
  not_if "grep dwc2 /etc/modules"
  command "echo dwc2 >> /etc/modules"
end

execute "append libcomposite to /etc/modules" do
  not_if "grep libcomposite /etc/modules"
  command "echo libcomposite >> /etc/modules"
end

# ruby
execute "Install ruby" do
  user "pi"
  not_if "rbenv versions | grep 3.0.1"
  command <<~EOH
    mkdir -p "$(rbenv root)"/plugins
    git clone https://github.com/rbenv/ruby-build.git --depth 1 "$(rbenv root)"/plugins/ruby-build
    rbenv install 3.0.1
  EOH
end

run_command 'sudo systemctl disable triggerhappy.socket'
run_command 'sudo systemctl disable triggerhappy.service'
run_command 'sudo systemctl disable bluetooth'
run_command 'sudo systemctl disable apt-daily-upgrade.timer'
run_command 'sudo systemctl disable apt-daily.timer'
