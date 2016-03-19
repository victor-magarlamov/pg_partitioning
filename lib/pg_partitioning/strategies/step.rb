require 'pg_partitioning/strategies/base'

module PgPartitioning
  module Strategies
    class Step < Base
      
      def valid?
        if super
          @error_message = if !@data_type.include? 'integer'
                             I18n.t "pg_partitioning.failure.column_type"
                           elsif @cond.blank?
                             I18n.t "pg_partitioning.failure.blank_cond"
                           end
        end
        @error_message.blank?
      end
        
      protected

      def create_insert_master_function
        @sql.execute "CREATE OR REPLACE FUNCTION #{@table_name}_insert_master() RETURNS TRIGGER AS $$
                       DECLARE
                         colname   text    := '#{@column_name.to_sym}';
                         colval    integer := NEW.#{@column_name.to_sym};
                         threshold integer := '#{@cond}';
                         step      integer := ROUND(colval / threshold);
                         tblname   text    := '#{@table_name}_' || step;
                       BEGIN
                         IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=tblname) THEN
                         EXECUTE 'CREATE TABLE '
                                 || tblname 
                                 || '(check (ROUND(' 
                                 || quote_ident(colname) 
                                 || '/'
                                 || threshold 
                                 || ')=' 
                                 || step
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
