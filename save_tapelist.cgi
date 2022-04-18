#!/usr/bin/perl

# FILE: save_tapelist.cgi
# DESCRIPTION: Form that processes and saves the tape list
#
# COMMENTS: It is so easy because it passes the arguments directly to save_tapelist_to_conf function, that takes the %in
# hash as input. Nothing more to be done here, now

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();

$actConfiguration = $in{'configuration'};

# Webmin header
&header ("Saving tapelist ($actConfiguration)", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# The tapelist is saved to the file.
save_tapelist_to_conf ($actConfiguration, \%in);

print "OK<BR><hr>";


&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

