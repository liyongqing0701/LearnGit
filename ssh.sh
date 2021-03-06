#!/bin/bash

DIR=$(dirname `readlink -f $0`)
. $DIR/testing.conf
SSHCONF="-F $DIR/ssh_config"

if [ $# == 0 ]
then
echo "$0 <host>"
exit 1
fi

host=$1
echo "$host" | grep -q "^\([0-9]\+\.\|[0-9a-fA-F]\+:\).*"
if [ $? -eq 0 ]
then
# assume we got an ip address
ip=$host
else
pos='$1'
echo "$host" | grep -q ".*1$"
if [ $? -eq 0 ]
then
# {host}1, use second address
pos='$2'
host=`echo "$host" | sed -n -e "s/1$//p"`
fi
ip="`echo $HOSTNAMEIPV4 | sed -n -e "s/^.*${host},//gp" | awk -F, "{ print ${pos} }" | awk '{ print $1 }'`"
if [ -z $ip ]
then
echo "Host '$host' unknown"
exit 1
fi
fi

shift
exec ssh $SSHCONF -q root@$ip $@

