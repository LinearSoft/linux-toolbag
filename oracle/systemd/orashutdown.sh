#!/bin/sh
#
# Slightly modified Oracle shutdown script
# it is meant to shutdown oracle services that systemd incorrectly thinks are stopped
# due to them being restarted manually
###
###################################
#
# usage: orashutdown $LISTENER_DB_SID
#
# Note:
# Use ORACLE_TRACE=T for tracing this script.
#
#####################################

if [ ! -f /etc/linearsoft/toolbag.conf ]; then
  echo "Unable to locate LinearSoft toolbag conf file"
  exit 1
fi
source /etc/linearsoft/toolbag.conf
source ${LSOFT_TOOLBAG_BASE}/oracle/systemd/init-db.sh

ORACLE_HOME_LISTNER=${ORACLE_HOME}
unset ORACLE_HOME
unset ORACLE_SID

# The  this to bring down Oracle Net Listener
if [ ! $ORACLE_HOME_LISTNER ] ; then
  echo "ORACLE_HOME_LISTNER is not SET, unable to auto-stop Oracle Net Listener"
else
  # Set the ORACLE_HOME for the Oracle Net Listener, it gets reset to
  # a different ORACLE_HOME for each entry in the oratab.
  ORACLE_HOME=$ORACLE_HOME_LISTNER ; export ORACLE_HOME

  # Stop Oracle Net Listener
  if [ -f $ORACLE_HOME_LISTNER/bin/tnslsnr ] ; then
    ps -ef | grep -i "[t]nslsnr" > /dev/null
    if [ $? -eq 0 ]; then
      echo "$0: Stoping Oracle Net Listener"
      $ORACLE_HOME_LISTNER/bin/lsnrctl stop
    else
        echo "Oracle Net Listener not running."
    fi
  else
    echo "Failed to auto-stop Oracle Net Listener using $ORACLE_HOME_LISTNER/bin/tnslsnr"
  fi
fi

# Set this in accordance with the platform
ORATAB=/etc/oratab
if [ ! $ORATAB ] ; then
  echo "$ORATAB not found"
  exit 1;
fi

# Stops an instance
stopinst() {
  ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
  if [ "$ORACLE_SID" = '*' ] ; then
    ORACLE_SID=""
  fi

  ###Check if DB is running
  ps -ef | grep -i "[p]mon_${ORACLE_SID}" > /dev/null
  if [ ! $? -eq 0 ]; then
    echo "${INST} \"${ORACLE_SID}\" not running."
    return 1
  fi

# Called programs use same database ID
  export ORACLE_SID
  ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
# Called scripts use same home directory
  export ORACLE_HOME
# Put $ORACLE_HOME/bin into PATH and export.
  PATH=$ORACLE_HOME/bin:${SAVE_PATH} ; export PATH
# add for bug 652997
  LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${SAVE_LLP} ; export LD_LIBRARY_PATH
  PFILE=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora

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

  case $VERSION in
    "6")  sqldba command=shutdown ;;
    "internal")  $SQLDBA <<EOF
connect internal
shutdown immediate
EOF
     ;;
     *)  $SQLDBA <<EOF
connect / as sysdba
shutdown immediate
quit
EOF
     ;;
  esac

  if test $? -eq 0 ; then
    echo "${INST} \"${ORACLE_SID}\" shut down."
  else
    echo "${INST} \"${ORACLE_SID}\" not shut down."
  fi
}

#
# Loop for every entry in oratab file and and try to shut down
# that ORACLE
#

cat $ORATAB | while read LINE
do
  case $LINE in
  \#*)                ;;        #comment-line in oratab
  *)
  ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
  if [ "$ORACLE_SID" = "" ]; then #Empty line
      continue
  fi
  if [ "$ORACLE_SID" = '*' ] ; then
      # NULL SID - ignore
      ORACLE_SID=""
      continue
  fi
  TMP=`echo $ORACLE_SID | cut -b 1`
  if [ "${TMP}" != '+' ]; then
    INST="Database instance"
    ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
    echo "Processing $INST \"$ORACLE_SID\""
    stopinst
  fi
  ;;
  esac
done

#
# Following loop shuts down 'ASM Instance[s]'
#

cat $ORATAB | while read LINE
do
  case $LINE in
    \#*)                ;;        #comment-line in oratab
    *)
    ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
    if [ "$ORACLE_SID" = "" ]; then
      continue
    fi
    if [ "$ORACLE_SID" = '*' ] ; then
      # NULL SID - ignore
      ORACLE_SID=""
      continue
    fi
    TMP=`echo $ORACLE_SID | cut -b 1`
    if [ "${TMP}" = '+' ]; then
      INST="ASM instance"
      ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
      echo "Processing $INST \"$ORACLE_SID\""
      stopinst
    fi
  ;;
  esac
done


