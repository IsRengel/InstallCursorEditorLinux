#!/bin/bash

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
    sudo chmod +x /opt/cursor/$FILE_NAME
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
    Exec=/opt/cursor/$FILE_NAME
    Type=Application
    Icon=/opt/cursor/assets/cursor.png
    StartupWMClass=Cursor
    X-AppImage-Version=240829epqamqp7h
    Comment=Cursor is an AI-first coding environment.
    MimeType=x-scheme-handler/cursor;
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
