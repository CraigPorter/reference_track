=head1 NAME

Repositories - Represents a collection of Repositories

=head1 SYNOPSIS

use ReferenceTrack::Repositories;
my $repository = ReferenceTrack::Repositories->new(
  _dbh     => $dbh
  );
$repository->find_by_name('reponame');
$repository->find_all_by_name('reponame');
  
=cut

package ReferenceTrack::Repositories;
use Moose;
use ReferenceTrack::Schema;
use Scalar::Util;

has '_dbh'                         => ( is => 'rw', required   => 1 );

sub _find_all_by_name_result_set
{
  my ($self,$query,$exact_match) = @_;
  return if Scalar::Util::tainted($query); 
#  $self->_dbh->resultset('Repositories')->search({ name => { -like => '%'.$query.'%' } });
  my $search_term = $exact_match ? $query : '%'.$query.'%';
  $self->_dbh->resultset('Repositories')->search({ name => { -like => $search_term } });
}

sub find_all_by_name
{
  my ($self,$query) = @_;
  my @all_results = $self->_find_all_by_name_result_set($query)->all();
  return  \@all_results ;
}

sub find_by_name
{
   my ($self,$query) = @_;
   $self->_find_all_by_name_result_set($query)->first;
}

sub find_by_exact_name
{
   my ($self,$query) = @_;
   $self->_find_all_by_name_result_set($query, 1)->first;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
