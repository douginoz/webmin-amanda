#!/usr/bin/perl
# FILE:  configs.cgi
# DESCRIPTION: Form to select an action (VIEW / EDIT, CREATE, DELETE) for a configuration. 
#
# COMMENTS: This will be the main form while creating and editing new configurations.

require './amanda-lib.pl';

# Webmin header
&header (&text('configs_title'), "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

# We read the available configurations
@configurations = get_amanda_backup_configurations();

print ("<H2>$text{'configs_view_configurations_subtitle'}</H2>");
$numConfigs = 0;

# We show an icon for each configuration. If the icon is clicked we edit or view that config
foreach (@configurations){
   $numConfigs++;
   push (@iconsConf, "images/configs.gif");
   push (@linksConf, "config_view.cgi?configuration=$_");
   push (@titlesConf, &text('configs_view_configuration', $_));
}
if ($numConfigs > 0){
	&icons_table(\@linksConf, \@titlesConf, \@iconsConf);
}
else{
   print "<p>", &text(no_configs_found, "$gconfig{'webprefix'}/config.cgi?$module_name"), "<p>";
}

print ("<HR>");

# We show an icon to create a configuration.
print ("<H2>$text{'configs_create_configuration_subtitle'}</H2>");
@iconsAdd = ( "images/config.gif");
@linksAdd = ( "config_create_select.cgi");
@titlesAdd = ( $text{'configs_create_configuration'});
&icons_table(\@linksAdd, \@titlesAdd, \@iconsAdd);

# For each configuration, we show an icon to delete it
print ("<HR>");
print ("<H2>$text{'configs_delete_configurations_subtitle'}</H2>");
$numConfigs = 0;
foreach (@configurations){
   $numConfigs++;
   push (@iconsConfDelete, "images/configs.gif");
   push (@linksConfDelete, "config_delete.cgi?configuration=$_");
   push (@titlesConfDelete, &text('configs_delete_configuration', $_));
}
if ($numConfigs > 0){
	icons_table(\@linksConfDelete, \@titlesConfDelete, \@iconsConfDelete);
}

print "<hr>";

# The footer is shown
&footer ("", &text('return_to_index'));

