package KiokuPAN::Model::Module;
use Moose;
use namespace::autoclean;

has [qw(name version file)] => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has cpan_meta => (
    isa      => 'HashRef',
    is       => 'ro',
    init_arg => 'meta'
);

__PACKAGE__->meta->make_immutable;

1;
__END__
