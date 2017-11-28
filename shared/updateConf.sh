#!/usr/bin/env bash
SRC_CONF=$1
ORG_CONF=$2

if [ ! -f ${SRC_CONF} ]; then
  echo "Unable to find source config file ${SRC_CONF}"
  exit 1
fi

if [ ! -f ${ORG_CONF} ]; then
  cat ${SRC_CONF} > ${ORG_CONF}
  exit 0
fi

#Setup temp dir with auto removal
WORK_DIR=`mktemp -d`
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi
function cleanup {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

#Generate tmp CONF
FILE_NAME=`basename "${ORG_CONF}"`
TMP_CONF=${WORK_DIR}/${FILE_NAME}
cp ${SRC_CONF} ${TMP_CONF}



#Update tmp conf with existing settings
egrep '^[ ^I]*LSOFT_[^ ^I=]+=[^=]+$' ${ORG_CONF} | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'  | while read line; do
  name=$(echo ${line} | cut -d'=' -f1)
  val=$(echo ${line} | cut -d'=' -f2)
  valfix=`echo "${val}" | sed -e 's/[\/&]/\\&/g'`
  sed -i "s/${name}=.*/${name}=${valfix}/g" ${TMP_CONF}
done

cat ${TMP_CONF} > ${ORG_CONF}

exit 0