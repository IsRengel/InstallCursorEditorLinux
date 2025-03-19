#!/bin/bash

EXEC_PATH="/opt/cursor/squashfs-root/AppRun"

function show_help() {
    echo "Usage: cursor [options] [path]"
    echo
    echo "Options:"
    echo "  --help      Show this help message"
    echo "  --update    Update Cursor IDE"
    echo "  --uninstall Uninstall Cursor IDE"
    echo
    echo "If path is provided, Cursor will open that location"
    echo "If no arguments are provided, Cursor will open normally"
}

function update_cursor() {
    if [ -f "/opt/cursor/update-cursor.sh" ]; then
        sudo /opt/cursor/update-cursor.sh
    else
        echo "Error: Update script not found"
        exit 1
    fi
}

function uninstall_cursor() {
    echo "Uninstalling Cursor IDE..."
    sudo systemctl disable update-cursor.service 2>/dev/null
    sudo rm -rf /opt/cursor
    rm -f ~/.config/systemd/user/update-cursor.service
    sudo rm -f /usr/local/bin/cursor
    sudo rm -f /usr/share/applications/cursor.desktop
    echo "Cursor IDE has been uninstalled"
}

case "$1" in
    --help)
        show_help
        ;;
    --update)
        update_cursor
        ;;
    --uninstall)
        uninstall_cursor
        ;;
    *)
        if [ -n "$1" ]; then
            # If path is provided, convert it to absolute path
            ABSOLUTE_PATH=$(readlink -f "$1")
            nohup $EXEC_PATH "$ABSOLUTE_PATH" >/dev/null 2>&1 &
        else
            nohup $EXEC_PATH >/dev/null 2>&1 &
        fi
        ;;
esac 