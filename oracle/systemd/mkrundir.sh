#!/usr/bin/env bash

SAVE_PATH=${PATH}
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}

PID_DIR=__PIDDIR__

if [ ! -d ${PID_DIR} ]; then
  mkdir ${PID_DIR}
  chown __USER__:__GROUP__ ${PID_DIR}
  chmod 775 ${PID_DIR}
fi

export PATH=${SAVE_PATH}