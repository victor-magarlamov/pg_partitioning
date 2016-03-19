require 'pg_partitioning/printer'

module PgPartitioning
  class InputMaster
    include Printer
    
    %w(mode table_name column_name cond).each do |act|
      define_method "ask_#{act}" do |argument = nil|
        begin
          quest_key = argument.blank? ? act : "#{act}_#{argument}"
          quest_val = I18n.t "pg_partitioning.quests.#{quest_key}", raise: true
          res = ask quest_val
          if send "#{quest_key}_valid?", res
            return res
          else
            alert @error_message
            send "ask_#{act}", argument unless ENV['RAILS_ENV'] == 'test'
          end
        rescue I18n::MissingTranslationData
          return nil
        end
      end
    end

    def method_missing(name, *args, &block)
      valid? *args if name.to_s.include? '_valid?'
    end
    
    def intro
      info <<-INTRO
      Hi! It's time to do partitioning)
      I can do it in different ways:
      
      by EQUALity
          - partition will be created by value of column,
          - in this case you should only set column name;
      
      by STEP
          - partition will be created by value of column divided by the step and rounded,
          - in this case you should else set number of the step,
          - a type of the column should be a numeric;
      
      by DATE
          - partition will be created by pattern from date,
          - in this case you should else set pattern for parsing the date,
          - acceptable (itself or in combination): Y, YY, YYY, YYYY, MM, D, DD, DDD, W, WW, HH24 
          - a type of the column should be a date/timestamp.
      INTRO
    end

    private
      def ask(text)
        text_color WHITE
        print I18n.t('pg_partitioning.enter', quest: text)
        gets.chomp
      end

      def valid?(text)
        res = !text.blank?
        @error_message = I18n.t 'pg_partitioning.failure.answer' unless res
        res
      end

      def mode_valid?(text)
        res = %w(0 1 2).include? text
        @error_message = I18n.t 'pg_partitioning.failure.mode' unless res
        res
      end
      
      def cond_step_valid?(text)
        res = text.to_i > 0
        @error_message = I18n.t "pg_partitioning.failure.step" unless res
        res
      end
      
      def cond_date_valid?(text)
        match = text.match /Y{1,4}|M{2}|D{1,3}|W{1,2}|HH24/
        res = !match.blank?
        @error_message = I18n.t "pg_partitioning.failure.pattern" unless res
        res
      end
  end
end

