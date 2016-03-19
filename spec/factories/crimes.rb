FactoryGirl.define do
  factory :crime do
    title Faker::Lorem.characters(10)
    association :bandit
  end
end
