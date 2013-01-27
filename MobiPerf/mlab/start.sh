#!/bin/bash
#this script needs to be run from the current directory

cd ~/mobiperf

for i in Downlink Uplink ServerConfig
do
	echo "running $i"
	sudo java -Xmx128M -jar $i.jar &
        sleep 1
done

port=$(sudo netstat -atup | grep "LISTEN" | wc -l)
if [ $port != 3 ];then
	echo "Error when start the thread"
else
	echo "Success deploying and running server"
fi
