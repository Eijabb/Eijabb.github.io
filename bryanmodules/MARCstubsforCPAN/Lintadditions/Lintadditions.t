#!perl -Tw

=head1 NAME

Lintadditions.t -- Tests to ensure MARC::Lintadditions subroutines work as expected.

=cut

use strict;
use Test::More tests=>17;

BEGIN { use_ok( 'MARC::File::USMARC' ); }
BEGIN { use_ok( 'MARC::Lintadditions' ); }

=head2 UNIMPLEMENTED

FROM_FILE: {
	my @expected = ( (undef) x $countofundefs, [ q{$tag: $error} ] );

	my $linter = MARC::Lintadditions->new();
	isa_ok( $linter, 'MARC::Lintadditions' );

	my $filename = "t/lintadditions.usmarc";

	my $file = MARC::File::USMARC->in( $filename );
	while ( my $marc = $file->next() ) {
		isa_ok( $marc, 'MARC::Record' );
		my $title = $marc->title;
		$linter->check_record( $marc );

	my $expected = shift @expected;
	my @warnings = $linter->warnings;

	if ( $expected ) {
		ok( eq_array( \@warnings, $expected ), "Warnings match on $title" );
		} 
	else {
		is( scalar @warnings, 0, "No warnings on $title" );
		}
	} # while

	is( scalar @expected, 0, "All expected messages have been exhausted." );
}

=cut #from file

FROM_TEXT: {
	my $marc = MARC::Record->new();
	isa_ok( $marc, 'MARC::Record', 'MARC record' );

	$marc->leader("00000nam  2200253 a 4500"); 
	my $nfields = $marc->add_fields(
		['001', "ttt04000001"
		],
		['020', "","",
			a => "154879474",
		],
		['020', "","",
			a => "1548794743",
		],
		['020', "","",
			a => "15487947443",
		],
		['020', "","",
			z => "1548794743",
		],

		['040', "","",
			a => " ",
		],
		[245, "0","0",
			a => "Test record from text / ",
			b => "other title info :",
			c => "Bryan Baldus",
		],
		[250, "", "",
			a => "3rd edition",
		],
		[260, "", "",
			a => "Oregon, Illinois ; ",
			b => "B. Baldus, ",
			c => "2000",
		],
		[300, "","",
			a => "39 p",
			c => "39 c",
		],
		[500, "","",
			a => "Includes index",
		],
		[650, "", "0",
			a => "MARC formats",
		],
	);
	is( $nfields, 12, "All the fields added OK" );

	my @expected = (
		q{020:  Subfield a has the wrong number of digits.},
		q{020:  Subfield a has bad checksum, 1548794743.},
		q{245: Must end with . (period).},
		q{245: Subfield _c must be preceded by /},
		q{245: Subfield _b should be preceded by space-colon, space-semicolon, or space-equals sign.},
		q{250: Must end with . (period)},
		q{260: Check ending punctuation, 2000},
		q{260: Subfield _b must be preceded by :},
		q{260: Subfield _c must be preceded by ,},
		q{300: Subfield _c must be preceded by ;},
		q{650: Check ending punctuation.},
	);

	my $linter = MARC::Lintadditions->new();
	isa_ok( $linter, 'MARC::Lintadditions' );

	$linter->check_record( $marc );
	my @warnings = $linter->warnings;
	while ( @warnings ) {
		my $expected = shift @expected;
		my $actual = shift @warnings;

		is( $actual, $expected, "Checking expected messages" );
	}
	is( scalar @expected, 0, "All expected messages exhausted." );
}

#####

