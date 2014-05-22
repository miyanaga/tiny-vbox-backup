#!/usr/bin/perl

use strict;
use Getopt::Std;
use Data::Dumper;
use File::Spec;

my %opts;
getopts("vdt", \%opts);
$opts{v} ||= "VBoxManage";
$opts{t} ||= "./tmp";
$opts{m} ||= 0;
$opts{d} ||= "./dest";

my $result;
my %ovfs;

sub command {
    my $command = join( ' ', map {
        /\s/ ? qq{"$_"} : $_
    } @_ );

    my $starts = time;
    print STDERR $command, "\n" if $opts{m};

    my $res = `$command`;

    my $duration = time - $starts;
    print STDERR "Takes $duration sec.\n\n" if $opts{m};

    print STDERR $res, "\n\n" if $opts{m};

    $res;
}

sub listvms {
    my $option = shift || 'vms';
    my %vms = map {
        /^"(.+?)"\s+{(.+?)}/;
        $1 => $2;
    } grep {
        /^"(.+?)"\s+{(.+?)}/;
    } split /\r?\n/, command($opts{v}, 'list' $option);

    %vms;
}

sub backupvm {
    my $running = shift;
    my $vm = shift;

    command($opts{v}, 'controlvm', $vm, "savestate") if $running;

    my $ovf = FileSpec->catdir($opts{t}, "$vm.ovf");
    $ovfs{$vm} = $ovf;
    command($opts{v}, 'export', $vm, '-o', $ovf);

    command($opts{v}, 'startvm', $vm) if $running;
}

my %stopped = listvms('vms');
my %running = listvms('runningvms');

for my $running (keys %running) {
    delete $stopped{$running};
}

backupvm(0, $_) foreach (keys %stopped);
backupvm(1, $_) foreach (keys %running);

