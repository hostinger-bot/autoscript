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
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Log Create User${NC}                   "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e ""
echo -e " ${MB}[1]${NC} ${YB}Log Vmess Account${NC}"
echo -e " ${MB}[2]${NC} ${YB}Log Vless Account${NC}"
echo -e " ${MB}[3]${NC} ${YB}Log Trojan Account${NC}"
echo -e " ${MB}[4]${NC} ${YB}Log Shadowsocks Account${NC}"
echo -e " ${MB}[5]${NC} ${YB}Log Shadowsocks 2022 Account${NC}"
echo -e " ${MB}[6]${NC} ${YB}Log All Xray Account${NC}"
echo -e ""
echo -e " ${MB}[0]${NC} ${YB}Back To Menu${NC}"
echo -e ""
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e ""
read -p " Select menu :  "  opt
echo -e ""
case $opt in
1) clear ; log-vmess ; exit ;;
2) clear ; log-vless ; exit ;;
3) clear ; log-trojan ; exit ;;
4) clear ; log-ss ; exit ;;
5) clear ; log-ss2022 ; exit ;;
6) clear ; log-allxray ; exit ;;
0) clear ; menu ; exit ;;
x) exit ;;
*) echo "salah tekan " ; sleep 0.5 ; log-create ;;
esac
