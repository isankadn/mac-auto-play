#!/bin/bash

# Retrieve the current user's username
CURRENT_USER=$(whoami)

# Full path to the desktop directory where the 'mac-auto-play' folder is
DESKTOP_PATH="/Users/$CURRENT_USER/Desktop/mac-auto-play"
TIMES_FILE="$DESKTOP_PATH/times.txt"

# Read start and stop times from the file
START_TIME=$(sed -n '1p' "$TIMES_FILE")
STOP_TIME=$(sed -n '2p' "$TIMES_FILE")

# Validate time format (basic regex for HH:MM format)
if ! [[ "$START_TIME" =~ ^([01][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
    echo "Start time is not in the correct format: HH:MM"
    exit 1
fi

if ! [[ "$STOP_TIME" =~ ^([01][0-9]|2[0-3]):([0-5][0-9])$ ]]; then
    echo "Stop time is not in the correct format: HH:MM"
    exit 1
fi

# Convert times to crontab format
CRON_START_TIME=$(echo "$START_TIME" | tr -d ':')
CRON_STOP_TIME=$(echo "$STOP_TIME" | tr -d ':')

# Backup the current crontab
crontab -l > "$DESKTOP_PATH/crontab_backup.txt"

sleep 1

# Remove old entries from the script and QuickTime Player (you may tailor this as needed)
crontab -l | grep -v 'script.applescript' | grep -v 'QuickTime Player' | crontab -

# Convert times to crontab format by extracting hours and minutes
CRON_START_HOUR=$(echo "$START_TIME" | cut -d':' -f1)
CRON_START_MINUTE=$(echo "$START_TIME" | cut -d':' -f2)
CRON_STOP_HOUR=$(echo "$STOP_TIME" | cut -d':' -f1)
CRON_STOP_MINUTE=$(echo "$STOP_TIME" | cut -d':' -f2)

# Update the cron jobs for start time
if ! (crontab -l; echo "$CRON_START_MINUTE $CRON_START_HOUR * * * osascript '$DESKTOP_PATH/script.applescript'") | crontab - ; then
    echo "Failed to update the start time cron job."
    exit 1
fi

# Update the cron jobs for stop time
if ! (crontab -l; echo "$CRON_STOP_MINUTE $CRON_STOP_HOUR * * * osascript -e 'tell application \"QuickTime Player\" to quit'") | crontab - ; then
    echo "Failed to update the stop time cron job."
    exit 1
fi
