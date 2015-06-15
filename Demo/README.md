# UncommonSense.Nav.Automation Demo script

This folder contains a demo script (`Demo.ps1`) that demonstrates some of the possibilities of UncommonSense.Nav.Automation. Since your working procedures are very likely to differ from mine, I strongly encourage you to take the script as your starting point and tweak it as you see fit. To use it, first install the script module from the main folder of this repo, according to the steps in the README.md there.

`Demo.ps1` uses:

<dl>
<dt>configs.txt</dt><dd>a user-customizable list of all relevant NAV configurations in comma-separated (csv) format. Each line is a configuration, and consists of the unique configuration name, the full path to the NAV development client to use (fin.exe or finsql.exe), the database server name (if any), the database name, and the user setup (zup) file to use.

Note: When working with NAV text object files it is recommended to use the ENU (English (US)) language. The language setting of the NAV development client is stored inside the user setup (zup) file. The user setup path in configs.txt should preferably point to a user setup file which is used exclusively for the PowerShell scripts. Since we cannot change the language to ENU from within PowerShell, it has to be done by the user manually by selecting ENU inside the NAV client. This of course is only needed in multilanguage environments where ENU is not the default language.</dd>

<dt>Compare-NAVApplication.ps1</dt><dd>a function that takes two NAV configuration names (the so called source database and target database; as defined in configs.txt), two folder names (one for source and one for target) and a set of object filters.  It opens the two databases, each with the appropriate NAV development client, retrieves a filtered list of object from the source database, allows the user to further tweak the selection, before exporting the selected objects from both the source and the target databases. Finally, it closes the two NAV development clients.</dd>
</dl>

`Demo.ps1` contains some hard-coded references to source/target configurations and the compare tool path. Add your own configurations to configs.txt, and update `Demo.ps1` so that it uses configurations relevant for your way of working. 

_IMPORTANT:_ In its current form, the script will delete the source and target folders (should they exist) before recreating them and exporting your objects. Before running the script, choose your `$BaseFolderName` so that `$SourceFolderName` and `$TargetFolderName` don't point to folders you wouldn't want to lose.
