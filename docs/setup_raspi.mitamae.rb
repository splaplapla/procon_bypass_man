run_command "apt-get update"

package 'rbenv' do
  action :install
end

package 'ruby-build' do
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

# PBM
execute "Initialize PBM" do
  command <<~SHELL
    sudo mkdir -p /usr/share/pbm/shared
    wget https://gist.githubusercontent.com/jiikko/3f9fb3194c0cc7685e31fbfcb5b5f9ff/raw/23ddee29d94350be80b79d290ac3c8ce8400bd88/add_procon_gadget.sh -O /usr/share/pbm/shared/add_procon_gadget.sh
    chmod +x /usr/share/pbm/shared/add_procon_gadget.sh
 SHELL
end

# ruby
execute "Install ruby" do
  not_if "rbenv versions | grep 3.0.1"
  command "rbenv install 3.0.1"
end

run_command 'sudo systemctl disable triggerhappy.socket'
run_command 'sudo systemctl disable triggerhappy.service'
run_command 'sudo systemctl disable bluetooth'
run_command 'sudo systemctl disable apt-daily-upgrade.timer'
run_command 'sudo systemctl disable apt-daily.timer'
