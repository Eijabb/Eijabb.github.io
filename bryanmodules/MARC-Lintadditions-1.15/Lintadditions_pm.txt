package MARC::Lintadditions;

use strict;
use warnings;
use vars qw($VERSION);

use MARC::Lint::CodeData qw(%GeogAreaCodes %ObsoleteGeogAreaCodes %LanguageCodes %ObsoleteLanguageCodes %Sources600_651 %ObsoleteSources600_651 %Sources655 %ObsoleteSources655);

use base qw(MARC::Lint);

$VERSION = 1.15;

=head1 NAME

MARC::Lintadditions -- extension of MARC::Lint
May be integrated into MARC::Lint in future version.

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

=head1 DESCRIPTION

Continuation of MARC::Lint. Contains added check functions.

Subfield codes may be indicated in the documentation with "$" or "_", interchangeably.

Functions added include:

C<check_007>: uses MARC::Lintadditions::validate007( \@bytesfrom007)
 Relies upon validate007(\@bytesfrom007)--see below.
 Also reports warning for non-blank byte 2.

C<check_020>: Moved to MARC::Lint
uses Business::ISBN to validate 020$a and 020$z ISBNs.
Current version needs work for ISBN-13 checking. Uses an internal sub, _isbn13_check_digit($ean) to validate 13 digit ISBNs, based on code in Business::ISBN.

C<check_022>: uses Business::ISSN to validate 022$a ISSNs

C<check_028>: Warns if subfield 'b' is not present.

C<check_040>: Compares subfield 'b' against MARC Code List for Languages data.

 --This relies upon the MARC::Lint::CodeData data pack to MARC::Lintadditions.

C<check_041>: Moved to MARC::Lint

Warns if subfields are not evenly divisible by 3 unless second
indicator is 7 (future implementation would ensure that each subfield is exactly
3 characters unless ind2 is 7--since subfields are now repeatable. This is not
implemented here due to the large number of records needing to be corrected.).
Validates against the MARC Code List for Languages.

 --This relies upon the MARC::Lint::CodeData data pack to MARC::Lintadditions.

C<check_042>: Warns if each subfield does not contain a valid code.
Current valid codes: anuc, dc, dhca, dlr, gamma, gils, isds/c, issnuk, lc, lcac, lccopycat, lccopycat-nm, lcd, lcderive, lchlas, lcllh, lcnccp, lcnitrate, lcnuc, lcode, msc, natgaz, nlc, nlmcopyc, nsdp, ntccf, pcc, premarc, reveal, sanb, scipio, ukblsr, ukscp, xissnuk, xlc, xnlc, xnsdp.
(based on MARC Code Lists for Relators, Sources, Description Conventions for 042).

C<check_043>: Moved to MARC::Lint

Warns if each subfield a is not exactly 7 characters. Validates each code against the MARC code list for Geographic Areas.

 --This relies upon the MARC::Lint::CodeData data pack to MARC::Lintadditions.

C<check_050>: Reports error if $b is not present.

 -Reports error if two Cutters are found with a period before each.
 For example: PN1997.A5$b.D45 2000
 Exception: G3701.P2 1992 $b .R3 (G schedule number with 2 Cutters)
 Not an exception: HD5325.R12 1894 _b C5758 2001 (date in between Cutters)
 
C<check_082>: Ensures that subfield 2 is present (and within the limits of the current editions (18-23 for full, 11-15 for abridged).

 -Reports errors if subfield 2 has non-digits.
 -Also verifies that Dewey number has decimal after 3rd digit if more than 3 digits are present in subfield _a

C<check_1xx> set: Checks for 100, 110, 111, 130 (each individually).

 -Verifies ending punctuation, depending on last subfield being numeric (_0, _1, _2, _3, _4, _5, _7, _9)
 -Warns unless subfield e is preceded by comma or hyphen

C<check_130>: In addition to above, checks for ind1 equal to 0. Also checks for articles using MARC::Lint::_check_article().

C<check_240>: Checks for ind2 equal to 0, and for punctuation before fields. Also reports possible articles using MARC::Lint's _check_article() method.

C<check_245>: Moved to MARC::Lint

Based on original check_245, which makes sure $a exists (and is first subfield).

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
 -Also makes sure at least one $a and one $b are present.
 -Accounts for $6 as first subfield.

C<check_300>: Looks for correct punctuation before each subfield.

 -Makes sure $b is preceded by : (space-colon)
 -Makes sure $c is preceded by ; (space-semicolon)

C<check_440>: Looks for correct punctuation before subfields.

 -Makes sure $n is preceded by . (no-space-period)
 -Makes sure $p is preceded by . (no-space-period)
 -Makes sure $x is preceded by , (no-space-comma)
 -Makes sure $v is preceded by ; (space-semicolon)
 -Performs rudimentary article check of 440 2nd indicator vs. 1st word of 440$a (for manual verification) using MARC::Lint's _check_article() method.

C<check_490>: Looks for correct punctuation before subfields.

 -Makes sure $x is preceded by , (no-space-comma)
 -Makes sure $v is preceded by ; (space-semicolon)

C<check_6xx> set: Checks for 600, 610, 611, 630, 650, 651, 655 (each individually).

 -Verifies ending punctuation, depending on last subfield being _2 or not
 -Makes sure field with second indicator 7 has subfield _2
 -Makes sure field with subfield _2 has second indicator 7
 -630 check also looks for articles using MARC::Lint's _check_article() method.

C<check_7xx> set: Checks for 700, 710, 711, 730, 740 (each individually).

 -Verifies ending punctuation, depending on last subfield being numeric (_3, _4, _5, _6, _8) 

C<check_700>: In addition to above, checks for ind1 equal to 3.

C<check_730>: In addition to above, checks for ind1 equal to 0. Also checks for articles using MARC::Lint::_check_article().

C<check_740>: In addition to above, checks for ind1 equal to 0.

C<check_8xx> set: Checks for 800, 810, 811, 830.
 
 -Verifies ending punctuation.
 --Does not yet deal with any special needs for numerical subfields.

C<check_830>: In addition to above, checks for ind2 equal to 0. Also checks for articles using MARC::Lint::_check_article().

Non-Object-Oriented subs:

C<validate007( \@bytesfrom007 )>, pass in an array of bytes from an 007 field. Returns an array reference and a scalar reference.  The returned arrayref contains the bytes from the passed array, up to the valid limit for that format type. It will contain 'bad' as a value for each byte that has a character not valid for that position. The scalar reference is either empty or holds the string '007 has data after limit.'
 See the POD in that sub for more information.
 

=head2 TO DO

 Check obsolete sources in 6xx for subfield 2.
 
 Reduce duplicated code in check_600 and check_655.

 Determine whether subfield _l is allowed in all 1xx, 6xx, 7xx, and 8xx fields, with identical rules. If so, remove duplicate code, enter in check_100(), with additional copy in check_240().

 Link C<check_042> to MARC Code Lists for Relators, Sources, Description Conventions

 Find exceptions for C<check_050> double Cutters vs. periods.

 Maintain MARC::Lint::CodeData file for updated geographic area codes, languages, or countries.

 Determine allowed 240 punctuation before subfields.

 Determine whether 245 ending period should be less restrictive, and allow trailing spaces after the final period.

 In check_245, spaces between initial check--account for [i.e. [initial].]--verify that this works.

 Compare text of 245$h against list of GMDs.
 Allow user to pass in array ref of locally defined GMDs when check_245 is called separately.

 Add indicator2 checks for 440 articles and maintain list for 245 exceptions.

 For the check_1xx and check_7xx subroutines, verify trailing punctuation rules.

 For the check_8xx subroutines, deal with numerical subfields (see if their ending punctuation differs from the alphabetical subfields).

 Account for subfield 'u' (or others containing URIs) in ending punctuation checks.

 Test each of the checking functions to make sure they are working properly.

 Add other C<check_XXX> functions.

 Verify each of the codes against current and changed lists. Maintain code data when future changes occur.

 Account for subfield '8' as 1st or 2nd (after subfield '6') subfield. Currently subfield 6 should be allowed as 1st subfield (in cases where 1st should usually be 'a'), but the presence of subfield '8' as the 1st subfield may generate errors.

=cut


#########################################
#########################################

sub check_007 {

    my $self = shift;
    my $field = shift;

    #turn off uninitialized warnings
    no warnings 'uninitialized';

    #put individual bytes of 007 field into 
    my $field007 = $field->as_string();

    my @bytes = (split ('', $field007));

    #warn if byte 2 is not blank
    $self->warn( "007: byte 2, 'u' is no longer valid." ) if ($bytes[2] eq 'u');

    #clean byte[2] before passing (change 'u' or '|' to blank space)
    $bytes[2] =~ s/[u|]/ /;

    #call validate007 sub, which found in this package
    #The sub returns an arrayref and a scalarref
    my ($arrayref007, $hasextradataref)  = MARC::Lintadditions::validate007(\@bytes);

    #dereference the returned values
    my @cleaned007 = @$arrayref007;

    #initialize $badrecord
    my $badrecord = 0;

    #loop through the array looking for bad bytes
    for my $i (0..$#cleaned007) {
        if ($cleaned007[$i] eq 'bad'){
                #warn which byte is bad
                $self->warn( "007: byte $i ($bytes[$i]) is invalid." );
            $badrecord=1;
        } #if bad byte
    } #for each byte

    #check for data after valid limit
    if ($$hasextradataref) {
    #warn about extra data after max limit
        $self->warn( "007: $$hasextradataref" );
        $badrecord = 1;
    }

    unless ($badrecord) {
        my $cleaned007data = join ('', @cleaned007);
        #ignore good 007 fields
        if ($field007 ne $cleaned007data) {
            $self->warn( "007: Check for trailing space ($field007 does not match $cleaned007data)." );
        } #if original does not match cleaned
    } #unless

} #check_007;

#########################################
#########################################

=head2 check_020() (CUT THIS)

This has been moved to MARC::Lint.

Looks at 020$a and reports errors if the check digit is wrong.
Looks at 020$z and validates number if hyphens are present.

Uses Business::ISBN to do validation.

=head2 TO DO (check_020)

Use this subroutine to help move invalid 020$a to $z.

Use this subroutine to help move valid $z to $a if CIP-level.

Update for $y if that is added to MARC21.

Fix 13-digit ISBN checking.
Currently reports all 13-digit ISBNS as needing checking.

sub check_020 {


use Business::ISBN;

    my $self = shift;
    my $field = shift;

###################################################

# break subfields into code-data array and validate data

    my @subfields = $field->subfields();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        my $isbnno = $data;
        #remove any hyphens
        $isbnno =~ s/\-//g;
        #remove nondigits
        $isbnno =~ s/^\D*(\d{9,12}[X\d])\b.*$/$1/;

        #report error if this is subfield 'a' 
        #and the first 10 or 13 characters are not a match for $isbnno
        if ($code eq 'a') { 
            if ((substr($data,0,length($isbnno)) ne $isbnno)) {
                $self->warn( "020: Subfield a may have invalid characters.");
            } #if first characters don't match

            #report error if no space precedes a qualifier in subfield a
            if ($data =~ /\(/) {
                $self->warn( "020: Subfield a qualifier must be preceded by space, $data.") unless ($data =~ /[X0-9] \(/);
            } #if data has parenthetical qualifier

            #report error if unable to find 10-13 digit string of digits in subfield 'a'
            if (($isbnno !~ /(?:^\d{10}$)|(?:^\d{13}$)|(?:^\d{9}X$)/)) {
                $self->warn( "020: Subfield a has the wrong number of digits, $data."); 
            } # if subfield 'a' but not 10 or 13 digit isbn
            #otherwise, check 10 and 13 digit checksums for validity
            else {
                if ((length ($isbnno) == 10)) {
                    $self->warn( "020: Subfield a has bad checksum, $data.") if (Business::ISBN::is_valid_checksum($isbnno) != 1); 
                } #if 10 digit ISBN has invalid check digit
                # do validation check for 13 digit isbn
#########################################
### Not yet fully implemented ###########
#########################################
                elsif (length($isbnno) == 13){
                    #change line below once Business::ISBN handles 13-digit ISBNs
                    my $is_valid_13 = _isbn13_check_digit($isbnno);
                    $self->warn( "020: Subfield a has bad checksum (13 digit), $data.") unless ($is_valid_13 == 1); 
                } #elsif 13 digit ISBN has invalid check digit
###################################################
            } #else subfield 'a' has 10 or 13 digits
        } #if subfield 'a'
        #look for valid isbn in 020$z
        elsif ($code eq 'z') {
            if (($data =~ /^ISBN/) || ($data =~ /^\d*\-\d+/)){
##################################################
## Turned on for now--Comment to unimplement ####
##################################################
                $self->warn( "020:  Subfield z is numerically valid.") if ((length ($isbnno) == 10) && (Business::ISBN::is_valid_checksum($isbnno) == 1)); 
            } #if 10 digit ISBN has invalid check digit
        } #elsif subfield 'z'

    } # while @subfields

} # check_020

=head2 _isbn13_check_digit($ean)

Internal sub to determine if 13-digit ISBN has a valid checksum. The code is
taken from Business::ISBN::as_ean. It is expected to be temporary until
Business::ISBN is updated to check 13-digit ISBNs itself.

=cut

sub _isbn13_check_digit { 

    my $ean = shift;
    #remove and store current check digit
    my $check_digit = chop($ean);

    #calculate valid checksum
    my $sum = 0;
    foreach my $index ( 0, 2, 4, 6, 8, 10 )
        {
        $sum +=     substr($ean, $index, 1);
        $sum += 3 * substr($ean, $index + 1, 1);
        }

    #take the next higher multiple of 10 and subtract the sum.
    #if $sum is 37, the next highest multiple of ten is 40. the
    #check digit would be 40 - 37 => 3.
    my $valid_check_digit = ( 10 * ( int( $sum / 10 ) + 1 ) - $sum ) % 10;

    return $check_digit == $valid_check_digit ? 1 : 0;

} # _isbn13_check_digit
#########################################
#########################################
=cut

=head2 DESCRIPTION

Subroutine for validating 022s.
Looks at 022$a and reports errors if the check digit is wrong.
Also reports errors if 022$a is not in the form 4-digits-hypen-4-digits.

Uses Business::ISSN to do validation.

=cut

sub check_022 {



    my $self = shift;
    my $field = shift;

use Business::ISSN;

    # break subfields into code-data array and validate data

    my @subfields = $field->subfields();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        my $issn = $data;
        #remove nondigits
        $issn =~ s/^\D*(\d{4}\-?\d{3}[X\d])\b.*$/$1/;

        #report error if this is subfield 'a' 
        #and the first 9 are not a match for $issn
         if (($code eq 'a') && (substr($data,0,length($issn)) ne $issn)) {
            $self->warn( "022: Subfield a may have invalid characters.");
        }

        #report error if unable to find valid 9 character ISSN
        if (($code eq 'a') && ($issn !~ /^\d{4}\-?\d{3}[X\d]/)){
            $self->warn( "022: Subfield a has the wrong number of digits.");
        } # if subfield 'a' but not correct form
        elsif ($code eq 'a') {
            unless (Business::ISSN::is_valid_checksum($issn) == 1) {
                $self->warn( "022: Subfield a has bad checksum, $data.");
            } #if correct length ISSN has invalid check digit


###################################################
###################################################
##### add elsif here if ISSN is longer than 9
###################################################
#				$self->warn( "022: Subfield a has bad checksum, $data.");
###################################################
        } #elsif subfield 'a'
###################################################
###################################################
##### elsif here if interested in checking $z or $y
###################################################
    } # while @subfields


} #check_022


#########################################
#########################################

=head2 DESCRIPTION

Subroutine for validating 024s (UPC (ind1 eq '1') and EAN (ind1 eq '3')).

Uses Business::??? to do validation [initial version checks only length].

=head2 TODO (check_024)

Implement validation using Business:: modules for EAN and UPC.

Implement validation of ISMN (ind1 eq '2')

=cut

sub check_024 {

    my $self = shift;
    my $field = shift;

#use EAN and UPC modules for validation
use Business::Barcode::EAN13;
use Business::UPC;
#use Business::ISMN;

    #get 1st ind
    my $ind1 = $field->indicator(1);
    #get subfield 'a' (should only be 1)
    my @subfields = $field->subfield( 'a' );

    #loop through subfield 'a'
    foreach my $subfield (@subfields) {

        if ($ind1 eq '1') {
            #upc validation
            #report error if number is not 12 digits
            unless ((length($subfield) == 12) && ($subfield =~ /\d{12}/)) {
                $self->warn( "024: First indicator is $ind1 (UPC), but subfield _a is not 12 digits ($subfield).");
            } #unless 12 digit UPC
            else {
                #do validation check
                my $upc = new Business::UPC($subfield);
                unless ($upc->is_valid) {
                    $self->warn( "024: Subfield _a (UPC) has bad checksum ($subfield).");
                } #unless correct length UPC has valid check digit
            } #else 12 digits
        } #if ind1 is UPC
        elsif ($ind1 eq '2') {
            #ISMN validation
        } #elsif ind1 is ISMN
        elsif ($ind1 eq '3') {
            #EAN validation
            #report error if number is not 13 digits
            unless ((length($subfield) == 13) && ($subfield =~ /\d{13}/)) {
                $self->warn( "024: First indicator is $ind1 (EAN), but subfield _a is not 13 digits ($subfield).");
            } #unless 13 digit EAN
            else {
                #do validation check
                my $is_valid_ean = Business::Barcode::EAN13::valid_barcode($subfield);
                unless ($is_valid_ean) {
                    $self->warn( "024: Subfield _a (EAN) has bad checksum ($subfield).");
                } #unless correct length EAN has valid check digit
            } #else 13 digits
        } #elsif ind1 is EAN

    } # while @subfields


} #check_024

#########################################
#########################################

sub check_028 {

    my $self = shift;
    my $field = shift;

    unless ($field->subfield('b')) {
        $self->warn ("028: Subfield b is missing.");
    }

} # check_028

#########################################
#########################################


sub check_040 {

    my $self = shift;
    my $field = shift;

    #check language code if $b is present
    #Uses codes from the MARC::Lint::CodeData package (%LanguageCodes, %ObsoleteLanguageCodes)
    if ($field->subfield('b')) {
        my $field040b = $field->subfield('b');

        my $validlang = 1 if ($LanguageCodes{$field040b});
        #look for invalid code match if valid code was not matched
        my $obsoletelang = 1 if $ObsoleteLanguageCodes{$field040b};

        # skip valid subfields
        unless ($validlang) {
            #report invalid matches as possible obsolete codes
            if ($obsoletelang) {
                $self->warn( "040: Subfield _b, $field040b, may be obsolete.");
            }
            else {
                $self->warn( "040: Subfield _b, $field040b, is not valid.");
            } #else code not found 
        } # unless found valid code
    } #if subfield b is present

} # check_040

#########################################
#########################################
=head2 CUT THIS
sub check_041 {

    #Uses codes from the MARC::Lint::CodeData package (%LanguageCodes, %ObsoleteLanguageCodes)

    my $self = shift;
    my $field = shift;

    # break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while

    #warn if length of each subfield is not divisible by 3 unless ind2 is 7
    unless ($field->indicator(2) eq '7') {
        for (my $index = 0; $index <=$#newsubfields; $index+=2) {
            if (length ($newsubfields[$index+1]) %3 != 0) {
                $self->warn( "041: Subfield _$newsubfields[$index] must be evenly divisible by 3 or exactly three characters if ind2 is not 7, ($newsubfields[$index+1])." );
            } #if field length not divisible evenly by 3
##############################################
# validation against code list data
## each subfield has a multiple of 3 chars
# need to look at each group of 3 characters
            else {

                #break each character of the subfield into an array position
                my @codechars = split '', $newsubfields[$index+1];

                my $pos = 0;
                #store each 3 char code in a slot of @codes041
                my @codes041 = ();
                while ($pos <= $#codechars) {
                    push @codes041, (join '', @codechars[$pos..$pos+2]);
                    $pos += 3;
                }


                foreach my $code041 (@codes041) {
                    #see if language code matches valid code
                    my $validlang = 1 if ($LanguageCodes{$code041});
                    #look for invalid code match if valid code was not matched
                    my $obsoletelang = 1 if ($ObsoleteLanguageCodes{$code041});

                    # skip valid subfields
                    unless ($validlang) {
#report invalid matches as possible obsolete codes
                        if ($obsoletelang) {
                            $self->warn( "041: Subfield _$newsubfields[$index], $newsubfields[$index+1], may be obsolete.");
                        }
                        else {
                            $self->warn( "041: Subfield _$newsubfields[$index], $newsubfields[$index+1] ($code041), is not valid.");
                        } #else code not found 
                    } # unless found valid code
                } #foreach code in 041
            } # else subfield has multiple of 3 chars
##############################################
        } # foreach subfield
    } #unless ind2 is 7
} #check_041

=cut

#########################################
#########################################

sub check_042 {

=head2 TO DO (check_042)

Consider storing the sources code list in MARC::Lint::CodeData.

=cut

    my $self = shift;
    my $field = shift;

######################################### 
## Change this once code list checking is implemented 
#########################################
#add other values as they are needed
    my @validcodes = ('anuc', 'dc', 'dhca', 'dlr', 'gamma', 'gils', 'isds/c', 'issnuk', 'lc', 'lcac', 'lccopycat', 'lccopycat-nm', 'lcd', 'lcderive', 'lchlas', 'lcllh', 'lcnccp', 'lcnitrate', 'lcnuc', 'lcode', 'msc', 'natgaz', 'nlc', 'nlmcopyc', 'nsdp', 'ntccf', 'pcc', 'premarc', 'reveal', 'sanb', 'scipio', 'ukblcatcopy', 'ukblderived', 'ukblsr', 'ukscp', 'xissnuk', 'xlc', 'xnlc', 'xnsdp');
######################################### 

    # break subfields into code-data array, checking for invalid data along the way

    my @subfields = $field->subfields();
    my @newsubfields = ();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unless (grep {$data =~ /^$_$/} @validcodes) {
            $self->warn( "042: subfield _a contains an invalid code, $data" );
        }
    } # while
} #check_042

