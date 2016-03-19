RSpec.shared_examples "happy_partitioning" do
  describe "success partitioning!" do
    before do
      Bandit.delete_all
      clear_triggers(table)
      @master.partitioning
    end

    it "create before insert trigger" do
      expect(insert_master_function_exists?(table)).to be true
    end
        
    it "create after insert trigger" do
      expect(after_insert_trigger_exists?(table)).to be true
    end

    it "create bandit" do
      expect{create :bandit}.to change{Bandit.all.size}.from(0).to(1)
    end
        
    describe "insert into nested table" do
      before { bandit = create :bandit }
          
      it{ expect(Bandit.count_by_sql "SELECT COUNT(*) FROM ONLY bandits").to be 0 }
      it{ expect(Bandit.count_by_sql "SELECT COUNT(*) FROM bandits").to be 1 }
    end
  end
end
