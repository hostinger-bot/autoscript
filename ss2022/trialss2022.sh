domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
cipher2="2022-blake3-aes-128-gcm"
userpsk=$(openssl rand -base64 16)
serverpsk=$(cat /usr/local/etc/xray/serverpsk)
masaaktif=1
echo ""
echo ""
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#ss2022$/a\#% '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#ss2022-grpc$/a\#% '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
echo -n "$cipher2:$serverpsk:$userpsk" | base64 -w 0 > /tmp/log
ss2022_base64=$(cat /tmp/log)
ss2022link1="ss://${ss2022_base64}@$domain:443?path=/ss2022&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
ss2022link2="ss://${ss2022_base64}@$domain:80?path=/ss2022&security=none&host=${domain}&type=ws#${user}"
ss2022link3="ss://${ss2022_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=ss2022-grpc&sni=$domain#${user}"
rm -rf /tmp/log
cat > /var/www/html/ss2022/ss2022-$user.txt << END
===============================
 Shadowsocks 2022 WS (CDN) TLS
===============================
- name: SS2022-$user
  type: ss
  server: $domain
  port: 443
  cipher: $cipher2
  password: $serverpsk:$userpsk
  plugin: v2ray-plugin
    plugin-opts:
    mode: websocket
    tls: true
    skip-cert-verify: true
    host: $domain
    path: "/ss2022"
    mux: true
=============================
  Shadowsocks 2022 WS (CDN)
=============================
- name: SS2022-$user
  type: ss
  server: $domain
  port: 80
  cipher: $cipher2
  password: $serverpsk:$userpsk
  plugin: v2ray-plugin
    plugin-opts:
    mode: websocket
    tls: false
    skip-cert-verify: false
    host: $domain
    path: "/ss2022"
    mux: true
===============================
 Link Shadowsocks 2022 Account
===============================
Link TLS  : $ss2022link1
==============================
Link NTLS : $ss2022link2
==============================
Link gRPC : $ss2022link3
==============================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "           Trial Shadowsocks 2022 Account           " | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-ss2022-$user.txt
echo -e "ISP           : ${ISP}" | tee -a /user/log-ss2022-$user.txt
echo -e "City          : ${CITY}" | tee -a /user/log-ss2022-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-ss2022-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-ss2022-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-ss2022-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-ss2022-$user.txt
echo -e "Cipher        : ${cipher2}" | tee -a /user/log-ss2022-$user.txt
echo -e "Password      : $serverpsk:$userpsk" | tee -a /user/log-ss2022-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-ss2022-$user.txt
echo -e "Path          : /ss2022" | tee -a /user/log-ss2022-$user.txt
echo -e "ServiceName   : ss2022-grpc" | tee -a /user/log-ss2022-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Link TLS      : ${ss2022link1}" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Link NTLS     : ${ss2022link2}" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Link gRPC     : ${ss2022link3}" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Format Clash  : https://$domain/ss2022/ss2022-$user.txt" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-ss2022-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-ss2022-$user.txt
echo " " | tee -a /user/log-ss2022-$user.txt
echo " " | tee -a /user/log-ss2022-$user.txt
echo " " | tee -a /user/log-ss2022-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
ss2022
