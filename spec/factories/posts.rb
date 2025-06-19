FactoryBot.define do
  factory :post do
    association :user
    
    title { Faker::Lorem.sentence(word_count: rand(3..8)) }
    content { Faker::Lorem.paragraph(sentence_count: rand(5..15)) }
    published { [true, false].sample }
    created_at { rand(30.days).seconds.ago }
    
    trait :unpublished do
      published { false }
    end
    
    trait :published do
      published { true }
    end
    
    trait :long_content do
      content { Faker::Lorem.paragraph(sentence_count: rand(50..100)) }
    end
  end
end 