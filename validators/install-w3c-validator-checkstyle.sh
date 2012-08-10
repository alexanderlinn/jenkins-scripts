#!/bin/sh -eu
#
# install-w3c-validator-checkstyle.sh
#
# Install a template to output W3C HTML validator in checkstyle XML format.
#

DEST="/usr/local/validator"

# Add the checkstyle XML template.
cat <<-EOF > "${DEST}/share/templates/en_US/checkstyle_output.tmpl"
	Content-Type: application/xml; charset=UTF-8
	X-W3C-Validator-Recursion: <TMPL_VAR NAME="depth" DEFAULT="1"><TMPL_IF NAME="fatal_error">
	X-W3C-Validator-Status: Abort<TMPL_ELSE><TMPL_IF NAME="valid_status">
	X-W3C-Validator-Status: <TMPL_VAR NAME="valid_status"></TMPL_IF>
	X-W3C-Validator-Errors: <TMPL_VAR NAME="valid_errors_num">
	X-W3C-Validator-Warnings: <TMPL_VAR NAME="valid_warnings_num"></TMPL_IF>

	<?xml version="1.0" encoding="UTF-8"?>
	<checkstyle version="1.3.4">
		<file name="<TMPL_VAR NAME="file_uri">">
		<TMPL_LOOP NAME="file_errors">
			<error line="<TMPL_VAR NAME="line" ESCAPE="HTML">" column="<TMPL_VAR NAME="char" ESCAPE="HTML">" <TMPL_IF NAME="err_type_err">severity="error"<TMPL_ELSE><TMPL_IF NAME="err_type_warn">severity="warning"<TMPL_ELSE>severity="info"</TMPL_IF></TMPL_IF> source="<TMPL_VAR NAME="num">" message="<TMPL_VAR NAME="msg" ESCAPE="HTML">" />
	</TMPL_LOOP>
		</file>
	</checkstyle>
EOF

# Patch the CGI script to use the new template.
patch <<EOF
--- check	2012-03-12 23:03:14.000000000 +0800
+++ $DEST/cgi-bin/check	2012-07-27 12:22:19.000000000 +0800
@@ -767,6 +767,7 @@
     n3   => ['earl_n3.tmpl'],
     json => ['json_output.tmpl'],
     ucn  => ['ucn_output.tmpl'],
+    checkstyle => ['checkstyle_output.tmpl', default_escape => 'HTML'],
 );
 my $template = $templates{$File->{Opt}->{Output}};
 if ($template) {
EOF
