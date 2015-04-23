# UncommonSense.Nav.Automation Demo script

This folder contains a demo script (`Demo.ps1`) that demonstrates some of the possibilities of UncommonSense.Nav.Automation. `Demo.ps1` uses:

<dl>
<dt>`configs.txt`</dt><dd>a user-customizable list of all relevant NAV configurations in comma-separated (csv). Each line is a configuration, and consists of the unique configuration name, the full path to the NAV development client to use (fin.exe or finsql.exe), the database server name (if any), the database name, and the user setup (zup) file to use.</dd>
<dt>`Compare-NAVApplication.ps1`</dt><dd>a function that takes two NAV configuration names (the so called source database and target database; as defined in configs.txt), two folder names (one for source and one for target) and a set of object filters.  It opens the two databases with the appropriate NAV development client, retrieves a filtered list of object from the source database, allows the user to further tweak the selection, before exporting the selected objects from both the source and the target databases. Finally, it closes the two NAV development clients.</dd>
</dl>


