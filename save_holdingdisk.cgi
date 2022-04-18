#!/usr/bin/perl

# FILE:  save_holdingdisk.cgi
# DESCRIPTION: Form that saves a holding disk. It is called from holdingdisk.cgi
#
# COMMENTS:

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$actName = $in{'name'};
$actConfiguration = $in{'configuration'};

# Webmin header
&header ("Saving holding disk", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# Parsing of the characteristics of the holding disk that is about to be created / modified
local %hdisk;
$hdisk{'name'} = $actName;
$hdisk{'comment'} = $in{'comment'};
$hdisk{'directory'} = $in{'directory'};
$hdisk{'use'} = $in{'use'};
$hdisk{'chunksize'} = $in{'chunksize'};

# We check for empty holding disk name
if (!$actName){
   print "Error: empty holding disk name<BR><HR>";
}
else{
   save_holdingdisk_to_conf ($actConfiguration, \%hdisk);
   print "OK<BR><HR>";
}

# The footer is shown
&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

