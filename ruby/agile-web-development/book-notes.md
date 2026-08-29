# Agile Web Development with Rails 8

## Part 1 - Getting Started

### Chapter 1 - Installing Rails

### Chapter 2 - Instant Gratification

- Use `rails new demo` to start a new app named `demo`.
- `bin/rails about` from your project directory shows a lot of information
  about your project. You could also `bundle exec rails about`.
- `bin/dev` will start a dev server.
- `bin/rails generate controller Say hello goodbye` will generate a `Say`
  controller with `hello` and `goodbye` actions.
- By default, Rails looks for templates in a file with the same name as the
  action it's handling. The views for say live in `app/views/say` and the
  `hello` action shows `hello.html.erb`. Controllers go in `app/controllers`.
- Content between `<%=` and `%>` in an erb file is interpreted as Ruby code
  and executed. The results are converted to a string and displayed.
- `<%` and `%>` embed code without inserting the results in the output.
- An instance variable in your controller can be declared in the `hello`
  method to access from the `hello.html.erb` template like `@time = Time.now`.
  The time is data and should be supplied to the view by the controller even if
  we could have embedded a `Time.now` call in the view.
- The default is for `http://localhost:3000/say/hello` to invoke the `hello`
  method of the `say` controller.
- You can link to `/say/goodbye` with
  `<%= link_to "Goodbye", say_goodbye_path %>`.

### Chapter 3 - The Architecture of Rails Applications

- The *model* is responsible for maintaining the state of the application. It
  is more than just the date; it enforce all the business rules that apply to
  the data.
- The *view* is responsible for generating a user interface, normally based on
  data in the model. The view might present users with various ways to input
  data, but the view itself never handles incoming data.
- *Controllers* orchestrate the application. They receive events from the
  outside world (normally, user input), interact with the model, and display
  an appropriate view to the user.
- In a Rails application, the request is first sent to a router which identifies
  a particular method (called an *action*) on a controller. The action may look
  at data in the request, interact with the model, and/or cause other actions to
  be invoked. Eventually the action prepares information for the view, which
  renders something to the user.
- Oject-relational mapping (ORM) libraries map database tables to classes. If
  our database has a table called **orders**, our program with have an **Order**
  class. Rows in the table correspond to objects of the class. Within that
  object, attributes are used to get and set the individual columns. Our
  **Order** object has methods to get and set the amount, the sales tax, etc.
  Our class objects will have methods that perform table-level operations also,
  like **find** to find by ID. Instance methods perform operations on individual
  rows. Active Record is the ORM in Rails.

  ```ruby
  order = Order.find(1)
  puts "Customer #{order.customer_id}, amount=$#{order.amount}"

  Order.where(name: 'dave').each do |order|
    puts order.amount
  end

  Order.where(name: 'dave').each do |order|
    order.pay_type = "Purchase order"
    order.save
  end
  ```

- Active Storage allows you to attach files from cloud storage services like
  S3 to your Active Records.
- Action Pack provides support for both views and controllers.
- Embedded Ruby (ERB) files support embedding Ruby snippets in the view, but
  be judicious about putting code directly in the view layer instead of using
  logic in the model or controller.

### Chapter 4 - Introduction to Ruby

- Everything you manipulate in Ruby is an object, and the results of those
  manipulations are themselves objects.
- You create objects with a *constructor*. The standard constructor is called
  **new**. To construct a **LineItem** class:

  ```ruby
  line_item_one = LineItem.new
  line_item_one.quantity = 1
  line_item_one.sku      = "AUTO_B_00"
  line_item_one.quantity() # => 1
  "dave".length            # => 4
  ```

- You invoke methods on objects by sending a message to the object containing
  the method's name along with any parameters the method may need. When an
  object receives a message, it looks at its own class for the method.
- Parentheses are generally optional in method calls.
- Local variables, method parameters, and method names should all start with
  a lowercase letter or an underscore. Instance variables begin with `@`.
  You separate words in a multiword method or variable name with underscores
  (`_`). Class names, module names, and constants must start with an uppercase
  letter. By convention, they use capitalization rather than underscores to
  distinguish the start of words within their name. Rails uses *symbols* to
  identify things. A symbol looks like a variable name but is prefixed with a
  colon (`:`). You can think of them as string literals magically made into
  constants.
