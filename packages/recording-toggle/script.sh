#!/usr/bin/env bash
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Recording Stopped" "Video saved to ~/Videos" -t 2000
else
    mkdir -p "$HOME/Videos"
    FILENAME="$HOME/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"

    if [ "${1:-}" == "region" ]; then
        notify-send "Select Region" "Click and drag to record an area" -t 2000
        wf-recorder -g "$(slurp)" -f "$FILENAME" &
    else
        notify-send "Recording Started" "Full screen recording active" -t 2000
        wf-recorder -f "$FILENAME" &
    fi
fi
