#!/usr/bin/env bash
#This file is to be sourced by the user's .bashrc file (Shebang line is for reference only)
if [ ! -f /etc/linearsoft/toolbag.conf ]; then
  return 1
fi
source /etc/linearsoft/toolbag.conf
source /etc/linearsoft/oracle.conf

alias chdb=". ${LSOFT_TOOLBAG_BASE}/oracle/bin/changedb.sh"

# ---------------------------------------------------
# Oracle Enterprise Manager Settings
# ---------------------------------------------------
shopt -s nocasematch
case "${LSOFT_ORACLE_EM}" in
 "yes" )
      alias emctl="${ORACLE_BASE}/middleware/oms/bin/emctl"
      alias emcli="${ORACLE_BASE}/middleware/oms/bin/emcli"
      ;;
 *)   ;;
esac