#!/bin/bash

#sudo apt-get update
#sudo apt-get install -y htop


ETCD_TAR_FILE=/vagrant/etcd-v3.3.13-linux-amd64.tar.gz

if [ ! -f "$ETCD_TAR_FILE" ]; then 
    wget https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz -O $ETCD_TAR_FILE
fi

sudo tar -xvzf $ETCD_TAR_FILE -C /opt/
sudo mv /opt/etcd-v3.3.13-linux-amd64 /opt/etcd

sudo useradd etcd
sudo groupadd etcd
sudo usermod -a -G etcd etcd

sudo mkdir -p /var/lib/etcd
sudo chown -R etcd:etcd /var/lib/etcd
sudo chmod -R a+rw /var/lib/etcd

sudo ln -sf /opt/etcd/etcd /usr/bin/
sudo ln -sf /opt/etcd/etcdctl /usr/bin/

sudo tee /etc/systemd/system/etcd.service << EOF
[Unit]
Description=etcd key-value store
Documentation=https://github.com/etcd-io/etcd
After=network.target

[Service]
User=etcd
Type=notify
Environment=ETCD_DATA_DIR=/var/lib/etcd
Environment=ETCD_NAME=%m
ExecStart=/usr/bin/etcd
Restart=always
RestartSec=10s
LimitNOFILE=40000

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl enable etcd

sudo apt install nginx -y
sudo tee /etc/nginx/sites-available/etcd << EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name _;

        location / {
                proxy_pass http://localhost:2379;

        }
}
EOF

sudo ln -s /etc/nginx/sites-available/etcd /etc/nginx/sites-enabled/etcd
sudo rm /etc/nginx/sites-enabled/default

reboot
