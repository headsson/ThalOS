#!/bin/bash
# Restore all SUID/SGID files/directories to their original permissions

while read line
do
	echo "Setuid $line"
	chmod u+s $line
done < /root/setup/perm.4000

while read line
do
	echo "Setgid $line"
	chmod g+s $line
done < /root/setup/perm.2000
