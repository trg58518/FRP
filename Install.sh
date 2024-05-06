#!/bin/bash
rm -rf /usr/frp/
rm -f /etc/systemd/system/frps.service

mkdir /usr/frp
cd /usr/frp

systemctl stop firewalld.service
systemctl disable firewalld.service


while true; do
	default_port=80
	read -p "请输入监听端口：:" input_port
	[ -z "${default_port}" ] && default_port=${input_port}
	if [ "" != "$default_port" ]; then
		break
	fi
	echo -e "[\033[33m错误\033[0m]!"
done

wget -O frps https://github.com/trg58518/FRP/raw/main/Centos/frp/frps
chmod 777 frps

cat >./frps.toml <<EOF
bindPort = ${default_port}
EOF

cat >/etc/systemd/system/frps.service <<EOF
[Unit]
Description=frp_server
After=network.target
[Service]
Type=simple
ExecStart=/usr/frp/frps -c /usr/frp/frps.toml
Restart=always
RestartSec=10
AmbientCapabilities=CAP_NET_BIND_SERVICE
[Install]
WantedBy=multi-user.target
EOF

chmod 777 /etc/systemd/system/frps.service
systemctl daemon-reload
systemctl enable frps.service

