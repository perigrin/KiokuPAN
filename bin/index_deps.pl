#!/usr/bin/env perl
use 5.12.1;
$|++;
use lib qw(lib);

{

    package Directory;
    use Moose;
    use namespace::autoclean;
    use autodie;

    use CPAN::Meta;

    extends qw(KiokuPAN::Directory);
    with qw(MooseX::Getopt);

    has '+dsn' => ( required => 1 );
    has '+extra_args' => ( default => sub { { create => 1 } } );

    use Storable;

    sub run {
        my $self   = shift;
        my $stream = $self->all_objects;
        while ( my $block = $stream->next ) {
            $self->new_scope;
            for my $module (@$block) {
                warn scalar @$block;
                next unless $module->has_cpan_meta;
                my $meta = CPAN::Meta->new( Storable::dclone( $module->cpan_meta ) );
                my $modules = $meta->effective_prereqs->requirements_for(
                    'runtime' => 'requires' )->as_string_hash;
                warn scalar keys %$modules;
                for my $name ( keys %$modules ) {
                    my $dep = ( $self->search( { name => $name } )->all )[0];
                    next unless defined $dep;
                    $module->add_upstream_dep($dep);
                    $dep->add_downstream_dep($module);
                    $self->update( $module, $dep );
                }
            }
            print '.';
        }
    }
}

Directory->new_with_options->run()
