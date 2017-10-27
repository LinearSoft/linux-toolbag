#!/usr/bin/env bash
#
# must be run . changedb.sh <dbname> for vars to propagate to external shell
#

INVOKED="sourced"
[ "$0" = "$BASH_SOURCE" ] && INVOKED="own"

NEWDB=$1

if [ "$NEWDB" == "" ]; then
  echo "Usage:. chdb <dbame>"
  [ "${INVOKED}" = "sourced" ] && return 0 || exit 0
fi

if [ ! -f /etc/linearsoft/oracle.conf ]; then
  echo "Unable to source /etc/linearsoft/oracle.conf"
  [ "${INVOKED}" = "sourced" ] && return 1 || exit 1
fi

source /etc/linearsoft/oracle.conf

if [ ! -f ${LSOFT_ORACLE_ORAENV} ]; then
  echo "ERROR: oraenv (${LSOFT_ORACLE_ORAENV}) not found"
  [ "${INVOKED}" = "sourced" ] && return 1 || exit 1
fi

if [ "${LSOFT_ORACLE_RAC}" = "yes" ]; then
  #FIND NODE NUMBER
  NODE_NUMBER=`cat /etc/oratab | grep +ASM | awk -F: '{print substr($1,5,3)}'`
  if [ -z "${NODE_NUMBER}" ]; then
    echo "ERROR: Unable to determine node number"
    [ "${INVOKED}" = "sourced" ] && return 2 || exit 2
  fi
  if [ "$NEWDB" = "asm" ]; then
    NEWDB="+ASM${NODE_NUMBER}"
  fi

  GRID_HOME=`dbhome +ASM${NODE_NUMBER}`
  if [ ! -d ${GRID_HOME} ]; then
    echo "ERROR: Unable to determine grid home"
    [ "${INVOKED}" = "sourced" ] && return 2 || exit 2
  fi
fi

dbcheck=`cat /etc/oratab | grep -E -v '^\#' | grep -E -v '^\w*$' | awk -F":" '{print $1}' | grep $NEWDB`
if [ "$NEWDB" != "$dbcheck" ]; then
  echo "ERROR: $NEWDB is not a vaild DB ($dbcheck)"
  [ "${INVOKED}" = "sourced" ] && return 2 || exit 2
fi

ORG_LD_LIB="${LD_LIBRARY_PATH}"
ORG_CLASSPATH="${CLASSPATH}"

export ORAENV_ASK=NO
export ORACLE_SID=$NEWDB
source ${LSOFT_ORACLE_ORAENV}

ORACLE_UNQNAME=${NEWDB}
TNS_ADMIN=$ORACLE_HOME/network/admin
ORA_NLS11=$ORACLE_HOME/nls/data
ORACLE_PATH=~/sql:$ORACLE_HOME/rdbms/admin
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib:$ORACLE_HOME/network/jlib

if [ "${LSOFT_ORACLE_RAC}" = "yes" ]; then
  if [ "$NEWDB" != "+ASM${NODE_NUMBER}" ]; then
      NEWDB=${NEWDB}${NODE_NUMBER}
  fi
  export ORACLE_SID=${NEWDB}
  TNS_ADMIN=${GRID_HOME}/network/admin
fi

export ORACLE_UNQNAME TNS_ADMIN ORA_NLS11 ORACLE_PATH CLASSPATH

#Using LD_LIBRARY_PATH or CLASSPATH as root can be problematic
if [ "$EUID" -eq 0 ]; then
  if [ -z "${ORG_LD_LIB}" ]; then
    unset LD_LIBRARY_PATH
  else
    LD_LIBRARY_PATH="${ORG_LD_LIB}"
    export LD_LIBRARY_PATH
  fi
  if [ -z "${ORG_CLASSPATH}" ]; then
    unset CLASSPATH
  else
    CLASSPATH="${ORG_CLASSPATH}"
    export CLASSPATH
  fi
fi
