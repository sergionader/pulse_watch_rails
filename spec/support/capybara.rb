require "capybara/rails"

Capybara.default_driver = :rack_test

RSpec.configure do |config|
  config.before(:each, :js, type: :system) do
    driven_by :selenium_headless
  end

  config.before(:each, type: :system) do |example|
    driven_by :rack_test unless example.metadata[:js]
  end
end
