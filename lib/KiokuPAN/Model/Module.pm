package KiokuPAN::Model::Module;
use Moose;
use namespace::autoclean;
our $VERSION = '0.02';

with qw(KiokuDB::Role::ID);

has [qw(name version file)] => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

sub kiokudb_object_id { $_[0]->name . $_[0]->version }

has cpan_meta => (
    isa       => 'HashRef',
    is        => 'ro',
    init_arg  => 'meta',
    predicate => 'has_cpan_meta',
);

has [qw(upstream_deps downstream_deps)] => (
    isa     => 'HashRef',
    is      => 'ro',
    lazy    => 1,
    default => sub { {} },
);

sub add_upstream_dep {
    my ( $s, $d ) = @_;
    $s->upstream_deps->{ $d->name } = $d;
}

sub add_downstream_dep {
    my ( $s, $d ) = @_;
    $s->downstream_deps->{ $d->name } = $d;
}

__PACKAGE__->meta->make_immutable;

1;
__END__
