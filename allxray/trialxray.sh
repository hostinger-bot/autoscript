domain=$(cat /usr/local/etc/xray/domain)
user=trial-`echo $RANDOM | head -c4`
masaaktif=1
domain=$(cat /usr/local/etc/xray/domain)
cipher="aes-128-gcm"
cipher2="2022-blake3-aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
pwtr=$(openssl rand -hex 4)
pwss=$(echo $RANDOM | md5sum | head -c 6; echo;)
userpsk=$(openssl rand -base64 16)
serverpsk=$(cat /usr/local/etc/xray/serverpsk)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#universal$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vmess$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless-xtls$/a\#&@ '"$user $exp"'\
},{"flow": "'""xtls-rprx-vision""'","id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#trojan$/a\#&@ '"$user $exp"'\
},{"password": "'""$pwtr""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#trojan-tcp$/a\#&@ '"$user $exp"'\
},{"password": "'""$pwtr""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#ss$/a\#&@ '"$user $exp"'\
},{"password": "'""$pwss""'","method": "'""$cipher""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#ss2022$/a\#&@ '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vmess-grpc$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless-grpc$/a\#&@ '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#trojan-grpc$/a\#&@ '"$user $exp"'\
},{"password": "'""$pwtr""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#ss-grpc$/a\#&@ '"$user $exp"'\
},{"password": "'""$pwss""'","method": "'""$cipher""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#ss2022-grpc$/a\#&@ '"$user $exp"'\
},{"password": "'""$userpsk""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
vmlink1=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "$domain",
"tls": "tls"
}
EOF`
vmlink2=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "$domain",
"tls": "none"
}
EOF`
vmlink3=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "vmess-grpc",
"type": "none",
"host": "$domain",
"tls": "tls"
}
EOF`
vmesslink1="vmess://$(echo $vmlink1 | base64 -w 0)"
vmesslink2="vmess://$(echo $vmlink2 | base64 -w 0)"
vmesslink3="vmess://$(echo $vmlink3 | base64 -w 0)"

vlesslink1="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user"
vlesslink2="vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user"
vlesslink3="vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user"
vlesslink4="vless://$uuid@$domain:443?security=tls&encryption=none&headerType=none&type=tcp&sni=$domain&flow=xtls-rprx-vision&fp=chrome#$user"

trojanlink1="trojan://$pwtr@$domain:443?path=/trojan&security=tls&host=$domain&type=ws&sni=$domain#$user"
trojanlink2="trojan://$pwtr@$domain:80?path=/trojan&security=none&host=$domain&type=ws#$user"
trojanlink3="trojan://$pwtr@$domain:443?security=tls&encryption=none&type=grpc&serviceName=trojan-grpc&sni=$domain#$user"
trojanlink4="trojan://$pwtr@$domain:443?security=tls&type=tcp&sni=$domain#$user"

echo -n "$cipher:$pwss" | base64 -w 0 > /tmp/log
ss_base64=$(cat /tmp/log)
shadowsockslink1="ss://${ss_base64}@$domain:443?path=/ss&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink2="ss://${ss_base64}@$domain:80?path=/ss&security=none&host=${domain}&type=ws#${user}"
shadowsockslink3="ss://${ss_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=ss-grpc&sni=$domain#${user}"
rm -rf /tmp/log

echo -n "$cipher2:$serverpsk:$userpsk" | base64 -w 0 > /tmp/log
ss2022_base64=$(cat /tmp/log)
ss2022link1="ss://${ss2022_base64}@$domain:443?path=/ss2022&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
ss2022link2="ss://${ss2022_base64}@$domain:80?path=/ss2022&security=none&host=${domain}&type=ws#${user}"
ss2022link3="ss://${ss2022_base64}@$domain:443?security=tls&encryption=none&type=grpc&serviceName=ss2022-grpc&sni=$domain#${user}"
rm -rf /tmp/log

cat > /var/www/html/allxray/allxray-$user.txt << END
========================================
        ----- [ All Xray ] -----
========================================
Domain      : $domain
ISP         : $ISP
City        : $CITY
Port TLS    : 443
Port NTLS   : 80
Port gRPC   : 443
Network     : TCP, Websocket, gRPC
Alpn        : h2, http/1.1
Expired On  : $exp
========================================
        ----- [ Vmess Link ] -----
========================================
Link TLS   : $vmesslink1
========================================
Link NTLS  : $vmesslink2
========================================
Link gRPC  : $vmesslink3
========================================

========================================
        ----- [ Vless Link ] -----
========================================
Link TLS   : $vlesslink1
========================================
Link NTLS  : $vlesslink2
========================================
Link gRPC  : $vlesslink3
========================================
Link XTLS  : $vlesslink4
========================================

========================================
       ----- [ Trojan Link ] -----
========================================
Link TLS   : $trojanlink1
========================================
Link NTLS  : $trojanlink2
========================================
Link gRPC  : $trojanlink3
========================================
Link TCP   : $trojanlink4
========================================

========================================
    ----- [ Shadowsocks Link ] -----
========================================
Link TLS   : $shadowsockslink1
========================================
Link NTLS  : $shadowsockslink2
========================================
Link gRPC  : $shadowsockslink3
========================================

========================================
  ----- [ Shadowsocks 2022 Link ] -----
========================================
Link TLS   : $ss2022link1
========================================
Link NTLS  : $ss2022link2
========================================
Link gRPC  : $ss2022link3
========================================
END
systemctl restart xray
clear
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "              ----- [ All Xray ] -----              " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Domain       : $domain" | tee -a /user/log-allxray-$user.txt
echo -e "ISP          : $ISP" | tee -a /user/log-allxray-$user.txt
echo -e "City         : $CITY" | tee -a /user/log-allxray-$user.txt
echo -e "Port TLS     : 443" | tee -a /user/log-allxray-$user.txt
echo -e "Port NTLS    : 80" | tee -a /user/log-allxray-$user.txt
echo -e "Port gRPC    : 443" | tee -a /user/log-allxray-$user.txt
echo -e "Network      : TCP, Websocket, gRPC" | tee -a /user/log-allxray-$user.txt
echo -e "Alpn         : h2, http/1.1" | tee -a /user/log-allxray-$user.txt
echo -e "Expired On   : $exp" | tee -a /user/log-allxray-$user.txt
echo -e "Link Akun    : https://$domain/allxray/allxray-$user.txt" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "             ----- [ Vmess Link ] -----             " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $vmesslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $vmesslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $vmesslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "             ----- [ Vless Link ] -----             " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $vlesslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $vlesslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $vlesslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link XTLS  : $vlesslink4" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "            ----- [ Trojan Link ] -----             " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $trojanlink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $trojanlink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $trojanlink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TCP   : $trojanlink4" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "           ----- [ Shadowsocks Link ] -----         " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $shadowsockslink1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $shadowsockslink2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $shadowsockslink3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "        ----- [ Shadowsocks 2022 Link ] -----       " | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link TLS   : $ss2022link1" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link NTLS  : $ss2022link2" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e "Link gRPC  : $ss2022link3" | tee -a /user/log-allxray-$user.txt
echo -e "————————————————————————————————————————————————————" | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
echo -e " " | tee -a /user/log-allxray-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
allxray
