require 'pg_partitioning/input_master'
require 'pg_partitioning/partitioning_master'

class PartitioningGenerator < Rails::Generators::Base
  
  def partitioning
    input_master = PgPartitioning::InputMaster.new
    input_master.intro
    
    mode        = input_master.ask_mode.to_i
    table_name  = input_master.ask_table_name
    column_name = input_master.ask_column_name
    cond        = input_master.ask_cond(PgPartitioning::PartitioningMaster::MODES[mode]) 
    
    master = PgPartitioning::PartitioningMaster.new(table_name, column_name, mode, cond)
    master.partitioning
  end
end
