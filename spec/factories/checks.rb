FactoryBot.define do
  factory :check do
    site_monitor
    status_code { 200 }
    response_time_ms { rand(50..500) }
    successful { true }
    error_message { nil }
    headers { {} }

    trait :successful do
      successful { true }
      status_code { 200 }
      error_message { nil }
    end

    trait :failed do
      successful { false }
      status_code { 500 }
      error_message { "Internal Server Error" }
    end

    trait :timeout do
      successful { false }
      status_code { nil }
      response_time_ms { nil }
      error_message { "Request timed out" }
    end
  end
end
