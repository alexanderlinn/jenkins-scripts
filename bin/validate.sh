#!/bin/sh -ue
#
# validate.sh - mirror a site and pump the HTML through the W3C validator.
#
# Change the value of ENDPOINT to point to your own private installation of the
# W3C Markup Validator. You'll need to add support for checkstyle XML output.
#
# Invoke this script with the URI of the site to validate as the first
# argument.

ENDPOINT="http://example.com/w3c-validator/check"

BASE="$1"

LOG="${WORKSPACE}/logs"
MIRROR="${WORKSPACE}/mirror"

# Applications
CURL="curl --silent"
WGET="wget --mirror --no-verbose --directory-prefix=${MIRROR}"

# Create a static mirror of the site.
rm -rf "${MIRROR}"
mkdir "${MIRROR}"
$WGET "$BASE"

# Submit the files to the validator.
rm -rf "${LOG}"
mkdir -p "${LOG}"

find "${MIRROR}" -type f -print0 | xargs -0 file --mime-type | \
egrep ':[[:space:]]*text/html$' | cut -d: -f1 | while read URI; do
  name=$(echo "$URI" | md5sum | cut -d\  -f1)

  # Validate the file.
  $CURL --data-urlencode "output=checkstyle" --data-urlencode "uploaded_file@$URI" \
    "${ENDPOINT}" > "${LOG}/${name}.checkstyle.xml"

  # Delete invalid validation reports. #lesigh
  type=$(file --brief --mime-type "${LOG}/${name}.checkstyle.xml")
  if [ "$type" != "application/xml" ]; then
    echo "COULD NOT VALIDATE ${URI}!"
    mv "${LOG}/${name}.checkstyle.xml" "${LOG}/${name}.checkstyle.html"
  else
    echo "${name} ${URI}"
    sed -i~ -Ee "s#<file name=\"([^\"]+)\">#<file name=\"${URI}\">#" "${LOG}/${name}.checkstyle.xml"
  fi

done
