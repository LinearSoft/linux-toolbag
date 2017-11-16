#!/usr/bin/env bash
SRC_CONF=$1
DST_CONF=$2

if [ ! -f ${SRC_CONF} ]; then
  lsoft_dispErr "Unable to find source config file ${SRC_CONF}"
  exit 1
fi

if [ ! -f ${DST_CONF} ]; then
  cat ${SRC_CONF} > ${DST_CONF}
  exit 0
fi


#Add missing vars to destination conf
sed '/^[ \t]*$/d' ${SRC_CONF} | while read line; do
  name=$(echo ${line} | cut -d'=' -f1)
  if ! grep -q ${name} ${DST_CONF}; then
    echo "${line}" >> ${DST_CONF}
  fi
done