#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(first);
use autodie;
use File::Basename 'basename';
use List::MoreUtils qw(firstidx);

my @tags = qw/ none Year StartPg EndPg Volume none SubVolume /;
#my @files = </home/prabhat/Desktop/Taggerfinal/stage1/*>;
my @files = <@ARGV>;
my $tag;my $basename=0; my $str; my $lines;my @arr;my $item;
for my $file ( @files) 			 # pick a file from directory
{	 
   if ($file =~ m/stage1\/(.*)\.csv\.xml$/)            #if it's an xml file
   {
	open (FH,$file) or die "Can't open file $!";
	$lines=""; $lines = do { local $/; <FH> };
	# insert spaces so that $lines can be parsed into array
    $lines =~ s/\:/ \: /g; $lines =~ s/\;/ \; /g; $lines =~ s/\-/ \- /g;  $lines =~ s/\–/ \– /g;
	$lines =~s/\,/ \, /g;  $lines =~ s/\(/ \( /g; $lines =~ s/\)/ \) /g;  $lines =~ s/\</ \< /g;
	$lines =~s/\"/ \" /g;  $lines =~ s/(\d+)/ $1 /g; $lines =~ s/\>/ \> /g; $lines =~ s/\// \/ /g; 
	$lines =~ s/\./ \. /g;
	# convert string to array
	@arr=(''); @arr = split(" ",$lines);      
	# remove everything before and including 'copy'
	# remove everything after 1st dot (.csv.xml)
	$basename = $file ;$basename=~ s/.*copy//g; $basename =~ s/\..*//g;                         
    open (MYFILE, ">tagged$basename.xml");	
	# get no.s (yr/vol/pgs etc.) and their tags from these files	              
	open (FILE, "<outtrain$basename");    
        while(<FILE>)
	{	
		# find tag and num (see outtrain file, 1st no. is tag)
		next unless / (\d) \s+ dummy , (\d*\.*\d*) , (\d*\.*\d*) /x;
		# no.(yr/vol/pg etc.) to be searched and tagged in xml file
		my $num = $3 * 1000;
        my $tag = $tags[$1];
        # $check ensures only 1st
        my $check=0;
        for $item (@arr) 
          { 
	    if (   ($item eq $num) && ($check eq 0)   ) 
		{ my $index = firstidx { $_ eq $item } @arr ;
		  if ($arr[$index - 1] ne "\.")
        	    {  $item = qq{<$tag>$item</$tag>} ;
		       $check=1; 
		    }
		  else { $item = qq{<index>$item</index>} ; }
		}
	  }
	}
	$str = join(" ",@arr);
    $str=~ s/\< \//\<\//g; $str =~ s/ PERSON /PERSON/g; $str =~ s/ ORGANIZATION /ORGANIZATION/g;
	$str =~ s/ LOCATION /LOCATION/g; $str =~ s/ MISC /MISC/g;
	print MYFILE "$str";$lines=();
	close (MYFILE); close(FILE); close(FH);
    }
}
__END__
