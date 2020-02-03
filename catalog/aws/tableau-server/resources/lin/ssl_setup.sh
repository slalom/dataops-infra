#!/bin/bash

echo -e "This script adds support for secure Tableau HTTPS encryption over SSL"
echo -e "\nPrerequisites:"
echo -e " 1. A domain which you own and have redirected to this server's URL"
echo -e " 2. A registration.json file (which will be the source of the email used for ownership"
echo -e "\nUsage:"
echo -e " bash setup.ssl HTTPS_DOMAIN"
echo -e "\nUsage Example:"
echo -e " bash setup.ssl bi.dataops.tk"
if [[ -z "$1" ]]; then
    echo "ERROR: Missing HTTPS_DOMAIN argument. See usage instructions above."
    exit 1
fi
read -r -p "Continue? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "Continuing SSL config..."
        ;;
    *)
        echo "Exiting SSL config. (Aborted)"
        exit 0
        ;;
esac

HTTPS_DOMAIN=$1

export EMAIL=$(jq .email -r registration.json)
export TSM=/opt/tableau/tableau_server/packages/customer*/tsm
sudo certbot certonly --agree-tos \
    --webroot \
    -m $EMAIL \
    -d $HTTPS_DOMAIN \
    --webroot-path /var/opt/tableau/tableau_server/data/tabsvc/httpd/htdocs
if [[ $RETURN_CODE -ne 0 ]]; then
    echo "The certbot program reported an error while confirming the domain."
    echo "Please see logs above and confirm that you are properly routing traffic to this IP address."
    exit $RETURN_CODE
fi
sudo chmod 755 -R /etc/letsencrypt/live
sudo chmod 755 -R /etc/letsencrypt/archive
$TSM security external-ssl enable \
    --cert-file /etc/letsencrypt/live/$HTTPS_DOMAIN/fullchain.pem \
    --key-file /etc/letsencrypt/live/$HTTPS_DOMAIN/privkey.pem
RETURN_CODE=$?
echo -e "\nSSL Setup complete. Please scan above for any critical error messages.\n"
read -r -p "Would you like to apply changes and restart the Tableau Server now? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "Applying changes and rebooting Tableau Server..."
        $TSM pending-changes apply
        ;;
    *)
        echo "Processing completed, skipped Tableau Server reboot."
        exit 0
        ;;
esac
