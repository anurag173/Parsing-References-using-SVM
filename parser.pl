#!/usr/bin/perl
#use strict;
use warnings;
use List::Util qw(first);

##############################################################################
# This script takes the original reference file as input and prepares it for #
# processing in libSVM. It extracts all numbers along with the punctuations  #
# following and preceding the number(if there are none, then space is used as#
# a punctuation).  
# Then, it deletes everything that we don't need like alphabets. This step is#
# required as libSVM works only with numbers. So we use the two punctuations #
# to map the number into a 3 dimensional space where first co-ordinate is the#
# preceding punctuation, second co-ordinate is the number itself and third is#
# the following punctuation. All the numbers are divided by 1000 as libSVM   #
# optimization algorithm works best in the range of [-1,1]. If large numbers #
# are used the optimization algorithm may not converge.                      #
# Here are the replaced numbers for the punctuations.			 #
#           Punctuation          Replaced by				 #
#				:				0.250									 #
#               ;                   0.250									 #
#          page/pg/pp/p             0.750									 #
#             -/–/–        			1.500									 #
# 		Vol/vol/ed/volume			0.900            #
#                ,                  1.000									 #
#                (                  1.100                		 #
#                )                  1.200                                    #
#           suppl/Suppl             1.300                                    #
# We have used the Gaussian kernel in libSVM which maps these 3D-points into #
# infinite dimensional space to classify these points.			 #
##############################################################################

#my @files = </home/prabhat/Desktop/Taggerfinal/stage2/*>;
my @files = <@ARGV>;
foreach my $file ( @files) 			# pick a file from directory
{	 
   if ($file =~ m/stage2\/(.*)\.csv$/)          # if it's a csv file
   {
	# to extract basename of file
	my $id = $1;	
	# outputfile should be trainbasename			
	open (MYFILE, ">train$id.csv");		
        # open the csv file
	open (FILE, "<$file") or die "Can't open $file: $_\n";
	# open temporary file to remove special characters from this csv file
	open (WRFILE, ">spchar$id.csv") or die "Can't open spchar$id.csv: $_\n";
	# store entire file text in single variable, $text
	my $text= do { local $/; <FILE> };
	my @arr = split("\n", $text);
	# removing special characters
	for ( @arr ) {	   s/[^\w\d\.\,\;\s\:\-\–\–\(\)\/]//g	;	}
	print WRFILE "@arr";
	close (WRFILE);
	close (FILE);
	# use new file without special characters for further 
	open (WRFILE, "<spchar$id.csv") or die "Can't open spchar$id.csv";
	while ( <WRFILE> )                      
	{
	    chomp $_ ;
	    # replacements in a single line                          
	    $_ =~ s/\013//g;$_ =~ s/\:/ \: /g; $_ =~ s/\;/ \; /g;$_ =~ s/page/ page /g;$_ =~ s/pg/ pg /g;
	    $_ =~ s/\-/ \- /g;$_ =~ s/\–/ \– /g;$_ =~ s/Vol/ Vol /g;$_ =~ s/volume/ volume /g;
	    $_ =~ s/ed/ ed /g;$_ =~ s/,/ , /g;$_ =~ s/\(/ \( /g;$_ =~ s/\)/ \) /g;
	    $_ =~ s/Suppl/ Suppl /g; $_ =~ s/pp/ pp /g; $_ =~ s/p/ p /g;
	
	    $_ =~ s/\b(dummy|final|page|pg|Vol|volume|ed|Suppl|suppl|pp|p)\b|[^\d\.\,\;\s\:\-\–\–\(\)]/$1 if defined $1/eg;
	    # removing indexes, assuming each ref ends with dot and there are only integer numbers involved
	    $_ =~ s/(\d)\.\d+\./$1 /g;        
	    # when there's no dot immediately after the index    
	    $_ =~ s/(\d)\.\d+/$1 /g;             
	    $_ =~ s/\./ \. /g;
	    my @data = split(" ", $_); 
	    # @index stores the numeric entries of @data  	 
	    my $k=0; my @index; my $i=0;                                    
	    for($i = 0; $i <= $#data; $i++)
	    {			                # loop to copy numeric entries of @data into @index 
		if ($data[$i]=~ /\d/) 
	             { $index[$k]=$i ; $k++ ; } 	
	    }
            my $s = "dummy"; 		        # $s will contain lines with 3 entries separated 					        	# by "," and lines separated by "\n" 
            $k=0;                               # reset k

	    if($#index==0) { $s=$s." .3 ".$data[1]/1000.0." .3" ; }
	    else {
         	     for($i = $index[$k];$i <= $index[$#index-1]; $i=$index[++$k])
		     {
  			if(($i > 0) && ($data[$i - 1] =~ /\D/)) 
			{$s = $s." "."$data[$i - 1]"." ".$data[$i]/1000.;}
			else 
			{ $s = $s." .3 ".$data[$i]/1000.; }
			if($data[$i + 1] =~ /\D/) 
			{$s = $s." "."$data[$i + 1]";}
			else 
			{ $s = $s." .3"; }
			if($i==$index[$#index-1]) 
			{ $s=$s."\ndummy"." "."$data[$index[$#index]-1]"." ".$data[$index[$#index]]/1000.0." ".".3" ;}
			if($i<$index[$#index-1]) {$s = $s."\ndummy";}
			}
		}
		#print "$s";			# check if $s is correct
		chomp $s;
		#$_ =~ s/\013//g;               # now replace punctuations by numbers
		$s =~ s/\:/.250/g;$s =~ s/\;/.5/g; 
		$s =~ s/ page /.75/g;$s =~ s/ pg /.75/g;$s =~ s/\-/1.5/g;$s =~ s/\–/1.5/g;
		$s =~ s/ \– /1.5/g;$s =~ s/Vol/.9/g;$s =~ s/volume/.9/g;$s =~ s/ed/.9/g;
		$s =~ s/\,/1/g;$s =~ s/\(/1.1/g;$s =~ s/\)/1.2/g;$s =~ s/Suppl/1.3/g;
	$s =~ s/pp/.75/g;$s =~ s/\bp\b/.75/g;$s =~ s/ /\,/g;$s =~ s/\,\.\,/\,0.7\,/g;
	$s=~ s/\,\.\n/\,0.7\n/g;
	
		print MYFILE "$s\n";
	 
	}
	close (MYFILE); 
	unlink "spchar$id.csv";
	}
}
	__END__
