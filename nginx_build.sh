#!/bin/sh

if [ -z "$*" ]; then
    echo "Syntax: ./nginx_build.sh VERSION (optional: SERVERNAME)"
    echo "exit..."
    exit
fi

if [ -z "$(pgrep nginx)" ]; then
    echo "Nginx is not running"
    echo "exit..."
    exit
fi

if [ -z "$2" ]
    then
        server_name="nothing to see here, move along!"
    else
        server_name=$2
fi

inst_dir="/tmp/nginx"
help_file="help_file.sh"
version=$1
attr=`nginx -V 2>&1 | grep 'configure arguments' | cut -d " " -f3-`

echo -e "\n***************************************************************************"
echo "cd/mkdir $inst_dir"
if [ ! -d $inst_dir ]; then
    mkdir $inst_dir
fi
cd $inst_dir
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "create helpfile"
echo "./configure $attr" > $inst_dir/$help_file
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "wget nginx Version $version"
wget https://nginx.org/download/nginx-"$version".tar.gz
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "untar nginx"
tar -xzvf nginx-"$version".tar.gz
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "search and replace serverinfo"
sed -i 's/"Server: nginx" CRLF/"Server: '"$server_name"'" CRLF/g' nginx-"$version"/src/http/ngx_http_header_filter_module.c
sed -i 's/"Server: " NGINX_VER CRLF/"Server: '"$server_name"'" CRLF/g' nginx-"$version"/src/http/ngx_http_header_filter_module.c
sed -i 's/"Server: " NGINX_VER_BUILD CRLF/"Server: '"$server_name"'" CRLF/g' nginx-"$version"/src/http/ngx_http_header_filter_module.c
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo ".configure"
cd nginx-"$version"
chmod 700 ../$help_file 
../$help_file
mv ../$help_file ../$help_file.$version
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "make"
make
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "make install"
sudo make install
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo "restart nginx.service"
sudo systemctl restart nginx.service
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
nginx -v
echo -e "***************************************************************************\n"
