class AddExpiresOnToCoupons < ActiveRecord::Migration[8.0]
  def change
    add_column :coupons, :expires_on, :date
  end
end
