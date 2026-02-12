#!/bin/bash

# Get current signal strength and network name (SSID)
# We use '|' as a delimiter because SSIDs can contain spaces.
# awk now prints SIGNAL first, then SSID.
IFS='|' read sig ssid <<<$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi | awk -F: '/^\*/{printf "%s|%s", $3, $2; found=1} END{if(!found)print "-1|offline"}')

# If no connection
if [ "$sig" -eq -1 ]; then
  # Output format: SIGNAL|SSID|STATUS
  echo "-1|offline|offline"
else
  # Check internet connectivity
  if curl -s --head --connect-timeout 2 https://www.google.com >/dev/null; then
    echo "$sig|$ssid|online"
  else
    echo "$sig|$ssid|offline"
  fi
fi
