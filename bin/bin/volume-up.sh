#!/bin/bash
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
newvol=$(awk -v v="$vol" 'BEGIN { v += 0.05; if (v > 1) v = 1; print v }')
wpctl set-volume @DEFAULT_AUDIO_SINK@ "$newvol"
