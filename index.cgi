#!/usr/bin/perl

# FILE: index.cgi
# DESCRIPTION: Index form. Lets you go to configuration options, check current backup status, etc
#
# COMMENTS: This is the main page of the module. From here, you can go everywhere.
require './amanda-lib.pl';


# We look for the amanda executables.
# If the path is not configured, we give the oportunity to go to the module configuration page
if (!$amadmin_path){
   &header (&text('index_title'), "", undef, 1, 1);
   print "<hr>\n";
   print "<p>",&text('index_no_amanda',"$gconfig{'webprefix'}/config.cgi?$module_name"),"<p>\n";
   print "<hr>\n";
   exit;

}

# We get the amanda version.
$amanda_version = get_amanda_version();
# We show the Webmin header
if ($amanda_version){
   &header (&text('index_title'), "", undef, 1, 1, undef, &help_search_link ("amanda", "man", "doc"), undef, undef, $amanda_version);
}
else{
   &header (&text('index_title'), "", undef, 1, 1, undef, &help_search_link ("amanda", "man", "doc"));
}


# Show configuration icons
# In general options, you can set general options for amanda. CVurrently, it shows the status of the server services (inetd and services)
# in configs, you can edit or view each configuration settings (amanda.conf and disklist)
# in status_check you can check the logs and status of amanda and backup runs (maybe it is better to put it into manage...)
# in mange configurations you will be able to make all thw normal operations for a given configuration...
# - label tapes, run amdump, amflush, amadmin, ...
@icons = ( "images/config.gif", "images/configs.gif", "images/status_check.gif", "images/config.gif");
@links = ( "config_general.cgi", "configs.cgi", "status_check.cgi", "manage.cgi");
@titles = ( $text{'general_config_title'}, $text{'configs_title'}, $text{'status_check_title'}, "Manage configurations (not ready)");
&icons_table(\@links, \@titles, \@icons, 4);

# The footer is shown
&footer ("/", &text('index_return'));


