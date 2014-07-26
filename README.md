# Wake up hosts
これはWake-on-LANパケットを送信するRubyスクリプトです．あらかじめホスト一覧ファイルを作成しておくことで，キーワードにマッチするホストすべてに対してWake-on-LANパケットを送信できます．
  
```bash
$ ./wake_up_hosts.rb cluster1
Waking up 68:05:ca:xx:xx:00... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:02... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:04... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:06... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:08... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:0a... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:0c... (broadcasting to 192.168.10.255)
Waking up 68:05:ca:xx:xx:0e... (broadcasting to 192.168.10.255)
```

## 設定ファイルの書き方
ホスト一覧ファイルは`~/.wol_hosts`に以下のように記述します．`#`から始まる行はコメント，各行の1つ目にはブロードキャスト先IPアドレスまたはネットワークインタフェース名，2つ目にはMACアドレス，3つ目以降にはキーワードを記述します．1つ目の項目にブロードキャスト先IPを指定した場合はそのIPに向けてWOLパケットが送信されます．ネットワークインタフェース名を指定した場合，`ip`コマンドを使用して対応するブロードキャストIPを自動取得します．

```
# primary hosts
192.168.100.255 68:05:ca:xx:xx:aa www1 www web_service
192.168.100.255 68:05:ca:xx:xx:bb www2 www web_service
192.168.100.255 68:05:ca:xx:xx:cc app1 app web_service
192.168.100.255 68:05:ca:xx:xx:dd app2 app web_service
192.168.100.255 68:05:ca:xx:xx:ee db1 db web_service
192.168.100.255 68:05:ca:xx:xx:ff db2 db web_service

# cluster1
eth1 68:05:ca:xx:xx:00 node01 cluster1
eth1 68:05:ca:xx:xx:02 node02 cluster1
eth1 68:05:ca:xx:xx:04 node03 cluster1
eth1 68:05:ca:xx:xx:06 node04 cluster1
eth1 68:05:ca:xx:xx:08 node05 cluster1
eth1 68:05:ca:xx:xx:0a node06 cluster1
eth1 68:05:ca:xx:xx:0c node07 cluster1
eth1 68:05:ca:xx:xx:0e node08 cluster1
```

## オプション
以下のオプションを指定できます．

オプション | 内容
--- | ---
-c, --config FILENAME | ホスト一覧ファイルを指定する
-d, --dry-run | 実際にはパケットを送信しない
-a, --all | ホスト一覧ファイルに登録されているすべてのホストにWOLパケットを送信する
-l, --list | ホスト一覧ファイルに登録されているホストを表示する
-h, --help | ヘルプを表示する

## 使用例
上で例に出したホスト一覧ファイルが`~/.wol_hosts`に保存されている前提で例示します．

* www1をWOLする場合
```bash
$ ./wake_up_hosts.rb www1
```
* app1とapp2をWOLする場合
```bash
$ ./wake_up_hosts.rb app
```
* www1, www2, db1をWOLする場合
```bash
$ ./wake_up_hosts.rb www db1
```
* cluster1のノードすべてをWOLする場合
```bash
$ ./wake_up_hosts.rb cluster1
```

## ライセンス
MITライセンスです．

