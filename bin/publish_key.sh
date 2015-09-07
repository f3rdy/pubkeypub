#!/bin/bash

# Easily publish your public key to remote hosts
#
# Copyright (C) 2015 Fred Thiele <ferdy_news@gmx.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# DEFAULT VALUES
#
PUBLIC_KEY_PATH="${HOME}/.ssh/id_rsa.pub"
REMOTE_USERNAME=${USER}
PASSWORD_FILE="None"
SSH_PASS=
SSH_OPTIONS="-oConnectTimeout=5 -oStrictHostKeyChecking=no"

usage() {
  cat << __EOF__
########################
# public key publisher #
########################

Usage: $0 -h REMOTE_HOST [ -u REMOTE_USERNAME ] [ -p PATH/TO/PUBLIC_KEY ] [ -f PASSWORD_FILE ] [ -r ]

Connects with to REMOTE_HOST using REMOTE_USERNAME and publishes the given
PUBLIC_KEY into the .ssh/authorized_keys of REMOTE_USERNAME home. If no
REMOTE_USERNAME was given, current USER is assumed also as remote name.
If the PATH/TO/PUBLIC_KEY is omitted, the USER/.ssh/id_rsa.pub is assumed
for the authorization process.

You may set a PASSWORD_FILE using -f file.txt to enable batch processing. You
need to set the file chmod 0600 to deny any access from others. You enter
your REMOTE_USERNAME password there. Useful for batch processing several machines.

Use flag -r to remove duplicate entries of the same key in authorized_keys.

__EOF__
}

while getopts "h:u:p:f:r" opt; do
  case $opt in
    h)
      REMOTE_HOST=$OPTARG
      ;;
    u)
      REMOTE_USERNAME=$OPTARG
      ;;
    p)
      PUBLIC_KEY_PATH=$OPTARG
      ;;
    f)
      PASSWORD_FILE=$OPTARG
      ;;
    r)
      REMOVE_DUPLICATES="true"
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

if [ ! -f $PUBLIC_KEY_PATH ]; then
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

if [ ! "$PASSWORD_FILE" = "None" ]; then
  if [ ! -f $PASSWORD_FILE ]; then
    echo
    echo "Password file not readable at ${PASSWORD_FILE}."
    echo
    usage
    exit 1
  else
    SSH_PASS="sshpass -p ${PASSWORD_FILE}"
  fi
fi

echo "### REMOTE_HOST: $REMOTE_HOST"
if [ -z "${DRY_RUN}" ]; then
  $SSH_PASS ssh $SSH_OPTIONS $REMOTE_USERNAME@$REMOTE_HOST 'bash -s' << __EOF__
    mkdir ~/.ssh -p
    touch ~/.ssh/authorized_keys

    # fix wrong lines containing double quotes on beginning and end of a key
    egrep -vwE "^\".*\"$" ~/.ssh/authorized_keys > ~/.ssh/authorized_keys_
    mv ~/.ssh/authorized_keys_ ~/.ssh/authorized_keys

    # check if key already exists
    grep -Fxq "\"$pub_key\"" ~/.ssh/authorized_keys >> /dev/null
    if [ ! \$? == 0  ]; then
      echo "${REMOTE_HOST}: Key is added remotely..."
      echo $pub_key >> ~/.ssh/authorized_keys
    else
      echo "${REMOTE_HOST}: Key already registered remotely..."
    fi
    if [ "$REMOVE_DUPLICATES" == "true" ]; then
      echo "${REMOTE_HOST}: Remove duplicate keys remotely... "
      sort -u ~/.ssh/authorized_keys > ~/.ssh/authorized_keys_
      mv ~/.ssh/authorized_keys_ ~/.ssh/authorized_keys
    fi
__EOF__
fi
