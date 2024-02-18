domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
cipher="aes-128-gcm"
# uuid=$(cat /proc/sys/kernel/random/uuid)
pwss=$(echo $RANDOM | md5sum | head -c 6; echo;)
masaaktif=1
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#ss$/a\#! '"$user $exp"'\
},{"password": "'""$pwss""'","method": "'""$cipher""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#ss-grpc$/a\#! '"$user $exp"'\
},{"password": "'""$pwss""'","method": "'""$cipher""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
echo -n "$cipher:$pwss" | base64 -w 0 > /tmp/log
ss_base64=$(cat /tmp/log)
shadowsockslink1="ss://${ss_base64}@$domain:443?path=/ss&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink2="ss://${ss_base64}@$domain:80?path=/ss&security=none&host=${domain}&type=ws#${user}"
shadowsockslink3="ss://${ss_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=ss-grpc&sni=$domain#${user}"
rm -rf /tmp/log
cat > /var/www/html/ss/ss-$user.txt << END
==========================
 Shadowsocks WS (CDN) TLS
==========================
- name: SS-$user
  type: ss
  server: $domain
  port: 443
  cipher: $cipher
  password: $pwss
  plugin: v2ray-plugin
    plugin-opts:
    mode: websocket
    tls: true
    skip-cert-verify: true
    host: $domain
    path: "/ss"
    mux: true
==========================
   Shadowsocks WS (CDN)
==========================
- name: SS-$user
  type: ss
  server: $domain
  port: 80
  cipher: $cipher
  password: $pwss
  plugin: v2ray-plugin
    plugin-opts:
    mode: websocket
    tls: false
    skip-cert-verify: false
    host: $domain
    path: "/ss"
    mux: true
==========================
 Link Shadowsocks Account
==========================
Link TLS : ${shadowsockslink1}
==========================
Link NTLS : ${shadowsockslink2}
==========================
Link gRPC : ${shadowsockslink3}
==========================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "              Trial Shadowsocks Account             " | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-ss-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-ss-$user.txt
echo -e "ISP           : ${ISP}" | tee -a /user/log-ss-$user.txt
echo -e "City          : ${CITY}" | tee -a /user/log-ss-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-ss-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-ss-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-ss-$user.txt
echo -e "Cipher        : ${cipher}" | tee -a /user/log-ss-$user.txt
echo -e "Password      : $pwss" | tee -a /user/log-ss-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-ss-$user.txt
echo -e "Path          : /ss" | tee -a /user/log-ss-$user.txt
echo -e "ServiceName   : ss-grpc" | tee -a /user/log-ss-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Link TLS      : ${shadowsockslink1}" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Link NTLS     : ${shadowsockslink2}" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Link gRPC     : ${shadowsockslink3}" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Format Clash  : https://$domain/ss/ss-$user.txt" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-ss-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss-$user.txt
echo " " | tee -a /user/log-ss-$user.txt
echo " " | tee -a /user/log-ss-$user.txt
echo " " | tee -a /user/log-ss-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
shadowsocks
