#!/usr/bin/perl
use File::Basename;
use strict;
##########################################################################
# Create samples from an image applying distortions repeatedly 
# (create many many samples from many images applying distortions)
#
#  perl createtrainsamples.pl <positives.dat> <negatives.dat> <vec_output_dir>
#  ex) perl createtrainsamples.pl positives.dat negatives.dat samples
#
# Author: Naotoshi Seo
# Date  : 06/02/2007
# Date  : 03/12/2006
#########################################################################
my $cmd = './createsamples.exe -w 20 -h 20 -maxxangle 0.6 -maxyangle 0 -maxzangle 0.3 -maxidev 100 -bgcolor 0 -bgthresh 0';
my $totalnum = 7000;
my $tmpfile  = 'tmp';

if ($#ARGV < 2) {
    print "Usage: perl createtrainsamples.pl\n";
    print "  <positives_collection_file_name>\n";
    print "  <negatives_collection_file_name>\n";
    print "  <output_dir_name>\n";
    exit;
}
my $positive  = $ARGV[0];
my $negative  = $ARGV[1];
my $outputdir = $ARGV[2];

open(POSITIVE, "< $positive");
my @positives = <POSITIVE>;
close(POSITIVE);

open(NEGATIVE, "< $negative");
my @negatives = <NEGATIVE>;
close(NEGATIVE);

# number of generated images from one image so that total will be $totalnum
my $num = int($totalnum / $#positives + .5);

# Get the directory name of positives
my $first = $positives[0];
my $last  = $positives[$#positives];
while ($first ne $last) {
    $first = dirname($first);
    $last  = dirname($last);
    if ( $first eq "" ) { last; }
}
my $imgdir = $first;
my $imgdirlen = length($first);

foreach my $img (@positives) {
    # Pick up negative images randomly
    my @localnegatives = ();
    for (my $i = 0; $i < $num; $i++) {
        my $ind = int(rand($#negatives));
        push(@localnegatives, $negatives[$ind]);
    }
    open(TMP, "> $tmpfile");
    print TMP @localnegatives;
    close(TMP);
    #system("cat $tmpfile");

    !chomp($img);
    my $vec = $outputdir . substr($img, $imgdirlen) . ".vec" ;
    print "$cmd -img $img -bg $tmpfile -vec $vec -num $num" . "\n";
    system("$cmd -img $img -bg $tmpfile -vec $vec -num $num");
}
unlink($tmpfile);
