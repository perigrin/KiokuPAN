package KiokuPAN::Directory;
use Moose;
use namespace::autoclean;
use MooseX::Types::Path::Class qw(Dir);

extends qw(KiokuX::Model);

has minicpan => (
    isa      => Dir,
    is       => 'ro',
    coerce   => 1,
    required => 1
);

has packages => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        shift->minicpan . '/modules/02packages.details.txt.gz';
    }
);

1;
__END__
