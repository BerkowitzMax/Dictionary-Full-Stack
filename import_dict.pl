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
my %letters = ();

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
while (<$dict>) {
	my @line_splitter = split(' ', $_); # break line of words into array
	$_ = lc for @line_splitter; # set each word to lowercase

	grep_push(@line_splitter); # push to corresponding bucket

	$word_count += scalar @line_splitter; # track number of words in file
}
close($dict);

print Dumper(\%letters);
print "$word_count\n";
