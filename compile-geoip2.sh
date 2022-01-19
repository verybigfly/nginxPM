#!/bin/bash
apt-get install -y wget libpcre3 libpcre3-dev libssl-dev zlib1g-dev

ngxversion=openresty-$(/etc/nginx/bin/openresty -v 2>&1|cut -d "/" -f2)

mkdir /tmp/compile && cd /tmp/compile
wget https://openresty.org/download/$ngxversion.tar.gz
tar xvf $ngxversion.tar.gz

mkdir /tmp/compile/$ngxversion/modules
cd /tmp/compile/$ngxversion/modules
git clone https://github.com/leev/ngx_http_geoip2_module.git

cd ../bundle/nginx-$(/etc/nginx/bin/openresty -v 2>&1|cut -d "/" -f2|grep -oP '^\d*\.\d*\.\d*')
export LUAJIT_LIB="/etc/nginx/luajit/lib/"
export LUAJIT_INC="../LuaJIT-*/src/"
COMPILEOPTIONS=$(/etc/nginx/bin/openresty -V 2>&1|grep -i "arguments"|cut -d ":" -f2-)
eval ./configure $COMPILEOPTIONS --add-dynamic-module=../../modules/ngx_http_geoip2_module
make

cp -f objs/ngx_stream_geoip2_module.so /etc/nginx/modules/
cp -f objs/ngx_http_geoip2_module.so /etc/nginx/modules/
rm -f /etc/nginx/modules/ngx_geoip2_*
touch /etc/nginx/modules/ngx_geoip2_$ngxversion

rm -rf /tmp/compile	