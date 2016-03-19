require 'pg_partitioning/printer'

module PgPartitioning
  module Strategies
    class Base
      include Printer
      
      def initialize(table, column, cond, sql_conn)
        @table_name = table
        @column_name = column
        @cond = cond
        @sql = sql_conn
      end
        
      def partitioning!
        raise error_message unless valid?
        create_insert_master_function
        create_before_insert_trigger
        create_drop_function
        create_after_insert_trigger
      end
      
      protected

      def valid?
        @data_type = column_data_type
        @error_message = I18n.t "pg_partitioning.failure.no_table" if @data_type.blank?
        @error_message.blank?
      end
      
      def error_message
        @error_message || I18n.t("pg_partitioning.failure.other")
      end

      def column_data_type
        res = nil
        @sql.execute("SELECT data_type FROM information_schema.columns 
                      WHERE table_name ='#{@table_name}' 
                      AND column_name = '#{@column_name}';").each do |r|
          res = r['data_type']
        end
        res
      end
      
      def create_before_insert_trigger
        @sql.execute "DROP TRIGGER IF EXISTS #{@table_name}_before_insert_trigger ON #{@table_name};
                      CREATE TRIGGER #{@table_name}_before_insert_trigger
                      BEFORE INSERT ON #{@table_name}
                      FOR EACH ROW EXECUTE PROCEDURE #{@table_name}_insert_master();"
        info I18n.t("pg_partitioning.progress.before_insert_trigger", state: "OK")
      end

      def create_drop_function
        @sql.execute "CREATE OR REPLACE FUNCTION #{@table_name}_delete_master() RETURNS TRIGGER AS $$
                      DECLARE
                        row #{@table_name.to_sym}%rowtype;
                      BEGIN
                        DELETE FROM ONLY #{@table_name} WHERE id = NEW.id RETURNING * INTO row;
                        RETURN row;
                      END;
                      $$ LANGUAGE plpgsql;"
        info I18n.t("pg_partitioning.progress.drop_master", state: "OK")
      end

      def create_after_insert_trigger
        @sql.execute "DROP TRIGGER IF EXISTS #{@table_name}_after_insert_trigger ON #{@table_name}; 
                      CREATE TRIGGER #{@table_name}_after_insert_trigger
                      AFTER INSERT ON #{@table_name}
                      FOR EACH ROW EXECUTE PROCEDURE #{@table_name}_delete_master();"
        info I18n.t("pg_partitioning.progress.after_insert_trigger", state: "OK")
      end
    end
  end
end
