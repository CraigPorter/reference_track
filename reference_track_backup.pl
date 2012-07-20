#!/usr/bin/env perl

# Backup references to warehouse disk
# Basic script

BEGIN { unshift(@INC, './modules') }
use strict;
use warnings;
use Getopt::Long;
use ReferenceTrack::Repository::Search;
use ReferenceTrack::Repository::Warehouse;

my($database,$reference,$warehouse,$help);

GetOptions ( 'database|d=s'  => \$database,  # database name (required)
	     'reference|r:s' => \$reference, # query term
	     'warehouse|w=s' => \$warehouse, # warehouse directory (required)
	     'help|h'        => \$help );

# Add checks and usage here...
( $database && $warehouse) or die("No database supplied.");


$reference ||= ''; # empty string finds all reference repositories


# database settings
my %database_settings;
$database_settings{database} = $database ;
$database_settings{host} = $ENV{VRTRACK_HOST} || 'mcs6';
$database_settings{port} = $ENV{VRTRACK_PORT} || 3347;
$database_settings{ro_user} = $ENV{VRTRACK_RO_USER}  || 'pathpipe_ro';
$database_settings{rw_user} =  $ENV{VRTRACK_RW_USER} || 'pathpipe_rw';
$database_settings{password} = $ENV{VRTRACK_PASSWORD};

# repository search
my $repository_search = ReferenceTrack::Repository::Search->new( database_settings => \%database_settings,
								 query             => $reference );

# update references
my $warehouse_backup = ReferenceTrack::Repository::Warehouse->new( repository_search_results => $repository_search,
								   warehouse_directory       => $warehouse );

# Add pre-flight check here ...
$warehouse_backup->backup_repositories_to_warehouse;

exit;
