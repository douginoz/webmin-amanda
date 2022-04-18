#!/usr/bin/perl

# FILE: status_check.cgi
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
&header ("Check status", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# For each amanda configuration, we check its status through the amstatus command. The output from this program is
# redirected to two temporal files (amstatus.stdout and amstatus.stderr), and once finished, this output is shown in the form
@configurations = get_amanda_backup_configurations();
foreach $configuration (@configurations){
	print "<H2>Backup configuration $configuration</H2>";
	print "<H3>Current status</H3>";
#	$result = qx(su $amanda_user -c "$amanda_exec_path/amstatus $configuration");
	system(system("sudo -u $amanda_user $amanda_exec_path/amstatus $configuration > amstatus.stdout 2> amstatus.stderr");
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

	# We show the links for the rest of the amanda check / view commands (amcheck, amoverview, amcheckdb, amadmin, ...)
	print "<BR>";
	print "<H3>Other status checks</H3>";
	print "<A HREF=status_check_command.cgi?configuration=$configuration&command=amcheck>Run self-check <em>(amcheck)</em></A><BR>";
	print "<A HREF=status_check_command.cgi?configuration=$configuration&command=amoverview>Overview <em>(amoverview)</em></A><BR>";
	print "<A HREF=status_check_command.cgi?configuration=$configuration&command=amcheckdb>Check database <em>(amcheckdb)</em></A><BR>";
	print "<A HREF=status_check_command.cgi?configuration=$configuration&command=amadmin_info>Misc. info <em>(amadmin info)</em></A><BR>";
	print "<A HREF=status_check_command.cgi?configuration=$configuration&command=amadmin_tape>Show next tape due <em>(amadmin tape)</em></A><BR>";
	print "<A HREF=status_check_command.cgi?configuration=$configuration&command=amadmin_disklist>Show disklist entries <em>(amadmin disklist)</em></A><BR>";
	print "<A HREF=amanda_debug_files.cgi?command=list_debug_dir_by_command>View Amanda debug files</A><BR>";
	print "<HR>";
}

# Delete the temporary output files
unlink ("amstatus.stderr");
unlink ("amstatus.stdout");

# The footer is shown
&footer ("", &text('return_to_index'));



