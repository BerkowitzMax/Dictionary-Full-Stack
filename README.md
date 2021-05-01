# Dictionary-Full-Stack
Full stack project work-in-progress. 

### MySQL Schema
```
create table dict_list
(
id INT unsigned NOT NULL AUTO_INCREMENT,
name VARCHAR(150),
length INT unsigned NOT NULL,
lang VARCHAR(150) NOT NULL,
path VARCHAR(150) NOT NULL,
PRIMARY KEY (id)
);

create table letter_a
(
word_id INT unsigned NOT NULL AUTO_INCREMENT,
word VARCHAR(150) NOT NULL,
length INT unsigned NOT NULL,
dict_id INT unsigned NOT NULL,
lang VARCHAR(150) NOT NULL,
PRIMARY KEY (word_id),
FOREIGN KEY (dict_id) REFERENCES dict_list(id)
);
```

`perl import_dict.pl file.txt` accepts file.txt arg and inserts the words into an associated letters hash which uses parameterized queries to update the database.
