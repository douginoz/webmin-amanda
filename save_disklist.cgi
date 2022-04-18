#!/usr/bin/perl

# FILE: save_disklist.cgi
# DESCRIPTION: Form that processes and saves the disk list
#
# COMMENTS: It is so easy because it passes the arguments directly to save_disklist_to_conf function, that takes the %in
# hash as input. Nothing more to be done here, now

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$actConfiguration = $in{'configuration'};

# Webmin header
&header ("Saving disklist ($actConfiguration)", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# The disklist is saved to the file.
save_disklist_to_conf ($actConfiguration, \%in);

print "OK<BR><hr>";

# The footer is shown
&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

