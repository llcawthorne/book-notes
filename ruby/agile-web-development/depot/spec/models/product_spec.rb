require "rails_helper"

RSpec.describe Product, type: :model do
  fixtures :all

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

    describe "description" do
      subject(:product) do
        attach_image(Product.new(title: "My Book Title", price: 1),
          filename: "lorem.jpg", content_type: "image/jpeg")
      end

      it "requires an English description even when another locale is filled in" do
        product.description_translations = { es: "Descripción en español" }

        expect(product).to be_invalid
        expect(product.errors[:description]).to be_present
      end

      it "is valid once the English description is present, regardless of other locales" do
        product.description_translations = { en: "An English description" }

        expect(product).to be_valid
      end
    end
  end

  describe "translated descriptions" do
    it "falls back to the English description when a locale has no translation at all" do
      product = products(:pragprog)
      expect(product.translations.find_by(locale: :it)).to be_nil

      italian_description = Globalize.with_locale(:it) { product.description }

      expect(italian_description).to eq(Globalize.with_locale(:en) { product.description })
    end

    it "never translates Japanese -- descriptions always fall back to English" do
      product = products(:pragprog)
      expect(product.translations.find_by(locale: :ja)).to be_nil

      expect(Globalize.with_locale(:ja) { product.description }).to eq(Globalize.with_locale(:en) { product.description })
    end

    it "returns the localized description once one is entered" do
      # fixtures one_es ("MiTexto") and two_de ("MeinText") exercise this via
      # fixture data rather than a runtime .create!, since a locale each
      # product already has a fixture translation for can't be re-created.
      expect(Globalize.with_locale(:es) { products(:one).description }).to eq("MiTexto")
      expect(Globalize.with_locale(:en) { products(:one).description }).not_to eq("MiTexto")

      expect(Globalize.with_locale(:de) { products(:two).description }).to eq("MeinText")
    end

    it "lets a territory locale fall back to its base language before English" do
      # products(:one) has a real Spanish translation (fixture one_es) but
      # no Spain-specific one, so es-ES should reuse the Spanish text rather
      # than dropping all the way to English (see
      # config/initializers/globalize.rb).
      product = products(:one)
      expect(product.translations.find_by(locale: "es-ES")).to be_nil

      expect(Globalize.with_locale(:"es-ES") { product.description }).to eq("MiTexto")
    end

    it "falls back to English when a locale's translation is blank, not just missing" do
      product = products(:pragprog)
      product.translations.create!(locale: :it, description: "")

      expect(Globalize.with_locale(:it) { product.description }).to eq(Globalize.with_locale(:en) { product.description })
    end
  end
end
