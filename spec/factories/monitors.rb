FactoryBot.define do
  factory :site_monitor do
    name { Faker::Internet.domain_name }
    url { Faker::Internet.url(scheme: "https") }
    http_method { "GET" }
    expected_status { 200 }
    check_interval_seconds { 300 }
    timeout_ms { 5000 }
    is_active { true }
    current_status { :up }

    trait :up do
      current_status { :up }
    end

    trait :down do
      current_status { :down }
    end

    trait :degraded do
      current_status { :degraded }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
