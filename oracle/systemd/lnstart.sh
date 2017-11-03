#!/bin/sh
#
#Modified to only start the listener associated with the
#ORACLE_HOME of the passed ORACLE_SID this script TO ONLY BE USED with systemd
###
###################################
# 
# usage: lnstart $ORACLE_SID
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

running() {
  pmon=`ps -ef | grep -w "$ORACLE_HOME/bin/tnslsnr"  | grep -v grep`
  if [ "$pmon" != "" ] ; then
    return 0
  fi
  return 1
}

###Start listener
if running; then
  echo "The listener is already already running"
  exit 1
fi

# Start Oracle Net Listener
if [ ! -x $ORACLE_HOME/bin/tnslsnr ] ; then
  echo "Failed to auto-start Oracle Net Listener using $ORACLE_HOME/bin/tnslsnr"
  exit 1
fi

echo "Starting Oracle Net Listener"
$ORACLE_HOME/bin/lsnrctl start

