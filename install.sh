#!/bin/bash

readonly REPO_DIR="$(dirname "$(readlink -m "${0}")")"
readonly TEMP_DIR="${REPO_DIR}/templates"

# Source the color and function variables
source "${REPO_DIR}/shell/vars.sh"
source "${REPO_DIR}/shell/functions.sh"


# Download cursor
echo -e "\n${BLUE_DARK}Installing cursor...${NC}"
download_cursor

# Agregar cursor al PATH en el archivo de configuración apropiado
echo -e "\n${BLUE_DARK}Define comand line cursor...${NC}"
add_cursor_alias

# Set up cursor
echo -e "\n${CYAN}Config cursor...${NC}"
setup_cursor

remove_files
