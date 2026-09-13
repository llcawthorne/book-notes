require "rails_helper"

RSpec.describe ChargeOrderJob, type: :job do
  fixtures :orders

  let(:order) { orders(:one) }
  let(:pay_type_params) { { "routing_number" => "123456", "account_number" => "987654" } }

  it "charges the order with the given payment params" do
    expect(order).to receive(:charge!).with(pay_type_params)

    described_class.perform_now(order, pay_type_params)
  end

  it "is enqueued on the default queue" do
    expect { described_class.perform_later(order, pay_type_params) }
      .to have_enqueued_job(described_class).on_queue("default")
  end
end
