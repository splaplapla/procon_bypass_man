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
* sudo sh /usr/share/pbm/shared/add_procon_gadget.sh の実行する
  * 何も表示されなければOK
* PCとRaspberry Pi4を接続し、プロコンとして認識していることを確認する
* sudo gem i pbmenv
* sudo pbmenv install latest

Raspberry Piのセットアップは以上です。  
次は、SwitchとRaspberry Piとプロコンにケーブルを接続した上で、次のコマンドをshellに入力し、procon_bypass_manの動作確認を行なってください。  

```shell
cd /usr/share/pbm/current
sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb
```

次のような出力が画面に表示されれば、動作しています。

```
 ----
 ProconBypassMan::VERSION: 0.2.2
 RUBY_VERSION: 3.0.1
 Pbmenv::VERSION: 0.1.10
 pid: 574
 root: /usr/share/pbm/v0.2.0
 pid_path: /usr/share/pbm/v0.2.0/pbm_pid
 setting_path: /usr/share/pbm/current/setting.yml
 uptime from boot: 60 sec
 use_pbmenv: true
 session_id: s_c6f36422-c20f-4a04-a446-b4a235c2face
 device_id: d_8b0c90d8-90*************************
 bypass_mode: normal(5)
 ----
```

<hr>
  
procon_bypass_manを手動で起動する場合は、先ほどの2行のコマンドを毎回入力してください。  
procon_bypass_manを自動起動する方法については `GETTING STARTED` を参照してください。

<hr>
  

ケーブルの接続方法は、次の写真を参考にしてください。

<img src="https://user-images.githubusercontent.com/1664497/151661582-3a1e8ce9-6c38-4754-8075-7a4453b3109a.jpg" width="500px">

<!--
## 上記手順の動作確認方法
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

-->
