# frozen_string_literal: true

FactoryBot.define do
  factory :author do
    sequence(:name) { |n| "Joe #{n}" }
  end

  factory :blog do
    sequence(:name) { |n| "Blog #{n}" }
    sequence(:content) { |n| "some blog stuff #{n}" }
    association :author
  end

  factory :tag do
    sequence(:name) { |n| "tag-#{n}" }
  end

  factory :blog_tags do
    association :tag
    association :blog
  end
end
