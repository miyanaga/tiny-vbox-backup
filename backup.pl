#!/usr/bin/perl

use strict;
use Getopt::Std;
use Data::Dumper;
use File::Spec;
use File::Copy 'move';

my %opts;
getopts("mb:d:t:", \%opts);
$opts{b} ||= "VBoxManage";
$opts{t} ||= "./tmp";
$opts{v} ||= 0;
$opts{d} ||= "./dest";

my $result;
my %ovfs;

sub command {
    my $command = join( ' ', map {
        /\s/ ? qq{"$_"} : $_
    } @_ );

    my $starts = time;
    print STDERR $command, "\n" if $opts{v};

    my $res = `$command`;

    my $duration = time - $starts;
    print STDERR "Takes $duration sec.\n\n" if $opts{v};

    print STDERR $res, "\n\n" if $opts{v};

    $res;
}

sub list_vms {
    my $option = shift || 'vms';
    my %vms = map {
        /^"(.+?)"\s+{(.+?)}/;
        $1 => $2;
    } grep {
        /^"(.+?)"\s+{(.+?)}/;
    } split( /\r?\n/, command($opts{b}, 'list', $option) );

    %vms;
}

sub backup_vm {
    my $running = shift;
    my $vm = shift;

    command($opts{b}, 'controlvm', $vm, "savestate") if $running;

    my $ovf = File::Spec->catdir($opts{t}, "$vm.ovf");
    $ovfs{$vm} = $ovf;
    unlink $ovf if -e $ovf;
    command($opts{b}, 'export', $vm, '-o', $ovf);

    command($opts{b}, 'startvm', $vm) if $running;
}

sub tmp_files {
    my $mode = shift || 'rm';

    opendir(my $dh, $opts{t});
    while(my $f = readdir($dh)) {
        next if $f eq '.' or $f eq '..';
        my $src = File::Spec->catdir($opts{t}, $f);
        my $dest = File::Spec->catdir($opts{d}, $f);
        next if -d $f;

        if ($mode eq 'move') {
            print STDERR "Moving $src to $dest\n";
            move $src, $dest;
        } else {
            print STDERR "Removing $src\n";
            unlink $src if -e $src;
        }
    }
    close($dh);
}

my %stopped = list_vms('vms');
my %running = list_vms('runningvms');

for my $running (keys %running) {
    delete $stopped{$running};
}

tmp_files('rm');
backup_vm(0, $_) foreach (keys %stopped);
backup_vm(1, $_) foreach (keys %running);

exit if $opts{t} eq $opts{d};

tmp_files('move');

