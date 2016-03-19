require 'pg_partitioning/strategies/base'

module PgPartitioning
  module Strategies
    class Equal < Base
      
      protected
      
      def create_insert_master_function
        @sql.execute "CREATE OR REPLACE FUNCTION #{@table_name}_insert_master() RETURNS TRIGGER AS $$
                       DECLARE
                         colname text := '#{@column_name.to_sym}';
                         colval  text := NEW.#{@column_name.to_sym};
                         tblname text := '#{@table_name}_' || colval;
                       BEGIN
                         IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=tblname) THEN
                         EXECUTE 'CREATE TABLE '
                                 || tblname 
                                 || '(check (' 
                                 || quote_ident(colname) 
                                 || '=' 
                                 || quote_literal(colval) 
                                 || ')) INHERITS (' 
                                 || TG_RELNAME 
                                 || ');';
                         END IF;
                         EXECUTE 'INSERT INTO ' || tblname || ' SELECT ($1).*' USING NEW;
                         RETURN NEW;
                       END;
                       $$ LANGUAGE plpgsql;"
        info I18n.t("pg_partitioning.progress.insert_master", state: "OK")
      end
    end
  end
end

