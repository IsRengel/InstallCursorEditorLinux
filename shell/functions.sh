#!/bin/bash

function add_cursor_alias() {
    # Determine the user's shell
    local SHELL_NAME=$(basename "$SHELL")

    # Set the appropriate configuration file
    local CONFIG_PATH
    if [ "$SHELL_NAME" = "bash" ]; then
        CONFIG_PATH="$HOME/.bashrc"
    elif [ "$SHELL_NAME" = "zsh" ]; then
        CONFIG_PATH="$HOME/.zshrc"
    else
        echo "Unable to determine the current shell."
        return 1
    fi

    # Add alias with "&" to run in the background
    echo 'alias cursor="/opt/cursor/cursor.AppImage"' >> "$CONFIG_PATH"
    echo "✅ Added alias 'cursor' to $CONFIG_PATH"
}

function download_cursor() {
    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIRECTORY"

    # Download cursor if it doesn't exist
    if [ -e "$OUTPUT_FILE" ]; then
        echo -e "${GREEN}✅ The file already exists: $OUTPUT_FILE${NC}"
    else
        echo -e "↓ ${CYAN}Downloading cursor... ${DOWNLOAD_EMOJI}${NC}"
        curl -o "$OUTPUT_FILE" "$URL_CURSOR_DOWN"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Download completed: $OUTPUT_FILE${NC}"
        else
            echo -e "${RED}❌ Error during download${NC}"
            exit 1
        fi
    fi

}


function setup_cursor() {
    local CURRENT_DIRECTORY=$(pwd)
    local DESKTOP_FILE="/usr/share/applications/cursor.desktop"

    # Set up cursor: move, grant permissions, and create .desktop file
    sudo mkdir -p /opt/cursor
    sudo cp -r "$CURRENT_DIRECTORY/assets" /opt/cursor/
    sudo mv "$OUTPUT_FILE" /opt/cursor/
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ File $OUTPUT_FILE moved successfully to /opt/cursor/${NC}"
    else
        echo -e "${RED}❌ Error moving the file${NC}"
        exit 1
    fi
    sudo chmod +x /opt/cursor/cursor.AppImage
    sudo chown $USER:$USER /opt/cursor
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Permissions granted successfully to /opt/cursor/cursor.AppImage${NC}"
    else
        echo -e "${RED}❌ Error granting permissions${NC}"
        exit 1
    fi
    # Create .desktop file
    sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
    [Desktop Entry]
    Name=Cursor
    Exec=/opt/cursor/cursor.AppImage
    Icon=/opt/cursor/assets/icon.svg
    Type=Application
    Categories=Development;
EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ File $DESKTOP_FILE created successfully.${NC}"
    else
        echo -e "${RED}❌ Error creating the file $DESKTOP_FILE${NC}"
        exit 1
    fi
}

remove_files() {
    # Remove the output directory
    rm -r "$OUTPUT_DIRECTORY"
}