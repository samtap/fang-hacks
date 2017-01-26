# Fang Hacks

Collection of modifications for the XiaoFang WiFi Camera

## General usage

Download an sd-card image from the [releases](https://github.com/samtap/fang-hacks/releases) page or follow the manual steps below.

**Updating**: If you've applied the hack before and are updating to a newer release, the web-interface will not allow you to apply the hack since (older versions of) scripts are already on the device. Make sure to click the Update button on the status page before rebooting!! This will copy all relevant files to the device, overwriting the previous version.

### 1. Prepare an sd-card with two partitions.
The first partition on the device must be a vfat partition. It will only contain some small scripts so 100MiB should be more than enough.
The second partition must be an ext2 partition and will contain all other files.

### 2. Copy bootstrap folder and snx_autorun.sh
The bootstrap folder contains CGI scripts for the embedded Boa webserver. The ```snx_autorun.sh``` script is the entry-point for enabling the hacks.

Both must be copied to the vfat partition.

### 3. Copy data folder
The data folder must be copied to the ext2 partition.

### 4. Place sd-card in device
Boot the device without sd-card, wait until the blue led stops flashing. The device will automatically run ```snx_autorun.sh``` when the sd-card is inserted. Do not boot the device with the card inserted and then re-insert it, to prevent it from being mounted incorrectly (mmcblk1 instead of mmcblk0).

### 5. Enable hacks
When you visit ```http://device-ip/cgi-bin/status``` you should now be presented with a status page. If you get a '404 Not Found' page, the ```snx_autorun.sh``` script didn't run. You can visit ``http://device-ip/cgi-bin/hello.cgi`` to check if the sd-card is mounted correctly. 

Click 'Apply' to enable the hacks. 

## Background
The modifications aim to be as least intrusive as possible. Currently there's no known recovery methode, i.e. an image to flash to the device when it doesn't boot, though you can solder wires to it and get access to a serial console. When it still boots and mounts vfat partitions automatically, limited recovery options are available through snx_autorun.sh and config files in the bootstrap folder. 
As long as you don't completely disable the cloud apps (DISABLE_CLOUD=1), you can always revert to original behavior by simply removing the sd-card. When cloud apps are disabled and no boot scripts are found on the sd-card (i.e. when it's not inserted), nothing is started when the device boots so you will not be able to access it through the web-interface, telnet, etc.

Small system modifications are made when you click Apply on the status page:

- A modified sdcard hotplug script is placed on the device to automatically mount ext2 volumes.
- Modified rc.local and rcS scripts are placed in /etc/init.d to enable hacks when the device is rebooted. It also disables copying original files from /root/etc_default to prevent overwriting changes to files in /etc. This poses a risk so always be extra careful when editing files in /etc
- The fang_hacks.sh script and cfg file are placed in /etc.

## Hacks
When the status page shows the hacks have been applied successfully, the following features are available:
- The data partition can be extended to use all the space available, in case you installed a pre-created sdcard image.
- You can switch the network mode to WiFi Client or HotSpot mode, completely disable the cloud apps and have a RTSP server running in 15 seconds after applying power. 
- You can place any binaries, scripts etc. you need in the data folder on the sd-card. The device only has limited space available on internal flash so you don't risk running out of space.
- A busybox build is provided with many applets available such as telnetd, ftpd, netcat.
- A dropbear build is provided with support for SSH/SFTP. Use sshfs to access all data on the sdcard remotely.
- Scripts placed in data/etc/scripts will be automatically executed after the device boots.

## Services
By default the following services are enabled:
- FTP server
- RTSP server (url: ```rtsp://device-ip/unicast```)
- Telnetd on port 2323 (user: root, password: ismart12)
- Dropbear SSH/SCP/SFTP 
- A script controls the IR filter and LEDs
- Manage the device via the status page ```http://device-ip/cgi-bin/status```

## Support
For questions, suggestions or just general discussion, please join #fanghacks on irc.freenode.net
