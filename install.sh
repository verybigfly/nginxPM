#!/bin/bash
test -f docker-compose.yml && echo "OK" || wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/docker-compose.yml
GEOIPACCOUNT=$(cat docker-compose.yml | grep -o "GEOIPUPDATE_ACCOUNT_ID: XXXXXX" | wc -l)
GEOIPLICENSE=$(cat docker-compose.yml | grep -o "GEOIPUPDATE_LICENSE_KEY: XXXXXXXXXXXXXXXXX" | wc -l)
if [ -x "$(command -v docker)" ] && [ -x "$(command -v docker-compose)" ]; then
    echo "Docker est bien installer"
else
    echo "Veuillez installer docker et docker compose"
    exit 0
fi

if [ "$GEOIPACCOUNT" == 1 ]  || [ "$GEOIPLICENSE" == 1 ] || { [ "$GEOIPACCOUNT" == 1 ]  && [ "$GEOIPLICENSE" == 1 ] ; } ; then
    echo "Veuillez remplir les champs GEOIPUPDATE_ACCOUNT_ID et GEOIPUPDATE_LICENSE_KEY avant de relancer le script"
    exit 0
else
    docker-compose pull
    docker-compose up -d nginxpm
    wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/compile-geoip2.sh
    mv compile-geoip2.sh ./data/data/
    chmod +x ./data/data/compile-geoip2.sh
    wget https://raw.githubusercontent.com/verybigfly/nginxPM-Custom/master/entrypoint.sh
    mv entrypoint.sh ./data/data/
    chmod +x ./data/data/entrypoint.sh
    sed -i '6i\    entrypoint: "/data/entrypoint.sh"' docker-compose.yml
    docker-compose up -d
    mkdir ./data/data/nginx/custom
    touch ./data/data/nginx/custom/http_top.conf
    echo -e 'charset utf-8;\ngeoip2 /data/geoip2/GeoLite2-City.mmdb {\n auto_reload 3h;\n $geoip2_metadata_country_build metadata build_epoch;\n $geoip2_data_country_code default=XX source=$remote_addr country iso_code;\n $geoip2_data_country_name default=- country names fr;\n $geoip2_data_city_name default=- city names fr;\n $geoip2_data_region_name default=- subdivisions 0 names fr;\n}\ngeo $allowed_ip {\n default no;\n 192.168.1.0/24 yes;\n}\n \nmap $geoip2_data_country_code $allowed_country {\n default $allowed_ip;\n FR yes;\n}\nlog_format proxy_geo escape=json '"'"'[$time_local] [Client $remote_addr] [$allowed_country $geoip2_data_country_code $geoip2_data_country_name $geoip2_data_region_name $geoip2_data_city_name] "$http_user_agent" '"'"'\n                                 '"'"'$upstream_cache_status $upstream_status $status - $request_method $scheme $host "$request_uri" [Length $body_bytes_sent] [Gzip $gzip_ratio] [Sent-to $server] "$http_referer"'"'"';' > ./data/data/nginx/custom/http_top.conf
    echo -e 'load_module /etc/nginx/modules/ngx_http_geoip2_module.so;\nload_module /etc/nginx/modules/ngx_stream_geoip2_module.so;' > ./data/modules/geoip2.conf
    echo -e 'if ($allowed_country = no) {\n	return 444;\n}'
    docker-compose restart
    echo "-------------------------------------------------"
    echo "-------------Installation Terminer---------------"
    echo "-------------------------------------------------"
    echo "Pour terminer la configuration veuillez ajouter :"
    echo "-------------------------------------------------" 
    echo "access_log /data/logs/proxy-host-%ID-HOST%_access-geo.log proxy_geo;"
    echo "-------------------------------------------------"
    echo "Dans la configuration avancée de chaque HOST en Web"
    echo "En Remplaçant %ID-HOST% par l'id du HOST"
    echo "Puis recharger la config de nginx avec :"
    echo "-------------------------------------------------"
    echo "docker exec -it nginxpm nginx -s reload"
    echo "-------------------------------------------------"
fi