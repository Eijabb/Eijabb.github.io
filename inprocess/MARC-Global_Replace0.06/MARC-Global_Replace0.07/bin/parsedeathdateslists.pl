#!perl

#my VERSION = 0.03;


=head2 NAME

Parse death date list -- Reads directory of HTML closed-date lists and parses into plain text old field, new field list.


=head2 DESCRIPTION

Reads folder of HTML files containing changed name headings and produces tab-delimited text file of the old and new headings. Attempts to remove diacritics by simple stripping of special entity characters. Subfield delimiter entities are replaced by "\x1F".

Attempts to extract old and new names from an HTML file of changed name headings. Produces a list of the form:

old_tag\told_ind1\told_name\tnew_tag\tnew_ind1\tnew_name

Each name includes subfield delimiter and code pairs using underscore as subfield delimiter.

Current version (eventually) will strip diacritics and attempts to convert characters to 7-bit ASCII. Produces a report of all diacritics stripped, for verification (in case something should not have been stripped). This report is currently supressed/not printed.

=head2 PROGRAMMING NOTES

The original #223 becomes &szlig; after decoding/encoding process (on Win and MacPerl). This should become \x1F (subfield delimiter) in finished field.

#161 becomes &iexcl;, and 'L' in the finished field.

#162 becomes &cent;, and 'O' in the finished field.

#163 becomes &pound;, and 'D' in the finished field.

#179 becomes &sup3;, and 'd' in the finished field.


=head2 VERSION HISTORY


Version 0.03: Updated Mar. 14, 2008.

-Improved handling of entitites. OCLC appears to have changed formats of character encoding at some point in the course of the weekly lists. Capitals seem to convert ok. Lower case letters with diacritics (built-in, like o-slash) may not convert correctly in all cases.
-Fixed problem with apostrophes being stripped during the HTML encoding process.

Version 0.02: Updated Aug. 20, 2006.

 -Converts &#161; to L, #163 to D, #179 to d, and #162 to O.
 -Changes '.htm' to '.txt' in cleaned filename.

Version 0.01: Updated June 26, 2006.

 -Added directory reading code from LCSHchangesparser.pl.
 -Revised/implemented diacritics stripping and conversion of subfield delimiter into "\x1F".


Initial versions unnumbered.

=cut

#initialize basic includes
use strict;
use warnings;

use HTML::TokeParser;
use HTML::Entities;
use MARC::BBMARC; #for time reporting
use IO::File;
use File::Temp;
use File::Find;
use File::Spec;

##########################
## Time coding routines ##
## Print start time and ##
## set start variable   ##
##########################

use Time::HiRes qw(  tv_interval );
# measure elapsed time 
my $t0 = [Time::HiRes::time()];
my $startingtime = MARC::BBMARC::startstop_time();
#########################
### Start main program ##
#########################

#######################################
### File Handling (revision needed) ###
#######################################
print ("Welcome to Parse Death Date Lists\n");
print <<DESCOFSCRIPT;
Parses HTML-based lists of closed date name authority records from OCLC.
The input files are UTF-8 encoded HTML stand-alone saves from the closed date archive.
Outputs are 1. A plain text file containing all names from all lists in the specified directory in the format:
old_tag \t old_ind1 \t old_hdg \t new_tag \t new_ind1 \t new_hdg \n
2. Separate files for each of the original files, in the same format as (1.).
Output files are stored in a 'cleaned' folder/directory within the originally provided directory.
DESCOFSCRIPT

##############################################
######### Directory manipulation #############
##############################################

#get directory name containing files to clean

print ("\nWhat is the input directory? (folder) ");
my $inputdir=<>;
chomp $inputdir;
#remove quotes from dropped in paths
$inputdir =~ s/^\"(.*)\"$/$1/;
my $root_dir = $inputdir;

#get an absolute path to the directory in case a relative path was passed, ignoring filename if one was passed
my $abs_path = File::Spec->rel2abs( $root_dir ) ;
$root_dir = $abs_path;
print "$abs_path absolute\n";
my @filestoclean;

#get list of text files in the directory to be cleaned
find( {wanted => \&process, follow=>0}, $root_dir);

sub process {

	my $cur_file = $File::Find::name;
	return unless (($File::Find::dir eq $root_dir) && (-f $cur_file && -T $cur_file && ($cur_file =~ /\.htm/)));
	push @filestoclean, $cur_file;

} # process

