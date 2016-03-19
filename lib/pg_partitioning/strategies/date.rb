require 'pg_partitioning/strategies/base'

module PgPartitioning
  module Strategies
    class Date < Base
      
      protected

      def valid?
        if super
          @error_message = if !(@data_type.include?('timestamp') || @data_type.include?('date'))
                             I18n.t "pg_partitioning.failure.column_type"
                           elsif (@cond.blank? || !cond_valid?)
                             I18n.t "pg_partitioning.failure.blank_cond"
                           end
        end
        @error_message.blank?
      end
      
      def cond_valid?
        res = []
        patterns = { year:  /(?<year>Y{1,4})/,
                     month: /(?<month>M{2})/,
                     day:   /(?<day>D{2})/,
                     week:  /(?<week>W{1,2})/,
                     hour:  /(?<hour>HH24{1})/ }
        
        patterns.each do |key, value|
          match = @cond.match value
          res << match[key] if match
        end
        @cond = res.join '_'
        !@cond.blank?
      end

      def create_insert_master_function
        @sql.execute "CREATE OR REPLACE FUNCTION #{@table_name}_insert_master() RETURNS TRIGGER AS $$
                       DECLARE
                         colname text      := '#{@column_name.to_sym}';
                         colval  timestamp := NEW.#{@column_name.to_sym};
                         pattern text      := '#{@cond.to_sym}';
                         sample  text      := TO_CHAR(colval, pattern);
                         tblname text      := '#{@table_name}_' || sample;
                       BEGIN
                         IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=tblname) THEN
                         EXECUTE 'CREATE TABLE '
                                 || tblname 
                                 || '(check (TO_CHAR(' 
                                 || quote_ident(colname) 
                                 || ','
                                 || quote_literal(pattern)
                                 || ')=' 
                                 || quote_literal(sample)
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
