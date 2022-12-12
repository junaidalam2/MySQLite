require 'csv'

 
class MySqliteRequest
    @@file_path = 'csv_files/'

    def initialize()
        @row_index_arr = nil
        @sort_key = nil
        @crud_state = nil  # :create; :read; :update; :delete
        @execute_where = nil
        @column_where_hash = {}

    end

    
    def check_file_type(filename)  # create, read, update, delete

        if filename[-4..-1] != '.csv'
            puts "ERROR >> file type not 'csv'"
        end
    
    end
    
    
    def from(filename)  # read

        @crud_state = :read
        path = Marshal.load(Marshal.dump(@@file_path))
        filename = path.concat(filename)
        check_file_type(filename)
        @table = CSV.parse(File.read(filename), headers: true)
        
        self

    end


    def join(left_db_column, right_db, right_db_column)  # read
        
        path = Marshal.load(Marshal.dump(@@file_path))
        right_db = path.concat(right_db)
        @right_table = CSV.parse(File.read(right_db), headers: true)
        left_table_col_index = @table.headers.find_index(left_db_column.to_s)
        right_table_col_index = @right_table.headers.find_index(right_db_column.to_s)
        @join_array = []
        header_array = @table.headers.concat(@right_table.headers)

        header_array.each_with_index do | element, index |
            for i in index..header_array.length do
                if index != i && element == header_array[i] && header_array[index] != nil  
                    header_array[i] = header_array[i] + "_1"
                    
                end
            end
        end
        
        @join_array.append(header_array)

        @table.each do |row_left|

            @right_table.each do |row_right|
                
                value_left = row_left[left_table_col_index]
                value_right = row_right[right_table_col_index] 

                if value_left == value_right
                    join_row = (row_left.to_h.values).concat(row_right.to_h.values)
                    @join_array << join_row
                    
                end
            end
        end

        delimeter = "!@#$%^&*()_|||SEPARATOR|||_!@#$%^&*()"  # elements may contain commas, code uses a unique delimeter
        csv_data = @join_array.map { _1.join(delimeter)}.join("\n")
        @join_table = CSV.parse(csv_data, headers: true, col_sep: delimeter)
        @table = @join_table

        self
    end


    def select(attribute_output)  # read 

        @attribute_output = attribute_output

        self
    end


    def select_run()  # read

        @column_index = []

        if @attribute_output.class() != Array
            @attribute_output = [@attribute_output]
        end
        
        if @attribute_output[0] == '*'
            @attribute_output = @table.headers
        end        

        @attribute_output.each do |element|
        
            col_index_num = @table.headers.find_index(element.to_s)
            
            if col_index_num.class == Integer

                @column_index << col_index_num 
            end 
            
            
        end
        
    end


    def where(attribute_find, value)  # read, update, delete

        @execute_where = 1
        
        case @crud_state
        when :read, :update, :delete
            where_find_col(attribute_find, value)
        else
            puts 'Where method to be called with select, update or delete methods only.'
        end

        self

    end


    def where_find_col(attribute_find, value)  # read, update, delete

        if @crud_state == :read
            @column_index_find = @table.headers.find_index(attribute_find)
        elsif @crud_state == :update || @crud_state == :delete 
            @column_index_find = @table_write[0].find_index(attribute_find)
        else
            puts 'Where method to be called with select, update or delete methods only.'
        end
        

        if @column_index_find
            @column_where_hash.store(@column_index_find, value)
        
        end
        
    end


    def where_read_find_rows()  # read

        @row_index_arr = []

        col_hash_length = @column_where_hash.length

        @table.each_with_index do |row, index|
            
            counter = 1
            @column_where_hash.each do | col_index, value |

                if row[col_index] != value
                    break
                elsif col_hash_length == counter
                    @row_index_arr << index
                end

                counter += 1
            end
        end

    end


    def order(asc_dec, sort_key)  # read
    
        @sort_key = sort_key
        @asc_dec = asc_dec.downcase

        self

    end


    def order_run()  # read
    
        @results_array.sort_by! { |hash| hash[@sort_key] }

        if @asc_dec == 'desc' 
            @results_array.reverse!
        end 

    end


    def insert(filename_insert)  # create

        @crud_state = :create

        path = Marshal.load(Marshal.dump(@@file_path))
        filename_insert = path.concat(filename_insert)
        @file_insert = File.open(filename_insert, 'a')
        @file_insert.puts
        
        self
    
    end


    def values(record_hash)  # create

        create_record(record_hash.values)

        self

    end


    def create_record(array_new_record)  # create, update
    
        string = ''
    
        array_new_record.each do |element|
    
            element = element.to_s
    
            if element.include? ','
                element = "\"#{element}\""
            end        
    
            delimeter = ","
            if string.length == 0
                delimeter = ""
            end
    
            string = string + delimeter + element 
                
        end
    
        return @new_record = string
    
    end


    def update(filename_write)  # update

        @crud_state = :update
        path = Marshal.load(Marshal.dump(@@file_path))
        filename_write = path.concat(filename_write)
        open_write(filename_write)

        self
    
    end
    

    def set(update_hash)  # update

        @update_hash = update_hash

        self

    end
    

    def where_update_find_rows()  # update, delete

        @records_array = []
        @row_index_arr_write = nil
        col_hash_length = @column_where_hash.length
    
        @table_write.each_index do |i|
            
            counter = 1
            @column_where_hash.each do | col_index, value |

                if @table_write[i][col_index] != value
                    break
                elsif col_hash_length == counter
                    
                    if @crud_state == :update
                        @records_array << @table_write[i]
                    end
                    
                    cursor = row_cursor(i)
                    delete_record(cursor)

                end

                counter += 1
            end
        end

    end


    def row_cursor(row_index_write)  # update, delete

        @file_write = File.open(@filename_write, 'r+')
        counter = 0

        while counter < row_index_write
            @file_write.gets
            counter += 1
        end

        cursor = @file_write.pos
        @file_write.close

        return cursor

    end


    def delete_record(cursor)  # update, delete

        file = File.open(@filename_write, 'r+')
        file.pos = cursor
    
        old_record = file.gets
        length = old_record.length
        file.pos = cursor
    
        while length > 0
            file.print 127.chr
            length -= 1
        end
    
        file.print "\n" 

        file.close

    end


    def find_col()  # update; store index number of columns to be updated

        @update_col_index = []
        update__keys_array = @update_hash.keys  # from set() method
        
        update__keys_array.each do |col|
            @table_write[0].each_index do |i|
                if col == @table_write[0][i]
                    @update_col_index.append(i)
                end
            end
        end

    end


    def update_records_array()  # update

        @records_array.each do |row|
            @update_hash.values.each_index do |i|
                index = @update_col_index[i]
                row[index] = @update_hash.values[i]
            end

            create_record(row)
            append_new_record()

        end
    
    end


    def append_new_record()  # create, update

        file = File.open(@filename_write, 'a')
        file.puts
        file.print @new_record
        file.close

        return self
    
    end


    def delete(filename_write)  # delete

        @crud_state = :delete

        path = Marshal.load(Marshal.dump(@@file_path))
        filename_write = path.concat(filename_write)
        open_write(filename_write)

        self
    
    end


    def open_write(filename_write)  # create, update, delete
    
        @filename_write = filename_write
        check_file_type(@filename_write)
        file_write = CSV.open(filename_write, 'r+')
        @table_write = file_write.readlines
    
    end


    def run()  # create, read, update, delete
    
        case @crud_state
        when :create
            run_insert()
            puts "Record inserted."
        when :read
            run_read()
        when :update
            run_update()
            puts "Record(s) updated."
        when :delete
            run_delete()
            puts "Record(s) deleted."
        else
            puts 'Error in input'
        end

        reset()

    end


    def reset()  # create, read, update, delete

        case @crud_state
        when :create  # insert
            @file_insert = nil
            @new_record = nil
        when :read # select
            @attribute_output = nil
            @table = nil
            @attribute_output = nil
            @row_index_arr = nil
            @column_index_find = nil
            @column_index = nil
            @sort_key = nil  
            @asc_dec = nil  
            @results_array = nil  
            @right_table = nil
            @join_array = nil
            @column_where_hash = nil
            @execute_where = nil
        when :update  
            @filename_write = nil
            @file_write = nil
            @table_write = nil
            @update_hash = nil
            @records_array = nil
            @row_index_arr_write = nil
            @update_col_index = nil
            @column_index_write = nil
            @new_record = nil
            @column_where_hash = nil
            @execute_where = nil
        when :delete 
            @filename_write = nil
            @table_write = nil
            @row_index_arr_write = nil
            @records_array = nil
            @file_write = nil
            @column_index_write = nil
            @new_record = nil
            @column_index_find = nil
            @column_where_hash = nil
            @execute_where = nil
        end

        @crud_state = nil

    end


    def run_insert()  # create

        @file_insert.print @new_record
        @file_insert.close
    
    end


    def run_read()  # read

        if @execute_where
            where_read_find_rows()
        end

        select_run()
        @results_array = []
        results_hash = {}

        flag, counter = nil, 0  
        if @row_index_arr == nil  # used if 'where' method is unused by the user
            @row_index_arr = @table
            flag = 1
        end

        @row_index_arr.each do |element_row|
            if flag
                element_row = counter
                counter += 1
            end

            @column_index.each do |element_col|
                results_hash.store(@table.headers[element_col], @table[element_row][element_col])
                
            end
            
            @results_array << results_hash
            results_hash = {}

        end

        if @sort_key != nil
            order_run()
        end

        print @results_array
        return @results_array

    end

    
    def run_update()  # update

        if @execute_where
            where_update_find_rows()
        end 

        find_col()
        update_records_array()

    end


    def run_delete()  # delete

        if @execute_where
            where_update_find_rows()
        end

    end


end

