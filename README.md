# Micro VirtualBox VMs backup script

Very simple Vistual Machines backup script.

    perl backup.pl [-v] [-r] [-t Temporary dir path] [-b VBoxMange path] [-d Destination dir path] [-x Excluding VMs]


To use simply:

    perl backup.pl -d "/path/to/backup"

## Memorandum

* -v is verbose and -r is dryrun.
* This script export all VMs as OVF to temporary dir.
* Then move them to backup destination dir.
* The script saves state and restarts running VMs arround exporting.
* So running VMs stops during exporting.

## License

Under the MIT license.