#make a new directory for cleaned files
my $cleandirname;
if (($^O eq 'MacOS') && ($root_dir =~ /:$/)) {$cleandirname = 'cleaned:';}
elsif (($^O eq 'MSWin32') && ($root_dir =~ /\\.*$/)) {$cleandirname = '\\cleaned\\';}
#elsif unix?--not yet tested
#elsif ($root_dir =~ /\/$/){$cleandirname = 'cleaned/';}
else {die "cleandirname could not be made, $!\n";}

my $cleaned_dir = $root_dir.$cleandirname;

mkdir $cleaned_dir, 0744;

my $allreplacedout = $cleaned_dir.'all.txt';
open (OUTALL, ">$allreplacedout") or die "cannot open $allreplacedout, $!\n"; 

#####may want bad heading output file later
#my $badhdg = $cleaned_dir.'bad.txt';
#open (BAD, ">$badhdg") or die "cannot open $badhdg, $!\n"; 
######

if ($^O eq 'MacOS') {
	MacPerl::SetFileInfo('R*ch', 'TEXT', $allreplacedout);
}#if MacOS

# @badheadingstoreturn will be used for printing the bad headings (for manual check)
#my @badheadingstoreturn = ();
#count for all headings
my $totalcount = 0;

############################################
# Set start time for main calculation loop #
############################################
my $t1 = [Time::HiRes::time()];
my $runningrecordcount=0;
###################################################

#####################
### Begin parsing ###
#####################

#declare array to store lines extracted from html
my %cleaned_headings_all = ();


foreach my $filetoclean (@filestoclean) {

	#get file name portion of path
	(my $volume, my $directories, my $filename) = File::Spec->splitpath( $filetoclean);

	#set final export file name and directory
	my $exportfile = $cleaned_dir.$filename;
	#change '.htm' to '.txt'
	$exportfile =~ s/\.htm$/.txt/;
	open(OUT, ">$exportfile")  or die "can not open out $exportfile, $!\n";
	if ($^O eq 'MacOS') {
		MacPerl::SetFileInfo('R*ch', 'TEXT', $exportfile);
	} #if MacPerl
	
	#declare array to store heading lines pre-cleaning
	my @heading_lines = ();

	my  $p = HTML::TokeParser->new($filetoclean);
	print "Parsing $filetoclean\n";

	while (my $token = $p->get_tag("p")) {
		my $controlno = $p->get_trimmed_text("br");
		my $encoded_controlno = HTML::Entities::encode($controlno);
		my $old_label = $p->get_trimmed_text("/b");
		my $encoded_old_label = HTML::Entities::encode($old_label);
		my $old_hdg = $p->get_trimmed_text("br");
		#preserve apostrophes by converting them to entities manually
		$old_hdg =~ s/\'/&#39;/g;
		my $encoded_old_hdg = HTML::Entities::encode($old_hdg);
print "$encoded_old_hdg was $old_hdg\n" if ($old_hdg =~ /rnulv/);
		my $new_label = $p->get_trimmed_text("/b");
		my $encoded_new_label = HTML::Entities::encode($new_label);
		my $new_hdg = $p->get_trimmed_text("p");
		#preserve apostrophes by converting them to entities manually
		$new_hdg =~ s/\'/&#39;/g;
		my $encoded_new_hdg = HTML::Entities::encode($new_hdg);

		if (($old_label =~ /old:/i) && ($new_label =~ /new:/i) && $old_hdg && $new_hdg) {

			push @heading_lines, "$encoded_old_hdg\t$encoded_new_hdg";
		} #if have old and new headings

###################################################
### add to count for user notification ###
	$runningrecordcount++;
	MARC::BBMARC::counting_print ($runningrecordcount);
###################################################

	} #while tags

	#declare hash to store cleaned headings
	my %cleaned_headings = ();

	#go through each heading line
	foreach my $heading_line (@heading_lines) {

		#strip diacritics
		my ($cleaned_line, $entities_ref) = strip_diacritics($heading_line);
		#deref array of cleaned entities if present
		my @stripped_entities =  @{$entities_ref};
		if (@stripped_entities) {
			print $heading_line, ": ", join "\t", @stripped_entities, "\n";
		} #if entities were stripped

		#parse cleaned line into desired format
#example: %cleaned_headings = ($old_hdg => {'old_tag' => $old_tag, 'old_ind1', 'new_tag' => $new_tag, 'new_ind1' => $new_ind1, 'new_hdg' => $new_hdg});
		##may want new_hdg => @new_hdgs
		my ($old_field, $new_field) = split "\t", $cleaned_line;
		my $old_tag = substr($old_field, 0, 3);
		my $old_ind1 = substr($old_field, 4, 1);
		my $old_hdg = substr($old_field, 6);
		my $new_tag = substr($new_field, 0, 3);
		my $new_ind1 = substr($new_field, 4, 1);
		my $new_hdg = substr($new_field, 6);
		unless (exists $cleaned_headings{$old_hdg}) {
			#add old heading and new to hash of headings
			$cleaned_headings{$old_hdg} = {'old_tag' => $old_tag, 'old_ind1' => $old_ind1, 'new_tag' => $new_tag, 'new_ind1' => $new_ind1, 'new_hdg' => $new_hdg};

		} #unless this old_hdg has been seen
		else {
			print $old_hdg, " has been seen already?\n";
		} #else duplicate heading
		#repeat for all files hash
		unless (exists $cleaned_headings_all{$old_hdg}) {
			#add old heading and new to hash of headings
			$cleaned_headings_all{$old_hdg} = {'old_tag' => $old_tag, 'old_ind1' => $old_ind1, 'new_tag' => $new_tag, 'new_ind1' => $new_ind1, 'new_hdg' => $new_hdg};
		} #unless this old_hdg has been seen
		else {
			print $old_hdg, "\thas been seen already?\n";
		} #else duplicate heading
	
	} #foreach heading line

	#print results for this file
	foreach my $old_heading (sort keys (%cleaned_headings)) {
		print OUT (join "\t", (
			$cleaned_headings{$old_heading}{'old_tag'},
			$cleaned_headings{$old_heading}{'old_ind1'},
			$old_heading,
			$cleaned_headings{$old_heading}{'new_tag'},
			$cleaned_headings{$old_heading}{'new_ind1'},
			$cleaned_headings{$old_heading}{'new_hdg'})),
			"\n";
	} #foreach old heading
	close OUT;
	print "$runningrecordcount records parsed\n";
} #foreach file to parse

