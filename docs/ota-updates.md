# Over The Air Unattended Updates (OTAU2)

This document enumerates some of the approaches and FLOSS software that could
be used to deploy OTAU2 to Lepidopter distribution.

## Requirements

A list of Lepidopter's OTAU2 requirements:

* Atomic software release update

* On failure, deploy previous working bootloader, kernel
    configuration, and filesystems

* On success, deploy newest working bootloader, kernel
    configuration, filesystems and reboot (if needed) for the changes to take
    effect

* Update of bootloader, kernel and configuration data, and filesystems

* Support for signing of images and verification of images on
    installation

* Support for a self-hosted deployment server

* Enable/disable a specific feature and apply/rollback system updates
    incrementally rather than through a complete OS update that
    replaces the filesystem

* [OPTIONAL] Support for different host roles with a specific configuration set
    applicable only to specific hosts or groups (eg: partner probes)

## Available tools

Before reading any further you should go through the excellent study of
software update management on [device-side software update strategies for
automotive grade linux]
(https://lists.linuxfoundation.org/pipermail/automotive-discussions/2016-May/002061.html)
and the related discussion in [OSTreee manual]
(https://ostree.readthedocs.io/en/latest/manual/related-projects/).

The following software could potentially used to implement and deploy OTAU2
updates.

### OSTree

[WIP EVALUATION]

### SWUpdate

[WIP EVALUATION]
