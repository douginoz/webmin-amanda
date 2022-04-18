#!/usr/bin/perl

# FILE: amanda_debug_files.cgi
# DESCRIPTION: This form shows the amanda debug files.
#
# COMMENTS: it can present the dir contents or a file, depending on the command parameter

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$command = $in{'command'};
$debug_file = $in{'debug_file'};

# Webmin header
&header ("Amanda debug files", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# We decide whether to show the directory content or just one file, depending on command
if ($command eq "list_debug_dir_by_command"){
	#We show the directory contents grouping by command first
	print "<H2>Showing debug files grouped by command</H2>";
	$debuglist_ref = list_debug_dir_by_command();

	if ($debuglist_ref == -1){
		print "The debug directory was not found<BR>";
		print "Check the debug path in the module <A HREF=\"$gconfig{'webprefix'}/config.cgi?$module_name\">configuration</A><BR>";
	}
	elsif ((scalar keys %$debuglist_ref) == 0){
		# if no files are found
		print "No debug files were found<BR>";
		print "Check the debug path in the module <A HREF=\"$gconfig{'webprefix'}/config.cgi?$module_name\">configuration</A><BR>";
	}
	else{
		# for each Amanda command we show a list of debug files
		for $commandsD (sort keys %$debuglist_ref){
			print "<H3>$commandsD</H3>";
			# For each of the files of that command sorted by date
			for $fileD (reverse sort @{$debuglist_ref->{$commandsD}}){
				# We extract the date and time
				$fileD =~ /\w+\.(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/;
				print "<A HREF=amanda_debug_files.cgi?command=show_file&debug_file=$fileD>$1-$2-$3  $4:$5:$6<em>($fileD)</em></A><BR>";
			}
		}
	}

}
elsif ($command eq "list_debug_dir_by_date"){
	# We show the directory contents grouping by date first
	print "Not yet implemented <BR>";

}
elsif ($command eq "show_file"){
	# We show the contents of the chosen file
	print "<H2>Showing file $debug_file</H2>";
	$linesDebug = show_debug_file ($debug_file);

	$numLines = $#$linesDebug + 1;
	#print "<PRE>";
	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesDebug->[$i];
		print "$_<BR>";
	}
	#print "</PRE>";


}

print "<hr>";

# We show the footer
&footer ("", &text('return_to_index'));





