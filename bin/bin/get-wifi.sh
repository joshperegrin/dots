#!/bin/bash

# Get current network name (SSID) and signal strength
read ssid sig <<<$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi | awk -F: '/^\*/{print $2, $3; found=1} END{if(!found)print "-1 -1"}')

# If no connection
if [ "$sig" -eq -1 ]; then
  echo "-1 offline"
else
  # Check internet connectivity
  if curl -s --head --connect-timeout 2 https://www.google.com >/dev/null; then
    echo "$sig $ssid online"
  else
    echo "$sig $ssid offline"
  fi
fi