- You define a method with `def` and end the definition with `end`. You don't 
  need a semicolon at the end of a statement as long as each statement is on a
  separate line. Ruby comments start with `#` and go to the end of the line.
  Identation isn't significant, and 2 spaces is standard. Ruby doesn't use
  braces to delimit the bodies of compound statements and definitions; you just
  end the body with the `end` keyword. The `return` keyword is optional and if
  not present the results of the last expression evaluated are returned.
- String literals can be single quoted (`'`) or double quoted (`"`). Single
  quoted strings involve very little processing. Double quoted strings
  do *substitutions* such as replacing "\n" with the newline character.
  Ruby also performs *expression interpolation* in duoble-quote strings where
  the sequence `#{expression}` is replaced.
- Ruby's arrays and hashes are indexed collections. They store collections of
  objects accessible with a key. The key is an integer for arrays and any
  object for hashes. Both grow as needed and can hold objects of differing
  types. Array literals are a set of objects between square brackets `[]`.
  You access an element by giving the array name followed by square brackets
  with an index in them.

  ```ruby
  a = [ 1, "cat", 3.14 ]    # array with three elements
  a[0]                      # access the first element => 1
  a[2] = nil                # set the third element
  a                         # => [ 1, "cat", nil ]
  ```

- *nil* is an object like any other but represents nothing.
- The `<<` method appends an item to an array.
- Ruby has a shortcut for an array of words:
  `a = %w[ ant bee cat dog elk ]` is equivalent to `a = ['ant', 'bee', ... ]`.
- A hash literal uses braces rather than square brackets and the literal must
  supply two objects for every entry: one key and one value. Keys must be
  unique and if you re-use a key the last assignment wins. In Rails, hashes
  normally use symbols as keys although they could be any object. Many hashes
  have been subtly modified so you can use a string or symbol interchangeably.

  ```ruby
  inst_section = {
      :cello     => "string",
      :clarinet  => "woodwind",
      :drum      => "percussion",
      :oboe      => "woodwind",
      :trumpet   => "brass",
      :violin    => "string"
  }

  # Equivalently using shorthand syntax usable with symbol keys
  inst_section = {
      cello:      "string",
      clarinet:   "woodwind",
      drum:       "percussion",
      oboe:       "woodwind",
      trumpet:    "brass",
      violin:     "string"
  }

  inst_section[:oboe]    # => "woodwind"
  inst_section[:bassoon] # => nil
  ```

- You can omit the braces when passing hashes as the last parameter of a 
  method call. `redirect_to action: "show", id: product.id` is actually
  passing a two element hash to `redirect_to`. This is the same syntax as
  keywork arguments.
- The regular expression is a first class type you can express as either
  `/pattern/` or `%r{pattern}`. Programs typically use the match operator
  `=~` to test strings against regular expressions.

  ```ruby
  if line =~ /P(erl|ython)/
    puts "There seems to be another scripting language here"
  ```

- Ruby has **if** and **while** statements:

  ```ruby
  if count > 10
    puts "Try again"
  elsif tries == 3
    puts "You lose"
  else
    puts "Enter a number"
  end

  while weight < 100 and num_pallets <= 30
    pallet = next_pallet()
    weight += pallet.weight
    num_pallets += 1
  end
  ```

- It also has **unless**, which is like **if** except it checks for the
  condition to be not true, and **until** which is like **while** except the
  loop continues until the condition evaluates to true.
- The Ruby control structures can also be used as *statement modifiers* where
  you place an **if**, **unless**, **while**, or **until** at the end of an
  expression to affect only that expression.
- Code blocks are statements between `{}` or between `do end`. Commonly braces
  are for single line blocks and `do end` are for multiline. To pass a block to
  a method, place the block after the paremeters (if any) to the method. A
  method can invoke an associated block can be called one or more times with
  **yield**. You can pass values to the block by giving parameters to **yield**.
  Within the block, you list the names o fthe arguments to receive these
  parameters between vertical bars `(|)`.

  ```ruby
  animals = %w[ ant bee cat dog elk ]   # create an array
  animal.each {|animal| puts animal }   # iterate over the contents
  3.times { print "Ho! " }              # => Ho! Ho! Ho!
  # The & prefix let's a method capture a block as a named parameter
  def wrap &b
    print "Santa says: "
    3.times(&b)
    print "\n"
  end
  wrap { print "Ho! "}
  ```

