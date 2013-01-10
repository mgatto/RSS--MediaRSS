#!perl -T

use Test::More tests => 1;
use local::lib;
use lib 'lib';

BEGIN {
    use_ok( 'XML::RSS::Media::Video' ) || print "Bail out!\n";
}


diag( "Testing internal subroutines" );

my $expected = "";
my $computed = XML::RSS::Media::Video::add_item_to_feed();
ok($computed, $expected);
