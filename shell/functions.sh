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
    # Extract the appimage
    cd /opt/cursor && \
	sudo /opt/cursor/$FILE_NAME --appimage-extract && \
	sudo chown -R $USER:$USER /opt/cursor/squashfs-root && \
	sudo chown root:root /opt/cursor/squashfs-root/chrome-sandbox && \
	sudo chmod 4755 /opt/cursor/squashfs-root/chrome-sandbox
    export EXE_PATH="/opt/cursor/squashfs-root/cursor"
    cd $CURRENT_DIRECTORY
    echo -e "${GREEN} Extracted cursor to: '${EXE_PATH}'${NC}"
    # Create .desktop file
    sudo tee "$DESKTOP_FILE" > /dev/null <<EOF
    [Desktop Entry]
    Name=Cursor
    GenericName=Text Editor
    Exec=$EXE_PATH %F
    Type=Application
    Icon=/opt/cursor/assets/cursor.png
    StartupWMClass=Cursor
    StartupNotify=false
    Comment=Cursor is an AI-first coding environment.
    MimeType=application/x-cursor-workspace;
    Categories=TextEditor;Development;IDE;
    Actions=new-empty-window;
    Keywords=cursor;vscode;code;
EOF
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ File $DESKTOP_FILE created successfully.${NC}"
    else
        echo -e "${RED}❌ Error creating the file $DESKTOP_FILE${NC}"
        exit 1
    fi

    sudo tee "/usr/local/bin/cursor" > /dev/null < "${CURRENT_DIRECTORY}/shell/cursor-command.sh"
    sudo chmod +x "/usr/local/bin/cursor"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Cursor command installed successfully${NC}"
    else
        echo -e "${RED}❌ Error installing cursor command${NC}"
        exit 1
    fi
}


function setup_update_script() {
    local UPDATE_SCRIPT="/opt/cursor/update-cursor.sh"

    # Create script of update
    sudo tee "$UPDATE_SCRIPT" > /dev/null <<EOF
#!/bin/bash
APPDIR=/opt/cursor
API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"

# Get the download URL from the API
APPIMAGE_URL=\$(curl -s "\$API_URL" | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4)

# Extract the version from the URL
VERSION=\$(echo "\$APPIMAGE_URL" | grep -o 'Cursor-[0-9.]*' | cut -d'-' -f2)

# Download the latest version
echo "Downloading Cursor version \$VERSION..."
wget -O "\$APPDIR/cursor-\${VERSION}-x86_64.AppImage" "\$APPIMAGE_URL"
chmod +x "\$APPDIR/cursor-\${VERSION}-x86_64.AppImage"

# Extract the appimage
cd \$APPDIR && sudo "\$APPDIR/cursor-\${VERSION}-x86_64.AppImage" --appimage-extract && \
    sudo chown $USER:$USER \$APPDIR/squashfs-root && \
    sudo chown root:root \$APPDIR/squashfs-root/chrome-sandbox && \
    sudo chmod 4755 \$APPDIR/squashfs-root/chrome-sandbox && \
    sudo mv \$APPDIR/squashfs-root/AppRun \$APPDIR/squashfs-root/cursor && \
    cd -

echo "Cursor has been updated to version \$VERSION"
EOF

    # permissions to script execution
    sudo chmod +x "$UPDATE_SCRIPT"
    echo -e "${GREEN}✅ Update script created at $UPDATE_SCRIPT${NC}"
}

function setup_systemd_service() {
    local SERVICE_FILE=~/.config/systemd/system/update-cursor.service

    # Ensure the systemd directory exists
    mkdir -p ~/.config/systemd/system

    # Create the systemd service file
    tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Update Cursor IDE

[Service]
ExecStart=/opt/cursor/update-cursor.sh
Type=oneshot

[Install]
WantedBy=default.target
EOF

    # Enable and start the service
    sudo systemctl enable $SERVICE_FILE
    sudo systemctl start update-cursor.service

    echo -e "${GREEN}✅ Systemd service for Cursor IDE updates created and started.${NC}"
}

remove_files() {
    # Remove the output directory
    rm -r "$OUTPUT_DIRECTORY"
}
