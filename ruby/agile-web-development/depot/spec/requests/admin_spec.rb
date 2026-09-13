require "rails_helper"

RSpec.describe "Admin", type: :request do
  fixtures :users

  describe "GET /admin" do
    context "when logged in" do
      before { login_as users(:one) }

      it "renders successfully" do
        get admin_url
        expect(response).to be_successful
      end
    end

    context "when not logged in" do
      it "redirects to the sign in page" do
        get admin_url
        expect(response).to redirect_to(new_session_url)
      end
    end
  end
end
