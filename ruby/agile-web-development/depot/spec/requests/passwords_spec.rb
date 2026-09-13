require "rails_helper"

RSpec.describe "Passwords", type: :request do
  fixtures :users

  let(:user) { users(:one) }
  let(:token) { user.password_reset_token }

  describe "GET /passwords/new" do
    it "renders successfully" do
      get new_password_url
      expect(response).to be_successful
    end
  end

  describe "POST /passwords" do
    context "when the email address belongs to a user" do
      it "emails reset instructions and redirects to sign in" do
        expect {
          post passwords_url, params: { email_address: user.email_address }
        }.to have_enqueued_mail(PasswordsMailer, :reset)

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when the email address is unknown" do
      it "does not send an email, but redirects the same as a known address" do
        expect {
          post passwords_url, params: { email_address: "nobody@example.com" }
        }.not_to have_enqueued_mail(PasswordsMailer, :reset)

        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end
    end
  end

  describe "GET /passwords/:token/edit" do
    context "with a valid token" do
      it "renders successfully" do
        get edit_password_url(token)
        expect(response).to be_successful
      end
    end

    context "with an invalid token" do
      it "redirects to request a new reset link" do
        get edit_password_url("not-a-real-token")

        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end
    end
  end

  describe "PATCH /passwords/:token" do
    context "with matching password and confirmation" do
      it "updates the password and redirects to sign in" do
        patch password_url(token),
          params: { password: "new_password", password_confirmation: "new_password" }

        expect(response).to redirect_to(new_session_path)
        expect(User.authenticate_by(email_address: user.email_address, password: "new_password")).to eq(user)
      end
    end

    context "with a mismatched confirmation" do
      it "does not update the password and redirects back to the edit form" do
        patch password_url(token),
          params: { password: "new_password", password_confirmation: "does not match" }

        expect(response).to redirect_to(edit_password_path(token))
        expect(flash[:alert]).to eq("Passwords did not match.")
        expect(User.authenticate_by(email_address: user.email_address, password: "new_password")).to be_nil
      end
    end
  end
end
