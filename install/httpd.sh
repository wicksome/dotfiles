#!/usr/bin/env bash

sudo -v

# Remove built-in Apache server (if any) from system. 
# Stop running Apache server and remove it.
sudo apachectl stop
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist

# Install Apache server provided by Homebrew
brew install httpd

# Configure httpd service to be auto-started on system boot.
sudo brew services start httpd

sudo chmod 666 /usr/local/var/log/httpd/access_log /usr/local/var/log/httpd/error_log