package KiokuPAN::Directory;
use Moose;
use namespace::autoclean;
use MooseX::Types::Path::Class qw(Dir);

extends qw(KiokuX::Model);

has columns => (
    isa        => 'ArrayRef',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_columns {
    [
        name => {
            data_type   => 'varchar',
            is_nullable => 1,
            extract     => sub { shift->name }
        },
        version => {
            data_type   => 'varchar',
            is_nullable => 1,
            extract     => sub { shift->version }
        },
        file => {
            data_type   => 'varchar',
            is_nullable => 1,
            extract     => sub { shift->file }
        },
    ];
}

around _build__connect_args => sub {
    my $next = shift;
    my $self = shift;
    my $args = $self->$next(@_);
    push @$args, columns => $self->columns;
    return $args;
};


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
