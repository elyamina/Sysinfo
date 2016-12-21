#!/bin/bash
cat /var/www/stat/load_average.log >> /var/www/stat/load_average_archive.log
cat /var/www/stat/listeners.log > /var/www/stat/listeners_archive.log
cat /var/www/stat/tcp_state.log > /var/www/stat/tcp_state_archive.log
cat /var/www/stat/cpu_stat.log > /var/www/stat/cpu_stat_archive.log
cat /var/www/stat/disk_stat.log > /var/www/stat/disk_stat_archive.log

N_CORES=$(cat /proc/cpuinfo | grep "cpu cores" | awk 'END {print $4}')
echo "Date: " $(date +"%y-%m-%d %T") > /var/www/stat/load_average.log
top -b -n 1 | awk -F " " '{for(i=1; i<13; i++) if ($i=="load"){split ($(i+2),la1,",");split ($(i+4),la5,","); split($(i+4),la15,","); print(la1[1]"."la1[2]" "la5[1]"."la5[2]" "la15[1]"."la15[2]);} else continue}' | awk -F " " -v warn=$WARN -v crit=$CRIT -v n=$N_CORES '{if ($1<(warn*n)) col1="black"; else if ($1>(crit*n)) col1="red"; else col1="yellow";  if ($2<(warn*n)) col2="black"; else if ($2>(crit*n)) col2="red"; else col2="yellow";if ($3<(warn*n)) col3="black"; else if ($3>(crit*n)) col3="red"; else col3="yellow"; print $1" "col1" "$2" "col2" "$3" "col3;}' >> /var/www/stat/load_average.log

#Listeners
cat /var/www/stat/netstat.log | sort | uniq -c | sort -nrk 1 | awk '{for (i=0;i<10;i++) if($i=="tcp" || $i=="tcp6" || $i=="udp" || $i=="udp6") print $i" "$(i+3)}' | sort | uniq -c | sort -nrk 1 > /var/www/stat/listeners.log

#TCP states
cat /var/www/stat/netstat_tcp.log |sort | uniq -c | sort -nrk 5 |awk -F " " '{if ($6!="State")print $6;}'|sort | uniq -c| sort -rk 1 > /var/www/stat/tcp_state.log

cat /var/www/stat/cpu.log | awk '{usr=$2; nice=$3;sys=$4;idle=$5;iowait=$6} END { if (nice<70) color="black"; else if ((usr)>80) color="red"; else color="yellow"; print($1" "usr" "nice" "(nice+usr)" "sys" "idle" "iowait" "color)}'>> /var/www/stat/cpu_stat.log
sort /var/www/stat/cpu_stat.log -nrk 1 -o /var/www/stat/cpu_stat.log

sort /var/www/stat/disk.log -nrk 2 | awk '(NR<2){nfs=$2; mfs=$3; fr=$1; n=1;} (NR>2){if (nfs==$2 && mfs==$3) {fr+=$1; n+=1;} else {print (nfs" "mfs" "(fr/n)); n=1;fr=$1;nfs=$2;mfs=$3;}} END{fr+=$1;n++; print (nfs" "mfs" "(fr/n))}' > /var/www/stat/disk_stat.log 

sort /var/www/stat/inodes.log -nrk 2 | awk '(NR<2){nfs=$2; mfs=$3; fr=$1; n=1;} (NR>2){if (nfs==$2 && mfs==$3) {fr+=$1; n+=1;} else {print (nfs" "mfs" "(fr/n)); n=1;fr=$1;nfs=$2;mfs=$3;}} END{fr+=$1;n++; print (nfs" "mfs" "(fr/n))}' > /var/www/stat/inodes_stat.log

sudo curl localhost/sysinfo > /usr/share/nginx/html/archive/$(awk 'BEGIN {print strftime("%Y-%m-%d_%H:%M:%S")".html"}')


ls /usr/share/nginx/html/archive/ -1 |sort -r| awk 'BEGIN{ print "<head> <title>Архив</title></head><html><body>"} {print "<p><a href=http://localhost/archive/"$1">"$1" </a></p>"} END{print "</html></body>"}'> /usr/share/nginx/html/archive.html

echo "" > /var/www/stat/inodes.log
echo "" > /var/www/stat/disk.log
echo "" > /var/www/stat/cpu.log



#echo ""| cat /var/www/stat/top_talkers.log 
#echo ""| cat > /var/www/stat/netstat.log 
#echo ""| cat > /var/www/stat/netstat_tcp.log 
#echo the end
