#!perl -T

use Test::More tests => 1;
use local::lib;
use lib 'lib';

BEGIN {
    use_ok( 'XML::RSS::Media::Video' ) || print "Bail out!\n";
}


diag( "Testing XML::RSS::Media::Video $XML::RSS::Media::Video::VERSION, Perl $], $^X" );
