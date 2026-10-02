require "rails_helper"

RSpec.describe User, type: :model do
  fixtures :all

  subject(:user) do
    User.new(name: "New User", email_address: "new_user@example.com",
      password: "secret", password_confirmation: "secret")
  end

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a name" do
      user.name = nil

      expect(user).to be_invalid
      expect(user.errors[:name]).to be_present
    end

    it "requires a unique name" do
      user.name = users(:one).name

      expect(user).to be_invalid
      expect(user.errors[:name]).to eq([ "has already been taken" ])
    end

    it "requires an email address" do
      user.email_address = nil

      expect(user).to be_invalid
      expect(user.errors[:email_address]).to be_present
    end

    it "requires a unique email address" do
      user.email_address = users(:one).email_address

      expect(user).to be_invalid
      expect(user.errors[:email_address]).to eq([ "has already been taken" ])
    end

    it "requires the email address to contain an @ symbol" do
      user.email_address = "not-an-email"

      expect(user).to be_invalid
      expect(user.errors[:email_address]).to eq([ "must contain an @ symbol" ])
    end

    it "does not duplicate the error when the email address is blank" do
      user.email_address = ""

      expect(user).to be_invalid
      expect(user.errors[:email_address]).to eq([ "can't be blank" ])
    end

    it "requires the password confirmation to match" do
      user.password_confirmation = "does not match"

      expect(user).to be_invalid
      expect(user.errors[:password_confirmation]).to be_present
    end
  end

  describe "changing the password on an existing user" do
    let(:existing_user) { users(:one) }

    it "does not require current_password when the password isn't changing" do
      existing_user.name = "Renamed"

      expect(existing_user).to be_valid
    end

    it "succeeds when current_password matches" do
      existing_user.current_password = "password"
      existing_user.password = "new secret"
      existing_user.password_confirmation = "new secret"

      expect(existing_user).to be_valid
    end

    it "fails when current_password is blank" do
      existing_user.password = "new secret"
      existing_user.password_confirmation = "new secret"

      expect(existing_user).to be_invalid
      expect(existing_user.errors[:current_password]).to be_present
    end

    it "fails when current_password is wrong" do
      existing_user.current_password = "not the password"
      existing_user.password = "new secret"
      existing_user.password_confirmation = "new secret"

      expect(existing_user).to be_invalid
      expect(existing_user.errors[:current_password]).to eq([ "is incorrect" ])
    end

    it "allows the check to be bypassed for the token-verified password reset flow" do
      existing_user.skip_current_password_check = true
      existing_user.password = "new secret"
      existing_user.password_confirmation = "new secret"

      expect(existing_user).to be_valid
    end
  end

  describe "email normalization" do
    it "strips whitespace and downcases the email address" do
      user.email_address = "  New_User@Example.com  "
      user.save!

      expect(user.email_address).to eq("new_user@example.com")
    end
  end

  describe "destroying the last user" do
    it "is prevented" do
      last_user = User.create!(name: "Last", email_address: "last@example.com",
        password: "secret", password_confirmation: "secret")
      User.where.not(id: last_user.id).delete_all

      expect { last_user.destroy }.to raise_error(User::Error, "Can't delete last user")
      expect(User.count).to eq(1)
    end
  end

  describe "destroying a user when others remain" do
    it "succeeds" do
      user.save!

      expect { user.destroy }.not_to raise_error
      expect(User.exists?(user.id)).to be false
    end
  end
end
