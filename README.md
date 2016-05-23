# Lepidopter - OONI powered Raspberry Pi image

## Description
The generic lepidopter image build script using the vmdebootstap method.
The image provides a ready to run
[ooniprobe](https://github.com/TheTorProject/ooni-probe) powered Debian jessie
distribution.

### Lepidopter repository tree structure

```
.
├── conf
│   └── tor-pt.conf Tor bridges and pluggable transports configuration file
├── customize       customize script used to customize lepidopter image
├── images          where the build Lepidopter images created
├── lepidopter-fh   Lepidopter image filesystem hierarchy
│   ├── cleanup.sh  cleanup script
│   ├── etc
│   │   ├── apt
│   │   │   └── apt.conf.d
│   │   │       └── 02compress-indexes
│   │   ├── cron.daily      daily cronjobs
│   │   │   ├── remove_upl_reports
│   │   │   ├── run_ooniprobe_deck
│   │   │   └── upload_reports
│   │   ├── cron.weekly     weekly cronjobs
│   │   │   ├── remove_inc_reports
│   │   │   ├── update_deck
│   │   │   └── update_ooniprobe
│   │   ├── default
│   │   │   └── lepidopter
│   │   ├── dpkg
│   │   │   └── dpkg.cfg.d
│   │   │       └── 01_nodoc
│   │   ├── init.d
│   │   │   └── regenerate_ssh_host_keys
│   │   ├── logrotate.d
│   │   │   └── ooniprobe
│   │   ├── motd.head                           Lepidopter MOTD ASCII logo
│   │   ├── network
│   │   │   └── if-up.d
│   │   │       └── run_oonideckgen
│   │   ├── ooniprobe
│   │   │   ├── ooniconfig.sh
│   │   │   ├── oonideckconfig
│   │   │   ├── ooniprobe.conf
│   │   │   └── oonireport.conf
│   │   └── update-motd.d
│   │       └── 50-lepidopter
│   ├── opt
│   │   └── ooni
│   │       ├── decks
│   │       ├── remove-inc-reports.sh
│   │       ├── remove-upl-reports.sh
│   │       ├── reports
│   │       ├── run-ooniprobe.sh
│   │       ├── update-deck.sh
│   │       ├── update-ooniprobe.sh
│   │       └── upload-reports.sh
│   ├── remove_ssh_host_keys.sh
│   ├── setup-ooniprobe.sh
│   └── var
│       └── log
│           └── ooni
├── lepidopter-vmdebootstrap_build.sh   main lepidopter vmdebootstrap script
├── scripts         external scripts 
│   └── setup.sh    install dependencies needed to create and build the image 
├── LICENSE.md
├── README.md       you are currently reading it
├── scripts
│   ├── lepidopter-sign.sh
│   └── setup.sh
└── Vagrantfile
```

### Supported Hardware

The image is targeted mainly for the Raspberry Pi devices currently all
hardware variant are being supported (armel architecture).
It should be fairly easy to create the same image for different
architectures, and OS distributions.

Supported hardware (tested):
* Raspberry Pi 1 Model B
* Raspberry Pi 1 Model B+
* Raspberry Pi 2 Model B

Possible supported hardware (untested):
* Beaglebone
* Cubietruck
* Wandboard

## Installation

Clone lepidopter git repository::

```
git clone https://github.com/TheTorProject/lepidopter
```

### Using vagrant

If you a vagrant type of person you can just run:

```
vagrant up
```

Then you should have the image good to go inside your current working directory.

### Install required packages (Debian)

The latest version of vmdebootstrap package is required.
Currently (as of today 0.11-1) from Debian sid repository is needed.

Optionally you could install lepidopter dependencies via the setup script

#### Install lepidopter dependencies and run setup script

```
./scripts/setup.sh
```
To compress the image as well you should use::
```
./scripts/setup.sh --compress
```

To perform an unattended lepidopter image build you could use this in Debian::

```
DEBIAN_FRONTEND=noninteractive ./scripts/setup.sh
```

## Building lepidopter image

Run the main build script::

```
./lepidopter-vmdebootstrap_build.sh
```

## Copying lepidopter image to the SD Card

[bmaptool](https://source.tizen.org/documentation/reference/bmaptool)
way (much faster!)::

```
bmaptool copy --nobmap lepidopter-alpha-armel.img.xz of=/dev/diskX
```

Note: bmaptool can copy compressed images to SD card without the need to 
decompress first!

### Extract the image archive

The image is compressed with XZ. By default xz make the file sparse if the
decompressed data contains long sequences of binary zeros. We need to disable
the creation of sparse file since dd needs the leading to create a bootable
image. You can extract the image file with:

`xz --decompress --verbose --no-sparse lepidopter-alpha-armel.img.xz`


dd way::

```
dd if=lepidopter-alpha-armel.img of=/dev/diskX bs=1m
```

[Detailed documentation](http://elinux.org/RPi_Easy_SD_Card_Setup#SD_card_setup)
on how to flash/copy lepidopter Raspberry Pi image to your SD card from
different OS.

Lepidopter image default username/password::

```
username: lepidopter
password: lepidopter
```

**Warning** Note:
Make sure that upon first login you should change the default username/password

## Testing image with QEMU
.. ..

<!--- TODO: Create your own kernel how-to -->
Requires a kernel image, build your 
[own]
(http://www.cnx-software.com/2011/10/18/raspberry-pi-emulator-in-ubuntu-with-qemu)
or use qemu-rpi-kernel image [kernel-qemu-4.1.7-jessie]
(https://github.com/dhruvvyas90/qemu-rpi-kernel/)

0) Remove all entries except root (/) in `/etc/fstab`. You can achieve this by
mounting the image and editing `/etc/fstab` or in QEMU by appending a kernel
command line `init=/bin/bash`.

1) Run lepidopter image in QEMU and redirect SSH connections from localhost
port 2222 to SSH port of the guest:

```
qemu-system-arm -M versatilepb -cpu arm1136-r2 \
    -kernel kernel-qemu-4.1.7-jessie \
    -hda lepidopter-armel.img  -m 256 \
    -append "root=/dev/sda2 rootfstype=ext4 rw" \
    -net nic -net user,hostfwd=tcp:127.0.0.1:2222-:22
```

2) You can now connect to lepidopter SSH (default password is `lepidopter`):

```
ssh -P 2222 lepidopter@localhost
```

## Read this before running Lepidopter!

Running ooniprobe is a potentially risky activity. This greatly depends on the
jurisdiction in which you are in and which test you are running. It is
technically possible for a person observing your internet connection to be
aware of the fact that you are running ooniprobe. This means that if running
network measurement tests is something considered to be illegal in your country
then you could be spotted.

Furthermore, ooniprobe takes no precautions to protect the install target
machine from forensics analysis. If the fact that you have installed or used
ooniprobe is a liability for you, please be aware of this risk.

## Links
* [vmdebootstrap](http://liw.fi/vmdebootstrap/)
* [OONI homepage](https://ooni.torproject.org)
* [ooniprobe documentation](https://ooni.torproject.org/docs/#using-ooniprobe)
