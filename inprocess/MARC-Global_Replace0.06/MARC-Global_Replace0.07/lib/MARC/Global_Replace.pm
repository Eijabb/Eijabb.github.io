#!perl

package MARC::Global_Replace;

our $VERSION = 0.07;

=head2 NAME

MARC::Global_Replace -- Collection of subroutines designed to assist in doing global replacement of subject headings.

=head2 DESCRIPTION

read_changed_SH([$file_path]) -- Reads a file of changed subject headings and returns a hash linking the old tag and heading with new tag and heading.

make_sub_a_hdgs(\%heading_data) -- Given a hash ref of heading data (as returned by read_changed_SH()), parses old and new tags into subfield 'a'-only headings, dropping subdivisions.

new_is_old(\%heading_data) -- Looks for new headings that have been changed again.

identify_changed_hdgs($field, \%heading_data) -- Given a MARC::Field object and a hash_ref containing old tag, old hdg, new tag, new hdg, and thesaurus data, determines whether field data matches a changed heading. Returns new_tag \t new_hdg if heading matches changed heading and 0 if not.

ind_to_thesaurus($sh_field) -- Translates 2nd indicator of passed-in MARC::Field (which should be 6xx) into word indicating the thesaurus represented by the indicator. If ind2 is '7', subfield '2' is checked for additional determination of thesaurs. Returns the thesaurus and any errors encountered.

as_hyphenated($sh_field) -- Breaks field into a string with dash-separated subfields.

match_sub_a_to_old(\%heading_data, $old_tag, $old_suba) -- Given the hash_ref of heading data (created by read_changed_SH()), the desired tagno, and a string of subfield 'a' data, returns a hash_ref of relevant full headings.

read_changed_names([$file_path]) -- Reads a file of changed name headings (x00) and returns a hash linking the old tag and heading with new tag and heading.

=head2 SYNOPSIS

use MARC::Global_Replace;

my %heading_data = MARC::Global_Replace::read_changed_SH();

=head1 TO DO

Remove dependence on MARC::QBI::Misc for file name handling (move code to MARC::BBMARC for distribution).


=cut


use strict;
use warnings;
use Carp;
use MARC::QBI::Misc;

#normalize strings according to NACO rules
use Text::Normalize::NACO qw( naco_normalize );

###########################################
###########################################
###########################################

=head2 read_changed_SH([$file_path])

Reads a file containing "old_tag \t old_hdg \t new_tag \t new_hdg \t thesaurus" lines. Old_hdg and New_hdg should be in the form 'Heading--Subdivision--Subdivision' (-- separates each subdivision). The file may have been generated by the LCSHchangesparserpl*.pl (* = version) script.

Optionally, pass in a full path to a file containing lines formatted as above. If none is provided, a prompt will appear for this file.

Thesauri for which the old heading has been changed will be (currently): 'LCSH', 'AC', 'Sears', 'GSAFD'.

The initial version of the module will likely support only 1 thesaurus per read_changed_SH() file.

Returns a hash_ref of heading data and an array_ref of any errors encountered.

=head2 TO DO (read_changed_SH([$file_path]))

Determine appropriate structure for return hash. Currently:

%heading_data = ($old_tag => {$old_hdg => {$new_tag =>$new_hdg, 'thesauri' = \@thesauri}});
so: '650' => {'Aged' => {'650' => 'Older people'},
'Aged--Health and hygiene' => {'650' => 'Older people--Health and hygiene', 'thesauri' => ['LCSH']}};

$heading_data{'650'}{'Aged'} = {'650' => 'Older people'};
$heading_data{'650'}{'Aged'}{'650'} = 'Older people';
push @{$heading_data{'650'}{'Aged'}{'thesauri'}}, 'LCSH', 'AC';

Future versions of the LCSHchangesparserpl*.pl program may further parse the headings into a subfield code-data pair. An example line might be:

650\tAged$xHealth and hygiene\t650\tOlder people$xHealth and hygiene

or something similar. Work in determining the appropriate subfield code may be done in the present module, instead.


