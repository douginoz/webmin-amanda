# FILE:  amanda-lib.pl
# DESCRIPTION: provides the basic functions to interface with the amanda system
#
# COMMENTS: currently, it contains the following capabilities:
#              - get the amanda version (if any)
#              - parse the configuration files, including the disklist
#              - write the changes to the configuration files, including disklist
#              - read the available amanda configurations (as it can manage multiple ones)
#              - check the service status (reading inetd.conf and services file. There must be a better way)
#              - create new configurations (either from a template, or from an existing one)
#              - delete existing configurations
#              - create new holding disks
#              - edit existing holding disks
#              - delete existing holding disks
#              - create new disklist entries
#              - edit existing disklist entries
#              - delete existing disklist entries
# -> I'm not sure if using local variables is the best practice, as it can have unexpected side effects
# -> Is there any problem if I return from a function a list that has been declared in that function?
# -> This is my first PERL project, so I know there must be better ways to do everything. Please, feel free to change what you feel to.
# -> Maybe it is good idea to comment using POD, but I have never used it, so I'm not sure.
# -> Lot of code factorization can be done.
#
# I have splitted the configuration parameters in several sets. This has been rather arbitrary, but I found it useful in order to spread
# the configuration process through several forms. If someone preferes something different, it should be discussed.
# NOTE: The passing of configurations parameters from forms to these functions is with individual hashes, enforcing the previous statement:
#     - %adminOptions
#	   - %cycleOptions
#	   - %networkOptions
#	   - ...




do '../web-lib.pl';


# Configuration loading
&init_config();


# Here are the globals, representing the amanda configuration.They are loaded by the call to init_config().
# Maybe some of them, can be found by other means, such as the user, and the tmp dir, that is specified at compile time.
$amadmin_path = $config{'amanda_exec_path'};
$amanda_exec_path = $config{'amanda_exec_path'};
$amanda_configs_dir = $config{'amanda_configs_path'};
$amanda_user = $config{'amanda_user'};
$amanda_group = $config{'amanda_group'};
$amanda_debug_path = $config{'amanda_debug_path'};

# NAME: get_amanda_version
# DESCRIPTION: gets the amanda version. It is called with a strange (s_jk_dhf), parameter as configuration name, because if none is specified
# it gives an error. I think that the version command should not ask for a configuration name, but that's life!!
# PARAMETERS: -
# RETURN: - version, or undef if amanda was not found
sub get_amanda_version
{
	local $out;

  	$out = `$amadmin_path/amadmin s_jk_dhf version`;
  	if ($out =~ /VERSION=\"(.*)\"/){
   	return $1;
	}

	return undef
}


# NAME: get_amanda_backup_configurations
# DESCRIPTION: self-explaining
# PARAMETERS: -
# RETURN: @listConfs: list of available configurations
sub get_amanda_backup_configurations
{
	local $dh;
	local $actDir;
	local @listConfs;

	# We open the dir, where the configurations are kept. Configurations are directories below that location,
	# containing at least a configuration file
  	opendir ($dh, $amanda_configs_dir) || return;

	# For each entry in the directory, if it is a directory, and it contains an amanda.conf file, it is supposed to be a valid configuration
	# and is added to the list of available configuration.
	while ($actDir = readdir($dh)){
		if ((-d "$amanda_configs_dir/$actDir") && (-e "$amanda_configs_dir/$actDir/amanda.conf")){
			push (@listConfs, $actDir);
		}
	}

	return @listConfs;
}



# NAME: get_admin_options_from_conf
# DESCRIPTION: loads the admin options from the configuration file into %adminOptions. Checks for multiple parameter definitions
# PARAMETERS: configuration name
# RETURN: -
sub get_admin_options_from_conf
{
  	local $actConf = shift;
  	local $fConf;
	local ($org_f=0, $mailto_f=0, $dumpuser_f=0, $infofile_f=0, $logdir_f=0, $indexdir_f=0);


	# We open the configuration file
  	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file loading the configuration options
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*org\s+\"(.*)\"/){
			$adminOptions{'org'} = $1;
			$org_f++;
		}
		elsif (/^\s*mailto\s+\"(.*)\"/){
			$adminOptions{'mailto'} = $1;
			$mailto_f++;
		}
		elsif (/^\s*dumpuser\s+\"(.*)\"/){
			$adminOptions{'dumpuser'} = $1;
			$dumpuser_f++;
		}
		elsif (/^\s*infofile\s+\"(.*)\"/){
			$adminOptions{'infofile'} = $1;
			$infofile_f++;
		}
		elsif (/^\s*logdir\s+\"(.*)\"/){
			$adminOptions{'logdir'} = $1;
			$logdir_f++;
		}
		elsif (/^\s*indexdir\s+\"(.*)\"/){
			$adminOptions{'indexdir'} = $1;
			$indexdir_f++;
		}
	}
	close ($fconf);

	# Check for multiple definitions
	if ($org_f > 1 || $mailto_f > 1 || $dumpuser > 1 || $infofile > 1 || $logdir_f > 1 || indexdir_f > 1){
		&error ("Multiple definition for administrative setting . Please check the $amanda_configs_dir/$actConf/amanda.conf file");
	}
}

