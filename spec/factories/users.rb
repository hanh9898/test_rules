FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    age { rand(18..65) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
    user_type { %w[regular premium admin].sample }
    active { [true, false].sample }
    
    trait :guest do
      user_type { "guest" }
      name { nil }
      email { nil }
    end
    
    trait :inactive do
      active { false }
    end
    
    trait :with_posts do
      after(:create) do |user|
        create_list(:post, rand(1..5), user: user)
      end
    end
  end
end 