#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Git::Warehouse');
}

# temp warehouse directory
my $tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $warehouse_dir = $tmpdirectory_obj->dirname();
#my $warehouse_dir = '/lustre/scratch108/pathogen/cp7/test_reference_repo/Warehouse';

my $reference_url = 'file://///nfs/pathnfs02/references/Escherichia/coli/Escherichia_coli_etec_h10407.git';
#my $warehouse_url = 'file:////'.$warehouse_dir.'/test_warehouse.git';
my $warehouse_url = $warehouse_dir.'/test_warehouse.git';

my $warehouse = ReferenceTrack::Repository::Git::Warehouse->new( reference_location => $reference_url,
								 warehouse_location => $warehouse_url );

is $warehouse->reference_exists, 1, 'confirm reference exists';
is $warehouse->warehouse_exists, 0, 'confirm warehouse does not exist';

ok $warehouse->clone_to_warehouse,  'clone to warehouse';
is $warehouse->warehouse_exists, 1, 'confirm warehouse exists';

ok $warehouse->backup_to_warehouse, 'backup to warehouse';


#print "Versions:\n",join("\n",$warehouse->list_version_branches),"\n";

done_testing();
