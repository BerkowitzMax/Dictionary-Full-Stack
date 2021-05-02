#!/usr/bin/perl

# ARGS: <file_name> <name> <language>

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

die "Arguments are <file_name> <name> <language>" unless(scalar @ARGV == 3);

my $dict;
my $file = $ARGV[0];
my $dict_ID;
my $lang = $ARGV[2];
my $word_count = 0;
my @words;
my %letters = (); # word : frequency

# set up and verify MySQL connection
my $dbh = DBI->connect("DBI:mysql:dict", 'root', 'root');
if (!$dbh) {
	die "failed to connect to MySQL database DBI->errstr()";
} else {
	print("Connected to MySQL server successfully.\n");
}

# verify file has not already been read
my $sth = $dbh->prepare(q/SELECT EXISTS(SELECT * FROM dict_list WHERE name = ?)/);
$sth->execute($ARGV[1]);
die "Input file has already been parsed.\n" unless(!$sth->fetch()->[0]);


# initialize dictionary, fetch ID
$sth = $dbh->prepare(q/INSERT INTO dict_list(name, lang, path)
						  VALUES (?,?,?)/);
$sth->execute($ARGV[1], $ARGV[2], $file) || die "Initialization failed: DBI->errstr()";
$sth = $dbh->prepare(q/SELECT id FROM dict_list WHERE name = ?/);
$sth->execute($ARGV[1]);
while(my @row = $sth->fetchrow_array()) {
	$dict_ID = $row[0];
}

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
print("Language set to $lang.\n");

# update length of file
$sth = $dbh->prepare(q/UPDATE dict_list SET length = ? WHERE id = ?/);
$sth->execute($word_count, $dict_ID);
print("Number of words in file: $word_count\n");

# iterate through each letter container
print("Successful insert [");
foreach my $key (keys %letters) {
	my $first_char = substr($key, 0, 1);
	my $num_occur = $letters{ $key };

	# prepared statement for populating letter tables
	$sth = $dbh->prepare(
				q/INSERT INTO letter_/.$first_char.q/(word, occurrences, dict_id, lang)
			     VALUES (?,?,?,?)/);
	if ($sth->execute($key, $num_occur, $dict_ID, $lang)) {
		print(".");
	}
}

$sth->finish();
print("]\n");
$dbh->disconnect();

print("Read completed.\n");
