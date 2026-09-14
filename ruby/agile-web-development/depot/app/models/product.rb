class Product < ApplicationRecord
  translates :description, fallbacks_for_empty_translations: true

  has_many :line_items
  before_destroy :ensure_not_referenced_by_any_line_item

  has_one_attached :image
  after_commit -> { broadcast_refresh_later_to "products" }
  validates :title, :image, presence: true
  validates :title, uniqueness: true
  validates :title, length: { minimum: 10 }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validate :acceptable_image
  validate :english_description_present

  # We only publish English-language books, so the English description is
  # the one that's always required; other locales are optional and fall
  # back to it (see config/initializers/globalize.rb) when blank.
  def english_description_present
    if Globalize.with_locale(:en) { description }.blank?
      errors.add(:description, "can't be blank")
    end
  end

  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG or PNG image")
    end
  end

  private

    # ensure that there are no line items that reference this product
    def ensure_not_referenced_by_any_line_item
      unless line_items.empty?
        errors.add(:base, "Line Items present")
        throw :abort
      end
    end
end
