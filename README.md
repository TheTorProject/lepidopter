# lepidopter - OONI powered Raspberry Pi image

## Description
The generic lepidopter image build script using the debootstap method.
The image provides a ready to run
[ooniprobe](https://github.com/TheTorProject/ooni-probe) installation.

## Using vagrant

If you a vagrant type of person you can just run:

```
vagrant up
```

Then you should have the image good to go inside your current working directory.

## Install required packages (Debian)
```
apt-get install vmdebootstrap
```

## Building lepidopter image
Run the main build script:
```
./lepidopter-vmdebootstrap_build.sh
```

## Copying lepidopter image to the SD Card:

```
dd if=path_of_your_image.img of=/dev/diskX bs=1m
```

[Detailed documentation](http://elinux.org/RPi_Easy_SD_Card_Setup#SD_card_setup) 
on how to flash/copy lepidopter Raspberry Pi image to your SD card from different OS.

Lepidopter image default username/password:

```
username: lepidopter
password: lepidopter
```

## Testing image with QEMU
.. ..

<!--- TODO: Create your own kernel how-to --->
Requires a kernel image, build your 
[own](http://www.cnx-software.com/2011/10/18/raspberry-pi-emulator-in-ubuntu-with-qemu) 
or use cnxsoft's [zImage_3.1.9](http://dl.dropbox.com/u/45842273/zImage_3.1.9)

1) Run lepidopter image in QEMU and redirect SSH connections from host port 2222 
to SSH port on the guest:

```
qemu-system-arm -M versatilepb -cpu arm1136-r2 -hda lepidopter.img -kernel zImage_3.1.9 \
-m 256 -append "root=/dev/sda2" -redir tcp:2222::22
```

2) You can now connect to lepidopter SSH (use default password lepidopter):

```
ssh -P 2222 root@localhost
```

#### Read this before running ooniprobe!

Running ooniprobe is a potentially risky activity. This greatly depends on the
jurisdiction in which you are in and which test you are running. It is
technically possible for a person observing your internet connection to be
aware of the fact that you are running ooniprobe. This means that if running
network measurement tests is something considered to be illegal in your country
then you could be spotted.

Futhermore, ooniprobe takes no precautions to protect the install target machine
from forensics analysis.  If the fact that you have installed or used ooni
probe is a liability for you, please be aware of this risk.

## Quick run ooniprobe

Performs a HTTP GET request over Tor and one over the local network and compares
 the two results using the Alexa top 1000 URLs list.

```
make lists -C /usr/share/ooni/inputs/
ooniprobe blocking/http_requests -f /usr/share/ooni/inputs/input-pack/alexa-top-1k.txt 
```

### Configuring ooniprobe

You may edit the configuration for ooniprobe by editing the configuration file
found inside of `~/.ooni/ooniprobe.conf`.

By default ooniprobe will not include personal identifying information in the
test result, nor create a pcap file. This behavior can be personalized.

## Links
* [Build script source](http://blog.kmp.or.at/2012/05/build-your-own-raspberry-pi-image)
* [OONI homepage](http://ooni.torproject.org)
* [ooniprobe documentation](https://ooni.torproject.org/docs/#using-ooniprobe)
