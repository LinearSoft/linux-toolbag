#!/usr/bin/env bash
LSOFT_BASE=/opt/linearsoft/toolbag

chmod +x ${LSOFT_BASE}/package/*.sh
ln -s ${LSOFT_BASE}/package/install.sh ${LSOFT_BASE}/package/update.sh