#########################################
#########################################

=head2 CUT THIS
sub check_043 {

    #Uses codes from the MARC::Lint::CodeData package (%GeogAreaCodes, %ObsoleteGeogAreaCodes)

    my $self = shift;
    my $field = shift;

    # break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while

    #warn if length of subfield a is not exactly 7
    for (my $index = 0; $index <=$#newsubfields; $index+=2) {
        if (($newsubfields[$index] eq 'a') && (length ($newsubfields[$index+1]) != 7)) {
            $self->warn( "043: Subfield _a must be exactly 7 characters, $newsubfields[$index+1]" );
        } # if suba and length is not 7
        #check against code list for geographic areas.
        elsif ($newsubfields[$index] eq 'a') {

            #see if geog area code matches valid code
            my $validgac = 1 if ($GeogAreaCodes{$newsubfields[$index+1]});
            #look for obsolete code match if valid code was not matched
            my $obsoletegac = 1 if ($ObsoleteGeogAreaCodes{$newsubfields[$index+1]});

            # skip valid subfields
            unless ($validgac) {
                #report invalid matches as possible obsolete codes
                if ($obsoletegac) {
                    $self->warn( "043: Subfield _a, $newsubfields[$index+1], may be obsolete.");
                }
                else {
                    $self->warn( "043: Subfield _a, $newsubfields[$index+1], is not valid.");
                } #else code not found 
            } # unless found valid code

        } #elsif suba
    } #foreach subfield
} #check_043

=cut

#########################################
#########################################

sub check_050 {

=head2


 Warns if subfield 'a' doesn't start with capital letters followed by digits.
 Warns if subfield 'b' is not present.
 Warns if two alphanumeric Cutters are preceded by a period.
 For example: _a TX907.5.F8 _b .G3 2001
 Exception--G schedule, e.g.: _a G3701.P2 1992 _b .R3

 Warns if Cutter letter is followed by nothing or a space (e.g. _b.R 2004)
 (unfinished coding)
 
 Warns if no Cutter is preceded by a period. Exceptions need to be found where this is ok.

 Warns if letter is last character of subfield 'a' (e.g., _aPN1997.R_bF39 2004)

=cut

    my $self = shift;
    my $field = shift;

    #get first 050$a
    my $subfielda = $field->subfield('a');
    unless ($subfielda =~ /^[A-Z]+\d+/) {
        $self->warn( "050: Subfield _a does not appear to be a valid LC classification.")
    } #unless subfield a starts with capital letter
    
    #get 050$b
    my $subfieldb;
    unless ($field->subfield('b')) {
        $self->warn( "050: Subfield _b may be missing.")
    }
    else {
        $subfieldb = $field->subfield('b');
        #put 'a' and 'b' together
        my $callno = $subfielda.$subfieldb;

        #warn if two alphanumeric Cutters are preceded by periods
        if ($callno =~ /\.[A-Z]\d+.*?\.[A-Z]\d*/) {
            #exceptions to two-period Cutters in field
###### In Process ######
            #exception only if LCC is in G schedule
            unless (($subfielda =~ /^G\d/)&&($subfielda =~ /\.[A-Z]\d+\s*\d{4}/)) {
########################
                $self->warn( "050: Two Cutters preceded by period.")
            } #unless this is an exception
        } #if $callno has double-period Cutters
        if (($callno =~ /[A-Z]\s+/) || ($subfielda =~ /[A-Z]$/)) {
                $self->warn( "050: Cutter may be unfinished.")
        } #if Cutter letter is followed by blank or nothing
        unless ($subfieldb =~ /^\.[A-Z]/) {
		unless ($callno =~ /\.[A-Z]/) {
                #if a capital letter for Cutter appears in the field report error for missing period
                $self->warn( "050: Cutter not preceded by period.") if ($callno =~ /^[A-Z]+.+?[A-Z]/);
            } #unless another Cutter is preceded by period
        } #unless subfieldb Cutter is preceded by period

    } # else field b is present

} # check_050

#########################################
#########################################

sub check_082 {

    my $self = shift;
    my $field = shift;
    
    #check decimal placement
    my $deweyno = $field->subfield('a') ? $field->subfield('a') : '';
    #if starts with 3 digits followed by at least one other character
    if ($deweyno =~ /^\d{3}.+/) {
    #add warning unless 3 digits, optional slash, then period
    $self->warn( "082: Third digit must be followed by decimal point ($deweyno) when number is longer than three digits." ) unless ($deweyno =~ /^\d{3}(\/)?\.\d/);
    }
    
    ######## Subfield 2 checks ########
    my $subfield2 = $field->subfield ("2") if ($field->subfield("2"));

    #all 082 fields need a subfield 2
    ##Some libraries may want this optional due to older records lacking subfield 2
    unless ($subfield2) {$self->warn( "082: Must have a subfield _2." );}

    #report error if non-digits are in subfield 2
    elsif ($subfield2 =~ /\D/) {$self->warn( "082: Subfield _2 has non-digits ($subfield2)." );}

    #If 1st ind is 0, edition must be lower than 23 (modify this code when the next ed. comes out)
    elsif ((($field->indicator(1)) eq '0') && ($subfield2 > 23)) {$self->warn( "082: Subfield _2 ($subfield2) is greater than edition 23." );}
    #If 1st ind is 0, edition for recent records should be greater than 18
    elsif ((($field->indicator(1)) eq '0') && ($subfield2 < 18)) {$self->warn( "082: Subfield _2 ($subfield2) is less than edition 18." );}
    #If 1st ind is 1, edition must be lower than 16 (modify this code when the next ed. comes out)
    elsif ((($field->indicator(1)) eq '1') && ($subfield2 > 16)) {$self->warn( "082: (Abridged) Subfield _2 ($subfield2) is greater than edition 15." );}
    #If 1st ind is 1, edition for recent records should be greater than 11
    elsif ((($field->indicator(1)) eq '1') && ($subfield2 < 11)) {$self->warn( "082: (Abridged) Subfield _2 ($subfield2) is less than edition 11." );}

} #check_082

