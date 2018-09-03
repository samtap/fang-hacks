# Chuangmi 720p hack

Collection of modifications for the Xiaomi Chuangmi 720p WiFi Camera

![Chuamngmi Camera](chuangmi.jpg?raw=true "Chuangmi 720P camera")

Originally forked from fang-hacks, but now mostly a place to hold a workable bootstrap

## Reason

From the factory, the camera can be found and set up by the Xiaomi MiHome app. It will then show a feed and provide talkback via the app, but this can raise privacy concerns, as the information is being sent via a server in China. Below is a series of steps which enables a local RTSP stream, and removes the reliance on an external connection.

## Step 1: Initial setup

Initial setup is performed using the Xiaomi MiHome app. This may not be necessary in future releases

1. Install the app on an Android/iOS device
2. Set up your account
3. Add a camera
4. Follow the onscreen steps until your camera is successfully added
5. View the camera in the app and go to settings - **do not update the firmware** (it can make things harder)
6. Make a note of the IP address of the camera

## Step 2: Telnet access, image rollback

A custom image which allows root access is required.

1. Format a microSD card to FAT32
2. Download tf_recovery.img
3. Copy tf_recovery.img to the root directory of the SD card
4. Unplug camera
5. Insert SD card
6. Plug in camera
7. wait for about 2 minutes until lights go blue
8. telnet 192.168.1.xx (camera IP as listed in the MiHome app) username: root, no password

## Step 3: Load custom software

Custom software including RTSP server, SSH and Samba. This software was developed for the Mijia 720p camera, but appears to work here as well

1. Download the latest release of mijia-720p-hack.zip from https://github.com/ghoost82/mijia-720p-hack/releases/latest/ (0.95 at time of writing)
2. Unplug camera
3. Eject SD card from camera
4. Unzip the contents of mijia-720p-hack/sdcard/ to the root directory of the SD card
5. Make any required changes to mijia-720p-hack.cfg
5. Insert SD card into camera
6. Plug in camera
7. Wait for camera light to go solid blue. This may take a couple of minutes.

Test it is working by going to http://192.168.1.xx (camera IP again) in your browser (assuming HTTP server is enabled) or using SSH to connect


## General usage

Telnet server
-------------

If enabled the telnet server is on port 23.

Default login/password:

* login = root
* password = 1234qwer (unless you specified another password in **mijia-720p-hack.cfg.cfg** file)

SSH server
----------

If enabled the SSH server is on port 22.

Default login/password:

* login = root
* password = 1234qwer (unless you specified another password in **mijia-720p-hack.cfg.cfg** file)

RTSP Server
-----------

If enabled the RTSP server is on port 554.

You can connect to live video stream (currently only supports 720p) on:

`rtsp://your-camera-ip/live/ch00_0`

For stability reasons it is recommend to disable cloud services while using RTSP.

FTP server
----------

If enabled the FTP server is on port 21.

There is no login/password required.

Samba
-----

If enabled the `MIJIA_RECORD_VIDEO` directory can be accessed via CIFS.
The share is readable by everyone.

Default login/password for read/write access:
* login = root
* password = 1234qwer (unless you specified another password in **mijia-720p-hack.cfg.cfg** file)


Cloud Services
--------------

Disabling the cloud services disables the following functions:

* Motion detection
* No video data or configuration with the smartphone application
* No recordings on the SD card or a remote file system

For stability reasons it is recommend to disable cloud services while using RTSP.

## License
Any files in this repo that are not already licensed (i.e. scripts and tools but *not* 3rd party binaries like busybox, dropbear et.al) are licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).
