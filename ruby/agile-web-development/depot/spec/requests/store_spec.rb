require "rails_helper"

RSpec.describe "Store", type: :request do
  fixtures :users, :products

  before { login_as users(:one) }

  describe "GET /" do
    it "renders the catalog" do
      get store_index_url

      expect(response).to be_successful
      assert_select "nav a", minimum: 4
      assert_select "main ul li", 3
      assert_select "h2", "The Pragmatic Programmer"
      assert_select "div", /\$[,\d]+\.\d\d/
    end

    it "makes each product's image a clickable add-to-cart control" do
      get store_index_url

      assert_select "form[action*='/line_items'] img", 3
    end
  end
end
