#!/bin/bash

sudo apt-get install nginx
sudo cp -f $PWD/nginx_conf/default.conf /etc/nginx/conf.d/
sudo cp -f $PWD/nginx_conf/index.html  /usr/share/nginx/html/
/etc/init.d/nginx start
sudo apt-get install apache2

sudo cp -f $PWD/apache2_confs/000-default.conf /etc/apache2/sites-enabled/
sudo cp -f $PWD/apache2_confs/000-default.conf /etc/apache2/sites-available/
sudo cp -f $PWD/apache2_confs/ports.conf /etc/apache2/
sudo cp -f $PWD/apache2_confs/index.html  /var/www/html/sysinfo/index.html
sudo cp -R $PWD/apache2_confs/sysinfo/  /var/www/html/
sudo cp -f $PWD/apache2_confs/serve-cgi-bin.conf  /etc/apache2/conf-available/
sudo cp -R $PWD/apache2_confs/sysinfo_cgi-bin/ /var/www/html/ 

sudo ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load

sudo apt-get install sysstat

sudo mkdir /var/www/stat
sudo cp -r $PWD/html/sysinfo /var/www/html/
sudo cp -r $PWD/html/sysinfo_cgi-bin/ /var/www/html/
#sudo cp $PWD/sysinfo_logger.sh /var/www/html/sysinfo_cgi-bin/
#sudo cp  $PWD/netinfo_logger.sh /var/www/html/sysinfo_cgi-bin/
#sudo cp  $PWD/loop_netstat.sh /var/www/html/sysinfo_cgi-bin/
#sudo cat  $PWD/crontab.conf >> /etc/crontab.conf
sudo crontab $PWD/crontab.conf
sudo /var/www/html/sysinfo_cgi-bin/loop_netstat.sh &


/etc/init.d/apache2 start
/etc/init.d/nginx restart
