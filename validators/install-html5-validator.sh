#!/bin/sh -e
#
# Install the validator.nu HTML5 validator.
#

DEST="/usr/local/html5-validator"

# Install into the appropriate directory
mkdir -p "${DEST}"
cd "${DEST}"

# Install JDK. There are probably other dependencies that should be installed
# here.
sudo aptitude install openjdk-6-jre-headless

# Checkout the build script and a dependency it doesn't seem to fetch itself.
hg clone https://bitbucket.org/validator/build build
if [ ! -d jing-trang ]; then
	hg clone --branch validator-nu https://bitbucket.org/validator/jing-trang jing-trang
fi

# Build the software
python build/build.py all
python build/build.py all
