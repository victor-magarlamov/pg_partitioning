module DbHelpers
  def clear_triggers(table)
    sql = <<-SQL
            DROP TRIGGER IF EXISTS #{table}_before_insert_trigger ON #{table};
            DROP TRIGGER IF EXISTS #{table}_after_insert_trigger ON #{table}; 
          SQL
    ActiveRecord::Base.connection.execute(sql)
  end
  
  def insert_master_function_exists?(table)
    sql = <<-SQL
            SELECT 1 FROM pg_trigger, pg_proc 
            WHERE pg_proc.oid=pg_trigger.tgfoid 
            AND pg_trigger.tgname = '#{table}_before_insert_trigger';
          SQL
    result = nil
    ActiveRecord::Base.connection.execute(sql).each do |r|
      result = r["?column?"]
    end
    result.to_i == 1
  end
  
  def after_insert_trigger_exists?(table)
    sql = <<-SQL
            SELECT 1 FROM pg_trigger, pg_proc 
            WHERE pg_proc.oid=pg_trigger.tgfoid 
            AND pg_trigger.tgname = '#{table}_after_insert_trigger';
          SQL
    result = nil
    ActiveRecord::Base.connection.execute(sql).each do |r|
      result = r["?column?"]
    end
    result.to_i == 1
  end
end