#########################################
#########################################

=head2 NAME

check_1xx subroutines

=head2 DESCRIPTION

Set of checks for trailing punctuation for 100, 110, 111, and 130 fields.

=head2 TO DO (check_1xx)

Account for other numerical subfields (which may have special punctuation needs).

Verify rules for ending punctuation.

=cut

sub check_100 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    my @subfields = $field->subfields();
    my @newsubfields = ();

    #break subfields into code-data array (so the entire field is in one array)
    #keep track of number of numeric subfields (as the last subfield(s))
    my $numericsubfieldcount = 0;
    my $nonnumericcode = 0;
    my $has_sub_e = 0;
    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        #stop looking for numeric when first nonnumeric (other than 6 or 8) code is found
        $nonnumericcode = 1 if ($code =~ /^[^0-579]$/);
        $has_sub_e = 1 if ($code eq 'e');
        unless ($nonnumericcode) {
            $numericsubfieldcount++ if ($code =~ /^[0-579]$/);
        } #unless nonnumeric code
        unshift (@newsubfields, $code, $data);
    } # while
        
    #Punctuation checks should apply to subfield preceding last numeric subfield.
    unless ($numericsubfieldcount) {

        # 1xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.");
        }

        # 1xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.");
        }
    } #unless last is numeric subfield

    #if last is numeric subfield (and field has at least 2 subfields)
    elsif ($numericsubfieldcount && ($#newsubfields >=3)) {
        # 1xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields-($numericsubfieldcount*2)] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.");
        }

        # 1xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields-($numericsubfieldcount*2)] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.");
        }
    } #elsif last is numeric subfield (and field has at least 2 subfields)
    #warn if numeric subfield exists but field has fewer than 2 subfields
    elsif (($numericsubfieldcount > 0) && ($#newsubfields < 3)) {
        $self->warn ($tagno, ": May have too few subfields.");
    }

    if ($has_sub_e) {
        #convert field to as_usmarc format to facilitate regex parsing
        my $field_as_marc = $field->as_usmarc();
        $self->warn ($tagno, ": Subfield _e should be preceded by comma or hyphen.") unless ($field_as_marc =~ /[\,\-]\x1Fe/);
    } #if has sub e

} # check_100

#########################################
#########################################
#########################################
#########################################

sub check_110 {

    my $self = shift;
    my $field = shift;

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

} # check_110

#########################################
#########################################
#########################################
#########################################

sub check_111 {

    my $self = shift;
    my $field = shift;

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

} # check_111

#########################################
#########################################
#########################################
#########################################

sub check_130 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #check indicator--should always be 0 
    ##Some libraries may have valid records with non-zero 1st indicator
    my $ind1 = $field->indicator(1);
    unless ($ind1 eq '0') {
        $self->warn ($tagno, ": First indicator should be 0, check for article.");
    } #unless 1st indicator is 0

    ######################################
    #double-check for article vs. indicator
    ######################################
    $self->MARC::Lint::_check_article($field);

    #similar punctuation rules to check_100, so call that instead of repeating
    check_100($self, $field);

    #################################################
    #check for proper punctuation before subfield _l#
    #################################################
    
        #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists



} # check_130

#########################################
#########################################

sub check_240 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #check 2nd indicator--should always be 0
    #some libraries may allow non-zero 2nd indicator
    my $ind2 = $field->indicator(2);
    unless ($ind2 eq '0') {
        $self->warn ($tagno, ": Second indicator should be 0, check for article.");
    } #unless 2nd indicator is 0

    ######################################
    #double-check for article vs. indicator
    $self->MARC::Lint::_check_article($field);

    #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists


} # check_240
#########################################
#########################################

=head2 CUT THIS

sub check_245 {

    my $self = shift;
    my $field = shift;
    
    ##add line below once GMD checking is implemented
    ## my %gmds = %{$_[0]} if @_;
    
    if ( not $field->subfield( "a" ) ) {
        $self->warn( "245: Must have a subfield _a." );
    }

    # break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while
        
    # 245 must end in period (may want to make this less restrictive by allowing trailing spaces)
    #do 2 checks--for final punctuation (MARC21 rule), and for period (LCRI 1.0C, Nov. 2003)
    if ($newsubfields[$#newsubfields] !~ /[.?!]$/) {
        $self->warn ( "245: Must end with . (period).");
    }
    elsif($newsubfields[$#newsubfields] =~ /[?!]$/) {
        $self->warn ( "245: MARC21 allows ? or ! as final punctuation but LCRI 1.0C, Nov. 2003, requires period.");
    }

#subfield a should be first subfield
    if ($newsubfields[0] ne 'a') {
        $self->warn ( "245: First subfield must be _a, but it is _$newsubfields[0]");
    }
    
    #subfield c, if present, must be preceded by /
    #also look for space between initials
    if ($field->subfield("c")) {
    
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
# 245 subfield c must be preceded by / (space-/)
            if ($newsubfields[$index] eq 'c') { 
                $self->warn ( "245: Subfield _c must be preceded by /") if ($newsubfields[$index-1] !~ /\s\/$/);
                # 245 subfield c initials should not have space
                $self->warn ( "245: Subfield _c initials should not have a space.") if (($newsubfields[$index+1] =~ /\b\w\. \b\w\./) && ($newsubfields[$index+1] !~ /\[\bi\.e\. \b\w\..*\]/));
                last;
            } #if
        } #for
    } # subfield c exists

    #each subfield b, if present, should be preceded by :;= (colon, semicolon, or equals sign)
    ### Are there others? ###
    if ($field->subfield("b")) {

        # 245 subfield b should be preceded by space-:;= (colon, semicolon, or equals sign)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#report error if subfield 'b' is not preceded by space-:;= (colon, semicolon, or equals sign)
            if (($newsubfields[$index] eq 'b') && ($newsubfields[$index-1] !~ / [:;=]$/)) {
                $self->warn ( "245: Subfield _b should be preceded by space-colon, space-semicolon, or space-equals sign.");
            } #if
        } #for
    } # subfield b exists


    #each subfield h, if present, should be preceded by non-space
    if ($field->subfield("h")) {

        # 245 subfield h should not be preceded by space
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
            #report error if subfield 'h' is preceded by space (unless dash-space)
            if (($newsubfields[$index] eq 'h') && ($newsubfields[$index-1] !~ /(\S$)|(\-\- $)/)) {
                $self->warn ( "245: Subfield _h should not be preceded by space.");
            } #if h and not preceded by no-space (unless dash)
            #report error if subfield 'h' does not start with open square bracket with a matching close bracket
            ##could have check against list of valid values here
            if (($newsubfields[$index] eq 'h') && ($newsubfields[$index+1] !~ /^\[\w*\s*\w*\]/)) {
                $self->warn ( "245: Subfield _h must have matching square brackets, $newsubfields[$index].");
            }
        } #for
    } # subfield h exists

    #each subfield n, if present, must be preceded by . (period)
    if ($field->subfield("n")) {

        # 245 subfield n must be preceded by . (period)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
            #report error if subfield 'n' is not preceded by non-space-period or dash-space-period
            if (($newsubfields[$index] eq 'n') && ($newsubfields[$index-1] !~ /(\S\.$)|(\-\- \.$)/)) {
                $self->warn ( "245: Subfield _n must be preceded by . (period).");
            } #if
        } #for
    } # subfield n exists

    #each subfield p, if present, must be preceded by a , (no-space-comma) if it follows subfield n, or by . (no-space-period or dash-space-period) following other subfields
    if ($field->subfield("p")) {

        # 245 subfield p must be preceded by . (period) or , (comma)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield p
            if ($newsubfields[$index] eq 'p') {
# case for subfield 'n' being field before this one (allows dash-space-comma)
                if (($newsubfields[$index-2] eq 'n') && ($newsubfields[$index-1] !~ /(\S,$)|(\-\- ,$)/)) {
                    $self->warn ( "245: Subfield _p must be preceded by , (comma) when it follows subfield _n.");
                } #if subfield n precedes this one
                # elsif case for subfield before this one is not n
                elsif (($newsubfields[$index-2] ne 'n') && ($newsubfields[$index-1] !~ /(\S\.$)|(\-\- \.$)/)) {
                    $self->warn ( "245: Subfield _p must be preceded by . (period) when it follows a subfield other than _n.");
                } #elsif subfield p preceded by non-period when following a non-subfield 'n'
            } #if index is looking at subfield p
        } #for
    } # subfield p exists


#######################################

=head2 CREDITS and DESCRIPTION (245 ind2 check)

Check of 245 2nd ind is based on code from Ian Hamilton.
This version is more limited in that it focuses on
English, Spanish, French, Italian and German articles.
Certain possible articles have been removed if they are valid English non-articles.
This version also disregards 041 codes and just uses
the list of articles to provide warnings/suggestions

source for articles = http://www.loc.gov/marc/bibliographic/bdapp-e.html

#add articles here as needed
##Some omitted due to similarity with valid words (e.g. the German 'die').
    my %article = (
        'a' => 'eng glg hun por',
        'an' => 'eng',
        'das' => 'ger',
        'dem' => 'ger',
        'der' => 'ger',
        'ein' => 'ger',
        'eine' => 'ger',
        'einem' => 'ger',
        'einen' => 'ger',
        'einer' => 'ger',
        'eines' => 'ger',
        'el' => 'spa',
        'en' => 'cat dan nor swe',
        'gl' => 'ita',
        'gli' => 'ita',
        'il' => 'ita mlt',
        'l' => 'cat fre ita mlt',
        'la' => 'cat fre ita spa',
        'las' => 'spa',
        'le' => 'fre ita',
        'les' => 'cat fre',
        'lo' => 'ita spa',
        'los' => 'spa',
        'os' => 'por',
        'the' => 'eng',
        'um' => 'por',
        'uma' => 'por',
        'un' => 'cat spa fre ita',
        'una' => 'cat spa ita',
        'une' => 'fre',
        'uno' => 'ita',
    );

#add exceptions here as needed
# may want to make keys lowercase
    my %exceptions = (
        'A & E' => 1,
        'A-' => 1,
        'A is ' => 1,
        'A l\'' => 1,
        'A la ' => 1,
        'El Nino' => 1,
        'El Salvador' => 1,
        'L-' => 1,
        'La Salle' => 1,
        'Las Vegas' => 1,
        'Lo mein' => 1,
        'Los Alamos' => 1,
        'Los Angeles' => 1,
    );

    #get 245 subfield 'a'
    my $title = $field->subfield('a');
    #get 2nd indicator
    my $ind2 = $field->indicator(2);

    my $char1_notalphanum = 0;
    #check for apostrophe, quote, bracket,  or parenthesis, before first word
    #remove if found and add to non-word counter
    while ($title =~ /^["'\[\(*]/){
        $char1_notalphanum++;
        $title =~ s/^["'\[\(*]//;
    }
    # split title into first word + rest on space, apostrophe or hyphen
    $title =~ /^([^ '\-]+)([ '\-])(.*)/i;
    my $firstword=$1, my $separator=$2; my $etc=$3;
    #get length of first word plus the number of chars removed above plus one for the separator
    my $nonfilingchars = length($firstword) + $char1_notalphanum + 1;
    
    my $isan_exception =0;
    #check to see if first word is an exception
    $isan_exception = grep {$title =~ /^\Q$_\E/i} (keys %exceptions);

    #lowercase chars of $firstword for comparison with article list
    $firstword = lc($firstword);

    my $isan_article = 0;

    #see if first word is in the list of articles and not an exception
    $isan_article = 1 if (($article{$firstword}) && !($isan_exception));

    #if article then $nonfilingchars should match $ind2
    if ($isan_article) {
        #account for quotes or apostrophes before 2nd word (only checks for 1)
        if (($separator eq ' ') && ($etc =~ /^['"]/)) {
            $nonfilingchars++;
        }
        #special case for 'en'
        if ($firstword eq 'en') {
            $self->warn ( "245: First word, $firstword may be an article, check indicator 2 ($ind2).") unless (($ind2 eq 3) || ($ind2 eq 0));
        }
        elsif ($nonfilingchars != $ind2) {
            $self->warn ( "245: First word, $firstword may be an article, check indicator 2 ($ind2).");
        } #unless ind2 is same as length of first word and nonfiling characters
    } #if first word is in article list
    #not an article so warn if $ind2 is not 0
    else {
        unless ($ind2 eq 0) {
            $self->warn ( "245: First word, $firstword does not appear to be an article, check indicator 2, ($ind2).");
        } #unless ind2 is 0
    } #else not in article list

#######################################

} # check_245

=cut

#########################################
#########################################

sub check_246 {

    my $self = shift;
    my $field = shift;

    # break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while
        
    #subfield a should be 1st or 2nd subfield
    if (($newsubfields[0] ne 'a') && ($newsubfields[2] ne 'a')){
        $self->warn ( "246: Subfield _a must be 1st or 2nd subfield.");
    }

    #subfield i, if present should be 1st subfield and should end with : (no-space-colon)
    if ($field->subfield('i')){ 
        if ($newsubfields[0] ne 'i') {
            $self->warn ( "246: Subfield _i, when present must be 1st subfield.");
        } #if 1st subfield not 'i'
        elsif ($newsubfields[1] !~ /\S:$/) {
            $self->warn ( "246: Subfield _i should end with : (no-space-colon), $newsubfields[1].");
        } #elsif subfield 'i' does not end with : (no-space-colon)
    } #if subfield 'i'

    #each subfield b, if present, should be preceded by :;= (colon, semicolon, or equals sign)
    ### Are there others? ###
    if ($field->subfield("b")) {

        # 246 subfield b should be preceded by space-:;= (colon, semicolon, or equals sign)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#report error if subfield 'b' is not preceded by space-:;= (colon, semicolon, or equals sign)
            if (($newsubfields[$index] eq 'b') && ($newsubfields[$index-1] !~ / [:;=]$/)) {
                $self->warn ( "246: Subfield _b should be preceded by space-colon, space-semicolon, or space-equals sign.");
            } #if
        } #for
    } # subfield b exists

    #each subfield n, if present, must be preceded by . (period)
    if ($field->subfield("n")) {
        # 246 subfield n must be preceded by . (period)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
            #report error if subfield 'n' is not preceded by non-space-period or dash-space-period
            if (($newsubfields[$index] eq 'n') && ($newsubfields[$index-1] !~ /(\S\.$)|(\-\- \.$)/)) {
                $self->warn ( "246: Subfield _n must be preceded by . (period).");
            } #if
        } #for
    } # subfield n exists

    #each subfield p, if present, must be preceded by a , (no-space-comma) if it follows subfield n, or by . (no-space-period or dash-space-period) following other subfields
    if ($field->subfield("p")) {

        # 246 subfield p must be preceded by . (period) or , (comma)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield p
            if ($newsubfields[$index] eq 'p') {
# case for subfield 'n' being field before this one (allows dash-space-comma)
                if (($newsubfields[$index-2] eq 'n') && ($newsubfields[$index-1] !~ /(\S,$)|(\-\- ,$)/)) {
                    $self->warn ( "246: Subfield _p must be preceded by , (comma) when it follows subfield _n.");
                } #if subfield n precedes this one
                # elsif case for subfield before this one is not n
                elsif (($newsubfields[$index-2] ne 'n') && ($newsubfields[$index-1] !~ /(\S\.$)|(\-\- \.$)/)) {
                    $self->warn ( "246: Subfield _p must be preceded by . (period) when it follows a subfield other than _n.");
                } #elsif subfield p preceded by non-period when following a non-subfield 'n'
            } #if index is looking at subfield p
        } #for
    } # subfield p exists

} # check_246

