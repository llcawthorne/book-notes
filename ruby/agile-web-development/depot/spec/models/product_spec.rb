require "rails_helper"

RSpec.describe Product, type: :model do
  fixtures :products

  def attach_image(product, filename:, content_type:)
    product.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files", filename)),
      filename: filename,
      content_type: content_type
    )
    product
  end

  describe "validations" do
    context "with no attributes" do
      subject(:product) { Product.new }

      it { is_expected.to be_invalid }

      it "requires a title, description, price, and image" do
        product.valid?

        expect(product.errors[:title]).to be_present
        expect(product.errors[:description]).to be_present
        expect(product.errors[:price]).to be_present
        expect(product.errors[:image]).to be_present
      end
    end

    describe "price" do
      subject(:product) do
        attach_image(Product.new(title: "My Book Title", description: "yyy"),
          filename: "lorem.jpg", content_type: "image/jpeg")
      end

      it "rejects a negative price" do
        product.price = -1

        expect(product).to be_invalid
        expect(product.errors[:price]).to eq([ "must be greater than or equal to 0.01" ])
      end

      it "rejects a zero price" do
        product.price = 0

        expect(product).to be_invalid
        expect(product.errors[:price]).to eq([ "must be greater than or equal to 0.01" ])
      end

      it "accepts a positive price" do
        product.price = 1

        expect(product).to be_valid
      end
    end

    describe "image" do
      subject(:product) { Product.new(title: "My Book Title", description: "yyy", price: 1) }

      it "accepts a JPEG image" do
        attach_image(product, filename: "lorem.jpg", content_type: "image/jpeg")

        expect(product).to be_valid
      end

      it "rejects an SVG image" do
        attach_image(product, filename: "logo.svg", content_type: "image/svg+xml")

        expect(product).to be_invalid
      end
    end

    describe "title" do
      subject(:product) do
        attach_image(Product.new(description: "yyy", price: 1),
          filename: "lorem.jpg", content_type: "image/jpeg")
      end

      it "must be unique" do
        product.title = products(:pragprog).title

        expect(product).to be_invalid
        expect(product.errors[:title]).to eq([ "has already been taken" ])
      end
    end
  end
end
