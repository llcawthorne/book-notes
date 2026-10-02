require "rails_helper"

RSpec.describe "SupportRequests", type: :request do
  fixtures :all

  before { login_as users(:one) }

  let(:support_request) { support_requests(:one) }

  describe "GET /support_requests" do
    it "renders successfully" do
      get support_requests_url
      expect(response).to be_successful
    end
  end

  describe "PATCH /support_requests/:id" do
    it "records the response, emails it to the requester, and redirects to the index" do
      expect {
        patch support_request_url(support_request), params: { support_request: { response: "We'll look into it." } }
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(ActionMailer::Base.deliveries.last.to).to eq([ support_request.email ])
      expect(response).to redirect_to(support_requests_path)
      expect(support_request.reload.response.to_plain_text).to eq("We'll look into it.")
    end
  end
end
