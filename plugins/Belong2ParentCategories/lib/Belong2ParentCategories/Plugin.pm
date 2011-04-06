package Belong2ParentCategories::Plugin;

use strict;

sub _post_save_entry {
    my ( $cb, $app, $entry, $original ) = @_;
    my @categories;
    for my $cat ( @{ $entry->categories || [] } )  {
        next if (! $cat );
        push ( @categories, $cat );
        for my $parent ( $cat->parent_categories ) {
            next if (! $parent );
            my $place = MT->model( 'placement' )->get_by_key( { blog_id => $entry->blog_id,
                                                                entry_id => $entry->id,
                                                                category_id => $parent->id } );
            if (! $place->id ) {
                $place->is_primary( 0 );
                $place->save or die $place->errstr;
            }
            push ( @categories, $parent );
        }
    }
    $entry->clear_cache( 'categories' );
    $entry->cache_property( 'categories', undef, \@categories );
    return 1;
}

1;