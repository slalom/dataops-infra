#!/bin/bash

# Logs at: /var/log/cloud-init-output.log
set -e

export IP=$(curl ifconfig.me)
mkdir -p /home/ubuntu/tableau/
LOG_FILE="/home/ubuntu/tableau/setuplog.txt"
exec > >(tee -a $LOG_FILE) 2>&1 # Log everything to setuplog.txt

export TABLEAU_VERSION_STRING="2020-1-0"
export TABLEAU_INSTALL_SOURCE="s3://tableau-quickstart/tableau-server-${TABLEAU_VERSION_STRING}_amd64.deb"

echo Configuring SSH banner...
BANNER="/etc/motd"
sudo touch $BANNER && chmod 777 $BANNER
echo "------------------------------------------------------" >> $BANNER
set +e
sudo apt-get update && sudo apt-get install -y figlet
figlet "Welcome to $PROJECT!" >> $BANNER
set -e
echo "------------------------------------------------------" >> $BANNER
echo "Welcome to the Tableau Server at $IP!" >> $BANNER
echo -e "    EC2 Node Index:      $EC2_NODE_INDEX" >> $BANNER
echo -e "    TSM Config:          https://$IP:8850/" >> $BANNER
echo -e "    Tableau Server:      http://$IP/" >> $BANNER
echo -e "    Default Admin Acct:  tabadmin:tabadmin" >> $BANNER
echo -e "    Setup directory:     /home/ubuntu/tableau" >> $BANNER
echo -e "    Data directory:      /var/opt/tableau/tableau_server" >> $BANNER
echo -e "    Tableau app path:    /opt/tableau/tableau_server" >> $BANNER
echo -e "    Tableau docs:        https://help.tableau.com/current/guides/everybody-install-linux/en-us/everybody_admin_install_linux.htm" >> $BANNER
echo -e "Possible Actions:" >> $BANNER
echo -e "    Tail setup log:      tail -f -n 200 $LOG_FILE  (ctrl+c to exit)" >> $BANNER
echo -e "    Start/stop server:   tsm start" >> $BANNER
echo -e "                         tsm stop" >> $BANNER
echo -e "    Register server:     tsm register --file registration.json" >> $BANNER
echo -e "                         tsm licenses activate -k <product-key>" >> $BANNER
echo -e "                         tsm pending-changes apply" >> $BANNER
echo -e "                         tsm initialize" >> $BANNER
echo -e "    Configure https:     bash ./ssl_setup.sh bi.mydomain.com" >> $BANNER
echo "------------------------------------------------------" >> $BANNER
echo -e "Cluster setup steps:     https://help.tableau.com/current/server-linux/en-us/install_additional_nodes.htm" >> $BANNER
echo -e "  On Leader Node:      " >> $BANNER
echo -e "    1. Get bootstrap file:    tsm topology nodes get-bootstrap-file --file ~/bootstrap.sh" >> $BANNER
echo -e "    2. Print, then copy:      cat ~/bootstrap.sh" >> $BANNER
echo -e "  On Secondary Nodes:  " >> $BANNER
echo -e "    3. Create file and paste: nano ~/bootstrap.sh" >> $BANNER
echo -e "    4. Run join script:       ~/tableau/tableau_join.sh" >> $BANNER
echo -e "                        OR:   cd /opt/tableau/tableau_server/packages/scripts.*" >> $BANNER
echo -e "                              sudo ./initialize-tsm --accepteula -a ubuntu -b ~/bootstrap.json" >> $BANNER
echo "------------------------------------------------------" >> $BANNER

cd /home/ubuntu
set -v # log verbose

echo "Installing prereqs..."
sudo apt-get update
sudo apt-get install -y \
    jq \
    software-properties-common
sudo add-apt-repository -y universe
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get -y install gdebi-core
sudo apt-get install -y certbot

echo "Configuring locale in the OS..."
export LANG=en_US.UTF-8
sudo localectl set-locale LANG=en_US.UTF-8

echo "Installing AWS CLI..."
snap install aws-cli --classic
echo "Updating PATH to avoid restart..."
export PATH=$PATH:/snap/bin
export AWS=/snap/bin/aws

echo ------------
echo "Showing contents of S3 bucket..."
$AWS s3 ls s3://tableau-quickstart --no-sign-request

echo "Downloading scripts from S3..."
mkdir -p /home/ubuntu/tableau/installer
$AWS s3 cp s3://tableau-quickstart/automated-installer tableau/ --no-sign-request
$AWS s3 cp s3://tableau-quickstart/manageFirewallPorts.py tableau/ --no-sign-request
$AWS s3 cp s3://tableau-quickstart/SilentInstaller.py tableau/ --no-sign-request
$AWS s3 cp s3://tableau-quickstart/ScriptedInstaller.py tableau/ --no-sign-request

echo "Downloading Postgres installer from S3..."
$AWS s3 cp s3://tableau-quickstart/tableau-postgresql-odbc_9.5.3_amd64.deb tableau/ --no-sign-request

echo "Downloading Tableau installer from S3..."
$AWS s3 cp ${TABLEAU_INSTALL_SOURCE} tableau/installer/ --no-sign-request

cd tableau

echo "Showing downloaded installer:"""
ls installer/* -la

echo "Installing Tableau Server..."
sudo gdebi -n installer/tableau-server-*.deb

echo "Creating 'tabadmin' account..."
sudo adduser --disabled-password --gecos "Tableau Admin,,," tabadmin
echo "tabadmin:tabadmin" | sudo chpasswd

cd /home/ubuntu/tableau
sudo chmod 777 *
if [[ $EC2_NODE_INDEX -eq 0 ]]; then
    echo "Running on primary node (EC2_NODE_INDEX=$EC2_NODE_INDEX)."
    echo "Beginning tableau_setup.sh..."
    ./tableau_setup.sh
else
    echo "Running on secondary node (EC2_NODE_INDEX=$EC2_NODE_INDEX)."
    echo "Skipping tableau_setup.sh..."
    echo "To join this node to the cluster, generate a file called ~/boostrap.json from TSM on the leader node and then run:"
    echo " > tableau/tableau_join.sh"
fi
