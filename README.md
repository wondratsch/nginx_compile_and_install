# nginx_compile_and_install

builds and installs nginx; also removes the 'Server'-Tag

prereqs:
up and running nginx (e.g. sudo dnf install nginx)

Fedora prereqs:
sudo dnf install gcc-c++ pcre-devel zlib-devel make wget openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools-devel redhat-rpm-config

usage:
./nginx_build.sh $version [optional: $server_name] (e.g. ./nginx_build.sh 1.13.2 apache)
