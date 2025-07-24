#!/bin/bash

# Load OS info
source /etc/os-release

# Normalize ID_LIKE and ID to lowercase
id=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
id_like=$(echo "$ID_LIKE" | tr '[:upper:]' '[:lower:]')

# Match known distros to Nerd Font icons
case "$id" in
    arch)
        icon=""  # Arch Linux
        ;;
    endeavouros)
        icon=""  # EndeavourOS (same icon as arch or unique if font supports it)
        ;;
    manjaro)
        icon=""  # Manjaro
        ;;
    ubuntu)
        icon=""  # Ubuntu
        ;;
    debian)
        icon=""  # Debian
        ;;
    fedora)
        icon=""  # Fedora
        ;;
    centos)
        icon=""  # CentOS
        ;;
    opensuse* | suse)
        icon=""  # openSUSE
        ;;
    gentoo)
        icon=""  # Gentoo
        ;;
    void)
        icon=""  # Void Linux
        ;;
    alpine)
        icon=""  # Alpine Linux
        ;;
    nixos)
        icon=""  # NixOS
        ;;
    zorin)
        icon=""  # Zorin (fallback)
        ;;
    linuxmint)
        icon=""  # Linux Mint
        ;;
    pop)
        icon=""  # Pop!_OS
        ;;
    garuda)
        icon="󰛓"  # Garuda (requires custom icon or fallback to arch)
        ;;
    kde)
        icon=""  # KDE Neon (fallback)
        ;;
    *)
        # Try ID_LIKE if ID is unknown
        case "$id_like" in
            arch)
                icon=""
                ;;
            debian)
                icon=""
                ;;
            fedora)
                icon=""
                ;;
            *)
                icon=""  # Generic Linux Tux
                ;;
        esac
        ;;
esac

# Output JSON for Waybar
echo "{\"text\": \"$icon\", \"tooltip\": \"$PRETTY_NAME\"}"
