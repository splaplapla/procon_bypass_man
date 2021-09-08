# Raspberry Pi4のセットアップ手順
* SDカードにRaspberry Pi OS (32-bit)を焼く
* SDカードをRaspberry Pi4本体に挿して起動する
* ラズパイGUI
  * 無線LANに接続する
  * sshdを許可する
* macからsshする
  * sudo apt-get dist-upgrade
  * hostnameを変える
      * sudo hostnamectl set-hostname raspizero
      * /etc/hosts に追記する
  * 仮想メモリを増やす(optional)
      * /etc/dphys-swapfile を CONF_SWAPSIZE=1024 にする
      * sudo /etc/init.d/dphys-swapfile restart && swapon -s
  * tailscale をインストールする(optional)
  * sudo apt-get install vim rbenv
  * rbenvでrubyを入れる
      * git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
      * rbenv install 3.0.1
      * rbenv local 3.0.1
      * gem i bundler
* sshkeyを作成する
* github に鍵を登録する
* ~/.ssh/authorized_keys に鍵を登録する
* ガジェットモードで起動する
  * /boot/config.txtに、dtoverlay=dwc2を追記
  * echo "dwc2" | sudo tee -a /etc/modules
  * echo "libcomposite" | sudo tee -a /etc/modules
  * sudo cat /etc/modules
  * cd ~ && wget https://gist.githubusercontent.com/jiikko/3f9fb3194c0cc7685e31fbfcb5b5f9ff/raw/23ddee29d94350be80b79d290ac3c8ce8400bd88/add_procon_gadget.sh
  * chmod 755 ~/add_procon_gadget.sh
  * sudo reboot
  * sudo sh ~/add_procon_gadget.sh の実行に成功させる
  *  /etc/rc.local に sh /home/pi/add_procon_gadget.sh って書く
* cd ~ && mkdir -p src && cd ~/src && git clone https://github.com/jiikko/procon_bypass_man_sample && cd procon_bypass_man && sudo bundle install

おわり. 起動する時は都度 sudo ruby app.rb を実行する

## 参考
* https://mtosak-tech.hatenablog.jp/entry/2020/08/22/114622
