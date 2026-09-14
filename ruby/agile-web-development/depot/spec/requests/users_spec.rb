require "rails_helper"

RSpec.describe "Users", type: :request do
  fixtures :users

  let(:user) { users(:one) }

  before { login_as user }

  describe "GET /users" do
    it "renders successfully" do
      get users_url
      expect(response).to be_successful
    end
  end

  describe "GET /users/new" do
    it "renders successfully" do
      get new_user_url
      expect(response).to be_successful
    end
  end

  describe "POST /users" do
    it "creates a user and redirects to the list" do
      expect {
        post users_url, params: { user: {
          email_address: "sam@example.org",
          name: "sam",
          password: "secret",
          password_confirmation: "secret"
        } }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(users_url)
    end
  end

  describe "GET /users/:id" do
    it "renders successfully" do
      get user_url(user)
      expect(response).to be_successful
    end
  end

  describe "GET /users/:id/edit" do
    it "renders successfully" do
      get edit_user_url(user)
      expect(response).to be_successful
    end
  end

  describe "PATCH /users/:id" do
    it "updates the user and redirects to the list" do
      patch user_url(user), params: { user: {
        email_address: user.email_address,
        name: user.name
      } }

      expect(response).to redirect_to(users_url)
    end

    context "when changing the password" do
      it "succeeds when the current password is correct" do
        patch user_url(user), params: { user: {
          email_address: user.email_address,
          name: user.name,
          current_password: "password",
          password: "secret",
          password_confirmation: "secret"
        } }

        expect(response).to redirect_to(users_url)
        expect(user.reload.authenticate("secret")).to be_truthy
      end

      it "fails when the current password is missing" do
        patch user_url(user), params: { user: {
          email_address: user.email_address,
          name: user.name,
          password: "secret",
          password_confirmation: "secret"
        } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(user.reload.authenticate("secret")).to be_falsy
      end

      it "fails when the current password is wrong" do
        patch user_url(user), params: { user: {
          email_address: user.email_address,
          name: user.name,
          current_password: "not the password",
          password: "secret",
          password_confirmation: "secret"
        } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(user.reload.authenticate("secret")).to be_falsy
      end
    end
  end

  describe "DELETE /users/:id" do
    it "destroys the user and redirects to the list" do
      expect {
        delete user_url(user)
      }.to change(User, :count).by(-1)

      expect(response).to redirect_to(users_url)
    end
  end

  describe "without being signed in" do
    before { logout }

    it "requires authentication to list users" do
      get users_url

      expect(response).to redirect_to(new_session_url)
    end

    it "requires authentication to view a user" do
      get user_url(user)

      expect(response).to redirect_to(new_session_url)
    end

    it "requires authentication to update a user" do
      patch user_url(user), params: { user: { name: "Hijacked Name" } }

      expect(response).to redirect_to(new_session_url)
      expect(user.reload.name).not_to eq("Hijacked Name")
    end

    it "requires authentication to destroy a user" do
      expect {
        delete user_url(user)
      }.not_to change(User, :count)

      expect(response).to redirect_to(new_session_url)
    end
  end
end
