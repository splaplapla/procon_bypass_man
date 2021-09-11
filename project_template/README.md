# Install Script
これらを展開すれば動くようになる

## Setup
### `bundle exec create_pbm_project`
* カレントディレクトにpbm_projectというディレクトを作成する
* pbm_project/setup.sh でsystemdのunitファイルのsymlinkを貼る
* sudo ln -s /usr/share/pbm/current/systemd_units/pbm.service /etc/systemd/system/pbm.service

## systemd

* systemctl daemon-reload
* systemctl enable pbm.service
* systemctl disable pbm.service
* systemctl start pbm.service
* systemctl status pbm.service
* systemctl restart pbm.service

### ログ
* journalctl -xe -f

