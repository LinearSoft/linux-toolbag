#!/bin/sh
#
# Modified to only start the DB SID provided
# it will not start the listener TO ONLY BE USED with systemd
###
###################################
# 
# usage: dbstart $ORACLE_SID
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

PIDDIR=__PIDDIR__
PIDFILE=${PIDDIR}/oradb-${ORACLE_SID}.pid

running ()
{
  pmon=`ps -ef | grep -w "ora_pmon_$ORACLE_SID"  | grep -v grep`
  if [ "$pmon" != "" ] ; then
    return 0
  fi
  return 1
}

# Put $ORACLE_HOME/bin into PATH and export.
PATH=$ORACLE_HOME/bin:${SAVE_PATH} ; export PATH
# add for bug # 652997
LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${SAVE_LLP} ; export LD_LIBRARY_PATH
PFILE=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora
SPFILE=${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora
SPFILE1=${ORACLE_HOME}/dbs/spfile.ora

echo ""
echo "Starting up database \"$ORACLE_SID\""
date
echo ""

#Listener version check skipped

# See if it is a V6 or V7 database
VERSION=undef
if [ -f $ORACLE_HOME/bin/sqldba ] ; then
  SQLDBA=sqldba
  VERSION=`$ORACLE_HOME/bin/sqldba command=exit | awk '
    /SQL\*DBA: (Release|Version)/ {split($3, V, ".") ;
    print V[1]}'`
  case $VERSION in
    "6") ;;
    *) VERSION="internal" ;;
  esac
else
  if [ -f $ORACLE_HOME/bin/svrmgrl ] ; then
    SQLDBA=svrmgrl
    VERSION="internal"
  else
    SQLDBA="sqlplus /nolog"
  fi
fi

STATUS=1
if [ -f $ORACLE_HOME/dbs/sgadef${ORACLE_SID}.dbf ] ; then
  STATUS="-1"
fi
if [ -f $ORACLE_HOME/dbs/sgadef${ORACLE_SID}.ora ] ; then
  STATUS="-1"
fi

if running ; then
  STATUS="-1"
  echo "Warning: ${INST} \"${ORACLE_SID}\" already started."
fi

if [ $STATUS -eq -1 ] ; then
  echo "Warning: ${INST} \"${ORACLE_SID}\" possibly left running when system went down (system crash?)." >&2
  echo "Action: Notify Database Administrator." >&2
  case $VERSION in
    "6")  sqldba "command=shutdown abort" ;;
    "internal")  $SQLDBA $args <<EOF
connect internal
shutdown abort
EOF
      ;;
    *)  $SQLDBA $args <<EOF
connect / as sysdba
shutdown abort
quit
EOF
      ;;
  esac

  if [ $? -eq 0 ] ; then
    STATUS=1
  else
    echo "Error: ${INST} \"${ORACLE_SID}\" NOT started." >&2
  fi
fi

if [ $STATUS -eq 1 ] ; then
  if [ -e $SPFILE -o -e $SPFILE1 -o -e $PFILE ] ; then
    case $VERSION in
      "6")  sqldba command=startup ;;
      "internal")  $SQLDBA <<EOF
connect internal
startup
EOF
        ;;
      *)  $SQLDBA <<EOF
connect / as sysdba
startup
quit
EOF
        ;;
    esac

    if [ $? -eq 0 ] ; then
      echo ""
      echo "${INST} \"${ORACLE_SID}\" warm started."
    else
      echo ""  >&2
      echo "Error: ${INST} \"${ORACLE_SID}\" NOT started." >&2
    fi
  else
    echo ""
    echo "No init file found for ${INST} \"${ORACLE_SID}\"." >&2
    echo "Error: ${INST} \"${ORACLE_SID}\" NOT started." >&2
  fi
fi

##Store PID
PID=`ps aux | grep -w "ora_pmon_$ORACLE_SID"  | grep -v grep | awk '{print $2;}'`
echo $PID > $PIDFILE
