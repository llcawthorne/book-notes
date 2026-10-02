require "rails_helper"

RSpec.describe "Sessions", type: :request do
  fixtures :all

  let(:user) { users(:one) }

  describe "GET /session/new" do
    it "renders successfully" do
      get new_session_url
      expect(response).to be_successful
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "starts a session and redirects to the admin area" do
        expect {
          post session_url, params: { email_address: user.email_address, password: "password" }
        }.to change(user.sessions, :count).by(1)

        expect(response).to redirect_to(admin_url)
      end

      it "returns to the page that required authentication" do
        get admin_url
        expect(response).to redirect_to(new_session_url)

        post session_url, params: { email_address: user.email_address, password: "password" }

        expect(response).to redirect_to(admin_url)
      end
    end

    context "with an invalid password" do
      it "does not start a session and redirects back to sign in" do
        expect {
          post session_url, params: { email_address: user.email_address, password: "wrong" }
        }.not_to change(user.sessions, :count)

        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("Try another email address or password.")
      end
    end

    context "with an unknown email address" do
      it "does not start a session" do
        expect {
          post session_url, params: { email_address: "nobody@example.com", password: "password" }
        }.not_to change(Session, :count)

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when no administrator exists yet" do
      before { User.delete_all }

      it "creates the first administrator from whatever was submitted and starts a session" do
        expect {
          post session_url, params: { email_address: "new_admin@example.com", password: "secret" }
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(admin_url)

        admin = User.last
        expect(admin.email_address).to eq("new_admin@example.com")
        expect(admin.authenticate("secret")).to be_truthy
      end

      it "does not bootstrap an administrator with a blank password" do
        expect {
          post session_url, params: { email_address: "new_admin@example.com", password: "" }
        }.not_to change(User, :count)

        expect(response).to redirect_to(new_session_path)
      end

      it "goes back to requiring real credentials once an administrator exists" do
        post session_url, params: { email_address: "new_admin@example.com", password: "secret" }
        delete session_url

        expect {
          post session_url, params: { email_address: "someone_else@example.com", password: "whatever" }
        }.not_to change(User, :count)

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE /session" do
    it "terminates the current session and redirects to sign in" do
      post session_url, params: { email_address: user.email_address, password: "password" }

      expect {
        delete session_url
      }.to change(Session, :count).by(-1)

      expect(response).to redirect_to(new_session_path)
    end
  end
end
