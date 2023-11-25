#!/bin/bash

# Check if two arguments are provided, default to nice_nano_v2 and cradio if not
if [ "$#" -ne 2 ]; then
    BOARD="nice_nano_v2"
    SHIELD="cradio"
    echo defaulting to board $BOARD and shield $SHIELD
else
  BOARD="$1"
  SHIELD="$2"
fi

# Create a unique timestamped folder in /tmp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEMP_DIR="/tmp/firmware_$TIMESTAMP"
mkdir $TEMP_DIR

# Extract remote URL from the current repo and convert SSH format to HTTPS if needed
GIT_REMOTE_URL=$(git remote get-url origin)
if [[ "$GIT_REMOTE_URL" == git@* ]]; then
    GIT_DOMAIN_AND_REPO="${GIT_REMOTE_URL#*@}"
    GIT_DOMAIN="${GIT_DOMAIN_AND_REPO%%:*}"
    GIT_REPO_PATH="${GIT_DOMAIN_AND_REPO#*:}"
    GIT_REPO_PATH="${GIT_REPO_PATH%.git}"
    GIT_REMOTE_URL="https://${GIT_DOMAIN}/${GIT_REPO_PATH}"
fi

echo $GIT_REMOTE_URL

# Step 1: Download firmware files
LEFT_FIRMWARE_URL="${GIT_REMOTE_URL}/releases/download/latest/${SHIELD}_left-${BOARD}-zmk.uf2"
RIGHT_FIRMWARE_URL="${GIT_REMOTE_URL}/releases/download/latest/${SHIELD}_right-${BOARD}-zmk.uf2"

wget -P $TEMP_DIR "$LEFT_FIRMWARE_URL"
wget -P $TEMP_DIR "$RIGHT_FIRMWARE_URL"

# Simple spinning animation setup
spinner_chars="/-\|"
counter=0

# Flash the right half first
echo "Please plug in and reset the right half of the keyboard."

while [ ! -d "/media/$USER/NICENANO" ]; do
    char="${spinner_chars:counter%4:1}"
    echo -ne "\r$char"
    sleep 0.2
    ((counter++))
done

echo -e "NICENANO detected!"
cp $TEMP_DIR/*right-${BOARD}*.uf2 "/media/$USER/NICENANO/"

while [ -d "/media/$USER/NICENANO" ]; do
    sleep 1
done

# Now flash the left half
counter=0
echo "Please plug in and reset the left half of the keyboard."

while [ ! -d "/media/$USER/NICENANO" ]; do
    char="${spinner_chars:counter%4:1}"
    echo -ne "\r$char"
    sleep 0.2
    ((counter++))
done

echo -e "NICENANO detected!"
cp $TEMP_DIR/*left-${BOARD}*.uf2 "/media/$USER/NICENANO/"

while [ -d "/media/$USER/NICENANO" ]; do
    sleep 1
done

# Cleanup
rm -rf $TEMP_DIR

echo "Script executed successfully."
