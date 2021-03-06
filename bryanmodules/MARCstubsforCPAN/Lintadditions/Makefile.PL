#!perl

=head2 NOTES

This file is untested on any platform.
I use MacPerl (5.8.0a2) and Win32 versions of Perl.
I have no experience with automatic installations (the standard make process).
If this file fails to install the module, please install manually:

1. Install MARC::Record (version 1.38 or greater).
2. Find where the MARC::Record module resides on your system.
3. Place this module in the MARC directory next to the Record.pm file.
4. Place the files in the bin/ directory whereever such files normally go on your system.

Thank you,
Bryan Baldus
eijabb@cpan.org

=cut

use strict;
use ExtUtils::MakeMaker;

print "Please let me know how to fix this if it fails. Thank you\n";

WriteMakefile(
	'NAME'	=> 'MARC::Lintadditions',
	'VERSION_FROM'	=> 'lib/MARC/Lintadditions.pm',
	'ABSTRACT_FROM'	=> 'lib/MARC/Lintadditions.pm',
	'PMLIBDIRS'	=> [ qw( lib/ ) ],
	'AUTHOR'	=> 'Bryan Baldus <eijabb@cpan.org>',
	'PREREQ_PM'	=> {
			    'MARC::Record' => 1.38,
#			    'Test::More' => 0,
#			    'File::Spec' => 0,
#			    'File::Find' => 0,
			    },
#	'EXE_FILES'	=> [ qw( bin/ ) ],

);