#print to file of all headings
foreach my $old_heading (sort keys (%cleaned_headings_all)) {
	print OUTALL (join "\t", (
		$cleaned_headings_all{$old_heading}{'old_tag'},
		$cleaned_headings_all{$old_heading}{'old_ind1'},
		#add double tab between old and new
		$old_heading,
		$cleaned_headings_all{$old_heading}{'new_tag'},
		$cleaned_headings_all{$old_heading}{'new_ind1'},
		$cleaned_headings_all{$old_heading}{'new_hdg'})),
		"\n";
	$totalcount++
} #foreach heading in all files

print "$totalcount headings output.\n";

close OUTALL;

####################

sub strip_diacritics {
	my $heading_line = shift;
	my $cleaned_line = '';
	
	$cleaned_line = $heading_line;
	#convert subfield code entities to hex 1F character
	$cleaned_line =~ s/(\&szlig;)|(\&#8225;)|(\&Atilde;\&#159;)|(\&Dagger;)/\x1F/g;

	#convert apostrophe encodings back to apostrophe character
	$cleaned_line =~ s/\&amp;#39;/'/g;

	#convert certain entities into appropriate [a-zA-z] character
	#O with slash through
	$cleaned_line =~ s/(\&cent;)|(\&#216;)|(\&Oslash;)/O/g;
	#o with slash through
	$cleaned_line =~ s/\&oslash;/o/g;
	#D with slash
	$cleaned_line =~ s/(\&pound;)|(\&ETH;)/D/g;
	#d with slash
	$cleaned_line =~ s/(\&sup3;)|(\&eth)/d/g;
	#L with slash
	$cleaned_line =~ s/\&iexcl;/L/g;
	
	#capture remaining entities for reporting
	my @entities = $cleaned_line =~ /\&[^\;\&]+;/g;

	#strip remaining entities
	$cleaned_line =~ s/\&[^\;]+;//g;
	
	#close up space on either side of the subfield code
	$cleaned_line =~ s/ (\x1F.) /$1/g;

	
	return ($cleaned_line, \@entities);
}

########################

##########################
### Main program done.  ##
### Report elapsed time.##
##########################

my $elapsed = tv_interval ($t0);
my $calcelapsed = tv_interval ($t1);
print sprintf ("%.4f %s\n", "$elapsed", "seconds from execution\n");
print sprintf ("%.4f %s\n", "$calcelapsed", "seconds to calculate\n");
my $endingtime = MARC::BBMARC::startstop_time();
print "Started at $startingtime\nEnded at $endingtime";

print "Press Enter to continue";
<>;

#####################
### END OF PROGRAM ##
#####################

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that this code is not a product of or supported by the 
employers of the various contributors to the code.

=head1 AUTHOR

Bryan Baldus
eija [at] inwave [dot] com

Copyright (c) 2006-2008

=cut