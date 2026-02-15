FactoryBot.define do
  factory :incident do
    title { "#{Faker::Hacker.ingverb.capitalize} #{Faker::Hacker.noun}" }
    status { :investigating }
    severity { :minor }

    trait :investigating do
      status { :investigating }
    end

    trait :identified do
      status { :identified }
    end

    trait :monitoring do
      status { :monitoring }
    end

    trait :resolved do
      status { :resolved }
      resolved_at { Time.current }
    end

    trait :minor do
      severity { :minor }
    end

    trait :major do
      severity { :major }
    end

    trait :critical do
      severity { :critical }
    end
  end
end
