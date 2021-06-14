#! /bin/bash

yum update -y;
yum install wget tcl  gcc centos-release-scl devtoolset-9-gcc devtooset-g-gcc-c++ devtoolset-9-binutils openssl-devel* -y;
scl enable devtoolset-9 bash
echo "source /opt/rh/devtoolset-9/enable" >> /etc/profile;
useradd --system redis;
mkdir /var/{lib,log}/redis;
chown redis:redis /var/lib/redis;

# mkdir /var/log/redis;
touch /var/log/redis/redis.log;
chmod 660 /var/log/redis;
chmod 640 /var/log/redis/redis.log;
mkdir /etc/redis;
chown -R redis:redis /etc/redis;

mkdir /tmp/redis;
cd /tmp/redis/;
wget http://download.redis.io/releases/redis-6.0.5.tar.gz;
sha256sum redis-6.0.5.tar.gz;
tar -xzvf redis-6.0.5.tar.gz;
cd redis-6.0.5;

# Build redis with tls enabled
make BUILD_TLS=yes install;
make test; 
cp redis.conf /etc/redis/;
chown redis:redis /etc/redis/redis.conf;
echo export PATH='$PATH:/usr/local/bin' >> /etc/profile;
source /etc/profile;

# /usr/local/bin/redis-server /etc/redis/redis.conf # Start the server

# Create a systemd unit for redis
cat > /etc/systemd/system/redis.service <<EOF
[Unit]
Description=The Redis Server
After=network.target

[Service]
PIDFile=/run/redis.pid
ExecStartPre=/usr/bin/rm -f /run/redis.pid
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
Restart=on-failure
RestartUSec=100m
KillSignal=SIGQUIT
StartLimitInterval=0
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Generate self signed certicate
mkdir /tmp/certs;
cd /tmp/certs;
openssl genrsa -out ca.key 4096;
openssl req -x509 -new -nodes -sha256 -key ca.key -days 365 -subj '/O=Redislabs/CN=Redis Prod CA' -out ca.crt;

openssl genrsa -out redis.key 2048;
mkdir /etc/ssl/private;
openssl req -new -sha256 -nodes -key redis.key -subj '/O=Redislabs/CN=Production Redis' | openssl x509 -req -sha256 -CA ca.crt -CAkey ca.key -CAserial /etc/ssl/private/ca.txt -CAcreateserial -days 365 -out redis.crt;
mkdir /usr/local/share/ca-certificates;
cp ca.crt /usr/local/share/ca-certificates/;
cp ca.key redis.key /etc/ssl/private/;
cp redis.crt /etc/ssl/;
chown redis:redis /usr/local/share/ca-certificates/ca.crt;
chmod 644 /usr/local/share/ca-certificates/ca.crt;
chmod 400 /etc/ssl/private/{ca,redis}.key;
chown redis:redis /etc/ssl/private/{ca,redis}.key;
chmod 644 /etc/ssl/redis.crt;
chown redis:redis /etc/ssl/redis.crt;


sed -i '/# port 0/a port 0' /etc/redis/redis.conf;
sed -i 's/^port 6379\>/# port 6379/' /etc/redis/redis.conf;
sed -i '/# tls-port/a tls-port 6379' /etc/redis/redis.conf;
sed -i '/# tls-cert-file /a tls-cert-file /etc/ssl/redis.crt' /etc/redis/redis.conf;
sed -i '/# tls-key-file \/etc\/ssl\/private\/redis.key/a tls-key-file \/etc/ssl\/private\/redis.key' /etc/redis/redis.conf;
sed -i '/# tls-key-file /a tls-key-file \/etc/ssl\/private\/redis.key' /etc/redis/redis.conf;
sed -i '/# tls-ca-cert-file /a tls-ca-cert-file /usr/local/share/ca-certificates/ca.crt' /etc/redis/redis.conf;
sed -i '/# tls-auth-clients no/a tls-auth-clients no' /etc/redis/redis.conf;
# sed -i '/# tls-protocols /a tls-protocols "TLSv1.2 TLSv1.3"' /etc/redis/redis.conf;
sed -i '/tls-protocols /a tls-protocols "TLSv1.2"' /etc/redis/redis.conf;
sed -i '/# tls-ciphersuites /a tls-ciphersuites TLS_CHACHA20_POLY1305_SHA256' /etc/redis/redis.conf;
sed -i '/# tls-prefer-server-ciphers yes/a tls-prefer-server-ciphers no' /etc/redis/redis.conf;
sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf;
sed -i 's/^bind 127.0.0.1\>/# bind 127.0.0.1/' /etc/redis/redis.conf; # Allow redis to accept external connection


# Reload systemd and start redis.service
systemctl daemon-reload;
systemctl enable --now redis.service;
systemctl status redis.service;

# Sample client connection with tls
# redis-cli --tls  --cacert /usr/local/share/ca-certificates/ca.crt
