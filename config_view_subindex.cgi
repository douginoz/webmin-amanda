#!/usr/bin/perl

# FILE:  config_view_subindex.cgi
# DESCRIPTION: Form that shows and edits the group of options selected before, in config_view.cgi
#
# COMMENTS: Here you have one of the following options:
# - admin
# - cycle
# - network
# - tape
# - holdingdisks
# - disklist

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();

$actConfiguration = $in{'configuration'};
$actAction = $in{'action'};

# Webmin header
&header (&text('config_view_title', "$actConfiguration ($actAction)"), "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# Depending on the ACTION, the form shows a group of parameters
if ($actAction eq "admin"){
	action_admin();
}
elsif ($actAction eq "cycle"){
	action_cycle();
}
elsif ($actAction eq "network"){
	action_network();
}

elsif ($actAction eq "tape"){
	action_tape();
}
elsif ($actAction eq "holdingdisks"){
	action_holdingdisks();
}
elsif ($actAction eq "disklist"){
	action_disklist();
}
elsif ($actAction eq "tapelist"){
        action_tapelist();
}




&footer ("config_view.cgi?configuration=$actConfiguration", &text('return_to_config_menu', $actConfiguration), "configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));





# Show admin option
sub action_admin
{
	&error_setup ("Reading admin options: ");
	# We load the admin options in %adminOptions
	get_admin_options_from_conf ($actConfiguration);

	# The options are formatted in the form
	print "<form action=save_config.cgi>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<input type=hidden name=action value=$actAction>";
	print "<table border>\n";
	print "<tr $tb> <td><b>$text{'config_view_subindex_admin'}</b></td> </tr>\n";
	print "<tr $cb><td><table width=100%>\n";
	print "<tr $cb> <td> Organization </td> <td><input type=text size=50 name=organization value=\"$adminOptions{'org'}\"></td><td>Aqui habra una ayuda";
	print "<tr $cb> <td> Mailto </td> <td><input type=text size=50 name=mailto value=\"$adminOptions{'mailto'}\">";
	print "<tr $cb> <td> Dumpuser </td> <td><input type=text size=50 name=dumpuser value=\"$adminOptions{'dumpuser'}\"></td><td> ($config{'amanda_user'})";
	printf "<tr $cb> <td> Info dir </td> <td><input size=50 name=infodir value=\"$adminOptions{'infofile'}\"> %s", &file_chooser_button("infodir", 1);
	printf "<tr $cb> <td> Log dir </td> <td><input size=50 name=logdir value=\"$adminOptions{'logdir'}\"> %s", &file_chooser_button("logdir", 1);
	printf "<tr $cb> <td> Index dir </td> <td><input size=50 name=indexdir value=\"$adminOptions{'indexdir'}\"> %s", &file_chooser_button("indexdir", 1);
	print "</table></td></tr></table>";
	print "<input type=submit value='$text{'save'}'>";
	print "<input type=reset value='$text{'reset'}'>";
	print "</form>";
	print "<hr>";

}


# Show cycle option
sub action_cycle
{
	&error_setup ("Reading cycle options: ");
	
	# We load the cycle options in %cycleOptions
	get_cycle_options_from_conf ($actConfiguration);

	# The options are formatted in the form
	print "<form action=save_config.cgi>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<input type=hidden name=action value=$actAction>";
	print "<table border>\n";
	print "<tr $tb> <td><b>$text{'config_view_subindex_cycle'}</b></td> </tr>\n";
	print "<tr $cb><td><table width=100%>\n";
	print "<tr $cb> <td> Dump cycle </td> <td><input type=text size=5 name=dumpcycle value=$cycleOptions{'dumpcycle'}></td><td>";
	if ($cycleOptions{'dumpcycleweekorday'} =~ /week/){
	   print"<input type=radio name=dumpcycleweekorday value=weeks checked>week(s) <input type=radio name=dumpcycleweekorday value=days>day(s)";
	}
	else{
		print"<input type=radio name=dumpcycleweekorday value=weeks>week(s) <input type=radio name=dumpcycleweekorday value=days checked>day(s)";
	}
	print "<tr $cb> <td> Runs per cycle </td> <td><input type=text size=5 name=runspercycle value=\"$cycleOptions{'runspercycle'}\">";
	print "<tr $cb> <td> Tape cycle </td> <td><input type=text size=5 name=tapecycle value=\"$cycleOptions{'tapecycle'}\">";
	print "<tr $cb> <td> Bump size </td> <td><input type=text size=10 name=bumpsize value=\"$cycleOptions{'bumpsize'}\">";
	print "<tr $cb> <td> Bump days </td> <td><input type=text size=5 name=bumpdays value=\"$cycleOptions{'bumpdays'}\">";
	print "<tr $cb> <td> Bump multiplicator </td> <td><input type=text input size=5 name=bumpmult value=\"$cycleOptions{'bumpmult'}\">";
	print "</table></td></tr></table>";
	print "<input type=submit value='$text{'save'}'>";
	print "<input type=reset value='$text{'reset'}'>";
	print "</form>";
	print "<hr>";

}


sub action_network
{
	&error_setup ("Reading network options: ");

	# We load the network options in %networkOptions
	get_network_options_from_conf ($actConfiguration);

	# The options are formatted in the form
	print "<form action=save_config.cgi>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<input type=hidden name=action value=$actAction>";
	print "<table border>\n";
	print "<tr $tb> <td><b>$text{'config_view_subindex_network'}</b></td> </tr>\n";
	print "<tr $cb><td><table width=100%>\n";
	print "<tr $cb> <td> Max parallel backups </td> <td><input type=text size=3 name=inparallel value=\"$networkOptions{'inparallel'}\"></td><td>Aqui habra una ayuda";
	print "<tr $cb> <td> Max net usage </td> <td><input type=text size=15 name=netusage value=\"$networkOptions{'netusage'}\">";
	print "<tr $cb> <td> Amcheck timeout </td> <td><input type=text size=8 name=ctimeout value=\"$networkOptions{'ctimeout'}\">";
	print "<tr $cb> <td> Data timeout </td> <td><input type=text size=8 name=dtimeout value=\"$networkOptions{'dtimeout'}\">";
	print "<tr $cb> <td> Estimation timeout </td> <td><input type=text size=8 name=etimeout value=\"$networkOptions{'etimeout'}\">";
	print "</table></td></tr></table>";
	print "<input type=submit value='$text{'save'}'>";
	print "<input type=reset value='$text{'reset'}'>";
	print "</form>";
	print "<hr>";

	return 1;
}





# Show tape option
sub action_tape
{
	&error_setup ("Reading tape options: ");

	# We load the tape options in %tapeOptions
	get_tape_options_from_conf ($actConfiguration);

	# The options are formatted in the form
	print "<form action=save_config.cgi>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<input type=hidden name=action value=$actAction>";
	print "<table border width=100%>\n";
	print "<tr $tb> <td><b>$text{'config_view_subindex_tape'}</b></td> </tr>\n";
	print "<tr $cb><td><table width=100%>\n";
	print "<tr $cb> <td> Run tapes </td> <td><input type=text size=3 name=runtapes value=$tapeOptions{'runtapes'}>";
	print "<tr $cb> <td> Tape buffers </td> <td><input type=text size=3 name=tapebufs value=$tapeOptions{'tapebufs'}>";
	printf "<tr $cb> <td> Tape device </td> <td><input type=text size=50 name=tapedev value=$tapeOptions{'tapedev'}> %s", &file_chooser_button("tapedev", 1);
	printf "<tr $cb> <td> Raw tape dev </td> <td><input type=text size=50 name=rawtapedev value=$tapeOptions{'rawtapedev'}> %s", &file_chooser_button("rawtapedev", 1);
	printf "<tr $cb> <td> Changer file </td> <td><input type=text size=50 name=changerfile value=$tapeOptions{'changerfile'}> %s", &file_chooser_button("changerfile",0);
	printf "<tr $cb> <td> Changer device </td> <td><input type=text size=50 name=changerdev value=$tapeOptions{'changerdev'}> %s", &file_chooser_button("changerdev", 1);
	print "<tr $cb> <td> Tape type </td> <td>";
	
	# For each tape type defined in the config file, a radio button item is created.
	foreach (@{$tapeOptions{'tapetypes'}}){
		if ($_ eq $tapeOptions{'tapetype'}){
			print"<input type=radio name=tapetype value=\"$_\" checked> $_ ";
		}
		else{
			print"<input type=radio name=tapetype value=\"$_\"> $_ ";
		}
		print "<BR>";
	}

	print "<tr $cb> <td> Label regexp </td> <td><input type=text input size=40 name=labelstr value=$tapeOptions{'labelstr'}>";
	print "</table></td></tr></table>";
	print "<input type=submit value='$text{'save'}'>";
	print "<input type=reset value='$text{'reset'}'>";
	print "</form>";

	print "<hr>";

}


# Show admin option
sub action_holdingdisks
{
	local @hdisks;
	local $hdiskRef;

	&error_setup ("Reading holding disks info: ");

	# We load the holding disks configuration
	@hdisks = get_holdingdisks_from_conf ($actConfiguration);

	# Part of the form to edit existing holding disks
	print ("<H2>Edit existing holding disk</H2>");
	if (scalar (@hdisks) == 0){
		print ("No holding disks defined<BR>");
	}
	else{
		for $hdiskRef (@hdisks){
			print ("<A HREF=holdingdisk.cgi?action=edit&name=$hdiskRef->{'name'}&configuration=$actConfiguration>Edit $hdiskRef->{'name'} holding disk</A><BR>");
		}
	}

	# Part of the form to create a new holding disk
	print ("<HR>");
	print ("<H2>Create new holding disk</H2><BR>");
	print ("<A HREF=holdingdisk.cgi?action=create&configuration=$actConfiguration>Click to create new holding disk</A><BR>");


	# Part of the form to delete an existing holding disk
	print ("<HR>");
	print ("<H2>Delete existing holding disk</H2><BR>");
	if (scalar (@hdisks) == 0){
		print ("No holding disks defined<BR>");
	}
	else{
		for $hdiskRef (@hdisks){
			print ("<A HREF=holdingdisk.cgi?action=delete&name=$hdiskRef->{'name'}&configuration=$actConfiguration>Delete $hdiskRef->{'name'} holding disk</A><BR>");
		}
	}
	print "<hr>";

}

sub action_disklist
{
	local @types;
	local @interfaces;
	local @disks;
	local @disklist;
	local $index;
	local $interfaceSelected = 0;

	&error_setup ("Reading disklist info: ");

	# We load the dump types from the configuration file
	@types = get_dumptypes_from_conf($actConfiguration);

	# We load the network interfaces from the configuration file
	@interfaces = get_network_interfaces_from_conf($actConfiguration);

	# We load the disk list from the disk list file
	@disklist = get_disklist_from_conf($actConfiguration);

	# We format the form
	print "<form action=save_disklist.cgi method=post>\n";
	print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<BR><H2>Existing disklist</H2>";
	print "<table border width=100%>\n";
	print "<tr $tb> <td><b>Delete</td><td><b>Host</td><td><b>Disk device</b></td><td><b>Dumptype</b></td><td><b>Spindle</b></td><td><b>Interface</b></td></b></tr>\n";

	$index = 0;

	# For each disk in the disk list, a row is created with its info.
	foreach $diskref (@disklist){
		print "<tr $cb><td><input type=checkbox name=delete$index></td>";
		print "<td><input type=text size=30 name=host$index value=$diskref->{'host'}></td>";
		print "<td><input type=text size=30 name=diskdev$index value=$diskref->{'diskdev'}></td>";

		print ("<td><select name=dumptype$index>");
  		foreach $type (@types){
 			if ($type eq $diskref->{'dumptype'}){
 				print ("<option value=\"$type\" SELECTED>$type");
 			}
 			else{
 				print ("<option value=\"$type\">$type");
 			}
 		}
 		print ("</select></td>");

		print "<td><input type=text size=5 name=spindle$index value=$diskref->{'spindle'}></td>";

		print ("<td><select name=interface$index>");
		$interfaceSelected = 0;
		foreach $interface (@interfaces){
 			if ($interface eq $diskref->{'interface'}){
 				print ("<option value=\"$interface\" SELECTED>$interface");
				$interfaceSelected = 1;
				
 			}
 			else{
 				print ("<option value=\"$interface\">$interface");
 			}
 		}
		# Empty default is added
		if ($interfaceSelected){
			print "<option value=\"\">DEFAULT";
		}
		else{
			print "<option value=\"\" SELECTED>DEFAULT";
		}
 		print ("</select></td>\n");
		$index++;
	}

	print "</table>";
	print "<BR><H2>Add new disks to disklist</H2>";
	print "<table border width=100%>\n";
	print "<tr $tb><td><b>Host</td><td><b>Disk device</b></td><td><b>Dumptype</b></td><td><b>Spindle</b></td><td><b>Interface</b></td></b></tr>\n";


	# Ten empty rows are displayed in order to select new disks to backup
	for ($i = 0; $i < 10; $i++){
		print "<tr $cb><td><input type=text size=30 name=host$index></td>";
		print "<td><input type=text size=30 name=diskdev$index></td>";

		print ("<td><select name=dumptype$index>");
  		foreach $type (@types){
			print ("<option value=\"$type\">$type");
 		}
 		print ("</select></td>");

		print "<td><input type=text size=5 name=spindle$index></td>";

		print ("<td><select name=interface$index>");
		foreach $interface (@interfaces){
 				print ("<option value=\"$interface\">$interface");
 		}
		# Empty default is added
		print "<option value=\"\"  SELECTED>DEFAULT";
 		print ("</select></td>");
		$index++;
	}

	print "<input type=hidden name=numberdisks value=$index>";
	print "</tr></table>";
	print "<input type=submit value='$text{'save'}'>";
	print "<input type=reset value='$text{'reset'}'>";
	print "</form>";

	print "<hr>";


}


sub action_tapelist
{
        local @types;
#        local @interfaces;
        local @tapes;
        local @tapelist;
        local $index;
        local $tapeusage = "";

        &error_setup ("Reading tapelist info: ");


        # We load the tape options in %tapeOptions
        get_tape_options_from_conf ($actConfiguration);

        # We load the disk list from the disk list file
        @tapelist = get_tapelist_from_conf($actConfiguration);

        # We format the form
        print "<form action=save_tapelist.cgi method=post>\n";
        print "<input type=hidden name=configuration value=$actConfiguration>";
        print "<BR><H2>Existing tapelist</H2>";
        print "<table border width=100%>\n";
	print "<tr $tb> <td><b>Remove</td><td><b>Tape label</b></td><td><b>Backup date</b></td><td><b>Usage</b></td></b></tr>\n";

        $index = 0;

        # For each tape in the tape list, a row is created with its info.
        foreach $taperef (@tapelist){
                print "<tr $cb><td><input type=checkbox name=remove$index></td>";
                print "<td>$taperef->{'label'}<input type=hidden name=label$index value=$taperef->{'label'}></td>";
                print "<td>$taperef->{'date'}<input type=hidden name=date$index value=$taperef->{'date'}></td>";

                print ("<td><select name=usage$index>");
                print ("<option value=\"reuse\"");
		$tapeusage = "reuse";
		if ($tapeusage eq $taperef->{'usage'}){
                                print (" SELECTED>\"reuse\"");
                        }
		else {
			 print (">\"reuse\"");
		}
                print ("<option value=\"no-reuse\"");
		$tapeusage = "no-reuse";
                if ($tapeusage eq $taperef->{'usage'}){
                                print (" SELECTED>\"no-reuse\"");
                        }
                else {
			 print (">\"no-reuse\"");
		}
                print ("</select></td>\n");
                $index++;
        }

        print "</table>";

        print "<input type=hidden name=numbertapes value=$index>";
        print "</tr></table>";
        print "<input type=submit value='$text{'save'}'>";
        print "<input type=reset value='$text{'reset'}'>";
        print "</form>";
        print "<form action=tape_options.cgi method=post>\n";
        print "<input type=hidden name=configuration value=$actConfiguration>";
	print "<input type=hidden name=tapedev value=$tapeOptions{'tapedev'}>";
        print "<BR><H2> Tape options</H2>";
        print "<input type=radio name='tapeoption' value='retension'>Retension<BR>";
        print "<input type=radio name='tapeoption' value='erase'>Erase<BR>";
        print "<input type=radio name='tapeoption' value='label'>Label tape: <input name=new_label value=$tapeOptions{'labelstr'}><BR><BR>";
        print "<input type=submit value='Submit'>";
        print "<input type=reset value='$text{'reset'}'>";
        print "</form>";
        print "<hr>";


}