# NAME: save_admin_options_to_conf
# DESCRIPTION: saves the admin options to the configuration file from %adminOptions. Checks for incorrect parameter definitions.
# If a field is empty, we check if that is correct, and in that case we comment the line from the previous definition, if any,
# to assign it the default value
# PARAMETERS: configuration name
# RETURN: -
sub save_admin_options_to_conf
{
	local $actConf = shift;
	local $linesRef = &read_file_lines ("$amanda_configs_dir/$actConf/amanda.conf");
	local $numLines = $#$linesRef + 1;
	local $i;
	local ($org_f=0, $mailto_f=0, $dumpuser_f=0, $infofile_f=0, $logdir_f=0, $indexdir_f=0);

	# We check for incorrect data
	if ($adminOptions{'org'} =~ /\"/){
		&error ("Incorrect caracter in org field");
	}
	if ($adminOptions{'mailto'} =~ /\"/){
		&error ("Incorrect caracter in mailto field");
	}
	if ($adminOptions{'dumpuser'} =~ /\"/){
		&error ("Incorrect caracter in dumpuser field");
	}
	if ($adminOptions{'infofile'} =~ /\"/){
		&error ("Incorrect caracter in infofile field");
	}
	if ($adminOptions{'logdir'} =~ /\"/){
		&error ("Incorrect caracter in logdir field");
	}
	if ($adminOptions{'indexdir'} =~ /\"/){
		&error ("Incorrect caracter in indexdir field");
	}

	# For each line, we search for the admin options and substitute or eliminate it.
	# If the line is not found , it is added at the end of the file if it has not a default value
	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesRef->[$i];
		next if /^#/;
		if (/^\s*org\s/){
			if ($adminOptions{'org'}){
				$linesRef->[$i] = "org \"$adminOptions{'org'}\"  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$org_f++;
		}

		elsif (/^\s*mailto\s/){
			if($adminOptions{'mailto'}){
				$linesRef->[$i] = "mailto \"$adminOptions{'mailto'}\"  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$mailto_f++;
		}

		elsif (/^\s*dumpuser\s/){
			if ($adminOptions{'dumpuser'}){
				$linesRef->[$i] = "dumpuser \"$adminOptions{'dumpuser'}\"  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$dumpuser_f++;
		}

		elsif (/^\s*infofile\s/){
			if ($adminOptions{'infofile'}){
				$linesRef->[$i] = "infofile \"$adminOptions{'infofile'}\"  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$infofile_f++;
		}

		elsif (/^\s*logdir\s/){
			if ($adminOptions{'logdir'}){
				$linesRef->[$i] = "logdir \"$adminOptions{'logdir'}\"  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$logdir_f++;
		}

		elsif (/^\s*indexdir\s/){
			if ($adminOptions{'indexdir'}){
				$linesRef->[$i] = "indexdir \"$adminOptions{'indexdir'}\"  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$indexdir_f++;
		}
	}

	# We check for missing fields to add them if defined in the form
	if (($org_f == 0) && ($adminOptions{'org'})){
		push (@$linesRef, "org \"$adminOptions{'org'}\"  # AMANDA_WEBMIN");
	}

	if (($mailto_f == 0) && ($adminOptions{'mailto'})){
		push (@$linesRef, "mailto \"$adminOptions{'mailto'}\"  # AMANDA_WEBMIN");
	}

	if (($dumpuser_f == 0) && ($adminOptions{'dumpuser'})){
		push (@$linesRef, "dumpuser \"$adminOptions{'dumpuser'}\"  # AMANDA_WEBMIN");
	}
	if (($infofile_f == 0) && ($adminOptions{'infofile'})){
		push (@$linesRef, "infofile \"$adminOptions{'infofile'}\"  # AMANDA_WEBMIN");
	}
	if (($logdir_f == 0) && ($adminOptions{'$logdir'})){
		push (@$linesRef, "logdir \"$adminOptions{'logdir'}\"  # AMANDA_WEBMIN");
	}
	if (($indexdir_f == 0) && ($adminOptions{'indexdir'})){
		push (@$linesRef, "indexdir \"$adminOptions{'indexdir'}\"  # AMANDA_WEBMIN");
	}

	&flush_file_lines();

	&webmin_log ("Saved", "Admin options", $actConf, \%in);

}


# NAME: get_cycle_options_from_conf
# DESCRIPTION: loads the cycle options from the configuration file into %cycleOptions. Checks for multiple parameter definitions
# PARAMETERS: configuration name
# RETURN: -
sub get_cycle_options_from_conf
{
  	local $actConf = shift;
  	local $fConf;
	local ($dumpcycle_f=0, $runspercycle_f=0, $tapecycle_f=0, $bumpsize_f=0, $bumpdays_f=0, $bumpmult_f=0);


	# We open the configuration file
  	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file loading the configuration options
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*dumpcycle\s+(\d+)\s+(\w+)/){
			$cycleOptions{'dumpcycle'} = $1;
   		$cycleOptions{'dumpcycleweekorday'} = $2;
			$dumpcycle_f++;
		}
		elsif (/^\s*runspercycle\s+(\d+)/){
			$cycleOptions{'runspercycle'} = $1;
			$runspercycle_f++;
		}
		elsif (/^\s*tapecycle\s+(\d+)\s+tapes*/){
			$cycleOptions{'tapecycle'} = $1;
			$tapecycle_f++;
		}
		elsif (/^\s*bumpsize\s+(\d+\s*(b|byte|bytes|k|kb|kbyte|kbytes|kilobyte|kilobytes|megabytes|megabyte|mbytes|mbyte|meg|mb|m|g|gb|gbyte|gbytes|gigabyte|gigabytes]))/i){
			$cycleOptions{'bumpsize'} = $1;
			$bumpsize_f++;
		}
		elsif (/^\s*bumpdays\s+(\d+)/){
			$cycleOptions{'bumpdays'} = $1;
			$bumpdays_f++;
		}
		elsif (/^\s*bumpmult\s+(\d*\.*\d*)/){
			$cycleOptions{'bumpmult'} = $1;
			$bumpmult_f++;
		}
	}
	close ($fconf);

	# Check for multiple definitions
	if ($dumpcycle_f > 1 || $runspercycle_f > 1 || $tapecycle_f > 1 || $bumpsize_f > 1 || $bumpdays_f > 1 || $bumpmult_f > 1){
		&error("Multiple definition for cycle setting. Please check the $amanda_configs_dir/$actConf/amanda.conf file");
	}
}


# NAME: save_cycle_options_to_conf
# DESCRIPTION: saves the cycle options to the configuration file from %cycleOptions. Checks for incorrect parameter definitions.
# If a field is empty, we check if that is correct, and in that case we comment the line from the previous definition, if any,
# to assign it the default value
# PARAMETERS: configuration name
# RETURN: -
sub save_cycle_options_to_conf
{
	local $actConf = shift;
	local $linesRef = &read_file_lines ("$amanda_configs_dir/$actConf/amanda.conf");
	local $numLines = $#$linesRef + 1;
	local $i;
	local ($dumpcycle_f=0, $runspercycle_f=0, $tapecycle_f=0, $bumpsize_f=0, $bumpdays_f=0, $bumpmult_f=0);
	local @cycleValues;


	# We check for incorrect caracters in the data
	if ($cycleOptions{'dumpcycle'}!~ /^\d*$/){
		&error ("dumpcycle must be a positive integer");
	}
	if ($cycleOptions{'runspercycle'} !~ /^\d*$/){
		&error ("runspercycle must be a positive integer");
	}
	if ($cycleOptions{'tapecycle'} !~ /^\d*$/){
		&error ("tapecycle must be a positive integer");
	}
	if (($cycleOptions{'bumpsize'}) &&
		($cycleOptions{'bumpsize'} !~ /^\d+\s*(b|byte|bytes|k|kb|kbyte|kbytes|kilobyte|kilobytes|megabytes|megabyte|mbytes|mbyte|meg|mb|m|g|gb|gbyte|gbytes|gigabyte|gigabytes)\s*$/i)){
		&error ("Incorrect specification in bumpsize field");
	}
	if ($cycleOptions{'bumpdays'} !~ /^\d*$/){
		&error ("bumpdays must be a positive integer");
	}
	if ($cycleOptions{'bumpmult'} !~ /^\d*\.*\d*$/){
		&error ("bumpmult must be a positive number");
	}

	# For each line, we search for the cycle options and substitute or eliminate it.
	# If the line is not found , it is added at the end of the file if it has not a default value
	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesRef->[$i];
		next if /^#/;
		if (/^\s*dumpcycle\s/){
			if ($cycleOptions{'dumpcycle'}){
				$linesRef->[$i] = "dumpcycle $cycleOptions{'dumpcycle'} $cycleOptions{'dumpcycleweekorday'} # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$dumpcycle_f++;
		}

		elsif (/^\s*runspercycle\s/){
			if ($cycleOptions{'runspercycle'}){
				$linesRef->[$i] = "runspercycle $cycleOptions{'runspercycle'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$runspercycle_f++;
		}

		elsif (/^\s*tapecycle\s/){
			if ($cycleOptions{'tapecycle'}){
				$linesRef->[$i] = "tapecycle $cycleOptions{'tapecycle'} tapes  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$tapecycle_f++;
		}

		elsif (/^\s*bumpsize\s/){
			if ($cycleOptions{'bumpsize'}){
				$linesRef->[$i] = "bumpsize $cycleOptions{'bumpsize'} # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$bumpsize_f++;
		}

		elsif (/^\s*bumpdays\s/){
			if ($cycleOptions{'bumpdays'}){
				$linesRef->[$i] = "bumpdays $cycleOptions{'bumpdays'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$bumpdays_f++;
		}

		elsif (/^\s*bumpmult\s/){
			if ($cycleOptions{'bumpmult'}){
				$linesRef->[$i] = "bumpmult $cycleOptions{'bumpmult'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$bumpmult_f++;
		}
	}

	# We check for missing fields to add them if defined in the form
	if (($dumpcycle_f == 0) && ($cycleOptions{'dumpcycle'})){
		push (@$linesRef, "dumpcycle $cycleOptions{'dumpcycle'} $cycleOptions{'dumpcycleweekorday'} # AMANDA_WEBMIN");
	}
	if (($runspercycle_f == 0) && ($cycleOptions{'runspercycle'})){
		push (@$linesRef, "runspercycle $cycleOptions{'runspercycle'}  # AMANDA_WEBMIN");
	}
	if (($tapecycle_f == 0) && ($cycleOptions{'tapecycle'})){
		push (@$linesRef, "tapecycle $cycleOptions{'tapecycle'} tapes  # AMANDA_WEBMIN");
	}
	if (($bumpsize_f == 0) && ($cycleOptions{'bumpsize'})){
		push (@$linesRef, "bumpsize $cycleOptions{'bumpsize'} # AMANDA_WEBMIN");
	}
	if (($bumpdays_f == 0) && ($cycleOptions{'bumpdays'})){
		push (@$linesRef, "bumpdays $cycleOptions{'bumpdays'}  # AMANDA_WEBMIN");
	}
	if (($bumpmult_f == 0) && ($cycleOptions{'bumpmult'})){
		push (@$linesRef, "bumpmult $cycleOptions{'bumpmult'}  # AMANDA_WEBMIN");
	}

	&webmin_log ("Saved", "Cycle options", $actConf, \%in);
	&flush_file_lines();
	return 1;

}


# NAME: get_network_options_from_conf
# DESCRIPTION: loads the network options from the configuration file into %networkOptions. Checks for multiple parameter definitions
# PARAMETERS: configuration name
# RETURN: -
sub get_network_options_from_conf
{
  	local $actConf = shift;
  	local $fConf;
	local ($inparallel_f=0, $netusage_f=0, $etimeout_f=0, $dtimeout_f=0, $ctimeout_f=0);


	# We open the configuration file
  	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file loading the configuration options
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*inparallel\s+(\d+)/i){
			$networkOptions{'inparallel'} = $1;
			$inparallel_f++;
		}
		elsif (/^\s*netusage\s+(\d+\s*(bps|kbps))/i){
			$networkOptions{'netusage'} = $1;
			$netusage_f++;
		}
		elsif (/^\s*ctimeout\s+(\d+)/){
			$networkOptions{'ctimeout'} = $1;
			$ctimeout_f++;
		}
		elsif (/^\s*dtimeout\s+(\d+)/){
			$networkOptions{'dtimeout'} = $1;
			$dtimeout_f++;
		}
		elsif (/^\s*etimeout\s+(\-*\d+)/){
			$networkOptions{'etimeout'} = $1;
			$etimeout_f++;
		}

	}
	close ($fconf);

	# Check for multiple definitions
	if ($inparallel_f > 1 || $netusage_f > 1 || $ctimeout > 1 || $dtimeout > 1 || $etimeout > 1){
		&error ("Multiple definition for network setting . Please check the $amanda_configs_dir/$actConf/amanda.conf file");
	}
}

# NAME: save_network_options_to_conf
# DESCRIPTION: saves the network options to the configuration file from %networkOptions. Checks for incorrect parameter definitions.
# If a field is empty, we check if that is correct, and in that case we comment the line from the previous definition, if any,
# to assign it the default value
# PARAMETERS: configuration name
# RETURN: -
sub save_network_options_to_conf
{
	local $actConf = shift;
	local $linesRef = &read_file_lines ("$amanda_configs_dir/$actConf/amanda.conf");
	local $numLines = $#$linesRef + 1;
	local $i;
	local ($inparallel_f=0, $netusage_f=0, $etimeout_f=0, $dtimeout_f=0, $ctimeout_f=0);

	# We check for incorrect data
	if ($networkOptions{'inparallel'}!~ /^\d*$/){
		&error ("Max parallel must be a positive integer");
	}
	if (($networkOptions{'netusage'}) &&
		($networkOptions{'netusage'}!~ /^\d*\s*(bps|kbps)*$/i)){
		&error ("Incorrect specification in maximum network usage field");
	}
	if ($networkOptions{'ctimeout'}!~ /^\d*$/){
		&error ("Amcheck timeout must be a positive integer");
	}
	if ($networkOptions{'dtimeout'}!~ /^\d*$/){
		&error ("Data timeout must be a positive integer");
	}
	if ($networkOptions{'etimeout'}!~ /^\-*\d*$/){
		&error ("Estimation timeout must be an integer");
	}


	# For each line, we search for the network options and substitute or eliminate it.
	# If the line is not found , it is added at the end of the file if it has not a default value
	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesRef->[$i];
		next if /^#/;
		if (/^\s*inparallel\s/){
			if ($networkOptions{'inparallel'}){
				$linesRef->[$i] = "inparallel $networkOptions{'inparallel'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$inparallel_f++;
		}

		elsif (/^\s*netusage\s/){
			if($networkOptions{'netusage'}){
				$linesRef->[$i] = "netusage $networkOptions{'netusage'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$netusage_f++;
		}

		elsif (/^\s*ctimeout\s/){
			if ($networkOptions{'ctimeout'}){
				$linesRef->[$i] = "ctimeout $networkOptions{'ctimeout'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$ctimeout_f++;
		}

		elsif (/^\s*dtimeout\s/){
			if ($networkOptions{'dtimeout'}){
				$linesRef->[$i] = "dtimeout $networkOptions{'dtimeout'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$dtimeout_f++;
		}

		elsif (/^\s*etimeout\s/){
			if ($networkOptions{'etimeout'}){
				$linesRef->[$i] = "etimeout $networkOptions{'etimeout'}  # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$etimeout_f++;
		}
	}

	# We check for missing fields to add them if defined in the form
	if (($inparallel_f == 0) && ($networkOptions{'inparallel'})){
		push (@$linesRef, "inparallel $networkOptions{'inparallel'}  # AMANDA_WEBMIN");
	}

	if (($netusage_f == 0) && ($networkOptions{'netusage'})){
		push (@$linesRef, "netusage $networkOptions{'netusage'}  # AMANDA_WEBMIN");
	}

	if (($ctimeout_f == 0) && ($networkOptions{'ctimeout'})){
		push (@$linesRef, "ctimeout $networkOptions{'ctimeout'}  # AMANDA_WEBMIN");
	}

	if (($dtimeout_f == 0) && ($networkOptions{'dtimeout'})){
		push (@$linesRef, "dtimeout $networkOptions{'dtimeout'}  # AMANDA_WEBMIN");
	}

	if (($etimeout_f == 0) && ($networkOptions{'etimeout'})){
		push (@$linesRef, "etimeout $networkOptions{'etimeout'}  # AMANDA_WEBMIN");
	}

	&flush_file_lines();

	&webmin_log ("Saved", "Network options", $actConf, \%in);

}





# NAME: get_tape_options_from_conf
# DESCRIPTION: loads the tape options from the configuration file into %tapeOptions. Checks for multiple parameter definitions
# PARAMETERS: configuration name
# RETURN: -
sub get_tape_options_from_conf
{
  	local $actConf = shift;
  	local $fConf;
	local ($runtapes_f=0, $tapebufs_f=0, $tapedev_f=0, $rawtapedev_f=0, $changerfile_f=0, $changerdev_f=0, $tapetype_f=0, $labelstr_f=0);


	# We open the configuration file
  	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file loading the configuration options
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*runtapes\s+(\d+)/){
			$tapeOptions{'runtapes'} = $1;
			$runtapes_f++;
		}
		elsif (/^\s*tapebufs\s+(\d+)/){
			$tapeOptions{'tapebufs'} = $1;
			$tapebufs_f++;
		}
		elsif (/^\s*tapedev\s+\"(.*)\"/){
			$tapeOptions{'tapedev'} = $1;
			$tapedev_f++;
		}
		elsif (/^\s*rawtapedev\s+\"(.*)\"/){
			$tapeOptions{'rawtapedev'} = $1;
			$rawtapedev_f++;
		}
		elsif (/^\s*changerfile\s+\"(.*)\"/){
			$tapeOptions{'changerfile'} = $1;
			$changerfile_f++;
		}
		elsif (/^\s*changerdev\s+\"(.*)\"/){
			$tapeOptions{'changerdev'} = $1;
			$changerdev_f++;
		}
		elsif (/^\s*tapetype\s+(\S+)/){
			$tapeOptions{'tapetype'} = $1;
			$tapetype_f++;
		}
		elsif (/^\s*labelstr\s+\"(.*)\"/){
			$tapeOptions{'labelstr'} = $1;
			$labelstr_f++;
		}
		elsif (/^\s*define\s+tapetype\s+(\S+)/){
			push @{$tapeOptions{'tapetypes'}}, $1;
		}

	}
	close ($fconf);

	# Check for multiple definitions
	if ($runtapes_f > 1 || $tapebufs_f > 1 || $tapedev_f > 1 || $rawtapedev_f > 1 || $changerfile_f > 1 || $changerdev_f > 1 ||
	    $tapetype_f > 1 || $labelstr_f > 1){
		&error ("Multiple definition for tape setting. Please check the $amanda_configs_dir/$actConf/amanda.conf file");
	}
}


# NAME: save_tape_options_to_conf
# DESCRIPTION: saves the tape options to the configuration file from %tapeOptions. Checks for incorrect parameter definitions.
# If a field is empty, we check if that is correct, and in that case we comment the line from the previous definition, if any,
# to assign it the default value
# PARAMETERS: configuration name
# RETURN: -
sub save_tape_options_to_conf
{
	local $actConf = shift;
	local $linesRef = &read_file_lines ("$amanda_configs_dir/$actConf/amanda.conf");
	local $numLines = $#$linesRef + 1;
	local $i;
	local ($runtapes_f=0, $tapebufs_f=0, $tapedev_f=0, $rawtapedev_f=0, $changerfile_f=0, $changerdev_f=0, $tapetype_f=0, $labelstr_f=0);

	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesRef->[$i];
		next if /^#/;
		if (/^\s*runtapes\s/){
			if ($tapeOptions{'runtapes'}){
				$linesRef->[$i] = "runtapes $tapeOptions{'runtapes'} # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$runtapes_f++;
		}

		elsif (/^\s*tapebufs\s/){
			if ($tapeOptions{'tapebufs'}){
				$linesRef->[$i] = "tapebufs $tapeOptions{'tapebufs'} # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$tapebufs_f++;
		}

		elsif (/^\s*tapedev\s/){
			if ($tapeOptions{'tapedev'}){
				$linesRef->[$i] = "tapedev \"$tapeOptions{'tapedev'}\" # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$tapedev_f++;
		}

		elsif (/^\s*rawtapedev\s/){
			if ($tapeOptions{'rawtapedev'}){
				$linesRef->[$i] = "rawtapedev \"$tapeOptions{'rawtapedev'}\" # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$rawtapedev_f++;
		}

		elsif (/^\s*changerfile\s/){
			if ($tapeOptions{'changerfile'}){
				$linesRef->[$i] = "changerfile \"$tapeOptions{'changerfile'}\" # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$changerfile_f++;
		}

		elsif (/^\s*changerdev\s/){
			if ($tapeOptions{'changerdev'}){
				$linesRef->[$i] = "changerdev \"$tapeOptions{'changerdev'}\" # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$changerdev_f++;
		}

		elsif (/^\s*tapetype\s/){
			if ($tapeOptions{'tapetype'}){
				$linesRef->[$i] = "tapetype $tapeOptions{'tapetype'} # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$tapetype_f++;
		}

		elsif (/^\s*labelstr\s/){
			if ($tapeOptions{'labelstr'}){
				$linesRef->[$i] = "labelstr \"$tapeOptions{'labelstr'}\" # AMANDA_WEBMIN";
			}
			else{
				$linesRef->[$i] = "# Set to default by AMANDA_WEBMIN - $_";
			}
			$labelstr_f++;
		}
	}


	# We check for missing fields to add them if defined in the form
	if (runtapes_f == 0){

	}


	&flush_file_lines();
	&webmin_log ("Saved", "Tape options", $actConf, \%in);
}


# NAME: get_holdingdisks_from_conf
# DESCRIPTION: loads the holding disks information from the configuration file. Does a very basic format parsing of the definition.
# PARAMETERS: configuration name
# RETURN: @holdingdisks: list of references to a hash with the holding disk characteristics
sub get_holdingdisks_from_conf
{
	local $actConf = shift;
	local @holdingdisks;
	local $actHash;
	local $nivelLlave = 0;

	# We open the configuration file
	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file loading the holding disk options
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*holdingdisk\s+(\S+)\s*\{/){
		   # We found a holdingdisk header, so we we extract its characteristics until we find a closing brace.
			$nivelLlave++;
			$actHash = {};
			$actHash->{'name'} = $1;
			while (<$fConf>){
				next if (/^#/);
				if (/\s*}/){
					$nivelLlave--;
					push (@holdingdisks, $actHash);
					last;
				}
				if (/^\s*comment\s+\"(.*)\"/){
					$actHash->{'comment'} = $1;
				}

				elsif (/^\s*directory\s+\"([\w|\/]*)\"/){
					$actHash->{'directory'} = $1;
				}

				elsif (/^\s*use\s+(\d+\s*[b|byte|bytes|k|kb|kbyte|kbytes|kilobyte|kilobytes|m|mb|meg|mbyte|mbytes|megabyte|megabytes|g|gb|gbyte|gbytes|gigabyte|gigabytes])\s+/i){
					$actHash->{'use'} = $1;
					#$actHash->{'useUnit'} = $2;
				}

				elsif (/^\s*chunksize\s+(\d+\s*[b|byte|bytes|k|kb|kbyte|kbytes|kilobyte|kilobytes|m|mb|meg|mbyte|mbytes|megabyte|megabytes|g|gb|gbyte|gbytes|gigabyte|gigabytes])\s+/i){
					$actHash->{'chunksize'} = $1;
					#$actHash->{'chunksizeUnit'} = $2;
				}
			}
		}
	}

	close ($fConf);


	if (nivelLlave != 0){
		&error ("No matching brace found. Check $amanda_configs_dir/$actConf/amanda.conf");
	}


	return @holdingdisks;
}


# NAME: delete_holding_disk_from_conf
# DESCRIPTION: deletes a holding disk definition from a configuration file.
# PARAMETERS: configuration name, holding disk to delete
# RETURN: -
sub delete_holdingdisk_from_conf
{
	local $actConf = shift;
	local $actName = shift;
	local $linesRef = &read_file_lines ("$amanda_configs_dir/$actConf/amanda.conf");
	local $numLines = $#$linesRef + 1;
	local $i;
	local $j;

	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesRef->[$i];
		next if /^#/;
		if (/^\s*holdingdisk\s+$actName\s*\{/){
			# We found the holding disk header we were looking for.
			# We delete everything up to the closing brace
			for ($j = $i; $j < $numLines; $j++){
				$_ = $linesRef->[$j];
				next if /^#/;
				if (/\s*}/){
					splice (@$linesRef, $i, $j-$i+1);
					&flush_file_lines();
					&webmin_log ("Deleted", "Holdingdisk $actName", $actConf, \%in);
				}
			}
		}
	}
}


# NAME: save_holdingdisk_to_conf
# DESCRIPTION: adds a holding disk definition to a configuration file.
# PARAMETERS: configuration name, reference to a hash containing holding disk to delete
# RETURN: -
sub save_holdingdisk_to_conf
{
	local $actConf = shift;
	local $refhdisk = shift;
	local $refToHoldingdiskArray;
	local $linesRef = &read_file_lines ("$amanda_configs_dir/$actConf/amanda.conf");
	local $numLines = $#$linesRef + 1;
	local $i;
	local $j;

	# Preparation of the structure that will be written to disk with the holding disk information
	push (@$refToHoldingdiskArray, "holdingdisk $refhdisk->{'name'} \{");
	if ($refhdisk->{'comment'}){
		push (@$refToHoldingdiskArray, "\tcomment \"$refhdisk->{'comment'}\"");
	}
	if ($refhdisk->{'directory'}){
		push (@$refToHoldingdiskArray, "\tdirectory \"$refhdisk->{'directory'}\"");
	}
	if ($refhdisk->{'use'}){
		push (@$refToHoldingdiskArray, "\tuse $refhdisk->{'use'}");
	}
	if ($refhdisk->{'chunksize'}){
		push (@$refToHoldingdiskArray, "\tchunksize $refhdisk->{'chunksize'}");
	}
	push (@$refToHoldingdiskArray, "}");


	for ($i = 0; $i < $numLines; $i++){
		$_ = $linesRef->[$i];
		next if /^#/;
		if (/^\s*holdingdisk\s+$refhdisk->{'name'}\s*\{/){
			# We found the holding disk header we were looking for.
			# We delete everything up to the closing brace
			for ($j = $i; $j < $numLines; $j++){
				$_ = $linesRef->[$j];
				next if /^#/;
				if (/\s*}/){
					splice (@$linesRef, $i, $j-$i+1, @$refToHoldingdiskArray);
					&flush_file_lines();
					&webmin_log ("Replaced", "Holdingdisk $refhdisk->{'name'}", $actConf, \%in);
				}
			}
		}
	}

	# Reemplazamos la informaciΩn antigua o no existente al final del archivo de configuracion
	splice (@$linesRef, @$linesRef, 0, @$refToHoldingdiskArray);
	&flush_file_lines();
	&webmin_log ("Created", "Holdingdisk $refhdisk->{'name'}", $actConf, \%in);

	return 1;
}



# NAME: get_dumptypes_from_conf
# DESCRIPTION: scans for the possible dumptypes in a configuration and loads them in @dumptypes. The parsing is very basic, as it just
# searches for strings of the form "define dumptype".
# PARAMETERS: configuration name
# RETURN: @dumptypes: list with the names of the available dumptypes
sub get_dumptypes_from_conf
{
	local $actConf = shift;
	local @dumptypes;

	# We open the configuration file
	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file searching for "define dumptype"
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*define\s+dumptype\s+(\S+)/){
			# Hemos encontrado una cabecera dumptype, de modo que aœadimos su nombre a la lista
			push (@dumptypes, $1);
		}
	}

	close ($fConf);


	return @dumptypes;
}

# NAME: get_network_interfaces_from_conf
# DESCRIPTION: scans for the possible network interfaces in a configuration and loads them in @netinterfaces.
# The parsing is very basic, as it just searches for strings of the form "define interface".
# PARAMETERS: configuration name
# RETURN: @netinterfaces: list with the names of the available nmetwork interfaces
sub get_network_interfaces_from_conf
{
	local $actConf = shift;
	local @netinterfaces;

	# We open the configuration file
	open ($fConf, "$amanda_configs_dir/$actConf/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$actConf/amanda.conf ($!)");

	# Parsing of the configuration file searching for "define interface"
	while (<$fConf>){
		next if (/^#/);
		if (/^\s*define\s+interface\s+(\S+)/){
			# Hemos encontrado una cabecera interface, de modo que aœadimos su nombre a la lista
			push (@netinterfaces, $1);
		}
	}

	close ($fConf);


	return @netinterfaces;
}


# NAME: get_disklist_from_conf
# DESCRIPTION: loads the disk list into @disklist.
# PARAMETERS: configuration name
# RETURN: @disklist: list containg references to hashes with the disks' characteristics in the disk list
sub get_disklist_from_conf
{
	local $actConf = shift;
	local $actHash;
	local @disklist;

	# We open the disk list file
	open ($fDisk, "$amanda_configs_dir/$actConf/disklist") || &error ("Unable to open $amanda_configs_dir/$actConf/disklist ($!)");

	# Parsing of the disk list file, loading the disks and their characteristics
	while (<$fDisk>){
		next if (/^#/);
		next if (/^\s/);
		$actHash = {};
		($actHash->{'host'}, $actHash->{'diskdev'}, $actHash->{'dumptype'}, $actHash->{'spindle'}, $actHash->{'interface'}) =
			/(\S+)\s+(\S+)\s+(\S+)\s*(-*\d*)\s*(\S*)/;
		push (@disklist, $actHash);
	}

	close ($fDisk);

	return @disklist;
}

sub get_tapelist_from_conf
{
        local $actConf = shift;
        local $actHash;
        local @tapelist;

        # We open the tapelist file
	open ($fTape, "$amanda_configs_dir/$actConf/tapelist") || &error ("Unable to open $amanda_configs_dir/$actConf/tapelist ($!)");

        # Parsing of the tapelist file, loading the tapes and their characteristics
        while (<$fTape>){
                next if (/^#/);
#                next if (/^\s/);
                $actHash = {};
		($actHash->{'date'}, $actHash->{'label'}, $actHash->{'usage'}) =
                        /(\S+)\s+(\S+)\s+(\S+)/;
                push (@tapelist, $actHash);
        }

        close ($fTape);

        return @tapelist;
}




# NAME: save_holdingdisk_to_conf
# DESCRIPTION: It directly gets the form %in hash. In this hash, there is information about the complete disk list.
# I don't know if this is the correct way because if there are a lot of disks in the disk list, maybe the form's POST size is not
# enough.
# PARAMETERS: configuration name, reference to the hash %in containing the form parameters.
# RETURN: -
sub save_disklist_to_conf
{
	local $actConf = shift;
	local $param = shift;
	local $i;

	# A new disklist file is created from scratch. All the information will be written, afterwards
	open ($fDisk, ">$amanda_configs_dir/$actConf/disklist") || &error ("Unable to open $amanda_configs_dir/$actConf/disklist ($!)");

	# For each disk specified in the %in hash, an entry in the disk list is created.
	for ($i = 0; $i < $param->{'numberdisks'}; $i++){
		# Entries marked to be deleted are ignored, so they are not written
		next if ($param->{"delete$i"} eq "on");

		# Entries with no host, or disk, or dumptype, are ignored as they are erroneous
		next if (!$param->{"host$i"} || !$param->{"diskdev$i"} || !$param->{"dumptype$i"});

		# If spindle is empty, it is changed to -1, as it is the default value. That way, an interaface can be defined, with no ambiguity
		if ($param->{"spindle$i"} eq ""){
			$param->{"spindle$i"} = "-1";
		}
		print ($fDisk $param->{"host$i"}, "\t", $param->{"diskdev$i"}, "\t", $param->{"dumptype$i"}, "\t", $param->{"spindle$i"}, "\t",
			$param->{"interface$i"}, "\n");
	}
	close ($fDisk);

	&webmin_log ("Changed", "disklist", $actConf, \%in);
}


sub save_tapelist_to_conf
{
        local $actConf = shift;
        local $param = shift;
        local $i;

        # A new disklist file is created from scratch. All the information will be written, afterwards
	open ($fTape, ">$amanda_configs_dir/$actConf/tapelist") || &error ("Unable to open $amanda_configs_dir/$actConf/tapelist ($!)");
       # For each disk specified in the %in hash, an entry in the disk list is created.
        for ($i = 0; $i < $param->{'numbertapes'}; $i++){
                # Entries marked to be removed are ignored, so they are not written
                next if ($param->{"remove$i"} eq "on");

		print ($fTape $param->{"date$i"}, " ", $param->{"label$i"}, " ", $param->{"usage$i"}, "\n");
        }
        close ($fTape);

        &webmin_log ("Changed", "tapelist", $actConf, \%in);
}



# NAME: copy_backup_config
# DESCRIPTION: creates a new backup configuration from an existing one.
# PARAMETERS: new configuration name, original configuration name
# RETURN: -
sub copy_backup_config
{
	local $new_name = shift;
	local $from_name = shift;

	# We check for the existence of the configurations dir
	if (!-d $amanda_configs_dir){
		&error ("Backup configs directory not found");
	}

	if (!$new_name){
		&error ("New name not specified");
	}

	# We get codes to execute chown
	($login, $pass, $uid, $gid) = getpwnam ($amanda_user);

	# We create the new dir, and change perms to make them accesible to the amanda user
	mkdir ("$amanda_configs_dir/$new_name") || &error ("Could not create new config directory ($!)");

	chown $uid, $gid, "$amanda_configs_dir/$new_name";

	# amanda.conf and disklist are copied to the target directory. Perms are changed afterwards
	open ($from, "$amanda_configs_dir/$from_name/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$from_name/amanda.conf ($!)");
	open ($to, ">$amanda_configs_dir/$new_name/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$new_name/amanda.conf ($!)");
	&copydata ($from, $to);
	close ($from);
	close ($to);
	chown $uid, $gid, "$amanda_configs_dir/$new_name/amanda.conf";
	chmod 0644, "$amanda_configs_dir/$new_name/amanda.conf";

	open ($from, "$amanda_configs_dir/$from_name/disklist") || &error ("Unable to open $amanda_configs_dir/$from_name/disklist ($!)");
	open ($to, ">$amanda_configs_dir/$new_name/disklist") || &error ("Unable to open $amanda_configs_dir/$new_name/disklist ($!)");
	&copydata ($from, $to);
	close ($from);
	close ($to);
	chown $uid, $gid, "$amanda_configs_dir/$new_name/disklist";
	chmod 0644, "$amanda_configs_dir/$new_name/disklist";

	&webmin_log ("Created", "backup config", "$new_name from $from_name");
}


# NAME: create_backup_config_from_template
# DESCRIPTION: creates a new backup configuration from a template (should be the example that comes with amanda)
# PARAMETERS: new configuration name
# RETURN: -
sub create_backup_config_from_template
{
	local $new_name = shift;

	# We check for the existence of the configurations dir
	if (!-d $amanda_configs_dir){
		&error ("Backup configs directory not found");
	}

	if (!$new_name){
		&error ("New name not specified");
	}

	# We get codes to execute chown
	($login, $pass, $uid, $gid) = getpwnam ($amanda_user);

	# We create the new dir, and change perms to make them accesible to the amanda user
	mkdir ("$amanda_configs_dir/$new_name") || &error ("Could not create new config directory ($!)");

	chown $uid, $gid, "$amanda_configs_dir/$new_name";

	# amanda.conf and disklist are copied to the target directory. Perms are changed afterwards
	open ($from, "amanda.conf.template") || &error ("Could not find amanda.conf template");
	open ($to, ">$amanda_configs_dir/$new_name/amanda.conf") || &error ("Unable to open $amanda_configs_dir/$new_name/amanda.conf ($!)");
	&copydata ($from, $to);
	close ($from);
	close ($to);
	chown $uid, $gid, "$amanda_configs_dir/$new_name/amanda.conf";
	chmod 0644, "$amanda_configs_dir/$new_name/amanda.conf";

	open ($from, "disklist.template") || &error ("Could not find disklist template");
	open ($to, ">$amanda_configs_dir/$new_name/disklist") || &error ("Unable to open $amanda_configs_dir/$new_name/disklist ($!)");
	&copydata ($from, $to);
	close ($from);
	close ($to);
	chown $uid, $gid, "$amanda_configs_dir/$new_name/disklist";
	chmod 0644, "$amanda_configs_dir/$new_name/disklist";

	&webmin_log ("Created", "backup config", "$new_name from template");

	return 1;
}


# NAME: delete_backup_config
# DESCRIPTION: deletes a backup configuration. No recover mechanism.
# PARAMETERS: configuration name to delete
# RETURN: -
sub delete_backup_config
{
	local $actConf = shift;

	# Delete the configuration file and the disk list
	unlink "$amanda_configs_dir/$actConf/amanda.conf" || &error ("Could not delete $amanda_configs_dir/$actConf/amanda.conf ($!)");
	unlink "$amanda_configs_dir/$actConf/disklist" || &error ("Could not delete $amanda_configs_dir/$actConf/disklist ($!)");

	# Delete the configuration directory, if empty
	rmdir "$amanda_configs_dir/$actConf" || &error ("Could not delete directory $amanda_configs_dir/$actConf ($!)");

	return 1;
}

# NAME: list_debug_dir_by_command
# DESCRIPTION: scans the temp dir and organizes the found files by command
# PARAMETERS: -
# RETURN: %debugfiles: hash of array containing the debug files, hashed by command
#         undef if there was an error
sub list_debug_dir_by_command
{
	local %debugfiles;
	local $dh;

	# We open the debug directory
  	opendir ($dh, $amanda_debug_path) || return undef;

	# For each file in the debug directory if it has the debug file format, it is added to the hash
	while ($actDir = readdir($dh)){
		if (-f "$amanda_debug_path/$actDir"){
			if ($actDir =~ /(\w+)\.\d+\.debug/){
				push (@{$debugfiles{$1}}, $actDir);
			}
		}
	}

	closedir ($dh);

	return %debugfiles;
}


# NAME: show_debug_file
# DESCRIPTION: shows a debug file, in the debug dir
# PARAMETERS: debug file name
# RETURN: $linesRef: reference to array containing the lines of the file
sub show_debug_file
{
	local $nameD = shift;
	local $linesRef = &read_file_lines ("$amanda_debug_path/$nameD");
	
	return $linesRef;
}





# NAME: get_amanda_services_status
# DESCRIPTION: parses /etc/inetd.conf and /etc/services looking for some predefined strings. A better way would be dynamic test of
# availability. Also, configuration of the server ports would be nice
# PARAMETERS: -
# RETURN: %amandastatus: hash with the status
sub get_amanda_services_status
{
	# prefix _i_ from _i_netd.conf and _s_ de _s_ervices
	local %amandastatus = (amandaidx_i, "OFF", amidxtape_i, "OFF", amandad_i, "OFF", amandaidx_s, "OFF", amidxtape_s, "OFF", amandad_sudp, "OFF", amandad_stcp, "OFF");

	open ($inetdconf, "/etc/inetd.conf") || return;
	open ($services, "/etc/services") || return;

	while (<$inetdconf>){
		next if (/^#/);
		if (/^\s*amandaidx\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+/){
			$amandastatus{'amandaidx_i'} = "ON";
		}
		elsif (/^\s*amidxtape\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+/){
			$amandastatus{'amidxtape_i'} = "ON";
		}
		elsif (/^\s*amanda\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+/){
			$amandastatus{'amandad_i'} = "ON";
		}

	}

	while (<$services>){
		next if (/^#/);
		if (/^\s*amanda\s+\d+\/tcp/){
			$amandastatus{'amandad_stcp'} = "ON";
		}
		if (/^\s*amanda\s+\d+\/udp/){
			$amandastatus{'amandad_sudp'} = "ON";
		}
		if (/^\s*amandaidx\s+\d+\/tcp/){
			$amandastatus{'amandaidx_s'} = "ON";
		}
		if (/^\s*amidxtape\s+\d+\/tcp/){
			$amandastatus{'amidxtape_s'} = "ON";
		}
	}
	close ($inetdconf);
	close ($services);

	return %amandastatus;

};
1;

