=head1 NAME

Warehouse - wrapper for cloning and updating a backup repository.

=head1 SYNOPSYS

use ....
my $warehouse_backup = ReferenceTrack::Repository::Warehouse->new(reference_location = $reference, 
                                                                  warehouse_location = $warehouse);
$warehouse_backup->clone_to_warehouse();
$warehouse_backup->backup_to_warehouse();

=cut

package ReferenceTrack::Repository::Warehouse;
use Moose;
#use Git::Repository;
#use ReferenceTrack::Repository;
use ReferenceTrack::Repository::Git::Instance;

has 'reference_location' => ( is => 'ro', isa => 'Str', required => 1 ); # git reference (can be url).
has 'warehouse_location' => ( is => 'ro', isa => 'Str', required => 1 ); # git warehouse (can't be url if setting-up).
has '_temp_repository' => ( is => 'rw', isa => 'ReferenceTrack::Repository::Git::Instance', lazy => 1, builder => '_build__temp_repository'); # work repo

sub _build__temp_repository
{
    my($self) = @_;
    return ReferenceTrack::Repository::Git::Instance->new( location => $self->reference_location );
}

sub _is_repository_location_exists
{
    my($self, $location) = @_;
    eval { my $remote_list = Git::Repository->run('ls-remote' => $location); };
    return $@ ? 0:1;
}


sub reference_exists
{
    my($self) = @_;
    return $self->_is_repository_location_exists($self->reference_location);
}

sub warehouse_exists
{
    my($self) = @_;
    return $self->_is_repository_location_exists($self->warehouse_location);
}

sub list_version_branches
{
    my($self) = @_;
    my @version_branches = ();

    my @all_branches = $self->_temp_repository->git_instance->run('branch' => '-a');

    for my $branch (sort @all_branches)
    {
        $branch =~ s/^\s+//;
        next unless $branch =~ /^remotes\/origin\/[\w,\.]+$/;
        next if $branch =~ /master/; 
        push @version_branches, $branch;
    }

    return @version_branches;
}

sub clone_to_warehouse
{
    my($self) = @_;

    return 0 unless $self->reference_exists;
    return 0 if $self->warehouse_exists;

    print Git::Repository->run( clone => ('--bare', '--no-hardlinks', $self->reference_location, $self->warehouse_location) ), "\n";

    return $self->warehouse_exists;
}


sub backup_to_warehouse
{
    my($self) = @_;

    return 0 unless $self->reference_exists;
    return 0 unless $self->warehouse_exists;

    my $temp_repo = $self->_temp_repository->git_instance;

    # remote add warehouse
    print $temp_repo->run(remote => ('add','warehouse',$self->warehouse_location));

    # update version branches
    for my $version_branch ($self->list_version_branches)
    {
	print $temp_repo->run(checkout => ('--track', $version_branch)),"\n";
        print $temp_repo->run(push => 'warehouse'),"\n";
    }
    # update master 
    print $temp_repo->run(checkout => 'master'),"\n";
    print $temp_repo->run(push => 'warehouse'),"\n";

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
