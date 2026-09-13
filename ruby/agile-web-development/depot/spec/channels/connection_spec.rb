require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  fixtures :users

  let(:user) { users(:one) }
  let!(:session) { user.sessions.create!(user_agent: "RSpec", ip_address: "127.0.0.1") }

  it "identifies the connection by the user of a valid session cookie" do
    cookies.signed[:session_id] = session.id

    connect

    expect(connection.current_user).to eq(user)
  end

  it "connects anonymously when there is no session cookie" do
    connect

    expect(connection.current_user).to be_nil
  end

  it "connects anonymously when the session cookie doesn't match a session" do
    cookies.signed[:session_id] = -1

    connect

    expect(connection.current_user).to be_nil
  end
end
