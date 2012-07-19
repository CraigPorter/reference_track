#!/usr/bin/env perl

BEGIN { unshift(@INC, './modules') }
use strict;
use warnings;
use Getopt::Long;
#use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Warehouse;

my($database,$reference,$warehouse);

GetOptions ( 'database|w=s'  => \$database,
	     'reference|r=s' => \$reference,
	     'warehouse|w=s' => \$warehouse );

($reference && $warehouse ) or die("failed at options\n");

my $warehouse_backup = ReferenceTrack::Repository::Warehouse->new( reference_location => $reference,
								   warehouse_location => $warehouse );

print "No reference\n" unless $warehouse_backup->reference_exists();
print "No warehouse\n" unless $warehouse_backup->warehouse_exists();

die("Reference is not a git repository") unless $warehouse_backup->reference_exists();

unless($warehouse_backup->warehouse_exists)
{
    print "Cloning to warehouse...\n";
    $warehouse_backup->clone_to_warehouse;
    $warehouse_backup->list_version_branches;

    #print "Cloning successful.\n" if $warehouse_backup->warehouse_exists;
    print  $warehouse_backup->warehouse_exists ? print "Cloning successful.\n":"Cloning Failed.\n"
}
else
{
    print "Backup to warehouse...\n";
    $warehouse_backup->backup_to_warehouse;
}


exit;
