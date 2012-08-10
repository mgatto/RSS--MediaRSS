#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'XML::RSS::MRSS::Video' ) || print "Bail out!\n";
}

diag( "Testing XML::RSS::MRSS::Video $XML::RSS::MRSS::Video::VERSION, Perl $], $^X" );