#########################################
#########################################

sub check_250 {

    my $self = shift;
    my $field = shift;
    
    my @subfields = $field->subfields();
    my @newsubfields = ();
    my $has_sub_6 = 0;
    #break subfields into code-data array (so the entire field is in one array)
    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        #check for subfield 6 being present
        $has_sub_6 = 1 if ($code eq '6');
        unshift (@newsubfields, $code, $data);
    } # while
        
    # 250 must end in period (may want to make this less restrictive by allowing trailing spaces)
    if ($newsubfields[$#newsubfields] !~ /\.$/) {
        $self->warn ( "250: Must end with . (period)");
    }

    #subfield a should be first subfield (or 2nd if subfield '6' is present)
    if ($has_sub_6) {
        #make sure there are at least 2 subfields
        if ($#newsubfields < 3) {
            $self->warn ("250: May have too few subfields.");
        } #if fewer than 2 subfields
        else {
            if ($newsubfields[0] ne '6') {
                $self->warn ( "250: First subfield must be _6, but it is _$newsubfields[0]");
            } #if 1st subfield not '6'
            if ($newsubfields[2] ne 'a') {
                $self->warn ( "250: First subfield after subfield _6 must be _a, but it is _$newsubfields[2]");
            } #if 2nd subfield not 'a'
        } #else at least 2 subfields
    } #if has subfield 6
    else {
        #1st subfield must be 'a'
        if ($newsubfields[0] ne 'a') {
            $self->warn ( "250: First subfield must be _a, but it  is _$newsubfields[0]");
        } #if 2nd subfield not 'a'
    } #else no subfield _6
     
} # check_250

#########################################
#########################################

sub check_260 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();
    my $has_sub_6 = 0;

    #report error if at least one subfield a and subfield b are not found
    $self->warn ( "260: Subfield _a must be present.") unless $field->subfield('a');
    $self->warn ( "260: Subfield _b must be present.") unless $field->subfield('b');

    #break subfields into code-data array (so the entire field is in one array)
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            #check for subfield 6 being present
            $has_sub_6 = 1 if ($code eq '6');
            unshift (@newsubfields, $code, $data);
        } # while

    # 260 must end in period, closing bracket, closing parens, closing angle bracket, or hypen
    ##are there others? Pattern: /[.\]\)\-\>]$/
    if ($newsubfields[$#newsubfields] !~ /[.\]\)\-\>]$/) {
        $self->warn ( "260: Check ending punctuation, $newsubfields[$#newsubfields]");
    }

    #subfield a should be first subfield (or 2nd if subfield '6' is present)
    if ($has_sub_6) {
        #make sure there are at least 2 subfields
        if ($#newsubfields < 3) {
            $self->warn ("$tagno: May have too few subfields.");
        } #if fewer than 2 subfields
        else {
            if ($newsubfields[0] ne '6') {
                $self->warn ( "$tagno: First subfield must be _6, but it is $newsubfields[0]");
            } #if 1st subfield not '6'
            if ($newsubfields[2] ne 'a') {
                $self->warn ( "$tagno: First subfield after subfield _6 must be _a, but it is _$newsubfields[2]");
            } #if 2nd subfield not 'a'
        } #else at least 2 subfields
    } #if has subfield 6
    else {
        #1st subfield must be 'a'
        if ($newsubfields[0] ne 'a') {
            $self->warn ( "$tagno: First subfield must be _a, but it is _$newsubfields[0]");
        } #if 2nd subfield not 'a'
    } #else no subfield _6
    ##End check for first subfield

    #field 260 should have at least subfield a and subfield b, and, unless it is a continuing resource, subfield c. Warn if only subfield a is present and stop looking for other problems

    # subfield count is 1 or 0 so report problem (e.g. 250 coded 260)
    if ($#newsubfields <=1) {$self->warn ( "260: Must contain more than one subfield.");}
    else {
        # look for incorrect punctuation
        # start at second subfield pair, since first should be subfield a
        ### known potential problem: if subfield is empty, array indexing may (possibly) be thrown off--check to see if this is the case
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
            #second and subsequent subfield a, if present, must be preceded by ; (space-semicolon)
            if (($newsubfields[$index] eq 'a') && ($newsubfields[$index-1] !~ /\s;$/)) {
                #warn unless this is 1st subfield a (preceded by subfield 6)
                $self->warn ( "260: Subfield _a must be preceded by ;") unless (($index-2 >= 0) && ($newsubfields[$index-2] eq '6'));
            } #if subfield a not preceded by ; (colon)

            #each subfield b, if present, must be preceded by : (space-colon)
            if (($newsubfields[$index] eq 'b') && ($newsubfields[$index-1] !~ /\s:$/)) {
                $self->warn ( "260: Subfield _b must be preceded by :");
            } #if subfield b not preceded by : (colon)

            #each subfield c, if present, must be preceded by , ([non-space]-comma)
            if (($newsubfields[$index] eq 'c') && ($newsubfields[$index-1] !~ /\S,$/)) {
                $self->warn ( "260: Subfield _c must be preceded by ,");
            } #if subfield c not preceded by comma
        } #for
    } #else (has more than 1 subfield)
} # check_260

#########################################
#########################################

sub check_300 {

    my $self = shift;
    my $field = shift;

    #break subfields into code-data array (so the entire field is in one array)
    my @subfields = $field->subfields();
    my @newsubfields = ();
    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while

    #field 300 should generally have at least 2 subfields, though there are likely ok exceptions. Stop looking for other problems if only one subfield exists (probably for PCIP, which often have only p. cm.

    # subfield count is 1 or 0 so skip to next field 
    if ($#newsubfields <=1) {
        return;
    } #if 0 or 1 subfield
    
    else {
        # look for incorrect punctuation
        # start at second subfield pair, since first should be subfield a
        ### potential problem: if subfield is empty, array indexing may (possibly) be thrown off--check to see if this is the case

        for (my $index = 2; $index <=$#newsubfields; $index+=2) {

            #subfield b, if present, must be preceded by : (space-colon)
            if (($newsubfields[$index] eq 'b') && ($newsubfields[$index-1] !~ /\s:$/)) {
                $self->warn ( "300: Subfield _b must be preceded by :");
            } #if subfield b not preceded by : (colon)

            #subfield c, if present, must be preceded by ; (space-semicolon)
            if (($newsubfields[$index] eq 'c') && ($newsubfields[$index-1] !~ /\s;$/)) {
                $self->warn ( "300: Subfield _c must be preceded by ;");
            } #if subfield c not preceded by comma

            #subfield e, if present, must be preceded by + (space-plus)
            if (($newsubfields[$index] eq 'e') && ($newsubfields[$index-1] !~ /\s\+$/)) {
                $self->warn ( "300: Subfield _e must be preceded by +");
            } #if subfield e not preceded by plus

        } #for
    } #else (has more than 1 subfield)
} # check_300

#########################################
#########################################

sub check_440 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag;

    # break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();
    my $has_sub_6 = 0;

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        #check for subfield 6 being present
        $has_sub_6 = 1 if ($code eq '6');
        unshift (@newsubfields, $code, $data);
    } # while
        
    #subfield a should be first subfield (or 2nd if subfield '6' is present)
    if ($has_sub_6) {
        #make sure there are at least 2 subfields
        if ($#newsubfields < 3) {
            $self->warn ("$tagno: May have too few subfields.");
        } #if fewer than 2 subfields
        else {
            if ($newsubfields[0] ne '6') {
                $self->warn ( "$tagno: First subfield must be _6, but it is $newsubfields[0]");
            } #if 1st subfield not '6'
            if ($newsubfields[2] ne 'a') {
                $self->warn ( "$tagno: First subfield after subfield _6 must be _a, but it is _$newsubfields[2]");
            } #if 2nd subfield not 'a'
        } #else at least 2 subfields
    } #if has subfield 6
    else {
        #1st subfield must be 'a'
        if ($newsubfields[0] ne 'a') {
            $self->warn ( "$tagno: First subfield must be _a, but it is _$newsubfields[0]");
        } #if 2nd subfield not 'a'
    } #else no subfield _6
    ##End check for first subfield

    #each subfield n, if present, must be preceded by . (period)
    if ($field->subfield("n")) {

        # 440 subfield n must be preceded by . (period)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
            #report error if subfield 'n' is not preceded by non-space-period or dash-space-period
            if (($newsubfields[$index] eq 'n') && ($newsubfields[$index-1] !~ /(\S\.$)|(\-\- \.$)/)) {
                $self->warn ( "440: Subfield _n must be preceded by . (period).");
            } #if
        } #for
    } # subfield n exists

    #each subfield p, if present, must be preceded by a , (no-space-comma) if it follows subfield n, or by . (no-space-period or dash-space-period) following other subfields
    if ($field->subfield("p")) {

        # 440 subfield p must be preceded by . (period) or , (comma)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield p
            if ($newsubfields[$index] eq 'p') {
# case for subfield 'n' being field before this one (allows dash-space-comma)
                if (($newsubfields[$index-2] eq 'n') && ($newsubfields[$index-1] !~ /(\S,$)|(\-\- ,$)/)) {
                    $self->warn ( "440: Subfield _p must be preceded by , (comma) when it follows subfield _n.");
                } #if subfield n precedes this one
                # elsif case for subfield before this one is not n
                elsif (($newsubfields[$index-2] ne 'n') && ($newsubfields[$index-1] !~ /(\S\.$)|(\-\- \.$)/)) {
                    $self->warn ( "440: Subfield _p must be preceded by . (period) when it follows a subfield other than _n.");
                } #elsif subfield p preceded by non-period when following a non-subfield 'n'
            } #if index is looking at subfield p
        } #for
    } # subfield p exists

    #each subfield x, if present, must be preceded by a , (no-space-comma)
    if ($field->subfield('x')) {
        # 440 subfield x must be preceded by , (comma)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield x
            if ($newsubfields[$index] eq 'x') {
                if ($newsubfields[$index-1] !~ /(\S,$)|(\-\- ,$)/) {
                    $self->warn ( "440: Subfield _x must be preceded by , (comma)");
                } #if subfield x not preceded by comma
            } #if this is subfield 'x'
        } #for
    } # subfield x exists

    #each subfield v, if present, must be preceded by a ; (space-semicolon)
    if ($field->subfield('v')) {
        # 440 subfield v must be preceded by ; (space semicolon)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield v
            if ($newsubfields[$index] eq 'v') {
                if ($newsubfields[$index-1] !~ /(\s;$)/) {
                    $self->warn ( "440: Subfield _v must be preceded by ; (space-semicolon)");
                } #if subfield v not preceded by comma
            } #if this is subfield 'v'
        } #for subfields
    } # subfield v exists

    ######################################
    #check for invalid 2nd indicator
    $self->MARC::Lint::_check_article($field);

} #check_440
#########################################
#########################################

