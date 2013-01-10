#!/bin/bash
# Author: Junxian Huang (hjx@eecs.umich.edu) 
#Compile and deploy for MLab servers
node=nodeList
count=0

#update nodeList
#wget http://ks.measurementlab.net/mlab-host-ips.txt
#cat mlab-host-ips.txt | grep "^mlab" | awk -F, '{print $1}' > nodeList

if [ $1 = "-c" ]; then
	./compile.sh

elif [ $1 = "-d" ]; then
	for n in `cat $node`
	do
	#	if [ $n = "mlab3.atl01.measurement-lab.org" ];then
	#		echo "this one"
	#	else
	#		continue
	#	fi
		((count += 1))
		if [ $n = "mobiperf.com" ]; then
			user="hjx"
			port=22
			echo "For mobiperf.com, you need to go to server and do bash end.sh => bash start.sh because need to type in password for sudo, not for Mlab nodes"
			ip=`dig +short $n`
		else
			user="michigan_1"
			port=806
			n=1.michigan.$n
			# ip=`dig +short @alfred.cs.princeton.edu $n` # query alfred.cs.princeton.edu if $n fails
			ip=`dig +short $n`
		fi

		# ping=`ping -c 2 -W 2 $ip | grep " 0\% packet loss" | wc -l`
		ping=`ping -c 2 -W 2 $ip | grep " 0\% packet loss" | wc -l`
		if [ $ping = "1" ]; then
		    echo "###############################"
			echo "$count: $n ($ip)  on"
		else
		    echo "###############################"
			echo "$count: $n ($ip) off"
			continue
		fi
		echo "Deploy"
		if [ $2 = "-e" ]; then
			ssh -o "StrictHostKeyChecking no" -p $port -l $user $ip 'bash ~/mobiperf/end.sh'
	        elif [$2 = "-r"]; then
	                ssh -o "StrictHostKeyChecking no" -p $port -l $user $ip 'bash ~/mobiperf/end.sh'
			ssh -o "StrictHostKeyChecking no" -p $port -l $user $ip 'bash ~/mobiperf/start.sh' &
		elif [ $2 = "-i" ]; then
			ssh -o "StrictHostKeyChecking no" -p $port -l $user $ip 'sudo yum -y install java'
		else
			ssh -o "StrictHostKeyChecking no" -p $port -l $user $n 'mkdir ~/mobiperf'
			scp -o "StrictHostKeyChecking no" -P $port  -r mlab/* $user@$ip:~/mobiperf
			#first terminate
			ssh -o "StrictHostKeyChecking no" -p $port -l $user $ip 'bash ~/mobiperf/end.sh'
			ssh -o "StrictHostKeyChecking no" -p $port -l $user $ip 'bash ~/mobiperf/start.sh' &
		fi
		echo $n " ($ip) done"
	done
elif [ $1 = "-t" ];then
        ps aux | grep "measurement-lab.org" | awk '{system("sudo kill -9 " $2);}'
        ps aux | grep "mobiperf.com" | awk '{system("sudo kill -9 " $2);}'
        ps aux | grep "michigan_1" | awk '{system("sudo kill -9 " $2);}'
else
	echo "Usage: compile -c; deploy -d; terminate remotely -d -e; restart all service -d -r; install java -d -i; kill all local process -t"
fi
