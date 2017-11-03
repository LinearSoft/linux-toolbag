#!/bin/sh
#
#Modified to only stop the DB SID provided
#it will not stop the listener TO ONLY BE USED with systemd
###
###################################
# 
# usage: dbshut $DB_SID
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

