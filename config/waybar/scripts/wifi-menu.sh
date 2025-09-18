#!/bin/bash
nmcli device wifi rescan
nmcli device wifi list | wofi --dmenu | awk '{print $1}' | xargs -r nmcli device wifi connect
