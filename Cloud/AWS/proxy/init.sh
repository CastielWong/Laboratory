#!/bin/bash
# output logs can be found on '/var/log/cloud-init-output.log'
DIR_WORK=/home/ubuntu/vol_ss_rust
DIR_HOME=/home/ubuntu

PROXY_PORT=9000
PROXY_ENCRYPT=aes-256-gcm
PROXY_PLUGIN=v2ray-plugin

mkdir -p ${DIR_WORK}

cd ${DIR_WORK}

# install docker
apt-get update
apt install docker.io -y

# add user to the docker group
usermod -a -G docker ubuntu

# set up proxy software
RANDOM_PWD=$(openssl rand -base64 32)

cat > ${DIR_WORK}/config.json <<EOF
{
    "server": "0.0.0.0",
    "server_port": ${PROXY_PORT},
    "password": "${RANDOM_PWD}",
    "timeout": 300,
    "method": "${PROXY_ENCRYPT}",
    "nameserver": "8.8.8.8",
    "mode": "tcp_and_udp",
    "plugin": "${PROXY_PLUGIN}",
    "plugin_opts": "server"
}
EOF

# get the image for shadowsocks from https://hub.docker.com/r/teddysun/shadowsocks-rust
docker pull teddysun/shadowsocks-rust

docker run -d \
    -p ${PROXY_PORT}:${PROXY_PORT} \
    -p ${PROXY_PORT}:${PROXY_PORT}/udp \
    --name ss-rust \
    --restart=always \
    -v ${DIR_WORK}:/etc/shadowsocks-rust \
    teddysun/shadowsocks-rust

cat > ${DIR_HOME}/config_clash.yaml <<EOF
name: "test"
type: ss
server: $(curl ifconfig.me)
port: ${PROXY_PORT}
cipher: ${PROXY_ENCRYPT}
password: ${RANDOM_PWD}
udp: false
plugin: ${PROXY_PLUGIN}
plugin-opts:
  mode: websocket
EOF
