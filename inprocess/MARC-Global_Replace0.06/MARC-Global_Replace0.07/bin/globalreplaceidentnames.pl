#!perl

=head2

Global Replace Identification Names --  Identifies records with personal name headings that have changed.

=cut

###########################
### Initialize includes ###
### and basic needs     ###
###########################
use strict;
use warnings;
use MARC::Batch;
use MARC::BBMARC;
use MARC::Global_Replace;
use MARC::File::MARCMaker;

#MARC::QBI::Misc for file name input (and overwrite protection)
use MARC::QBI::Misc;

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

print ("Welcome to Global Replace Names Identification script\n");

###########################################
###### File handling initialization #######
###########################################

#declare array to store file names
my @file_names = ();
#prompt for input file
my $inputfile_message = "What is the input file? (MRC) ";
#call get_file_name for the input file
my ($inputfile, $error) = MARC::QBI::Misc::get_file_name($inputfile_message, '<');
die "Error with input file name" if $error;
push @file_names, $inputfile if $inputfile;

my $outputfile_message = "What is the export file? (TXT) ";
my ($exportfile, $error2) = MARC::QBI::Misc::get_file_name($outputfile_message, '>', \@file_names);
die "Error with export file name" if $error2;
push @file_names, $exportfile if $exportfile;

open(OUT, ">$exportfile") or die "Can not open $exportfile, $!";

#if using MacPerl, set creator and type to BBEdit and Text
if ($^O eq 'MacOS') {
MacPerl::SetFileInfo('R*ch', 'TEXT', $exportfile);
}
###########################################
#### End File handling initialization #####
###########################################

#retrieve changed heading data
###will prompt for file
my ($heading_data_ref, $errors_ref) = MARC::Global_Replace::read_changed_names();
my %heading_data = %$heading_data_ref;
print join "\n", @$errors_ref, "\n" if @$errors_ref;

#initialize $batch as new MARC::Batch object
my $batch = MARC::Batch->new('USMARC', "$inputfile");

############################################
# Set start time for main calculation loop #
############################################
my $t1 = [Time::HiRes::time()];
my $runningrecordcount=0;
###################################################
my $field_changed_count = 0;
my $rec_with_changed_hdg_count = 0;

#### Start while loop through records in file #####
while (my $record = $batch->next()) {
###################################################
### add to count for user notification ###
$runningrecordcount++;
MARC::BBMARC::counting_print ($runningrecordcount);
###################################################
	my @errors_to_print = ();

	my $controlno = $record->field('001')->as_string() if $record->field('001');

	my @tags_to_check = ('100', '600', '700', '800');
	foreach my $field ($record->field(@tags_to_check)) {
		my ($has_changed, $errs_ref) = MARC::Global_Replace::identify_changed_names($field, \%heading_data);

		#report non-change related errors
		if (@$errs_ref) {
			push @errors_to_print, (join "\t", @$errs_ref);
		} #if non-change errors
		
		if ($has_changed) {
			my $cleaned_field = $field->MARC::File::MARCMaker::as_marcmaker();
			$cleaned_field =~ s/=([0-9][0-9][0-9]  ..)\$a(.+?)\n/$1\t$2/;
			push @errors_to_print, ("$cleaned_field\t$has_changed");
			$field_changed_count++;
		} #if changed
	} #foreach name field

	#report errors (changed headings)
	if (@errors_to_print) {
		print OUT join ("\t", $controlno, @errors_to_print), "\n";
		$rec_with_changed_hdg_count++;
	} #if changed

} # while

print "$rec_with_changed_hdg_count records changed\n$field_changed_count fields changed\n$runningrecordcount records scanned\n";

close $inputfile;
close OUT;

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


END{print "\nPress Enter to quit"; <>;}


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

Copyright (c) 2003-2006

=cut