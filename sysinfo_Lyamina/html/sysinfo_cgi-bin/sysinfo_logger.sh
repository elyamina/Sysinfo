#!/bin/bash

WARN=0.7
CRIT=0.9
TCP_N=0
UDP_N=0
ICMP_N=0

#rm -rf $(ls | sort -r | awk '(NR>6){print $0}')

#LOAD AVERAGE counting



while true; do
sleep 10

cat /var/www/stat/iostat_stat.log > /var/www/stat/iostat_archive.log
cat /var/www/stat/netload_stat.log > /var/www/stat/netload_stat_archive.log

cat /var/www/stat/inodes_stat.log > /var/www/stat/inodes_stat_archive.log
cat /var/www/stat/top_proto.log >/var/www/stat/top_proto_archive.log
cat /var/www/stat/top_pack.log > /var/www/stat/top_pack_archive.log
cat /var/www/stat/top_bytes.log > /var/www/stat/top_bytes_archive.log

cat /var/www/stat/iostat.log |sort -r| awk -v time=0 -v n=6 '(NR<2) {time=$1; print $0} (NR>2) {if ($1==time)print $0; else if (n>1) {n-=1; time=$1; print $0;} else;}'| sort -k 2 | awk -v n=6 '(NR<2){disk=$2; rrqms=$3; wrqms=$4; rs=$5; ws=$6; rkbs=$7; wkbs=$8; avgrq=$9; avgsz=$10; await=$11; r_await=$12; w_await=$13; svctm=$14; util=$15;} (NR>1){if (disk==$2) {rrqms+=$3; wrqms+=$4; rs+=$5; ws+=$6; rkbs+=$7; wkbs+=$8; avgrq+=$9; avgsz+=$10; await+=$11; r_await+=$12; w_await+=$13; svctm+=$14; util+=$15;} else {print (disk" "rrqms/n" "wrqms/n" "rs/n" "ws/n" "rkbs/n" "wkbs/n" "avgrq/n" "avgsz/n" "await/n" "r_await/n" "w_await/n" "svctm/n" "util/n); disk=$2; rrqms=$3; wrqms=$4; rs=$5; ws=$6; rkbs=$7; wkbs=$8; avgrq=$9; avgsz=$10; await=$11; r_await=$12; w_await=$13; svctm=$14; util=$15;}} END {print (disk" "rrqms/n" "wrqms/n" "rs/n" "ws/n" "rkbs/n" "wkbs/n" "avgrq/n" "avgsz/n" "await/n" "r_await/n" "w_await/n" "svctm/n" "util/n);}'> /var/www/stat/iostat_stat.log 


cat /var/www/stat/net_load.log | sort -rk 18 | awk -v time=0 -v c=6 '(NR<2) { iface=$1; print $0} (NR>2) {n+=1; if (iface==$1 && n==c)print $0; else if (iface!=$1) {iface=$1; n=1; print $0;} else;}'|sort -k 18 | awk -v n=6 '(NR<2){iface=$1; rbytes=$2; rpack=$3; rerrs=$4; rdrop=$5; rfilo=$6; rframe=$7; rcompr=$8; rmult=$9; tbytes=$10; tpack=$11; terrs=$12; tdrop=$13; tfilo=$14; tcolls=$15; tcar=$16; tcompr=$17; time=$18;} (NR>1){if (iface==$1){ print iface" "($2-rbytes)" "($3-rpack)" "($4-rerrs)" "($5-rdrop)" "($6-rfilo)" "($7-rframe)" "($8-rcompr)" "($9-rmult)" "($10-tbytes)" "($11-tpack)" "($12-terrs)" "($13-tdrop)" "($14-tfilo)" "($15-tcolls)" "($16-tcar)" "($17-tcompr)} else if ($1!=iface){i=1;  iface=$1; rbytes=$1; rpack=$3; rerrs=$4; rdrop=$5; rfilo=$6; rframe=$7; rcompr=$8; rmult=$9; tbytes=$10; tpack=$11; terrs=$12; tdrop=$13; tfilo=$14; tcolls=$15; tcar=$16; tcompr=$17; time=$18;}}' > /var/www/stat/netload_stat.log 

#отлов Top Talkers
cat /var/www/stat/top_proto.log >/var/www/stat/top_proto_archive.log

