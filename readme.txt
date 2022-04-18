WEBMIN module for Amanda readme file and release notes:

This is a modified version of webmin-amanda by Luis Lloret from 2005-03-02 (http://webmin-amanda.sourceforge.net/)
The original version is only available via sourceforge and I haven't found the author

This current version works under Ubuntu 20+ by modifying the system("su $amanda_user") execution to "sudo -u $amanda_user")


Some notes about the actual status:
	- Please, consider this as an alpha release. So BACKUP your existing Amanda configuration files before going on.
	- Code can (and probably must) be improved, as this is my first PERL project. 
	- Testing has been minimal, as I have not had access to a real taper. It has only been tested under SuSE 8.0, 8.2 and 9.0 and RedHat 8.0. This is beginning to change as more and more people is getting involved in testing. 
	- It has been tested only with the MSC.Linux Webmin theme, so I do not know how will it be with other themes.

	- Feedback (of any kind) and contributions will be greatly appreciated. 
	

CURRENT FEATURES
- read the configuration files, including the disklist
- write the changes to the configuration files, including disklist
- read the available amanda configurations (as it can manage multiple ones)
- check the service status (reading inetd.conf and services file. There must be a better way)
- create new configurations (either from a template, or from an existing one)
- delete existing configurations
- monitor currently running backups
- check and view some of the most important Amanda atributes:
   - next tape due (amadmin tape)
   - disklist entries (amadmin disklist)
   - misc. info (amadmin info)
   - self-check (amcheck)
   - amanda overview (amoverview)
   - check tape consistency (amcheckdb)
- debug amanda installations, featuring navigation through the Amanda debug files
- logging of Webmin actions for the Amanda module, when changing something.
- tapelist-extension under "Edit / view backup configuration" for removing, labeling, retensioning  and erasing tapes (contributed by Hannu Tikka)
- internationalization support for Spanish language


PLANNED FEATURES
- enhance the monitoring of backups.
- ability to search the backup databases to find a specific file / directory to restore.
- provide a front-end for the most interesting Amanda commands to manage a configuration, not just watch it (label and remove tapes, verify tapes, run tape commands, restore from tape, cleanup and flush backups, etc).
- Provide a Wizard to assist in the initial setup and configuration of an Amanda Backup Server (check inetd services, files, directories, tapes, etc).
- Create and edit dumptypes.
- Support include files.



TODO
- There are lots of hard-coded strings. They must be internationalized.
- Add some help in the configuration forms, to show what is each item.
- More testing.
- Yet more testing.


INSTALL
Just follow the webmin instruction to add a new module


TESTED UNDER
This Software has been tested (but very little, indeed) under this versions:
WEBMIN: 1.070 - 1.150.
AMANDA: versions 2.4.2 and 2.4.4
OS: SuSE Linux 8.0, 8.2, and 9.0. RedHat 8.0, Solaris 9.
If you install and use the module succesfully, please let me know the versions you are working with.


ACKNOLEDGEMENTS
- I would like to thank the Amanda developers for such a nice backup software. 
- Thanks go to Webmin team for making life so easy (well, not exactly ;). 
- The MSC team for those nice (and sometimes multifunctional) icons. 
- The webmin-pserver module developers (as I have learned most Webmin programming by looking at that code). Some code has been borrowed from them, too.
- Thanks to the people that have been testing and suffering this Software.
- Hannu Tikka, for the nice constributions so far.
* Finally, I would like to thank YOU for reading this far. 


LICENSE
This is GPL work. You can find a copy of the license in the package, named license.txt

