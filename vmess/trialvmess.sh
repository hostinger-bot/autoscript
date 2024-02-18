domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#universal$/a\#@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vmess$/a\#@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vmess-grpc$/a\#@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/xray/config.json
vlink1=`cat<<EOF
{
"v": "2",
"ps": "$user",
"add": "$domain",
"port": "443",
"id": "$uuid",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "$domain",
"tls": "tls"
}
EOF`
vlink2=`cat<<EOF
{
"v": "2",
"ps": "$user",
"add": "$domain",
"port": "80",
"id": "$uuid",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "$domain",
"tls": "none"
}
EOF`
vlink3=`cat << EOF
{
"v": "2",
"ps": "$user",
"add": "$domain",
"port": "443",
"id": "$uuid",
"aid": "0",
"net": "grpc",
"path": "vmess-grpc",
"type": "none",
"host": "$domain",
"tls": "tls"
}
EOF`
vmesslink1="vmess://$(echo $vlink1 | base64 -w 0)"
vmesslink2="vmess://$(echo $vlink2 | base64 -w 0)"
vmesslink3="vmess://$(echo $vlink3 | base64 -w 0)"
cat > /var/www/html/vmess/vmess-$user.txt << END
==========================
    Vmess WS (CDN) TLS
==========================
- name: Vmess-$user
  type: vmess
  server: ${domain}
  port: 443
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${domain}
==========================
      Vmess WS (CDN)
==========================
- name: Vmess-$user
  type: vmess
  server: ${domain}
  port: 80
  uuid: ${uuid}
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  servername: ${domain}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${domain}
==========================
     Vmess gRPC (CDN)
==========================
- name: Vmess-$user
  server: $domain
  port: 443
  type: vmess
  uuid: $uuid
  alterId: 0
  cipher: auto
  network: grpc
  tls: true
  servername: $domain
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: "vmess-grpc"
==========================
    Link Vmess Account
==========================
Link TLS  : vmess://$(echo $vlink1 | base64 -w 0)
==========================
Link NTLS : vmess://$(echo $vlink2 | base64 -w 0)
==========================
Link gRPC : vmess://$(echo $vlink3 | base64 -w 0)
==========================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "                Trial Vmess Account                 " | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "Remarks       : $user" | tee -a /user/log-vmess-$user.txt
echo -e "ISP           : $ISP" | tee -a /user/log-vmess-$user.txt
echo -e "City          : $CITY" | tee -a /user/log-vmess-$user.txt
echo -e "Domain        : $domain" | tee -a /user/log-vmess-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-vmess-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-vmess-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-vmess-$user.txt
echo -e "id            : $uuid" | tee -a /user/log-vmess-$user.txt
echo -e "AlterId       : 0" | tee -a /user/log-vmess-$user.txt
echo -e "Security      : auto" | tee -a /user/log-vmess-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-vmess-$user.txt
echo -e "Path          : /vmess" | tee -a /user/log-vmess-$user.txt
echo -e "ServiceName   : vmess-grpc" | tee -a /user/log-vmess-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "Link TLS      : $vmesslink1" | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "Link NTLS     : $vmesslink2" | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "Link gRPC     : $vmesslink3" | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "Format Clash  : https://$domain/vmess/vmess-$user.txt" | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-vmess-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-vmess-$user.txt
echo " " | tee -a /user/log-vmess-$user.txt
echo " " | tee -a /user/log-vmess-$user.txt
echo " " | tee -a /user/log-vmess-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
vmess
