#!/bin/sh
####################################################################################################
# Script: Install_asn.sh
# VERSION=1.0.0
# Author: Xentrk
# Date: 25-September-2020
#
# Description:
#   Install asn utility & required entware packages
#   Entware packages
#     bash, whois
####################################################################################################
GIT_REPO="asn"
BRANCH="master"
# Change branch to master after merge
GITHUB_DIR="https://raw.githubusercontent.com/Xentrk/$GIT_REPO/$BRANCH"

Chk_Entware() { # Chk_Entware code source: Martineau

  # ARGS [wait attempts] [specific_entware_utility]
  READY="1"          # Assume Entware Utilities are NOT available
  ENTWARE_UTILITY="" # Specific Entware utility to search for
  MAX_TRIES="30"

  if [ -n "$2" ] && [ "$2" -eq "$2" ] 2>/dev/null; then
    MAX_TRIES="$2"
  elif [ -z "$2" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    MAX_TRIES="$1"
  fi

  if [ -n "$1" ] && ! [ "$1" -eq "$1" ] 2>/dev/null; then
    ENTWARE_UTILITY="$1"
  fi

  # Wait up to (default) 30 seconds to see if Entware utilities available.....
  TRIES="0"

  while [ "$TRIES" -lt "$MAX_TRIES" ]; do
    if [ -f "/opt/bin/opkg" ]; then
      if [ -n "$ENTWARE_UTILITY" ]; then # Specific Entware utility installed?
        if [ -n "$(opkg list-installed "$ENTWARE_UTILITY")" ]; then
          READY="0" # Specific Entware utility found
        else
          # Not all Entware utilities exists as a stand-alone package e.g. 'find' is in package 'findutils'
          if [ -d /opt ] && [ -n "$(find /opt/ -name "$ENTWARE_UTILITY")" ]; then
            READY="0" # Specific Entware utility found
          else
            opkg install "$ENTWARE_UTILITY"
            READY="0"
            break
          fi
        fi
      else
        READY="0" # Entware utilities ready
      fi
      break
    fi
    sleep 1
    logger -st "($(basename "$0"))" "$$ Entware $ENTWARE_UTILITY not available - wait time $((MAX_TRIES - TRIES - 1)) secs left"
    TRIES=$((TRIES + 1))
  done
  return "$READY"
}

Chk_Entware 30
if [ "$READY" -eq 1 ]; then
  echo "You must first install Entware before proceeding"
  printf 'Exiting %s\n' "$(basename "$0")"
  exit 1
fi

Chk_Entware bash 30
if [ "$READY" -eq 1 ]; then
  echo "Unable to install entware package 'bash'"
  printf 'Exiting %s\n' "$(basename "$0")"
  exit 1
fi

Chk_Entware whois 30
if [ "$READY" -eq 1 ]; then
  echo "Unable to install entware package 'whois'"
  printf 'Exiting %s\n' "$(basename "$0")"
  exit 1
fi

while true; do
  echo "Downloading, please wait patiently..."
  /usr/sbin/curl -s --retry 3 $GITHUB_DIR/asn -o /opt/bin/asn
  chmod 755 /opt/bin/asn && printf '%s\n' "asn successfully installed"
  exit 0
done
