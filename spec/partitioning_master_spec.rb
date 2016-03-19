require_relative '../lib/pg_partitioning/partitioning_master'

describe "PgPartitioning::PartitioningMaster" do
  let(:table)  { 'bandits' }
  let(:column) { 'specialization' }
  let(:mode)   { 0 }
  
  subject { PgPartitioning::PartitioningMaster.new(table, column, mode) }
  
  it { is_expected.to respond_to :partitioning }
  it { expect(subject.instance_variable_get(:@table_name)).to eq table }
  it { expect(subject.instance_variable_get(:@column_name)).to eq column }
  
  context "mode is equal" do
    before do
      @master = PgPartitioning::PartitioningMaster.new(table, column, 0)
      @strategy = @master.instance_variable_get :@strategy
    end

    it { expect(@strategy.class).to be PgPartitioning::Strategies::Equal }

    describe "partitioning!" do
      
      it_behaves_like "happy_partitioning"

      describe "generate right table name" do
        before do
          Bandit.delete_all
          clear_triggers(table)
          @master.partitioning
          @thief = create :thief
          @killer = create :killer
        end
            
        it{ expect(Bandit.all.size).to be 2 }
        it{ expect(Bandit.find_by_sql("SELECT * FROM bandits_killer").first).to eq @killer }
        it{ expect(Bandit.find_by_sql("SELECT * FROM bandits_thief").first).to eq @thief }
      end
      
      context "with nonexistent name" do
        it "raise error no table" do
          master = PgPartitioning::PartitioningMaster.new('nonexistent table', column, 0)
          strategy = master.instance_variable_get :@strategy
          expect{strategy.partitioning!}.to raise_error( I18n.t "pg_partitioning.failure.no_table" )
        end
        
        it "raise error no column" do
          master = PgPartitioning::PartitioningMaster.new(table, "nonexistent column", 0)
          strategy = master.instance_variable_get :@strategy
          expect{strategy.partitioning!}.to raise_error( I18n.t "pg_partitioning.failure.no_table" )
        end
      end
    end
  end
  
  context "mode is step" do
    before do
      @master = PgPartitioning::PartitioningMaster.new(table, 'id', 1, 100)
    end

    it { expect(@master.instance_variable_get(:@strategy).class).to be PgPartitioning::Strategies::Step }
    
    describe "partitioning!" do
      
      it_behaves_like "happy_partitioning"
      
      describe "generate right table name" do
        before do
          Bandit.delete_all
          clear_triggers(table)
          @master.partitioning
          @thief = create :thief
          @killer = create :killer
        end
            
        it{ expect(Bandit.all.size).to be 2 }
        it{ expect(Bandit.find_by_sql("SELECT * FROM bandits_2").first).to eq @killer }
        it{ expect(Bandit.find_by_sql("SELECT * FROM bandits_0").first).to eq @thief }
      end
      
      context "with invalid data" do
        it "raise error type is not integer" do
          master = PgPartitioning::PartitioningMaster.new(table, 'created_at', 1, 100)
          strategy = master.instance_variable_get :@strategy
          expect{strategy.partitioning!}.to raise_error( I18n.t "pg_partitioning.failure.column_type" )
        end
        
        it "raise error condition is blank" do
          master = PgPartitioning::PartitioningMaster.new(table, :id, 1)
          strategy = master.instance_variable_get :@strategy
          expect{strategy.partitioning!}.to raise_error( I18n.t "pg_partitioning.failure.blank_cond" )
        end
      end
    end
  end
  
  context "mode is date" do
    before do
      @master = PgPartitioning::PartitioningMaster.new(table, 'date_of_birth', 2, 'YYYMMHH24')
    end

    it { expect(@master.instance_variable_get(:@strategy).class).to be PgPartitioning::Strategies::Date }
    
    describe "partitioning!" do
      
      it_behaves_like "happy_partitioning"
      
      describe "generate right table name" do
        before do
          Bandit.delete_all
          clear_triggers(table)
          @master.partitioning
          @thief = create :thief
          @killer = create :killer
        end
            
        it{ expect(Bandit.all.size).to be 2 }
        it{ expect(Bandit.find_by_sql("SELECT * FROM bandits_001_05_00").first).to eq @killer }
        it{ expect(Bandit.find_by_sql("SELECT * FROM bandits_998_01_00").first).to eq @thief }
      end

      context "with invalid data" do
        it "raise error type of column is not date/time" do
          master = PgPartitioning::PartitioningMaster.new(table, 'id', 2, 'YYY')
          strategy = master.instance_variable_get :@strategy
          expect{strategy.partitioning!}.to raise_error( I18n.t "pg_partitioning.failure.column_type" )
        end
        
        it "raise error condition is blank" do
          master = PgPartitioning::PartitioningMaster.new(table, 'created_at', 2)
          strategy = master.instance_variable_get :@strategy
          expect{strategy.partitioning!}.to raise_error( I18n.t "pg_partitioning.failure.blank_cond" )
        end
      end
    end
  end
end
