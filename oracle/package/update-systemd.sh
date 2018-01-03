#!/usr/bin/env bash
#This file is only sourced by it's parent postUpdate & etcUpdated scripts (Shebang line is for reference only)

for FILE in mkrundir.sh oradb\@.service dbstart.sh; do
  sed -i "s@__PIDDIR__@${LSOFT_ORACLE_PID_DIR}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/${FILE}
done

sed -i "s@__USER__@${LSOFT_ORACLE_USER_ORACLE}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/mkrundir.sh
sed -i "s@__GROUP__@${LSOFT_ORACLE_GROUP_ORACLE}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/mkrundir.sh

Service=( oradb\@.service oralsnr\@.service orashutdown.service oraem.service oraagent.service )
User=( ${LSOFT_ORACLE_USER_ORACLE} ${LSOFT_ORACLE_USER_ORACLE} ${LSOFT_ORACLE_USER_ORACLE} ${LSOFT_ORACLE_USER_EM} ${LSOFT_ORACLE_USER_AGENT} )
Group=( ${LSOFT_ORACLE_GROUP_ORACLE} ${LSOFT_ORACLE_GROUP_ORACLE} ${LSOFT_ORACLE_GROUP_ORACLE} ${LSOFT_ORACLE_GROUP_EM} ${LSOFT_ORACLE_GROUP_AGENT} )

sed -i "s@__ORADEFDB__@${LSOFT_ORACLE_DEFAULT_DB_ORACLE}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/oradb@.service
sed -i "s@__ORADEFDB__@${LSOFT_ORACLE_DEFAULT_DB_ORACLE}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/orashutdown.service
sed -i "s@__OEMSID__@${LSOFT_ORACLE_DB_EM}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/oraem.service

for index in 0 1 2 3 4; do
    SERVICE=${Service[index]}
    USER=${User[index]}
    GROUP=${Group[index]}
    sed -i "s@__USER__@${USER}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/${SERVICE}
    sed -i "s@__GROUP__@${GROUP}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/${SERVICE}
    sed -i "s@__BASE__@${LSOFT_TOOLBAG_BASE}@g" ${LSOFT_TOOLBAG_BASE}/oracle/systemd/${SERVICE}
    if [ -f /etc/systemd/system/${SERVICE} ]; then
        cat ${LSOFT_TOOLBAG_BASE}/oracle/systemd/${SERVICE} > /etc/systemd/system/${SERVICE}
    fi
done

systemctl daemon-reload