- Control is sequential within a block or method unless an exception occurs.
- Exceptions are objects of the **Exception** class or its subclasses. The
  **raise** method causes an exception to be raised. Both methods and blocks
  of code wrapped between **begin** and **end** keywords intercept certain
  classes of exception using **rescue** clauses:

  ```ruby
  begin
    content = load_blog_data(file_name)
  rescue BlogDataNotFound
    STDERR.puts "File #{file_name} not found"
  rescue BlogDataFormatError
    STDERR.puts "Invalid blog data in #{file_name}"
  rescue Exception => exc
    STDERR.puts "General error loading #{file_name}: #{exc.message}"
  end
  ```

- **rescue** clauses can be directly place on the outermost level of a method
  definition without needing to enclose the contents in a **begin/end** block.
- Ruby has two basic concepts for organizing methods: classes and modules.

  ```ruby
  class Order < ApplicationRecord

    has_many :line_items
    def self.find_all_unpaid
      self.where("paid = 0")
    end

    def total
      sum = 0
      line_items.each {|li| sum += li.total}
      sum
    end

  end
  ```

- Class definitions start with the **class** keyword and are followed by the
  class name (which must start with an uppercase letter). This **Order** class
  is defined to be a subclass of the **ApplicationRecord** class. Prefixing
  a method name with **self** makes it a class method. Objects hold their
  state in *instance variables* whose names start with `@`. They aren't
  directly accessible from outside a class without methods that return their
  values.

  ```ruby
  class Greet
    def initialize(name)
      @name = name
    end

    def name
      @name
    end

    def name=(new_name)
      @name = new_name
    end
  end

  g = Greeter.new("Barney")
  g.name    # => Barney
  g.name = "Betty"
  g.name    # => Betty
  ```

- Ruby also provides convenience methods that write accessor methods for you.

  ```ruby
  class Greeter
    attr_accessor   :name       # create reader and writer methods
    attr_reader     :greeting   # create reader only
    attr_writer     :age        # create writer only
  end
  ```

- Methods are public by default but can be declared `protected` or `private`.

  ```ruby
  class MyClass
    def m1
    end
    protected
    def m2
    end
    private
    def m3
    end
  end
  ```

- `private` methods can only be called within the same instance. `protected`
  methods can be called both in the same instance and by other instances of
  the same class and its subclasses.
- Modules also hold a collection of methods, constants, and other module and
  class definitions, but you can't create objects based on modules. Modules
  act as a namespace and allow you to share functionality among classes. If
  a class *mixes in* a module, that module's methods become available as if
  they'd been defined in the class. Multiple classes can mix in the same
  module to share the module's functionality without using inheritance. You
  can also mix multiple modules into a single class.
- Ruby uses modules for helper methods. Rails automatically mixes these helper
  modules into the appropriate view templates. For example, if you wanted to
  write a helper method that's callable from views invoked by the store
  controller, you could define the following module in the **store_helper.rb**
  file in the **app/helpers** directory:

  ```ruby
  module StoreHelper
    def capitalize_word(string)
      string.split(" ").map {|word| word.capitalize}.join(" ")
    end
  end
  ```

- In the context of Rails, YAML is used as a convenient way to define the
  configuration of things such as databases, test data, and translations; and
  the Ruby YAML module supports it.

  ```yaml
  development:
    adapter: sqlite3
    database: storage/development.sqlite3
    pool: 5
    timeout: 5000
  ```

- In YAML, indentation is important, so this defines **development** as having
  a set of four key-value pairs separated by colons.
