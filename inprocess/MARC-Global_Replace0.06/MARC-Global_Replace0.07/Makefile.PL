use strict;
use ExtUtils::MakeMaker;

&WriteMakefile(
    NAME          => 'MARC::Global_Replace',
    DISTNAME      => 'MARC-Global_Replace',
    VERSION_FROM  => 'lib/MARC/Global_Replace.pm',
    ABSTRACT_FROM => 'lib/MARC/Global_Replace.pm',
    AUTHOR        => 'Bryan Baldus <eijabb@cpan.org>',
    PREREQ_PM     => {
                        'Test::More' => 0,
                        'MARC::Record' => 0,
                     },
    EXE_FILES     => [ qw( bin/ ) ],
);
