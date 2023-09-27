#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <board> <shield>"
    exit 1
fi

BOARD="$1"
SHIELD="$2"

# Create a unique timestamped folder in /tmp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEMP_DIR="/tmp/firmware_$TIMESTAMP"
mkdir $TEMP_DIR

# Extract remote URL from the current repo
GIT_REMOTE_URL=$(git remote get-url origin)
# Convert SSH format to HTTPS
if [[ "$GIT_REMOTE_URL" == git@* ]]; then
    GIT_DOMAIN_AND_REPO="${GIT_REMOTE_URL#*@}"
    GIT_DOMAIN="${GIT_DOMAIN_AND_REPO%%:*}"
    GIT_REPO_PATH="${GIT_DOMAIN_AND_REPO#*:}"
    GIT_REPO_PATH="${GIT_REPO_PATH%.git}"
    GIT_REMOTE_URL="https://${GIT_DOMAIN}/${GIT_REPO_PATH}"
fi

echo $GIT_REMOTE_URL

# Step 1: Download and unzip firmware files to the unique timestamped folder
LEFT_FIRMWARE_URL="${GIT_REMOTE_URL}/releases/download/latest/${SHIELD}_left-${BOARD}-zmk.uf2"
RIGHT_FIRMWARE_URL="${GIT_REMOTE_URL}/releases/download/latest/${SHIELD}_right-${BOARD}-zmk.uf2"

wget -P $TEMP_DIR "$LEFT_FIRMWARE_URL"
wget -P $TEMP_DIR "$RIGHT_FIRMWARE_URL"

# Step 2: Ensure NICENANO exists before proceeding with the copy
while [ ! -d "/media/$USER/NICENANO" ]; do
    echo "Please plug in and reset the left half of the keyboard."
    sleep 1
done

# Copy the left firmware file
cp $TEMP_DIR/*left-${SHIELD}*.uf2 "/media/$USER/NICENANO/"

# Step 3: Wait for /media/$USER/NICENANO to disappear
while [ -d "/media/$USER/NICENANO" ]; do
    sleep 1
done

# Prompt the user to plug in and reset the right half of the keyboard

# Step 4: Wait for /media/$USER/NICENANO to reappear
while [ ! -d "/media/$USER/NICENANO" ]; do
    echo "Please plug in and reset the right half of the keyboard."
    sleep 1
done

# Step 5: Copy the right firmware file
cp $TEMP_DIR/*right-${SHIELD}*.uf2 "/media/$USER/NICENANO/"

# Step 6: Cleanup
rm -rf $TEMP_DIR

echo "Script executed successfully."
