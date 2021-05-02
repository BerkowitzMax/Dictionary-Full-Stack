#!/usr/bin/perl

# ARGS: <file> <dictionary_id>

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

die "Arguments are <file_name> <dictionary_id>" unless(scalar @ARGV == 2);

my $dict;
my $file = $ARGV[0];
my $dict_ID = $ARGV[1];
my $lang;
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
print("Processing file...\n");
while (<$dict>) {
	push( @words, split(' ', $_) );
}
close($dict);
$word_count = scalar @words;

$_ = lc for @words; # set each word to lowercase
hash_frequency(@words); # push to corresponding bucket

#print Dumper(\%letters);

# set up and verify MySQL connection
my $dbh = DBI->connect("DBI:mysql:dict", 'root', 'root');
if (!$dbh) {
	die "failed to connect to MySQL database DBI->errstr()";
} else {
	print("Connected to MySQL server successfully.\n");
}

# fetch language of current dictionary
my $sql = "SELECT lang FROM dict_list WHERE id = ?";
my $sth = $dbh->prepare($sql);
$sth->execute($dict_ID);
while(my @row = $sth->fetchrow_array()) {
	$lang = $row[0];
}
$sth->finish();
print("Language set to $lang.\n");

# update length of file
my $sql = "UPDATE dict_list SET length = ? WHERE id = ?";
my $sth = $dbh->prepare($sql);
$sth->execute($word_count, $dict_ID);
$sth->finish();
print ("Number of words in file: $word_count\n");

# iterate through each letter container
foreach my $key (keys %letters) {
	my $first_char = substr($key, 0, 1);
	my $num_occur = $letters{ $key };

	# prepared statement for populating letter tables
	my $sql = "INSERT INTO letter_$first_char(word, occurrences, dict_id, lang)
			   VALUES (?,?,?,?)";
}

$dbh->disconnect();

