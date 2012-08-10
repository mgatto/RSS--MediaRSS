use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'XML::RSS::MRSS::Video',
    AUTHOR              => q{Michael Gatto <mgatto@lisantra.com>},
    VERSION_FROM        => 'lib/XML/RSS/MRSS/Video.pm',
    ABSTRACT_FROM       => 'lib/XML/RSS/MRSS/Video.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'XML--RSS--MRSS--Video-*' },
);
