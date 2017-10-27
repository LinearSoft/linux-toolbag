#!/usr/bin/env bash
if [ ! -f /etc/linearsoft/toolbag.conf ]; then
  return 1
fi

source ${LSOFT_TOOLBAG_BASE}/profile.d/bash-ls.sh
source ${LSOFT_TOOLBAG_BASE}/profile.d/bash-nano.sh
source ${LSOFT_TOOLBAG_BASE}/profile.d/putty-displayFix.sh
source ${LSOFT_TOOLBAG_BASE}/profile.d/x11-forward.sh