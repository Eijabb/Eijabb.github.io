#!perl -w

=head1 NAME

Lintadditions.t -- Tests to ensure MARC::Lintadditions subroutines work as expected.

=head2 TODO

Currently fails some tests due to subfield 6 not being 1st (Lint not yet fixed to account for these).

=cut

use strict;
use Test::More tests=>67;

BEGIN { use_ok( 'MARC::File::USMARC' ); }
BEGIN { use_ok( 'MARC::Lintadditions' ); }

=head2 UNIMPLEMENTED

FROM_FILE: {
	my @expected = ( (undef) x $countofundefs, [ q{$tag: $error} ] );

	my $linter = MARC::Lintadditions->new();
	isa_ok( $linter, 'MARC::Lintadditions' );

	my $filename = File::Spec->catfile(File::Spec->updir(), 't', 'lintadditions.usmarc';

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
	['007', "vfuexahou e" #u in byte 2, invalid bytes 3 and 4, data after
		],
		['007', "vf mbahou " #extra space after
		],
		['007', "vf mbaho" #extra space after
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
			a => "9781548794743", #13 digit valid
		],
		['020', "","",
			a => "9781548794745", #13 digit invalid
		],

		['020', "","",
			z => "1548794743",
		],

		['024', "1","",
			a => "012345678901",
		], #UPC 12 digit

		['024', "1","",
			a => "012345678902",
		], #UPC 12 digit

		['024', "1","",
			a => "01234567890",
		], #UPC 11 digit

		['024', "3","",
			a => "9781548794743",
		], #EAN 13 digit valid

		['024', "3","",
			a => "9781548794745",
		], #EAN 13 digit invalid


		['040', "","",
			a => " ",
			b => "end" #invalid
		],
		['041', "2","", #1st ind invalid
			a => 'end', #invalid
			a => 'span', #too long
			h => 'far', #obsolete
		],
		['042', "", "",
			a => 'n-us---', #should be coded as 043 field
		],
		['043', "","",
			a => 'n-----', #6 chars vs. 7
			a => 'n-us----', #8 chars vs. 7
			a => 'n-ma-us', #invalid code
			a => 'e-ur-ai', #obsolete code
		],
		['050', "", "4",
			a => 'PN1997.R3',
			b => '.F39 2004' #extra decimal in 2nd Cutter
		],
		['050', "", "4",
			a => 'PN1997.R3 F39 2004' #no subfield b
		],
		['050', "", "4",
			a => 'PN1997.R', #unfinished
			b => 'F39 2004',
		],
		['082', "0", "4",
			a => '6160.85' #more than 3 digits before decimal
		], #no subfield 2
		['082', "1", "4",
			a => '616.85',
			'2' => 'sears' #non-digits in subfield 2
		], 
		['082', "0", "4",
			a => '616.85',
			'2' => '24' #subfield 2 edition too high
		], 
		['082', "1", "4",
			a => '616.85',
			'2' => '10' #subfield 2 edition too low
		],
		[100, "1", "",
			a => 'Baldus, Bryan', #needs ending punctuation
		], 
		[245, "1","0",
			6 => "880-01",
			a => "Test record from text / ",
			b => "other title info :",
			c => "Bryan Baldus",
		],
		[250, "", "",
			6 => "880-02",
			a => "3rd edition",
		],
		[260, "", "",
			6 => "880-03",
			a => "Oregon, Illinois ; ",
			b => "B. Baldus, ",
			c => "2000",
		],
		[300, "","",
			a => "39 p",
			c => "39 c",
		],
		[440, "", "0",
			6 => "880-04",
			a => "The series of books"
		],
		[490, "0", "",
			6 => "880-05",
			a => "Untraced series"
		],
		[500, "","",
			a => "Includes index",
		],
		[600, "1", "0",
			a => "Smith, John",
			q => "(John J.).", #period after parens
			'2' => 'sears' #indicator problem
		],
		[600, "1", "7",
			a => "Smith, John", #no punctuation
			#no subfield 2
		],
		[610, "2", "0",
			a => "Acme Company", #no punctuation
		],
		[611, "2", "7",
			a => "Expedition of the Great (1800).", #period after parens
			#no subfield 2
		],
		[630, "1", "7", #1st ind not 0
			a => "Title of the subject", #no punctuation
			#no subfield 2
		],
		[650, "", "0",
			a => "MARC formats",
		],
		[650, "", "7",
			2 => "sears",
			#single subfield
		],
		[650, "", "7",
			a => "HEALTH & FITNESS / Diseases / Heart",
			2 => "bisacsh",
			#ignore ending punctuation
		],
		[655, "", "7",
			a => "Feature films.",
			2 => "sars", #should be sears
		],
		[700, "1", "",
			a => "Smith, John", #no punctuation
		],
		[700, "1", "",
			6 => "880-06",
			a => "Smith, James", #has subfield 6 and 4 without punctuation
			4 => "ill"
			
		],
		[700, "1", "",
			a => "Smith, Joe.", #incorrect punctuation before e
			e => "ill."
		],
		[710, "2", "",
			a => "Tests and More (Firm).", #period after parens
		],
		[710, "2", "",
			a => "Tests Incorporated", #no ending punctuation
		],


	);
	is( $nfields, 48, "All the fields added OK" );

	my @expected = (
		q{007: byte 2, 'u' is no longer valid.},
		q{007: byte 3 (e) is invalid.},
		q{007: byte 4 (x) is invalid.},
		q{007: 007 has data after limit.},
		q{007: Check for trailing space (vf mbahou  does not match vf mbahou).},
		q{007: byte 8 () is invalid.},
		q{020: Subfield a has the wrong number of digits, 154879474.},
		q{020: Subfield a has bad checksum, 1548794743.},
		q{020: Subfield a has the wrong number of digits, 15487947443.},
		q{020: Subfield a has bad checksum (13 digit), 9781548794745.},
		q{024: Subfield _a (UPC) has bad checksum (012345678901).},
		q{024: Subfield _a (UPC) has bad checksum (012345678902).},
		q{024: First indicator is 1 (UPC), but subfield _a is not 12 digits (01234567890).},
		q{024: Subfield _a (EAN) has bad checksum (9781548794745).},
		q{040: Subfield _b, end, is not valid.},
		q{041: Indicator 1 must be blank, 0 or 1 but it's "2"},
		q{041: Subfield _a, end (end), is not valid.},
		q{041: Subfield _a must be evenly divisible by 3 or exactly three characters if ind2 is not 7, (span).},
		q{041: Subfield _h, far, may be obsolete.},
		q{042: subfield _a contains an invalid code, n-us---},
		q{043: Subfield _a must be exactly 7 characters, n-----},
		q{043: Subfield _a must be exactly 7 characters, n-us----},
		q{043: Subfield _a, n-ma-us, is not valid.},
		q{043: Subfield _a, e-ur-ai, may be obsolete.},
		q{050: Two Cutters preceded by period.},
		q{050: Subfield _b may be missing.},
		q{050: Cutter may be unfinished.},
		q{082: Third digit must be followed by decimal point (6160.85) when number is longer than three digits.},
		q{082: Must have a subfield _2.},
		q{082: Subfield _2 has non-digits (sears).},
		q{082: Subfield _2 (24) is greater than edition 23.},
		q{082: (Abridged) Subfield _2 (10) is less than edition 11.},
		q{100: Check ending punctuation.},
		q{245: Must end with . (period).},
		q{245: Subfield _c must be preceded by /},
		q{245: Subfield _b should be preceded by space-colon, space-semicolon, or space-equals sign.},
		q{250: Must end with . (period)},
		q{260: Check ending punctuation, 2000},
		q{260: Subfield _b must be preceded by :},
		q{260: Subfield _c must be preceded by ,},
		q{300: Subfield _c must be preceded by ;},
		q{440: First word, the, may be an article, check 2nd indicator (0).},
		q{600: Should not end with closing parens-period.},
		q{600: Second indicator is not coded 7 but subfield _2 is present},
		q{600: Check ending punctuation.},
		q{600: Second indicator is coded 7 but subfield _2 is not present.},
		q{610: Check ending punctuation.},
		q{611: Should not end with closing parens-period.},
		q{611: Second indicator is coded 7 but subfield _2 is not present.},
		q{630: First indicator should be 0, check for article.},
		q{630: First word, title, does not appear to be an article, check 1st indicator (1).},
		q{630: Check ending punctuation.},
		q{630: Second indicator is coded 7 but subfield _2 is not present.},
		q{650: Check ending punctuation.},
		q{650: May have too few subfields.},
#q{650: Check ending punctuation.}, #ignored by local policy
		q{655: Check subfield 2 code (sars).},
		q{700: Check ending punctuation.},
		q{700: Check ending punctuation.},
		q{700: Subfield _e should be preceded by comma or hyphen.},
		q{710: Should not end with closing parens-period.},
		q{710: Check ending punctuation.},
	);

	my $linter = MARC::Lintadditions->new();
	isa_ok( $linter, 'MARC::Lintadditions' );

	$linter->check_record( $marc );
	my @warnings = $linter->warnings;
	while ( @warnings ) {
		my $expected = shift @expected;
		my $actual = shift @warnings;

		is( $actual, $expected, "Checking expected messages ($expected)" );
	}
	is( scalar @expected, 0, "All expected messages exhausted." );
}

#####
