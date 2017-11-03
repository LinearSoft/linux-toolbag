#!/usr/bin/env sh
#
###WCIT
#This script TO ONLY BE USED with systemd
###
###################################
#
# usage: emshut
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

EMFOUND=0
for i in `cat $oratab | grep -v '^#' | cut -d ":" -f1`; do
    if [ -f "$i/install/unix/scripts/omsstup" ]; then
        EMFOUND=1
        PATH=/usr/bin:/bin:/usr/local/bin:$PATH
        ORACLE_HOME=$i
        export PATH ORACLE_HOME
        $ORACLE_HOME/bin/emctl stop oms -all
    fi
done

if [ $EMFOUND -eq 0 ]; then
    echo "Unable to find em home"
    exit 1
fi

exit 0