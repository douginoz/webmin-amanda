#!/usr/bin/perl

# FILE: amlabel.cgi
# DESCRIPTION: Shows the current state of the existing amanda configurations.
#
# COMMENTS: it is like the exit of the amstatus command.
# It lets the user choose some more status info.
# - It should be refreshed every X seconds. Now, it must be refreshed manually.

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();

CHECK_INIT:
# Webmin header
&header ("$in{'tapeoption'} tape", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

if ($in{'tapeoption'} eq "label"){
	system("su $amanda_user -c \"$amanda_exec_path/amlabel $configuration $in{'new_label'}\" > amstatus.stdout 2> amstatus.stderr");
	open ($status_stderr, "amstatus.stderr");
	open ($status_stdout, "amstatus.stdout");

	print "<pre>";
	while (<$status_stderr>){
		if (/No such file or directory/i){
			print "No running dump for configuration $configuration";
			last;
		}
		if (/errors processing config/i){
			print "Error found in $configuration config file";
			last;
		}
	}
	print "<BR>";

	while (<$status_stdout>){
		print ("$_");
	}
	print "</pre>";
	close ($status_stderr);
	close ($status_stdout);
	print "<HR>";
}
if (($in{'tapeoption'} eq "retension") || ($in{'tapeoption'} eq "erase")){
        print "/usr/bin/mt -f $in{'tapedev'} $in{'tapeoption'}<BR>";
        system("su $amanda_user -c \"/usr/bin/mt -f $in{'tapedev'} $in{'tapeoption'} \" > amstatus.stdout");
	if ($? == 0) {
        print "OK<BR><BR>";
	}
	else {
        print "Failed!<BR><BR>",
	}
        open ($status_stdout, "amstatus.stdout");

        print "<pre>";
        while (<$status_stdout>){
                print ("$_");
        }
        print "</pre>";
        close ($status_stdout);
        print "<HR>";
}

# Delete the temporary output files
unlink ("amstatus.stderr");
unlink ("amstatus.stdout");

print "<hr>";

&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'))



