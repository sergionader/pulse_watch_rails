require "rails_helper"

RSpec.describe "Sessions" do
  let!(:user) { create(:user, email: "admin@example.com", password: "test1234##") }

  describe "GET /login" do
    it "renders the login form" do
      get login_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects to admin if already signed in" do
      sign_in(user)
      get login_path
      expect(response).to redirect_to(admin_monitors_path)
    end
  end

  describe "POST /login" do
    context "with valid credentials" do
      it "signs in and redirects to admin" do
        post login_path, params: { email: "admin@example.com", password: "test1234##" }
        expect(response).to redirect_to(admin_monitors_path)
        follow_redirect!
        expect(response.body).to include("Signed in successfully")
      end
    end

    context "with invalid credentials" do
      it "re-renders login with error" do
        post login_path, params: { email: "admin@example.com", password: "wrong" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email or password")
      end
    end

    context "with non-existent email" do
      it "re-renders login with error" do
        post login_path, params: { email: "nobody@example.com", password: "test1234##" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /logout" do
    it "signs out and redirects to login" do
      sign_in(user)
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "admin access without authentication" do
    it "redirects to login" do
      get admin_monitors_path
      expect(response).to redirect_to(login_path)
    end
  end
end
