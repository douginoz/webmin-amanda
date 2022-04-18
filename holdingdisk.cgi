#!/usr/bin/perl

# FILE:  holdingdisk.cgi
# DESCRIPTION: Form that lets the user do the action requested in a holding disk in the config_view_subindex.cgi form.
# Depending on the ACTION it can perform any of the following actions:
#	- Create a new holding disk
#  - Edit an existing holding disk
#  - Delete an existing holding disk
#
# COMMENTS:

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();
$actName = $in{'name'};
$actAction = $in{'action'};
$actConfiguration = $in{'configuration'};

# Decision of which function to call depending on the action parameter
if ($actAction eq "create"){
	holdingdisk_action_create();
}
elsif ($actAction eq "edit"){
	holdingdisk_action_edit();
}
elsif ($actAction eq "delete"){
	holdingdisk_action_delete();
}

# The footer is shown
&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));


# NAME: holdingdisk_action_create
# DESCRIPTION: creates a form to create a new holding disk
# PARAMETERS: -
# RETURN: -
sub holdingdisk_action_create
{
	# Webmin header
	&header ("Create new holding disk", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));
	# We show the form that permits the creation of a new holding disk
	# The CGI to process the data will be the same as in the editting case
	print "<form action=save_holdingdisk.cgi>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<table border >\n";
	print "<tr $tb> <td><b>Holding disk parameters</b></td> </tr>\n";
	print "<tr $cb> <td><table width=100%>\n";
	print "<tr $cb> <td> Name </td> <td><input type=text size=50 name=name></td><td>Some help here";
	print "<tr $cb> <td> Comment </td> <td><input type=text size=50 name=comment>";
	printf "<tr $cb> <td> Directory </td> <td><input size=50 name=directory> %s", &file_chooser_button("directory", 1);
	print "<tr $cb> <td> Available space </td> <td><input size=8 name=use>";
	print "<tr $cb> <td> Chunk size </td> <td><input size=8 name=chunksize>";
	print "</table></td></tr></table>";
	print "<input type=submit value='$text{'save'}'>\n";
	print "</form>";

	return 1;
}


# NAME: holdingdisk_action_edit
# DESCRIPTION: creates a form to edit an existing holding disk
# PARAMETERS: -
# RETURN: -
sub holdingdisk_action_edit
{
	local @hdisks;
	local $hdiskRef;
	local $hdiskEdit;

	# We search for the selected holding disk in the list of existing holding disks
	@hdisks = get_holdingdisks_from_conf ($actConfiguration);
	for $hdiskRef (@hdisks){
		if ($hdiskRef->{'name'} eq $actName){
			$hdiskEdit = $hdiskRef;
			last;
		}
	}

	# Webmin header
	&header ("Edit holding disk ($actName)", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));
	# We show the form to edit the holding disk. It is the same as in the creation, but it has existing values. The name cannot be changed
	# The CGI to process this will be the same as in the creation case
	print "<form action=save_holdingdisk.cgi>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<input type=hidden name=name value=$actName>";
	print "<table border >\n";
	print "<tr $tb> <td><b>Holding disk parameters</b></td> </tr>\n";
	print "<tr $cb> <td><table width=100%>\n";
	print "<tr $cb> <td> Comment </td> <td><input type=text size=50 name=comment value=\"$hdiskEdit->{'comment'}\">";
	printf "<tr $cb> <td> Directory </td> <td><input size=50 name=directory value=$hdiskEdit->{'directory'}> %s", &file_chooser_button("directory", 1);
	print "<tr $cb> <td> Available space </td> <td><input size=8 name=use value=\"$hdiskEdit->{'use'}\">";
	print "<tr $cb> <td> Chunk size </td> <td><input size=8 name=chunksize value=\"$hdiskEdit->{'chunksize'}\">";
	print "</table></td></tr></table>";
	print "<input type=submit value='$text{'save'}'>\n";
	print "</form>";




	return 1;
}


# NAME: holdingdisk_action_create
# DESCRIPTION: creates a form to confirm the deletion of a holding disk
# PARAMETERS: -
# RETURN: -
sub holdingdisk_action_delete
{
	# Webmin header
	&header ("Delete holding disk ($actName)", "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));
	
	# We ask for confirmation
	print ("Are you sure?<BR>");
	print ("<A HREF=holdingdisk_delete.cgi?configuration=$actConfiguration&name=$actName> Click this link to delete</A>");

	return 1;
}

