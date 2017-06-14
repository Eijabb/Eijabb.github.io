package MARC::PCIPmaker;

use strict;
use warnings;
use MARC::Record;
use Business::ISBN;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default.

@EXPORT = qw();

$VERSION = 1.02;

=head1 NAME

MARC::PCIPmaker -- Module for generating PCIP block, based on code from the Library of Congress.

=head2 DESCRIPTION

This module's main sub, makecard, is based on Visual Basic code from the Library of Congress, translatated into Perl. Some code from the original has been removed or modified according to QBI's needs. In translating, preference was given to following the original logic as much as possible, rather than using Perl- and MARC::Record-based logic and techniques (hence conversions between MARC::Record objects and raw MARC format, particularly for subfield manipulation).

The code is geared toward the needs of CIP-level records, but may have some general applicability for card/ISBD-format generation from full-MARC records, with minor modifications.


TO DO:

Current code works to create block similar to LC's, with minor modifications. Formatting (bold, fonts, markup) for printing is probably handled outside the makecard function, so that step has yet to be done. Also, the current version does not break lines at a certain length, so that remains to be done.

Intend to split lines at 70? characters, but need to take into account whole words and dangling numbers in subject heading/added entry block.


Future:

Generalize for non-CIP level items, to produce ISBD display. Current version will work with non-CIP-level.

Revise how roman numerals are generated, using some module (to be found).

Rework code to be more Perlish.



=head2 USEFUL ITEMS FOR CODING

Chr($):
29 => \x1D #end of record
30 => \x1E #end of field
31 => \x1F #subfield delimiter
32 => \x20 #space (blank)

#sub utlimisc.bas::Stuff ($text, $offset, $length, $replace)

%cipdata = (
	'mainentry' => 'As String',
	'Title' => 'As String',
	'edition' => 'As String',
	'phys' => 'As String',
	'pub' => 'As String',
	'callno' => 'As String',
	'nlmcallno' => 'As String',
	'dewey' => 'As String',
	'lccn' => 'As String',
	'isbn' => 'As String',
	'ppd' => 'As String',
	'ut' => 'As String',
	'series' => 'As String',
	'aes' => ['20', 'As String'],
	'tilaes' => ['10', 'As String'],
	'nlms' => ['20', 'As String'],
	'subjects' => ['20', 'As String'],
	'juvsubjects' => ['20', 'As String'],
	'seriestracings' => ['10', 'As String'],
	'catnotes' => ['30', 'As String'],
	'pubdata' => 'As String',
) #cipdata type

=head2 LC's RTF-related code

	#clear rtf text box
	rtf_data.Text = ''
	#load message and CIP data
	rtf_data.Text = $block
	#scroll to CIP data
	rtf_data.SelStart = Len(rtf_data.Text) # - 1
	#place cursor at bottom of RTF box
	#Me.Show
	#rtf_data.SetFocus

###############################

LC's e-mail contains the following preface:

"Please print the data on the copyright page of your publication exactly as provided, observing all capitalization, spacing, and punctuation, and maintaining the overall format and left margins.  Do not add the number of pages or the size of the book to the 'p. cm.' portion of the CIP record."


=head2 makecard ($raw_record, [$want_all_records])

Given a raw MARC record string, produces a CIP data block/card view of the record.

Optionally pass boolean indicating whether block is allowed for non-CIP-level records.

Returns a finished block and any errors found (in an array).

=head2 Variables may be used

my $pref = ''
my @constant = (); #with 8 positions used
my @roman = (); #with 10 positions used
my $MsgTxt = '';
#Dim $sResponse, $sMsg, $sStyle, $sTitle #message box stuff

=head2 SYNOPSIS

	#$PCIPrecord = $batch->next in while loop, as generally constructed for most other MARC reading Perl programs

	my $record_as_marc = $PCIPrecord->as_usmarc();
	my ($PCIPblock, @errorsinPCIP) = MARC::PCIPmaker::makecard($record_as_marc);

	if (@errorsinPCIP) {
		print "The following errors were found in generating the PCIP block\n", join "\n", @errorsinPCIP, "\n";
	}
	else {
		print OUT $PCIPblock;
	}

=cut

