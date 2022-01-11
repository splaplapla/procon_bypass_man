セットアップ手順を半自動化にしました

# Raspberry Pi4のセットアップ手順 With mitamae
* SDカードにRaspberry Pi OS lite (32-bit)を焼く
    * sshをできる状態で焼いておく
* SDカードをRaspberry Pi4本体に挿して起動する
* sshする
* wget -O - "https://github.com/itamae-kitchen/mitamae/releases/latest/download/mitamae-armhf-linux.tar.gz" | tar xvz
* wget https://raw.githubusercontent.com/splaplapla/procon_bypass_man/master/docs/setup_raspi.mitamae.rb -O setup_raspi.mitamae.rb
* sudo ./mitamae-armhf-linux local setup_raspi.mitamae.rb -l debug
* sudo reboot
* sudo sh /usr/share/pbm/shared/add_procon_gadget.sh の実行に成功させる
* /etc/rc.local に sh /usr/share/pbm/shared/add_procon_gadget.sh って書く
* PCとRaspberry Pi4を接続し、プロコンとして認識していることを確認する
* sudo gem i pbmenv
* sudo pbmenv install latest

## テスト方法
* 使えそうなイメージ
  * navikey/raspbian-bullseye
  * balenalib/raspberry-pi

```shell
docker run -it --rm --name my-running-app2 navikey/raspbian-bullseye bash
```

### 準備
* docker runするとrootなのでpiでログインする

```shell
useradd -m --uid 1000 --groups sudo pi
echo pi:pi | chpasswd
su pi
cd ~ && sudo ls
```

### mitamaeスクリプトを実行する

```
wget -O - "https://github.com/itamae-kitchen/mitamae/releases/latest/download/mitamae-armhf-linux.tar.gz" | tar xvz
wget https://raw.githubusercontent.com/splaplapla/procon_bypass_man/master/docs/setup_raspi.mitamae.rb -O setup_raspi.mitamae.rb
sudo ./mitamae-armhf-linux local setup_raspi.mitamae.rb -l debug
```

実行に成功したら以下を確認する

* /home/pi/.rbenv/verions に ruby3.0.1がインストールしていること
* /etc/modules に指定の文字列があること
* /boot/config.txt に指定の文字列があること
* /usr/share/pbm/shared/add_procon_gadget.sh が存在していること
