#!/bin/bash
set -ev

exec > >(tee -a /home/ubuntu/tableau_setup_log.txt) 2>&1

echo "Step 1: Initializing TSM (Tableau Services Manager)..."
source /etc/profile.d/tableau_server.sh  # Update PATH
set +e
cd /opt/tableau/tableau_server/packages/scripts.*
sudo -H ./initialize-tsm --accepteula -a ubuntu
set -e

echo "Adding 'tabadmin' account to 'tsmadmin' group..."
sudo usermod -G tsmadmin -a tabadmin

echo ------------
echo -e "TSM is initialized and taking requests at: https://$IP:8850/"

echo "Step 2: Activating Tableau Server (optional)..."
cd /home/ubuntu/tableau
export TSM=/opt/tableau/tableau_server/packages/customer*/tsm
export TABCMD=/opt/tableau/tableau_server/packages/customer*/tabcmd

$TSM licenses activate -t                  # 14-day Trial
# $TSM licenses activate -k <product key>  # License Key

echo "Installing SSL for HTTPS..."
# Uses domain name from www.freenom.com
# Ref: https://community.tableau.com/thread/296360
# Ref: https://medium.com/@kcabading/getting-a-free-domain-for-your-ec2-instance-3ac2955b0a2f
# Ref: https://certbot-dns-route53.readthedocs.io/en/stable/

echo "Step 3: Registering Tableau Server..."
sudo -H $TSM register --template > registration-template.json
$TSM register --file registration.json

echo "Step 4: Initializing Tableau Server..."
echo "{\"configEntities\":{\"identityStore\":{\"_type\":\"identityStoreType\",\"type\":\"local\"}}}" > identity_store.json
$TSM settings import -f identity_store.json
$TSM pending-changes apply
$TSM initialize

echo "Step 5: Starting Tableau Server (`date +'%T %Z'`)..."
$TSM start
$TABCMD initialuser --server 'localhost:80' --username 'tabadmin' --password 'tabadmin'

export IP=$(curl ifconfig.me)

echo "Tableau Setup Complete (`date +'%T %Z'`)!"
echo -e "\tDATA_DIR:      /var/opt/tableau/tableau_server"
echo -e "\tTABLEAU_DIR:   /opt/tableau/tableau_server"
echo -e "\tTSM Config:     https://$IP:8850/"
echo -e "\tTableau Server: http://$IP/"