=head2 SYNOPSIS (read_changed_SH([$file_path]))

my ($heading_data_ref, $errors_ref) = MARC::Global_Replace::read_changed_SH();
my %heading_data = %$heading_data_ref;
print join "\n", @$errors_ref, "\n" if @$errors_ref;

=cut

sub read_changed_SH {

######

	my %heading_data = ();
	my @errors_to_return = ();


	my $inputfile = (shift || '');
	unless ($inputfile) {
	
		#prompt for input file
		my $inputfile_message = "Please enter the path and name of the file of old and new headings (txt): ";
		#call get_file_name for the input file
		($inputfile, my $error) = MARC::QBI::Misc::get_file_name($inputfile_message, '<');
		die "Error with input file name" if $error;

	} #unless input file was passed

	open (IN, "<$inputfile") or die "Cannot open $inputfile file for reading, $!";

	while (my $line = <IN>) {
		chomp $line;
		#skip blank lines
		next if $line =~ /^\s*$/;
		#end on presence of line of hyphens
		last if ($line eq '--------------------');
##Lines: old_tag\told_hdg\tnew_tag\tnew_hdg
		#skip lines that don't start with a tag number
		next unless $line =~ /^\d\d\d\t/;

		###break line into parts
		my ($old_tag, $old_hdg, $new_tag, $new_hdg, $thesaurus) = split "\t", $line;
		#report error if one of the variables is empty
		unless ($old_tag && $old_hdg && $new_tag && $new_hdg && $thesaurus) {
			push @errors_to_return, "Line is missing old tag ($old_tag)" unless ($old_tag);
			push @errors_to_return, "Line is missing old hdg ($old_hdg)" unless ($old_hdg);
			push @errors_to_return, "Line is missing new tag ($new_tag)" unless ($new_tag);
			push @errors_to_return, "Line is missing new hdg ($new_hdg)" unless ($new_hdg);
			push @errors_to_return, "Line is missing thesaurus ($thesaurus)" unless ($thesaurus);
		} #unless old or new tag or hdg are missing
		else {
			#add current data to hash of heading data
			unless (exists $heading_data{$old_tag}{$old_hdg}) {
				$heading_data{$old_tag}{$old_hdg} = {$new_tag => $new_hdg};
				push @{$heading_data{$old_tag}{$old_hdg}{'thesauri'}}, $thesaurus;
			} #unless already seen old-tag, old-heading pair
			else {


#####FIX THIS!!!!!!!########

				push @errors_to_return, "$old_tag\t$old_hdg\texists, with thesaurus\t$thesaurus";
#				$heading_data{$old_tag}{$old_hdg} = {$new_tag => $new_hdg};
				push @{$heading_data{$old_tag}{$old_hdg}{'thesauri'}}, $thesaurus;
			} #else already exists
		} #else line has needed elements
	} #while file has lines
	close IN;

######

	return (\%heading_data, \@errors_to_return);

} #read_changed_SH([$file_path])

###############################################
###############################################
###############################################

=head2 make_sub_a_hdgs(\%heading_data)

Given a hash ref of heading data (as returned by read_changed_SH()), parses old and new tags into subfield 'a'-only headings, dropping subdivisions.

For example:

