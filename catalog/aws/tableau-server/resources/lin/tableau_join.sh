#!/bin/bash
set -ev

exec > >(tee -a /home/ubuntu/tableau_setup_log.txt) 2>&1

echo "Step 1: Initializing TSM with bootstrap.json..."
source /etc/profile.d/tableau_server.sh  # Update PATH
set +e
cd /opt/tableau/tableau_server/packages/scripts.*
sudo -H ./initialize-tsm --accepteula -a ubuntu -b ~/bootstrap.json
set -e
