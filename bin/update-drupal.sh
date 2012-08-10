#!/bin/sh -eu
#
# update-drupal.sh - update a Drupal-based site so it can be tested.
#

# Configure the base domain for CI jobs
ROOT="ci.example.com"

HTDOCS="${WORKSPACE}/htdocs"
URI="http://${JOB_NAME}.${ROOT}/"

DRUSH="drush --uri=\"$URI\" --root=\"$HTDOCS\""

CONN=$(drush --uri="$URI" --root="$HTDOCS" sql-connect | sed -Ee 's/ --/\n/g')
DBHOST=$(echo -- "$CONN" | grep '^host=' | cut -d= -f2)
DBNAME=$(echo -- "$CONN" | grep '^database=' | cut -d= -f2)
DBUSER=$(echo -- "$CONN" | grep '^user=' | cut -d= -f2 | cut -b1-16)
DBPASS=$(echo -- "$CONN" | grep '^password=' | cut -d= -f2)

# Database
if [ "$DBUSER" = "root" ]; then
	echo 'CANNOT USE root DATABASE USER!'
	exit 1
fi
echo "DROP DATABASE IF EXISTS ${DBNAME};" | mysql
mysqladmin create "${DBNAME}"
echo "GRANT ALL ON ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}'" | mysql
for dump in "${WORKSPACE}/dump"/*.sql; do
	mysql "${DBNAME}" < "${dump}"
done

# Files
find  "${HTDOCS}/sites" -maxdepth 2 -name settings.php -print0 | xargs -r -0 dirname | xargs -r -I % /bin/mkdir -p %/files
find  "${HTDOCS}/sites" -maxdepth 2 -name files -print0 | xargs -r -0 sudo /bin/chown -R :www-data
find  "${HTDOCS}/sites" -maxdepth 2 -name files -print0 | xargs -r -0 sudo /bin/chmod -R g+w

# Clear caches
drush --uri="$URI" --root="$HTDOCS" --quiet --yes cc all
