require 'rails_helper'

RSpec.describe Bandit, type: :model do
  subject { build :bandit }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :specialization }
  it { is_expected.to respond_to :date_of_birth }
  
  it { expect(Bandit.reflect_on_association(:gang).macro).to eq :belongs_to }
  it { expect(Bandit.reflect_on_association(:crimes).macro).to eq :has_many }
end