('650' => {'Aged--Health and hygiene' => {'650' => 'Older people--Health and hygiene, 'thesauri' => ['LCSH']}})

becomes:

('650' => {'Aged' => {'650' => 'Older people', 'thesauri' = 'LCSH'}})


The main purpose of the sub is to create a hash to be used for identifying records needing to be changed, while work progresses on the replacement capabilities. Replacement will require headings to be parsed and assigned appropriate subfield coding, which will take some time.

=head2 SYNOPSIS (make_sub_a_hdgs(\%heading_data))

 my $changed_hdgs_sub_a_ref = MARC::Global_Replace::make_sub_a_hdgs(\%heading_data);

	my %changed_hdgs_sub_a = %$changed_hdgs_sub_a_ref;

	#while records
	#foreach sh ($record->field('6..'))
		#if ((exists $changed_hdgs_sub_a{$sh->tag()}) && (defined $changed_hdgs_sub_a{$sh->tag()}{$sh->subfield('a')})) {
			#$sh_has_changed++; #to indicate need for MARC editing
			#push @errors_to_print, "$controlno\t{$sh->subfield('a')} has changed to $new_hdg"; #new_hdg extracted from appropriate value
		#}

=cut

sub make_sub_a_hdgs {

	my $heading_data_ref = shift;
	my %heading_data = %$heading_data_ref;
	#declare hash to return
	my %sub_a_data = ();
	foreach my $old_tag (keys %heading_data) {
		foreach my $old_hdg (keys %{$heading_data{$old_tag}}) {
			my $new_count = 0;
			#get thesauri related to this old_tag-old_hdg pair
			my @thesauri = @{$heading_data{$old_tag}{$old_hdg}{'thesauri'}};
			foreach my $new_tag (keys %{$heading_data{$old_tag}{$old_hdg}}) {
				#'thesauri' will be one of the new_tag keys so skip it
				next if ($new_tag eq 'thesauri');
				$new_count++;
				#report problem if old tag and old hdg are linked to more than one new tag/new hdg
				if ($new_count > 1) {
					print "$old_hdg has more than one new tag ($new_tag)\n"; 
				} #if new count > 1
				my $new_hdg = $heading_data{$old_tag}{$old_hdg}{$new_tag};
				my ($new_sub_a) = split '--', $new_hdg;
				my ($old_sub_a) = split '--', $old_hdg;
				if ($new_sub_a && $old_sub_a) {
					$sub_a_data{$old_tag}{$old_sub_a}{$new_tag} = $new_sub_a;

				#add thesauri to sub_a_data hash
				@{$sub_a_data{$old_tag}{$old_sub_a}{'thesauri'}} = @thesauri;
				} #if new and old subfield 'a' hdgs exist
				else {
#					print "Missing subfield_a data_old_or_new: $old_tag\t$old_hdg\t$new_tag\t$new_hdg\t\n";
				} #else missing sub a data old or new
			} #foreach new tag
		} #foreach old hdg
	} #foreach old tag
	
	
	
	return (\%sub_a_data);
} #make_sub_a_hdgs(\%heading_data)

###########################################
###########################################
###########################################

=head2 new_is_old(\%heading_data)

Looks for new headings that have been changed again.

my $hdg_data_ref = MARC::Global_Replace::new_is_old(\%heading_data);

my %hdg_data = %$hdg_data_ref;

=cut

sub new_is_old {

	my $heading_data_ref = shift;
	my %heading_data = %$heading_data_ref;

	#look at each heading for new headings that are also old headings
	foreach my $oldtag (keys %heading_data) {
		foreach my $oldhdg (keys %{$heading_data{$oldtag}}) {
			my %new_hdg_data = %{$heading_data{$oldtag}{$oldhdg}};
			foreach my $newtag (keys %new_hdg_data) {
				my $newhdg = $new_hdg_data{$newtag};
				if (defined $heading_data{$newtag} && defined $heading_data{$newtag}{$newhdg}) {

					my %updated_new_data = %{$heading_data{$newtag}{$newhdg}};
					foreach my $newertag (keys %updated_new_data) {
						my $newerhdg = $updated_new_data{$newertag};
						#update old heading to newer heading
						$heading_data{$oldtag}{$oldhdg}{$newertag} = $newerhdg;

####testing
print "Changed heading:\tOrig.:\t$oldtag\t$oldhdg\tNext:\t$newtag\t$newhdg\tNew:\t$newertag\t$newerhdg\n";
####/testing

					} #foreach newer tag
				} #if new heading is an old heading
			} #foreach newtag
		} #foreach oldhdg
	} #foreach oldtag

	return \%heading_data;
	
} #new_is_old

###########################################
###########################################
###########################################

=head2 identify_changed_hdgs($field, \%heading_data)

Given a MARC::Field object and a hash_ref containing old tag, old hdg, new tag, new hdg, and thesaurus data, determines whether field data matches a changed heading.

Returns new_tag \t new_hdg if heading matches changed heading and 0 if not.

Future version should return array_ref of any errors found.

=head2 TODO

Current version looks only at subfield a (so more false hits are likely). Later version should parse subfields of the field and compare against full changed headings.

=head2 SYNOPSIS (identify_changed_hdgs($field, \%heading_data))

my $has_changed = MARC::Global_Replace::identify_changed_hdgs($field, \%heading_data, \%changed_hdgs_sub_a);

if ($has_changed) {
	#add controlno to var for manual change
	#print message to error file about old and new heading
	###print "Field ", $field->subfield('a'), " may have changed (to: $has_changed)\n";
}

=cut

sub identify_changed_hdgs {

	require MARC::Field;

	my $field = shift;
	my $heading_data_ref = shift;
	my %heading_data = %$heading_data_ref;
	#get hashref of subfield a of changed headings only
	my $changed_hdgs_sub_a_ref = shift; 
	my %changed_hdgs_sub_a = %$changed_hdgs_sub_a_ref;

	my $has_changed = '';



	my $field_tag = $field->tag();
	my $suba = $field->subfield('a') || '';

	#get thesaurus for this tag's 2nd ind
	my ($ind2_thesaurus, $errs_ref) = MARC::Global_Replace::ind_to_thesaurus($field);
	#report any errors found trying to get indicator
	print join "\n", "Errors: ", @$errs_ref, "\n" if (@$errs_ref);

	if ($field_tag && $suba && $ind2_thesaurus) {
		#remove trailing period
		$suba =~ s/\.$//;
		if (defined $changed_hdgs_sub_a{$field_tag}{$suba}) {
			my @thesauri = @{$changed_hdgs_sub_a{$field_tag}{$suba}{'thesauri'}};
			#if current thesaurus is among those linked to this old_tag-old_hdg pair
			if (grep {$ind2_thesaurus eq $_} @thesauri) {

#####testing
				#retrieve full old_hdg(s) that might match this subfield_a data
				my @hdgs_matched = @{MARC::Global_Replace::match_sub_a_to_old(\%heading_data, $field_tag, $suba)};
#####/testing
				
####testing
				#
				###compare with full field vs. full changed headings
				my $field_string =  MARC::Global_Replace::as_hyphenated($field);
				#remove trailing period
				$field_string =~ s/\.$//;
				if (my @keys_matched = grep {$field_string =~ /^(\Q$_\E)/; $1} @hdgs_matched) {

##testing
print "More than 1 match\t", join ("\t", @keys_matched), "\n" if (scalar @keys_matched > 1);
##/testing

					foreach my $key_matched (@keys_matched) {
						#get thesauri associated with full heading
						my @thesauri_full = @{$heading_data{$field_tag}{$key_matched}{'thesauri'}};
						#if current thesaurus is among those linked to this old_tag-old_hdg pair

						if (grep {$ind2_thesaurus eq $_} @thesauri_full) {
							#retrieve hash of new data containing new_tag, new_hdg, and thesauri for associated with old_tag-old_hdg pair
							my %new_data = %{$heading_data{$field_tag}{$key_matched}};

							foreach my $new_tag (keys %new_data) {
								#skip thesauri key
								next if ($new_tag eq 'thesauri');

								#retrieve new_hdg
								my $new_hdg = $heading_data{$field_tag}{$key_matched}{$new_tag};
##testing
##print "$new_hdg is new heading\tmatched: ", $key_matched, "\tfield string: $field_string", "\n";
##/testing
####################testing_nonreplacements (date partial match)
unless (($key_matched eq $new_hdg) && ($field_tag eq $new_tag)) {
##testing--trying to limit false matches vs. non-matches
	my @field_string_parts = split '--', $field_string;
	my @new_heading_parts =  split '--', $new_hdg;

	
##/testing
								unless ($field_string_parts[0] eq $new_heading_parts[0]) {
#								unless ($field_string =~ /^\Q$new_hdg\E/) {
print "orig not new ($field_string)\n";
									$has_changed .= join "\t", $new_tag, $new_hdg;
								} #unless existing hdg. contains all of new
} #unless old and new match
####################/testing_nonreplacements (date partial match)


#####/testing
							} #foreach new tag
						} #if full thesaurus matches
					} #foreach matching key
####/testing
				} #if old_hdg matches full field (at least in part)
			} #if suba thesaurus matches 
		} #if tag and sub_a match
	} #if field has tag and subfield 'a'

	return $has_changed;

} #identify_changed_hdgs

###########################################
###########################################
###########################################

=head2 ind_to_thesaurus($sh_field)

Translates 2nd indicator of passed-in MARC::Field (which should be 6xx) into word indicating the thesaurus represented by the indicator. If ind2 is '7', subfield '2' is checked for additional determination of thesaurs.

Returns the thesaurus and any errors encountered.

=cut

sub ind_to_thesaurus {

	my $field = shift;
	my $thesaurus = '';
	my @errors_to_return = ();
	
	#get tag for reporting
	my $tag = $field->tag();
	unless ($field->tag() =~ /^6..$/) {
		push @errors_to_return, "$tag does not appear to be a 6xx subject heading";
	} #unless 6xx tag

	my %base_thesauri = (
		'0' => 'LCSH',
		'1' => 'AC',
		'2' => 'MeSH',
		'3' => 'NAL',
		'4' => 'Other',
		'5' => 'CASH',
		'6' => 'RVM',
		'7' => 'Sub2',
	); #base thesauri

	
	my $ind2 = $field->indicator(2);
	#special case for 2nd indicator of '7'
	if ($ind2 eq '7') {
		if ($field->subfield('2')) {
			my $sub2 = $field->subfield('2');
			$thesaurus  = lc($sub2);
		} #if subfield '2' exists
		else {
			push @errors_to_return, join '', $tag, " does not appear to have a subfield '2' (", $field->as_string(), ")";
		} #no subfield '2'
	} #if ind2 is '7'
	else {
		$thesaurus = (exists $base_thesauri{$ind2} ? $base_thesauri{$ind2} : '');
		push @errors_to_return, join '', $tag, " second indicator ($ind2) does not appear to be valid." unless ($thesaurus);
	} #ind2 not '7'

	return ($thesaurus, \@errors_to_return);

} #ind_to_thesaurus($sh_field);

###########################################
###########################################
###########################################

=head2 as_hyphenated($sh_field)

Breaks field into a string with dash-separated subfields.

For example:
650  \0 _a Aged _x Health and hygiene.
becomes
Aged--Health and hygiene

Use:

my $sh_string = MARC::Global_Replace::as_hyphenated($sh_field);

=cut

sub as_hyphenated {

	my $sh_field = shift;
	my @new_subdata = ();
	
	my @subfields = $sh_field->subfields();
	while (my $subfield = pop(@subfields)) {
		my ($code, $data) = @$subfield;
		#add only data portion
		unshift (@new_subdata, $data);
	} # while

	return join( "--", @new_subdata );

} #as_hyphenated($sh_field)

###########################################
###########################################
###########################################

=head2 match_sub_a_to_old(\%heading_data, $old_tag, $old_suba)

Given the hash_ref of heading data (created by read_changed_SH()), the desired tagno, and a string of subfield 'a' data, returns a hash_ref of relevant full headings.

The resulting hash_ref can then be compared with the hyphenated field to determine whether the heading has changed or not.


=cut

sub match_sub_a_to_old {

	my $hdg_data_ref = shift;
	my %heading_data = %{$hdg_data_ref};
	my $old_tag = shift;
	my $sub_a = shift;

	my @headings_matched = grep {$_ =~ /^\Q$sub_a\E/} keys %{$heading_data{$old_tag}};

	return \@headings_matched;

} # match_sub_a_to_old(\%heading_data, $old_tag, $old_suba)


###########################################
###########################################
###########################################

=head2 read_changed_names([$file_path])

Similar to read_changed_SH(), reads a file of changed name headings. Each line of the supplied file should be in the format:

old_tag \t old_ind1 \t old_hdg \t new_tag \t new_ind1 \t new_hdg

where old_hdg and new_hdg contain subfield delimiters as \x1F. They are currently also assumed to contain ASCII-7 characters/no diacritics other than the subfield delimiter.

The file may have been generated by the parsedeathdatelist.pl script.

Optionally, pass in a full path to a file containing lines formatted as above. If none is provided, a prompt will appear for this file.

Returns a hash_ref of heading data and an array_ref of any errors encountered.

Example hash entry:
%heading_data = ('100' => {"SMITH JOHN \x1FD1900" => {'100' => "SMITH JOHN \x1FD1900 1999", 'old_ind1' => '1', 'new_ind1' => '1', 'orig_old' => "Smith, John,\x1Fd1900-", 'orig_new' => "Smith, John,\x1Fd1900-1999"}});


=head2 TODO

Normalize headings. Link normalized headings to unnormalized headings (separate sub?) to try to catch miscoded headings in the bib. record.

Allow UTF-8 encoded text file rather than assuming ASCII-only?

=cut

sub read_changed_names {

	my %heading_data = ();
	my @errors_to_return = ();


	my $inputfile = (shift || '');
	unless ($inputfile) {
	
		#prompt for input file
		my $inputfile_message = "Please enter the path and name of the file of old and new headings (txt): ";
		#call get_file_name for the input file
		($inputfile, my $error) = MARC::QBI::Misc::get_file_name($inputfile_message, '<');
		die "Error with input file name" if $error;

	} #unless input file was passed

	open (IN, "<$inputfile") or die "Cannot open $inputfile file for reading, $!";

	while (my $line = <IN>) {
		chomp $line;
		#skip blank lines
		next if $line =~ /^\s*$/;
		#skip lines that don't start with a tag number
		next unless $line =~ /^\d\d\d\t/;
		

		###break line into parts
		my ($old_tag, $old_ind1, $old_hdg, $new_tag, $new_ind1, $new_hdg) = split "\t", $line;
		#report error if one of the variables is empty
		unless ($old_tag && $old_hdg && ($old_ind1 =~ /[0-9]/) && $new_tag && ($new_ind1 =~ /[0-9]/) && $new_hdg) {
			push @errors_to_return, "Line is missing old tag ($old_tag)" unless ($old_tag);
			push @errors_to_return, "Line is missing old ind1 ($old_ind1)" unless ($old_ind1);
			push @errors_to_return, "Line is missing old hdg ($old_hdg)" unless ($old_hdg);
			push @errors_to_return, "Line is missing new tag ($new_tag)" unless ($new_tag);
			push @errors_to_return, "Line is missing new ind1 ($new_ind1)" unless ($new_ind1);
			push @errors_to_return, "Line is missing new hdg ($new_hdg)" unless ($new_hdg);
		} #unless old or new tag or hdg are missing
		else {
			#normalize old and new hdgs
			my $norm_old_hdg = naco_normalize($old_hdg);
			my $norm_new_hdg = naco_normalize($new_hdg);
			#add current data to hash of heading data
			$heading_data{$old_tag}{$norm_old_hdg} = {$new_tag => $norm_new_hdg, 'old_ind1' => $old_ind1, 'new_ind1' => $new_ind1, 'orig_old' => $old_hdg, 'orig_new' => $new_hdg};
		} #else line has needed elements
	} #while file has lines
	close IN;

######

	return (\%heading_data, \@errors_to_return);

} #read_changed_names([$file_path])

###########################################
###########################################
###########################################

=head2 identify_changed_names($field, \%heading_data)

Given a field and a hash_ref of heading data in the format:

$heading_data{$old_tag}{$norm_old_hdg} = {$new_tag => $norm_new_hdg, 'old_ind1' => $old_ind1, 'new_ind1' => $new_ind1, 'orig_old' => $old_hdg, 'orig_new' => $new_hdg};

returns "$new_tag\t$new_hdg" if heading matches changed heading and empty string if not. Also returns arrayref of any errors encountered.

Strips subfields other than 'abcdq' for parsing using hash lookup.

=head2 TODO

 -Normalize headings. Link normalized headings to unnormalized headings (separate sub?) to try to catch miscoded headings in the bib. record.

 --Current version strips trailing period, which could cause problems for names where period is supposed to be at the end of the name (initial as last element, qualifiers).

=cut

sub identify_changed_names {

	require MARC::Field;

	my $field = shift;
	my $heading_data_ref = shift;
	my %heading_data = %$heading_data_ref;

	my $has_changed = '';
	my @errors_to_return = ();

	#set tag to 100 for all (authority 100)
	my $tag = '100';
	#covert field to MARC format to simplify parsing
	my $field_marc = $field->as_usmarc();
	my $ind1 = $field->indicator('1');
	#strip indicators, subfield _a, and end of field character
	$field_marc =~ s/^..\x1Fa//;
	$field_marc =~ s/\x1E$//;
	#strip subfields other than 'abcdq' for parsing using hash lookup.
	##so, strip delimiter+character not desired+characters up to next delimiter
	$field_marc =~ s/\x1F[^abcdq][^\x1F]+//g;


	#normalize heading for hash lookups
	my $norm_field = naco_normalize($field_marc);

	if (exists $heading_data{$tag}{$norm_field}) {
		my $orig_new = $heading_data{$tag}{$norm_field}{'orig_new'};
		my $orig_old = $heading_data{$tag}{$norm_field}{'orig_old'};
		my $norm_new = $heading_data{$tag}{$norm_field}{$tag};
		my $old_ind1 = $heading_data{$tag}{$norm_field}{'old_ind1'};
		my $new_ind1 = $heading_data{$tag}{$norm_field}{'new_ind1'};

		#report error if new_ind1 is not current ind1
		push @errors_to_return, "Indicator in field does not match new indicator (current: $ind1 vs. new: $new_ind1)." unless ($ind1 eq $new_ind1);

		#report error if old is not exact for current
		push @errors_to_return, "Current field ($field_marc) is not exact match for old field ($orig_old)." unless ($field_marc eq $orig_old);

		#report changed headings unless current is exact match for new
		$has_changed = "new_".$orig_new unless ($field_marc eq $orig_new);
	} #if current field is an old heading
	return ($has_changed, \@errors_to_return);

} #identify_changed_names($field, \%heading_data)

###########################################
###########################################
###########################################


1;

#END{print "Press Enter to quit"; <>;}

=head1 VERSION HISTORY

Version 0.07--Updated May 8, 2010. Released Aug. 2, 2012

 -Revised identify_changed_hdgs($field, \%heading_data) to better deal with new headings that are shortened versions of old headings (for example, Tigers->Tiger). Still working out false hits vs. non-hits.

Version 0.06--Updated June 18, 2006. Released

 -Added subs for personal names--closed date reporting.

Version 0.05--Updated May 1, 2006. Released June 6, 2006.

 -Revised identify_changed_hdgs($field, \%heading_data, \%changed_hdgs_sub_a) attempting to resolve problem of closed dates vs. open.

Version 0.04--Updated Feb. 13, 2006. Unreleased

 -Modified identify_changed_hdgs($field, \%heading_data, \%changed_hdgs_sub_a) to not report headings where new and old are identical.
 --NEED TO STRIP ENDING PERIODS FOR MATCH TO WORK!!
 --Testing needed for sears heading changes--currently appears to fail to match

Version 0.03--Updated Aug. 3, 2005. Released Aug. 14, 2005.

 -Added as_hyphenated($sh_field) to break field into a string with dashes separating subfields.
 -Revised subs as needed.
 
Version 0.02--Updated Aug. 1, 2005.

 -Added ind_to_thesaurus($sh_field) to translate 2nd indicator into word form of thesaurus.

Version 0.01--Created July 6, 2005

 -Original version.

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that this code is not a product of or supported by the 
employers of the various contributors to the code.

=head1 AUTHOR

Bryan Baldus
eijabb [at] cpan [dot] org

Copyright (c) 2005-2012

=cut
