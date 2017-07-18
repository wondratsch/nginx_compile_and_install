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
timestamp=`date +%Y%m%d%H%M%S`
version=$1
attr=`nginx -V 2>&1 | grep 'configure arguments' | cut -d " " -f3-`

echo -e "\n***************************************************************************"
if [ ! -d $inst_dir ]; then
    echo "mkdir $inst_dir"
    mkdir $inst_dir
fi

if [ ! -r $inst_dir ]; then
    echo "$inst_dir is not readable for $USER"
    echo "Changing Ownership to user $USER"
    read -p "Continue? [y/n]" choice
    case "$choice" in
        y|Y ) echo "chown $USER $inst_dir"; sudo chown $USER $inst_dir;;
        n|N ) echo "please fix permissions for $inst_dir manually"; exit;;
        * ) echo "invalid answer; exit."; exit;;
    esac
fi
cd $inst_dir
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
if [ ! -r nginx-"$version".tar.gz ]
    then
        if [ ! -f nginx-"$version".tar.gz ]
            then
                echo "wget nginx $version"
                wget https://nginx.org/download/nginx-"$version".tar.gz
                if [ ! $? -eq 0 ]; then
                    echo "something with wget went wrong; exit."
                    exit
                fi
            else
                echo "nginx-"$version".tar.gz in $inst_dir is not readable for $USER"
                echo "Removing file and reload it from nginx.org"
                read -p "Continue? [y/n]" choice
                case "$choice" in
                    y|Y ) echo "rm nginx-"$version".tar.gz && wget nginx $version"; sudo rm nginx-"$version".tar.gz && wget https://nginx.org/download/nginx-"$version".tar.gz;;
                    n|N ) echo "please fix permissions for nginx-"$version".tar.gz manually"; exit;;
                    * ) echo "invalid answer; exit."; exit;;
                esac
        fi
    else
        echo "nginx-$version.tar.gz exists and has read permission"
fi
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
echo "create helpfile"
echo "./configure $attr" > $inst_dir/$help_file
echo "DONE!"
echo -e "***************************************************************************\n"

echo -e "\n***************************************************************************"
echo ".configure"
cd nginx-"$version"
chmod 700 ../$help_file 
../$help_file
mv ../$help_file ../$help_file.$version.$timestamp
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
