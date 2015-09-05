#!/bin/bash

#
# DEFAULT VALUES
#
PUBLIC_KEY_PATH="${HOME}/.ssh/id_rsa.pub"
REMOTE_USERNAME=${USER}

usage() {
  cat << __EOF__
########################
# public key publisher #
########################

Usage: $0 -h REMOTE_HOST [ -u REMOTE_USERNAME ] [ -p PATH/TO/PUBLIC_KEY ] [ -d ]

Connects with to REMOTE_HOST using REMOTE_USERNAME and publishes the given
PUBLIC_KEY into the .ssh/authorized_keys of REMOTE_USERNAME home. If no
REMOTE_USERNAME was given, current USER is assumed also as remote name.
If the PATH/TO/PUBLIC_KEY is omitted, the USER/.ssh/id_rsa.pub is assumed
for the authorization process. Append a -d for performing a dry-run.

__EOF__
}

while getopts "h:u:p:d" opt; do
  case $opt in
    h)
      REMOTE_HOST=$OPTARG;
      ;;
    u)
      REMOTE_USERNAME=$OPTARG;
      ;;
    p)
      PUBLIC_KEY_PATH=$OPTARG
      ;;
    d)
      DRY_RUN=true
      ;;
    \?)
      usage
      exit -1
      ;;
    :)
      usage
      echo "ERROR: Option -$OPTARG requires an argument." >&2
      exit -1
      ;;
  esac
done

if [ -z "${REMOTE_HOST}" ]; then
  echo
  echo "Please provide a remote host to connect to." >&2
  echo
  usage
  exit 1
fi

if [ ! -f $PUBLIC_KEY_PATH ] ; then
  echo
  echo "File not readable at $PUBLIC_KEY_PATH!">&2
  echo
  usage
  exit 1
fi
if [ $(grep -v ^ssh $PUBLIC_KEY_PATH >> /dev/null) ]; then
  echo
  echo "Please provide a valid public key! None found at $PUBLIC_KEY_PATH!" >&2
  echo
  usage
  exit 1
fi
pub_key="$(cat $PUBLIC_KEY_PATH)"

if [ -z "${DRY_RUN}" ]; then
  ssh $REMOTE_USERNAME@$REMOTE_HOST "echo \"$pub_key\" >> ~/.ssh/authorized_keys"
else
  echo
  echo "## DRY RUN ##"
  echo
  echo ssh $REMOTE_USERNAME@$REMOTE_HOST "echo \"$pub_key\" >> ~/.ssh/authorized_keys"
fi
