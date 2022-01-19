#!/bin/bash
apt-get update
apt-get install -y libmaxminddb0 libmaxminddb-dev

echo "=>Check for GeoIP modules files and version flag..."
set -- /etc/nginx/modules/ngx_geoip2_*
if [[ -f /etc/nginx/modules/ngx_http_geoip2_module.so && -f /etc/nginx/modules/ngx_stream_geoip2_module.so && -f "$1" ]]; then
        moduleversion=$(echo $1|cut -d "-" -f2|grep -oP '^\d*\.\d*\.\d*')
        ngxversion=$(/etc/nginx/bin/openresty -v 2>&1|cut -d "/" -f2|grep -oP '^\d*\.\d*\.\d*')
        if [ "$moduleversion" != "$ngxversion" ]; then
                echo "!=>GeoIP modules ($moduleversion) and nginx ($ngxversion) version mismatch !"
                echo "!=>Starting compilation !"
                /data/compile-geoip2.sh
        else
                echo "=>GeoIP modules found and version match nginx !"
        fi
else
        echo "!=>No GeoIP module found !"
        echo "!=>Starting compilation !"
        /data/compile-geoip2.sh
fi

apt-get clean
rm -rf /var/lib/apt/lists/*

set -- /etc/nginx/modules/ngx_geoip2_*
moduleversion=$(echo $1|cut -d "-" -f2|grep -oP '^\d*\.\d*\.\d*')
ngxversion=$(/etc/nginx/bin/openresty -v 2>&1|cut -d "/" -f2|grep -oP '^\d*\.\d*\.\d*')
echo "### GeoIP Modules $moduleversion - Nginx $ngxversion ###"
echo "### Starting NPM orignal entrypoint ###"
/init