#!/bin/bash
test -f ./docker-compose.yml && echo "Fichier docker-compose.yml Présent" || echo "Téléchargement du docker-compose.yml" && wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/docker-compose.yml
GEOIPACCOUNT='cat docker-compose.yml | grep -o "GEOIPUPDATE_ACCOUNT_ID: xxxxxx" | wc -l'
GEOIPLICENSE='cat docker-compose.yml | grep -o "GEOIPUPDATE_LICENSE_KEY: xxxxxxxxxxxxxxxx | wc -l'
if [ -x "$(command -v docker)" ] && [ -x "$(command -v docker-compose)" ]; then
    echo "Docker est bien installer"
else
    echo "Veuillez installer docker et docker compose"
    exit 0
fi

if test -z "$GEOIPACCOUNT"  || test -z "$GEOIPLICENSE" || { test -z "$GEOIPACCOUNT"  && test -z "$GEOIPLICENSE"; } ;
then
    echo "Veuillez remplir les champs GEOIPUPDATE_ACCOUNT_ID et GEOIPUPDATE_LICENSE_KEY avant de relancer le script"
    exit 0
else
    docker-compose pull
    docker-compose up -d nginxpm
    sleep 20
    docker-compose down
    wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/compile-geoip2.sh
    mv compile-geoip2.sh ./data/data/
    chmod +x ./data/data/compile-geoip2.sh
    wget 
fi