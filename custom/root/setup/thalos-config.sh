#!/bin/bash
# thalos-config, part of the thalos raspbian dist available at https://github.com/headsson/ThalOS
# This script is inspired by and borrows code from Alex Bradbury's raspi-config (http://github.com/asb/raspi-config)

config_timezone() {
	dpkg-reconfigure tzdata
}

config_keyboard() {
	# Copied from raspi-config
	dpkg-reconfigure keyboard-configuration &&
	printf "Reloading keymap. This may take a short while\n" &&
	invoke-rc.d keyboard-setup start
}

config_hostname() {
	# Copied/modified from raspi-config
 	CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
 	echo -n "New hostname: "
 	read NEW_HOSTNAME
 	if [ $? -eq 0 ]; then
		echo $NEW_HOSTNAME > /etc/hostname
		sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
	fi
}

do_expand_rootfs() {
	# Copied/modified from raspi-config
	if ! [ -h /dev/root ]; then
		echo "/dev/root does not exist or is not a symlink. Don't know how to expand"
		return 0
	fi

	ROOT_PART=$(readlink /dev/root)
	PART_NUM=${ROOT_PART#mmcblk0p}
	if [ "$PART_NUM" = "$ROOT_PART" ]; then
		echo "/dev/root is not an SD card. Don't know how to expand"
		return 0
	fi

	# NOTE: the NOOBS partition layout confuses parted. For now, let's only 
	# agree to work with a sufficiently simple partition layout
	if [ "$PART_NUM" -ne 2 ]; then
		echo "Your partition layout is not currently supported by this tool. You are probably using NOOBS, in which case your root filesystem is already expanded anyway."
		return 0
	fi

	LAST_PART_NUM=$(parted /dev/mmcblk0 -ms unit s p | tail -n 1 | cut -f 1 -d:)

	if [ "$LAST_PART_NUM" != "$PART_NUM" ]; then
		echo "/dev/root is not the last partition. Don't know how to expand"
		return 0
	fi

	# Get the starting offset of the root partition
	PART_START=$(parted /dev/mmcblk0 -ms unit s p | grep "^${PART_NUM}" | cut -f 2 -d:)
	[ "$PART_START" ] || return 1
	# Return value will likely be error for fdisk as it fails to reload the
	# partition table because the root fs is mounted
	fdisk /dev/mmcblk0 <<EOF
p
d
$PART_NUM
n
p
$PART_NUM
$PART_START

p
w
EOF

  # now set up an init.d script
cat <<\EOF > /etc/init.d/resize2fs_once &&
#!/bin/sh
### BEGIN INIT INFO
# Provides:          resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5 S
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting resize2fs_once" &&
    resize2fs /dev/root &&
    rm /etc/init.d/resize2fs_once &&
    update-rc.d resize2fs_once remove &&
    log_end_msg $?
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF
	chmod +x /etc/init.d/resize2fs_once &&
	update-rc.d resize2fs_once defaults &&
	if [ "$INTERACTIVE" = True ]; then
		echo "Root partition has been resized.\nThe filesystem will be enlarged upon the next reboot"
	fi
}

echo "ThalOS setup"
echo "------------"
echo "This is the first time you are logging on as root, as such this config script will run once. You can re-run this script at anytime by typing: /root/setup/thalos-config.sh"
echo ""

# Config timezone
echo -n "Current Timezone: "
cat /etc/timezone
echo -n "This is your current date/time/timezone config, change it? [Y/n] "
read answer
if [ "$answer" != "n" ]; then
	config_timezone
fi
echo ""

# Config keyboard
echo -n "Your current keyboard is: "
grep XKBLAYOUT /etc/default/keyboard |cut -d= -f2
echo -n "Do you want to change it? [Y/n] "
read answer
if [ "$answer" != "n" ]; then
	config_keyboard
fi
echo ""

# Config hostname
echo -n "Current hostname: "
cat /etc/hostname | tr -d " \t\n\r"
echo ""
echo -n "Change hostname? [Y/n] "
read answer
if [ "$answer" != "n" ]; then
	config_hostname
fi
echo ""

# Change root password
echo -n "Change root password? [Y/n] "
read answer
if [ "$answer" != "n" ]; then
	passwd
fi
echo ""

# SH Card resize
echo -n "Optimize SD Card's available disk space (highly recommended)? [Y/n] "
read answer
if [ "$answer" != "n" ]; then
	do_expand_rootfs

	echo ""
	echo "The system needs to be rebooted to finish the SD Card reallocation process"
	echo -n "Reboot now? [Y/n] "
	read answer
	if [ "$answer" != "n" ]; then
		reboot &
	else
		echo "WARNING: You should reboot as soon as possible to finish the SD Card reallocation process!"
	fi
fi
echo ""
echo "Setup complete"