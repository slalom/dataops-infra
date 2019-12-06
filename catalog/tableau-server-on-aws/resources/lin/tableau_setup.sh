#!/bin/bash
set -ev

exec > >(tee -a /home/ubuntu/tableau_setup_log.txt) 2>&1

echo "Step 1: Initializing TSM (Tableau Services Manager)..."
cd /opt/tableau/tableau_server/packages/scripts.*
source /etc/profile.d/tableau_server.sh  # Update PATH
set +e
export LANG=en_US.UTF-8
sudo localectl set-locale LANG=en_US.UTF-8
sudo -H initialize-tsm --accepteula
set -e

echo "Step 2: Activating Tableau Server (optional)..."
cd /home/ubuntu/tableau
export TSM=/opt/tableau/tableau_server/packages/customer*/tsm
tsm licenses activate -t  # 14-day Trial
# tsm licenses activate -k <product key>  # License Key

echo "Installing SSL for HTTPS..."
# Uses domain name from www.freenom.com
# Ref: https://community.tableau.com/thread/296360
# Ref: https://medium.com/@kcabading/getting-a-free-domain-for-your-ec2-instance-3ac2955b0a2f
# Ref: https://certbot-dns-route53.readthedocs.io/en/stable/

echo "Step 3: Registering Tableau Server..."
# Register Tableau
sudo -H $TSM register --template > registration-template.json
# nano registration.json
$TSM register --file registration.json

echo "Step 4: Initializing Tableau Server..."
# Initialize Tableau
echo "{\"configEntities\":{\"identityStore\":{\"_type\":\"identityStoreType\",\"type\":\"local\"}}}" > identity_store.json
$TSM settings import -f identity_store.json
$TSM pending-changes apply
$TSM initialize

echo "Step 5: Starting Tableau Server (`date +'%T %Z'`)..."
# Start Tableau

$TSM start
tabcmd initialuser --server 'localhost:80' --username 'tabadmin' --password 'tabadmin'

export IP=$(curl ifconfig.me)

echo "Tableau Setup Complete (`date +'%T %Z'`)!"
echo -e "\tDATA_DIR:      /var/opt/tableau/tableau_server"
echo -e "\tTABLEAU_DIR:   /opt/tableau/tableau_server"
echo -e "\tTSM Config:     https://$IP:8850/"
echo -e "\tTableau Server: http://$IP/"
