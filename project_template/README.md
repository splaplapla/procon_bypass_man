# Project Template
* これらは https://github.com/splaplapla/pbmenv がinstallするときに配備するファイルです

## systemdを使ってサービスに登録する方法
systemctl enableした後は、次回のOS起動時にserviceも自動起動します

* pbm
  * sudo systemctl link /usr/share/pbm/current/systemd_units/pbm.service
  * sudo systemctl enable pbm.service

## systemdを使ってサービスから解除する方法
* sudo systemctl disable pbm.service

### CheatSheet
* systemctl daemon-reload
* systemctl enable pbm.service
* systemctl disable pbm.service
* systemctl start pbm.service
* systemctl status pbm.service
* systemctl restart pbm.service
* systemctl list-unit-files --type=service

### デバッグ
* journalctl -xe -f
