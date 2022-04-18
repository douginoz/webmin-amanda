#!/usr/bin/perl

# FILE:  config_create_select.cgi
# DESCRIPTION: Form to create a new configuration, either from another existing configuration, or from a template. A list box is
# provided to select any of the existing configuration
#
# COMMENTS:

require './amanda-lib.pl';

# Parameter parsing
&ReadParse();

&header ($text{'configs_create_configuration'}, "", undef, 0, 0, undef, &help_search_link ("amanda", "man", "doc"));

local @configurations = get_amanda_backup_configurations();

# Creation of the form
print "<form action=config_create.cgi>\n";
print "<table border>\n";
print "<tr $tb> <td><b>$text{'configs_create_configuration'}</b></td> </tr>\n";
print "<tr $cb><td><table width=100%>\n";
print "<tr $cb><td>$text{'config_create_new_name'} <input type=text size=25 name=config_name>";
print "<tr $cb><td><input type=radio name=origin value=from_template checked>$text{'config_create_from_template'}";
# If there are no configurations the radio button to select "from existing config" is disabled
if (!scalar @configurations){
	print "<tr $cb><td><input type=radio name=origin value=from_existing_config disabled>$text{'config_create_from_existing'}";
}
else{
	print "<tr $cb><td><input type=radio name=origin value=from_existing_config>$text{'config_create_from_existing'} &nbsp";
}

if (!scalar @configurations){
print "<select name=from_config disabled>";
}
else{
print "<select name=from_config>";
}

# Loading of the configuration into the list box
for (@configurations){
	print "<option value=\"$_\">$_";
}
print "</select>";

# Reset and Save buttons
print "</table></td></tr></table>";
print "<input type=submit value='$text{'save'}'>\n";
print "<input type=reset value='$text{'reset'}'>\n";
print "</form>";
print "<hr>";

# The footer is shown
&footer ("configs.cgi", &text('return_to_configs'), "", &text('return_to_index'));

