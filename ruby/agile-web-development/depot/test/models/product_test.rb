require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image].any?
  end

  test "product price must be positive" do
    product = Product.new(title:       "My Book Title",
                          description: "yyy")
    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"),
                         filename: "lorem.jpg", content_type: "image/jpeg")
    product.price = -1
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01" ],
      product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01" ],
      product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(filename, content_type)
    Product.new(
      title:        "My Book Title",
      description:  "yyy",
      price:        1
    ).tap do |product|
      product.image.attach(
        io: File.open("test/fixtures/files/#{filename}"), filename:, content_type:)
    end
  end

  test "image url" do
    product = new_product("lorem.jpg", "image/jpeg")
    assert product.valid?, "image/jpeg must be valid"

    product = new_product("logo.svg", "image/svg+xml")
    assert_not product.valid?, "image/svg+xml must be invalid"
  end

  test "product is not valid without a unique title" do
    product = Product.new(title:        products(:pragprog).title,
                          description:  "yyy",
                          price:        1)
    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"),
                         filename: "lorem.jpg", content_type: "image/jpeg")

    assert product.invalid?
    assert_equal [ "has already been taken" ], product.errors[:title]
  end

  def new_product_without_description
    Product.new(title: "My Book Title", price: 1).tap do |product|
      product.image.attach(
        io: File.open("test/fixtures/files/lorem.jpg"), filename: "lorem.jpg", content_type: "image/jpeg")
    end
  end

  test "requires an English description even when another locale is filled in" do
    product = new_product_without_description
    product.description_translations = { es: "Descripción en español" }

    assert product.invalid?
    assert product.errors[:description].any?
  end

  test "is valid once the English description is present, regardless of other locales" do
    product = new_product_without_description
    product.description_translations = { en: "An English description" }

    assert product.valid?
  end

  test "falls back to the English description when a locale has no translation at all" do
    product = products(:pragprog)
    assert_nil product.translations.find_by(locale: :it)

    italian_description = Globalize.with_locale(:it) { product.description }

    assert_equal Globalize.with_locale(:en) { product.description }, italian_description
  end

  test "Japanese is deliberately not translated -- descriptions always fall back to English" do
    product = products(:pragprog)
    assert_nil product.translations.find_by(locale: :ja)

    assert_equal Globalize.with_locale(:en) { product.description },
      Globalize.with_locale(:ja) { product.description }
  end

  test "returns the localized description once one is entered" do
    # fixtures one_es ("MiTexto") and two_de ("MeinText") exercise this via
    # fixture data rather than a runtime .create!, since a locale each
    # product already has a fixture translation for can't be re-created.
    assert_equal "MiTexto", Globalize.with_locale(:es) { products(:one).description }
    assert_not_equal "MiTexto", Globalize.with_locale(:en) { products(:one).description }

    assert_equal "MeinText", Globalize.with_locale(:de) { products(:two).description }
  end

  test "a territory locale falls back to its base language before English" do
    # products(:one) has a real Spanish translation (fixture one_es) but no
    # Spain-specific one, so es-ES should reuse the Spanish text rather than
    # dropping all the way to English (config/initializers/globalize.rb).
    product = products(:one)
    assert_nil product.translations.find_by(locale: "es-ES")

    assert_equal "MiTexto", Globalize.with_locale(:"es-ES") { product.description }
  end

  test "falls back to English when a locale's translation is blank, not just missing" do
    product = products(:pragprog)
    product.translations.create!(locale: :it, description: "")

    assert_equal Globalize.with_locale(:en) { product.description },
      Globalize.with_locale(:it) { product.description }
  end
end