- *Marshaling* is the process of taking an object and converting it to a stream
  of bytes that can be stored outside the application. The saved object can be  read by another instance of the application or a separate application to
  reconstitute the originally saved object. Some objects cannot be marshaled
  and raise a **TypeError**. When you load a marshaled object, Ruby needs to
  know the definition of the class of that objects and all the objects it
  contains. Rails uses marshaling to store session data. If you rely on Rails
  to dynamically load classes, it's possible that a particular class may not
  have been defined at the point it reconstitutes session data. For that
  reason, use the **model** declaration in your controllers to list all models
  that are marshaled to preemptively load the necessary classes.

  ```ruby
  class CreateProducts < ActiveRecord::Migration[8.0]
    def change
      create_table :products do |t|
        t.string :title
        t.text :description
        t.decimal :price, precision: 8, scale: 2

        t.timestamps
      end
    end
  end
  ```

- We are creating a `CreateProducts` class that inherits from the versioned
  `Migration` class in the `ActiveRecord` module specifying that compatibility
  with Rails 8 is desired. We define one method named `change`. This method
  calls the `create_table` method definied in `ActiveRecord::Migration`, 
  passing it the name of the table in the form of a symbol. The call to
  `create_table` also passes as block to be evaluated before the table is
  created. The block is passed an object name `t` when called which is used
  to accumulate a list of fields. Methods added by Rails named after the
  common data types are used to add a field definition to the accumulating set
  of names. `decimal` also accepts a number of optional parameters, expressed
  as a hash.
- Ruby Idioms
  - Ruby method names can end in an exclamation mark (*a bang method*) or a
    question mark (*a predicate method*). Bang methods normally do something
    destructive to the receiver. Predicate methods normally return **true** or
    **false** depending on some condition.
  - `a || b` evaluates `a`. If it isn't **false** or **nil** then evaluation
    stops and `a` is returned. Otherwise, the statement returns `b`. This is a
    common way to return a default value if the first value isn't set.
  - `a ||= b` is the same as `a = a op b` for most operators.

    ```ruby
    count += 1          # same as count = count + 1
    price *= discount   #         price = price * discount
    count ||= 0         #         count = count || 0
    ```

  - So `count ||= 0` gives `count` the value of 0 if `count` is nil or false.
  - `obj = self.new` returns a new object of the receiver's class. This is more
    flexible than calling `Person.new` in case `Person` is subclassed.
  - `lambda` converts a block into an object of type `Proc`. `->` is alternate
    syntax introduced in Ruby 1.9.

    ```ruby
    # These two are equivalent
    square = lambda { |x| x * x }
    square = ->(x) { x * x }
    # Both can be called with `square.call(3)`, `square.(3)`, or `square[3]`.
    ```

  - `require File.expand_path("../../config/environment",__FILE__)` loads an
    external source file into our application and is commonly used to include
    library code and classes.

## Part 2 - Building an Application

### Chapter 5 - The Depot Application

- Our shopping cart app has *buyers* and *sellers*. The *buyer* uses Depot to
  browse the products we have to sell, select some to purchase, and supply the
  information needed to create an order. A *seller* uses Depot to maintain a
  list of products to sell, to determine the orders that are awaiting shipment,
  and to mark orders as shipped.
- We can mock up some page flows by hand. Our
  buyer is going to get a catalog page that lists items. When they add an item
  to cart, they'll be taken to the cart, and can either return to shopping or
  checkout. When they do checkout, we capture contact and payment details then
  display a receipt page. The seller logs in and sees a menu letting her create
  or view a product or ship existing orders. When viewing a product, the seller
  can edit the details or delete the product entirely. Shipping is purposefully
  simplistic. It will display each order that hasn't shipped with one order per
  page, and the seller can either skip to the next or ship the order using the
  information from the page as appropriate.
- Based on the use cases and flows, we need some basic data. For one is the
  Product which at least has a name, description, image, and price. We need
  at least a login name and password for our seller. We'll have a cart since we
  need a place to keep a list of items the buyer bought, but it doesn't hold
  much other than that. It's line items will need at least product, quantity,
  and price. And for an Order we need buyer details, payment details, and
  shipping status.

### Chapter 6 - Task A: Creating the Application

#### Iteration A1: Creating the Product Maintenance Application

- You can make a new project that uses Tailwind CSS with `rails new depot -css
  tailwind`.
- SQLite 3 is the default database for Rails development and requires no
  installation.
