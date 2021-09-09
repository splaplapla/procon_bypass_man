# Install Script
これらを展開すれば動くようになる

## Setup

## systemd

```shell
sudo ln -s /home/pi/src/procon_bypass_man_sample/systemd_units/pbm.service /etc/systemd/system/pbm.service
sudo systemctl enable pbm.service
```

他の操作

* systemctl daemon-reload
* systemctl enable pbm.service
* systemctl disable pbm.service
* systemctl start pbm.service
* systemctl status pbm.service
* systemctl restart pbm.service

### ログ
* journalctl -xe -f

