# Micro VirtualBox VMs backup script

Very simple backup script.

    perl backup.pl [-m] [-t Temporary dir path] [-v VBoxMange path] [-d Destination dir path]

Debug(Verbose) option is '-m'.

To use simply:

    perl backup.pl -d "/path/to/backup"

## Memorandum

* This script export all VMs as OVF to temporary dir.
* Then move them to backup destination dir.
* The script saves state and restarts running VMs arround exporting.
* So running VMs stops during exporting.

## License

Under the MIT license.