- In Rails, a model is automatically mapped to a database table whose name is the
  plural form of the model's class. So if we create a **Product** model, Rails
  associates it with a **products** table. Use the command to generate a
  *scaffold* for our new **Product** model.

  ```ruby
  depot> bin/rails generate scaffold Product \
           title:string description:text image:attachment price:decimal
  ```

- Note that `\` before a new line is used to continue lines in Linux/OS X, but
  you would need `^` in Windows (and backslash in `bin\rails`).
- The first file generated by scaffolding in `db/migrate` is the migration
  script `20250420000001_create_products.rb` (for some date).
- You can edit your migration scripts. We will modify our first one to specify
  `,precision: 8, scale: 2` for the decimal field.
- We also defined an attachment, so we need to install the tables that Active
  Storage uses to track attachments. This only needs to be done once per
  database and is done by `bin/rails active_storage:install`.
- To apply the migration, run `bin/rails db:migrate`. Rails looks for unapplied
  migrations and applies them. The **products** table is added to the database
  specified in the **development** section of the **config/database.yml** file.
- To undo and redo the last migration script run `bin\rails db:migrate:redo`
- When using things like CSS processors (Tailwind) and JavaScript bundlers,
  run your development server with `bin/dev`.
- Now we can go to <http://localhost:3000/products> and enter new products.
- But first let's modify `depot/app/views/products/_form.html.erb` to have more
  rows in the description and limit the acceptable files to select for upload
  to images:

  ```ruby
  # ...
  <div class="my-5">
    <%= form.label :description %>
    <%= form.textarea :description, rows: 10, class:
      ["block shadow-sm rounded-md border px-3 py-2 mt-2 w-full",
      {"border-gray-400 focus:outline-blue-600":
        product.errors[:description].none?",
       "border-red-400 focus:outline-red-600":
        product.errors[:description.any?}]
  </div>

  <div class="my-5">
    <%= form.label :image %>
    <%= form.file_field :image, accept: "image/*", class:
      ["block shadow-sm rounded-md border px-3 py-2 mt-2 w-full",
      {"border-gray-400 focus:outline-blue-600": product.errors[:image].none?",
       "border-red-400 focus:outline-red-600": product.errors[:image].any?}] %>
  </div>
  # ...
  ```

- This looks like a big change, but we're only changing "rows: 4" to "rows: 10"
  and adding 'accept: "image/*"' to what's already there.

#### Iteration A2: Making Prettier Listings

- The product display is ugly. Make it look better and actually show the pictures
  instead of just the filenames.
- First we are going to modify the `db/seeds.rb` file to seed our database with
  more data instead of entering each product in one at a time. Be warned that
  the `seeds.rb` script removes existing data before loading the new data.
  To populate your **products** table with test data run `bin/rails db:seed`.

  ```ruby
  # db/seeds.rb
  Product.delete_all
  # ...
  product = Product.create(title: 'Rails Scales!',
    description:
      %(<p>
        <em>Practical Techniques for Performance and Growth</em>
        Rails doesn't scale. ...
      </p>),
    price: 30.95)

  product.image.attach(io: File.open(
    Rails.root.join('db', 'images', 'cprpo.jpg')),
      filename: 'cprpo.jpg')

  product.save!
  # ...
  ```

- You can use `%(string)` as alternative syntax for double-quoted string
  literals.
- Now we can edit `app/views/products/index.html.erb` and replace the scaffold-
  generated view with Tailwind CSS styling:
- The Rails helper method `cycle` can alternate CSS classes of rows.
- The `truncate` method can be used to display the first eighty characters of
  the description, and the `strip_tags` method removes HTML tags.
- The `number_to_currency` helper is used to format money.
- The `image_tag` helper is used to display an image.
- You can put `data: { turbot_confirm: 'Are you sure?' }` to confirm a button
  press.
- The `mx-auto` class centers elements horizontally and the `px-2` and `px-3`
  classes add vertical and horizontal padding.
- Other classes have sensible names like `text-xl`, `bg-green-600`, and
  `hover:underline`.
- We also need to add a line to `app/controllers/application_controller.rb`:

  ```ruby
  class ApplicationController < ActionController::Base
    # Only allow modern browsers supporting webp images, web push, badges,
    # import maps, CSS nesting, and CSS :has.
    allow_browser versions: modern

    include ActiveStorage::SetCurrent
  end
  ```

- Our newly formatted view has a problem that when you edit items the details
  don't show up until the user refreshes the page. We can do that with HotWire.

  ```ruby
  # app/models/product.rb
  class Product < ApplicationRecord
    has_one_attached :image
    after_commit -> { broadcast_refresh_later_to "products" }
  end

  # app/views/products/index.html.erb - at the top
  <%= turbo_stream_from "products" %>
  <%= turbo_refreshes_with method: :morph, scroll: :preserve %>
  ```

- The first change tells Rails to broadcast changes to the product model to any
  clients that are listening. `after_commit` is an Active Record callback that's
  called after a record is saved. The first line of the second change tells the
  browser to listen for changes to the product model and update the page when
  they occur. The second line of the second change tells the browser to apply the
  changes directly to the page without refreshing it and to preserve the scroll
  position. Methods with names starting with `turbo_` are part of the Turbo
  framework. Turbo is a set of tools for building modern, reactive web
  applications.
- You can access the database directly with `bin/rails dbconsole`.
- To display application changes without reloading, add Hotwire Spark by
  running `bundle add hotwire-spark --group development`.

### Chapter 7 - Task B: Validation and Unit Testing

#### Iteration B1: Validating!

- We want it so no product gets put in the database with an empty title or
  description field, and invalid URL for the image, or an invalid price.
  The model is an ideal place for validations since all data goes through it.
- Add this line to `app/models/product.rb`in the `Product` class: 
  `validates :title, :description, :image, presence: true`
- `validates` is the standard Rail validator that checks one or more model
  fiels against one or more conditions. Here we are using `presence: true` to
  tell it to check that each of the named fields are present and non-empty.
- We also want to validate `:price`, so we add another validator:
  `validates :price, numericality: { greater_than_or_equal_to: 0.01 }`
- We test against 0.01 so smaller values aren't rounded down to zero.
- We can also add `validates :title, uniqueness: true` for unique titles and
  `validate :acceptable_image` if we define an `acceptable_image` method:

  ```ruby
  # within the Product class of app/models/product.rb
  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG or PNG image")
    end
  end
  ```

#### Iteration B2: Unit Testing of Models

- There is already a `test/models/product_test.rb` from our model generation.
- The default `ProductTest` doesn't test anything.
- Tests subclass `ActiveSupport::TestCase` which itself is a subclass of
  `MiniTest:Test` that comes preinstalled with Ruby. The `assert` method expects
  it arguments to be true. If we create an empty product, we expect it to be
  invalid and for an error to be associated with each field. We use the model's
  `errors` and `invalid?` methods to see if it validates, and we can use `any?`
  method of the error list to see if an error is associated with a particular
  attribute.

  ```ruby
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
  ```

- Now to rerun just the unit tests run `rails test:models`.
- Assert statements take an optional extra parameter that is a string to be
  written along with the error message if the assertion fails.
- In Rails a test fixture is a specification of the initial contents of a model
  (or models) under test. So if we want **products** to always start with known
  data at the start of every unit test, we would specify the contents in a
  fixture. You specify fixture data in files in `test/fixtures` directory.
  The files contant test data in YAML format. Each fixture file contains the
  data for a single model. The base name of the file must match the name of a
  database table. So data for the **Product** model which is stored in the
  **products** table would be **products.yml**. Rails creates the fixture file
  when you create the model, so you just need to add data to it. The default
  fixtures are named `one` and `two` but it's highly recommended you use
  descriptive names for your fixtures. They aren't significant but are referred
  to in tests using the fixtures. Note because we're using image attachments,
  we need to define blobs in `test/fixtures/active_storage/blogs.yml` and attach
  them to products in `fixtures/active_storage/attachments.yml`. For each fixture
  Rails loads into a test, it defines a method with the same name as the fixture
  you can use to access preloaded model objects containing the fixture data.
  Calling `products(:pragprog)` will return a `Product` model contain the data
  in the `pragprog` fixture.

