#!/bin/bash
# This script allows to setup a ramdisk storage pool for LXD containers,
# making tests running in such containers really fast
# As we use LXD 2.0 on Travis CI, we are not able to use the storage API
service lxd stop
# Move /var/lib/lxd
mv /var/lib/lxd /var/lib/lxd.bak
# Create a ramdisk to replace /var/lib/lxd
mkdir -p /var/lib/lxd
mount -t tmpfs -o size=6g tmpfs /var/lib/lxd
# Restore LXD files into the ramdisk
mv /var/lib/lxd.bak/* /var/lib/lxd/
service lxd start
df -h
