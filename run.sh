#!/bin/bash
test -f ./docker-compose.yml && echo "Fichier docker-compose.yml Présent" || echo "Téléchargement du docker-compose.yml" && wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/docker-compose.yml
test -f ./Dockerfile && echo "Fichier Dockerfile Présent" || echo "Téléchargement du docker-compose.yml" && wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/Dockerfile
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
    docker-compose build
    docker-compose up -d
    sleep 20
    docker-compose down
    test -d ./data/nginx/custom/ && echo "let's go" || mkdir ./data/nginx/custom/
    test -d ./data/nginx/custom/ && echo "let's go" || mkdir ./data/nginx/custom/
    test -f ./modules/geoip2.conf && echo "let's  go" || echo -e "load_module /etc/nginx/modules/ngx_http_geoip2_module.so;\nload_module /etc/nginx/modules/ngx_stream_geoip2_module.so;" > ./modules/geoip2.conf
    test -f ./data/nginx/custom/http_top.conf && echo "let's  go" || echo -e 'charset utf-8;\ngeoip2 /data/geoip2/GeoLite2-City.mmdb {\n auto_reload 3h;\n $geoip2_metadata_country_build metadata build_epoch;\n $geoip2_data_country_code default=XX source=$remote_addr country iso_code;\n $geoip2_data_country_name default=- country names fr;\n $geoip2_data_city_name default=- city names fr;\n $geoip2_data_region_name default=- subdivisions 0 names fr;\n}\ngeo $allowed_ip {\n default no;\n 192.168.1.0/24 yes;\n}\n \nmap $geoip2_data_country_code $allowed_country {\n default $allowed_ip;\n FR yes;\n}\nlog_format proxy_geo escape=json '"'"'[$time_local] [Client $remote_addr] [$allowed_country $geoip2_data_country_code $geoip2_data_country_name $geoip2_data_region_name $geoip2_data_city_name] "$http_user_agent" '"'"'\n                                 '"'"'$upstream_cache_status $upstream_status $status - $request_method $scheme $host "$request_uri" [Length $body_bytes_sent] [Gzip $gzip_ratio] [Sent-to $server] "$http_referer"'"'"';' > ./data/nginx/custom/http_top.conf
    docker-compose up -d
fi