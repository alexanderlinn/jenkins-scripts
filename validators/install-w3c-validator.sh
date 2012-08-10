#!/bin/sh -e
#
# Install the W3 markup validator.
#

# Directory to install code
DEST=/usr/local/validator
# Directory to install configuration
CONF=/etc/w3c


####
# INSTALL DEPENDENCIES
###

# Debian 6 packages
sudo aptitude install perl opensp libosp-dev libxml2 libxml2-dev \
	libapache2-mod-perl2 libyaml-perl libcgi-pm-perl libconfig-general-perl \
	libhtml-parser-perl libhtml-template-perl libjson-perl libwww-perl \
	libnet-ip-perl liburi-perl libhtml-tidy-perl libio-socket-ssl-perl \
	libnet-ssleay-perl

# Perl modules from CPAN
sudo cpan SGML::Parser::OpenSP XML::LibXML HTML::Encoding Encode::JIS2K \
	Encode::HanExtra

####
# DOWNLOAD VALIDATOR CODE
####

if [ ! -f "validator.tar.gz" ]; then
wget http://validator.w3.org/validator.tar.gz
fi
if [ ! -f "sgml-lib.tar.gz" ]; then
wget http://validator.w3.org/sgml-lib.tar.gz
fi

TMP=validator-code

rm -rf $TMP
mkdir -p $TMP
tar -xf validator.tar.gz --strip-components=1 -C $TMP
tar -xf sgml-lib.tar.gz --strip-components=1 -C $TMP

####
# INSTALL CODE
####

sudo mkdir -p "$DEST"
sudo rsync -a $TMP/htdocs $DEST
sudo rsync -a $TMP/httpd/cgi-bin $DEST
sudo rsync -a $TMP/httpd $DEST
sudo rsync -a $TMP/share $DEST

# Cache dirs
sudo mkdir -p $DEST/cache
sudo chmod 777 $DEST/cache


####
# INSTALL CONFIGURATION
####

# Create config files
sudo mkdir -p $CONF
sudo rsync -a $DEST/htdocs/config/ $CONF
sudo rsync -a $TMP/httpd/config/ $CONF/httpd

####
# ENABLE WEB SERVER
####

# Configure Apache
sudo a2enmod perl
sudo ln -s $CONF/httpd/httpd.conf /etc/apache2/conf.d/w3c-validator.conf
sudo apache2ctl graceful

