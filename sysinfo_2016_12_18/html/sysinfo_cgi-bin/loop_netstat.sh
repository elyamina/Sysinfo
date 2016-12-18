#!/bin/bash
while true; do
sleep 10
netstat -ltn | cat >>/var/www/stat/netstat.log
netstat -lun | cat >>/var/www/stat/netstat.log
ss -t state all | awk '{print ($2" "$3" "$4" "$5" "$1)}' | cat >>/var/www/stat/netstat_tcp.log
mpstat | awk -F " " '(NR>3){split ($3,usr,","); split($4, nice,","); split($5, sys,",");split($12, idle,",");split($6, iowait,","); print ($1" "usr[1]"."usr[2]" "nice[1]"."nice[2]" "sys[1]"."sys[2]" "idle[1]"."idle[2]" "iowait[1]"."iowait[2])}'| cat >> /var/www/stat/cpu.log
df | awk -F " " '(NR>1){pr =1; split ($6,m,"/"); split ($5, used, "%"); for (i=0; i<6; i++) if(m[i]=="sys") pr=0; if (pr) print (100-used[1])" "$6" "$1}' | cat >> /var/www/stat/disk.log
df -i | awk -F " " '(NR>1){pr =1; split ($6,m,"/"); split ($5, used, "%"); for (i=0; i<6; i++) if(m[i]=="sys") pr=0; if (pr) print (100-used[1])" "$6" "$1}' | cat >> /var/www/stat/inodes.log
done
