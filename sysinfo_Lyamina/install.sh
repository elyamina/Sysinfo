#!/bin/bash
PATH=/usr/sbin:$PATH
sudo chmod a+x  $PWD/html/sysinfo_cgi-bin/* 
sudo chmod 777 $PWD/*
sudo apt-get install nginx
sudo cp -f $PWD/nginx_conf/default.conf /etc/nginx/conf.d/
sudo cp -f $PWD/nginx_conf/index.html  /usr/share/nginx/html/
/etc/init.d/nginx start
sudo apt-get install apache2

sudo cp -f $PWD/apache2_confs/000-default.conf /etc/apache2/sites-enabled/
sudo cp -f $PWD/apache2_confs/000-default.conf /etc/apache2/sites-available/
sudo cp -f $PWD/apache2_confs/ports.conf /etc/apache2/
sudo cp -f $PWD/apache2_confs/index.html  /var/www/html/sysinfo/index.html
sudo cp -R $PWD/html/sysinfo/  /var/www/html/
sudo cp -f $PWD/apache2_confs/serve-cgi-bin.conf  /etc/apache2/conf-available/
sudo cp -R $PWD/html/sysinfo_cgi-bin/ /var/www/html/ 

sudo ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load

sudo apt-get install sysstat
sudo apt-get install gawk
sudo apt-get install apparmor-utils

sudo mkdir /var/www/stat
sudo chmod 777 /var/www/stat/
sudo mkdir /var/www/stat/top_t
sudo mkdir /usr/share/nginx/html/archive/

#sudo cp -r $PWD/html/sysinfo /var/www/html/
#sudo cp -r $PWD/html/sysinfo_cgi-bin/ /var/www/html/
#sudo cp $PWD/sysinfo_logger.sh /var/www/html/sysinfo_cgi-bin/
#sudo cp  $PWD/netinfo_logger.sh /var/www/html/sysinfo_cgi-bin/
#sudo cp  $PWD/loop_netstat.sh /var/www/html/sysinfo_cgi-bin/
sudo cat  $PWD/crontab.conf >> /etc/crontab.conf
sudo crontab $PWD/crontab.conf
sudo /var/www/html/sysinfo_cgi-bin/loop_netstat.sh &
sudo aa-complain /usr/sbin/tcpdump
sudo tcpdump -qni any -G 10 -w /var/www/stat/top_t/top_talkers_%H:%M:%S.log &
/etc/init.d/apache2 start
/etc/init.d/nginx restart
sudo /var/www/html/sysinfo_cgi-bin/sysinfo_logger.sh &
while true; 
do 
sudo mpstat 60 1 | awk '{if ($1!="Linux" && $2!="CPU" && $1!="Среднее:")print $0}'| awk -F " " '{split ($3,usr,","); split($4, nice,","); split($5, sys,",");split($12, idle,",");split($6, iowait,","); print ($1" "usr[1]"."usr[2]" "nice[1]"."nice[2]" "sys[1]"."sys[2]" "idle[1]"."idle[2]" "iowait[1]"."iowait[2])}'| cat >> /var/www/stat/cpu.log; 
done



