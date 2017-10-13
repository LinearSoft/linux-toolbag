#Automatically set display var
if [ "$PS1" ]; then
  LSOFT_SSHCLIENT=`who -m | awk '{ gsub(/[\(\)]/,"",$5); print $5;}'`
  LSOFT_TMP_IP=${LSOFT_SSHCLIENT}
  if [[ ${LSOFT_TMP_IP} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    export DISPLAY=${LSOFT_SSHCLIENT}:0.0
  fi
fi