sub makecard {

	#On Error GoTo RecordProblem

	#retrieve passed MARC string
	my $raw_record = shift;
	
	#retrieve variable indicating whether only CIP-level records are allowed or not
	my $want_all_records = (shift || 0);
	#turn raw MARC string into MARC::Record object
	my $record = MARC::Record::new_from_usmarc($raw_record);

	#declare variables
	my @constant = (); #with 8 positions used
	my @roman = (); #with 10 positions used

	#declare variable for storing errors
	my @errorstoreturn = ();

	$constant[1] = '';
	$constant[2] = '';
	$constant[3] = '';
	$constant[4] = "Cover";
	$constant[5] = "Added t.p.";
	$constant[6] = "Caption";
	$constant[7] = "Running";
	$constant[8] = "Spine";
	$roman[1] = "I";
	$roman[2] = "II";
	$roman[3] = "III";
	$roman[4] = "IV";
	$roman[5] = "V";
	$roman[6] = "VI";
	$roman[7] = "VII";
	$roman[8] = "VIII";
	$roman[9] = "IX";
	$roman[10] = "X";
	#add more roman numerals here, if necessary
	$roman[11] = "XI";
	$roman[12] = "XII";
	$roman[13] = "XIII";
	$roman[14] = "XIV";
	$roman[15] = "XV";
	$roman[16] = "XVI";
	$roman[17] = "XVII";
	$roman[18] = "XVIII";
	$roman[19] = "XIX";
	$roman[20] = "XX";
	$roman[21] = "XXI";
	$roman[22] = "XXII";
	$roman[23] = "XXIII";
	$roman[24] = "XXIV";
	$roman[25] = "XXV";
	$roman[26] = "XXVI";
	$roman[27] = "XXVII";
	$roman[28] = "XXVIII";
	$roman[29] = "XXIX";
	$roman[30] = "XXX";
	$roman[31] = "XXXI";
	$roman[32] = "XXXII";
	$roman[33] = "XXXIII";
	$roman[34] = "XXXIV";
	$roman[35] = "XXXIV";
	$roman[36] = "XXXIV";
	$roman[37] = "XXXIV";
	$roman[38] = "XXXIV";
	
	my $thisemail = '';
	#my $month = '';
	my $msgtext;
	my %myECIP; #As cipdata;
	my $aeblock = ' '; #space #added entries
	my $subjblock = ''; #LCSH headings
	my $txt = ''; # As String;
	my $ISBN13 = 0; # As Boolean;

	my $juvblock = ' '; #space #juvenile headings
	my $nlmblock = ' '; #space #MeSH headings
	my $publccn = ''; #LCCN
	my $pubisbn = ''; #ISBN
	my $pubname = ''; #name (260b)
	my $pubdata = ''; #

#this doesn't seem to work, so converted to spaces within the code
#my $s2xChr32 = '  '; #double space

	my $romanized = 0; #false
#	my $a = 0;
#	my $s = 0;
#	my $e = 0;
#	my $j = 0;
#	my $m = 0;

	#predefine empty elements that may not have fields in record
	$myECIP{'edition'} = '';
	$myECIP{'series'} = '';
	$myECIP{'juvsubjects'} = [];
	$myECIP{'nlms'} = [];
	$myECIP{'aes'} = [];
	$myECIP{'tilaes'} = [];
	$myECIP{'seriestracings'} = [];
	$myECIP{'catnotes'} = [];
	
	##retrieve the leader
	my $leader = $record->leader();

	#check for pre-publication level in LDR/17
	unless (substr($leader, 17, 1) eq "8" ) {
		unless ($want_all_records) { 
			my $sMsg = "Record is not at prepublication level!";
			push @errorstoreturn, $sMsg;
			#exit sub
			return $txt, @errorstoreturn;
		} #unless want all records
	} #unless coded as CIP-level

	##for each of the fields in the record
	my @fields = $record->fields();
	foreach my $field (@fields) {
		#get tag number
		my $fldtag = $field->tag();
	
		#Select Case fldtag
		if ($fldtag eq '008') {
			#check for romanized record code in 008/38
			my $field008 = $field->as_string();
			my $modrec = substr($field008, 38, 1);
			$romanized = 1 if ($modrec eq 'o');
		} #008 field
		
		#elsif field is 906, check for 'cip' in subfield 'e'
		#elsif ($fldtag eq '906') { #LC specific test
			##check to be sure this is a CIP title
		#} #906

		#LCCN (will need to modify generating code to place before ISBN block in
		#finished printout, with prefix text "LCCN")
		elsif ($fldtag eq '010') {
			$myECIP{'lccn'} = $field->subfield('a') ? $field->subfield('a') : '';
			#if length is not 10 and the lccn doesn't start with '2' 
			#then add a hyphen between the 2nd and 3rd digits
			if (defined $myECIP{'lccn'} && (length($myECIP{'lccn'}) != 10) && ($myECIP{'lccn'} !~ /^ *2/ )) {
				#then remove leadinga and trailing spaces and add a hyphen between the 2nd and 3rd digits
				my $tempLCCN = ($myECIP{'lccn'} || '');
				$tempLCCN =~ s/^ *//;
				$tempLCCN =~ s/ *$//;
				substr($tempLCCN, 2, 0, '-') if $tempLCCN;
				$myECIP{'lccn'} = $tempLCCN if $tempLCCN;
			} #if lccn not 10 digits and doesn't start with 2
			#set $publccn to the lccn found, if any
			$publccn = $myECIP{'lccn'} if $myECIP{'lccn'};
			#remove leading and trailing spaces from LCCN
			$publccn =~ s/^ *//;
			$publccn =~ s/ *$//;
		} #elsif 010
		
		elsif ($fldtag eq '020') {
			if ( $myECIP{'isbn'} ) {
				#if $myECIP{isbn} has data already, tack on a space -- space before adding more
				$myECIP{'isbn'} = $myECIP{'isbn'}." -- ";
			} #if $myECIP{'isbn'} not empty
###
			my @subfields = $field->subfields();
			my $newstr = '';
			foreach my $subfield (@subfields) {
				my ($code, $isbndata) = (@$subfield);
				if ($code eq 'z') {
					$isbndata = 'ISBN (invalid) ' . $isbndata;
					$newstr .= $isbndata;
				} #if subfield 'z'
				else {
					#if first 13 chars are numeric
					if ( $isbndata =~ /^(\d{13})( .*)?/) {
						#have 13-digit ISBN
						$ISBN13 = 1; #true
						my $qualifier = $2 || '';
						$newstr .= "ISBN *" . fixsbn($1) . $qualifier;
					} #if 13 digit
					#if first 10 chars match 10-digit ISBN format
					elsif ($isbndata =~ /^(\d{9}[0-9X])( .*)?/i) {
						#have 10-digit ISBN
						my $qualifier = $2 || '';
						$newstr .= "ISBN ".fixsbn($1) . $qualifier;
					} #elsif 10 digit
					else {
print "Else not 10 or 13: ", $isbndata, "\n";
						#neither 10 nor 13 so add as-is
						$newstr .= $isbndata.' ';
					} #else not 10 nor 13
				} #else not z
			} #foreach subfield

			$newstr =~ s/^ *//;
			$newstr =~ s/ *$//;

			$myECIP{'isbn'} .= $newstr;
			#remove double spaces introduced between qualifier and number 
			##(not in original VB code, but probably bad translation somewhere)
			$myECIP{'isbn'} =~ s/  / /g;
		} # elsif 020 field

		elsif ($fldtag eq "050") {
			my $second050 = '';
			#replace decoded field with MARC version for now
			my $field_as_marc = $field->as_usmarc();
			if ( $myECIP{'callno'}) {
				$myECIP{'callno'} = $myECIP{'callno'}."\n["; ##]
			} # if callno not empty
			#need to look for second subfield a here
			if ( substr($field_as_marc, 3) =~ /\x1Fa/) {
				$second050 = "\n  [".stripit(substr($field_as_marc, index($field_as_marc, "\x1Fa", 3))); #] #
				#remove second 050a from original field
				$field_as_marc = substr($field_as_marc, 0, (index($field_as_marc, "\x1Fa", 3)));
			} #if multiple 050 subfield a exist
			if ( $field->subfield('u') ) {
				#call number is whole string up to subfield 'u'
				$myECIP{callno} = stripit(substr($field_as_marc, 0, index($field_as_marc, "\x1Fu")));
			} #if subfield u
			else {
				$myECIP{'callno'} = stripit($field_as_marc);
			} #else no subfield u

			my $spac = 0;
			my $lgth = length($myECIP{'callno'});
			for my $l (0..$lgth) {
				if ( substr($myECIP{'callno'}, $l, 1) eq ' ' ) {
					$spac++;
				}
			} # for $l (Next $l)
			if ($spac == 2) {
				#remove first space
				$myECIP{'callno'} =~ s/ //;
			} #if 2 spaces
			elsif ($spac == 3) {
				#remove first space
				$myECIP{'callno'} =~ s/ //;
			}
			if ($second050) {
				$myECIP{'callno'} = $myECIP{'callno'}.$second050
			} #if second collno
			if ($myECIP{'callno'} =~ /\[/ #]
			) { 
				#add closing bracket if open bracket was found
				#[ 
				$myECIP{'callno'} .= ']';
			} #if open bracket in callno
		} #elsif 050
		
		elsif ($fldtag eq "060") {
			$myECIP{nlmcallno} = stripit($field->as_usmarc());
		} #elsif 060
		
		#if 082 field and dewey not yet set
		elsif ($fldtag eq "082" && !($myECIP{'dewey'})) {
			my $second082 = '';
			my $deweyed = '';
			#convert field to MARC for manipulation
			my $field_as_marc = $field->as_usmarc();
			if ($field->subfield('2')) {
				$deweyed = '--dc'.$field->subfield('2');
				#remove last 4 chars of string (subfield-2 and 2 chars)
				$field_as_marc = substr($field_as_marc, 0, length($field_as_marc) - 4);
			} #if subfield 2
			if ( substr($field_as_marc, 3) =~ /\x1Fa/) {
				$second082 = "\n  [".stripit(substr($field_as_marc, index($field_as_marc, "\x1Fa", 3)))."]";
###################### uncertain translation ##############
				##I don't know why the next line, originally:
				#$second082 = Mid$($second082, 1, Len($second082) - 3)
				#is necessary???
				$second082 = substr($second082, 0, length($second082)-3); ####??? I must be misunderstanding the code??? ###
###################### /uncertain translation ##############

				#remove second subfield a from base field string
				$field_as_marc = substr($field_as_marc, 0, (index($field_as_marc, "\x1Fa", 3)));
			} #if multiple 082 subfield a exist
			$myECIP{'dewey'} = stripit($field_as_marc).$deweyed;
			#replace all / with '
			$myECIP{'dewey'} =~ s/\//\'/g;
			if ($second082) { $myECIP{'dewey'} .= $second082;}
		} #elsif 082
		
		elsif ($fldtag eq "088") {
			#add stringified field to notes
			push @{$myECIP{'catnotes'}}, stripit($field->as_usmarc());
		} #elsif 088

		elsif (($fldtag eq "100")||($fldtag eq "110")||($fldtag eq  "111")||($fldtag eq "130")) {
			$myECIP{'mainentry'} = stripit($field->as_usmarc());
		} #elsif 1xx

		elsif ($fldtag eq "240") {
			$myECIP{'ut'} = "[".stripit($field->as_usmarc())."]";
		} #elsif 240
		
		elsif ($fldtag eq "245" ) {
			if ( $field->indicator(1) eq '1' ) {
				push @{$myECIP{'tilaes'}},  "Title.";
			} #if 1st indicator is 1
			$myECIP{'Title'} = stripit($field->as_usmarc());
			if ( $myECIP{'mainentry'}) {
				#add 2 spaces in front of title main entry
				$myECIP{'Title'} = "  " . $myECIP{'Title'};
			} #unless mainentry exists
		} # elsif 245

		elsif ($fldtag eq "250" ) {
			#original had no space, perhaps because one was automatically added after the title in VB?
			$myECIP{'edition'} = " -- ".stripit($field->as_usmarc());
		} #elsif 250

		elsif ($fldtag eq "260") {
			$myECIP{'pub'} = $field->subfield('b');
			$myECIP{'pub'} =~ s/^ *//;
			$myECIP{'pub'} =~ s/ *$//;
			$pubname = $myECIP{'pub'};
		} #elsif 260
		
		#elsif ($fldtag eq "263") {
			#LC version checks projected pub date
			#This isn't necessary in QBI version
		#} #elsif 263

		elsif ($fldtag eq "300" ) {
			$myECIP{'phys'} = "   " . stripit($field->as_usmarc());
		} #elsif 300
		
		elsif (($fldtag eq "440")||($fldtag eq "490")) {
			unless ( $myECIP{'series'}) {
				$myECIP{'series'} = " -- ";
			} #unless a series has been added already
			$myECIP{'series'} .= " (".stripity($field->as_usmarc()).")";
			#remove double spaces (not in VB original, possibly due to stripity difference?)
			$myECIP{'series'} =~ s/  / /g;
			if ( $fldtag eq "440" ) {
				#? NEED TO include "ISSN" in tracing? #orig LC question #
				if ((@{$myECIP{'seriestracings'}}) && ($myECIP{'seriestracings'}->[-1] =~ /Series./)) {
					push @{$myECIP{'seriestracings'}}, "Series: ".stripit($field->as_usmarc());
				} #if previous series have been added
				else {
					push @{$myECIP{'seriestracings'}}, "Series.";
				} #else 1st series
			} #if 440
		} #elsif 440 or 490

		elsif ($fldtag eq "505") {
			if ( $myECIP{'phys'} =~ /v\./) {
				my $pref = "Contents: ";
				push @{$myECIP{'catnotes'}}, (join "", ($pref, stripit($field->as_usmarc())));
			}
		} #elsif 505
		
		elsif (grep {$fldtag eq $_} (500..589)) {
			my $pref = '';
			if ( $fldtag eq "520" ) {$pref = "Summary: ";}
			if ( $fldtag eq "538" ) {$pref = "System requirements: ";}
			if ( $fldtag eq "521" ) {$pref = "Audience: ";}
				push @{$myECIP{'catnotes'}}, (join "", ($pref, stripit($field->as_usmarc())));
		} #elsif 5xx..589
		
		elsif (($fldtag eq "740")||($fldtag eq "246")) {
			my $tilind1 = '';
			my $tilind2 = '';
			if ( $fldtag eq "246" ) {
				$tilind1 = $field->indicator(1);
				$tilind2 = $field->indicator(2);
			}
			my $tilae = stripit($field->as_usmarc());
			if (($tilind1 eq "1") || ($tilind1 eq "3") || ($fldtag eq "740")) {
				#make sure title added entry ends in period
				unless ( $tilae =~ /\.$/ ) { 
					$tilae .= ".";
				} #unless title ends in period
				push @{$myECIP{'aes'}}, ("Title: ".$tilae);
			} #if ind1 is 1 or 3 or tag is 740
			if ((($tilind1 eq "0")||($tilind1 eq "1")) && ($tilind2 ne ' ')) {
				push @{$myECIP{'catnotes'}}, $constant[$tilind2]." title: ".$tilae;
			} #if indicator 1 is 0 or 1
		} #elsif 246 or 740
		
		elsif (($fldtag eq "700")||($fldtag eq "710")||($fldtag eq "711")||($fldtag eq "730")) {
			push @{$myECIP{'aes'}}, stripit($field->as_usmarc());
		} #elsif 700, 710, 711, or 730

		elsif ($fldtag eq "830") {
			push @{$myECIP{'seriestracings'}}, stripit($field->as_usmarc());
		} #elsif 830
		
		elsif (($fldtag eq "600")||($fldtag eq "610")||($fldtag eq "611")||($fldtag eq "630")||($fldtag eq "650")||($fldtag eq "651")||($fldtag eq "655")) {
			if ( $field->indicator(2) eq '0' ) {
				push @{$myECIP{'subjects'}}, stripitx($field->as_usmarc());
			} #if LCSH
			if ( $field->indicator(2) eq '1' ) {
				my $juvsubj = stripitx($field->as_usmarc());
				#remove leading and trailing spaces
				$juvsubj =~ s/^ *//;
				$juvsubj =~ s/ *$//;
				push @{$myECIP{'juvsubjects'}}, $juvsubj;
			} #if LCSHAC
			if ( $field->indicator(2) eq '2' ) {
				push @{$myECIP{'nlms'}}, stripitx($field->as_usmarc());
			} #if MeSH
		} #elsif 6xx
		
		#elsif ($fldtag eq  "963") {
			#LC version looks for e-mail address
			#This isn't necessary in QBI version
		#} #elsif 963

	} #foreach field

	#############################
	## Put components together ##
	#############################

	#LC checks here for 263 pubdate and whether item has been processed

	#add note about romanized record (based on 008/38)
	if ( $romanized ) {
		#not likely for QBI PCIP
		push @{$myECIP{'catnotes'}}, "Romanized record.";
	} #if romanized

	#add main entry to output text if it exists
	if ($myECIP{'mainentry'}) {
		#add to output text and end with new line char
		$txt = $myECIP{'mainentry'}."\n";
	} #if mainentry exists
	#add uniform title if it exists
	if ($myECIP{'ut'}) {
		#add to output text 2 spaces, uniform title, and new line char
		$txt .= "  ".$myECIP{'ut'}."\n";
	} #if uniform title
	
	#add title and edition statemnt and new line char
	$txt .= $myECIP{'Title'}.$myECIP{'edition'}."\n";
	#add four spaces before physical description, followed by series and new line char
	$txt .= "    ".$myECIP{'phys'}.$myECIP{'series'};

	#join each note with a new line character and two spaces into a single string of notes
	#extra empty string inserted so first note has spaces in front
	my $notes = join "\n  ", "", @{$myECIP{'catnotes'}};
	#add notes to main string, preceded by 2 spaces
	####may have extra 2 spaces after last new line char
	$txt .= $notes."\n";

	#add LCCN from 010 here, after last set of notes
	##Not in LC's version, since there, LCCN is placed at the bottom of the block
	$txt .= "  LCCN ".$publccn."\n" if ($publccn);
	
	#add ISBNs
	if (($myECIP{'isbn'}) && ($ISBN13 == 1)) { #has 13-digit ISBN
		#print each ISBN-13 and 10 pair on its own line
		$txt .= "  ".fixsbn13($myECIP{'isbn'})."\n";
		#pubisbn used for reporting in e-mail
		$pubisbn = fixsbn13($pubisbn);
	} #if 13 digit ISBN is present
	elsif (($myECIP{'isbn'}) && ($ISBN13 == 0)) {
		#no 13-digit ISBNs so print as single paragraph
		$txt .= "  ".$myECIP{'isbn'}."\n";
	} #elsif ISBN and not 13-digit
	
	#No extra blank line between notes and subjects?

	#add subject headings to output text
	foreach (my $x = 0; $x <= $#{$myECIP{'subjects'}}; $x++) {
		$txt .= ' '.($x + 1).". ".${$myECIP{'subjects'}}[$x];
	} # foreach LCSH
	
	#add juvenile subject headings
	if ( @{$myECIP{'juvsubjects'}} ) {
		my $juvpref = '';
		for (my $x = 0; $x <= $#{$myECIP{'juvsubjects'}}; $x++) {
			#add bracket in front of 1st heading
			if ( $x == 0 ) {
				$juvpref = " [" #] #close bracket for balancing in coding only
			} #if first heading
			else {
				$juvpref = ' ';
			} #after first
			#add prefix and heading to output text
			$txt .= $juvpref.($x + 1).". ".$myECIP{'juvsubjects'}[$x];
		} # foreach juvenile heading
		#add closing bracket to opening '['
		$txt .= "]";
	} #if juvenile SH

	#there shouldn't be MeSH in QBI's PCIP, but just in case
	if ( @{$myECIP{'nlms'}} ) {
		my $meshpref = '';
		for (my $x = 0; $x <= $#{$myECIP{'nlms'}}; $x++) {
			if ( $x == 0 ) { 
				$meshpref = "\n"."  [DNLM: " #]
			} #if first heading
			else {
				$meshpref = ' ';
			} #else not first
			$txt .= $meshpref.($x + 1).". ".$myECIP{'nlms'}[$x];
		} # foreach mesh heading
		#add MeSH call# and closing bracket for the '['
		$txt .= "  ".$myECIP{'nlmcallno'}."]";
	} #if MeSH 

	#add added entries
	#get ending count for each, taking into account empty array ref (-1)
	my $a = $#{$myECIP{'aes'}};
	my $t = $#{$myECIP{'tilaes'}};
	#keep track of roman numeral indexing
	my $roman_num = 0;
	#for added entries
	for (my $x = 0; $x <= $#{$myECIP{'aes'}}; $x++) {
		if ( $x == 0 ) {
			#add extra 2 spaces before first heading
			$txt .= "  ";
		} #if first added entry
		$roman_num++;
		$txt .= $roman[$roman_num] . ". " . $myECIP{'aes'}[$x] . ' ';
	} # foreach added entry
	#for title added entries
	for (my $x = 0; $x <= $#{$myECIP{'tilaes'}}; $x++) {
		if ( $x + $roman_num == 0 ) {
		$txt .= "  ";
		} #if first added entry
		$roman_num++;
		$txt .= $roman[$roman_num] . ". " . $myECIP{'tilaes'}[$x].' ';
	} # foreach title added entry
	#for series added entries
	for (my $x = 0; $x <= $#{$myECIP{'seriestracings'}}; $x++) {
			if ( $x + $roman_num == 0 ) {
				$txt .= "  ";
			} #if first added entry
		$roman_num++;
		$txt .= $roman[$roman_num] . ". " .  $myECIP{'seriestracings'}[$x] . ' ';

	} # foreach series title

	#finish block with call numbers and control number

	#declare variables for common spacers
	my $s2Tabs = "\t\t";
	my $s3Tabs = "\t\t\t";
	my $s2newlines = "\n\n";
	my $s3newlines = "\n\n\n";
	my $sSolidLine = " " x 5 . "_" x 84;

	#may need extra new line char between SH/Added entry block and callnos
	
	#add LC callno after new line and 2 spaces
	$txt .= "\n"."  ".$myECIP{'callno'}."\n";
	#add DDC after 2 spaces
	$txt .= "  ".$myECIP{'dewey'}."\n";
	
	###change line below to 001 for control no instead of LCCN
	#retrieve 001 controlno
	my $controlno = $record->field('001')->as_string();
	#add controlno to output text, with appropriate spacing for indentation
	$txt .= ralign($controlno);

	#convert diacritics (Western-European, not Unicode stuff)
	#these need to be added manually to the finished output block
	##skip for now
	#$txt = Voyager2MsoftAscii($txt)

################################
#### Return resulting block ####
################################

	my $block = MARC::PCIPmaker::add_PCIP_header($txt);

	return ($block, @errorstoreturn);

} #end makecard

=head2 add_PCIP_header($txt)

Given a formatted block of text (from makecard), adds PCIP header.

Returns the formatted block.

=cut

sub add_PCIP_header {

	my $txt = shift;
	my $block = '';

	#MS Word spacing in existing block:
	#{\s x 37}<b>Publisher's Cataloging-in-Publication</b>

	#declare variables for common spacers
	my $s2Tabs = "\t\t";
	my $s2newlines = "\n\n";

	#generate text for PCIP block introduction
	#first line of header should be bold
	my $header = $s2newlines.$s2Tabs."Publisher's Cataloging-in-Publication\n";

	$block = $header.$s2newlines.$txt."\n";
	return $block;

} #add_PCIP_header($txt)

=head2 RecordProblem ($tagno)

VB function prints errors found in records, but Perl version may (probably won't) call this sub automatically. In other words, this sub could probably be deleted.

=cut


sub RecordProblem {

	my $tagno = shift;

	my $sMsg = "There is a problem with the PCIP record!\nThe ".$tagno." field appears to have an error in it." if $tagno;
	return $sMsg;
	
} #RecordProblem

=head2 ralign($flushright As String)

Adds spaces in front of the passed string, formatted according to 70 spaces minus the length of the passed string.

$flushright needs to be less than 70 characters long.

=cut

sub ralign {
	
	my $flushright = shift;
	return (" " x (70 - length($flushright)).$flushright);

} #ralign

=head2 stripit($messedup As String)

Takes raw MARC field as input. Skips first 2 characters (which are either indicators or subfield delimiter and code). Replaces subfield delim-code pair with single space if not at the beginning or end of the field. Returns the resulting string.
Similar to MARC::Field::as_string().

=cut

sub stripit {

	my $messedup_string = shift;
	#skip first 2 characters, which will either be the indicators 
	#if a full field string was passed
	#or will be subfield delimiter and char
	#break into individual characters
	my @messedup = split "", (substr($messedup_string, 2));
	my $newstr = '';
	my $nextbad = 0; #false#

	for (my $I = 0; $I <= $#messedup; $I++) {
		if ($messedup[$I] =~ /^[\x1F\x1E\x1D]/) {
			$I = $I + 1;
			##numbers in if below may be off by 1
			if (($I > 2) && ($I < $#messedup)) {
				$newstr .= ' ';
			} #if $I >2 and $I < length of messedup string minus 1
		} #if subfield delimiter
		else {
			$newstr = $newstr.$messedup[$I];
		} #else not delimiter
	} # for $I (Next I)

	return $newstr;

} #stripit

=head2 stripitx($subjhdg As String)

=cut

sub stripitx {

	#retrieve passed string
	my $subjfield_asmarc = shift;
	#skip first 2 characters, which are indicators or subfield a delimiter-code pair
	#break each char into array position
	my @subjhdg = split "", substr($subjfield_asmarc, 2);
	my $newstr = '';
	for (my $I = 0; $I <= $#subjhdg; $I++) {
		if ($subjhdg[$I] =~ /[\x1e\x1d]/) {
			$I++;
		} #if end of field or end of record
		elsif ($subjhdg[$I] eq "\x1F") {
			$I++;
			my $sfc = $subjhdg[$I];
			if ($sfc =~ /[vxyz]/) {
				#add hyphens between subfields v, x, y, or z
				$newstr .= "--";
			} #if subfield v, x, y, or z
			else {
				#add space between other subfields
				$newstr .= ' ';
			}
		} #elsif subfield delimiter
		else {
			$newstr .= $subjhdg[$I];
		} #else char in subfield
	} # for chars in subjhdg (Next I)


	#remove leading and trailing spaces
	#not in original?
	$newstr =~ s/^ *//;
	$newstr =~ s/ *$//;
	
	return $newstr;
	
} #stripitx

=head2 stripity($seriesst As String)

Parses 4xx and converts subfield indicators to proper appearance.
Pass in 4xx string. Returns parsed string, replacing subfield code and delimiter with appropriate values/formatting.

=cut

sub stripity {

	my $seriesst_string = shift;
	#remove first 2 chars (indicators or first subfield code and delimiter) and put each char into an array slot
	my @seriesst = split "", substr($seriesst_string, 2);
	my $newstr = '';
	for (my $I = 0; $I <= $#seriesst; $I++) {
		if ($seriesst[$I] =~ /[\x1e\x1d]/) {
			$I++;
		} #if end of field or end of record
		elsif ($seriesst[$I] eq "\x1F") {
			$I++;
			my $sfc = $seriesst[$I];
			if ($sfc eq 'x') {
				#if subfield 'x', then add prefix ' ISSN '
				$newstr .= " ISSN ";
			} #if subfield x
			else {
				if (($I > 1) && ($I < ($#seriesst - 1))) {
					$newstr .= ' ';
				} #if past 2nd char and before 1 before end of string?
			} #else not subfield x
		} #elsif subfield delimiter
		else {
			$newstr .= $seriesst[$I];
		}
	} # for chars (Next $I)

	return $newstr;

} #stripity

=head2 stripitz ($isbnfield) 

Reads each character of the field, building a new string. 
Used for ISBN (field 020).
=cut

sub stripitz {

	my $isbnfield = shift;
	#remove first 2 chars (indicators or first subfield code and delimiter) and put each char into an array slot
	my @isbnchars = split "", substr($isbnfield, 2);
	my $newstr = '';
	for (my $I = 0; $I <= $#isbnchars; $I++) {
		if ($isbnchars[$I] =~ /[\x1e\x1d]/) {
			$I++;
		} #if end of field or end of record
		elsif ($isbnchars[$I] eq "\x1F") {
			$I++;
			my $sfc = $isbnchars[$I];
			if ($sfc eq 'z') {
				#if subfield 'x', then add prefix ' (invalid) '
				$newstr .= " (invalid) ";
			} #if subfield z
			else {
					$newstr .= ' ';
				} #else 
		} #elsif subfield delimiter
		else {
			$newstr .= $isbnchars[$I];
		}
	} # for chars (Next $I)
	#remove leading and trailing spaces
	$newstr =~ s/^ *//;
	$newstr =~ s/ *$//;
	return $newstr;

} #stripitz

=head2 BROKEN

sub stripitz { #using MARC::Record style. Currently broken

	my $isbnfield = shift;
	my $newstr = '';
	foreach my $subfield ($isbnfield->subfields()) {
		#if subfield code is 'z'
		if (${$subfield}[0] eq 'z') {
			#add space "(invalid)" space to existing string before adding the rest of the subfield
			$newstr .= " (invalid) ";
			#add the rest of the subfield data
			$newstr .= ${$subfield}[1];
		} # if subfield 'z'
		else {
			#add space to existing string before adding the rest of the subfield
			$newstr .= ' ';
			#add the rest of the subfield data
			$newstr .= ${$subfield}[1];
		} #else not subfield z
	} # foreach subfield
	#remove leading and trailing spaces from $newstr before sending it back to the caller
	$newstr =~ s/^ *//;
	$newstr =~ s/ *$//;
	return $newstr;
} #stripitz
=cut



=head2 fixsbn ($unhyphened_isbn)

Hyphenates an ISBN according to country and publisher codes. The Perl version relies upon Business::ISBN to handle determining placement of hyphens.

=head2 TODO (fixsbn)

Add prompt for user to specify where publisher said hyphens should go, including none.

Deal with ISBN-13, which may not hyphenate properly using current version of Business::ISBN.

Do error checking on passed ISBN strings. Currently, depends upon these having been corrected before being passed to the sub. Need to check length, make sure only digits are present, make sure check digit is correct.

=cut

sub fixsbn {

	my $unhyphened = shift;
	my $hyphenated = '';
	if (length($unhyphened) == 10) {
		my $isbn_object = new Business::ISBN($unhyphened);
		#hyphenate according to default positions
		$hyphenated = $isbn_object->as_string();

	} #if 10 digit
	elsif (length($unhyphened) == 13) {
		#place hyphen between 3rd and 4th characters (978-)
		my $prefix = substr($unhyphened, 0, 3).'-';
		my $check_digit_13 = substr($unhyphened, -1, 1);
		#convert 13 to 10 to find hyphen positions
		my $isbn = Business::ISBN::ean_to_isbn($unhyphened);
		#generate isbn object for the 10
		my $isbn10_obj = new Business::ISBN($isbn);
		#hyphenate according to defaults
		my $hyphenated10 = $isbn10_obj->as_string();
		#replace check digit with original for 13 digit
		substr($hyphenated10, -1, 1, $check_digit_13);
		#put parts together
		$hyphenated = $prefix.$hyphenated10;
	} #if 13 digit
	return $hyphenated.' ';

} # end fixsbn

=head2 fixsbn13($ISBNs13)

Pass in string of ISBN text, returns formatted string, including line breaks and spacing, for ISBN notes.

=cut

sub fixsbn13 {
	
	#retrieve passed in string of 13-digit ISBNs
	my $ISBNs13 = shift;
	my @sISBNs13 = ();
	my $I = 0;
	my $isbns_to_return = '';
	
	if ( $ISBNs13 =~ / -- /) {
		#break each into an array slot
		@sISBNs13 = split(" -- ", $ISBNs13);
ISBNTEXT: for my $I (0..$#sISBNs13) {
			if ( $sISBNs13[$I] =~ /invalid/ ) {
				#replace 13 text with proper format prefix
				$sISBNs13[$I] =~ s/ISBN \(invalid\) \*/ISBN-13: (invalid) /;
				#replace 10 text with proper format prefix
				$sISBNs13[$I] =~ s/ISBN \(invalid\) /ISBN-10: (invalid) /;
			} #if invalid
			else {
				#add proper format prefixes
				$sISBNs13[$I] =~ s/ISBN \*/ISBN-13: /;
				$sISBNs13[$I] =~ s/ISBN /ISBN-10: /;
			} #else valid
			if ( $I == 4 ) {
				#more than 3-4 ISBNs (or pairs of 10 and 13), so add a bracketed "[etc.]";
				$isbns_to_return = $isbns_to_return."[etc.]";
				last ISBNTEXT;
			} #if past 3 or 4 -- need to determine 0 vs. 1 base in original VB code
			if ( $I < $#sISBNs13 ) {
				$isbns_to_return = $isbns_to_return.$sISBNs13[$I]."\n  ";
			} #if more ISBNs exist
			else {
				$isbns_to_return = $isbns_to_return.$sISBNs13[$I];
			} #else last of isbn13 text
		} # foreach item in @sISBNs13
	} #if $ISBNs13 has " -- "
	else {
		if ( $ISBNs13 =~ /invalid/) {
			#fix prefix text for invalid
			$isbns_to_return =~ s/ISBN (invalid) \*/ISBN-13: (invalid) /;
		} #if invalid in single ISBN13
		else {
			#only 1 valid ISBN13 was passed
			$isbns_to_return =~ s/ISBN \*/ISBN-13: /;
		} #else 1 valid ISBN13
	} #else single ISBN13

	return $isbns_to_return;
	
} # end fixsbn13

1;

=head1 VERSION HISTORY

Version 1.02: Updated July 16, 2006.

 -Removed some QBI-specific code for posting to website.
 -Renamed module to MARC::PCIPmaker.

Version 1.01: Updated July 20, 2005.

 -Bug fixes.
 -Revised in minor ways to generate block for non-CIP-level items.
 --Consider revising overall module for general release as ISBD formatting module.

Version 1.00: Initial version based on code in Visual Basic from the Library of Congress.

 -Composes the PCIP block, but does not yet split lines at a maximum line length.
 -Does not yet format the header for bold, italics, or the proper font.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that this module is not a product of or supported by the 
employers of the various contributors to the code.

=head1 AUTHOR

Bryan Baldus
eijabb@cpan.org

Copyright (c) 2005

=cut


__END__
