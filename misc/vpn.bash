#!/usr/bin/env bash
path="$1"
usrn="$2"

for file_path in $(ls "$path/"*.ovpn); do
    file="$(basename ${file_path/.ovpn/})"
    nmcli c delete "$file"
    nmcli c import type openvpn file "$file_path"
    nmcli c modify "$file" +vpn.data username="$usrn"
done

