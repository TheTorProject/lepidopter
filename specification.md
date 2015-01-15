# Lepidopter 0.1 release

* It should be based on debian wheezy.

* Provide a script for building the raspberry pi image.

* Offer the .img(s) as a download on ooni.torproject.org.

* Provide instructions on how to burn the image to your raspberry pi.

* It should come with the latest ooniprobe pre-installed.

* It should come with updated inputs and geoip files.

* When it connects to the network it should re-generate the test deck that is
  used for scanning (and possibly also update the cronjob)
  see: http://askubuntu.com/questions/258580/how-to-run-a-script-every-time-internet-connects

* The build script should also support configuring a tor hidden service that
  allows ssh access to some set of keys.

## Cronjobs

* Update the inputs every week.

* Check for ooniprobe updates every week.

* Run ooniprobe with the configured deck every day.

* Every week it should run oonireport to identify reports that have already
  been submitted to the collector and delete the ones already submitted from
  filesystem and try to re-submit the ones that have not been submitted.
  note: if the not submitted reports are empty it should just trash the files.
  note2: make sure to also adjust ~/.ooni/reporting.yml so that the reports
         deleted are no longer there.


# Lepidopter future releases

In future releases when the raspberry pi first boots up it will setup a WPA
encrypted wifi network with a default password.
The SSID shall contain the string "OONI" and it will be a captive portal that
redirects any connection on the local network to a setup wizard page (or the
web GUI if it's already configured).

See below for details on the setup wizard and web GUI.

## Setup wizard

This will be displayed only the first time the probe is setup. It will guide
the user through configuring the following setting from a web interface:

* The WPA password and password for accessing the admin interface (perhaps they
  could both be the same?)

* If the probe should also expose a tor hidden service that grants OONI devs
  remote access.

* If the Web GUI should also be exposed as a Tor Hidden Service (should this HS
  address be the same as the one above?).

* What types of measurements should be run with a description of each test and
  their associated inputs.

When the wizard is complete it will provide a summary of the configured options.
If the user has chosen to enable Tor Hidden Service remote administration it will
also print out the tor hidden service address and the list of authorized keys.
The user may add their own key or remove some keys from the list.

When they click save they will be redirected to the Web GUI.

## Web GUI

This will be shown every time a user logs into the raspberry pi Web GUI.

It will expose the following functionality.

* List of measurements run so far with timestamps and test type.

* The HS address of ssh and/or web GUI.

* The list of authorized ssh keys.

