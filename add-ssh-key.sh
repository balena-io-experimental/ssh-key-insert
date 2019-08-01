#!/bin/bash

set -o errexit -o pipefail

# Don't run anything before this source as it sets PATH here
# shellcheck disable=SC1091
source /etc/profile

# Edit the SSHKEY variable to add your ssh-key, similar to this example:
# SSHKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3rIsl4KO2zasaRSC4U6eauGqy5E6zuq4wgApKfzXjjIdtNHfYMC28CCCJvDbbaM2qx02z1x2XsxhvsIVI5+8VNNMXiy9/KRZGqpi1DK4R41k5NgyXW1RtU4CfOU4nFriVif1xq7d96qJTfvDUS47Vbr2aRT001Gq5Qh5Oo+p+YQVhWqn1I4A4VEYCXp69Vn/agZTww6yGnQRCU4Du5WKOTfrEw/BPbNLhndPNejgES+lPiGjTDW3m9rFaWM99TwuI7vQ6Gi+GXwfPCWlhR1frh9fifT8PFw9hhaoTv8q+f/hBuIOcfmWYZ38JfCWrgvYGfNoMiGNY33dd19CmJXgf nobody@nowhere"
SSHKEY=""

if [ -z "$SSHKEY" ]; then
  echo "FAIL: No SSHKEY set to be inserted"
  exit 1
fi

BASEFILE="/mnt/boot/config.json"
NEWFILE="$BASEFILE.new"

main() {
  jq  ".os.sshKeys += [ \"$SSHKEY\" ]" "$BASEFILE" > "$NEWFILE"
  echo "INSERTING"
  if [ "$(jq -e '.os.sshKeys' "$NEWFILE")" != "" ] ; then
    systemctl stop resin-supervisor || true
    mv "$NEWFILE" "$BASEFILE"
    echo "Restarting supervisor"
    systemctl start resin-supervisor || true
    echo "Restarting SSH key copy service"
    systemctl restart os-sshkeys || true
    echo "DONE"
  else
    echo "FAIL: ssh key not found in transitory file $BASEFILE"
    exit 1
  fi
}

(
  # Check if already running and bail if yes
  flock -n 99 || (echo "Already running script..."; exit 1)
  main
) 99>/tmp/sshkey.lock
# Proper exit, required due to the locking subshell
exit $?
