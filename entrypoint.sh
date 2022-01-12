#!/bin/bash
timeout 20s /init 
test -f /etc/nginx/modules/geoip2.conf && echo "let's  go" || echo -e "load_module /etc/nginx/modules/ngx_http_geoip2_module.so;\nload_module /etc/nginx/modules/ngx_stream_geoip2_module.so;" > /etc/nginx/modules/geoip2.conf
test -f /data/nginx/custom/http_top.conf && echo "let's  go" || echo -e 'charset utf-8;\ngeoip2 /data/geoip2/GeoLite2-City.mmdb {\n auto_reload 3h;\n $geoip2_metadata_country_build metadata build_epoch;\n $geoip2_data_country_code default=XX source=$remote_addr country iso_code;\n $geoip2_data_country_name default=- country names fr;\n $geoip2_data_city_name default=- city names fr;\n $geoip2_data_region_name default=- subdivisions 0 names fr;\n}\ngeo $allowed_ip {\n default no;\n 192.168.1.0/24 yes;\n}\n \nmap $geoip2_data_country_code $allowed_country {\n default $allowed_ip;\n FR yes;\n}\nlog_format proxy_geo escape=json '"'"'[$time_local] [Client $remote_addr] [$allowed_country $geoip2_data_country_code $geoip2_data_country_name $geoip2_data_region_name $geoip2_data_city_name] "$http_user_agent" '"'"'\n                                 '"'"'$upstream_cache_status $upstream_status $status - $request_method $scheme $host "$request_uri" [Length $body_bytes_sent] [Gzip $gzip_ratio] [Sent-to $server] "$http_referer"'"'"';' > /data/nginx/custom/http_top.conf
apt-get update
apt-get install -y libmaxminddb0 libmaxminddb-dev
apt-get clean
rm -rf /var/lib/apt/lists/*
done