class Bandit < ActiveRecord::Base
  belongs_to :gang
  has_many :crimes, dependent: :destroy
end
