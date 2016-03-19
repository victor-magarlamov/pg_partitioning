class Gang < ActiveRecord::Base
  has_many :bandits, dependent: :destroy
end
