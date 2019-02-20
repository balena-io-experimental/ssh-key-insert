#!/bin/bash

set -o errexit -o pipefail

# Don't run anything before this source as it sets PATH here
# shellcheck disable=SC1091
source /etc/profile

# Edit this to add your ssh-key:
SSHKEY=""

if [ -z "$SSHKEY" ]; then
  echo "FAIL: No SSHKEY set to be inserted"
  exit 1
fi

BASEFILE="/mnt/boot/config.json"
NEWFILE="$BASEFILE.new"

main() {
  echo "YEAH"
  jq  ".os.sshKeys += [ \"$SSHKEY\" ]" "$BASEFILE" > "$NEWFILE"
  echo "INSERTING"
  if [ "$(jq -e '.os.sshKeys' "$NEWFILE")" != "" ] ; then
    mv "$NEWFILE" "$BASEFILE"
    echo "DONE"
  else
    echo "FAIL: ssh key not found in transitory file $BASEFILE"
    exit 1
  fi
}

main
exit 0
