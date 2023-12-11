#!/bin/bash

# colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BLUE_DARK='\033[0;34m'
readonly NC='\033[0m'  # No Color

# emojis
readonly DOWNLOAD_EMOJI='\U1F4E2'  # Unicode character for a download emoji

# vars
readonly OUTPUT_DIRECTORY=~/Cursor
readonly FILE_NAME=cursor.AppImage
readonly OUTPUT_FILE=$OUTPUT_DIRECTORY/$FILE_NAME
readonly URL_CURSOR_DOWN="https://download.cursor.sh/linux/appImage/x64"
