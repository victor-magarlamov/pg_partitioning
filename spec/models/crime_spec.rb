require 'rails_helper'

RSpec.describe Crime, type: :model do
  subject { build :crime }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  
  it { expect(Crime.reflect_on_association(:bandit).macro).to eq :belongs_to }
end
