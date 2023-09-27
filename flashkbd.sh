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


# Simple spinning animation
spinner_chars="/-\|"
counter=0

# Print the initial message
echo -n "Please plug in and reset the left half of the keyboard. "

while [ ! -d "/media/$USER/NICENANO" ]; do
    # Handle the spinner animation
    char="${spinner_chars:counter%4:1}"
    echo -ne "\rPlease plug in and reset the left half of the keyboard. $char"
    sleep 0.2

    # Increase counter for spinner animation
    ((counter++))
done

echo -e "\rPlease plug in and reset the left half of the keyboard. NICENANO detected!"


# Copy the left firmware file
cp $TEMP_DIR/*left-${BOARD}*.uf2 "/media/$USER/NICENANO/"

# Step 3: Wait for /media/$USER/NICENANO to disappear
while [ -d "/media/$USER/NICENANO" ]; do
    sleep 1
done

# Simple spinning animation
spinner_chars="/-\|"
counter=0

# Print the initial message
echo -n "Please plug in and reset the right half of the keyboard. "

while [ ! -d "/media/$USER/NICENANO" ]; do
    # Handle the spinner animation
    char="${spinner_chars:counter%4:1}"
    echo -ne "\rPlease plug in and reset the right half of the keyboard. $char"
    sleep 0.2

    # Increase counter for spinner animation
    ((counter++))
done

echo -e "\rPlease plug in and reset the right half of the keyboard. NICENANO detected!"

# Step 5: Copy the right firmware file
cp $TEMP_DIR/*right-${BOARD}*.uf2 "/media/$USER/NICENANO/"

# Step 6: Cleanup
rm -rf $TEMP_DIR

echo "Script executed successfully."
