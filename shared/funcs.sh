#!/usr/bin/env bash
lsoft_echoStd () {
  echo "$@"
}

lsoft_echoErr () {
  echo "$@" 1>&2
}

lsoft_echoBoth () {
  echo "$@"
  echo "$@" 1>&2
}

lsoft_dispErr () {
  msg="$@"
  formated="===ERROR\n${msg}\n==="
  if [[ $- == *i* ]]; then
    echo -e "$formated" 1>&2
  else
    echo -e "$formated"
    echo -e "$formated" 1>&2
  fi
}

lsoft_stampStart () {
  if [ -z "$1" ]; then
    echo -n '======START -- '; date
  else
    echo -n "======START -- $1 -- "; date
  fi
}

lsoft_stampStop () {
  if [ -z "$1" ]; then
    echo -n '======STOP -- '; date
  else
    echo -n "======STOP -- $1 -- "; date
  fi
}

lsoft_rootCheck () {
  if [ "$(id -u)" != "0" ]; then
      lsoft_echoErr "This script must be run by root"
      exit 1
  fi
}

lsoft_randSleep () {
  if [ "$1" = "randSleep" ]; then
    SLEEPSEC=$(( ($RANDOM % 20 ) * 5 ))
    echo "Sleeping for $SLEEPSEC sec(s)"
    sleep $SLEEPSEC
  else
    echo "No Random Sleep"
  fi
}
