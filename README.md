# Welcome to My Sqlite

## Task

The application replicates certain SQL commands: SELECT, UPDATE, INSERT and DELETE. The tables accessed are contained in CSV format.

*my_sqlite_request.rb* accesses CSV files and *my_sqlite.cli.rb* manages a command line interface.

## Description

### *my_sqlite_request.rb*

The code consists of a single class called *MySqliteRequest*. After the class is initialized, a series of methods within the class are called with each method corresponding to SQL operators (SELECT, FROM, WHERE, etc.). Examples are further below.

### *my_sqlite.cli.rb*

The code also consists of a single class called *CLI*. The code initianalizses the class which in turn initializes the class *MySqliteRequest* within *my_sqlite_request.rb*. *CLI* will parse user inputs such as "SELECT name, year_start, college FROM nba_player_data.csv;". Examples are further below.

### Conceptual Code Architecture

The CRUD state largely determines the sequence of methods: CREATE = INSERT, READ = SELECT, UPDATE = UPDATE, DELETE = DELETE. Methods are shared between CRUD states where possible. Note: CRUD states refer to records within a table and not the table itself.

Some instance variables are declared upon intitialization of the class. However, instance variables are largely declared when required by the specific methods being called in order to improve efficiency. The reason for not declaring all instance variables upon initialization is because of the four distinct CRUD states which organize the code.

## Video Demonstration

See link below:

<a href="https://youtu.be/_YpnY-UPNKg" target="_blank">
   <img src="https://github.com/junaidalam2/MySqlite/blob/main/videoThumbnail.jpg">
</a>

## Tech Stack

- Ruby
  - Gems:
    - csv

## Installation

Installation of Ruby is required. The application uses the csv gem which is already included within Ruby. Ruby operates on a standard IDE.

## Usage

### SQL Operators and Clauses

-*SELECT*\
-*INSERT* or *INSERT INTO*\
-*UPDATE*\
-*DELETE*\
-*FROM*\
-*WHERE*\
-*JOIN*\
-*ORDER BY*\
-*VALUES*\
-*SET*\
-*AND*\
-*DESC*\
-*ASC*\
-*ON*

### Limitations

-*INSERT* must be used with the *VALUES* operator.\
-*JOIN* is limted to inner join among two tables with primary keys. If the joined tables have columns with duplicate names, '_1' is appended to the duplicate column name.\
-*UPDATE* must be used with the *WHERE* operator unlike SQL.  

### *my_sqlite_request.rb*: Mapping of Methods to Operators & Clauses

-*SELECT*: select([column_name1, column_name2, column_name3, ...]) or select('*')\
-*INSERT* or *INSERT INTO*: insert(file_name)\
-*UPDATE*: update(file_name)\
-*DELETE*: delete(file_name)\
-*FROM*: from(file_name) [Note: the file path *csv_files/* is a class variable and not required to be inputted by the user.]\
-*WHERE*: where(column_name, value)\
-*JOIN* with *ON*: join(left_table_column_name, right_table_name, right_table_column_name)\
-*ORDER BY*: order(*ASC*/*DESC*, column_name)\
-*VALUES*: values(hash_of_column_names_and_values)\
-*SET*: set(hash_of_column_names_and_values)

### Examples of User Inputs In *my_sqlite.cli.rb* Being Mapped to Methods in *my_sqlite_request.rb*

1 - User Input -> "SELECT name FROM nba_player_data.csv WHERE college = 'Duke University';":

request = MySqliteRequest.new\
request = request.from('nba_player_data.csv')\
request = request.select('name')\
request = request.where('college', 'Duke University')\
request.run

2 - User Input -> "UPDATE nba_player_data.csv SET year_end = '5023', 'position' = 'C' WHERE name = 'Alaa Abdelnaby';":

request = MySqliteRequest.new\
request = request.update('nba_player_data.csv')\
request = request.set({'year_end' => 5023, 'position' => 'C'})\
request = request.where('name', 'Alaa Abdelnaby')\
request.run

3 - User Input -> "SELECT name, year_start, college, year_end, position FROM nba_player_data.csv WHERE college = 'Duke University' AND year_start = '2014';":

request = MySqliteRequest.new\
request = request.from('nba_player_data.csv')\
request = request.select(['name', 'year_start', 'college', 'year_end', 'position'])\
request = request.where('year_start', '2014')\
request = request.where('college', 'Duke University)\
request.run

4 - User Input -> "DELETE FROM 'nba_player_data.csv' WHERE name = 'Alaa Abdelnaby';":

request = MySqliteRequest.new\
request = request.delete('nba_player_data.csv')\
request = request.where('name', 'Alaa Abdelnaby')\
request.run

5 - User Input -> "INSERT INTO 'nba_player_data.csv' VALUES ('name_CLI', 2022, 2023, 'position1', '10-4', 300, 'July 21, 2021', 'college1');":

request = MySqliteRequest.new\
request = request.insert('nba_player_data.csv')\
request = request.values({'name' => 'name_CLI', 'year_start' => 2022, 'year_end' => 2023, 'position' => 'position1', 'height' => '10-4', 'weight' => 300, 'birth_date' => 'July 21, 2021', 'college' => 'college1'})\
request.run

6 - User Input -> "SELECT name, year_start, college FROM 'nba_player_data.csv' JOIN 'nba_players.csv' ON name = Player WHERE 'year_start' = '1969' ORDER BY college DESC;"

request = MySqliteRequest.new\
request = request.from('nba_player_data.csv')\
request = request.select(['name', 'year_start', 'college'])\
request = request.join('name', 'nba_players.csv', 'Player')\
request = request.where('year_start', '1969')\
request = request.order('DESC', 'college')\
request.run

## Test Data - CSV Files

The application can be used on csv files containing data with headers. There are five files included in the subfolder *csv_files*:

1. *nba_player_data_multiple_wherev1.csv* - sames as *nba_player_data.csv* but used for unit tests for which the WHERE operator includes multiple columns and the UPDATE operator is used
2. *nba_player_data.csv* - original data
3. *nba_players.csv* - original data
4. *test_insert_v1.csv* - sames as *nba_player_data.csv* but used for unit tests for the INSERT operator
5. *test_write_v1.csv* - sames as *nba_player_data.csv* but used for unit tests for the UPDATE and DELETE operators

## Author

- [@junaidalam2](https://github.com/junaidalam2)

## Support

For support, email junaid.alam2@gmail.com.
