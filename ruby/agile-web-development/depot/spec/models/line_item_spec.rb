require "rails_helper"

RSpec.describe LineItem, type: :model do
  fixtures :all

  subject(:line_item) do
    LineItem.new(product: products(:pragprog), quantity: 3, price: products(:pragprog).price)
  end

  describe "validations" do
    it "requires a product" do
      line_item.product = nil

      expect(line_item).to be_invalid
      expect(line_item.errors[:product]).to be_present
    end

    it "does not require an order" do
      line_item.order = nil

      expect(line_item).to be_valid
    end

    it "does not require a cart" do
      line_item.cart = nil

      expect(line_item).to be_valid
    end
  end

  describe "#total_price" do
    it "multiplies the captured price by the quantity" do
      expect(line_item.total_price).to eq(products(:pragprog).price * 3)
    end

    it "uses the captured price rather than the product's current price" do
      products(:pragprog).update!(price: line_item.price + 100)

      expect(line_item.total_price).to eq(line_item.price * 3)
    end
  end

  describe "#decrement_quantity!" do
    it "reduces the quantity by one when more than one remains" do
      line_item.save!

      expect { line_item.decrement_quantity! }.to change(line_item, :quantity).from(3).to(2)
      expect(line_item).to be_persisted
    end

    it "destroys the line item once the quantity would reach zero" do
      line_item.quantity = 1
      line_item.save!

      line_item.decrement_quantity!

      expect(line_item).to be_destroyed
      expect(LineItem.exists?(line_item.id)).to be false
    end
  end

  describe "#increment_quantity!" do
    it "increases the quantity by one" do
      line_item.save!

      expect { line_item.increment_quantity! }.to change(line_item, :quantity).from(3).to(4)
      expect(line_item).to be_persisted
    end
  end
end
