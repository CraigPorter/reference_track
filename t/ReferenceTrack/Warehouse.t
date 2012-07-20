#!/usr/bin/env perl

use strict;
use warnings;
use File::Temp;

BEGIN { unshift(@INC, './modules') }
BEGIN {
    use Test::Most;
    use_ok('ReferenceTrack::Repository::Warehouse');
    use_ok('ReferenceTrack::Repository::Search');
}


my $database = 'pathogen_reference_track';
my $query    = ''; # empty string finds all reference repos

my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};

# repository search
my $repository_search = ReferenceTrack::Repository::Search->new( database_settings => \%database_settings,
								 query             => $query );


# temp warehouse directory
my $tmpdirectory_obj = File::Temp->newdir(CLEANUP => 1);
my $warehouse_dir = $tmpdirectory_obj->dirname();
#my $warehouse_dir = '/lustre/scratch108/pathogen/cp7/test_reference_repo/Warehouse';


my $warehouse = ReferenceTrack::Repository::Warehouse->new( repository_search_results => $repository_search,
							    warehouse_directory       => $warehouse_dir );

for my $data_ref (@{$warehouse->_repository_name_location})
{
    print ' - ',join(' ',@{$data_ref}),"\n"; # debug
}

ok $warehouse->backup_repositories_to_warehouse, 'backup to warehouse'; # clone new repo
ok $warehouse->backup_repositories_to_warehouse, 'backup to warehouse'; # backup existing repo


done_testing();
