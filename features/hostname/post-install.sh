#!/bin/bash

echo 'pickled' >work/etc/hostname
sed -i 's/raspberrypi/pickled/' work/etc/hosts

rm work/etc/os-release.orig
cat <<_EOF_ >work/etc/os-release
PRETTY_NAME="Pickled GNU/Linux 1 (nissa)"
NAME="Pickled GNU/Linux"
VERSION_ID="1"
VERSION="1 (nissa)"
ID=pickled
ID_LIKE=debian
ANSI_COLOR="1;31"
HOME_URL="https://github.com/telesammans/pickled"
SUPPORT_URL="https://github.com/telesammans/pickled"
BUG_REPORT_URL="https://github.com/telesammans/pickled"
_EOF_

echo 'Pickled GNU/Linux 1 \n \l' >work/etc/issue
echo '' >>work/etc/issue
echo 'Pickled GNU/Linux 1' >work/etc/issue.net
rm work/etc/issue.orig
rm work/etc/issue.net.orig