sub check_490 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag;
    my $has_sub_6 = 0;

    # break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();

    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        #check for subfield 6 being present
        $has_sub_6 = 1 if ($code eq '6');
        unshift (@newsubfields, $code, $data);
    } # while
        
    #subfield a should be first subfield (or 2nd if subfield '6' is present)
    if ($has_sub_6) {
        #make sure there are at least 2 subfields
        if ($#newsubfields < 3) {
            $self->warn ("$tagno: May have too few subfields.");
        } #if fewer than 2 subfields
        else {
            if ($newsubfields[0] ne '6') {
                $self->warn ( "$tagno: First subfield must be _6, but it is $newsubfields[0]");
            } #if 1st subfield not '6'
            if ($newsubfields[2] ne 'a') {
                $self->warn ( "$tagno: First subfield after subfield _6 must be _a, but it is _$newsubfields[2]");
            } #if 2nd subfield not 'a'
        } #else at least 2 subfields
    } #if has subfield 6
    else {
        #1st subfield must be 'a'
        if ($newsubfields[0] ne 'a') {
            $self->warn ( "$tagno: First subfield must be _a, but it is _$newsubfields[0]");
        } #if 2nd subfield not 'a'
    } #else no subfield _6
    ##End check for first subfield

    #each subfield x, if present, must be preceded by a , (no-space-comma)
    if ($field->subfield('x')) {
        # 490 subfield x must be preceded by , (comma)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield x
            if ($newsubfields[$index] eq 'x') {
                if ($newsubfields[$index-1] !~ /(\S,$)|(\-\- ,$)/) {
                    $self->warn ( "490: Subfield _x must be preceded by , (comma)");
                } #if subfield x not preceded by comma
            } #if this is subfield 'x'
        } #for
    } # subfield x exists

    #each subfield v, if present, must be preceded by a ; (space-semicolon)
    if ($field->subfield('v')) {
        # 440 subfield v must be preceded by ; (space semicolon)
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield v
            if ($newsubfields[$index] eq 'v') {
                if ($newsubfields[$index-1] !~ /(\s;$)/) {
                    $self->warn ( "490: Subfield _v must be preceded by ; (space-semicolon)");
                } #if subfield v not preceded by comma
            } #if this is subfield 'v'
        } #for subfields
    } # subfield v exists

} #check_490
#########################################
#########################################

=head2 NAME

check_6xx -- collection of subroutines for checking trailing punctuation in 6xx fields.
Also checks for correct presence or absence of subfield _2 based on indicator2.

=cut

#########################################
#########################################

sub check_600 {

    my $self = shift;
    my $field = shift;

    my $tagno = $field->tag();


###local exception for ending punctuation
###add indicators and subfield 2 codes to include from punctuation checking
    #list of indicators ('7' covers only codes set by @thesauri_to_include)
    my %indicators_to_include = ('0' => 'lcsh', '1' => 'lcac', '7' => 'other'); #add 2, 3, 4, 5, 6 as needed
    #list of codes paired with non-zero
    my %thesauri_to_include = ('sears' => '1'); #add as desired: (, 'bisacsh' => '1')

    #flag to set
    my $ignore_heading_punctuation = 0;


    my $second_indicator = $field->indicator(2);

    #store subfield 2 if it exists
    my $sub_2 = '';
    if ($field->subfield('2')) {
        $sub_2 = $field->subfield('2');
    } #if subfield '2' exists

    unless (exists $indicators_to_include{$second_indicator}) {
        $ignore_heading_punctuation = 1;
    } #unless indicator is in list of indicators to check
    elsif ($second_indicator eq '7') {
        if ($sub_2 && !(exists $thesauri_to_include{$sub_2})) {
            $ignore_heading_punctuation = 1;
        } #unless heading is to be checked
	} #elsif 2nd indicator is 7

###


    my @subfields = $field->subfields();
    my @newsubfields = ();

    #break subfields into code-data array (so the entire field is in one array)
    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while
        
#if last subfield is 2, then punctuation checks should apply to preceding subfield.
    unless ($newsubfields[$#newsubfields-1] eq '2') {

# 6xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.") unless $ignore_heading_punctuation;
        } #if proper punctuation not found

# 6xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.") unless $ignore_heading_punctuation;
        } #if ends in parens-period
    } #unless last is subfield _2

#if last is subfield _2 (and field has at least 2 subfields)
    elsif (($newsubfields[$#newsubfields-1] eq '2') && ($#newsubfields >=3)) {
# 6xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields-2] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.") unless $ignore_heading_punctuation;
        } #if proper punctuation not found

# 6xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields-2] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.") unless $ignore_heading_punctuation;
        } #if 2nd to last ends in parens-period
    } #elsif last is subfield _2 (and field has at least 2 subfields)
#warn if subfield _2 exists but field has fewer than 2 subfields
    elsif (($newsubfields[$#newsubfields-1] eq '2') && ($#newsubfields < 3)) {
        $self->warn ($tagno, ": May have too few subfields.");
    } #elsif subfield 2 is only subfield

#checks for indicator2 being 7 or not, vs. presence/absence of subfield _2
    if (($field->indicator(2) eq 7) && !($sub_2)) {
        $self->warn ($tagno, ": Second indicator is coded 7 but subfield _2 is not present.");
    } #elsif 2nd ind. '7' and subfield '2' does not exist
    elsif (($field->indicator(2) ne 7) && ($sub_2)) {
        $self->warn ($tagno, ": Second indicator is not coded 7 but subfield _2 is present");
    } #elsif 2nd ind. not '7' and subfield '2' exists 
    elsif (($field->indicator(2) eq 7) && ($sub_2)) {
        #report error unless subfield 2 code matches a valid MARC code for sources
        #account for slashes indicating edition and language of source
        my ($sub_2_cleaned) =  split /\//, $sub_2;
        $self->warn ($tagno, ": Check subfield 2 code (", $sub_2, ").") unless (exists $Sources600_651{$sub_2_cleaned});

    } #elsif 2nd ind. '7' and subfield '2' exists

    #################################################
    #check for proper punctuation before subfield _l#
    #################################################
    ###duplicates code in check_130 and check_240 ###
        #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists



} # check_600

#########################################
#########################################

sub check_610 {

    my $self = shift;
    my $field = shift;
    
    #same punctuation rules as check_600, so call that instead of repeating
    check_600($self, $field);

} # check_610

#########################################
#########################################

sub check_611 {

    my $self = shift;
    my $field = shift;

    #same punctuation rules as check_600, so call that instead of repeating
    check_600($self, $field);

} # check_611

#########################################
#########################################

sub check_630 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();


    #check indicator--should always be 0
    my $ind1 = $field->indicator(1);
    unless ($ind1 eq '0') {
        $self->warn ($tagno, ": First indicator should be 0, check for article.");
    } #unless 1st indicator is 0

    ######################################
    #double-check for article vs. indicator
    $self->MARC::Lint::_check_article($field);


    #same punctuation rules as check_600, so call that instead of repeating
    check_600($self, $field);

} # check_630

#########################################
#########################################

sub check_650 {

    my $self = shift;
    my $field = shift;

    #same punctuation rules as check_600, so call that instead of repeating
    check_600($self, $field);

} # check_650

#########################################
#########################################

sub check_651 {

    my $self = shift;
    my $field = shift;
    
        #same punctuation rules as check_600, so call that instead of repeating
    check_600($self, $field);

} # check_651

#########################################
#########################################

sub check_655 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #similar punctuation rules as check_600, but subfield 2 codes differ
    #repeating code from check_600 until workaround is found

###local exception for ending punctuation
###add indicators and subfield 2 codes to include from punctuation checking
    #list of indicators ('7' covers only codes set by @thesauri_to_include)
    my %indicators_to_include = ('0' => 'lcsh', '1' => 'lcac', '7' => 'other'); #add 2, 3, 4, 5, 6 as needed
    #list of codes paired with non-zero
    my %thesauri_to_include = ('sears' => '1'); #add as desired: (, 'bisacsh' => '1')

    #flag to set
    my $ignore_heading_punctuation = 0;


    my $second_indicator = $field->indicator(2);

    #store subfield 2 if it exists
    my $sub_2 = '';
    if ($field->subfield('2')) {
        $sub_2 = $field->subfield('2');
    } #if subfield '2' exists

    unless (exists $indicators_to_include{$second_indicator}) {
        $ignore_heading_punctuation = 1;
    } #unless indicator is in list of indicators to check
    elsif ($second_indicator eq '7') {
        if ($sub_2 && !(exists $thesauri_to_include{$sub_2})) {
            $ignore_heading_punctuation = 1;
        } #unless heading is to be checked
	} #elsif 2nd indicator is 7

###




    my @subfields = $field->subfields();
    my @newsubfields = ();

    #break subfields into code-data array (so the entire field is in one array)
    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while
        
#if last subfield is 2, then punctuation checks should apply to preceding subfield.
    unless ($newsubfields[$#newsubfields-1] eq '2') {

# 6xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.") unless $ignore_heading_punctuation;
        } #if proper punctuation not found

# 6xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.") unless $ignore_heading_punctuation;
        } #if parens-period found
    } #unless last is subfield _2

#if last is subfield _2 (and field has at least 2 subfields)
    elsif (($newsubfields[$#newsubfields-1] eq '2') && ($#newsubfields >=3)) {
# 6xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields-2] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.") unless $ignore_heading_punctuation;
        } #if proper punctuation not found

# 6xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields-2] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.") unless $ignore_heading_punctuation;
        } #if 2nd to last ends with parens-period
    } #elsif last is subfield _2 (and field has at least 2 subfields)
#warn if subfield _2 exists but field has fewer than 2 subfields
    elsif (($newsubfields[$#newsubfields-1] eq '2') && ($#newsubfields < 3)) {
        $self->warn ($tagno, ": May have too few subfields.") unless $ignore_heading_punctuation;
    } #elsif last subfield is '2' but it is the only subfield present


#checks for indicator2 being 7 or not, vs. presence/absence of subfield _2
    if (($field->indicator(2) eq 7) && !($sub_2)) {
        $self->warn ($tagno, ": Second indicator is coded 7 but subfield _2 is not present.");
    } #if 2nd ind '7' and subfield '2' is not present
    elsif (($field->indicator(2) ne 7) && ($sub_2)) {
        $self->warn ($tagno, ": Second indicator is not coded 7 but subfield _2 is present");
    } #elsif 2nd ind is not '7' and subfield '2' is present
    elsif (($field->indicator(2) eq 7) && ($sub_2)) {
        #report error unless subfield 2 code matches a valid MARC code for sources
        #account for slashes indicating edition and language of source
        my ($sub_2_cleaned) =  split /\//, $sub_2;
        $self->warn ($tagno, ": Check subfield 2 code (", $sub_2, ").") unless ($Sources655{$sub_2_cleaned});

    } #elsif 2nd ind '7' and subfield '2' is present



} # check_655

#########################################
#########################################

=head2 NAME

check_7xx subroutines

=head2 DESCRIPTION

Set of checks for trailing punctuation for 700, 710, 711, 730, and 740 fields.

=head2 TO DO (check_7xx)

Account for other numerical subfields (which may have special punctuation needs).

Verify rules for ending punctuation.

=cut

#########################################
#########################################

sub check_700 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #check indicator--should not be '3' (family name)?
    my $ind1 = $field->indicator(1);
    if ($ind1 eq '3') {
        $self->warn ($tagno, ": First indicator should be 0 or 1, not 3.");
    } # if 1st indicator is 3

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

    #################################################
    #check for proper punctuation before subfield _l#
    #################################################
    ###duplicates code in check_130, check_240, and check_630 ###
        #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists



} # check_700

#########################################
#########################################

sub check_710 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

    #################################################
    #check for proper punctuation before subfield _l#
    #################################################
    ###duplicates code in check_130, check_240, check_630, and other check_7xx ###
        #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists



} # check_710

#########################################
#########################################

sub check_711 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

    #################################################
    #check for proper punctuation before subfield _l#
    #################################################
    ###duplicates code in check_130, check_240, check_630, and other check_7xx ###
        #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists



} # check_711

#########################################
#########################################

sub check_730 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    ###testing
    #same punctuation as 130, so call that instead of repeating
    check_130($self, $field);
    ###/testing

=head2 CUT AS DUPLICATE???

    #check 1st indicator--should always be 0 
    #Some libraries may have non-zero 1st indicator
    my $ind1 = $field->indicator(1);
    unless ($ind1 eq '0') {
        $self->warn ($tagno, ": First indicator should be 0, check for article.");
    } #unless 1st indicator is 0
    ######################################
    #double-check for article vs. indicator
    $self->MARC::Lint::_check_article($field);

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

=cut

} # check_730

#########################################
#########################################

sub check_740 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #check 1st indicator--should always be 0
    ##Some libraries may have non-zero 1st indicator
    my $ind1 = $field->indicator(1);
    unless ($ind1 eq '0') {
        $self->warn ($tagno, ": First indicator should be 0, check for article.");
    } #unless 1st indicator is 0

    #same punctuation rules as check_100, so call that instead of repeating
    check_100($self, $field);

} # check_740

#########################################
#########################################

=head2 NAME

check_8xx subroutines

=head2 DESCRIPTION

Set of checks for trailing punctuation for 800, 810, 811, and 830 fields.

=head2 TO DO (check_8xx)

Account for numerical subfields (which may have special punctuation needs).

=cut

#########################################
#########################################

sub check_800 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    my @subfields = $field->subfields();
    my @newsubfields = ();

    #break subfields into code-data array (so the entire field is in one array)
    while (my $subfield = pop(@subfields)) {
        my ($code, $data) = @$subfield;
        unshift (@newsubfields, $code, $data);
    } # while
        

