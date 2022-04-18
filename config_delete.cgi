#!/usr/bin/perl

# FILE:  config_delete.cgi
# DESCRIPTION: Form to delete a configuration. First it asks for confirmation.
#
# COMMENTS: provides a link to confirm the deletion. In case it is clicked the form calls itself with the parameter confirmation=yes

require './amanda-lib.pl';

&error_setup ("Deleting config");

# Parameter parsing
&ReadParse();
$actConfiguration = $in{'configuration'};
$confirmation = $in{'confirmation'};

if ($confirmation eq "yes"){
	&header (&text ('config_deleting', $actConfiguration), "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));
	delete_backup_config ($actConfiguration);
	print ("Backup configuration $actConfiguration deleted OK<BR>");
}
else{
	&header (&text('config_delete', $actConfiguration), "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));
	print ("$text{'sure'}<BR>");
	print ("<A HREF=config_delete.cgi?configuration=$actConfiguration&confirmation=yes> $text{'config_delete_click'}</A>");

}

print "<hr>";

# The footer is shown
&footer ("configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));



