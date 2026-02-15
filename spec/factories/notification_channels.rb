FactoryBot.define do
  factory :notification_channel do
    channel_type { :email }
    config { { address: Faker::Internet.email } }
    active { true }

    trait :email do
      channel_type { :email }
      config { { address: Faker::Internet.email } }
    end

    trait :slack do
      channel_type { :slack }
      config { { webhook_url: "https://hooks.slack.com/services/#{Faker::Alphanumeric.alphanumeric(number: 10)}" } }
    end

    trait :discord do
      channel_type { :discord }
      config { { webhook_url: "https://discord.com/api/webhooks/#{Faker::Number.number(digits: 18)}/#{Faker::Alphanumeric.alphanumeric(number: 68)}" } }
    end

    trait :inactive do
      active { false }
    end
  end
end
