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
        create_trigger('insert_master', 'before')
        create_drop_function
        create_trigger('delete_master', 'after')
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
        query = ActiveRecord::Base.send(:sanitize_sql_array,
                                        ["SELECT data_type FROM information_schema.columns
                                          WHERE table_name = ? AND column_name = ?;",
                                         @table_name, @column_name])
        @sql.execute(query).each do |r|
          res = r['data_type']
        end
        res
      end
      
      def create_trigger(master, mode)
        drop_trigger(mode)
        @sql.execute "CREATE TRIGGER #{@table_name}_#{mode}_insert_trigger
                      #{mode} INSERT ON #{@table_name}
                      FOR EACH ROW EXECUTE PROCEDURE #{@table_name}_#{master}();"
        info I18n.t("pg_partitioning.progress.#{mode}_insert_trigger", state: "OK")
      end

      def drop_trigger(mode)
        @sql.execute "DROP TRIGGER IF EXISTS #{@table_name}_#{mode}_insert_trigger ON #{@table_name};"
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
    end
  end
end
