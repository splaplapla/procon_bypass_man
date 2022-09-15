https://github.com/splaplapla/procon_bypass_man/blob/master/docs/setup_raspi_by_mitamae.md に半自動化した手順があります

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
  * sudo apt-get install vim rbenv git -y
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
  * sudo reboot
* cd ~ && mkdir -p src && cd ~/src && git clone https://github.com/jiikko/procon_bypass_man_sample && cd procon_bypass_man_sample

おわり. 起動する時は都度 sudo ruby app.rb を実行する

## 参考
* https://mtosak-tech.hatenablog.jp/entry/2020/08/22/114622

# TIPS
* SDカードにイメージを焼くときは、ImagerのAdvanced Optionsを使うとセットアップが楽になる
* raspios_liteにした方が起動が早くなりそう
    * https://qiita.com/Liesegang/items/dcdc669f80d1bf721c21
    * http://ftp.jaist.ac.jp/pub/raspberrypi/raspios_lite_armhf
