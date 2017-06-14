=head1 NAME

MARC::Lintadditions -- extension of MARC::Lint

=head1 SYNOPSIS

#(See MARC::Lint and MARC::Doc::Tutorial of the MARC::Record distribution)

 use MARC::Batch;
 use MARC::Lintadditions;
 
 #change filename to path/name of a file of MARC records
 my $inputfile = 'filename.mrc';
 
 my $batch = MARC::Batch->new('USMARC', "$inputfile");
 my $linter = MARC::Lintadditions->new();
 my $counter = 0;
 my $errorcount = 0;
 while (my $record = $batch->next()) {
  $counter++;
  my $controlno =$record->field('001')->as_string();

  $linter->check_record($record);

  if (my @haswarnings = $linter->warnings()){
   print OUT join( "\t", "$controlno", @haswarnings, "\t\n");
   $errorcount++;
  }
 }

=head1 CHANGES NECESSARY TO MARC::Lint

The following have been changed from Distribution version of MARC::Lint:

-Added data for fields 001-008.

This includes fake data for these fields, since they don't have indicators or subfields (left first position of data blank where subfield code would be, and used blank for ind1 and ind2.
Need to test to see if this added data causes problems.

The following is the data (to be) added (to Lint.pm) for this (Lintadditions.pm) to work properly:

__DATA__
001	NR	CONTROL NUMBER

002	NR	LOCALLY DEFINED CATALOGER INITIALs #non-standard local practice
ind1	blank	Undefined
ind2	blank	Undefined
	NR	Undefined

003	NR	CONTROL NUMBER IDENTIFIER
ind1	blank	Undefined
ind2	blank	Undefined
	NR	Undefined

005	NR	DATE AND TIME OF LATEST TRANSACTION

006	R	FIXED-LENGTH DATA ELEMENTS--ADDITIONAL MATERIAL CHARACTERISTICS--GENERAL INFORMATION

007	R	PHYSICAL DESCRIPTION FIXED FIELD--GENERAL INFORMATION
ind1	blank	Undefined
ind2	blank	Undefined
	NR	Undefined

008	NR	FIXED-LENGTH DATA ELEMENTS--GENERAL INFORMATION
ind1	blank	Undefined
ind2	blank	Undefined
	NR	Undefined

=head1 DESCRIPTION

Continuation of MARC::Lint (part of the MARC::Record package (based on v. 1.38)). Contains added check functions.

Subfield codes may be indicated in the documentation with "$" or "_", interchangeably.

Functions added include:

C<readcodedata()>: Reads Geographic Area Code, Language Data at the end of Lintadditions.pm, to build an array of geographic area codes and language codes, valid and obsolete, for use in check_043 and check_041.
This is a modified version of the same subroutine in MARC::BBMARC, so that Lintadditions.pm can rely slightly less upon BBMARC.pm. 

C<check_007>: uses MARC::Lintadditions::validate007( \@bytesfrom007)
 This required changing MARC::Lint.pm by adding to __DATA__ information about the control fields, 001-008.
 For this, I used blank for indicator values, and left the subfield code blank before repeatability and description.
 Relies upon validate007(\@bytesfrom007)--see below.

C<check_020>: uses Business::ISBN to validate 020$a and 020$z ISBNs.

C<check_022>: uses Business::ISSN to validate 022$a ISSNs

C<check_028>: Warns if subfield 'b' is not present.

C<check_040>: Compares subfield 'b' against MARC Code List for Languages data.

C<check_041>: Warns if subfields are not evenly divisible by 3 unless second indicator is 7 
(future implementation would ensure that each subfield is exactly 3 characters unless ind2 is 7--since subfields are now repeatable. 
 This is not implemented here due to the large number of records needing to be corrected.).
Validates against the MARC Code List for Languages.

C<check_042>: Warns if each subfield does not contain a valid code.
Current valid codes: pcc, lcac, lccopycat, nsdp.
Planned improvement: Compare codes against MARC Code Lists for Relators, Sources, Description Conventions.

C<check_043>: Warns if each subfield a is not exactly 7 characters. Validates each code against the MARC code list for Geographic Areas.

 --This relies upon the DATA at the end of this file, which contains cleaned versions of the GAC, Languages, and Country code lists.

C<check_050>: Reports error if $b is not present.

 -Reports error if two Cutters are found with a period before each.
 For example: PN1997.A5$b.D45 2000
 Exception: G3701.P2 1992 $b .R3 (G schedule number with 2 cutters)
 Not an exception: HD5325.R12 1894 _b C5758 2001 (date in between Cutters)
 
