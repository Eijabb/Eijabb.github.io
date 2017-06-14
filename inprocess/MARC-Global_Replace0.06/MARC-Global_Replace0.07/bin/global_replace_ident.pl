#!perl

=head2

Global Replace Ident -- Identifies records with subject headings that have changed.

Currently limited to subfield 'a' (limit by MARC::Global_Replace).

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

print ("Welcome to Global Replace Identification script\n");

###########################################
###### File handling initialization #######
###########################################

#declare array to store file names
my @file_names = ();
#prompt for input file
my $inputfile_message = "What is the input file? (MARC) ";
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
my ($heading_data_ref, $errors_ref) = MARC::Global_Replace::read_changed_SH();
my %heading_data = %$heading_data_ref;
print join "\n", @$errors_ref, "\n" if @$errors_ref;

#get hash of subfield_a of changed headings
my ($changed_hdgs_sub_a_ref) = MARC::Global_Replace::make_sub_a_hdgs(\%heading_data);
my %changed_hdgs_sub_a = %$changed_hdgs_sub_a_ref;

#initialize $batch as new MARC::Batch object
my $batch = MARC::Batch->new('USMARC', "$inputfile");
########## Start extraction #########

############################################
# Set start time for main calculation loop #
############################################
my $t1 = [Time::HiRes::time()];
my $runningrecordcount=0;
###################################################

my $rec_with_changed_hdg_count = 0;
#set list of valid 6xx to check
my @fields6xx = ('600', '610', '611', '630', '650', '651', '655');
#### Start while loop through records in file #####
while (my $record = $batch->next()) {
###################################################
### add to count for user notification ###
$runningrecordcount++;
MARC::BBMARC::counting_print ($runningrecordcount);
###################################################
	my $controlno = $record->field('001')->as_string();
	my @errors_to_print = ();
	foreach my $field ($record->field(@fields6xx)) {
		my $has_changed = MARC::Global_Replace::identify_changed_hdgs($field, \%heading_data, \%changed_hdgs_sub_a);

		if ($has_changed) {

			my $cleaned_field = $field->MARC::File::MARCMaker::as_marcmaker();
			$cleaned_field =~ s/=([0-9][0-9][0-9]  ..)\$a(.+?)\n/$1\t$2/;
			push @errors_to_print, ("$cleaned_field\t$has_changed");
		} #if has_changed
	} #foreach field in marc record

	#report errors (changed headings)
	if (@errors_to_print) {
		print OUT join ("\t", $controlno, @errors_to_print), "\n";
		$rec_with_changed_hdg_count++;
	} #if changed

	
} # while

close $inputfile;
close OUT;

print "$rec_with_changed_hdg_count records changed\n$runningrecordcount records scanned\n";

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

Copyright (c) 2003-2005

=cut