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
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "               ${WB}----- [ DNS Setting ] -----${NC}              "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
udns=$(cat /user/current) >> /dev/null 2>&1
echo -e ""
echo -e "  ${YB}Current DNS${NC} : ${GB}$udns${WB}"
echo -e ""
echo -e " ${MB}[1]${NC} ${YB}Google DNS${NC}"
echo -e " ${MB}[2]${NC} ${YB}Cloudflare DNS${NC}"
echo -e " ${MB}[3]${NC} ${YB}Cisco OpenDNS${NC}"
echo -e " ${MB}[4]${NC} ${YB}Quad9 DNS${NC}"
echo -e " ${MB}[5]${NC} ${YB}Level 3 DNS${NC}"
echo -e " ${MB}[6]${NC} ${YB}Freenom World DNS${NC}"
echo -e " ${MB}[7]${NC} ${YB}Neustar DNS${NC}"
echo -e " ${MB}[8]${NC} ${YB}AdGuard DNS${NC}"
echo -e " ${MB}[9]${NC} ${YB}Control D DNS${NC}"
echo -e " ${MB}[10]${NC} ${YB}Custom DNS${NC}"
echo -e ""
echo -e " ${MB}[11]${NC} ${YB}Back To Main Menu${NC}"
echo ""
read -p "Select From Options [ 1 - 11 ] : " dns
echo -e ""
case $dns in
1) clear ;
echo -e " "
echo -e "${YB}Setup Google DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=8.8.8.8 8.8.4.4
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Google DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
2) clear ;
echo -e " "
echo -e "${YB}Setup Cloudflare DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=1.1.1.1 1.0.0.1
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Cloudflare DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
3) clear ;
echo -e " "
echo -e "${YB}Setup Cisco OpenDNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=208.67.222.222 208.67.222.220
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Cisco OpenDNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
4) clear ;
echo -e " "
echo -e "${YB}Setup Quad9 DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=9.9.9.9 149.112.112.112
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Quad9 DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
5) clear ;
echo -e " "
echo -e "${YB}Setup Level 3 DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=4.2.2.1 4.2.2.2
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Level 3 DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
6) clear ;
echo -e " "
echo -e "${YB}Setup Freenom World DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=80.80.80.80 80.80.81.81
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Freenom World DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
7) clear ;
echo -e " "
echo -e "${YB}Setup Neustar DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=156.154.70.2 156.154.71.2
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Neustar DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
8) clear ;
echo -e " "
echo -e "${YB}Setup AdGuard DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=94.140.14.14 94.140.15.15
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "AdGuard DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
9) clear ;
echo -e " "
echo -e "${YB}Setup Control D DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=76.76.2.43 76.76.10.43
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Control D DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
10) clear ;
echo -e " "
read -p "Please Insert Custom DNS (IPv4 Only): " custom
if [ -z $custom ]; then
echo " "
echo "Please Insert Custom DNS !!!"
sleep 1
clear
changer
fi
echo -e "${YB}Setup Custom DNS${NC}"
cat > /etc/systemd/resolved.conf << END
[Resolve]
DNS=$custom
Domains=~.
ReadEtcHosts=yes
END
systemctl restart resolvconf
systemctl restart systemd-resolved
systemctl restart NetworkManager
echo "Custom DNS" > /user/current
echo -e "${YB}Setup Completed${NC}"
sleep 1.5 ; clear ; changer ;;
11) clear ; menu ;;
*) echo -e "${YB}Please enter an correct number${NC}" ; sleep 1 ; changer ;;
esac
