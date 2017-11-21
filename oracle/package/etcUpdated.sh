#!/usr/bin/env bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}

LSOFT_ETC_BASE=/etc/linearsoft
LSOFT_TOOLBAG_BASE=/opt/linearsoft/toolbag

if [ ! -f /etc/linearsoft/toolbag.conf ]; then
  echo "Unable to located toolbag.conf"
  exit 1
fi

if [ ! -f /etc/linearsoft/oracle.conf ]; then
  echo "Unable to located oracle.conf"
  exit 1
fi

source /etc/linearsoft/toolbag.conf
source /etc/linearsoft/oracle.conf

rm -rf ${LSOFT_TOOLBAG_BASE}/oracle/systemd
cp -a ${LSOFT_TOOLBAG_BASE}/oracle/package/systemd-org ${LSOFT_TOOLBAG_BASE}/oracle/systemd

source ${LSOFT_TOOLBAG_BASE}/oracle/package/update-systemd.sh