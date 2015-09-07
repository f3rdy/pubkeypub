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
  ssh $REMOTE_USERNAME@$REMOTE_HOST "mkdir ~/.ssh -p && echo \"$pub_key\" >> ~/.ssh/authorized_keys"
else
  echo
  echo "## DRY RUN ##"
  echo
  echo ssh $REMOTE_USERNAME@$REMOTE_HOST "mkdir ~/.ssh -p && echo \"$pub_key\" >> ~/.ssh/authorized_keys"
fi
