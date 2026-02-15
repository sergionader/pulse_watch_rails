FactoryBot.define do
  factory :incident_update do
    incident
    status { :investigating }
    message { Faker::Lorem.paragraph }
  end
end
