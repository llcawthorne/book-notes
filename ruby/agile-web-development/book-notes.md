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

