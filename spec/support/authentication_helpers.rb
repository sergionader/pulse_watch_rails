module AuthenticationHelpers
  def sign_in(user = nil)
    user ||= create(:user)
    post login_path, params: { email: user.email, password: user.password }
    user
  end

  def sign_in_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.include AuthenticationHelpers, type: :system
end
