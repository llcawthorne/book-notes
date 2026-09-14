class CreateProductTranslationsAndMoveDescription < ActiveRecord::Migration[8.0]
  class Product < ActiveRecord::Base
  end

  class ProductTranslation < ActiveRecord::Base
  end

  def up
    create_table :product_translations do |t|
      t.references :product, null: false, foreign_key: true
      t.string :locale, null: false
      t.text :description

      t.timestamps
    end
    add_index :product_translations, [ :product_id, :locale ], unique: true

    Product.reset_column_information
    Product.find_each do |product|
      ProductTranslation.create!(product_id: product.id, locale: "en", description: product.description)
    end

    remove_column :products, :description
  end

  def down
    add_column :products, :description, :text

    Product.reset_column_information
    ProductTranslation.where(locale: "en").find_each do |translation|
      Product.where(id: translation.product_id).update_all(description: translation.description)
    end

    drop_table :product_translations
  end
end
