#!/usr/bin/perl

###################################
# Accepts text file arg.
# Places words into buckets based 
# first character. Populates
# As records in MySQL letter tables
###################################
use strict;
use warnings;

use Data::Dumper;

my $dict;
my $file = $ARGV[0];
my $word_count = 0;
my @words;
my %letters = (); # letter : [word list]

# split data into buckets based 
# on first character
sub grep_push {
	my @data = @_;
	foreach (@data) {
		my $first_char = substr($_, 0, 1);
		push(
			@{ $letters{$first_char} },
			$_
		);
	}
}

open($dict, "<$file") or die "Couldn't open $file, $!";

 # add each word into a single array
while (<$dict>) {
	push( @words, split(' ', $_) );
}
close($dict);
$word_count = scalar @words;

$_ = lc for @words; # set each word to lowercase
grep_push(@words); # push to corresponding bucket

print Dumper(\%letters);
print "$word_count\n";
