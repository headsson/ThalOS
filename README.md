# ThalOS
*The secure raspberry pi router/firewall project*

## Introduction
ThalOS a complete operating system based on the hardfp Raspbian distribution for the Raspberry Pi platform. The goal of ThalOS is to be an extremely small and secure system for use of the Raspberry Pi as a router/firewall. The entire system is around 500 MB and is basically a debootstrapped raspbian installation with some special configurations from raspbian, some tweaked setup and a custom kernel. See the wiki for more documentation. This repo contains all the modified files used in the making of the distribution.

## Quickstart
 - Download the latest image from [Sourceforge](https://sourceforge.net/projects/thalos/files/?source=navbar)
 - Write image to your SD Card
  - [Windows Instructions][1]
  - [OS X Instructions][2]
  - [Linux Instructions][3]
 - Boot Raspberry PI
 - Login as root with password: **raspberry**
  - You can login via Console
  - or login via SSH: **192.168.1.254**
 - When you login, a "finalizing setup script" will be executed. Run through the final setup (make sure you exapand the filesystem at the end)
 - Configure your network by editing **/etc/network/interfaces**
 - Make sure your system is up to date by running: **apt-get update && apt-get upgrade**
 - Congratulations! You can now start configuring your router/firewall

## Documentation
All documentation is located at the [wiki][4]

## Philosophy
The ThalOS project is designed to be as small (stripped from unnecessary files and features) and secure as possible with a focus on being a router. As such, some design decisions have been made which may seem extreme (like a custom locked down kernel). **You should read the [design part][5] on the wiki for more information on how this system has been built.**

  [1]: http://elinux.org/RPi_Easy_SD_Card_Setup#Flashing_the_SD_Card_using_Windows
  [2]: http://elinux.org/RPi_Easy_SD_Card_Setup#Flashing_the_SD_card_using_Mac_OSX
  [3]: http://elinux.org/RPi_Easy_SD_Card_Setup#Flashing_the_SD_Card_using_Linux_.28including_on_a_Pi.21.29
  [4]: https://github.com/headsson/ThalOS/wiki
  [5]: https://github.com/headsson/ThalOS/wiki/Design