NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
clear
domain=$(cat /usr/local/etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Add Vless Account${NC}                 "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  Add Vless Account                 "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
add-vless
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#universal/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless$/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless-grpc$/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless-xtls$/a\#&@ '"$user $exp"'\
},{"flow": "'""xtls-rprx-vision""'","id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
vlesslink1="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user"
vlesslink2="vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user"
vlesslink3="vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user"
vlesslink4="vless://$uuid@$domain:443?security=tls&encryption=none&headerType=none&type=tcp&sni=$domain&flow=xtls-rprx-vision&fp=chrome#$user"
cat > /var/www/html/vless/vless-$user.txt << END
==========================
    Vless WS (CDN) TLS
==========================
- name: Vless-$user
  type: vless
  server: ${domain}
  port: 443
  uuid: ${uuid}
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: ${domain}
  network: ws
  ws-opts:
  path: /vless
  headers:
  Host: ${domain}
==========================
      Vless WS (CDN)
==========================
- name: Vless-$user
  type: vless
  server: ${domain}
  port: 80
  uuid: ${uuid}
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  network: ws
  ws-opts:
  path: /vless
  headers:
  Host: ${domain}
==========================
      Vless gRPC (CDN)
==========================
- name: Vless-$user
  server: $domain
  port: 443
  type: vless
  uuid: $uuid
  cipher: auto
  network: grpc
  tls: true
  servername: $domain
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: "vless-grpc"
==========================
     Vless XTLS Vision
==========================
- name: Vless-$user
  type: vless
  server: $domain
  port: 443
  uuid: $uuid
  network: tcp
  tls: true
  udp: true
  # xudp: true
  flow: xtls-rprx-vision 
  servername: $domain
  client-fingerprint: chrome
  # fingerprint: xxxx
  skip-cert-verify: true
==========================
    Link Vless Account
==========================
Link TLS  : vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user
==========================
Link NTLS : vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user
==========================
Link gRPC : vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user
==========================
Link XTLS : vless://$uuid@$domain:443?security=tls&encryption=none&headerType=none&type=tcp&sni=$domain&flow=xtls-rprx-vision&fp=chrome#$user
==========================
END
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "                    Vless Account                   " | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-vless-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-vless-$user.txt
echo -e "ISP           : $ISP" | tee -a /user/log-vless-$user.txt
echo -e "City          : $CITY" | tee -a /user/log-vless-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-vless-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-vless-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-vless-$user.txt
echo -e "id            : ${uuid}" | tee -a /user/log-vless-$user.txt
echo -e "Encryption    : none" | tee -a /user/log-vless-$user.txt
echo -e "Flow          : xtls-rprx-vision" | tee -a /user/log-vless-$user.txt
echo -e "Network       : TCP, Websocket, gRPC" | tee -a /user/log-vless-$user.txt
echo -e "Path          : /vless" | tee -a /user/log-vless-$user.txt
echo -e "ServiceName   : vless-grpc" | tee -a /user/log-vless-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link TLS      : ${vlesslink1}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link NTLS     : ${vlesslink2}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link gRPC     : ${vlesslink3}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link XTLS     : ${vlesslink4}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Format Clash  : https://$domain/vless/vless-$user.txt" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
vless