# 8xx must end in proper punctuation (may want to make this less restrictive by allowing trailing spaces)
        if ($newsubfields[$#newsubfields] !~ /[\!\?\-\'\"\)\.]$/) {
            $self->warn ($tagno, ": Check ending punctuation.");
        }

# 8xx should not end with closing parens-period
        if ($newsubfields[$#newsubfields] =~ /\)\.$/) {
            $self->warn ($tagno, ": Should not end with closing parens-period.");
        }

    #################################################
    #check for proper punctuation before subfield _l#
    #################################################
    ###duplicates code in check_130, check_240, check_630, and check_7xx ###
        #each subfield l, if present, must be preceded by a ., ?, or ! (no-space-period, question mark, or exclamation point)
    if ($field->subfield('l')) {
        my @subfields = $field->subfields();
        my @newsubfields = ();
        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        for (my $index = 2; $index <=$#newsubfields; $index+=2) {
#only looking for subfield l
            if ($newsubfields[$index] eq 'l') {
                if ($newsubfields[$index-1] !~ /(\S[\.\?\!]$)|(\-\- [\.\?\!]$)/) {
                    $self->warn ( $tagno, ": Subfield _l must be preceded by . (or ? or !) (no-space-period, question mark, or exclamation point)");
                } #if subfield l not preceded by period
            } #if this is subfield 'l'
        } #for subfields
    } # subfield l exists



} # check_800

#########################################
#########################################

sub check_810 {

    my $self = shift;
    my $field = shift;

    #same punctuation rules as check_800, so call that instead of repeating
    check_800($self, $field);

} # check_810

#########################################
#########################################

sub check_811 {

    my $self = shift;
    my $field = shift;

    #same punctuation rules as check_800, so call that instead of repeating
    check_800($self, $field);

} # check_811

#########################################
#########################################

sub check_830 {

    my $self = shift;
    my $field = shift;
    my $tagno = $field->tag();

    #check 2nd indicator--should always be 0
    my $ind2 = $field->indicator(2);
    unless ($ind2 eq '0') {
        $self->warn ($tagno, ": Second indicator should be 0, check for article.");
    } #unless 2nd indicator is 0
    ######################################
    #double-check for article vs. indicator
    $self->MARC::Lint::_check_article($field);

    #same punctuation rules as check_800, so call that instead of repeating
    check_800($self, $field);

} # check_830

#########################################
#########################################
#########################################
#########################################
############# Validate 007 ##############
#########################################
#########################################
#########################################
#########################################

=head2 validate007()

validate007() -- 007 value checking

=head2 Description

Reads passed string, which should contain data from an 007.
Validates each character of the string against MARC21 documentation.
Returns an arrayref containing an 007 within max length.
Any byte in that arrayref not having an allowed char has value 'bad'.
Also returns scalarref (which is defined) if 007 has characters other than spaces after the allowed length.  If the only problem is extra spaces, then the returned arrayref data can be used as new 007 data.

Currently (in this code), pipe chars are invalid everywhere, even though the MARC documentation allows them for any byte.

Reference to $visualizerec is either empty (if 007 is of ok length) or '007 has data after limit.'

Doesn't check for 007 that is too short.

Note: In this code, all 007 bytes below are allowed to have a blank space. This is not necessarily correct according to the documentation, but some systems (or editing software) allows it in place of the pipe to note no attempt to code.

=head2 TO DO (for validate007)

Figure out why the format arrays are declared initially, rather than
within the if/elsif statements, since they don't seem to be needed outside the
conditional scope.

Determine best way to deal with bad values.

Deal with variable length in electronic resources and motion pictures.
Electronic resources has a workaround, but motion pictures is not yet started (in terms of sublimit).

Check for short lengths?

 Rewrite for better efficiency.


=head2 Testing/synopsis

 use MARC::Lintadditions;

 my $badbytecount = 0;
 my $visualizecount = 0;
 my $currentfieldcount = 0;
 
 my @fields007 = ('aducznzn');
 #or my @fields007 = $record->field('007')->as_string(); #where $record is MARC::Record object with 007 fields
 foreach my $field007 (@fields007) {
    my @bytes = (split ('', $field007));
    $currentfieldcount++;
    #call validate007 sub in MARC::Lintadditions
    #The sub returns an arrayref and a scalarref
    my ($arrayref007, $hasextradataref)  = MARC::Lintadditions::validate007(\@bytes);

    #dereference the returned values
    my @cleaned007 = @$arrayref007;
    #loop through the array looking for bad bytes
    for (my $i = 0 ; $i <= $#cleaned007; $i++) {
        if ($cleaned007[$i] eq 'bad'){
            $badbytecount++;
        } #if bad byte
    } #for each byte

    #check for data after valid limit
    if ($$hasextradataref) {
        #add to count of records to manually examine
        $visualizecount++;
        #print record out here for further processing
    }

    print "Report for field $currentfieldcount of ", scalar @fields007, " total fields\n";
    print "$badbytecount bytes were bad\n$visualizecount fields have extra data after limit\n";

 } #foreach 007 field

=cut

##########################################
##########################################

sub validate007 {

############################
### Initialize variables ###
############################
    ##passed in arrayref, set it to $bytes##
    ### access array by @$bytesref ###
    my $bytesref = shift;
    my @bytes = @$bytesref;
    ## will define $limit for each format of 007
    my $limit;
    #the various formats
    my (@map007, @elecres007, @globe007, @tactmat007, @projgraph007, @microform007, @nonprojgraph007, @motionpict007, @kit007, @notatedmusic007, @remotesensimg007, @soundrec007, @text007, @vidrec007, @unspec007);
	#use @unknown if none of the above are found
    my @unknown = ();

    # return $visualizerec if 007 has data after $limit
    my $visualizerec = '';

#########################################
############ Start Maps 007 #############
#########################################
    if ($bytes[0]  =~ /^a$/) {
        $map007[0] = 'a'; 
        #print ("Map, 0-7\n");
        $limit = 8;
        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit)
{
            for (my $i = $limit; $i < scalar @bytes; $i++) {
                if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #else {print "length ok"}
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        #### validate values in each byte ###
        if ($bytes[1] =~ /^[ dgjkqrsuyz|]$/) 
            {$map007[1] = $bytes[1];} else {$map007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$map007[2] = $bytes[2];} else {$map007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ ac|]$/ )
            {$map007[3] = $bytes[3];} else {$map007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ abcdefgjpqrstuyz|]$/ )
            {$map007[4] = $bytes[4];} else {$map007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ fnuz|]$/ )
            {$map007[5] = $bytes[5];} else {$map007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ abcduz|]$/ )
            {$map007[6] = $bytes[6];} else {$map007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ abmn|]$/ )
            {$map007[7] = $bytes[7];} else {$map007[7] = "bad"}; 

###############################
#decide whether this should be here or in calling program
#if (my @grepmapbad = grep {$_ eq "bad"} @map007)
#{}
###############################

        return (\@map007, \$visualizerec)

####################################
    } # maps

#########################################
############ End Maps 007 ###############
#########################################
#########################################
### Start Electronic resource 007 #######
#########################################
    elsif ($bytes[0] eq 'c') {
        $elecres007[0] = 'c'; 
        #print ("Electronic resource, 0-13\n"); 
        $limit = 14;
        #bytes 6-13 are optional
        my $sublimit = 6; 

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            } #for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ abcfhjmoruz|]$/) 
            {$elecres007[1] = $bytes[1];} else {$elecres007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$elecres007[2] = $bytes[2];} else {$elecres007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ abcgmnuz|]$/ )
            {$elecres007[3] = $bytes[3];} else {$elecres007[3] = "bad"};
        if ($bytes[4] =~ /^[ aegijnouvz|]$/ )
            {$elecres007[4] = $bytes[4];} else {$elecres007[4] = "bad"};
        if ($bytes[5] =~ /^[ au|]$/ )
            {$elecres007[5] = $bytes[5];} else {$elecres007[5] = "bad"};

        #if @bytes is equal to or longer than minimum, 
        # but shorter than limit, then validate each
        if (($sublimit <= scalar @bytes) && (scalar @bytes < $limit)) {
            if ($bytes[6] && ($bytes[6] =~ /^[ \dmn\-|]$/ ))
                {$elecres007[6] = $bytes[6];} 
            elsif (! $bytes[6]) {#end of bytes
            } 
            else {$elecres007[6] = "bad";};
            if ($bytes[7] && ($bytes[7] =~ /^[ \dmn\-|]$/ ))
                {$elecres007[7] = $bytes[7];}
            elsif (! $bytes[7]) {#end of bytes
            }
            else {$elecres007[7] = "bad";};
            if ($bytes[8] && ($bytes[8] =~ /^[ \dmn\-|]$/ ))
                {$elecres007[8] = $bytes[8];} 
            elsif (! $bytes[8]) {#end of bytes
            }
            else {$elecres007[8] = "bad";};
            if ($bytes[9] && ($bytes[9] =~ /^[ amu|]$/ ))
                {$elecres007[9] = $bytes[9];}
            elsif (! $bytes[9]) {#end of bytes
            }
            else {$elecres007[9] = "bad";};
            if ($bytes[10] && ($bytes[10] =~ /^[ anpu|]$/ ))
                {$elecres007[10] = $bytes[10];}
            elsif (! $bytes[10]) {#end of bytes
            }
            else {$elecres007[10] = "bad";};
            if ($bytes[11] && ($bytes[11] =~ /^[ abcdmnu|]$/ ))
                {$elecres007[11] = $bytes[11];}
            elsif (! $bytes[11]) {#end of bytes
            } else {$elecres007[11] = "bad";};
            if ($bytes[12] && ($bytes[12] =~ /^[ abdmu|]$/ ))
                {$elecres007[12] = $bytes[12];}
            elsif (! $bytes[12]) {#end of bytes
            }
            else {$elecres007[12] = "bad";};
            if ($bytes[13] && ($bytes[13] =~ /^[ anpru|]$/ ))
                {$elecres007[13] = $bytes[13];}
            elsif (! $bytes[13]) {#end of bytes
            }
            else {$elecres007[13] = "bad";};
        } #if longer than min, shorter than limit
        elsif (scalar @bytes >= $limit) {
            if ($bytes[6] =~ /^[ \dmn\-|]$/ )
                {$elecres007[6] = $bytes[6];}
            else {$elecres007[6] = "bad";};
            if ($bytes[7] =~ /^[ \dmn\-|]$/ )
                {$elecres007[7] = $bytes[7];}
            else {$elecres007[7] = "bad";};
            if ($bytes[8] =~ /^[ \dmn\-|]$/ )
                {$elecres007[8] = $bytes[8];}
            else {$elecres007[8] = "bad";};
            if ($bytes[9] =~ /^[ amu|]$/ )
                {$elecres007[9] = $bytes[9];}
            else {$elecres007[9] = "bad";};
            if ($bytes[10] =~ /^[ anpu|]$/ )
                {$elecres007[10] = $bytes[10];}
            else {$elecres007[10] = "bad";};
            if ($bytes[11] =~ /^[ abcdmnu|]$/ )
                {$elecres007[11] = $bytes[11];}
            else {$elecres007[11] = "bad";};
            if ($bytes[12] =~ /^[ abdmu|]$/ )
                {$elecres007[12] = $bytes[12];}
            else {$elecres007[12] = "bad";};
            if ($bytes[13] =~ /^[ anpru|]$/ )
                {$elecres007[13] = $bytes[13];}
            else {$elecres007[13] = "bad";};
        } #else if length is ok or too long for full

###############################
#if (my @grepelecresbad = grep {$_ eq "bad"} @elecres007)
#{print "bad elecres007\n"}
###############################

        return (\@elecres007, \$visualizerec)

####################################
    } #electronic resource

########################################
### End Electronic resource 007 #######
########################################

##########################################
############ Start Globe 007 #############
##########################################

    elsif ($bytes[0] eq 'd') {
        $globe007[0] = 'd'; 
        #print ("Globe, 0-5\n"); 
        $limit = 6;

### See if length is ok, 
### and if length problem is due to extra data 
### or just spaces ###
        if (scalar @bytes > $limit){
            for (my $i = $limit; $i < scalar @bytes; $i++) {
                if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ abceuz|]$/) 
            {$globe007[1] = $bytes[1];} else {$globe007[1] = "bad"};
        if ($bytes[2] =~ /^[ ]$/)
            {$globe007[2] = $bytes[2];} else {$globe007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ ac|]$/)
            {$globe007[3] = $bytes[3];} else {$globe007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ abcdefgpuz|]$/)
            {$globe007[4] = $bytes[4];} else {$globe007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ fnuz|]$/)
            {$globe007[5] = $bytes[5];} else {$globe007[5] = "bad"}; 

###############################
#if (my @grepglobebad = grep {$_ eq "bad"} @globe007)
#{print "bad globe007\n"}
###############################

        return (\@globe007, \$visualizerec)

####################################
    } # Globe

##########################################
############ End Globe 007 #############
##########################################


############################################
######## Start Tactile material 007 ########
############################################
    elsif ($bytes[0] eq 'f') {
        $tactmat007[0] = 'f'; 
        #print ("Tactile material, 0-9\n"); 
        $limit = 10;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++) {
                if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ abcduz|]$/) 
            {$tactmat007[1] = $bytes[1];} else {$tactmat007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$tactmat007[2] = $bytes[2];} else {$tactmat007[2] = "bad"};
        if ($bytes[3] =~ /^[ abcdemnuz|]$/)
            {$tactmat007[3] = $bytes[3];} else {$tactmat007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ abcdemnuz|]$/)
            {$tactmat007[4] = $bytes[4];} else {$tactmat007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ abmnuz|]$/)
            {$tactmat007[5] = $bytes[5];} else {$tactmat007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ abcdefghijklnuz|]$/)
            {$tactmat007[6] = $bytes[6];} else {$tactmat007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ abcdefghijklnuz|]$/)
            {$tactmat007[7] = $bytes[7];} else {$tactmat007[7] = "bad"}; 
        if ($bytes[8] =~ /^[ abcdefghijklnuz|]$/)
            {$tactmat007[8] = $bytes[8];} else {$tactmat007[8] = "bad"}; 
        if ($bytes[9] =~ /^[ abnuz|]$/)
            {$tactmat007[9] = $bytes[9];} else {$tactmat007[9] = "bad"}; 
###############################
#if (my @greptactmatbad = grep {$_ eq "bad"} @tactmat007)
#{print "bad tactmat007\n"}
###############################

        return (\@tactmat007, \$visualizerec)

