#!/usr/bin/env sh
#
#This script TO ONLY BE USED with systemd
###
###################################
#
# usage: agentstart
#
#####################################

if [ -f /etc/oragchomelist ]; then
    oratab="/etc/oragchomelist"
else
    oratab="/var/opt/oracle/oragchomelist"
fi

if [ ! -f "$oratab" ]; then
    echo "Unable to load oratab"
    exit 1
fi

AGENTFOUND=0
for i in `cat $oratab | grep -v '^#' | cut -d ":" -f1`; do
    if [ -f "$i/install/unix/scripts/agentstup" ]; then
        AGENTFOUND=1
        PATH=/usr/bin:/bin:/usr/local/bin:$PATH
        ORACLE_HOME=`cat $oratab | grep $i | grep -v '^#' | cut -d ":" -f2`
        export PATH ORACLE_HOME
        $ORACLE_HOME/bin/emctl start agent
    fi
done

if [ $AGENTFOUND -eq 0 ]; then
    echo "Unable to find agent home"
    exit 1
fi

exit 0