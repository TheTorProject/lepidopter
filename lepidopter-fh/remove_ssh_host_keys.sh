#!/bin/bash
# Re-enables at first boot after regeneration of ssh host keys
update-rc.d ssh disable
rm -f /etc/ssh/ssh_host*
chmod +x /etc/init.d/regenerate_ssh_host_keys
update-rc.d regenerate_ssh_host_keys defaults
history -c
