require 'rails_helper'

RSpec.describe Cart, type: :model do
  fixtures :all
  subject(:cart) { Cart.new }

  let(:book_one) { products(:pragprog) }
  let(:book_two) { products(:two) }

  describe "#add_product" do
    context "adding unique products" do
      before do
        cart.add_product(book_one).save!
        cart.add_product(book_two).save!
      end

      it "has two line items" do
        expect(cart.line_items.size).to eq(2)
      end
      it "has a total price of the two items' price" do
        expect(cart.total_price).to eq(book_one.price + book_two.price)
      end
    end

    context "adding duplicate products" do
      before do
        cart.add_product(book_one).save!
        cart.add_product(book_one).save!
      end

      it "has one line item" do
        expect(cart.line_items.size).to eq(1)
      end
      it "has a line item with a quantity of 2" do
        expect(cart.line_items.first.quantity).to eq(2)
      end
      it "has a total price of twice the product's price" do
        expect(cart.total_price).to eq(book_one.price * 2)
      end
    end

    context "price capture" do
      it "captures the product's current price on the line item" do
        line_item = cart.add_product(book_one)

        expect(line_item.price).to eq(book_one.price)
      end

      it "keeps the originally captured price after the product's price changes" do
        line_item = cart.add_product(book_one)
        line_item.save!
        original_price = line_item.price

        book_one.update!(price: original_price + 10)
        line_item.reload

        expect(line_item.price).to eq(original_price)
        expect(line_item.price).not_to eq(book_one.price)
      end

      it "keeps the captured price when the quantity increments" do
        first_item = cart.add_product(book_one)
        first_item.save!

        same_item = cart.add_product(book_one)

        expect(same_item.id).to eq(first_item.id)
        expect(same_item.quantity).to eq(2)
        expect(same_item.price).to eq(first_item.price)
      end
    end
  end
end
