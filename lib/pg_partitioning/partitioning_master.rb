require 'pg_partitioning/printer'
require 'pg_partitioning/strategies/equal'
require 'pg_partitioning/strategies/date'
require 'pg_partitioning/strategies/step'

module PgPartitioning
  class PartitioningMaster
    include Printer
    
    MODES = %w(equal step date).freeze

    def initialize(table_name, column_name, mode, cond=nil)
      @table_name = table_name 
      @column_name = column_name
      @cond = cond
      @sql = ActiveRecord::Base.connection()
      
      klass = "PgPartitioning::Strategies::#{MODES[mode].classify}"
      @strategy = klass.constantize.new(@table_name, @column_name, @cond, @sql)
    end

    def partitioning
      @strategy.partitioning!
      
      drop_foreign_keys
      migration
      
      mode = show_value_of('constraint_exclusion')
      if mode != 'partition'
        alert I18n.t('pg_partitioning.messages.partition_mode', current: mode)
      end
      
      info I18n.t 'pg_partitioning.progress.finish'
    rescue => e
      alert e.message || I18n.t('pg_partitioning.failure.other')
    end

    private
      def drop_foreign_keys
        fk_info = []
        query = ActiveRecord::Base.send(
                  :sanitize_sql_array,
                  ["SELECT tc.constraint_name, tc.table_name, kcu.column_name, 
                           ccu.table_name AS foreign_table_name,
                           ccu.column_name AS foreign_column_name 
                    FROM   information_schema.table_constraints AS tc 
                    JOIN   information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
                    JOIN   information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
                    WHERE  constraint_type = 'FOREIGN KEY' AND ccu.table_name=?;", @table_name])
           
        @sql.execute(query).each do |r|
          fk_info << r
        end

        fk_info.each do |r|
          @sql.execute "ALTER TABLE #{r['table_name']} DROP CONSTRAINT #{r['constraint_name']};"
        end
        
        info I18n.t('pg_partitioning.progress.drop_fk', state: 'OK')
      end

      def migration
        @sql.execute <<-SQL
          CREATE MATERIALIZED VIEW temp_table AS SELECT * FROM #{@table_name};
          DELETE FROM #{@table_name};
          INSERT INTO #{@table_name} (SELECT * FROM temp_table);
          DROP MATERIALIZED VIEW temp_table;
        SQL
        info I18n.t('pg_partitioning.progress.migration', state: 'OK')
      end
      
      def show_value_of(param)
        res = ''
        @sql.execute("SHOW #{param};").each{ |r| res = r[param] }
        res
      end
  end
end
