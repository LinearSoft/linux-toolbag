#!/usr/bin/env bash
#This file is only sourced by other systemd scripts (Shebang line is for reference only)

trap 'exit' 1 2 3

# for script tracing
case $ORACLE_TRACE in
  T) set -x ;;
esac

# Set path if path not set (if called from /etc/rc)
SAVE_PATH=/bin:/usr/bin:/etc:${PATH} ; export PATH
SAVE_LLP=$LD_LIBRARY_PATH

ORACLE_SID=$1
if [ -z $ORACLE_SID ]; then
  echo "A database SID must be provided"
  echo "usage: $0 ORACLE_SID"
  exit 1;
fi

###Locate DB Oracle Home
if [ ! -f /etc/oratab ] ; then
  echo "/etc/oratab not found"
  exit 1;
fi
ORACLE_HOME=`cat /etc/oratab | grep -m 1 -E "${ORACLE_SID}:" | awk -F ':' '{print $2}'`
if [ -z "$ORACLE_HOME" ]; then
  echo "Unable to determine Oracle Home"
  exit 1
fi
if [ ! -x "$ORACLE_HOME/bin/sqlplus" ]; then
  echo "Invalid Oracle Home: $ORACLE_HOME"
  exit 1
fi
export ORACLE_SID RACLE_HOME