#!/usr/bin/perl

# FILE:  config_view.cgi
# DESCRIPTION: Main configuration form. From here the user, can enter any configuration submenu
#
# COMMENTS: Here you have the following options:
# - Admin options (like organization name, or info dir)
# - backup cycle options (like runs per cycle)
# - network options (like max backups in parallel)
# - tape options (like the tape device)
# - holding disks properties
# - disk list managing

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();

$actConfiguration = $in{'configuration'};

# Webmin header
&header (&text('config_view_title', $actConfiguration), "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# Load icons, links and text for the commands
@icons = ( "images/admin.gif", "images/cycle.gif", "images/network.gif", "images/icon.gif", "images/holding.gif", "images/disklist.gif", "images/icon.gif");
@links = ( "config_view_subindex.cgi?action=admin&configuration=$actConfiguration",
"config_view_subindex.cgi?action=cycle&configuration=$actConfiguration",
"config_view_subindex.cgi?action=network&configuration=$actConfiguration",
"config_view_subindex.cgi?action=tape&configuration=$actConfiguration",
"config_view_subindex.cgi?action=holdingdisks&configuration=$actConfiguration",
"config_view_subindex.cgi?action=disklist&configuration=$actConfiguration",
"config_view_subindex.cgi?action=tapelist&configuration=$actConfiguration");

@titles = ( $text{'config_view_subindex_admin'},
$text{'config_view_subindex_cycle'},
$text{'config_view_subindex_network'},
$text{'config_view_subindex_tape'},
$text{'config_view_subindex_holdingdisk'},
$text{'config_view_subindex_disklist'},
$text{'config_view_subindex_tapelist'});

# The table is shown
&icons_table(\@links, \@titles, \@icons, 6);



&footer ("configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

