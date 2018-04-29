#!/bin/bash
# Created by Yamada246 20170731
# Reference: 
# https://dotblogs.com.tw/supershowwei/2016/02/02/112238
# https://coderwall.com/p/ypo94q/redis-install-script-for-automatic-deployments
pw="12345678"
serverIP="10.10.10.100"
allowIP="10.10.30.0/24"
################
# Installation #
################
yum -y install gcc tcl
wget http://download.redis.io/releases/redis-4.0.1.tar.gz
tar xzf redis-4.0.1.tar.gz
#################
# Compile Redis #
#################
cd redis-4.0.1
make
##########################
# Test and install Redis #
##########################
# make test
make install
##########################
# Create Redis directory #
##########################
mkdir /etc/redis
mkdir /var/redis
############################
# Create working directory #
############################
mkdir /var/redis/6379
###########################
# Copy configuration file #
# Set Redis settings      #
###########################
sed -e 's/daemonize no/daemonize yes/g' -e 's/pidfile \/var\/run\/redis_6379.pid/pidfile \/var\/run\/redis_6379.pid/g' -e 's/logfile ""/logfile \/var\/log\/redis_6379.log/g' -e 's/dir .\//dir \/var\/redis\/6379/g' -e "s/# requirepass foobared/requirepass $pw/g" -e "s/bind 127.0.0.1/bind 127.0.0.1 $serverIP/g" /redis-4.0.1/redis.conf > /etc/redis/redis_6379.conf
##################################
# Add allow port 6379 to allowIP #
##################################
iptables -A INPUT -p tcp --dport 6379 -s $allowIP -j ACCEPT
iptables-save > /etc/sysconfig/iptables
service iptables restart
###########################
# Copy&Modify init script #
###########################
sed -e '2c # chkconfig: 2345 80 90' -e '11c CONF="/etc/redis/redis_${REDISPORT}.conf"' -e 's/$EXEC $CONF/$EXEC $CONF \&/g' /redis-4.0.1/utils/redis_init_script > /etc/init.d/redis_6379
chmod 755 /etc/init.d/redis_6379
##########################
# Register Redis service #
##########################
chkconfig --add redis_6379
#######################
# Start Redis service #
#######################
service redis_6379 start