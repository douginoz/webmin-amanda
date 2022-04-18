#!/usr/bin/perl

# FILE:  config_general.cgi
# DESCRIPTION: This is now just a test CGI, to show the amanda services status
#
# COMMENTS: Much work has to be done here. 
# Maybe it can be the starting point for a general configuration Wizard, to assist in the whole setup process


require './amanda-lib.pl';

# Parameter parsing
&ReadParse();

# Webmin header
&header ("Config general", "", undef, 1, 1, undef, &help_search_link ("amanda", "man", "doc"));

%status = get_amanda_services_status();
foreach (keys (%status)){
	print ("$_: ");
	print ("$status{$_}<BR>");
}

# The footer is added
&footer ("", &text('return_to_index'));