C<check_082>: Ensures that subfield 2 is present (and within the limits of the current editions (18-22 for full, 11-14 for abridged).

 -Reports errors if subfield 2 has non-digits.
 -Also verifies that Dewey number has decimal after 3rd digit if more than 3 digits are present in subfield _a

C<check_1xx> set: Checks for 100, 110, 111, 130 (each individually).

 -Verifies ending punctuation, depending on last subfield being numeric (_3, _4, _5, _6, _8) 

C<check_130>: In addition to above, checks for ind1 equal to 0.

C<check_240>: Checks for ind2 equal to 0, and for punctuation before fields.

C<check_245>: Based on original check_245, which makes sure $a exists (and is first subfield).

 -Also warns if last character of field is not a period
 --Follows LCRI 1.0C, Nov. 2003 rather than MARC21 rule
 -Verifies that $c is preceded by / (space-/)
 -Verifies that initials in $c are not spaced
 -Verifies that $b is preceded by :;= (space-colon, space-semicolon, space-equals)
 -Verifies that $h is not preceded by space unless it is dash-space
 -Verifies that data of $h is enclosed in square brackets
 -Verifies that $n is preceded by . (period)
  --As part of that, looks for no-space period, or dash-space-period (for replaced elipses)
 -Verifies that $p is preceded by , (no-space-comma) when following $n and . (period) when following other subfields.
 -Performs rudimentary check of 245 2nd indicator vs. 1st word of 245$a (for manual verification).

C<check_246>: Checks punctuation preceding subfields.

C<check_250>: Ensures an ending period.

C<check_260>: Looks for correct punctuation before each subfield.

 -Makes sure field ends in period, square bracket, angle bracket, or hyphen.
 -Makes sure $a after the first is preceded by ; (space-semicolon)
 -Makes sure $b is preceded by : (space-colon)
 -Makes sure $c is preceded by , (comma)

C<check_300>: Looks for correct punctuation before each subfield.

 -Makes sure $b is preceded by : (space-colon)
 -Makes sure $c is preceded by ; (space-semicolon)

C<check_440>: Looks for correct punctuation before subfields.

 -Makes sure $n is preceded by . (no-space-period)
 -Makes sure $p is preceded by . (no-space-period)
 -Makes sure $x is preceded by , (no-space-comma)
 -Makes sure $v is preceded by ; (space-semicolon)

C<check_490>: Looks for correct punctuation before subfields.

 -Makes sure $x is preceded by , (no-space-comma)
 -Makes sure $v is preceded by ; (space-semicolon)

C<check_6xx> set: Checks for 600, 610, 611, 630, 650, 651, 655 (each individually).

 -Verifies ending punctuation, depending on last subfield being _2 or not
 -Makes sure field with second indicator 7 has subfield _2
 -Makes sure field with subfield _2 has second indicator 7

C<check_7xx> set: Checks for 700, 710, 711, 730, 740 (each individually).

 -Verifies ending punctuation, depending on last subfield being numeric (_3, _4, _5, _6, _8) 

C<check_700>: In addition to above, checks for ind1 equal to 3.

C<check_730>: In addition to above, checks for ind1 equal to 0.

C<check_740>: In addition to above, checks for ind1 equal to 0.

C<check_8xx> set: Checks for 800, 810, 811, 830.
 
 -Verifies ending punctuation.
 --Does not yet deal with any special needs for numerical subfields.

C<check_830>: In addition to above, checks for ind2 equal to 0.

Non-Object-Oriented subs:

C<validate007( \@bytesfrom007 )>, pass in an array of bytes from an 007 field. Returns an array reference and a scalar reference.  The returned arrayref contains the bytes from the passed array, up to the valid limit for that format type. It will contain 'bad' as a value for each byte that has a character not valid for that position. The scalar reference is either empty or holds the string '007 has data after limit'.
 See the POD in that sub for more information.
 

=head2 TO DO

 Link C<check_042> to MARC Code Lists for Relators, Sources, Description Conventions

 Find exceptions for C<check_050> double cutters vs. periods.

 Examine efficiency of C<readcodedata()>. Is there a better way to do the validation checks against the data for check_041 and check_043?

 -Testing use of global variable for storing parsed data, to hopefully improve efficiency.

 Determine allowed 240 punctuation before subfields.

 Determine whether 245 ending period should be less restrictive, and allow trailing spaces after the final period.

 In check_245, spaces between initial check--account for [i.e. [initial].]--verify that this works.

 Compare text of 245$h against list of GMDs.

 Add indicator2 checks for 440 articles and maintain list for 245 exceptions.

 For the check_1xx and check_7xx subroutines, verify trailing punctuation rules.

 For the check_8xx subroutines, deal with numerical subfields (see if their ending punctuation differs from the alphabetical subfields).

 Account for subfield 'u' (or others containing URIs) in ending punctuation checks.

 Test each of the checking functions to make sure they are working properly.

 Add other C<check_XXX> functions.

 Verify each of the codes against current and changed lists. Maintain code data when future changes occur.

=cut