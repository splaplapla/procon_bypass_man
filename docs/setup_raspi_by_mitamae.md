# Raspberry Pi4のセットアップ手順 With mitamae
* SDカードにRaspberry Pi OS lite (32-bit)を焼く
    * sshをできる状態で焼いておく
* SDカードをRaspberry Pi4本体に挿して起動する
* sshする
* curl -L https://github.com/itamae-kitchen/mitamae/releases/latest/download/mitamae-armhf-linux.tar.gz tar xvz
* curl https://raw.githubusercontent.com/splaplapla/procon_bypass_man/master/docs/setup_raspi.mitamae.rb | mitamae-armhf-linux local -l debug
* sudo reboot
* sudo sh ~/add_procon_gadget.sh の実行に成功させる
* /etc/rc.local に sh /usr/share/pbm/shared/add_procon_gadget.sh って書く
* PCとRaspberry Pi4を接続し、プロコンとして認識していることを確認する
* TOOD install pbmenv
