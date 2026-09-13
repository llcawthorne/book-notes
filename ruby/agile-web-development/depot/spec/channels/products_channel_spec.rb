require "rails_helper"

RSpec.describe ProductsChannel, type: :channel do
  it "confirms the subscription" do
    subscribe

    expect(subscription).to be_confirmed
  end

  it "streams from the shared products broadcast" do
    subscribe

    expect(subscription).to have_stream_from("store/products")
  end
end
