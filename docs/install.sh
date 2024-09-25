rm -rf xray
clear
NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
secs_to_human() {
echo -e "${WB}Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds${NC}"
}
start=$(date +%s)
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt install socat netfilter-persistent -y
apt install vnstat lsof fail2ban -y
apt install curl sudo -y
apt install screen cron screenfetch -y
mkdir /user >> /dev/null 2>&1
mkdir /tmp >> /dev/null 2>&1
apt install resolvconf network-manager dnsutils bind9 -y
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=8.8.8.8 8.8.4.4
Domains=~.
ReadEtcHosts=yes
END
systemctl enable resolvconf
systemctl enable systemd-resolved
systemctl enable NetworkManager
rm -rf /etc/resolv.conf
rm -rf /etc/resolvconf/resolv.conf.d/head
echo "
nameserver 127.0.0.53
" >> /etc/resolv.conf
echo "
" >> /etc/resolvconf/resolv.conf.d/head
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Google DNS" > /user/current
rm /usr/local/etc/xray/city >> /dev/null 2>&1
rm /usr/local/etc/xray/org >> /dev/null 2>&1
rm /usr/local/etc/xray/timezone >> /dev/null 2>&1
bash -c "$(curl -L https://raw.githubusercontent.com/hostinger-bot/autoscript/main/xray/installer.sh)" - install --beta
curl -s ipinfo.io/city >> /usr/local/etc/xray/city
curl -s ipinfo.io/org | cut -d " " -f 2-10 >> /usr/local/etc/xray/org
curl -s ipinfo.io/timezone >> /usr/local/etc/xray/timezone
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
clear
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install nginx -y
rm -rf /var/www/html/* >> /dev/null 2>&1
rm /etc/nginx/sites-enabled/default >> /dev/null 2>&1
rm /etc/nginx/sites-available/default >> /dev/null 2>&1
mkdir -p /var/www/html/vmess >> /dev/null 2>&1
mkdir -p /var/www/html/vless >> /dev/null 2>&1
mkdir -p /var/www/html/trojan >> /dev/null 2>&1
mkdir -p /var/www/html/ss >> /dev/null 2>&1
mkdir -p /var/www/html/ss2022 >> /dev/null 2>&1
mkdir -p /var/www/html/allxray >> /dev/null 2>&1
systemctl restart nginx
clear
touch /usr/local/etc/xray/domain
echo -e "${YB}Input Domain${NC} "
echo " "
read -rp "Enter your domain : " -e dns
if [ -z $dns ]; then
echo -e "Nothing input for domain!"
else
echo "$dns" > /usr/local/etc/xray/domain
echo "DNS=$dns" > /var/lib/dnsvps.conf
fi
clear
systemctl stop nginx
systemctl stop xray
domain=$(cat /usr/local/etc/xray/domain)
curl https://get.acme.sh | sh
source ~/.bashrc
cd .acme.sh
bash acme.sh --issue -d $domain --server letsencrypt --keylength ec-256 --fullchain-file /usr/local/etc/xray/fullchain.crt --key-file /usr/local/etc/xray/private.key --standalone --force
chmod 745 /usr/local/etc/xray/private.key
clear
echo -e "${GB}[ INFO ]${NC} ${YB}Setup Nginx & Xray Conf${NC}"
cipher="aes-128-gcm"
cipher2="2022-blake3-aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
pwtr=$(openssl rand -hex 4)
pwss=$(echo $RANDOM | md5sum | head -c 6; echo;)
userpsk=$(openssl rand -base64 16)
serverpsk=$(openssl rand -base64 16)
echo "$serverpsk" > /usr/local/etc/xray/serverpsk
cat > /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "api": {
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ],
    "tag": "api"
  },
  "stats": {},
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "dns": {
     "servers": [
        "https://1.1.1.1/dns-query"
        ],
        "queryStrategy": "UseIP"
  },
  "routing": {
     "domainStrategy": "IPIfNonMatch",
     "rules": [
        {
           "type": "field",
           "domain": [
              "geosite:openai",
              "geosite:google",
              "geosite:youtube",
              "geosite:netflix",
              "geosite:spotify",
              "geosite:zoom",
              "geosite:facebook",
              "geosite:cloudflare"
              ],
              "outboundTag": "WARP"
        }
      ]
   },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
# XTLS
    {
      "listen": "::",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "flow": "xtls-rprx-vision",
            "id": "$uuid"
#vless-xtls
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "alpn": "h2",
            "dest": 2323,
            "xver": 2
          },
          {
            "dest": 800,
            "xver": 2
          },
          {
            "path": "/vless",
            "dest": "@vless-ws",
            "xver": 2
          },
          {
            "path": "/vmess",
            "dest": "@vmess-ws",
            "xver": 2
          },
          {
            "path": "/trojan",
            "dest": "@trojan-ws",
            "xver": 2
          },
          {
            "path": "/ss",
            "dest": "100",
            "xver": 2
          },
          {
            "path": "/ss2022",
            "dest": "110",
            "xver": 2
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "ocspStapling": 3600,
              "certificateFile": "/usr/local/etc/xray/fullchain.crt",
              "keyFile": "/usr/local/etc/xray/private.key"
            }
          ],
          "minVersion": "1.2",
          "cipherSuites": "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256:TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256:TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384:TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384:TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256:TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
          "alpn": [
            "h2",
            "http/1.1"
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# TROJAN TCP TLS
    {
      "port": 2323,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$pwtr",
            "level": 0
#trojan-tcp
          }
        ],
        "fallbacks": [
          {
            "dest": "844",
            "xver": 2
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "acceptProxyProtocol": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# VLESS WS
    {
      "listen": "@vless-ws",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "email":"general@vless-ws",
            "id": "$uuid"
#vless

          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vless"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# VMESS WS
    {
      "listen": "@vmess-ws",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "email": "general@vmess-ws", 
            "id": "$uuid",
            "level": 0
#vmess
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vmess"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# TROJAN WS
    {
      "listen": "@trojan-ws",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$pwtr",
            "level": 0
#trojan
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/trojan"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# SS WS
    {
      "listen": "127.0.0.1",
      "port": "100",
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
            {
              "method": "aes-128-gcm",
              "password": "$pwss"
#ss
            }
          ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/ss"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# SS2022 WS
    {
      "listen": "127.0.0.1",
      "port": "110",
      "protocol": "shadowsocks",
      "settings": {
        "method": "2022-blake3-aes-128-gcm",
        "password": "$(cat /usr/local/etc/xray/serverpsk)",
        "clients": [
          {
            "password": "$userpsk"
#ss2022
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/ss2022"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# VLESS GRPC
    {
      "listen": "127.0.0.1",
      "port": 11000,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "email":"general@vless-grpc",
            "id": "$uuid"
#vless-grpc

          }
        ],
        "decryption": "none"
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vless-grpc"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# VMESS GRPC
    {
      "listen": "127.0.0.1",
      "port": 12000,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "email": "general@vmess-grpc", 
            "id": "$uuid",
            "level": 0
#vmess-grpc
          }
        ]
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vmess-grpc"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# TROJAN GRPC
    {
      "listen": "127.0.0.1",
      "port": 13000,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$pwtr",
            "level": 0
#trojan-grpc
          }
        ]
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "trojan-grpc"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# SS GRPC
    {
      "listen": "127.0.0.1",
      "port": 14000,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
            {
              "method": "aes-128-gcm",
              "password": "$pwss"
#ss-grpc
            }
          ],
        "network": "tcp,udp"
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "ss-grpc"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# SS2022 GRPC
    {
      "listen": "127.0.0.1",
      "port": 15000,
      "protocol": "shadowsocks",
      "settings": {
        "method": "2022-blake3-aes-128-gcm",
        "password": "$(cat /usr/local/etc/xray/serverpsk)",
        "clients": [
          {
            "password": "$userpsk"
#ss2022-grpc
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings":{
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "ss2022-grpc"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$uuid"
#universal
          }
        ],
        "fallbacks": [
          {
            "dest": 800,
            "xver": 2
          },
          {
            "dest": 200,
            "xver": 2
          },
          {
            "dest": 210,
            "xver": 2
          },
          {
            "path": "/vless",
            "dest": "@vless-ws",
            "xver": 2
          },
          {
            "path": "/vmess",
            "dest": "@vmess-ws",
            "xver": 2
          },
          {
            "path": "/trojan",
            "dest": "@trojan",
            "xver": 2
          }
        ],
        "decryption": "none"
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# TROJAN WS
    {
      "listen": "@trojan",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$pwtr",
            "level": 0
#trojan
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/trojan"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
# SS WS
    {
      "listen": "127.0.0.1",
      "port": "200",
      "protocol": "shadowsocks",
      "settings": {
        "clients": [
            {
              "method": "aes-128-gcm",
              "password": "$pwss"
#ss
            }
          ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/ss"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "210",
      "protocol": "shadowsocks",
      "settings": {
        "method": "2022-blake3-aes-128-gcm",
        "password": "$(cat /usr/local/etc/xray/serverpsk)",
        "clients": [
          {
            "password": "$userpsk"
#ss2022
          }
        ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/ss2022"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
       "protocol": "freedom",
       "settings": {
          "domainStrategy": "UseIP"
       },
       "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "blocked"
    },
    {
       "protocol": "wireguard",
       "settings": {
          "secretKey": "yD2iamc8Px/vzQh5eXSJP1XG2CTJl+nK+Qf5enmfbFA=",
          "address": [
             "172.16.0.2/32",
             "2606:4700:110:86b8:2bfb:c840:6743:98b2/128"
             ],
             "peers": [
                {
                   "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                   "allowedIPs": [
                      "0.0.0.0/0",
                      "::/0"
                      ],
                      "endpoint": "162.159.192.11:7281"
                }
              ],
              "reserved":[148, 253, 57],
              "mtu": 1280,
              "domainStrategy": "ForceIPv4v6"
       },
       "tag": "WARP"
    }
  ]
}
END
cat > /etc/nginx/nginx.conf << END
# Generated by nginxconfig.io
user www-data;
pid /run/nginx.pid;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
   multi_accept on;
   worker_connections 65535;
}

http {
   charset utf-8;
   sendfile on;
   tcp_nopush on;
   tcp_nodelay on;
   server_tokens off;
   types_hash_max_size 2048;
   server_names_hash_bucket_size 128;
   server_names_hash_max_size 512;
   client_max_body_size 16M;

   # MIME
   include mime.types;
   default_type application/octet-stream;

   # logging
   access_log /var/log/nginx/access.log;
   error_log /var/log/nginx/error.log warn;

   # Compression
   gzip on;
   gzip_comp_level 5;
   gzip_min_length 256;
   gzip_proxied any;
   gzip_types application/javascript application/json application/xml text/css text/plain text/xml application/xml+rss;

   include /etc/nginx/conf.d/*.conf;
   include /etc/nginx/sites-enabled/*;

   server {
       listen 800 proxy_protocol default_server;
       listen 844 http2 proxy_protocol default_server;
       set_real_ip_from 127.0.0.1;
       real_ip_header proxy_protocol;
       server_name _;
       return 400;
   }
   server {
       listen 844 http2;
       set_real_ip_from 127.0.0.1;
       real_ip_header proxy_protocol;
       server_name $domain;

       # Web Content
       location / {
         root /var/www/html;
       }

       # gRPC Reverse Proxy
       location /vmess-grpc {
         grpc_pass grpc://127.0.0.1:11000;
         include /etc/nginx/conf.d/grpc.conf;
       }
       location /vless-grpc {
         grpc_pass grpc://127.0.0.1:12000;
         include /etc/nginx/conf.d/grpc.conf;
       }
       location /trojan-grpc {
         grpc_pass grpc://127.0.0.1:13000;
         include /etc/nginx/conf.d/grpc.conf;
       }
       location /ss-grpc {
         grpc_pass grpc://127.0.0.1:14000;
         include /etc/nginx/conf.d/grpc.conf;
       }
       location /ss2022-grpc {
         grpc_pass grpc://127.0.0.1:15000;
         include /etc/nginx/conf.d/grpc.conf;
       }
   }
}
END
wget -q -O /etc/nginx/conf.d/grpc.conf https://raw.githubusercontent.com/hostinger-bot/autoscript/main/config/grpc.conf

# wget -q -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/hostinger-bot/autoscript/main/config/nginx.conf
# sudo sed -i -e 's/example.com/${domain}/g' /etc/nginx/conf.d/xray.conf
systemctl restart nginx
systemctl restart xray
echo -e "${GB}[ INFO ]${NC} ${YB}Setup Done${NC}"
sleep 1
clear
# Blokir lalu lintas torrent (BitTorrent)
sudo iptables -A INPUT -p udp --dport 6881:6889 -j DROP
sudo iptables -A INPUT -p tcp --dport 6881:6889 -j DROP
# Blokir lalu lintas torrent dengan modul string
sudo iptables -A INPUT -p tcp --dport 6881:6889 -m string --algo bm --string "BitTorrent" -j DROP
sudo iptables -A INPUT -p udp --dport 6881:6889 -m string --algo bm --string "BitTorrent" -j DROP
cd /usr/bin
GITHUB=raw.githubusercontent.com/hostinger-bot/autoscript/main
echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Main Menu${NC}"
wget -q -O menu "https://${GITHUB}/menu/menu.sh"
wget -q -O vmess "https://${GITHUB}/menu/vmess.sh"
wget -q -O vless "https://${GITHUB}/menu/vless.sh"
wget -q -O trojan "https://${GITHUB}/menu/trojan.sh"
wget -q -O shadowsocks "https://${GITHUB}/menu/shadowsocks.sh"
wget -q -O ss2022 "https://${GITHUB}/menu/ss2022.sh"
wget -q -O allxray "https://${GITHUB}/menu/allxray.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vmess${NC}"
wget -q -O add-vmess "https://${GITHUB}/vmess/add-vmess.sh"
wget -q -O del-vmess "https://${GITHUB}/vmess/del-vmess.sh"
wget -q -O extend-vmess "https://${GITHUB}/vmess/extend-vmess.sh"
wget -q -O trialvmess "https://${GITHUB}/vmess/trialvmess.sh"
wget -q -O cek-vmess "https://${GITHUB}/vmess/cek-vmess.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Vless${NC}"
wget -q -O add-vless "https://${GITHUB}/vless/add-vless.sh"
wget -q -O del-vless "https://${GITHUB}/vless/del-vless.sh"
wget -q -O extend-vless "https://${GITHUB}/vless/extend-vless.sh"
wget -q -O trialvless "https://${GITHUB}/vless/trialvless.sh"
wget -q -O cek-vless "https://${GITHUB}/vless/cek-vless.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Trojan${NC}"
wget -q -O add-trojan "https://${GITHUB}/trojan/add-trojan.sh"
wget -q -O del-trojan "https://${GITHUB}/trojan/del-trojan.sh"
wget -q -O extend-trojan "https://${GITHUB}/trojan/extend-trojan.sh"
wget -q -O trialtrojan "https://${GITHUB}/trojan/trialtrojan.sh"
wget -q -O cek-trojan "https://${GITHUB}/trojan/cek-trojan.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Shadowsocks${NC}"
wget -q -O add-ss "https://${GITHUB}/ss/add-ss.sh"
wget -q -O del-ss "https://${GITHUB}/ss/del-ss.sh"
wget -q -O extend-ss "https://${GITHUB}/ss/extend-ss.sh"
wget -q -O trialss "https://${GITHUB}/ss/trialss.sh"
wget -q -O cek-ss "https://${GITHUB}/ss/cek-ss.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Shadowsocks 2022${NC}"
wget -q -O add-ss2022 "https://${GITHUB}/ss2022/add-ss2022.sh"
wget -q -O del-ss2022 "https://${GITHUB}/ss2022/del-ss2022.sh"
wget -q -O extend-ss2022 "https://${GITHUB}/ss2022/extend-ss2022.sh"
wget -q -O trialss2022 "https://${GITHUB}/ss2022/trialss2022.sh"
wget -q -O cek-ss2022 "https://${GITHUB}/ss2022/cek-ss2022.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu All Xray${NC}"
wget -q -O add-xray "https://${GITHUB}/allxray/add-xray.sh"
wget -q -O del-xray "https://${GITHUB}/allxray/del-xray.sh"
wget -q -O extend-xray "https://${GITHUB}/allxray/extend-xray.sh"
wget -q -O trialxray "https://${GITHUB}/allxray/trialxray.sh"
wget -q -O cek-xray "https://${GITHUB}/allxray/cek-xray.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Menu Log${NC}"
wget -q -O log-create "https://${GITHUB}/log/log-create.sh"
wget -q -O log-vmess "https://${GITHUB}/log/log-vmess.sh"
wget -q -O log-vless "https://${GITHUB}/log/log-vless.sh"
wget -q -O log-trojan "https://${GITHUB}/log/log-trojan.sh"
wget -q -O log-ss "https://${GITHUB}/log/log-ss.sh"
wget -q -O log-ss2022 "https://${GITHUB}/log/log-ss2022.sh"
wget -q -O log-allxray "https://${GITHUB}/log/log-allxray.sh"
sleep 0.5

echo -e "${GB}[ INFO ]${NC} ${YB}Downloading Other Menu${NC}"
wget -q -O xp "https://${GITHUB}/other/xp.sh"
wget -q -O dns "https://${GITHUB}/other/dns.sh"
wget -q -O certxray "https://${GITHUB}/other/certxray.sh"
wget -q -O about "https://${GITHUB}/other/about.sh"
wget -q -O clear-log "https://${GITHUB}/other/clear-log.sh"
wget -q -O changer "https://${GITHUB}/other/changer.sh"
echo -e "${GB}[ INFO ]${NC} ${YB}Download All Menu Done${NC}"
sleep 2
chmod +x add-vmess
chmod +x del-vmess
chmod +x extend-vmess
chmod +x trialvmess
chmod +x cek-vmess

chmod +x add-vless
chmod +x del-vless
chmod +x extend-vless
chmod +x trialvless
chmod +x cek-vless

chmod +x add-trojan
chmod +x del-trojan
chmod +x extend-trojan
chmod +x trialtrojan
chmod +x cek-trojan

chmod +x add-ss
chmod +x del-ss
chmod +x extend-ss
chmod +x trialss
chmod +x cek-ss

chmod +x add-ss2022
chmod +x del-ss2022
chmod +x extend-ss2022
chmod +x trialss2022
chmod +x cek-ss2022

chmod +x add-xray
chmod +x del-xray
chmod +x extend-xray
chmod +x trialxray
chmod +x cek-xray

chmod +x log-create
chmod +x log-vmess
chmod +x log-vless
chmod +x log-trojan
chmod +x log-ss
chmod +x log-ss2022
chmod +x log-allxray

chmod +x menu
chmod +x vmess
chmod +x vless
chmod +x trojan
chmod +x shadowsocks
chmod +x ss2022
chmod +x allxray

chmod +x xp
chmod +x dns
chmod +x certxray
chmod +x about
chmod +x clear-log
chmod +x changer
cd
echo "0 0 * * * root xp" >> /etc/crontab
echo "*/3 * * * * root clear-log" >> /etc/crontab
systemctl restart cron
cat > /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
clear
echo ""
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}XRAY${NC}"
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
echo -e "                 ${WB}»»» Protocol Service «««${NC}  "
echo -e "${BB}—————————————————————————————————————————————————————————${NC}"
echo -e "  ${YB}- Vmess WS CDN TLS${NC}            : ${YB}443${NC}"
echo -e "  ${YB}- Vmess WS CDN${NC}                : ${YB}80${NC}"
echo -e "  ${YB}- Vmess gRPC${NC}                  : ${YB}443${NC}"
echo -e "  ${YB}- Vless XTLS Vision${NC}           : ${YB}443${NC}"
echo -e "  ${YB}- Vless WS CDN TLS${NC}            : ${YB}443${NC}"
echo -e "  ${YB}- Vless WS CDN${NC}                : ${YB}80${NC}"
echo -e "  ${YB}- Vless gRPC${NC}                  : ${YB}443${NC}"
echo -e "  ${YB}- Trojan TCP${NC}                  : ${YB}443${NC}"
echo -e "  ${YB}- Trojan WS CDN TLS${NC}           : ${YB}443${NC}"
echo -e "  ${YB}- Trojan WS CDN${NC}               : ${YB}80${NC}"
echo -e "  ${YB}- Trojan gRPC${NC}                 : ${YB}443${NC}"
echo -e "  ${YB}- Shadowsocks WS CDN TLS${NC}      : ${YB}443${NC}"
echo -e "  ${YB}- Shadowsocks WS CDN${NC}          : ${YB}80${NC}"
echo -e "  ${YB}- Shadowsocks gRPC${NC}            : ${YB}443${NC}"
echo -e "  ${YB}- Shadowsocks 2022 WS CDN TLS${NC} : ${YB}443${NC}"
echo -e "  ${YB}- Shadowsocks 2022 WS CDN${NC}     : ${YB}80${NC}"
echo -e "  ${YB}- Shadowsocks 2022 gRPC${NC}       : ${YB}443${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo ""
rm -f xray
secs_to_human "$(($(date +%s) - ${start}))"
echo -e "${YB}[ WARNING ] reboot now ? (Y/N)${NC} "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
