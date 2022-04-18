#!/usr/bin/perl

# FILE: status_check_command.cgi
# DESCRIPTION: Shows the result of the selected command for a given configiration
#
# COMMENTS:
# Changed su commands to work under ubuntu 20

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$actConfiguration = $in{'configuration'};
$actCommand = $in{'command'};

# Webmin header
&header ("Misc. status", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# We execute the solicited command, redirecting its standard output and standard error
# to two files, that can be read afterwards
if ($actCommand eq "amcheck"){
        print "<H2>Performing self-check ($actConfiguration)...</H2>";
        print "This may take some time, so please be patient<BR>";
        system("sudo -u $amanda_user $amanda_exec_path/amcheck -s -c $actConfiguration > ammisc.stdout 2>ammisc.stderr");
}
elsif ($actCommand eq "amoverview"){
        print "<H2>Showing Amanda Backups overview ($actConfiguration)...</H2>";
        print "This may take some time, so please be patient<BR>";
        system("sudo -u $amanda_user $amanda_exec_path/amoverview $actConfiguration > ammisc.stdout 2>ammisc.stderr");
}
elsif ($actCommand eq "amcheckdb"){
        print "<H2>Checking database for tape consistency($actConfiguration)...</H2>";
        print "This may take some time, so please be patient<BR>";
        system("sudo -u $amanda_user $amanda_exec_path/amcheckdb $actConfiguration > ammisc.stdout 2>ammisc.stderr");
}
elsif ($actCommand eq "amadmin_info"){
        print "<H2>Current info records ($actConfiguration)...</H2>";
        print "This may take some time, so please be patient<BR>";
        system("sudo -u $amanda_user $amanda_exec_path/amadmin $actConfiguration info > ammisc.stdout 2>ammisc.stderr");
}
elsif ($actCommand eq "amadmin_tape"){
        print "<H2>Next tape due ($actConfiguration)...</H2>";
        print "This may take some time, so please be patient<BR>";
        system("sudo -u $amanda_user $amanda_exec_path/amadmin $actConfiguration tape > ammisc.stdout 2>ammisc.stderr");
}
elsif ($actCommand eq "amadmin_disklist"){
        print "<H2>Disklist entries ($actConfiguration)...</H2>";
        print "This may take some time, so please be patient<BR>";
        system("sudo -u $amanda_user $amanda_exec_path/amadmin $actConfiguration disklist > ammisc.stdout 2>ammisc.stderr");
}
else{
        print "Unrecognized command";
}

# We show the result.
open ($status_stdout, "ammisc.stdout");
open ($status_stderr, "ammisc.stderr");
print "<pre>";
while (<$status_stdout>){
	print ("$_");
}
while (<$status_stderr>){
	print ("$_");
}
print "</pre>";

# The temporary files are closed and deleted
close ($status_stdout);
close ($status_stderr);

unlink ("ammisc.stdout");
unlink ("ammisc.stderr");

# We show the links for the rest of the amanda check / view commands (amcheck, amoverview, amcheckdb, amadmin, ...)
print "<BR><hr>";
print "<H3>More status checks</H3>";
print "<A HREF=status_check_command.cgi?configuration=$actConfiguration&command=amcheck>Run self-check <em>(amcheck)</em></A><BR>";
print "<A HREF=status_check_command.cgi?configuration=$actConfiguration&command=amoverview>Overview <em>(amoverview)</em></A><BR>";
print "<A HREF=status_check_command.cgi?configuration=$actConfiguration&command=amcheckdb>Check database <em>(amcheckdb)</em></A><BR>";
print "<A HREF=status_check_command.cgi?configuration=$actConfiguration&command=amadmin_info>Misc. info <em>(amadmin info)</em></A><BR>";
print "<A HREF=status_check_command.cgi?configuration=$actConfiguration&command=amadmin_tape>Show next tape due <em>(amadmin tape)</em></A><BR>";
print "<A HREF=status_check_command.cgi?configuration=$actConfiguration&command=amadmin_disklist>Show disklist entries <em>(amadmin disklist)</em></A><BR>";

print "<hr>";

# The footer is shown
&footer ("", &text('return_to_index'));


