class User < ApplicationRecord
  attr_accessor :current_password, :skip_current_password_check

  validates :name, presence: true, uniqueness: true
  validates :email_address, presence: true, uniqueness: true
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validate :current_password_must_match, if: :changing_password_on_existing_user?

  after_destroy :ensure_an_admin_remains

  class Error < StandardError
  end

  private

    def changing_password_on_existing_user?
      persisted? && password_digest_changed? && !skip_current_password_check
    end

    def current_password_must_match
      if current_password.blank?
        errors.add(:current_password, "can't be blank")
      elsif !BCrypt::Password.new(password_digest_was).is_password?(current_password)
        errors.add(:current_password, "is incorrect")
      end
    end

    def ensure_an_admin_remains
      if User.count.zero?
        raise Error, "Can't delete last user"
      end
    end
end
