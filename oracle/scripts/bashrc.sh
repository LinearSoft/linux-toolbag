#!/usr/bin/env bash
#This file is to be sourced by the user's .bashrc file (Shebang line is for reference only)
if [ -f /etc/linearsoft/toolbag.conf ]; then
  return 1
fi
source /etc/linearsoft/toolbag.conf

alias chdb=". ${LSOFT_TOOLBAG_BASE}/oracle/bind/changedb.sh"