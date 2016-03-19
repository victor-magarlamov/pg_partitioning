FactoryGirl.define do
  factory :bandit do
    date_of_birth  40.years.ago
    name           Faker::Lorem.characters(10)
    specialization Faker::Lorem.characters(5)
    association    :gang
    
    trait :thief do
      id 1
      specialization 'thief'
      date_of_birth Date.new(1998, 1, 1)
    end
    
    trait :killer do
      id 200
      specialization 'killer'
      date_of_birth Date.new(2001, 5, 10)
    end
    
    factory :thief, traits: [:thief]
    factory :killer, traits: [:killer]
  end
end
