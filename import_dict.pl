#!/usr/bin/perl

###################################
# Accepts text file arg.
# Places words into buckets based 
# on amount of occurrences. Populates
# as records in MySQL letter tables
###################################
use strict;
use warnings;
use DBI;
use Data::Dumper;

my $dict;
my $file = $ARGV[0];
my $word_count = 0;
my @words;
my %letters = (); # word : frequency

# track number of occurrences
sub hash_frequency {
	my @data = @_;
	foreach (@data) {
		$letters{ $_ } += 1;
	}
}

open($dict, "<$file") or die "Couldn't open $file, $!";

# add each word into a single array
print("Processing file\n");
while (<$dict>) {
	push( @words, split(' ', $_) );
}
close($dict);
$word_count = scalar @words;

$_ = lc for @words; # set each word to lowercase
hash_frequency(@words); # push to corresponding bucket

#print Dumper(\%letters);
print "\$word_count: $word_count\n";

# set up and verify MySQL connection
my $dbh = DBI->connect("DBI:mysql:dict", 'root', 'root');
if (!$dbh) {
	die "failed to connect to MySQL database DBI->errstr()";
} else {
	print("Connected to MySQL server successfully.\n");
}

# iterate through each letter container
foreach my $key (keys %letters) {
	my $first_char = substr($key, 0, 1);

	# prepared statement for populating letter tables
	my $sql = "INSERT INTO letter_$first_char(word, occurrences, dict_id, lang)
			   VALUES (?,?,?,?)";
}

$dbh->disconnect();

