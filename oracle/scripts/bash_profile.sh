#!/usr/bin/env bash
#This file is to be sourced by the user's .bash_profile file (Shebang line is for reference only)

if [ ! -f /etc/linearsoft/toolbag.conf ]; then
  return 1
fi

if [ ! -f /etc/linearsoft/oracle.conf ]; then
  return 1
fi

source /etc/linearsoft/toolbag.conf
source /etc/linearsoft/oracle.conf

# ---------------------------------------------------
# Oracle User App Vars (SQLPlus/etc)
# ---------------------------------------------------
PATH=$PATH:${LSOFT_TOOLBAG_BASE}/oracle/bin/
TMP=/tmp
TMPDIR=/tmp

SQLPATH=~/sql
NLS_DATE_FORMAT="${LSOFT_ORACLE_DATE_FORMAT}"

export PATH TMP TMPDIR SQLPATH NLS_DATE_FORMAT


# ---------------------------------------------------
# Oracle System Level Settings
# ---------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  THREADS_FLAG=native
  export THREADS_FLAG

  if [ -z "${LD_LIBRARY_PATH}" ]; then
    LD_LIBRARY_PATH=/lib64:/lib:/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib
    export LD_LIBRARY_PATH
  fi

  umask 022
fi


# ---------------------------------------------------
# Oracle Database Settings
# ---------------------------------------------------

CURRENT_USER=`id -u -n`
INIT_DB=${LSOFT_ORACLE_DEFAULT_DB_ORACLE}
if [ "${CURRENT_USER}" = "${LSOFT_ORACLE_USER_GRID}" ] || [ "$EUID" -eq 0 ]; then
  INIT_DB=${LSOFT_ORACLE_DEFAULT_DB_GRID}
fi

source ${LSOFT_TOOLBAG_BASE}/oracle/bin/chdb.sh ${INIT_DB}
