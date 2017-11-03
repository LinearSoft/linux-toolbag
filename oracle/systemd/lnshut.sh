#!/bin/sh
#
#Modified to only start the listener associated with the
#ORACLE_HOME of the passed ORACLE_SID this script TO ONLY BE USED with systemd
###
###################################
# 
# usage: lnshut $ORACLE_SID
#
#
# Note:
# Use ORACLE_TRACE=T for tracing this script.
#
# On all UNIX platforms except SOLARIS
# ORATAB=/etc/oratab
#
#####################################

if [ ! -f /etc/linearsoft/toolbag.conf ]; then
  echo "Unable to locate LinearSoft toolbag conf file"
  exit 1
fi
source /etc/linearsoft/toolbag.conf
source ${LSOFT_TOOLBAG_BASE}/oracle/systemd/init-db.sh

###Stop listener
if [ ! -x $ORACLE_HOME/bin/tnslsnr ] ; then
  echo "Failed to auto-stop Oracle Net Listener using $ORACLE_HOME/bin/tnslsnr"
  exit 1
fi

echo "$0: Stoping Oracle Net Listener"
$ORACLE_HOME/bin/lsnrctl stop
