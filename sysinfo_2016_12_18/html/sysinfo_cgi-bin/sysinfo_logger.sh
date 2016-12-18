#!/bin/bash
C_LA1="black"
C_LA5=black
C_LA15=black
WARN=0.7
CRIT=0.9
TCP_N=0
UDP_N=0
ICMP_N=0

#LOAD AVERAGE counting
cat /var/www/stat/load_average.log >> /var/www/stat/load_average_archive.log
cat /var/www/stat/local_iostat.log > /var/www/stat/local_iostat_archive.log
cat /var/www/stat/local_netload.log > /var/www/stat/local_netload_archive.log
cat /var/www/stat/cpu_stat.log > /var/www/stat/cpu_stat_archive.log
cat /var/www/stat/disk_stat.log > /var/www/stat/disk_stat_archive.log
cat /var/www/stat/inodes_stat.log > /var/www/stat/inodes_stat_archive.log

N_CORES=$(cat /proc/cpuinfo | grep "cpu cores" | awk 'END {print $4}')
echo "Date: " $(date +"%y-%m-%d %T") > /var/www/stat/load_average.log
top -b -n 1 | awk -F " " '{for(i=1; i<13; i++) if ($i=="load"){split ($(i+2),la1,",");split ($(i+4),la5,","); split($(i+4),la15,","); print(la1[1]"."la1[2]" "la5[1]"."la5[2]" "la15[1]"."la15[2]);} else continue}' | awk -F " " -v warn=$WARN -v crit=$CRIT -v n=$N_CORES '{if ($1<(warn*n)) col1="black"; else if ($1>(crit*n)) col1="red"; else col1="yellow";  if ($2<(warn*n)) col2="black"; else if ($2>(crit*n)) col2="red"; else col2="yellow";if ($3<(warn*n)) col3="black"; else if ($3>(crit*n)) col3="red"; else col3="yellow"; print $1" "col1" "$2" "col2" "$3" "col3;}' | cat >> /var/www/stat/load_average.log

echo "Date: " $(date +"%y-%m-%d %T") > /var/www/stat/local_iostat.log
#iostat -xk | awk  '{print ($0)}' | cat >> /var/www/stat/local_iostat.log
iostat -p ALL | awk  '{print ($0)}' | cat >> /var/www/stat/local_iostat.log
#echo $(awk -F " " '{for (i=1; i<10; i++)if ( $i=="cpu" && $(i+1)=="cores") print( $(i+3)); else continue}' /proc/cpuinfo)


NET_INTERFACES=$(awk 'END { print NR }' /proc/net/dev)
let "NET_INTERFACES -= 2"
echo $NET_INTERFACES
net_load[$NET_INTERFACES]=0

echo "Date: " $(date +"%y-%m-%d %T") > /var/www/stat/local_netload.log
net_load=( $(awk -F " " -v k=2 '{if (NR>k) print $1}' /proc/net/dev) )
i=0;
while [ $i -lt $NET_INTERFACES ];
do 
net_load[$i]=${net_load[$i]/:/};
echo Net_statistics:  ${net_load[$i]} | cat >> /var/www/stat/local_netload.log ;
ethtool -S ${net_load[$i]} | awk  '{print ($0)}' | cat >> /var/www/stat/local_netload.log
let i+=1;
done;

#TCP_N=$(grep -c tcp /var/www/stat/top_talkers.log);
#UDP_N=$(grep -c UDP /var/www/stat/top_talkers.log);
#ICMP_N=$(grep -c ICMP /var/www/stat/top_talkers.log);
#let SUM=TCP_N+UDP_N+ICMP_N;
#TCP_P=$(echo "scale=2;" ${TCP_N}"*" 100 "/" ${SUM} | bc );
#UDP_P=$(echo "scale=2;" $UDP_N"*" 100 "/"$SUM | bc);
#ICMP_P=$(echo "scale=2;" $ICMP_N"*" 100 "/"$SUM | bc);
#grep -a tcp /var/www/stat/top_talkers.log | cat > /var/www/stat/udp_length.log 
#echo "EOF" >> /var/www/stat/udp_length.log 
#awk -F " " '{print ($2)}' /var/www/stat/udp_length.log
#echo -e "TCP= "$TCP_N "%TCP= "$TCP_P "\nUDP= "$UDP_N "%UDP= "$UDP_P "\nICMP= "$ICMP_N "%ICMP= "$ICMP_P | sort -nrk 2 | cat > /var/www/stat/top_proto.log

#awk -F " " '{print $6}' /var/www/stat/top_talkers.log | cat >> /var/www/stat/top_talkers_proto.log
#echo $tcp
#cat /var/www/stat/top_talkers.log > /var/www/stat/top_talkers_archive.log
#echo " " > /var/www/stat/top_talkers.log
cat /var/www/stat/cpu.log | awk '{usr=usr+$2; nice=nice+$3;sys+=$4;idle+=$5;iowait+=$6} END { if (nice/NR<70) color="black"; else if ((usr/NR)>80) color="red"; else color="yellow"; print($1" "usr/NR" "nice/NR" "(nice+usr)/NR" "sys/NR" "idle/NR" "iowait/NR" "color)}'| cat >> /var/www/stat/cpu_stat.log 
sort /var/www/stat/cpu_stat.log -nrk 1 -o /var/www/stat/cpu_stat.log

sort /var/www/stat/disk.log -nrk 2 | awk '(NR<2){nfs=$2; mfs=$3; fr=$1; n=1;} (NR>2){if (nfs==$2 && mfs==$3) {fr+=$1; n+=1;} else {print (nfs" "mfs" "(fr/n)); n=1;fr=$1;nfs=$2;mfs=$3;}} END{fr+=$1;n++; print (nfs" "mfs" "(fr/n))}'| cat > /var/www/stat/disk_stat.log 

sort /var/www/stat/inodes.log -nrk 2 | awk '(NR<2){nfs=$2; mfs=$3; fr=$1; n=1;} (NR>2){if (nfs==$2 && mfs==$3) {fr+=$1; n+=1;} else {print (nfs" "mfs" "(fr/n)); n=1;fr=$1;nfs=$2;mfs=$3;}} END{fr+=$1;n++; print (nfs" "mfs" "(fr/n))}'| cat > /var/www/stat/inodes_stat.log
echo "" | cat > /var/www/stat/inodes.log
echo "" | cat > /var/www/stat/disk.log
echo "" | cat > /var/www/stat/cpu.log


