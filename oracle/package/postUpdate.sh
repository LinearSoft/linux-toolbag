#!/usr/bin/env bash
#This file is only sourced by it's parent postUpdate script (Shebang line is for reference only)

${LSOFT_TOOLBAG_BASE}/shared/updateConf.sh ${LSOFT_TOOLBAG_BASE}/oracle/package/oracle.conf /etc/linearsoft/oracle.conf
source /etc/linearsoft/oracle.conf

chmod +x ${LSOFT_TOOLBAG_BASE}/oracle/bin/*
chmod +x ${LSOFT_TOOLBAG_BASE}/oracle/systemd/*.sh

cp -a ${LSOFT_TOOLBAG_BASE}/oracle/systemd ${LSOFT_TOOLBAG_BASE}/oracle/package/systemd-org

source ${LSOFT_TOOLBAG_BASE}/oracle/package/update-systemd.sh
