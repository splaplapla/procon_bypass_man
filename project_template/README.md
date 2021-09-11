# Project Template
https://github.com/splaplapla/pbmenv で使っているファイルです

## systemd
* sudo ln -s /usr/share/pbm/current/systemd_units/pbm.service /etc/systemd/system/pbm.service
* commnds
  * systemctl daemon-reload
  * systemctl enable pbm.service
  * systemctl disable pbm.service
  * systemctl start pbm.service
  * systemctl status pbm.service
  * systemctl restart pbm.service

### ログ
* journalctl -xe -f

