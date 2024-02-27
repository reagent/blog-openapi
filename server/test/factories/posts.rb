FactoryBot.define do
  factory :post do
    title { 'title' }
    body { 'body' }
  end

  trait :published do
    published_at { 1.day.ago }
  end

  trait :draft do
    published_at { 1.day.from_now }
  end
end
