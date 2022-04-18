#!/usr/bin/perl

# FILE:  holdingdisk_delete.cgi
# DESCRIPTION: Form to delete a holding disk. 
#
# COMMENTS: 
require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$actName = $in{'name'};
$actConfiguration = $in{'configuration'};

# Webmin header
&header ("Delete holding disk ($actName)", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

delete_holdingdisk_from_conf ($actConfiguration, $actName);

print ("$actName Deleted OK");

# The footer is shown
&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));


