https://github.com/splaplapla/procon_bypass_man/blob/master/docs/setup_raspi_by_mitamae.md に半自動化した手順があります

# Raspberry Pi4のセットアップ手順
* SDカードにRaspberry Pi OS (32 or 64-bit)を焼く
* SDカードをRaspberry Pi4本体に挿して起動する
* ラズパイGUI
  * 無線LANに接続する
  * sshdを許可する
* macからsshする
  * sudo apt-get update
  * sudo apt-get dist-upgrade
  * sudo apt-get install vim rbenv git -y
  * rbenvでrubyを入れる
      * git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
      * rbenv install 3.0.1
      * rbenv local 3.0.1
      * gem i bundler
* ガジェットモードで起動する
  * /boot/config.txtに、dtoverlay=dwc2を追記
  * echo "dwc2" | sudo tee -a /etc/modules
  * echo "libcomposite" | sudo tee -a /etc/modules
  * sudo cat /etc/modules
  * sudo reboot
* cd ~ && mkdir -p src && cd ~/src && git clone https://github.com/jiikko/procon_bypass_man_sample && cd procon_bypass_man_sample

おわりです.  
  
起動する時は下記を確認の上、`sudo /home/pi/.rbenv/versions/3.0.1/bin/ruby app.rb` を実行してください。

* 「ラズパイとSwitch」と「ラズパイとプロコン」を **データ通信可能なケーブル** で接続する
* **Proコントローラーの有線通信** をONにする


![image](https://user-images.githubusercontent.com/1664497/193258615-1da27049-6d1f-4bfc-af1d-2f894f9c610e.png)


## 参考
* https://mtosak-tech.hatenablog.jp/entry/2020/08/22/114622

# TIPS
* SDカードにイメージを焼くときは、ImagerのAdvanced Optionsを使うとセットアップが楽になる
* raspios_liteにした方が起動が早くなりそう
    * https://qiita.com/Liesegang/items/dcdc669f80d1bf721c21
    * http://ftp.jaist.ac.jp/pub/raspberrypi/raspios_lite_armhf
