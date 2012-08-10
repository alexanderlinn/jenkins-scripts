#!/bin/sh -eu
#
# update-spip.sh - update a SPIP-based site so it can be tested.
#

HTDOCS="${WORKSPACE}/htdocs"

# Find the database configuration details
eval $(cd "${HTDOCS}"; php "${HOME}/spip-database.php")

# Check database credentials
if [ "$DBUSER" = "root" ]; then
	echo 'CANNOT USER root DATABASE USER!'
	exit 1
fi
DBUSER=$(echo "$DBUSER" | cut -b1-16)

# Wipe the database clean
echo "DROP DATABASE IF EXISTS ${DBNAME};" | mysql
mysqladmin create "${DBNAME}"
echo "GRANT ALL on ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}'" | mysql
for dump in "${WORKSPACE}/dump"/*.sql; do
	mysql "${DBNAME}" < "${dump}"
done

# Clear any generated files
if [ -d "${HTDOCS}/local" ]; then
	find "${HTDOCS}/local" -maxdepth 1 -mindepth 1 -print0 | xargs -0 sudo -u www-data rm -rf
	rmdir "${HTDOCS}/local"
fi
if [ -d "${HTDOCS}/tmp" ]; then
	find "${HTDOCS}/tmp" -maxdepth 1 -mindepth 1 -print0 | xargs -0 sudo -u www-data rm -rf
	rmdir "${HTDOCS}/tmp"
fi

# Create generated file directories
mkdir -p "${HTDOCS}/local" "${HTDOCS}/tmp"
chmod -R g+ws,o+w "${HTDOCS}/IMG" "${HTDOCS}/local" "${HTDOCS}/tmp"
