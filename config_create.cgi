#!/usr/bin/perl

# FILE:  config_create.cgi
# DESCRIPTION: Form to proceed with the creation a new configuration, either from another existing configuration, or from a template.
#
# COMMENTS: provides a link to start editing the new configuration.
# It is called after config_create_select to inform about the creation.
require './amanda-lib.pl';


# Parameter parsing
&ReadParse();

# Webmin header
&header ($text{'config_creating_new'}, "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

&error_setup ($text{'config_creating_new'});

# We check the kind of creation and proceed accordingly
if ($in{'origin'} eq "from_template"){
	create_backup_config_from_template ($in{'config_name'});
}
elsif ($in{'origin'} eq "from_existing_config"){
	copy_backup_config ($in{'config_name'}, $in{'from_config'});
}
else{
	&error ("Invalid origin specified");
}

print (&text('config_creating_new_OK', "<A HREF=\"config_view.cgi?configuration=$in{'config_name'}\"> $in{'config_name'}</A>"));
print "<BR><HR>\n";

# The footer is shown
&footer ("configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

