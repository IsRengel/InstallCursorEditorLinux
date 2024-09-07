#!/bin/bash

readonly REPO_DIR="$(dirname "$(readlink -m "${0}")")"
readonly TEMP_DIR="${REPO_DIR}/templates"

# Source the color and function variables
source "${REPO_DIR}/shell/vars.sh"
source "${REPO_DIR}/shell/functions.sh"


# Download cursor
echo -e "\n${BLUE_DARK}Installing cursor...${NC}"
download_cursor

# Set up cursor
echo -e "\n${CYAN}Config cursor...${NC}"
setup_cursor

# Setup update script
echo -e "\n${CYAN}Setting up update script...${NC}"
setup_update_script

# Setup systemd service
echo -e "\n${CYAN}Setting up systemd service...${NC}"
setup_systemd_service

# Remove files
remove_files
