require_relative '../lib/pg_partitioning/input_master'

describe "PgPartitioning::InputMaster" do
  subject { PgPartitioning::InputMaster.new }

  it { is_expected.to respond_to :ask_mode }
  it { is_expected.to respond_to :ask_table_name }
  it { is_expected.to respond_to :ask_column_name }
  it { is_expected.to respond_to :ask_cond }
  it { is_expected.to respond_to :intro }
  it { is_expected.to respond_to :print_row }
  it { is_expected.to respond_to :info }
  it { is_expected.to respond_to :alert }
  it { is_expected.to respond_to :message }
  it { is_expected.to respond_to :text_color }

  describe "ask" do
    before do
      subject.instance_variable_set(:@error_message, nil) 
    end

    context "with invalid" do
      it "mode type" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.mode").and_return(5)
        subject.ask_mode
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.mode")
      end
      
      it "cond step" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.cond_step").and_return("bla")
        subject.ask_cond('step')
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.step")
      end
      
      it "cond date" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.cond_date").and_return("bla")
        subject.ask_cond('date')
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.pattern")
      end
    end
    
    context "with empty" do
      it "mode type" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.mode").and_return("")
        subject.ask_mode
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t 'pg_partitioning.failure.mode')
      end
      
      it "table name" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.table_name").and_return("")
        subject.ask_table_name
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.answer")
      end
      
      it "column name" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.column_name").and_return("")
        subject.ask_column_name
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.answer")
      end
      
      it "cond step" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.cond_step").and_return("")
        subject.ask_cond('step')
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.step")
      end
      
      it "cond date" do
        allow(subject).to receive(:ask).with(I18n.t "pg_partitioning.quests.cond_date").and_return("")
        subject.ask_cond('date')
        expect(subject.instance_variable_get(:@error_message)).to eq(I18n.t "pg_partitioning.failure.pattern")
      end
    end
  end
end
