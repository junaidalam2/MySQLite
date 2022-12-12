time = Time.new
puts "MySQLite version 0.1 #{time.strftime("%Y/%d/%m")}"
require_relative 'my_sqlite_request.rb'
require_relative 'unit_tests.rb'


class CLI
    @@request_cli = MySqliteRequest.new
    @@operator_array = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'FROM', 'WHERE', 'JOIN', 'ORDER', 'VALUES', 'SET', 'AND', 'ORDER BY', 'DESC', 'ASC'] 

    def initialize()
        @array_index_to_delete = []
        @user_input = gets
        @user_input = @user_input.chomp

        check_for_unit_test()
        
        @user_input.delete_suffix!(';')
        @query_array = @user_input.split

        fix_separated_text()  # joins text that was erroneously split by spaces, removes excessive quotation marks and commas
        upcase_operators()
        cli_parser()
    end


    def check_for_unit_test()
        
        if @user_input == 'run unit test'
            puts 'Enter index number of hash of unit tests in CLI_Unit_Test.'
            unit_test_hash_index = gets
            unit_test_hash_index = unit_test_hash_index.chomp.to_i
            @user_input = CLI_Unit_Test.unit_test[unit_test_hash_index]
        end

    end 


    def fix_separated_text()

        start_index = 0
        end_index = @query_array.length - 1
        i = start_index + 1

        while i > start_index && i <= end_index 
                
            if @query_array[i] == ',' 
                @query_array.delete_at(i)
                end_index = @query_array.length - 1
            end
            
            if @query_array[i][-2] == '"' || @query_array[i][-2] == "'"
                @query_array[i].delete_suffix!(',')
            end

            @query_array[i] = remove_quotation_marks(@query_array[i])
            
            i += 1
        end
        
        join_parsed_values(start_index)

        j = start_index + 1
        end_index = @query_array.length - 1 
        while j > start_index && j <= end_index
            
            @query_array[j].delete_suffix!(',')
            @query_array[j] = remove_quotation_marks(@query_array[j])
        
            j += 1

        end

    end


    def remove_quotation_marks(text)
    
        if (text[0] == "'" && text[-1] == "'") || (text[0] == '"' && text[-1] == '"')
            text.delete_prefix!(text[0])
            text.delete_suffix!(text[-1])
        end

        return text

    end

    
    def join_parsed_values(start_index) 
    
        
        array_length = @query_array.length
        i = start_index + 1

        open_bracket_index = nil
        closed_bracket_index = nil
        switch = 0
        quotation_mark = nil


        while i > start_index && i < array_length 
            
            if (@query_array[i][0] == "'" && @query_array[i][-1] != "'") || (@query_array[i][0] == '"' && @query_array[i][-1] != '"') && (switch == 0)
                open_bracket_index = i
                quotation_mark = @query_array[i][0]
                switch = 1
            end
    
            if (@query_array[i][0] != "'" && @query_array[i][-1] == quotation_mark) || (@query_array[i][0] != '"' && @query_array[i][-1] == quotation_mark) && (switch == 1)
                closed_bracket_index = i
                switch = 0
                concatenate_values(open_bracket_index, closed_bracket_index)
            end
    
            i += 1
        end
    

        j = 0
        while j < @array_index_to_delete.length  #after joining values, check again for , and '' to remove
            
            index =  @array_index_to_delete[j]
            @query_array.delete_at(index)
            
            j += 1
        end

    end


    def concatenate_values(open_bracket_index, closed_bracket_index)
        
        i = open_bracket_index + 1
        text_concat = @query_array[open_bracket_index]
        while i > open_bracket_index && i <= closed_bracket_index
            
            text_concat.concat(" ").concat(@query_array[i])
            @array_index_to_delete << open_bracket_index + 1
            
            i += 1
        end

        @query_array[open_bracket_index] = text_concat
       
    end
    

    def upcase_operators()  # make operators upcase
     
        @query_array.each_index do |i|
            if @@operator_array.include? @query_array[i].upcase
                @query_array[i] = @query_array[i].upcase
            end
        end
    end


    def cli_parser()

        case @query_array[0]
        when 'INSERT'
            cli_insert_parser()
            insert_call()
        when 'SELECT'
            cli_select_parser()
            select_call()
        when 'UPDATE'
            cli_update_parser()
            update_call()
        when 'DELETE'
            cli_delete_parser()
            delete_call()
        else
            puts 'ERROR >> Need to provide INSERT, SELECT, UPDATE, or DELETE statement.'
        end
    
    end
     

    def insert_into()

        if @query_array[1].upcase == 'INTO'
            @query_array.delete_at(1)
        end
    
    end


    def find_operator(operator)

        operator_index = nil 
        @query_array.each_index do |i|
            if @query_array[i].upcase == operator
                @query_array[i] = @query_array[i].upcase
                operator_index = i
                break
            end
    
        end
    
        return operator_index
    
    end


    def parse_values(values_index)  # returns array consisting of the record to be inserted
        
        @query_array[values_index + 1].delete_prefix!('(')
        @query_array[@query_array.length - 1].delete_suffix!(')')
        remove_quotation_marks(@query_array[values_index + 1])
        remove_quotation_marks(@query_array[@query_array.length - 1])

        return record_array = @query_array.slice(values_index + 1, @query_array.length)
    
    end


    def create_hash(operator, start_index)
    
        hash = {}
    
        i = start_index + 2
        while i> start_index + 1 && i < @query_array.length 
            
            if @query_array[i] == '='
                hash.store(@query_array[i - 1], @query_array[i + 1]) 
            end
            
            if operator == 'WHERE'
                if @@operator_array.include? @query_array[i] && @query_array[i] != 'AND'
                    break
                end
            elsif @@operator_array.include? @query_array[i]
                break
            end
            
            i += 1
        end
        
        return hash
    
    end
    
    
    def cli_insert_parser()
    
        insert_into()
        @db_table = @query_array[1]
        values_index = find_operator('VALUES')
        # fix_separated_text(values_index)
        record_array = parse_values(values_index)

        array_dummy_keys = *(1..record_array.length)
        @record_hash = Hash[array_dummy_keys.zip record_array]
        
    end


    def obtain_columns(from_index)
    
        column_array = @query_array.slice(1,from_index-1)
        
        return column_array
    
    end
    

    def order_join_text()

        if @query_array[@order_index + 1] = 'BY'
        
            @query_array[@order_index].concat(" ").concat(@query_array[@order_index + 1])
            @query_array.delete_at(@order_index + 1)
        end
    
    end 


    def order_asc_desc()

        @order_asc_desc = 'ASC'

        if @order_index + 2 < @query_array.length
            if @query_array[@order_index + 2] == 'DESC'
                @order_asc_desc = 'DESC'
            end
        end
    
    end 


    def cli_select_parser()

        from_index = find_operator('FROM')
        @db_table = @query_array[from_index + 1]
        @column_array = obtain_columns(from_index)

        @join_index = find_operator('JOIN')
        if @join_index
            @right_table = @query_array[@join_index + 1]
            @join_hash = create_hash('JOIN', @join_index)
        end

        @where_index = find_operator('WHERE')
        if @where_index
            @hash_where = create_hash('WHERE', @where_index)
        end

        @order_index = find_operator('ORDER')
        if @order_index
            order_join_text()
            @order_column = @query_array[@order_index + 1]
            order_asc_desc()
        end

    end
    
    
    def cli_delete_parser()
    
        from_index = find_operator('FROM')
        @db_table = @query_array[from_index + 1]
        where_index = find_operator('WHERE')
        if where_index
            @hash_where = create_hash('WHERE', where_index)
        end
    
    end
    

    def cli_update_parser()
    
        @db_table = @query_array[1]
        set_index = find_operator('SET')
        if set_index
            @hash_set = create_hash('SET', set_index)
        end
        where_index = find_operator('WHERE')
        if where_index
            @hash_where = create_hash('WHERE', where_index)
        end
    
    end
    

    def insert_call()

        request = @@request_cli
        request = request.insert(@db_table)
        request = request.values(@record_hash)
        request.run

    end


    def select_call()

        request = @@request_cli
        request = request.from(@db_table)
        request = request.select(@column_array)

        if @join_index
            request = request.join(@join_hash.keys[0], @right_table, @join_hash.values[0])
        end

        if @where_index
            @hash_where.each do | key, value |
                request = request.where(key, value)
            end
        end
        
        if @order_index
            request = request.order(@order_asc_desc, @order_column)
        end

        request.run

    end
 

    def update_call()

        request = @@request_cli
        request = request.update(@db_table)
        request = request.set(@hash_set)

        @hash_where.each do | key, value |
            request = request.where(key, value)
        end
        
        request.run

    end


    def delete_call()

        request = @@request_cli
        request = request.delete(@db_table)
        
        @hash_where.each do | key, value |
            request = request.where(key, value)
        end
        
        request.run

    end

end

interface = CLI.new






    