rm -rf  /var/www/stat/top_temp.log
rm -rf  /var/www/stat/top_temp.log
N=$(ls /var/www/stat/top_t/|awk'END {print NR}')

#if (N>6) then rm -rf /var/www/stat/top_t/*$(ls /var/www/stat/top_t | sort -r | awk '(NR>5){print $0}');
#fi
for var in $(ls /var/www/stat/top_t -1 | sort) ;  
do  tcpdump -vqnr /var/www/stat/top_t/$var >> /var/www/stat/top_temp.log; 
done

#топ протоколы
TCP_N=$(grep -c TCP /var/www/stat/top_temp.log);
UDP_N=$(grep -c UDP /var/www/stat/top_temp.log);
ICMP_N=$(grep -c ICMP /var/www/stat/top_temp.log);
TCP_B=$(grep -a TCP /var/www/stat/top_temp.log | awk -F " " '{split ($17, l, ")");print l[1]}'| awk '{s+=$0} END{print s}')
ICMP_B=$(grep -a ICMP /var/www/stat/top_temp.log | awk -F " " '{if ($2="IP" && $14=="ICMP" ){split ($17, l,")");s+=l[1]}} END {print s}')
UDP_B=$(grep -a UDP /var/www/stat/top_temp.log | awk -F " " '{if ($2="IP" && $14=="UDP" ){split ($17, l,")");s+=l[1]}} END {print s}')
let SUM=TCP_B+UDP_B+ICMP_B;
TCP_P=$(awk -v tcp=$TCP_B -v s=$SUM 'BEGIN { if (s!=0) print (tcp*00/s)}' )
UDP_P=$(awk -v udp=$UDP_B -v s=$SUM 'BEGIN { if (s!=0) print (udp*100/s)}')
ICMP_P=$(awk -v icmp=$ICMP_B -v s=$SUM 'BEGIN { if (s!=0) print (icmp*100/s)}')
echo -e "TCP "$TCP_N "TCP_BYTES= "$TCP_B "%TCP= "$TCP_P "\nUDP "$UDP_N "UDP_BYTES= "$UDP_B  "%UDP= "$UDP_P "\nICMP "$ICMP_N "ICMP_BYTES= "$ICMP_B "%ICMP= "$ICMP_P | sort -nrk 2  > /var/www/stat/top_proto.log


#топ по байтам
cat /var/www/stat/top_temp.log | awk '{if ($4=="tcp") {split ($1,Sip,"."); split ($3,Rip,"."); print (Sip[1]"."Sip[2]"."Sip[3]"."Sip[4]" "Sip[5]" "Rip[1]"."Rip[2]"."Rip[3]"."Rip[4]" "$4" "$5)}if ($4=="UDP,") {split ($1,Sip,"."); split ($3,Rip,"."); print (Sip[1]"."Sip[2]"."Sip[3]"."Sip[4]" "Sip[5]" "Rip[1]"."Rip[2]"."Rip[3]"."Rip[4]" "$4" "$6)} if ($i=="ICMP") print($1" - "$2" "$4" " $6);}'| sort | awk '(NR<2){src=$1; dst=$3; src_p=$2; proto=$4; bytes=$5;} (NR>2){if (src==$1 && dst==$3 && src_p==$2) bytes+=$5; else {print (src" "src_p" "dst" "proto" "(bytes/60)); proto=$4; bytes=$5; src=$1; dst=$3; src_p=$2}} END{bytes+=$5; print (src" "src_p" "dst" "proto" "(bytes/60))}'| sort -nrk 5 > /var/www/stat/top_bytes.log

#топ по пактеам
cat /var/www/stat/top_temp.log | awk '{if ($4=="tcp") {split ($1,Sip,"."); split ($3,Rip,"."); print (Sip[1]"."Sip[2]"."Sip[3]"."Sip[4]" "Sip[5]" "Rip[1]"."Rip[2]"."Rip[3]"."Rip[4]" "$4)}if ($4=="UDP,") {split ($1,Sip,"."); split ($3,Rip,"."); print (Sip[1]"."Sip[2]"."Sip[3]"."Sip[4]" "Sip[5]" "Rip[1]"."Rip[2]"."Rip[3]"."Rip[4]" "$4)} if ($i=="ICMP") print($1" - "$2" "$4);}' | sort | uniq -c | sort -nrk 1 > /var/www/stat/top_pack.log

done


