# Project Template
これらは https://github.com/splaplapla/pbmenv がinstallするときに配備するファイルです

## systemdを使ってサービスに登録する方法
* sudo ln -s /usr/share/pbm/current/systemd_units/pbm.service /etc/systemd/system/pbm.service
* sudo ln -s /usr/share/pbm/current/systemd_units/pbm_web.service /etc/systemd/system/pbm_web.service
* sudo systemctl enable pbm.service
* sudo systemctl enable pbm_web.service

## systemdを使ってサービスから解除する方法
* sudo systemctl disable pbm.service
* sudo systemctl disable pbm_web.service

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
