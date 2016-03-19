require 'rails_helper'

RSpec.describe Gang, type: :model do
  subject { build :gang }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  
  it { expect(Gang.reflect_on_association(:bandits).macro).to eq :has_many }
end