####################################
    }# tactile material
############################################
######## End Tactile material 007 ########
############################################


########################################
####### Start Projected graphic 007 ####
########################################
    elsif ($bytes[0] eq 'g') {
        $projgraph007[0] = 'g'; 
        #print ("Projected graphic, 0-8\n"); 
        $limit = 9;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ cdfostuz|]$/) 
            {$projgraph007[1] = $bytes[1];} else {$projgraph007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$projgraph007[2] = $bytes[2];} else {$projgraph007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ abchmnuz|]$/)
            {$projgraph007[3] = $bytes[3];} else {$projgraph007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ dejkmouz|]$/)
            {$projgraph007[4] = $bytes[4];} else {$projgraph007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ abu|]$/)
            {$projgraph007[5] = $bytes[5];} else {$projgraph007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ abcdefghiuz|]$/)
            {$projgraph007[6] = $bytes[6];} else {$projgraph007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ abcdefgjkstuvwxyz|]$/)
            {$projgraph007[7] = $bytes[7];} else {$projgraph007[7] = "bad"}; 
        if ($bytes[8] =~ /^[ cdehjkmuz|]$/)
            {$projgraph007[8] = $bytes[8];} else {$projgraph007[8] = "bad"}; 

###############################
#if (my @grepprojgraphbad = grep {$_ eq "bad"} @projgraph007)
#{print "bad projgraph007\n"}
###############################

        return (\@projgraph007, \$visualizerec)

####################################
    } # projected graphic
########################################
####### End Projected graphic 007 ####
########################################

#####################################
######## Start Microform 007 ########
#####################################
    elsif ($bytes[0] eq 'h') {
        $microform007[0] = 'h'; 
        $limit = 13;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ abcdefguz|]$/) 
            {$microform007[1] = $bytes[1];} else {$microform007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$microform007[2] = $bytes[2];} else {$microform007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ abmu|]$/)
            {$microform007[3] = $bytes[3];} else {$microform007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ adfghlmnopuz|]$/)
            {$microform007[4] = $bytes[4];} else {$microform007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ abcdeuv|]$/)
            {$microform007[5] = $bytes[5];} else {$microform007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ \d\-|]$/)
            {$microform007[6] = $bytes[6];} else {$microform007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ \d\-|]$/)
            {$microform007[7] = $bytes[7];} else {$microform007[7] = "bad"}; 
        if ($bytes[8] =~ /^[ \d\-|]$/)
            {$microform007[8] = $bytes[8];} else {$microform007[8] = "bad"}; 
        if ($bytes[9] =~ /^[ bcmuz|]$/)
            {$microform007[9] = $bytes[9];} else {$microform007[9] = "bad"}; 
        if ($bytes[10] =~ /^[ abcmnuz|]$/)
            {$microform007[10] = $bytes[10];} else {$microform007[10] = "bad"}; 
        if ($bytes[11] =~ /^[ abcmu|]$/)
            {$microform007[11] = $bytes[11];} else {$microform007[11] = "bad"}; 
        if ($bytes[12] =~ /^[ acdprtimnuz|]$/)
            {$microform007[12] = $bytes[12];} else {$microform007[12] = "bad"}; 
###############################
#if (my @grepmicroformbad = grep {$_ eq "bad"} @microform007)
#{print "bad microform007\n"}
###############################

        return (\@microform007, \$visualizerec)

####################################
    } # microform
#####################################
######## End Microform 007 ########
#####################################

########################################
#### Start Nonprojected graphic 007 ####
########################################
    elsif ($bytes[0] eq 'k') {
        $nonprojgraph007[0] = 'k'; 
        #print ("Nonprojected graphic, 0-5\n"); 
        $limit = 6;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ cdefghijlnouz|]$/) 
            {$nonprojgraph007[1] = $bytes[1];} else {$nonprojgraph007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$nonprojgraph007[2] = $bytes[2];} else {$nonprojgraph007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ abchmuz|]$/)
            {$nonprojgraph007[3] = $bytes[3];} else {$nonprojgraph007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ abcdefghmopqrstuz|]$/)
            {$nonprojgraph007[4] = $bytes[4];} else {$nonprojgraph007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ abcdefghmopqrstuz|]$/)
            {$nonprojgraph007[5] = $bytes[5];} else {$nonprojgraph007[5] = "bad"}; 

###############################
#if (my @grepnonprojgraphbad = grep {$_ eq "bad"} @nonprojgraph007)
#{print "bad nonprojgraph007\n"}
###############################

        return (\@nonprojgraph007, \$visualizerec)

####################################
    } # nonprojected graphic

#######################################
#### End Nonprojected graphic 007 ####
#######################################


####################################
##### Start Motion picture 007 #####
####################################
    elsif ($bytes[0] eq 'm') {
        $motionpict007[0] = 'm'; 
        #print ("Motion picture, 0-22\n"); 
        $limit = 23;
        #my sublimit = ## # bytes after ## are optional;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++) {
                if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
                else {print "space after limit\n";}
            } #for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ cfruz|]$/) 
            {$motionpict007[1] = $bytes[1];} else {$motionpict007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$motionpict007[2] = $bytes[2];} else {$motionpict007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ bchmnuz|]$/)
            {$motionpict007[3] = $bytes[3];} else {$motionpict007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ abcdefuz|]$/)
            {$motionpict007[4] = $bytes[4];} else {$motionpict007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ abu|]$/)
            {$motionpict007[5] = $bytes[5];} else {$motionpict007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ abcdefghiuz|]$/)
            {$motionpict007[6] = $bytes[6];} else {$motionpict007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ abcdefguz|]$/)
            {$motionpict007[7] = $bytes[7];} else {$motionpict007[7] = "bad"}; 
        if ($bytes[8] =~ /^[ kmnqsuz|]$/)
            {$motionpict007[8] = $bytes[8];} else {$motionpict007[8] = "bad"}; 
        if ($bytes[9] =~ /^[ abcdefgnz|]$/)
            {$motionpict007[9] = $bytes[9];} else {$motionpict007[9] = "bad"}; 
        if ($bytes[10] =~ /^[ abnuz|]$/)
            {$motionpict007[10] = $bytes[10];} else {$motionpict007[10] = "bad"}; 
        if ($bytes[11] =~ /^[ deoruz|]$/)
            {$motionpict007[11] = $bytes[11];} else {$motionpict007[11] = "bad"}; 
        if ($bytes[12] =~ /^[ acdprtimnuz|]$/)
            {$motionpict007[12] = $bytes[12];} else {$motionpict007[12] = "bad"}; 
        if ($bytes[13] =~ /^[ abcdefghijklmnpqrstuvz|]$/)
            {$motionpict007[13] = $bytes[13];} else {$motionpict007[13] = "bad"}; 
        if ($bytes[14] =~ /^[ abcdnuz|]$/)
            {$motionpict007[14] = $bytes[14];} else {$motionpict007[14] = "bad"}; 
        if ($bytes[15] =~ /^[ abcdefghklm|]$/)
            {$motionpict007[15] = $bytes[15];} else {$motionpict007[15] = "bad"}; 
        if ($bytes[16] =~ /^[ cinu|]$/)
            {$motionpict007[16] = $bytes[16];} else {$motionpict007[16] = "bad"}; 
        if ($bytes[17] =~ /^[ \d\-|]$/)
            {$motionpict007[17] = $bytes[17];} else {$motionpict007[17] = "bad"}; 
        if ($bytes[18] =~ /^[ \d\-|]$/)
            {$motionpict007[18] = $bytes[18];} else {$motionpict007[18] = "bad"}; 
        if ($bytes[19] =~ /^[ \d\-|]$/)
            {$motionpict007[19] = $bytes[19];} else {$motionpict007[19] = "bad"}; 
        if ($bytes[20] =~ /^[ \d\-|]$/)
            {$motionpict007[20] = $bytes[20];} else {$motionpict007[20] = "bad"}; 
        if ($bytes[21] =~ /^[ \d\-|]$/)
            {$motionpict007[21] = $bytes[21];} else {$motionpict007[21] = "bad"}; 
        if ($bytes[22] =~ /^[ \d\-|]$/)
            {$motionpict007[22] = $bytes[22];} else {$motionpict007[22] = "bad"}; 

###############################
#if (my @grepmapbad = grep {$_ eq "bad"} @motionpict007)
#{print "bad motionpict007\n"}
###############################

        return (\@motionpict007, \$visualizerec)

####################################
    }# motion pictures
####################################
##### End Motion picture 007 #####
####################################

########################################
############ Start Kit 007 #############
########################################
    elsif ($bytes[0] eq 'o') {
        $kit007[0] = 'o'; 
        #print ("Kit, 0-1\n"); 
        $limit = 2;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++) {
                if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ u|]$/) 
            {$kit007[1] = $bytes[1];} else {$kit007[1] = "bad"}; 
###############################
#if (my @grepmapbad = grep {$_ eq "bad"} @kit007)
#{print "bad kit007\n"}
###############################

        return (\@kit007, \$visualizerec)

####################################
    } #kit

########################################
############ End Kit 007 #############
########################################

#####################################
###### Start Notated music 007 ######
#####################################
    elsif ($bytes[0] eq 'q') {
        $notatedmusic007[0] = 'q'; 
        #print ("Notated music, 0-1\n"); 
        $limit = 2;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ u|]$/) 
            {$notatedmusic007[1] = $bytes[1];} else {$notatedmusic007[1] = "bad"}; 
###############################
#if (my @grepnotatedmusicbad = grep {$_ eq "bad"} @notatedmusic007)
#{print "bad notatedmusic007\n"}
###############################

        return (\@notatedmusic007, \$visualizerec)

####################################
} # notated music

#####################################
###### End Notated music 007 ######
#####################################

######################################
### Start Remote-sensing image 007 ###
######################################
        elsif ($bytes[0] eq 'r') {
            $remotesensimg007[0] = 'r'; 
            #print ("Remote-sensing image, 0-10\n"); 
            $limit = 11;

            ### See if length is ok, 
            ### and if length problem is due to extra data 
            ### or just spaces ###
            if (scalar @bytes > $limit) {
                for (my $i = $limit; $i < scalar @bytes; $i++)  
                    {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
                }#for bytes after limit
            }#if length too long
            #### validate values in each byte ###
            #turn off uninitialized warnings
            no warnings 'uninitialized';
            if ($bytes[1] =~ /^[ u|]$/) 
                {$remotesensimg007[1] = $bytes[1];} else {$remotesensimg007[1] = "bad"}; 
            if ($bytes[2] =~ /^[ ]$/)
                {$remotesensimg007[2] = $bytes[2];} else {$remotesensimg007[2] = "bad"}; 
            if ($bytes[3] =~ /^[ abcnuz|]$/)
                {$remotesensimg007[3] = $bytes[3];} else {$remotesensimg007[3] = "bad"}; 
            if ($bytes[4] =~ /^[ abcnu|]$/)
                {$remotesensimg007[4] = $bytes[4];} else {$remotesensimg007[4] = "bad"}; 
            if ($bytes[5] =~ /^[ \dnu|]$/)
                {$remotesensimg007[5] = $bytes[5];} else {$remotesensimg007[5] = "bad"}; 
            if ($bytes[6] =~ /^[ abcdefghinuz|]$/)
                {$remotesensimg007[6] = $bytes[6];} else {$remotesensimg007[6] = "bad"}; 
            if ($bytes[7] =~ /^[ abcmnuz|]$/)
                {$remotesensimg007[7] = $bytes[7];} else {$remotesensimg007[7] = "bad"}; 
            if ($bytes[8] =~ /^[ abuz|]$/)
                {$remotesensimg007[8] = $bytes[8];} else {$remotesensimg007[8] = "bad"}; 
            if ($bytes[9] =~ /^[ adgjmnprstuz|]$/)
                {$remotesensimg007[9] = $bytes[9];} else {$remotesensimg007[9] = "bad"}; 
            if ($bytes[10] =~ /^[ abcdefvzguzmn|]$/)
                {$remotesensimg007[10] = $bytes[10];} else {$remotesensimg007[10] = "bad"}; 

###############################
#if (my @grepremotesensimgbad = grep {$_ eq "bad"} @remotesensimg007)
#{print "bad remotesensimg007\n"}
###############################

        return (\@remotesensimg007, \$visualizerec)

####################################
    } # remote-sensing image
######################################
### End Remote-sensing image 007 ###
######################################


###########################################
######## Start Sound recording 007 ########
###########################################
    elsif ($bytes[0] eq 's') {
        $soundrec007[0] = 's'; 
        #print ("Sound recording, 0-13\n"); 
        $limit = 14;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ degiqstuwz|]$/) 
            {$soundrec007[1] = $bytes[1];} else {$soundrec007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$soundrec007[2] = $bytes[2];} else {$soundrec007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ abcdefhiklmopruz|]$/)
            {$soundrec007[3] = $bytes[3];} else {$soundrec007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ mqsuz|]$/)
            {$soundrec007[4] = $bytes[4];} else {$soundrec007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ mnsuz|]$/)
            {$soundrec007[5] = $bytes[5];} else {$soundrec007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ abcdefgjonsuz|]$/)
            {$soundrec007[6] = $bytes[6];} else {$soundrec007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ lmnopuz|]$/)
            {$soundrec007[7] = $bytes[7];} else {$soundrec007[7] = "bad"}; 
        if ($bytes[8] =~ /^[ abcdefnuz|]$/)
            {$soundrec007[8] = $bytes[8];} else {$soundrec007[8] = "bad"}; 
        if ($bytes[9] =~ /^[ abdimnrstuz|]$/)
            {$soundrec007[9] = $bytes[9];} else {$soundrec007[9] = "bad"}; 
        #Note, byte 10 of soundrec used to be 'n' for cassettes, now 'p' ##
        if ($bytes[10] =~ /^[ abcgilmprsuwz|]$/)
            {$soundrec007[10] = $bytes[10];} else {$soundrec007[10] = "bad"}; 
        if ($bytes[11] =~ /^[ hlnu|]$/)
            {$soundrec007[11] = $bytes[11];} else {$soundrec007[11] = "bad"}; 
        if ($bytes[12] =~ /^[ abcdefghnuz|]$/)
            {$soundrec007[12] = $bytes[12];} else {$soundrec007[12] = "bad"}; 
        if ($bytes[13] =~ /^[ abdeuz|]$/)
            {$soundrec007[13] = $bytes[13];} else {$soundrec007[13] = "bad"}; 

