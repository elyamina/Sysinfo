#!/bin/bash
TCP_N=0
UDP_N=0
ICMP_N=0
TCP_PID=0
TCP_B=0
UDP_B=0
ICMP_B=0
#cat /var/www/stat/top_proto.log >/var/www/stat/top_proto_archive.log
#cat /var/www/stat/top_pack.log > /var/www/stat/top_pack_archive.log
#cat /var/www/stat/top_bytes.log > /var/www/stat/top_bytes_archive.log
#cat /var/www/stat/listeners.log > /var/www/stat/listeners_archive.log
#cat /var/www/stat/tcp_state.log > /var/www/stat/tcp_state_archive.log

tcpdump -q -n -i any -l | tee /var/www/stat/top_talkers.log & export TCP_PID=$!
sleep 59
let TCP_PID-=1;
kill $TCP_PID
let TCP_PID+=1;
kill $TCP_PID

cat /var/www/stat/top_proto.log >/var/www/stat/top_proto_archive.log
TCP_N=$(grep -c tcp /var/www/stat/top_talkers.log);
UDP_N=$(grep -c UDP /var/www/stat/top_talkers.log);
ICMP_N=$(grep -c ICMP /var/www/stat/top_talkers.log);
let SUM=TCP_N+UDP_N+ICMP_N;
#TCP_P=$(echo "scale=2;" ${TCP_N}"*" 100 "/" ${SUM} | bc );
#UDP_P=$(echo "scale=2;" $UDP_N"*" 100 "/"$SUM | bc);
#ICMP_P=$(echo "scale=2;" $ICMP_N"*" 100 "/"$SUM | bc);

TCP_B=$(grep -a tcp /var/www/stat/top_talkers.log | awk -F " " '{print $7}' | awk '{s += $1} END {print s}')
ICMP_B=$(grep -a ICMP /var/www/stat/top_talkers.log | awk -F " " '{for (i=0; i<14; i++) if ($i=="length")print $(i+1)}' | awk '{s += $1} END {if (s)print s; else print "0"}')
UDP_B=$(grep -a UDP /var/www/stat/top_talkers.log | awk -F " " '{for (i=0; i<14; i++) if ($i=="length")print $(i+1)}' | awk '{s += $1} END {if (s)print s; else print "0"}')
let SUM=TCP_B+UDP_B+ICMP_B;
TCP_P=$(awk -v tcp=$TCP_B -v s=$SUM 'BEGIN { print (tcp*100/s)}' )
UDP_P=$(awk -v udp=$UDP_B -v s=$SUM 'BEGIN { print (udp*100/s)}')
ICMP_P=$(awk -v icmp=$ICMP_B -v s=$SUM 'BEGIN { print (icmp*100/s)}')
echo $TCP_P $UDP_P $ICMP_P

cat /var/www/stat/top_pack.log > /var/www/stat/top_pack_archive.log
#uniq -c -f 1 /var/www/stat/top_talkers.log | sort -nrk 1 | cat > /var/www/stat/top_pack.log 
cat /var/www/stat/top_talkers.log | awk '{split ($3,Sip,"."); split ($5,Rip,"."); i=1; if ($(i+5)=="ICMP") print ($(i+2)" "$(i+4)" "$(i+5)); else if($(i+1)=="IP") print (Sip[1]"."Sip[2]"."Sip[3]"."Sip[4]" "Sip[5]" "Rip[1]"."Rip[2]"."Rip[3]"."Rip[4]" "$(i+5))}' | sort | uniq -c | sort -nrk 1 | cat > /var/www/stat/top_pack.log

cat /var/www/stat/top_bytes.log > /var/www/stat/top_bytes_archive.log

cat /var/www/stat/top_talkers.log | awk '{split ($3,Sip,"."); split ($5,Rip,"."); i=1; if ($(i+5)=="ICMP") print ($(i+2)" - "$(i+4)" "$(i+5)" " $(i+13)); else if($(i+1)=="IP") print (Sip[1]"."Sip[2]"."Sip[3]"."Sip[4]" "Sip[5]" "Rip[1]"."Rip[2]"."Rip[3]"."Rip[4]" "$(i+5)" "$(i+6))}' | sort | awk '(NR<2){src=$1; dst=$3; src_p=$2; proto=$4; bytes=$5;} (NR>2){if (src==$1 && dst==$3 && src_p==$2) bytes+=$5; else {print (src" "src_p" "dst" "proto" "(bytes/60)); proto=$4; bytes=$5; src=$1; dst=$3; src_p=$2}} END{bytes+=$5; print (src" "src_p" "dst" "proto" "(bytes/60))}'| sort -nrk 5| cat > /var/www/stat/top_bytes.log

echo -e "TCP "$TCP_N "TCP_BYTES= "$TCP_B "%TCP= "$TCP_P "\nUDP "$UDP_N "UDP_BYTES= "$UDP_B  "%UDP= "$UDP_P "\nICMP "$ICMP_N "ICMP_BYTES= "$ICMP_B "%ICMP= "$ICMP_P | sort -nrk 2 | cat > /var/www/stat/top_proto.log

cat /var/www/stat/listeners.log > /var/www/stat/listeners_archive.log
cat /var/www/stat/netstat.log | sort | uniq -c | sort -nrk 1 | awk '{for (i=0;i<10;i++) if($i=="tcp" || $i=="tcp6" || $i=="udp" || $i=="udp6") print $i" "$(i+3)}' | sort | uniq -c | sort -nrk 1 |cat >> /var/www/stat/listeners.log
cat /var/www/stat/tcp_state.log > /var/www/stat/tcp_state_archive.log
cat /var/www/stat/netstat_tcp.log |sort | uniq -c | sort -nrk 5 |awk -F " " '{if ($6!="State")print $6;}'|sort | uniq -c| sort -rk 1 | cat > /var/www/stat/tcp_state.log


echo ""| cat /var/www/stat/top_talkers.log 
echo ""| cat > /var/www/stat/netstat.log 
echo ""| cat > /var/www/stat/netstat_tcp.log 
echo the end
