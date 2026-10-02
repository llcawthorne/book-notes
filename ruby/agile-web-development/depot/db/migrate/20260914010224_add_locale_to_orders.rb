class AddLocaleToOrders < ActiveRecord::Migration[8.0]
  def change
    # Captured from I18n.locale at checkout time (see OrdersController#create)
    # so OrderMailer -- rendered later, in a background job with no request
    # to inherit a locale from -- knows what language/currency to use.
    add_column :orders, :locale, :string, null: false, default: "en"
  end
end
