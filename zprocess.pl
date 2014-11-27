#!/usr/bin/perl
#use strict;

use List::Util qw(first);
#print "Supply the source file/directory containing test files:(including the / at the end)";
#$srcName = <>;
#print "$srcName";
#my $srcName = '/home/prabhat/Desktop/Taggerfinal/test/';
##################################################################################
# This is the first part of the whole process and is to be performed before any  #
# other task is performed.										 ##################################################################################

##################################################################################
# When we used the Stanford NER, we observed that it works better when there are #
# dots after the initial names. Take an example, it recognizes 'Lee S.K.' as a   #
# name but fails on 'Lee S K'. So, we use this script as a preprocessing tool    #
# to add dots after the capital letters. These may occur as SK, S K etc. This    #
# also helps in improving the performance of the journal name detector. This take#
# -s a .csv file as input. The file should only be named as .csv but it can by   #
# text file that needs the extraction to be performed. It has to be noted that it#
# doesn't affect the processing of the numerical part.				 #
##################################################################################
my @files = <@ARGV>;
 
my $count = 1 ;
foreach my $file ( @files)
{
	if ($file =~ m/stage1\/(.*)\.csv$/)
	{	
		my $id = $1;
		open (MYFILE, ">copy$id.csv");
		open(FILE, $file) or die "can't open the file: $_!";
		while(<FILE>)
		{	
			chomp $_ ;
			$_ =~ s/([A-Z])/$1\./g;
			$_ =~ s/\.([a-z])/$1/g;
			$_ =~ s/\.{2,}/\./g;
			print MYFILE "$_\n";
		}
		close (MYFILE); 
		unlink $file;
	}
	
	$count++;
}
