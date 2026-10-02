require "rails_helper"

RSpec.describe SupportRequest, type: :model do
  fixtures :all

  subject(:support_request) do
    SupportRequest.new(email: "chris@example.com", subject: "Need help", body: "I can't check out!")
  end

  it { is_expected.to be_valid }

  it "does not require an order" do
    support_request.order = nil

    expect(support_request).to be_valid
  end

  it "can be associated with an order" do
    support_request.order = orders(:one)

    expect(support_request).to be_valid
    expect(support_request.order).to eq(orders(:one))
  end

  describe "#response" do
    it "accepts a rich text response" do
      support_request.save!
      support_request.response = "<div>We'll look into it.</div>"

      expect(support_request.response.to_plain_text).to eq("We'll look into it.")
    end
  end
end
