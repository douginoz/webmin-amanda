#!/usr/bin/perl

# FILE: save_config.cgi
# DESCRIPTION: Form that preprocesses and saves the configuration. Depending on the ACTION, a group of options is saved. It is called from
# the config_view_subindex, when disklist is selected as action
#
# COMMENTS: It does not manage neither the holding disks nor the disk list

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$actConfiguration = $in{'configuration'};
$actAction = $in{'action'};

# Webmin header
&header (&text('config_save_title', "$actConfiguration"), "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# Admin options?
if ($actAction eq "admin"){
	&error_setup ("Saving admin options: ");
	$adminOptions{'org'} = $in{'organization'};
	$adminOptions{'mailto'} = $in{'mailto'};
	$adminOptions{'dumpuser'} = $in{'dumpuser'};
	$adminOptions{'infofile'} = $in{'infodir'};
	$adminOptions{'logdir'}= $in{'logdir'};
	$adminOptions{'indexdir'} = $in{'indexdir'};

	save_admin_options_to_conf($actConfiguration);
}
# Cycle options?
elsif ($actAction eq "cycle"){
	&error_setup ("Saving cycle options: ");
	$cycleOptions{'dumpcycle'} = $in{'dumpcycle'};
	$cycleOptions{'dumpcycleweekorday'} = $in{'dumpcycleweekorday'};
	$cycleOptions{'runspercycle'} = $in{'runspercycle'};
	$cycleOptions{'tapecycle'} = $in{'tapecycle'};
	$cycleOptions{'bumpsize'} = $in{'bumpsize'};
	$cycleOptions{'bumpdays'}= $in{'bumpdays'};
	$cycleOptions{'bumpmult'} = $in{'bumpmult'};
	save_cycle_options_to_conf($actConfiguration);
}
# Network options?
elsif ($actAction eq "network"){
	&error_setup ("Saving network options: ");
	$networkOptions{'inparallel'} = $in{'inparallel'};
	$networkOptions{'netusage'} = $in{'netusage'};
	$networkOptions{'ctimeout'} = $in{'ctimeout'};
	$networkOptions{'dtimeout'} = $in{'dtimeout'};
	$networkOptions{'etimeout'} = $in{'etimeout'};
	save_network_options_to_conf($actConfiguration);
}

# Tape options?
# This is another way to enter the data, but it is not very clean, I think
elsif ($actAction eq "tape"){
	&error_setup ("Saving tape options: ");
	for $kkkey (keys %in){
		$tapeOptions{$kkkey} = $in{$kkkey};
	}
	save_tape_options_to_conf ($actConfiguration);
}

print "OK";

# The footer is shown
&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

