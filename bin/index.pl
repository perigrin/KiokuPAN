#!/usr/bin/env perl
use 5.12.1;
$|++;
use lib qw(lib);

# perl deps.pl --dsn dbi:SQLite:deps.db --minicpan $HOME/mirrors/minicpan

{

    package Directory;
    use Moose;
    use namespace::autoclean;
    use autodie;

    use CPAN::Meta;
    use Try::Tiny;
    use CHI;

    use aliased 'KiokuPAN::Model::Module';

    extends qw(KiokuPAN::Directory);
    with qw(MooseX::Getopt);

    has '+dsn' => ( required => 1 );
    has '+extra_args' => ( default => sub { { create => 1 } } );

    has cache => (
        default => sub {
            CHI->new(
                driver   => 'File',
                root_dir => "/tmp/${\shift->meta->name}.$$.cache"
            );
        },
        handles => { cache => 'compute' },
    );

    sub get_meta {
        my $tarball = shift;
        return unless -e $tarball;
        my $tar = $tarball =~ /bz2/ ? 'tar -Oqxjf' : 'tar -Oqxzf';
        my $meta = try {
            if ( my $yaml = `$tar $tarball '*/META.yml'` ) {
                return { %{ CPAN::Meta->load_yaml_string($yaml) } };
            }
            elsif ( my $json = `$tar $tarball '*/META.json'` ) {
                return { %{ CPAN::Meta->load_json_string($json) } };
            }
        };
        return $meta || ();
    }

    sub load {
        my ($self) = @_;
        open my $pkgs, "/usr/bin/gzcat ${\$self->packages}  |";
        while ( <$pkgs> ne "\n" ) { }
        while (<$pkgs>) {
            my $scope = $self->new_scope;
            chomp;
            my %p;
            @p{qw(name version file)} = split /\s+/, $_;
            $p{tar} = $self->minicpan . "/authors/id/$p{file}";
            $p{meta} = $self->cache( $p{tar}, sub { get_meta( $p{tar} ) } );
            delete $p{meta} unless defined $p{meta};
            try { $self->store( Module->new(%p) ) } catch { warn $_; };
        }
    }

    __PACKAGE__->meta->make_immutable;
}

Directory->new_with_options->load;

__END__
TODO:
    - use CPAN::Meta->as_struct when the fixed version is released
