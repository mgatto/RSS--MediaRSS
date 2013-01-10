#!perl -T

use Test::More tests => 2;
use local::lib;
use lib 'lib';
use XML::RSS::Media::Video;

BEGIN {
}

my $mrss = XML::RSS::Media::Video->new({
    player_url  => 'http://jamesacook.net/assets/flash/player.swf',
    title       => 'James A Cook: Sculpture Videos',
    link        => 'jamesacook.net',
    description => 'A Tucson, Arizona Sculptor and Video Artist',
});
# create an object
ok( defined $mrss );                # check that we got something
ok( $mrss->isa('XML::RSS::Media::Video') );     # and it's the right class
