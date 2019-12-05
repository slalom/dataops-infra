echo on

echo Step 1: Initializing TSM (Tableau Services Manager)...
cd /opt/tableau/tableau_server/packages/scripts.*

REM source /etc/profile.d/tableau_server.sh  # Update PATH

echo "Install SSL for HTTPS..."
https://interworks.com/blog/trhymer/2018/08/30/protect-tableau-server-for-free-with-lets-encrypt-windows/

echo "Step 2: Activating Tableau Server (optional)..."
REM tsm licenses activate -k <product key>  # License Key
REM tsm licenses activate -t  # 14-day Trial

echo "Step 3: Registering Tableau Server..."
tsm register --template > registration-template.json
echo "Registering with..."
echo registration.json
tsm register --file registration.json

echo "Step 4: Initializing Tableau Server..."
# Initialize Tableau
echo "{\"configEntities\":{\"identityStore\":{\"_type\":\"identityStoreType\",\"type\":\"local\"}}}" > identity_store.json
tsm settings import -f identity_store.json
tsm pending-changes apply
tsm initialize

echo "Step 5: Starting Tableau Server..."
tsm start
tabcmd initialuser --server 'localhost:80' --username 'tabadmin' --password 'tabadmin'

echo Tableau Setup Complete!
