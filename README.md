# Dictionary-Full-Stack
Full stack project work-in-progress. 

### MySQL Schema
```
create table dict_list
(
id INT unsigned NOT NULL AUTO_INCREMENT,
name VARCHAR(150),
length INT unsigned,
lang VARCHAR(150) NOT NULL,
path VARCHAR(150) NOT NULL,
PRIMARY KEY (id)
);

create table letter_a
(
word_id INT unsigned NOT NULL AUTO_INCREMENT,
word VARCHAR(150) NOT NULL,
occurrences INT unsigned NOT NULL,
dict_id INT unsigned NOT NULL,
lang VARCHAR(150) NOT NULL,
PRIMARY KEY (word_id),
FOREIGN KEY (dict_id) REFERENCES dict_list(id) ON DELETE CASCADE
);
```

`perl import_dict.pl <file_name> <name> <language>` accepts 3 arguments describing a dictionary and inserts words into an associated letters hash which uses prepared statements to efficiently and safely update the database.
