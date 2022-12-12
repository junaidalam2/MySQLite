require_relative 'my_sqlite_request.rb'


# UNIT TESTS - my_sqlite_cli.rb
class CLI_Unit_Test
    @@user_input_unit_test_hash = {
        0 => "INSERT INTO test_insert_v1.csv VALUES ('name_CLI', 2022, 2023, 'position1', '10-4', 300, 'July 21, 2021', 'college1');",
        1 => "SELECT * FROM nba_player_data.csv;",
        2 => "SELECT name FROM nba_player_data.csv;",
        3 => "SELECT name, year_start, college FROM nba_player_data.csv;",
        4 => "SELECT name, year_start, college FROM nba_player_data.csv WHERE year_start = '1990';",
        5 => "sElEct name, year_start, college FROM nba_player_data.csv WHERE name = 'Alaa Abdelnaby';",
        6 => "UPDATE test_write_v1.csv SET year_end = '4023', 'year_start' = '1991' WHERE position = 'position@';",
        7 => "UPDATE test_write_v1.csv SET year_end = '5023', 'year_start' = '2023' WHERE name = 'Alaa Abdelnaby';",
        8 => "UPDATE test_write_v1.csv SET year_end = '5023', 'year_start' = '2023' WHERE name = 'name3';",
        9 => "DELETE FROM 'test_write_v1.csv' WHERE name = 'name2';",
        10 => "SELECT * FROM 'nba_player_data.csv' JOIN 'nba_players.csv' ON name = Player WHERE weight = 240;",
        11 => "SELECT * FROM 'nba_player_data.csv' JOIN 'nba_players.csv' ON name = Player WHERE 'year_start' = '1969' ORDER BY college DESC;",
        12 => "SELECT * FROM 'nba_player_data.csv' JOIN 'nba_players.csv' ON name = Player WHERE 'year_start' = '1969' ORDER BY college;",
        13 => "SELECT * FROM 'nba_player_data.csv' JOIN 'nba_players.csv' ON name = Player WHERE 'year_start' = '1969' ORDER BY college ASC;",
        14 => "SELECT name, year_start, college FROM 'nba_player_data.csv' JOIN 'nba_players.csv' ON name = Player WHERE 'year_start' = '1969' ORDER BY college ASC;",
        15 => "SELECT 'name', 'year_start', 'college', 'year_end', 'position' FROM nba_player_data.csv WHERE year_start = '2014' AND 'college' = 'Duke University';"
    }

    def self.unit_test
        @@user_input_unit_test_hash
    end
end


# UNIT TESTS - my_sqlite_request.rb
def request_unit_test(unit_test_number)

    case unit_test_number
    when 0
        request = MySqliteRequest.new
        request = request.from('nba_player_data.csv')
        request = request.select('name')
        request = request.where('college', 'Duke University')
        request.run
    when 1
        filename = 'nba_player_data.csv'
        attribute_output = 'name'
        attribute = 'year_start'
        value = '1990'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request.run
    when 2
        filename = 'nba_player_data.csv'
        attribute_output = 'birth_date'
        attribute = 'year_start'
        value = '1990'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request.run
    when 3
        filename = 'nba_player_data.csv'
        attribute_output = ['college', 'year_end']
        attribute = 'year_start'
        value = '1990'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request.run
    when 4
        filename = 'nba_player_data.csv'
        attribute_output = '*'
        right_db = 'nba_players.csv'
        left_db_column ='name'
        right_db_column = 'Player'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.join(left_db_column, right_db, right_db_column)
        request.run
    when 5
        filename = 'nba_player_data.csv'
        attribute_output = '*'
        right_db = 'nba_players.csv'
        left_db_column ='name'
        right_db_column = 'Player'
        attribute = 'year_start'
        value = '1969'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.join(left_db_column, right_db, right_db_column)
        request = request.where(attribute, value)
        request.run
    when 6
        filename = 'test_insert_v1.csv'
        record_hash = {'name' => 'name3', 'year_start' => 2022, 'year_end' => 2023, 'position' => 'position1', 'height' => '10-4', 'weight' => 300, 'birth_date' => 'July 21, 2021', 'college' => 'college1'}

        request = MySqliteRequest.new
        request = request.insert(filename)
        request = request.values(record_hash)
        request.run 
    when 7    
        filename = 'nba_player_data.csv'
        attribute_output = '*'
        right_db = 'nba_players.csv'
        left_db_column ='name'
        right_db_column = 'Player'
        attribute = 'year_start'
        value = '1969'
        order_attribute = 'college'
        order = 'dEsC'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.join(left_db_column, right_db, right_db_column)
        request = request.where(attribute, value)
        request = request.order(order, order_attribute)
        request.run
    when 8
        filename_write = 'test_write_v1.csv'
        attribute_find = 'name' 
        value = 'Alaa Abdelnaby'
        record_hash = {'year_end' => 3023, 'position' => 'position@'}

        request = MySqliteRequest.new
        request = request.update(filename_write)
        request = request.set(record_hash)
        request = request.where(attribute_find, value)
        request.run
    when 9
        filename_write = 'test_write_v1.csv'
        attribute_find = 'name' 
        value = 'Alaa Abdelnaby'
        record_hash = {'year_start' => 2022}

        request = MySqliteRequest.new
        request = request.update(filename_write)
        request = request.set(record_hash)
        request = request.where(attribute_find, value)
        request.run
    when 10
        filename_write = 'test_write_v1.csv'
        attribute_find = 'name' 
        value = 'name2'

        request = MySqliteRequest.new
        request = request.delete(filename_write)
        request = request.where(attribute_find, value)
        request.run
    when 11
        filename = 'nba_player_data.csv'
        attribute_output = ['name', 'year_start', 'college', 'year_end']
        attribute = 'year_start'
        value = '1991'
        attribute1 = 'college'
        value1 = 'Louisiana State University'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request = request.where(attribute1, value1)
        request.run
    when 12
        filename = 'nba_player_data.csv'
        attribute_output = ['name', 'year_start', 'college', 'year_end', 'position']
        attribute = 'year_start'
        value = '2014'
        attribute1 = 'college'
        value1 = 'Duke University'
        
        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request = request.where(attribute1, value1)
        request.run
    when 13
        filename = 'nba_player_data.csv'
        attribute_output = ['name', 'year_start', 'year_end',  'college']
        attribute = 'year_start'
        value = '2014'
        attribute1 = 'college'
        value1 = 'Duke University'
        attribute2 = 'year_end'
        value2 = '2017'

        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request = request.where(attribute1, value1)
        request = request.where(attribute2, value2)
        request.run
    when 14
        filename_write = 'nba_player_data_multiple_wherev1.csv'
        attribute = 'year_start'
        value = '2014'
        attribute1 = 'college' 
        value1 = 'Duke University'
        record_hash = {'year_end' => 4023, 'position' => 'position#'}

        request = MySqliteRequest.new
        request = request.update(filename_write)
        request = request.set(record_hash)
        request = request.where(attribute, value)
        request = request.where(attribute1, value1)
        request.run
    when 15
        filename = 'nba_player_data_multiple_wherev1.csv'
        attribute_output = ['name', 'year_start', 'college', 'year_end', 'position']
        attribute = 'year_start'
        value = '2014'
        attribute1 = 'college'
        value1 = 'Duke University'
        
        request = MySqliteRequest.new
        request = request.from(filename)
        request = request.select(attribute_output)
        request = request.where(attribute, value)
        request = request.where(attribute1, value1)
        request.run
    end

end


# request_unit_test(0)
# request_unit_test(13)
