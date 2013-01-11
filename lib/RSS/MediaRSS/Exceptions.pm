package RSS::MediaRSS::Exceptions;
# ABSTRACT: Exception classes for RSS::MediaRSS

use Exception::Class (


    RSS::MediaRSS::Exceptions => {
        alias => 'throw_error',
        description => 'generic exception'
    },

    RSS::MediaRSS::Exceptions::Validation => {
        alias       => 'throw_validation',
        isa         => 'RSS::MediaRSS::Exceptions',
        fields      => 'parameter',
        description => ''
    },

    RSS::MediaRSS::Exceptions::MediaRootNotFindable => {
        isa         => 'RSS::MediaRSS::Exceptions',
        fields      => [ 'taste', 'bitterness' ],
        description => ''
    },
);

1;
