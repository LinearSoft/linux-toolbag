#!/usr/bin/env bash
LSOFT_ETC_BASE=/etc/linearsoft

LSOFT_TOOLBAG_BASE=/opt/linearsoft/toolbag

if [ -f /etc/linearsoft/toolbag.conf ]; then
  source /etc/linearsoft/toolbag.conf
fi


LSOFT_TMP_DIR=/tmp/lsoft_toolbag_deploy
LSOFT_DEPLOY_TAR=${LSOFT_TMP_DIR}/lsoft_toolbag.tar.gz

inst_dispErr () {
  msg="$@"
  formated="===ERROR\n${msg}\n==="
  if [[ $- == *i* ]]; then
    echo -e "$formated" 1>&2
  else
    echo -e "$formated"
    echo -e "$formated" 1>&2
  fi
}

#Check for req apps
if ! hash wget 2>/dev/null; then
  inst_dispErr The wget app is required.
  exit 1
fi

if ! hash tar 2>/dev/null; then
  inst_dispErr The tar app is required.
  exit 1
fi

#Create base dir
mkdir -p ${LSOFT_TOOLBAG_BASE} 2>/dev/null
if [ ! -d ${LSOFT_TOOLBAG_BASE} ]; then
  inst_dispErr Unable to create deploy directory
  exit 2
fi

#Create etc dir
mkdir -p /etc/linearsoft 2>/dev/null
if [ ! -d /etc/linearsoft ]; then
  inst_dispErr Unable to create etc/config directory
  exit 2
fi

#Create tmp dir
rm -rf ${LSOFT_TMP_DIR} 2>/dev/null
mkdir ${LSOFT_TMP_DIR} 2>/dev/null
if [ ! -d ${LSOFT_TMP_DIR} ]; then
  inst_dispErr Unable to create temporary directory
  exit 2
fi

wget https://api.github.com/repos/LinearSoft/linux-toolbag/tarball/master -O ${LSOFT_DEPLOY_TAR} >/dev/null
if [ $? -ne 0 ]; then
  inst_dispErr Unable to download distribution file
  exit 2
fi

tar -xzf ${LSOFT_DEPLOY_TAR} -C ${LSOFT_TMP_DIR}/
if [ $? -ne 0 ]; then
  inst_dispErr Unable to extract distribution file
  exit 2
fi

rm -rf ${LSOFT_TOOLBAG_BASE}/*
cp -r ${LSOFT_TMP_DIR}/LinearSoft-linux-toolbag*/* ${LSOFT_TOOLBAG_BASE}/
rm -rf ${LSOFT_TMP_DIR}
source ${LSOFT_TOOLBAG_BASE}/package/postUpdate.sh
