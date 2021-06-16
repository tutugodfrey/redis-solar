#! /bin/bash

# This script should be executed as root
useradd --no-create-home prometheus;
mkdir /etc/prometheus;
mkdir /var/lib/prometheus;

wget https://github.com/prometheus/prometheus/releases/download/v2.19.0/prometheus-2.19.0.linux-amd64.tar.gz
tar xvfz prometheus-2.19.0.linux-amd64.tar.gz

cp prometheus-2.19.0.linux-amd64/{prometheus,promtool} /usr/local/bin;
cp -r prometheus-2.19.0.linux-amd64/{consoles,console_libraries} /etc/prometheus;

chown prometheus:prometheus /etc/prometheus;
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool};
chown -R prometheus:prometheus /etc/prometheus/{consoles,console_libraries};
chown -R prometheus:prometheus /var/lib/prometheus;

cp prometheus.yml /etc/prometheus/;

cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload;
systemctl enable --now prometheus.service

# Configure Node Exporter
useradd --no-create-home node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar xzf node_exporter-1.0.1.linux-amd64.tar.gz
cp node_exporter-1.0.1.linux-amd64/node_exporter /usr/local/bin/node_exporter

cat > /etc/systemd/system/node-exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter Service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now node-exporter

# Configure alert manager
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz
tar xvfz alertmanager-0.21.0.linux-amd64.tar.gz
cp alertmanager-0.21.0.linux-amd64/{alertmanager,amtool} /usr/local/bin
mkdir /var/lib/alertmanager
cp {alertmanager,rules}.yml /etc/prometheus/;
chown -R prometheus:prometheus /etc/prometheus

cat > /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Alert Manager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/prometheus/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload;
systemctl enable alertmanager;
systemctl start alertmanager