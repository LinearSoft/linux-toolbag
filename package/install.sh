#!/usr/bin/env bash
LSOFT_BASE=/opt/linearsoft/toolbag
LSOFT_TMP_DIR=/tmp/lsoft_toolbag_deploy


lsoft_dispErr () {
  msg="$@"
  formated="===ERROR\n${msg}\n==="
  if [ "$PS1" ]; then
    echo -e "$formated" 1>&2
  else
    echo -e "$formated"
    echo -e "$formated" 1>&2
  fi
}

#Check for req apps
if ! hash wget 2>/dev/null; then
  lsoft_dispErr The wget app is required.
  exit 1
fi

if ! hash tar 2>/dev/null; then
  lsoft_dispErr The tar app is required.
  exit 1
fi

#Create base dir
mkdir -p ${LSOFT_BASE} 2>/dev/null
if [ ! -d ${LSOFT_TMP_DIR} ]; then
  lsoft_dispErr Unable to create deploy directory
fi

#Create tmp dir
rm -rf ${LSOFT_TMP_DIR} 2>/dev/null
mkdir ${LSOFT_TMP_DIR} 2>/dev/null
if [ ! -d ${LSOFT_TMP_DIR} ]; then
  lsoft_dispErr Unable to create temporary directory
fi

wget https://api.github.com/repos/LinearSoft/linux-toolbag/tarball/master ${LSOFT_TMP_DIR}/lsoft_toolbag.tar.gz >/dev/null
if [ $? -ne 0 ]; then
  lsoft_dispErr Unable to download distribution file
  exit 2
fi

tar -xzf ${LSOFT_TMP_DIR}/lsoft_toolbag.tar.gz -C ${LSOFT_TMP_DIR}/
if [ $? -ne 0 ]; then
  lsoft_dispErr Unable to extract distribution file
  exit 2
fi

rm -rf ${LSOFT_BASE}/*
cp -r ${LSOFT_TMP_DIR}/LinearSoft-linux-toolbag*/* ${LSOFT_BASE}/
rm -rf ${LSOFT_TMP_DIR}
. ${LSOFT_BASE}/postUpdate.sh
