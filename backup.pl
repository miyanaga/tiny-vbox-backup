#!/usr/bin/perl

use strict;
use Getopt::Std;
use Data::Dumper;

my %opts;
getopts("v", \%opts);
$opts{v} ||= "VBoxManage";

my $result;

sub listvms {
    my $option = shift || 'vms';
    my %vms = map {
        /^"(.+?)"\s+{(.+?)}/;
        $1 => $2;
    } grep {
        /^"(.+?)"\s+{(.+?)}/;
    } split /\r?\n/, `$opts{v} list $option`;

    %vms;
}

my %vms = listvms('vms');
my %running = listvms('runningvms');

for my $running (keys %running) {
    delete $vms{$running};
}

print STDERR Dumper(\%vms);
print STDERR Dumper(\%running);