###############################
#if (my @grepsoundrecbad = grep {$_ eq "bad"} @soundrec007)
#{print "bad soundrec007\n"}
###############################

        return (\@soundrec007, \$visualizerec)

####################################
    } # sound recording
###########################################
######## End Sound recording 007 ########
###########################################


##########################################
############ Start Text 007 ##############
##########################################
    elsif ($bytes[0] eq 't') {
        $text007[0] = 't'; 
        #print ("Text, 0-1\n"); 
        $limit = 2;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ abcduz|]$/) 
            {$text007[1] = $bytes[1];} else {$text007[1] = "bad"}; 
###############################
#if (my @greptextbad = grep {$_ eq "bad"} @text007)
#{print "bad text007\n"}
###############################

        return (\@text007, \$visualizerec)

####################################
    } # text
##########################################
############ End Text 007 ##############
##########################################


#########################################
####### Start Videorecording 007 ########
#########################################
    elsif ($bytes[0] eq 'v') {
        $vidrec007[0] = 'v'; 
        #print ("Videorecording, 0-8\n"); 
        $limit = 9;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ cdfruz|]$/) 
            {$vidrec007[1] = $bytes[1];} else {$vidrec007[1] = "bad"}; 
        if ($bytes[2] =~ /^[ ]$/)
            {$vidrec007[2] = $bytes[2];} else {$vidrec007[2] = "bad"}; 
        if ($bytes[3] =~ /^[ abcmnuz|]$/)
            {$vidrec007[3] = $bytes[3];} else {$vidrec007[3] = "bad"}; 
        if ($bytes[4] =~ /^[ abcdefghijkmopqsuvz|]$/)
            {$vidrec007[4] = $bytes[4];} else {$vidrec007[4] = "bad"}; 
        if ($bytes[5] =~ /^[ abu|]$/)
            {$vidrec007[5] = $bytes[5];} else {$vidrec007[5] = "bad"}; 
        if ($bytes[6] =~ /^[ abcdefghiuz|]$/)
            {$vidrec007[6] = $bytes[6];} else {$vidrec007[6] = "bad"}; 
        if ($bytes[7] =~ /^[ amopqruz|]$/)
            {$vidrec007[7] = $bytes[7];} else {$vidrec007[7] = "bad"}; 
        if ($bytes[8] =~ /^[ kmnqsuz|]$/)
            {$vidrec007[8] = $bytes[8];} else {$vidrec007[8] = "bad"}; 

###############################
#if (my @grepvidrecbad = grep {$_ eq "bad"} @vidrec007)
#{print "bad vidrec007\n"}
###############################

        return (\@vidrec007, \$visualizerec)

####################################

    } # videorecording
########################################
####### End Videorecording 007 ########
########################################


######################################
####### Start Unspecified 007 ########
######################################
    elsif ($bytes[0] eq 'z') {
        $unspec007[0] = 'z';
        #print ("Unspecified, 0-1");
        $limit = 2;

        ### See if length is ok, 
        ### and if length problem is due to extra data 
        ### or just spaces ###
        if (scalar @bytes > $limit) {
            for (my $i = $limit; $i < scalar @bytes; $i++)  
                {if ($bytes[$i] !~ /^ $/) {$visualizerec = '007 has data after limit.';}
            }#for bytes after limit
        }#if length too long
        #### validate values in each byte ###
        #turn off uninitialized warnings
        no warnings 'uninitialized';
        if ($bytes[1] =~ /^[ muz|]$/) 
            {$unspec007[1] = $bytes[1];} else {$unspec007[1] = "bad"}; 
###############################
#if (my @grepunspecbad = grep {$_ eq "bad"} @007)
#{print "bad 007\n"}
###############################

        return (\@unspec007, \$visualizerec)

####################################
    } #unspecified

######################################
####### End Unspecified 007 ##########
######################################
    else {
        $visualizerec = "Byte 0 ($bytes[0]) represents an unknown format";
        return (\@unknown, \$visualizerec);
    }
######################################
######################################
######################################
######################################
######################################
######################################
######### End validate007 ############
######################################
} ### sub validate007 end

##########################
##########################
##########################
#########################################
#########################################
#########################################
#########################################
#########################################
#########################################
#########################################
#########################################
#########################################

#########################################
#########################################





1;

=head2 BASIC check_XXX code

sub check_XXX {

    my $self = shift;
    my $field = shift;

# break subfields into code-data array (so the entire field is in one array)

    my @subfields = $field->subfields();
    my @newsubfields = ();

        while (my $subfield = pop(@subfields)) {
            my ($code, $data) = @$subfield;
            unshift (@newsubfields, $code, $data);
        } # while
        
}

=head1 SEE ALSO

MARC::Record -- Required for this module to work.

MARC::Lint -- In the MARC::Record distribution and basis for this module.

MARC::Errorchecks -- Extension of MARC::Lint for checks involving cross-field checking
(vs. individual tags covered in this module).

MARC pages at the Library of Congress (http://www.loc.gov/marc)

Anglo-American Cataloging Rules, 2nd ed., 2002 revision, plus updates.

Library of Congress Rule Interpretations to AACR2R.

MARC Report (http://www.marcofquality.com) -- More full-featured commercial program for validating MARC records.

=head2 VERSION HISTORY


Version 1.15: Updated May 21, 2012. Released Aug. 6, 2012.

 -Updated check_082() for editions 23 and 15 of Dewey.
 -Updated check_6xx subs to ignore punctuation checking on all but certain headings (locally, ignores all but LCSH, LCAC, and Sears).

Version 1.14: Updated July 6, 2009. Released 2009.

 -Updated validate007( \@bytesfrom007 ) bytes to account for 007/04 (Videorecordings) value of 's' for Blu-ray, from MARC Update no. 9, Oct. 2008.
 -Updated validate007( \@bytesfrom007 ) bytes to allow pipe character (for No attempt to code). Previously, while this character was allowed by the MARC documentation, it was disallowed in Lintadditions due to local QBI practice (the character may be incompatible with old cataloging software).
 -Revised capitalization of Cutter.

Version 1.13: Updated Oct. 21, 2007. Released Oct. 21, 2007.

 -Updated check_100 (and by call, all check_1xx, check_7xx, and check_8xx):
 --Non-numeric reduced from non-digits to [0-5, 79], since 6 and 8 follow different rules.
 --Added check for punctuation preceding $e.
 -Updated check_260, check_440, and check_490 to deal with subfield 6 being 1st when checking for subfield a as first subfield.


Version 1.12: Updated Mar. 1-Aug 26, 2007. Released Oct. 3, 2007.

 -Updated check_042 with new code, ukblderived, from Technical Notice for Aug. 13, 2007.
 -Updated check_042 with new code, scipio, from Technical Notice for Mar. 1, 2007.
 -Updated check_xxx methods (check_250) to account for subfield '6' as 1st subfield.

Version 1.11: Updated June 12, 2006-Feb. 7, 2007. Released Feb. 25, 2007.

 -updated check_130(), check_6xx, and check_7xx to check for proper punctuation before subfield _l.
 -Updated check_240() to allow ? and ! before subfield _l, based on LCRI revision in 2006.
 -Updated check_050() to report error if subfield _a doesn't start with capital letters followed by digits.
 -Updated check_050() to report error if subfield _a ends in capital letter.
 -Replaced $field->tag() in warning statements with $tagno.
 -Revised $2 validation to split on '/', thus ignoring edition and language additions on valid codes
 -Updated check_440 to look for miscoded 2nd ind. using MARC::Lint::_check_article().
 -Updated 130, 240, 630, 730, and 830 checks to look for article, using MARC::Lint::_check_article().
 -Updated check_042() with source code from technical notice of Sept. 29, 2006.
 -Added TO DO item for determining whether check_130, 630, and 730 can use the same code.

Version 1.10: Updated Oct. 17, 2005-May 18, 2006. Released June 6, 2006.

 -Added check_024() for UPC and EAN validation.
 -check_042() updated with valid source codes from MARC list for sources.
 -check_050() updated to report Cutters not preceded by period.
 -Misc. bug fixes, including turning off uninitialized warnings for short 007 bytes.

Version 1.09: Updated Mar. 31-Apr., 2005. Released July 16, 2005.

 -check_260() updated to report error if subfield 'a' and 'b' are not present.
 -More '==' etc. changed to 'eq' etc. for indicators.
 -check_082() updated to set $dewey to empty string if no 082$a is present before checking for 3 digits.

Version 1.08: Updated Feb. 21-Feb. 27, 2005. Released Feb. 27, 2005.

 -Revision of check_020() in preparation for move to MARC::Lint.
 -Moved check_020() to MARC::Lint (remains here during testing).
 -validate007() revised to deal with possibility of subfields existing in pre-010 fields, or other non-legitimate 1st characters existing.


Version 1.07: Updated Jan. 2-Feb. 1, 2005. Released  Feb. 13, 2005.

 -Updated check_260 to account for angle brackets for open dates in subfield c.
 -Updated check_020 to handle 13-digit ISBNs. This relies upon the new internal _isbn13_check_digit($ean), temporary until Business::ISBN handles 13-digit ISBNs directly.
 -Added basic check to check_600 (and by call, other 6xx) for subfield 2 codes. Similar code duplicated in check_655, due to difference in code lists for each field. Still need to deal with obsolete code error reporting.
 -Moved check_245 to MARC::Lint (retained here as a POD section during testing).
 -Moved check_041 and check_043 to MARC::Lint (retained here as a POD section during testing).
 -Added warning to check_007 for obsolete byte 2.
 -Removed pod info related to changes needed to MARC::Lint (which has been updated).
 -Misc. cleanup.
 -Revised check_1xx, check_6xx, check_7xx, and check_8xx to use check_100, etc. (to avoid code duplication).
 (based on code from Ian Hamilton)

Version 1.06: Updated Nov. 21-24, 2004. Released Dec. 5, 2004.

 -Removed readcodedata(), replaced with separate data pack, MARC::Lint::CodeData
 -Updated check_040, check_041 and check_043 to use MARC::Lint::CodeData.
 -Deleted the DATA section based on the above changes.
 -Misc. bug fixes.
 -Reports 13 digit ISBNs as errors pending updating of Business::ISBN to account for 13 digit ISBNs.

Version 1.05: Updated Aug. 30-Oct. 16, 2004. Released Oct. 17, 2004.

 -Moved institution-specific code from check_040 to MARC::QBIerrorchecks.
 --check_040 still present to check $b language (currently commented-out)
 -Moved check_037 to MARC::QBIerrorchecks.
 -Updated check_082 to ensure decimal after 3rd digit in numbers longer than 3 digits.
 -Moved validate007(\@bytesfrom007) from MARC::BBMARC (to make MARC::Lintadditions more self-contained).
 -Fixed problem in 6xx check for subfield _2 (changed '==' to 'eq').
 -Updated validate007(\@bytesfrom007) (bug fixes, misc. revisions)
 -Updated check_050 to check for unfinished Cutters (single capital letter followed by space or nothing)

Version 1.04: Updated Aug. 10-22, 2004. Released Aug. 22, 2004. 

 -Implemented VERSION (uncommented)
 -Revised check_050 exception (Thank you to all who posted about this).
 -Moved VERSION HISTORY to end of module.
 -Added preliminary checking of 245 2nd indicator in check_245 (Thanks to Ian Hamilton).

Version 1.03: Updated July 20-Aug. 7, 2004. Released Aug. 8, 2004.

 -Added check_1xx and check_7xx sets.
 -Added checks for non-filing indicator in 130, 630, 730, 740 and 830.
 -Added indicator check for 700--ind1 == 3 -> error.
 -Added validation of 041 against MARC Code List for Languages.
 -Added check_028 and check_037.
 -Removed some variables from warning messages.
 -Added check_050.
 -Added check_040 (IOrQBI specific).
 -Added check_440 and check_490.
 -Added check_246.
 -Changed check_245 ending punctuation errors based on MARC21 rule change vs. LCRI 1.0C from Nov. 2003.
 -Added check for square brackets in 245 $h.
 -Added check for 260 ending punctuation.
 
Version 1.02: Updated July 2-17, 2004. Released July 18, 2004.

 -Cleaned up some of the documentation
 -Added global variable in hopes of improving efficiency of language/GAC/country code validation
 -Modified check_043 and/or C<readcodedata()> to use the new global variable.
 -Added check_6xx subroutines (600, 610, 611, 630, 650, 651, 655)
 -Added check for  space between initials in 245 $c in check_245
 -Added check_042 (valid values: lcac, lccopycat, pcc, nsdp)
 -Added check_020 (relies upon Business::ISBN module)
 -Added check_022 (relies upon Business::ISSN module)
  
Version 1.01: Updated June 17, 2004. Released June 20, 2004. 

 -Added validation of 043 against GAC list.
 -Added check_082.
 -Added checks for $b, $h, $n, and $p in 245.
 -Other changes/fixes.

Version 1.0 (unnumbered): Released May 31, 2004. Initial version.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that this code is not a product of or supported by the 
employers of the various contributors to the code.

=head1 AUTHOR

Bryan Baldus
eijabb@cpan.org

Copyright (c) 2004-2012.

=cut


__END__
