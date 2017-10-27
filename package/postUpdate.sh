#!/usr/bin/env bash
#This file is only called by install.sh (Shebang line is for reference only)

source ${LSOFT_TOOLBAG_BASE}/shared/funcs.sh

chmod +x ${LSOFT_TOOLBAG_BASE}/package/install.sh
ln -s ${LSOFT_TOOLBAG_BASE}/package/install.sh ${LSOFT_TOOLBAG_BASE}/package/update.sh

chmod +x ${LSOFT_TOOLBAG_BASE}/shared/updateConf.sh

${LSOFT_TOOLBAG_BASE}/shared/updateConf.sh ${LSOFT_TOOLBAG_BASE}/package/toolbag.conf /etc/linearsoft/toolbag.conf

#Oracle
source ${LSOFT_TOOLBAG_BASE}/oracle/package/postUpdate.sh