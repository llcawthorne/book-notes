# Learn Go with Tests

## Chapter 1 - Why unit tests?

- The strength of software is that we can change it. Most software will need to
  change over time in unpredictable ways, but don't try to over-engineer for
  that, because the future is too hard to predict.
- Instead, we need to keep our software malleable. Software has to be refactored
  as it evolves, or it will turn into a mess.
- A good test suite lets you refactor faster and with less stress.
- Writing good unit tests is a design problem, so structure your code into
  meaningful units that you can fit together like Lego bricks.
- TDD can help, and even force, you to design well-factored software
  iteratively, backed by tests that support future work as it arrives.
- Wrapping up
  - The strength of software is that we can change it. Most software will
    require change over time in unpredictable ways, but don't try to
    over-engineer, because it's too hard to predict the future.
  - Instead we need to make it so we can keep our software malleable. In order
    to change software we have to refactor it as it evolves, or it will turn
    into a mess.
  - A good test suite can help you refactor quicker and in a less stressful
    manner.
  - Writing good unit tests is a design problem, so think about structuring your
    code so you have meaningful units that you can integrate together like Lego
    bricks.
  - TDD can help and force you to design well-factored software iteratively,
    backed by tests to help future work as it arrives.

## Chapter 2 - Hello, World

- Run `go mod init MODULENAME` once, in the top-level folder, before running
  commands like `go test` or `go build`. Each chapter folder below it is its own
  package within that one module. We used `example.com/learn-go-with-tests`.
  Use a path with a dot in its first element, like a domain. Go reserves
  dot-free first elements for the standard library and its tools.
- Go finds `go.mod` by searching parent directories, so `go test` works inside
  a chapter folder, and `go test ./...` at the top runs every chapter's tests.
- Writing tests
  - The test must be in a file with a name like `xxx_test.go`.
  - The test function's name must start with `Test`.
  - The test function takes exactly one argument, `t *testing.T`.
  - To use the `*testing.T` type, you need to import `"testing"`.
- To see the documentation for `fmt`, run `go doc fmt`.
- You can also install pkgsite with
  `go install golang.org/x/pkgsite/cmd/pkgsite@latest`, then run
  `pkgsite -open` in your module directory to browse the docs at
  <http://localhost:8080>. The home page only links to your module, but the
  standard library is served too: browse <http://localhost:8080/std> or search
  for a package like `fmt`. `pkgsite -cache .` also serves your module cache;
  the `.` is needed there, since `-cache` alone serves only the cache.
- It is often useful to define one test like `TestHello` for the `Hello`
  function, then define several subtests within it using `t.Run`.
- Test helper functions should take `t testing.TB`. `testing.TB` is an interface
  that both `*testing.T` and `*testing.B` satisfy, so the helper works in tests
  and benchmarks. Inside the helper, we call `t.Helper()` and, when needed,
  `t.Errorf` or `t.Fail()`. `t.Helper()` makes failure messages report the line
  in the test that called the helper, instead of a line inside the helper.
- When consecutive parameters have the same type, you can write
  `(got, want string)` instead of `(got string, want string)`.
- `:=` is Go's short variable declaration (declare and assign). `=` is plain
  assignment to a variable that already exists.
- In Go, any identifier (function, type, constant, variable, or struct field)
  that starts with a capital letter is exported, meaning it is visible outside
  its package. One that starts with a lowercase letter is unexported, meaning
  it is private to its package.

  ```go
  // 02-hello-world/hello.go
  package main

  import "fmt"

  const (
  	spanish = "Spanish"
  	french  = "French"

  	englishHelloPrefix = "Hello, "
  	spanishHelloPrefix = "Hola, "
  	frenchHelloPrefix  = "Bonjour, "
  )

  // Hello returns a personalised greeting in a given language.
  func Hello(name string, language string) string {
  	if name == "" {
  		name = "World"
  	}

  	return greetingPrefix(language) + name
  }

  func greetingPrefix(language string) (prefix string) {
  	switch language {
  	case spanish:
  		prefix = spanishHelloPrefix
  	case french:
  		prefix = frenchHelloPrefix
  	default:
  		prefix = englishHelloPrefix
  	}
  	return
  }

  func main() {
  	fmt.Println(Hello("world", "English"))
  }
  ```

  ```go
  // 02-hello-world/hello_test.go
  package main

  import "testing"

  func TestHello(t *testing.T) {
  	t.Run("saying hello to people", func(t *testing.T) {
  		got := Hello("Chris", "")
  		want := "Hello, Chris"
  		assertCorrectMessage(t, got, want)
  	})
  	t.Run("say 'Hello, World' when an empty string is supplied",
  		func(t *testing.T) {
  			got := Hello("", "")
  			want := "Hello, World"
  			assertCorrectMessage(t, got, want)
  		})
  	t.Run("in Spanish", func(t *testing.T) {
  		got := Hello("Elodie", "Spanish")
  		want := "Hola, Elodie"
  		assertCorrectMessage(t, got, want)
  	})
  	t.Run("in French", func(t *testing.T) {
  		got := Hello("Marcella", "French")
  		want := "Bonjour, Marcella"
  		assertCorrectMessage(t, got, want)
  	})
  }

  func assertCorrectMessage(t testing.TB, got, want string) {
  	t.Helper()
  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}
  }
  ```

- Wrapping up
  - Some of Go's syntax around:
    - Writing tests
    - Declaring functions, with arguments and return types
    - `if`, `const`, and `switch`
    - Declaring variables and constants
  - The TDD process and why the steps are important
    - Write a failing test and see it fail so we know we have written a relevant
      test for our requirements, and that it produces an easy-to-understand
      description of the failure.
    - Write the smallest amount of code to make it pass, so we know we have
      working software.
    - Then refactor, backed with the safety of our tests to ensure we have
      well-crafted code that is easy to work with.

## Chapter 3 - Integers

- A doc comment is an ordinary `//` comment directly above a top-level package,
  func, type, const or var declaration, with no blank line in between.
- Example functions begin with `Example` and live in a package's `_test.go`
  files. They appear in your documentation and are compiled whenever tests run.
  The `// Output: 6` comment is what makes `go test` run the example and check
  its output; remove it and the example is compiled but never run. Examples
  without `Output` are useful for code that can't run as a unit test, such as
  code that accesses the network, since the compiler still checks that they
  build.
- `go test -v` lists each test and example as it runs, with its result.
- Run `pkgsite -open` (see the last chapter for installation) and browse to
  <http://localhost:8080/> to see our doc comment and example.
- Aside from running `pkgsite`, you can see Go module documentation at
  <https://pkg.go.dev/>.

  ```go
  // 03-integers/adder_test.go
  package integers

  import (
  	"fmt"
  	"testing"
  )

  func TestAdder(t *testing.T) {
  	sum := Add(2, 2)
  	expected := 4

  	if sum != expected {
  		t.Errorf("expected '%d' but got '%d'", expected, sum)
  	}
  }

  func ExampleAdd() {
  	sum := Add(1, 5)
  	fmt.Println(sum)
  	// Output: 6
  }

  // 03-integers/adder.go
  package integers

  // Add takes two integers and returns the sum of them.
  func Add(x, y int) int {
  	return x + y
  }
  ```

- Wrapping up
  - We have covered:
    - More practice of the TDD workflow
    - Integers, addition
    - Writing better documentation so users of our code can understand its usage
      quickly
    - Examples of how to use our code, which are checked as part of our tests

## Chapter 4 - Iteration

- To repeat things in Go, you need `for`. There are no `while`, `do`, or
  `until` keywords.
- In Go there are no parentheses surrounding the three components of the `for`
  statement. It's just `for i := 0; i < 5; i++ {`.
- You can also do an infinite loop with just `for {`. It's infinite, but can
  still be exited with `break`, `return`, or `panic`.
- We will see `for` with `range` in the next chapter.
- You can declare a variable `repeated` of `string` type like
  `var repeated string`. You can declare a constant like
  `const repeatCount = 5`.
- The `+=` operator is called the Add AND assignment operator, and it adds the
  right operand to the left operand and assigns the result to the left operand.
- In your test file you can declare benchmarks as
  `func BenchmarkXxx(b *testing.B) {`. `*testing.B` gives you access to
  `b.Loop()`, which returns true as long as the benchmark should keep running.
  To run benchmarks, run `go test -bench=.` (or `go test -bench="."` in
  PowerShell).
  By default benchmarks run sequentially.
- The standard library provides `strings.Builder`, which minimizes
  memory copying of strings. It has a `WriteString` method which is more
  efficient than repeated uses of `+=`. Switching it to `WriteString` was five
  times as fast in the benchmark.
- You can run `go test -bench=. -benchmem` to report memory allocations where
  `B/op` is the number of bytes allocated per iteration and `allocs/op` is the
  number of allocations per iteration.

  ```go
  // 04-for/repeat_test.go
  package iteration

  import (
  	"fmt"
  	"testing"
  )

  func TestRepeat(t *testing.T) {
  	repeated := Repeat("a", 5)
  	expected := "aaaaa"
  
  	if repeated != expected {
  		t.Errorf("expected %q but got %q", expected, repeated)
  	}
  }

  func BenchmarkRepeat(b *testing.B) {
  	//... setup ...
  	for b.Loop() {
  		//... code to measure ...
  		Repeat("a", 5)
  	}
  	// ... cleanup ...
  }

  func ExampleRepeat() {
  	output := Repeat("a", 5)
  	fmt.Println(output)
  	// Output: aaaaa
  }

  // 04-for/repeat.go
  package iteration

  import "strings"

  // Repeat returns character repeated repeatCount times.
  func Repeat(character string, repeatCount int) string {
  	var repeated strings.Builder
  	for i := 0; i < repeatCount; i++ {
  		repeated.WriteString(character)
  	}
  	return repeated.String()
  }
  ```

- Wrapping up
  - More TDD practice
  - Learned `for`
  - Learned how to write benchmarks

## Chapter 5 - Arrays and slices

- Arrays allow you to store multiple elements of the same type in a variable,
  in a particular order. Arrays have a fixed capacity, which you define when
  you declare the variable. We can initialize an array in two ways:
  - `[N]type{value1, value2, ..., valueN}`, e.g.
    `numbers := [5]int{1, 2, 3, 4, 5}`
  - `[...]type{value1, value2, ..., valueN}`, e.g.
    `numbers := [...]int{1, 2, 3, 4, 5}`, where the compiler counts the
    elements for you.
- You'll notice in our `Errorf` in this test code we're using a different
  placeholder. `%d` prints an integer in base 10, `%q` prints a double-quoted
  string with Go escapes (so an empty string shows up as `""`), and `%v` is the
  "default" format for any value, which works well for arrays (`[1 2 3]`).
- Remember as always to write the minimal amount of code for the test to run.
  After starting a test for `Sum`, define `Sum` and return a bogus result. You
  want to get to the point where you get a clear error message and not an
  `undefined: Sum` error.

  ```go
  // 05-arrays/sum_test.go
  package main

  import "testing"

  func TestSum(t *testing.T) {
  
  	numbers := [5]int{1, 2, 3, 4, 5}
  
  	got := Sum(numbers)
  	want := 15
  
  	if got != want {
  		t.Errorf("got %d want %d given, %v", got, want, numbers)
  	}
  }

  // 05-arrays/sum.go
  package main

  func Sum(numbers [5]int) int {
  	return 0
  }
  
  // at this point `go test` should give:
  // --- FAIL: TestSum (0.00s)
  //  sum_test.go:13: got 0 want 15 given, [1 2 3 4 5]
  ```

- You could fix it like this by manually incrementing a counter and accessing
  the array by index like `array[index]`:

  ```go
  // 05-arrays/sum.go
  package main

  func Sum(numbers [5]int) int {
  	sum := 0
  	for i := 0; i < 5; i++ {
  		sum += numbers[i]
  	}
  	return sum
  }
  ```

- But after that gets the tests to pass, we want to refactor to use `range`:

  ```go
  // 05-arrays/sum.go
  package main

  func Sum(numbers [5]int) int {
  	sum := 0
  	for _, number := range numbers {
  		sum += number
  	}
  	return sum
  }
  ```

- `range` lets you iterate over an array. Each iteration, `range` returns two
  values - the index and the value. We are choosing to ignore the index using
  `_` (the blank identifier).
- An interesting property of arrays is that the size is encoded in its type. If
  you try to pass a `[4]int` to this function that expects a `[5]int`, it won't
  compile even though our code would handle either now. Go has slices though
  which work with any size.
- If we write a new test that passes our function a slice, we will get a new
  error `cannot use numbers (type []int) as type [5]int in argument to Sum`.
  We have a choice between breaking our existing API by changing the `Sum`
  argument to be a slice or creating a new function. No one is using our API
  right now, so we're going to break it rather than have two functions to
  maintain. For reference, here is our code now that we're using slices and
  have fixed the compiler messages:

  ```go
  // 05-arrays/sum_test.go
  package main

  import "testing"

  func TestSum(t *testing.T) {
  
  	t.Run("collection of 5 numbers", func(t *testing.T) {
  		numbers := []int{1, 2, 3, 4, 5}
  
  		got := Sum(numbers)
  		want := 15
  
  		if got != want {
  			t.Errorf("got %d want %d given, %v", got, want, numbers)
  		}
  	})
  
  	t.Run("collection of any size", func(t *testing.T) {
  		numbers := []int{1, 2, 3}
  
  		got := Sum(numbers)
  		want := 6
  
  		if got != want {
  			t.Errorf("got %d want %d given, %v", got, want, numbers)
  		}
  	})
  }

  // 05-arrays/sum.go
  package main

  func Sum(numbers []int) int {
  	sum := 0
  	for _, number := range numbers {
  		sum += number
  	}
  	return sum
  }
  ```

- You'll find most of the time slices are more flexible than arrays. They're
  defined like `[]int{1, 2, 3}` for some number of values. Type can vary but
  we're using `int` here.
- It shouldn't be our goal to have as many tests as possible, but rather to have
  as much confidence as possible in our code base. **Every test has a cost.**
  In our case, we have two tests that test passing a slice. Slices of different
  sizes aren't treated differently, so it's a little redundant.
- Go can analyze your test coverage by running `go test -cover`. If you run it
  now, you'll see you have 100% coverage. Delete one test, and you still have
  100% coverage.
- We are going to define a new function `SumAll` that takes a varying number of
  slices and returns a new slice containing the totals for each slice passed in.
  First we'll write a test:

  ```go
  // 05-arrays/sum_test.go
  // ...
  func TestSumAll(t *testing.T) {
  
  	got := SumAll([]int{1, 2}, []int{0, 9})
  	want := []int{3, 9}
  
  	if got != want {
  		t.Errorf("got %v want %v", got, want)
  	}
  }
  ```

- That obviously fails with `undefined: SumAll`, so let's define it:

  ```go
  // 05-arrays/sum.go
  func SumAll(numbersToSum ...[]int) []int {
  	return nil
  }
  ```

- If we try to run our tests now, we get a new error that teaches us something
  about slices:
  `invalid operation: got != want (slice can only be compared to nil)`.
  Go does not let you use equality operators with slices. You could iterate over
  the slice and compare values, but the `slices` package has been available
  since Go 1.21 and has a `slices.Equal` function to do a simple shallow compare
  of two slices of the same type. The function expects the elements to be
  comparable, so it can't be applied to slices with non-comparable elements like
  2D slices; use `slices.EqualFunc(a, b, slices.Equal[[]Int])` for those.

  ```go
  // 05-arrays/sum_test.go
  func TestSumAll(t *testing.T) {
  
  	got := SumAll([]int{1, 2}, []int{0, 9})
  	want := []int{3, 9}
  
  	if !slices.Equal(got, want) {
  		t.Errorf("got %v want %v", got, want)
  	}
  }
  ```

- Now we get a normal error message about unexpected values:
  `sum_test.go:28: got [] want [3 9]`.
- So to fix this, we need to iterate over the varargs, calculate the sum using
  our existing `Sum` function, then add it to the slice we will return:

  ```go
  // 05-arrays/sum.go
  // ...
  func SumAll(numbersToSum ...[]int) []int {
  	lengthOfNumbers := len(numbersToSum)
  	sums := make([]int, lengthOfNumbers)
  
  	for i, numbers := range numbersToSum {
  		sums[i] = Sum(numbers)
  	}
  
  	return sums
  }
  ```

- The book skipped over explaining varargs, but `numbersToSum ...[]int` means
  we can take any number of slices. Inside the function, `numbersToSum` is a
  `[][]int`.
- Now there's a new way to create a slice. `make([]int, n)` creates a slice of
  length `n` with every element set to the zero value. We're setting `n` to the
  `len` of the `numbersToSum` we need to work through. The length of a slice,
  `len(mySlice)`, is the number of elements it holds, while the capacity,
  `cap(mySlice)`, is the number of elements its underlying array has room for.
  A third argument sets capacity separately: `make([]int, 0, 5)` creates a slice
  with length 0 and capacity 5. With only two arguments, as in our code, the
  capacity equals the length. After making our slice, we can index into it with
  `mySlice[N]` to get a value out or assign it a new value with `=`. This gets
  our tests to pass.
- Indexing is limited by a slice's length, not its capacity. If you have a
  slice of length 2 and try to do `mySlice[10] = 1`, you will get a *runtime
  error* (a panic). Instead, you can use the `append` function, which takes a
  slice and new values and returns a slice with the values added, growing the
  underlying array if needed. We will refactor our `SumAll` to do this so we
  don't need to manually assign by index:

  ```go
  // 05-arrays/sum.go
  func SumAll(numbersToSum ...[]int) []int {
  	var sums []int
  	for _, numbers := range numbersToSum {
  		sums = append(sums, Sum(numbers))
  	}
  
  	return sums
  }
  ```

- Now we aren't manually managing length or capacity either. We start with an
  empty (`nil`) slice, `var sums []int`, and just `append` the result of `Sum`
  to it as we work through the varargs. Now we are going to change our
  requirements, though. Instead of `SumAll` we want `SumAllTails`, which
  calculates the total of the "tails" of each slice. The tail of a collection is
  all items in the collection except the first one (the "head"). I'm actually
  going to keep `SumAll` and just write and test `SumAllTails` separately.

  ```go
  // 05-arrays/sum_test.go
  func TestSumAllTails(t *testing.T) {
  	got := SumAllTails([]int{1, 2}, []int{0, 9})
  	want := []int{2, 9}

  	if !slices.Equal(got, want) {
  		t.Errorf("got %v want %v", got, want)
  	}
  }
  ```

- If we run the test now, we get the expected `undefined` error:
  `undefined: SumAllTails`. If we copy in the body of `SumAll`, it compiles but
  we get the wrong values back, so let's use `numbers[1:]` to access the tail:

  ```go
  // 05-arrays/sum.go
  func SumAllTails(numbersToSum ...[]int) []int {
  	var sums []int
  	for _, numbers := range numbersToSum {
  		tail := numbers[1:]
  		sums = append(sums, Sum(tail))
  	}
  	return sums
  }
  ```

- This works. Slices can be sliced! The syntax is `slice[low:high]`, which
  includes `low` but not `high`. Omitting `low` means 0 and omitting `high`
  means `len(slice)`, so `numbers[1:]` says take everything from index 1 to the
  end. But what would happen if we passed it an empty slice? We can write the
  test!

  ```go
  // 05-arrays/sum_test.go
  func TestSumAllTails(t *testing.T) {
  
  	t.Run("make the sums of some tails of slices", func(t *testing.T) {
  		got := SumAllTails([]int{1, 2}, []int{0, 9})
  		want := []int{2, 9}
  
  		if !slices.Equal(got, want) {
  			t.Errorf("got %v want %v", got, want)
  		}
  	})
  
  	t.Run("safely sum empty slices", func(t *testing.T) {
  		got := SumAllTails([]int{}, []int{3, 4, 5})
  		want := []int{0, 9}
  
  		if !slices.Equal(got, want) {
  			t.Errorf("got %v want %v", got, want)
  		}
  	})
  }
  ```

- So testing with empty slices is generally a good idea, and here it finds a
  panic:
  `panic: runtime error: slice bounds out of range [1:0]`.
  `low` may be at most `len(slice)`, so `[]int{7}[1:]` is an empty slice, but
  `[]int{}[1:]` panics. What is the tail of an empty slice? We want its sum to
  be 0:

  ```go
  // 05-arrays/sum.go
  func SumAllTails(numbersToSum ...[]int) []int {
  	var sums []int
  	for _, numbers := range numbersToSum {
  		if len(numbers) == 0 {
  			sums = append(sums, 0)
  		} else {
  			tail := numbers[1:]
  			sums = append(sums, Sum(tail))
  		}
  	}
  	return sums
  }
  ```

- We have repeating code in our assertions again, so we're going to factor that
  out into a helper:

  ```go
  // 05-arrays/sum_test.go
  func TestSumAllTails(t *testing.T) {
  
  	checkSums := func(t testing.TB, got, want []int) {
  		t.Helper()
  		if !slices.Equal(got, want) {
  			t.Errorf("got %v want %v", got, want)
  		}
  	}
  
  	t.Run("make the sums of some tails of slices", func(t *testing.T) {
  		got := SumAllTails([]int{1, 2}, []int{0, 9})
  		want := []int{2, 9}
  		checkSums(t, got, want)
  	})
  
  	t.Run("safely sum empty slices", func(t *testing.T) {
  		got := SumAllTails([]int{}, []int{3, 4, 5})
  		want := []int{0, 9}
  		checkSums(t, got, want)
  	})
  }
  ```

- Since we only need the function in one place, we are declaring it and
  assigning it to a variable. It allows you to reduce the surface area of your
  API.
- Final version of this chapter's code:

  ```go
  // 05-arrays/sum_test.go
  package main
  
  import (
  	"slices"
  	"testing"
  )

  func TestSum(t *testing.T) {

  	t.Run("collection of any size", func(t *testing.T) {
  		numbers := []int{1, 2, 3}
  
  		got := Sum(numbers)
  		want := 6
  
  		if got != want {
  			t.Errorf("got %d want %d given, %v", got, want, numbers)
  		}
  	})
  }

  func TestSumAll(t *testing.T) {

  	got := SumAll([]int{1, 2}, []int{0, 9})
  	want := []int{3, 9}

  	if !slices.Equal(got, want) {
  		t.Errorf("got %v want %v", got, want)
  	}
  }

  func TestSumAllTails(t *testing.T) {

  	checkSums := func(t testing.TB, got, want []int) {
  		t.Helper()
  		if !slices.Equal(got, want) {
  			t.Errorf("got %v want %v", got, want)
  		}
  	}

  	t.Run("make the sums of some tails of slices", func(t *testing.T) {
  		got := SumAllTails([]int{1, 2}, []int{0, 9})
  		want := []int{2, 9}
  		checkSums(t, got, want)
  	})

  	t.Run("safely sum empty slices", func(t *testing.T) {
  		got := SumAllTails([]int{}, []int{3, 4, 5})
  		want := []int{0, 9}
  		checkSums(t, got, want)
  	})
  }

  // 05-arrays/sum.go
  package main

  // Sum calculates the total from a slice of numbers.
  func Sum(numbers []int) int {
  	sum := 0
  	for _, number := range numbers {
  		sum += number
  	}
  	return sum
  }

  // SumAll calculates the respective sums of every slice passed in.
  func SumAll(numbersToSum ...[]int) []int {
  	var sums []int
  	for _, numbers := range numbersToSum {
  		sums = append(sums, Sum(numbers))
  	}

  	return sums
  }

  // SumAllTails calculates the sums of all but the first number given a
  // collection of slices.
  func SumAllTails(numbersToSum ...[]int) []int {
  	var sums []int
  	for _, numbers := range numbersToSum {
  		if len(numbers) == 0 {
  			sums = append(sums, 0)
  		} else {
  			tail := numbers[1:]
  			sums = append(sums, Sum(tail))
  		}
  	}
  	return sums
  }
  ```

- Wrapping up
  - We covered:
    - Arrays
    - Slices
      - The various ways to make them
      - How they have a fixed capacity but you can create new slices from old
        ones using `append`
      - How to slice, slices!
    - `len` to get the length of an array or slice
    - Test coverage tool (`go test -cover`)
    - `slices.Equal` and why it is needed instead of regular equality operators

## Chapter 6 - Structs, methods & interfaces

- Alright, let's say we want to calculate the perimeter of a rectangle with
  decimal measurements of height and width. We know we'll need a
  `Perimeter(width float64, height float64)` function, where `float64` is a
  64-bit floating point number. We start with a test, and we use the `%f` format
  string or more specifically `%.2f` to display our floats:

  ```go
  // 06-structs/shapes_test.go
  package main

  import "testing"

  func TestPerimeter(t *testing.T) {
  	got := Perimeter(10.0, 10.0)
  	want := 40.0
  
  	if got != want {
  		t.Errorf("got %.2f want %.2f", got, want)
  	}
  }
  ```

- By now we should know how to fix it:

  ```go
  // 06-structs/shapes.go
  package main
  
  func Perimeter(width float64, height float64) float64 {
  	return 0
  }
  ```

- That will change our error to: `shapes_test.go:10: got 0.00 want 40.00`. So
  again we write just enough code to make it pass:

  ```go
  // 06-structs/shapes.go
  package main
  
  func Perimeter(width float64, height float64) float64 {
  	return 2 * (width + height)
  }
  ```

- Next we define `Area` the same way, test first.
- We're comparing floats with `==` and `!=` here, but it's safe because we're
  using whole numbers where they are exactly representable. If you were using
  0.1 or results of division, you could use `cmp.Diff` with
  `cmpopts.EquateApprox` from `go-cmp`.
- Our `Area` and `Perimeter` functions work, but it isn't obvious they are
  meant for rectangles. We will create our own type called `Rectangle` to
  encapsulate the concept using a **struct**. A struct is just a named
  collection of fields where you can store data.

  ```go
  // 06-structs/shapes.go
  type Rectangle struct {
  	Width  float64
  	Height float64
  }

  // Then refactor our tests to use it
  // 06-structs/shapes_test.go
  package main

  import "testing"

  func TestPerimeter(t *testing.T) {
  	rectangle := Rectangle{10.0, 10.0}
  	got := Perimeter(rectangle)
  	want := 40.0

  	if got != want {
  		t.Errorf("got %.2f want %.2f", got, want)
  	}
  }

  func TestArea(t *testing.T) {
  	rectangle := Rectangle{12.0, 6.0}
  	got := Area(rectangle)
  	want := 72.0

  	if got != want {
  		t.Errorf("got %.2f want %.2f", got, want)
  	}
  }
  ```

- Now when we run our tests we get an error, since our functions still expect
  two numbers but we're passing one `Rectangle`:
  `./shapes_test.go:7:19: not enough arguments in call to Perimeter`.
  So we will make our functions take rectangles and access their fields with the
  `myStruct.field` syntax:

  ```go
  // 06-structs/shapes.go
  package main

  type Rectangle struct {
  	Width  float64
  	Height float64
  }

  func Perimeter(rectangle Rectangle) float64 {
  	return 2 * (rectangle.Width + rectangle.Height)
  }

  func Area(rectangle Rectangle) float64 {
  	return rectangle.Width * rectangle.Height
  }
  ```

- And everything is green! But wait, we have a new requirement to calculate the
  area of circles. Of course we start with a test:

  ```go
  // 06-structs/shapes_test.go
  func TestArea(t *testing.T) {
  	t.Run("rectangles", func(t *testing.T) {
  		rectangle := Rectangle{12.0, 6.0}
  		got := Area(rectangle)
  		want := 72.0

  		if got != want {
  			t.Errorf("got %.2f want %.2f", got, want)
  		}
  	})

  	t.Run("circles", func(t *testing.T) {
  		circle := Circle{10.0}
  		got := Area(circle)
  		want := 314.1592653589793

  		if got != want {
  			t.Errorf("got %.2f want %.2f", got, want)
  		}
  	})
  }
  ```

- And we have the error: `./shapes_test.go:27:13: undefined: Circle`.
  So let's define a `Circle` struct:

  ```go
  // 06-structs/shapes.go
  type Circle struct {
  	Radius float64
  }
  ```

- We change our error message to:
  `./shapes_test.go:28:15: cannot use circle (variable of struct type Circle)
  as Rectangle value in argument to Area`.
- Some languages allow you to overload a function name, declaring it again with
  different parameters, but not Go. We could either declare a function with the
  same name in a new package, or we could define methods on our newly defined
  types instead.
- A method is a function with a receiver. A method declaration binds an
  identifier, the method name, to a method, and associates the method with the
  receiver's base type. Methods are very similar to functions, but they are
  called by invoking them on an instance of a particular type. Let's change our
  tests as if we already had methods defined:

  ```go
  // 06-structs/shapes_test.go
  func TestArea(t *testing.T) {
  	t.Run("rectangles", func(t *testing.T) {
  		rectangle := Rectangle{12.0, 6.0}
  		got := rectangle.Area()
  		want := 72.0

  		if got != want {
  			t.Errorf("got %.2f want %.2f", got, want)
  		}
  	})

  	t.Run("circles", func(t *testing.T) {
  		circle := Circle{10.0}
  		got := circle.Area()
  		want := 314.1592653589793

  		if got != want {
  			t.Errorf("got %.2f want %.2f", got, want)
  		}
  	})
  }
  ```

- Now we have two errors: `./shapes_test.go:18:20: rectangle.Area undefined
  (type Rectangle has no field or method Area)` and
  `./shapes_test.go:28:17: circle.Area undefined (type Circle has no field or
  method Area)`. So let's define these as methods:

  ```go
  // 06-structs/shapes.go
  type Rectangle struct {
  	Width  float64
  	Height float64
  }

  func (r Rectangle) Area() float64 {
  	return 0
  }

  type Circle struct {
  	Radius float64
  }

  func (c Circle) Area() float64 {
  	return 0
  }
  ```

- The syntax for declaring methods is almost the same as for functions aside
  from specifying the receiver:
  `func (receiverName ReceiverType) MethodName(args)`. When your method is
  called on a variable of that type, you get your reference to its data via the
  `receiverName` variable. In many programming languages this is done implicitly
  and you access the receiver via `this`. It is a convention to make the
  receiver variable the first letter of the type: `r Rectangle`. Now we just get
  errors because we're returning the wrong values:

  ```text
  --- FAIL: TestArea (0.00s)
      --- FAIL: TestArea/rectangles (0.00s)
          shapes_test.go:22: got 0.00 want 72.00
      --- FAIL: TestArea/circles (0.00s)
          shapes_test.go:32: got 0.00 want 314.16
  ```

- So we can attach calculations to our methods:

  ```go
  // 06-structs/shapes.go
  package main

  import "math"

  type Rectangle struct {
  	Width  float64
  	Height float64
  }

  func (r Rectangle) Area() float64 {
  	return r.Width * r.Height
  }

  type Circle struct {
  	Radius float64
  }

  func (c Circle) Area() float64 {
  	return math.Pi * c.Radius * c.Radius
  }
  ```

- We're green again, so it's time to refactor. We'll define a `checkArea`
  helper:

  ```go
  // 06-structs/shapes_test.go
  func TestArea(t *testing.T) {

  	checkArea := func(t testing.TB, shape Shape, want float64) {
  		t.Helper()
  		got := shape.Area()
  		if got != want {
  			t.Errorf("got %g want %g", got, want)
  		}
  	}

  	t.Run("rectangles", func(t *testing.T) {
  		rectangle := Rectangle{12.0, 6.0}
  		checkArea(t, rectangle, 72.0)
  	})

  	t.Run("circles", func(t *testing.T) {
  		circle := Circle{10.0}
  		checkArea(t, circle, 314.1592653589793)
  	})
  }
  ```

- But now we're asking for a `Shape` to be passed in. The error explains the
  problem: `./shapes_test.go:17:40: undefined: Shape`. How does something become
  a shape? We just tell Go what a `Shape` is using an interface declaration:

  ```go
  // 06-structs/shapes.go
  type Shape interface {
  	Area() float64
  }
  ```

- We're creating a new type just like we did for `Rectangle` and `Circle`, but
  this time we're creating an `interface` rather than a `struct`. In Go
  **interface resolution is implicit**. If the type you pass matches what the
  interface is asking for (here having an `Area` method that returns a
  `float64`), it will compile. Our helper does not need to concern itself with
  whether the shape is a `Rectangle` or a `Circle` or even a `Triangle`. By
  declaring an interface, the helper is *decoupled* from the concrete types and
  only has the method it needs to do its job. This kind of approach of using
  interfaces to declare **only what you need** is very important in software
  design and will be covered in more detail in later sections.
- Now with everything green again, it's time for more refactoring. We will
  implement "table driven tests". Table driven tests are useful when you want
  to build a list of test cases that can be tested in the same manner.

  ```go
  // 06-structs/shapes_test.go
  func TestArea(t *testing.T) {

  	areaTests := []struct {
  		shape Shape
  		want  float64
  	}{
  		{Rectangle{12, 6}, 72.0},
  		{Circle{10}, 314.1592653589793},
  	}

  	for _, tt := range areaTests {
  		got := tt.shape.Area()
  		if got != tt.want {
  			t.Errorf("got %g want %g", got, tt.want)
  		}
  	}
  }
  ```

- The only new syntax here is creating an "anonymous struct" `areaTests`. We
  are declaring a slice of structs by using `[]struct` with two fields, the
  `shape` and the `want`. Then we fill the slice with cases. We then iterate
  over them just like we do any other slice, using the struct fields to run
  our tests. It is very easy to add a new shape. In addition, if a bug is found
  with `Area` it is very easy to add a new test case to exercise it before
  fixing it.
- Table driven tests can be a great item in your toolbox, but be sure that you
  have a need for the extra noise in the tests. They are a great fit when you
  wish to test various implementations of an interface, or if the data being
  passed in to a function has lots of different requirements that need testing.
- It's only one line to add a test for `Triangle`: `{Triangle{12, 6}, 36.0},`.
  If we tried to run it now we get `undefined: Triangle`, so let's add that
  to `shapes.go`.

  ```go
  // 06-structs/shapes.go
  type Triangle struct {
  	Base   float64
  	Height float64
  }
  ```

- So now we get a new error. `./shapes_test.go:23:4: cannot use Triangle{…}
  (value of struct type Triangle) as Shape value in struct literal: Triangle
  does not implement Shape (missing method Area)`. We can fix that by defining
  `Area` for `Triangle`:

  ```go
  // 06-structs/shapes.go
  func (t Triangle) Area() float64 {
  	return 0
  }
  ```

- And now we just get `shapes_test.go:29: got 0 want 36`, so we need to define
  our calculation:

  ```go
  // 06-structs/shapes.go
  func (t Triangle) Area() float64 {
  	return (t.Base * t.Height) * 0.5
  }
  ```

- And we're green again! So we can refactor. Our next pain point to clean up is
  our list of test cases for `TestArea`. Look at it:

  ```go
  		{Rectangle{12, 6}, 72.0},
  		{Circle{10}, 314.1592653589793},
  		{Triangle{12, 6}, 36.0},
  ```

- It's not immediately clear what all the numbers represent. So far, we've only
  seen structs like `MyStruct{val1, val2}` but you can optionally use the names
  of the fields:

  ```go
  		{shape: Rectangle{Width: 12, Height: 6}, want: 72.0},
  		{shape: Circle{Radius: 10}, want: 314.1592653589793},
  		{shape: Triangle{Base: 12, Height: 6}, want: 36.0},
  ```

- Our current table driven tests have the problem that it's hard to tell which
  one broke when something goes wrong. We can make it clearer by giving each
  case a `name` and passing it to `t.Run`, so it becomes the subtest's name in
  the output. We can also print the shape itself in the failure message with
  `%#v`, which formats a value as Go syntax, like
  `main.Rectangle{Width:12, Height:6}`. `want` is also a little vague, so let's
  make it `hasArea`:

  ```go
  // 06-structs/shapes_test.go
  func TestArea(t *testing.T) {

  	areaTests := []struct {
  		name    string
  		shape   Shape
  		hasArea float64
  	}{
  		{name: "Rectangle", shape: Rectangle{Width: 12, Height: 6}, hasArea: 72.0},
  		{name: "Circle", shape: Circle{Radius: 10}, hasArea: 314.1592653589793},
  		{name: "Triangle", shape: Triangle{Base: 12, Height: 6}, hasArea: 36.0},
  	}

  	for _, tt := range areaTests {
  		// using tt.name from the case to use it as the `t.Run` test name
  		t.Run(tt.name, func(t *testing.T) {
  			got := tt.shape.Area()
  			if got != tt.hasArea {
  				t.Errorf("%#v got %g want %g", tt.shape, got, tt.hasArea)
  			}
  		})
  	}
  }
  ```

- Let's look at the final code for this chapter:

  ```go
  // 06-structs/shapes_test.go
  package main
  
  import "testing"
  
  func TestPerimeter(t *testing.T) {
  	rectangle := Rectangle{10.0, 10.0}
  	got := Perimeter(rectangle)
  	want := 40.0
  
  	if got != want {
  		t.Errorf("got %.2f want %.2f", got, want)
  	}
  }
  
  func TestArea(t *testing.T) {
  
  	areaTests := []struct {
  		name    string
  		shape   Shape
  		hasArea float64
  	}{
  		{name: "Rectangle", shape: Rectangle{Width: 12, Height: 6}, hasArea: 72.0},
  		{name: "Circle", shape: Circle{Radius: 10}, hasArea: 314.1592653589793},
  		{name: "Triangle", shape: Triangle{Base: 12, Height: 6}, hasArea: 36.0},
  	}
  
  	for _, tt := range areaTests {
  		// using tt.name from the case to use it as the `t.Run` test name
  		t.Run(tt.name, func(t *testing.T) {
  			got := tt.shape.Area()
  			if got != tt.hasArea {
  				t.Errorf("%#v got %g want %g", tt.shape, got, tt.hasArea)
  			}
  		})
  	}
  }
  
  // 06-structs/shapes.go
  package main
  
  import "math"
  
  // Shape is implemented by anything that can tell us its Area.
  type Shape interface {
  	Area() float64
  }
  
  // Triangle represents the dimensions of a triangle.
  type Triangle struct {
  	Base   float64
  	Height float64
  }
  
  // Area returns the area of the triangle.
  func (t Triangle) Area() float64 {
  	return (t.Base * t.Height) * 0.5
  }
  
  // Rectangle has the dimensions of a rectangle.
  type Rectangle struct {
  	Width  float64
  	Height float64
  }
  
  // Area returns the area of the rectangle.
  func (r Rectangle) Area() float64 {
  	return r.Width * r.Height
  }
  
  // Circle represents a circle...
  type Circle struct {
  	Radius float64
  }
  
  // Area returns the area of the circle.
  func (c Circle) Area() float64 {
  	return math.Pi * c.Radius * c.Radius
  }
  
  // Perimeter returns the perimeter of a rectangle.
  func Perimeter(rectangle Rectangle) float64 {
  	return 2 * (rectangle.Width + rectangle.Height)
  }
  ```

- Wrapping up
  - Declaring structs to create your own data types, which lets you bundle
    related data together and make the intent of your code clearer
  - Declaring interfaces so you can define functions that can be used by
    different types (ad hoc polymorphism)
  - Adding methods so you can add functionality to your data types and so you
    can implement interfaces
  - Table driven tests to make your assertions clearer and your test suites
    easier to extend & maintain

## Chapter 7 - Pointers & errors

- We're going to make a `Wallet` struct that lets us deposit `Bitcoin`. The idea
  with this struct is controlling access to the data via methods.

  ```go
  // 07-pointers/wallet_test.go
  package main

  import "testing"

  func TestWallet(t *testing.T) {

  	wallet := Wallet{}

  	wallet.Deposit(10)

  	got := wallet.Balance()
  	want := 10

  	if got != want {
  		t.Errorf("got %d want %d", got, want)
  	}
  }
  ```

- If we run the test now, we get `undefined: Wallet`. This is as easy to fix as
  adding a `type Wallet struct{}` line to `wallet.go`, but then we get
  `wallet.Deposit` and `wallet.Balance` undefined errors. We want the minimum
  code, so we'll define those to do nothing and return 0 (remember the
  receiver!). So now here is `wallet.go`:

  ```go
  // 07-pointers/wallet.go
  package main

  type Wallet struct{}

  func (w Wallet) Deposit(amount int) {
  
  }

  func (w Wallet) Balance() int {
  	return 0
  }
  ```

- And we get an error of `got 0 want 10`. Our tests are executing, but we're
  not getting the right value back. We could slavishly work just to pass the
  test and hardcode a return value of 10, then require multiple tests to force
  us to write working code, but we aren't taking it that far! We'll go ahead
  and give our Wallet some state.

  ```go
  // 07-pointers/wallet.go
  package main

  type Wallet struct {
  	balance int
  }

  func (w Wallet) Deposit(amount int) {
  	w.balance += amount
  }

  func (w Wallet) Balance() int {
  	return w.balance
  }
  ```

- In Go, if an identifier starts with a lowercase letter, it is private to *the
  package it's defined in.* In this case, we want our methods to manipulate
  `balance`, but no one else.
- But when we run the test, we still get `got 0 want 10`. This looks like it
  should work. In Go, when you call a function or a method the arguments are
  copied, and that includes the receiver, so when calling
  `func (w Wallet) Deposit(amount int)` the `w` is a copy of whatever we called
  the method on. So to troubleshoot we'll print out the memory address of
  `balance` in the test and within the `Deposit` method using `&wallet.balance`
  and `&w.balance`, since `&myVal` gives us the address of `myVal`. In our print
  statements, we can format it with `%p`. The `%p` placeholder prints memory
  addresses in base 16 notation with leading `0x` and `\n` prints a new line.
  Like this:

  ```go
  // 07-pointers/wallet_test.go
  	got := wallet.Balance()
  	fmt.Printf("address of balance in test is %p \n", &wallet.balance)
  	want := 10

  // 07-pointers/wallet.go
  func (w Wallet) Deposit(amount int) {
  	fmt.Printf("address of balance in Deposit is %p \n", &w.balance)
  	w.balance += amount
  }
  ```

- And when we run our test we see:

  ```text
  address of balance in Deposit is 0x41018ad90090
  address of balance in test is 0x41018ad90088
  ```

- So when we change the value of the balance in the code, we are changing a
  copy separate from what is seen by the test. The way we fix this is with
  *pointers*. Rather than taking a copy of the Wallet, we instead take a pointer
  to that wallet so we can change the original values within it.

  ```go
  // 07-pointers/wallet.go
  func (w *Wallet) Deposit(amount int) {
  	w.balance += amount
  }

  func (w *Wallet) Balance() int {
  	return w.balance
  }
  ```

- We have changed the receiver type from `Wallet` to `*Wallet`, which you can
  read as "a pointer to a wallet". When we re-run the tests, they now pass. You
  may notice that we didn't dereference the pointer, like `(*w).balance`. This
  is because pointers to structs are called *struct pointers*, and they are
  automatically dereferenced. Also, technically we didn't need to change the
  receiver for `Balance`, as we weren't modifying anything and could read from
  a copy, but by convention you should keep your method receiver types the same
  for consistency.
- Now that the tests pass, we want a simple refactor. We are using `int` for
  money, but we mean `Bitcoin`. `int` is actually fine for this, but we want a
  more descriptive name. So `type Bitcoin int` lets us create a `Bitcoin` type
  from `int`. To make `Bitcoin` we simply use `Bitcoin(999)`. By doing this, we
  can declare methods on our new type. We want to be able to print `Bitcoin`, so
  we will implement `Stringer`. For reference, here is `Stringer`:

  ```go
  type Stringer interface {
  	String() string
  }
  ```

- `Stringer` is defined in the `fmt` package and lets you define how your type
  is printed when used with the `%s` or `%v` format strings, or printed directly
  with `fmt.Println`.

  ```go
  func (b Bitcoin) String() string {
  	return fmt.Sprintf("%d BTC", b)
  }
  ```

- The syntax for creating a method on a type declaration is the same as for a
  struct. We didn't write a test in advance for this `String` method, so we'll
  add one now. We'll also add a separate test for "withdraw" within
  `TestWallet`:

  ```go
  // 07-pointers/wallet_test.go
  package main

  import (
  	"testing"
  )

  func TestWallet(t *testing.T) {

  	t.Run("deposit", func(t *testing.T) {
  		wallet := Wallet{}

  		wallet.Deposit(Bitcoin(10))

  		got := wallet.Balance()
  		want := Bitcoin(10)

  		if got != want {
  			t.Errorf("got %s want %s", got, want)
  		}
  	})

  	t.Run("withdraw", func(t *testing.T) {
  		wallet := Wallet{balance: Bitcoin(20)}

  		wallet.Withdraw(Bitcoin(10))

  		got := wallet.Balance()
  		want := Bitcoin(10)

  		if got != want {
  			t.Errorf("got %s want %s", got, want)
  		}
  	})
  }

  func TestBitcoin(t *testing.T) {
  	t.Run("Bitcoin String", func(t *testing.T) {
  		btc := Bitcoin(10)
  		got := btc.String()
  		want := "10 BTC"

  		if got != want {
  			t.Errorf("got %s want %s", got, want)
  		}
  	})
  }
  ```

- And of course this fails with `wallet.Withdraw undefined`, so we add an empty
  method and get `got 20 BTC want 10 BTC`, so we specify `w.balance -= amount`.
  And we're back to green. We take this opportunity to factor out an
  `assertBalance` helper for both our balance checks.
- So now we need to think about what happens when we try to withdraw more than
  is in an account. In Go, it is idiomatic for your function to return an
  `error` for the caller to check and act on. So we'll assume that
  functionality is there when writing our test:

  ```go
  // 07-pointers/wallet_test.go
  	t.Run("withdraw insufficient funds", func(t *testing.T) {
  		startingBalance := Bitcoin(20)
  		wallet := Wallet{startingBalance}
  		err := wallet.Withdraw(Bitcoin(100))

  		assertBalance(t, wallet, startingBalance)

  		if err == nil {
  			t.Error("wanted an error but didn't get one")
  		}
  	})
  ```

- This new test fails with
  `./wallet_test.go:35:10: wallet.Withdraw(Bitcoin(100)) (no value) used as
  value`, which is a little unclear. It's actually a build failure because
  `Withdraw` has no return value. If we update `Withdraw`:

  ```go
  // 07-pointers/wallet.go
  func (w *Wallet) Withdraw(amount Bitcoin) error {
  	w.balance -= amount
  	return nil
  }
  ```

- Now we get a proper error message:

  ```text
  --- FAIL: TestWallet (0.00s)
      --- FAIL: TestWallet/withdraw_insufficient_funds (0.00s)
          wallet_test.go:37: got -80 BTC want 20 BTC
          wallet_test.go:40: wanted an error but didn't get one
  ```

- So clearly we need to both deal with the situation so we don't overdraw funds
  and return an `err`. `errors.New` is how you create an error.

  ```go
  // 07-pointers/wallet.go
  func (w *Wallet) Withdraw(amount Bitcoin) error {

  	if amount > w.balance {
  		return errors.New("oh no")
  	}

  	w.balance -= amount
  	return nil
  }
  ```

- This gets our test suite green again, but we're going to refactor in two ways.
  First we want an `assertError` to match our `assertBalance`. Second, we want a
  better error message than "oh no", and to do that we need a way to test the
  error string.

  ```go
  // 07-pointers/wallet_test.go
  func TestWallet(t *testing.T) {
  	// ...
  	assertError := func(t testing.TB, got error, want string) {
  		t.Helper()

  		if got == nil {
  			t.Fatal("wanted an error but didn't get one")
  		}

  		if got.Error() != want {
  			t.Errorf("got %q, want %q", got, want)
  		}
  	}
  	// ...
  	t.Run("withdraw insufficient funds", func(t *testing.T) {
  		startingBalance := Bitcoin(20)
  		wallet := Wallet{startingBalance}
  		err := wallet.Withdraw(Bitcoin(100))
  
  		assertError(t, err, "cannot withdraw, insufficient funds")
  		assertBalance(t, wallet, startingBalance)
  	})
  }
  ```

- As you can see above, by calling the `Error` method on an `error`, we can
  convert it to a string. First we make sure it is not `nil`, so we don't call
  `Error` on `nil`. We're also using `t.Fatal`, which will stop the test if it
  is called. This is because we don't want to make any more assertions on the
  error returned if there isn't one around. Without this the test could carry
  on to the next step and panic because of a nil pointer. Now when we run the
  tests, we get
  `wallet_test.go:49: got "oh no", want "cannot withdraw, insufficient funds"`,
  which is as easy to fix as updating our error message in `wallet.go`. When we
  correct that and go green again, it is time to refactor. The current problem
  is we have our error message string hardcoded in two places. It would be
  really annoying for the test to fail if someone reworded the error. We will
  refactor this out to a
  `var ErrInsufficientFunds = errors.New("cannot withdraw, insufficient funds")`
  and rework our test to check for this instead of a string. While we're
  refactoring, we move the helpers out of the tests and into separate functions,
  so when someone opens up a file they can start reading assertions first
  instead of helpers. We also refactor our `assertError` to use `errors.Is`
  rather than an equality check so it can catch wrapped errors.
- The tests here help us understand the *real* usage of our code so we can make
  sympathetic code. We can see here that a developer can simply call our code,
  use `errors.Is` to check for `ErrInsufficientFunds`, and act accordingly.
- We will also install errcheck. To do so, run
  `go install github.com/kisielk/errcheck@latest`. It is a linter you can run
  by typing `errcheck .` in your project directory. If we run it now, it will
  say `wallet_test.go:19:18: wallet.Withdraw(Bitcoin(10))`. It is pointing out
  that we don't check for the absence of an `error` when we call `Withdraw` in
  our normal withdraw scenario. We will refactor our test now and define an
  `assertNoError` helper to check this.
- Also, I mentioned using `errors.Is` earlier, but here the book explains why.
  Imagine we have a method that calls this code:

  ```go
  func ProcessWithdrawal(wallet *Wallet, accountID string,
  	amount Bitcoin) error {
  	if err := wallet.Withdraw(amount); err != nil {
  		return fmt.Errorf("processing withdrawal for account %s: %w",
  			accountID, err)
  	}
  	return nil
  }
  ```

- The `%w` verb is like `%v` in that it substitutes in `err`'s string, but it
  also wraps `err` inside the new error that `fmt.Errorf` returns, rather than
  copying its message into a new, unrelated string. So we have the higher level
  context of `accountID` but still have the underlying `err` from underneath.
  Since `ProcessWithdrawal` returns a different error than
  `ErrInsufficientFunds`, comparing with `==` would fail. `errors.Is` solves
  this problem - it checks a chain of wrapped errors, not just the outermost
  one. It works by repeatedly calling `errors.Unwrap` on `err` until it either
  finds a match or runs out of errors to unwrap. If you need to check for an
  error of a particular *type* (and get at its fields) rather than compare
  against a sentinel value like `ErrInsufficientFunds`, then you'll need
  `errors.As`, which will be explained in the error types chapter later. Rule
  of thumb: use `errors.Is` to check *which* error it is, and `errors.As` to
  get *data out of* it.
- Final code:

  ```go
  // 07-pointers/wallet_test.go
  package main

  import (
  	"errors"
  	"testing"
  )

  func TestWallet(t *testing.T) {

  	t.Run("deposit", func(t *testing.T) {
  		wallet := Wallet{}
  		wallet.Deposit(Bitcoin(10))

  		assertBalance(t, wallet, Bitcoin(10))
  	})

  	t.Run("withdraw", func(t *testing.T) {
  		wallet := Wallet{balance: Bitcoin(20)}
  		err := wallet.Withdraw(Bitcoin(10))

  		assertNoError(t, err)
  		assertBalance(t, wallet, Bitcoin(10))
  	})

  	t.Run("withdraw insufficient funds", func(t *testing.T) {
  		startingBalance := Bitcoin(20)
  		wallet := Wallet{startingBalance}
  		err := wallet.Withdraw(Bitcoin(100))

  		assertError(t, err, ErrInsufficientFunds)
  		assertBalance(t, wallet, startingBalance)
  	})
  }

  func TestBitcoin(t *testing.T) {
  	t.Run("Bitcoin String", func(t *testing.T) {
  		btc := Bitcoin(10)
  		got := btc.String()
  		want := "10 BTC"

  		if got != want {
  			t.Errorf("got %s want %s", got, want)
  		}
  	})
  }

  func assertBalance(t testing.TB, wallet Wallet, want Bitcoin) {
  	t.Helper()
  	got := wallet.Balance()

  	if got != want {
  		t.Errorf("got %s want %s", got, want)
  	}
  }

  func assertNoError(t testing.TB, got error) {
  	t.Helper()
  	if got != nil {
  		t.Fatal("got an error but didn't want one")
  	}
  }

  func assertError(t testing.TB, got error, want error) {
  	t.Helper()

  	if got == nil {
  		t.Fatal("wanted an error but didn't get one")
  	}

  	if !errors.Is(got, want) {
  		t.Errorf("got %q, want %q", got, want)
  	}
  }

  // 07-pointers/wallet.go
  package main

  import (
  	"errors"
  	"fmt"
  )

  // ErrInsufficientFunds means a wallet does not have enough Bitcoin to
  // perform a withdraw.
  var ErrInsufficientFunds = errors.New("cannot withdraw, insufficient funds")

  // Bitcoin represents a number of Bitcoins.
  type Bitcoin int

  func (b Bitcoin) String() string {
  	return fmt.Sprintf("%d BTC", b)
  }

  // Wallet stores the number of Bitcoin someone owns.
  type Wallet struct {
  	balance Bitcoin
  }

  // Deposit will add some Bitcoin to a wallet.
  func (w *Wallet) Deposit(amount Bitcoin) {
  	w.balance += amount
  }

  // Withdraw subtracts some Bitcoin from the wallet, returning an error if it
  // cannot be performed.
  func (w *Wallet) Withdraw(amount Bitcoin) error {

  	if amount > w.balance {
  		return ErrInsufficientFunds
  	}

  	w.balance -= amount
  	return nil
  }

  // Balance returns the number of Bitcoin a wallet has.
  func (w *Wallet) Balance() Bitcoin {
  	return w.balance
  }
  ```

- Wrapping up
  - Pointers
    - Go copies values when you pass them to functions/methods, so if you're
      writing a function that needs to mutate state you'll need it to take a
      pointer to the thing you want to change.
    - The fact that Go takes a copy of values is useful a lot of the time, but
      sometimes you won't want your system to make a copy of something, in
      which case you need to pass a reference. Examples include referencing
      very large data structures or things where only one instance is necessary
      (like database connection pools).
  - nil
    - Pointers can be nil
    - When a function returns a pointer to something, you need to make sure you
      check if it's nil, or you might get a runtime panic - the compiler won't
      help you here.
    - Useful for when you want to describe a value that could be missing
  - Errors
    - Errors are the way to signify failure when calling a function/method.
    - By listening to our tests we concluded that checking for a string in an
      error would result in a flaky test. So we refactored our implementation
      to use a meaningful value instead, and this resulted in easier to test
      code and concluded this would be easier for users of our API too.
    - This is not the end of the story with error handling; you can do more
      sophisticated things, but this is just an intro. Later sections will
      cover more strategies.
    - Don't just check errors, handle them gracefully
  - Create new types from existing ones
    - Useful for adding more domain specific meaning to values
    - Can let you implement interfaces

## Chapter 8 - Maps

- Declaring a map is somewhat similar to an array, except it starts with the
  `map` keyword and requires two types. The key type is written in `[]` and the
  value type goes right after the `[]`, as in `map[string]string`. The key must
  be a comparable type (one that works with `==`), which is explained in depth
  in the language spec at <https://go.dev/ref/spec#Comparison_operators>. The
  value can be any type:

  ```go
  // 08-maps/dictionary_test.go
  package main

  import "testing"

  func TestSearch(t *testing.T) {
  	dictionary := map[string]string{"test": "this is just a test"}

  	got := Search(dictionary, "test")
  	want := "this is just a test"

  	if got != want {
  		t.Errorf("got %q want %q given, %q", got, want, "test")
  	}
  }

  // and after we get "undefined: Search"
  // 08-maps/dictionary.go
  package main

  func Search(dictionary map[string]string, word string) string {
  	return ""
  }
  ```

- Now our error is:
  `dictionary_test.go:12: got "" want "this is just a test" given, "test"`, so
  we can write some code. Most of the logic is in the map, though; all we need
  for the body of `Search` is `return dictionary[word]`. Getting a value out of
  a map looks like indexing an array, but with a key: `myMap[key]`.
- While we're green, we define an `assertStrings` helper to compare the
  results.
- I feel like we understand TDD well enough now that I'm not going to report
  every time we fail for something not defined or not returning the right
  values. Here we added a new test for a word not in the dictionary that
  required us to return an `error`. Until we modified the function to return two
  values, it wouldn't compile. And then we had to change our map lookup to check
  `ok` and return a real `ErrNotFound` when the entry isn't there. `ErrNotFound`
  is an honest to goodness error defined like we did last chapter. I'll post the
  whole file here in a minute. After the test passes, we also extract an
  `assertError` function and pass it our new `ErrNotFound`.
- A map lookup can return 2 values. The second value is a boolean which
  indicates if the key was found successfully. This lets us differentiate
  between a word that doesn't exist in the map and one whose definition is the
  zero value (an empty string), since a missing key also reads as `""`.
- That's a lot of changes! Let's see where our code stands now that we're back
  to green and have refactored our error testing:

  ```go
  // 08-maps/dictionary_test.go
  package main

  import (
  	"errors"
  	"testing"
  )

  func TestSearch(t *testing.T) {
  	dictionary := Dictionary{"test": "this is just a test"}

  	t.Run("known word", func(t *testing.T) {
  		got, _ := dictionary.Search("test")
  		want := "this is just a test"

  		assertStrings(t, got, want)
  	})

  	t.Run("unknown word", func(t *testing.T) {
  		_, got := dictionary.Search("unknown")
  		if got == nil {
  			t.Fatal("expected to get an error.")
  		}
  		assertError(t, got, ErrNotFound)
  	})
  }

  func assertStrings(t testing.TB, got, want string) {
  	t.Helper()

  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}
  }

  func assertError(t testing.TB, got, want error) {
  	t.Helper()

  	if !errors.Is(got, want) {
  		t.Errorf("got error %q want %q", got, want)
  	}
  }

  // 08-maps/dictionary.go
  package main

  import "errors"

  type Dictionary map[string]string

  var ErrNotFound = errors.New("could not find the word you were looking for")

  func (d Dictionary) Search(word string) (string, error) {
  	definition, ok := d[word]
  	if !ok {
  		return "", ErrNotFound
  	}
  	return definition, nil
  }
  ```

- A dictionary with one word in it isn't very helpful, so we need a way to add
  words and for that we need a `TestAdd`.

  ```go
  // 08-maps/dictionary_test.go
  func TestAdd(t *testing.T) {
  	dictionary := Dictionary{}
  	dictionary.Add("test", "this is just a test")

  	want := "this is just a test"
  	got, err := dictionary.Search("test")
  	if err != nil {
  		t.Fatal("should find added word:", err)
  	}
  	assertStrings(t, got, want)
  }
  ```

- I also learned a little more about gopls. `grd` jumps to definition, then
  `Ctrl-o`/`Ctrl-i` jump back and forward. `gra` opens the code actions menu;
  on an undefined function it offers to create a stub for it (check the
  signature afterward, since gopls often guesses the return types wrong). `grn`
  is rename symbol. `grd` is one of a series of jumps: `grd`/`grt`/`gri` go to
  definition/type definition/implementation. `gO` lists the symbols in the
  current file and `gW` searches symbols project wide. `gW` is a live search,
  so its list stays empty until you start typing a name. `K` on a method shows
  its documentation. And `<leader>sd` (space, then `sd`) searches diagnostics.
  That's a few helpful shortcuts; there are many more. (GOPLS Shortcuts)
- I started running my tests automatically by splitting my tmux window with
  `C-a %` then switching to my `learning-go-with-tests` directory and running
  `gotestsum -watch`. I have to restart it when I make a new directory. To
  workaround this, I now run a zsh alias `gtw` for go test watch.
- The body of our new `Add` function is simply `d[word] = definition`. It takes
  two string parameters: `word` and `definition`. Adding to a map is similar to
  assigning to an array element. You just need to specify a key and set it
  equal to a value. An interesting property of maps is that you can modify them
  without passing their address (e.g. `&myMap`). A map value is really a
  pointer to the underlying data structure, so passing a map only copies that
  pointer.
- A gotcha with maps is that they can be a `nil` value. A `nil` map behaves
  like an empty map when reading, but attempts to write to a `nil` map will
  cause a runtime panic. So never declare a map with `var m map[string]string`
  and then write to it. Instead do `var dictionary = map[string]string{}`, with
  the `{}` at the end, or `var dictionary = make(map[string]string)`. Both
  approaches create an empty hash map and point `dictionary` at it, so you will
  never get a runtime panic.
- We did factor out an `assertDefinition` test helper and use it in `TestAdd`,
  along with having another test:

  ```go
  // 08-maps/dictionary_test.go
  func TestAdd(t *testing.T) {
  	t.Run("new word", func(t *testing.T) {
  		dictionary := Dictionary{}
  		word := "test"
  		definition := "this is just a test"

  		err := dictionary.Add(word, definition)

  		assertError(t, err, nil)
  		assertDefinition(t, dictionary, word, definition)
  	})

  	t.Run("existing word", func(t *testing.T) {
  		word := "test"
  		definition := "this is just a test"
  		dictionary := Dictionary{word: definition}
  		err := dictionary.Add(word, "new test")
  		assertError(t, err, ErrWordExists)
  		assertDefinition(t, dictionary, word, definition)
  	})
  }

  func assertDefinition(t testing.TB, dictionary Dictionary, word, definition string) {
  	t.Helper()
  	got, err := dictionary.Search(word)
  	if err != nil {
  		t.Fatal("should find added word:", err)
  	}
  	assertStrings(t, got, definition)
  }
  ```

- Our add function doesn't return anything yet and `ErrWordExists` needs
  definition:

  ```go
  // 08-maps/dictionary.go
  var (
  	ErrNotFound   = errors.New("could not find the word you were looking for")
  	ErrWordExists = errors.New("cannot add word because it already exists")
  )

  func (d Dictionary) Add(word, definition string) error {
  	_, err := d.Search(word)
  
  	switch err {
  	case ErrNotFound:
  		d[word] = definition
  	case nil:
  		return ErrWordExists
  	default:
  		return err
  	}
  
  	return nil
  }
  ```

- By using a `switch` to check the error we have an extra safety net in case
  `Search` returns an error other than `ErrNotFound`. We're also going to
  refactor our errors now that we're green again:

  ```go
  // 08-maps/dictionary.go
  const (
  	ErrNotFound   = DictionaryErr("could not find the word you were looking for")
  	ErrWordExists = DictionaryErr("cannot add word because it already exists")
  )

  type DictionaryErr string

  func (e DictionaryErr) Error() string {
  	return string(e)
  }
  ```

- So here we changed our errors to constants; this required us to create our
  own `DictionaryErr` type, which implements the `error` interface. Note that
  `T(x)` is Go's type conversion syntax. We're converting a string error message
  to a `DictionaryErr`, and in the `Error` method converting it back to a
  `string`. Go lets you convert freely between types that share an underlying
  type. Note that `string(someInt)` doesn't convert to the string form of the
  number but instead treats the integer as a Unicode code point (`go vet` warns
  about it). Use `strconv.Itoa(someInt)` or `fmt.Sprint(someInt)`. But
  converting between `string` types like we do here is always safe.
- Now we want to add a way to `Update` definitions; test first of course.

  ```go
  // 08-maps/dictionary_test.go
  func TestUpdate(t *testing.T) {
  	word := "test"
  	definition := "this is just a test"
  	dictionary := Dictionary{word: definition}
  	newDefinition := "new definition"

  	dictionary.Update(word, newDefinition)

  	assertDefinition(t, dictionary, word, newDefinition)
  }

  // and after we see the test fail
  // 08-maps/dictionary.go
  func (d Dictionary) Update(word, definition string) {
  	d[word] = definition
  }
  ```

- But this has the reverse of the problem with `Add`. If you give it a word not
  in the dictionary, it adds it. Let's write some tests to catch this behavior:

  ```go
  // 08-maps/dictionary_test.go
  func TestUpdate(t *testing.T) {
  	t.Run("existing word", func(t *testing.T) {
  		word := "test"
  		definition := "this is just a test"
  		dictionary := Dictionary{word: definition}
  		newDefinition := "new definition"

  		err := dictionary.Update(word, newDefinition)

  		assertError(t, err, nil)
  		assertDefinition(t, dictionary, word, newDefinition)
  	})

  	t.Run("new word", func(t *testing.T) {
  		word := "test"
  		definition := "this is just a test"
  		dictionary := Dictionary{}

  		err := dictionary.Update(word, definition)

  		assertError(t, err, ErrWordDoesNotExist)
  	})
  }

  // 08-maps/dictionary.go
  const (
  	ErrNotFound         = DictionaryErr("could not find the word you were looking for")
  	ErrWordExists       = DictionaryErr("cannot add word because it already exists")
  	ErrWordDoesNotExist = DictionaryErr("cannot perform operation on word because it does not exist")
  )

  func (d Dictionary) Update(word, definition string) error {
  	_, err := d.Search(word)

  	switch err {
  	case ErrNotFound:
  		return ErrWordDoesNotExist
  	case nil:
  		d[word] = definition
  	default:
  		return err
  	}

  	return nil
  }
  ```

- This looks almost identical to `Add`, but the two cases are swapped: we
  update the `dictionary` on `nil` and return an error on `ErrNotFound`.
- We could have reused `ErrNotFound` instead of declaring a new error, but it is
  often better to have a precise error for when an update fails. Specific errors
  give you more information about what went wrong. In a webapp, for example, we
  might want to redirect on `ErrNotFound` and display an error on
  `ErrWordDoesNotExist`.
- Now we're going to create a `Delete` function:

  ```go
  // 08-maps/dictionary_test.go
  func TestDelete(t *testing.T) {
  	word := "test"
  	dictionary := Dictionary{word: "test definition"}

  	dictionary.Delete(word)

  	_, err := dictionary.Search(word)
  	assertError(t, err, ErrNotFound)
  }

  // 08-maps/dictionary.go
  func (d Dictionary) Delete(word string) {
  	delete(d, word)
  }
  ```

- The `delete` command takes a map and a key and deletes the key from the map.
- This is green, but we might as well refactor to handle cases where the word
  doesn't exist. We should recognize the pattern by now:

  ```go
  // 08-maps/dictionary_test.go
  func TestDelete(t *testing.T) {
  	t.Run("existing word", func(t *testing.T) {
  		word := "test"
  		dictionary := Dictionary{word: "test definition"}

  		err := dictionary.Delete(word)

  		assertError(t, err, nil)
  		_, err = dictionary.Search(word)
  		assertError(t, err, ErrNotFound)
  	})

  	t.Run("non-existing word", func(t *testing.T) {
  		word := "test"
  		dictionary := Dictionary{}

  		err := dictionary.Delete(word)
  		assertError(t, err, ErrWordDoesNotExist)
  	})
  }

  // 08-maps/dictionary.go
  func (d Dictionary) Delete(word string) error {
  	_, err := d.Search(word)

  	switch err {
  	case ErrNotFound:
  		return ErrWordDoesNotExist
  	case nil:
  		delete(d, word)
  	default:
  		return err
  	}
  
  	return nil
  }
  ```

- Final code:

  ```go
  // 08-maps/dictionary_test.go
  package main

  import (
  	"errors"
  	"testing"
  )

  func TestSearch(t *testing.T) {
  	dictionary := Dictionary{"test": "this is just a test"}

  	t.Run("known word", func(t *testing.T) {
  		got, _ := dictionary.Search("test")
  		want := "this is just a test"

  		assertStrings(t, got, want)
  	})

  	t.Run("unknown word", func(t *testing.T) {
  		_, got := dictionary.Search("unknown")
  		if got == nil {
  			t.Fatal("expected to get an error.")
  		}
  		assertError(t, got, ErrNotFound)
  	})
  }

  func TestAdd(t *testing.T) {
  	t.Run("new word", func(t *testing.T) {
  		dictionary := Dictionary{}
  		word := "test"
  		definition := "this is just a test"

  		err := dictionary.Add(word, definition)

  		assertError(t, err, nil)
  		assertDefinition(t, dictionary, word, definition)
  	})

  	t.Run("existing word", func(t *testing.T) {
  		word := "test"
  		definition := "this is just a test"
  		dictionary := Dictionary{word: definition}
  		err := dictionary.Add(word, "new test")
  		assertError(t, err, ErrWordExists)
  		assertDefinition(t, dictionary, word, definition)
  	})
  }

  func TestUpdate(t *testing.T) {
  	t.Run("existing word", func(t *testing.T) {
  		word := "test"
  		definition := "this is just a test"
  		dictionary := Dictionary{word: definition}
  		newDefinition := "new definition"

  		err := dictionary.Update(word, newDefinition)

  		assertError(t, err, nil)
  		assertDefinition(t, dictionary, word, newDefinition)
  	})

  	t.Run("new word", func(t *testing.T) {
  		word := "test"
  		definition := "this is just a test"
  		dictionary := Dictionary{}

  		err := dictionary.Update(word, definition)

  		assertError(t, err, ErrWordDoesNotExist)
  	})
  }

  func TestDelete(t *testing.T) {
  	t.Run("existing word", func(t *testing.T) {
  		word := "test"
  		dictionary := Dictionary{word: "test definition"}

  		err := dictionary.Delete(word)

  		assertError(t, err, nil)
  		_, err = dictionary.Search(word)
  		assertError(t, err, ErrNotFound)
  	})

  	t.Run("non-existing word", func(t *testing.T) {
  		word := "test"
  		dictionary := Dictionary{}

  		err := dictionary.Delete(word)
  		assertError(t, err, ErrWordDoesNotExist)
  	})
  }

  func assertStrings(t testing.TB, got, want string) {
  	t.Helper()

  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}
  }

  func assertError(t testing.TB, got, want error) {
  	t.Helper()

  	if !errors.Is(got, want) {
  		t.Errorf("got error %q want %q", got, want)
  	}
  }

  func assertDefinition(t testing.TB, dictionary Dictionary, word, definition string) {
  	t.Helper()
  	got, err := dictionary.Search(word)
  	if err != nil {
  		t.Fatal("should find added word:", err)
  	}
  	assertStrings(t, got, definition)
  }

  // 08-maps/dictionary.go
  package main

  const (
  	// ErrNotFound means the definition could not be found for the given word
  	ErrNotFound = DictionaryErr("could not find the word you were looking for")

  	// ErrWordExists means you are trying to add a word that is already known
  	ErrWordExists = DictionaryErr("cannot add word because it already exists")

  	// ErrWordDoesNotExist occurs when trying to perform an operation on a word
  	// not in the dictionary
  	ErrWordDoesNotExist = DictionaryErr("cannot perform operation on word because it does not exist")
  )

  // Dictionary store definitions to words.
  type Dictionary map[string]string

  // DictionaryErr are errors that can happen when interacting with the
  // dictionary.
  type DictionaryErr string

  func (e DictionaryErr) Error() string {
  	return string(e)
  }

  // Add inserts a word and definition into the dictionary.
  func (d Dictionary) Add(word, definition string) error {
  	_, err := d.Search(word)

  	switch err {
  	case ErrNotFound:
  		d[word] = definition
  	case nil:
  		return ErrWordExists
  	default:
  		return err
  	}

  	return nil
  }

  // Delete removes a word from the dictionary.
  func (d Dictionary) Delete(word string) error {
  	_, err := d.Search(word)

  	switch err {
  	case ErrNotFound:
  		return ErrWordDoesNotExist
  	case nil:
  		delete(d, word)
  	default:
  		return err
  	}

  	return nil
  }

  // Update changes the definition of a given word.
  func (d Dictionary) Update(word, definition string) error {
  	_, err := d.Search(word)

  	switch err {
  	case ErrNotFound:
  		return ErrWordDoesNotExist
  	case nil:
  		d[word] = definition
  	default:
  		return err
  	}

  	return nil
  }

  // Search find a word in the dictionary.
  func (d Dictionary) Search(word string) (string, error) {
  	definition, ok := d[word]
  	if !ok {
  		return "", ErrNotFound
  	}
  	return definition, nil
  }
  ```

- Wrapping up
  - In this section we made a full CRUD (Create, Read, Update and Delete) API for
    our dictionary and throughout the process learned how to:
    - Create maps
    - Search for items in maps
    - Add new items to maps
    - Update items in maps
    - Delete items from a map
    - Learned more about errors
      - How to create errors that are constants
      - Writing error wrappers

## Chapter 9 - Dependency Injection

- The benefits of dependency injection include:
  - You don't need a framework
  - It does not overcomplicate your design
  - It facilitates testing
  - It allows you to write great, general-purpose functions.
- Imagine we have the following function:

  ```go
  func Greet(name string) {
  	fmt.Printf("Hello, %s", name)
  }
  ```

- We want to test it, but it prints to stdout. What we need to do is **inject**
  the dependency of printing. Our function doesn't need to care *where* or *how*
  the printing happens, so we should accept an *interface* rather than a
  concrete type. If we do that, we can then change the implementation to print
  to something we control so we can test it. In "real life" we would inject
  something that writes to stdout. You can see in the source code for
  `fmt.Printf` there is already a seam for us to hook in:

  ```go
  // It returns the number of bytes written and any write error encountered
  func Printf(format string, a ...interface{}) (n int, err error) {
  	return Fprintf(os.Stdout, format, a...)
  }
  ```

- But what exactly is an `os.Stdout`? We can see from the definition of `Fprintf`:

  ```go
  func Fprintf(w io.Writer, format string, a ...interface{}) (n int, err error) {
  	p := newPrinter()
  	p.doPrintf(format, a)
  	n, err = w.Write(p.buf)
  	p.free()
  	return
  }
  ```

- An `io.Writer`:

  ```go
  type Writer interface {
  	Write(p []byte) (n int, err error)
  }
  ```

- So we see that `os.Stdout` implements `io.Writer`; `Printf` passes `os.Stdout`
  to `Fprintf` which expects an `io.Writer`. As you write more Go code, you'll see
  this interface popping up a lot because it's a great general purpose interface
  for "put this data somewhere". So we know under the covers we're ultimately
  using `Writer` to send our greeting somewhere and we will use this existing
  abstraction to make our code testable and more reusable.

  ```go
  // 09-di/di_test.go
  package main

  import (
  	"bytes"
  	"testing"
  )

  func TestGreet(t *testing.T) {
  	buffer := bytes.Buffer{}
  	Greet(&buffer, "Chris")

  	got := buffer.String()
  	want := "Hello, Chris"

  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}
  }
  ```

- The `Buffer` type from the `bytes` package implements the `Writer` interface,
  because it has the method `Write(p []byte) (n int, err error)`. We start with
  an implementation that ignores the `Buffer` and does `fmt.Printf`.

  ```go
  // 09-di/di.go
  package main

  import (
  	"bytes"
  	"fmt"
  )

  func Greet(writer *bytes.Buffer, name string) {
  	fmt.Printf("Hello, %s", name)
  }
  ```

- That gets us to the `got "" want "Hello, Chris"` error message. We can even
  see the output when the test runs. Remember `fmt.Fprintf` is like
  `fmt.Printf` but takes a `Writer`, whereas `fmt.Printf` defaults to stdout.

  ```go
  // 09-di/di.go
  func Greet(writer *bytes.Buffer, name string) {
  	fmt.Fprintf(writer, "Hello, %s", name)
  }
  ```

- We have made our new function too specific now. It only takes a `*bytes.Buffer`
  and not `os.Stdout`. If we change this, we can use `Greet` in both tests and
  `main`:

  ```go
  // 09-di/di.go
  package main

  import (
  	"fmt"
  	"io"
  	"os"
  )

  func Greet(writer io.Writer, name string) {
  	fmt.Fprintf(writer, "Hello, %s", name)
  }

  func main() {
  	Greet(os.Stdout, "Elodie")
  }
  ```

- Now that we take `io.Writer` we have options for where to send our greeting.
  We could pass in an `http.ResponseWriter` and define a `MyGreeterHandler`.
  `http.ResponseWriter` also implements `io.Writer` allowing us to re-use `Greet`.
  We do this in the final code for the chapter below:

  ```go
  // 09-di/di_test.go
  package main

  import (
  	"bytes"
  	"testing"
  )

  func TestGreet(t *testing.T) {
  	buffer := bytes.Buffer{}
  	Greet(&buffer, "Chris")

  	got := buffer.String()
  	want := "Hello, Chris"

  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}
  }

  // 09-di/di.go
  package main

  import (
  	"fmt"
  	"io"
  	"log"
  	"net/http"
  )

  // Greet sends a personalised greeting to writer.
  func Greet(writer io.Writer, name string) {
  	fmt.Fprintf(writer, "Hello, %s", name)
  }

  // MyGreeterHandler says Hello, world over HTTP.
  func MyGreeterHandler(w http.ResponseWriter, r *http.Request) {
  	Greet(w, "world")
  }

  func main() {
  	log.Fatal(http.ListenAndServe(":5001", http.HandlerFunc(MyGreeterHandler)))
  }
  ```

- Our first round of code was not easy to test because it wrote data to
  somewhere we couldn't control. Motivated by our tests we refactored the code
  so we could control where the data was written by **injecting a dependency**,
  which allowed us to:
  - **Test our code.** If you can't test a function easily, it's usually because
    of dependencies hard-wired into a function or global state. If you have a
    global database connection pool, for instance, that is used by some kind of
    service layer, it is likely going to be difficult to test and slow to run.
    DI will motivate you to inject in a database dependency (via an interface)
    which you can then mock out with something you can control in your tests.
  - **Separate our concerns**, decoupling *where the data goes* from *how to
    generate it*. If you ever feel like a method/function has too many
    responsibilities (generating data and writing to a db? handling HTTP
    requests and doing domain level logic?) DI is probably going to be the tool
    you need.
  - **Allow our code to be re-used in different contexts.** The first "new"
    context our code can be used in is inside tests. But further on, if someone
    wants to try something new with your function, they can inject their own
    dependencies.
- You use mocking to replace real things you inject with a pretend version that
  you can control and inspect in your tests. We'll discuss it more next chapter.
  In this example, the standard library had something ready for us to use.
- By having some familiarity with the `io.Writer` interface we are able to use
  `bytes.Buffer` in our test as our `Writer`, and then we can use other
  `Writer`s from the standard library to use our function in a command line app
  or in a web server. The more familiar you are with the standard library, the
  more you'll see these general purpose interfaces, which you can then re-use in
  your own code to make your software reusable in a number of contexts.

## Chapter 10 - Mocking

- We want a program that counts down from 3, printing each number on a new line
  with a 1-second pause, and when it reaches zero it will print "Go!" and exit.
  We want to design this simple application through an iterative, test-driven
  approach. It's an important skill to be able to slice up requirements as small
  as you can so you can have working software. So we're breaking this into three
  steps:
  - Print 3
  - Print 3, 2, 1 and Go!
  - Wait a second between each line
- We just learned last chapter how to test a program that prints to stdout.

  ```go
  // 10-mocking/countdown_test.go
  package main

  import (
  	"bytes"
  	"testing"
  )

  func TestCountdown(t *testing.T) {
  	buffer := &bytes.Buffer{}

  	Countdown(buffer)

  	got := buffer.String()
  	want := "3"

  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}
  }
  
  // then we see Countdown undefined, then we need to take arguments, then we need
  // to print 3!
  // 10-mocking/main.go
  package main

  import (
  	"fmt"
  	"io"
  	"os"
  )

  func main() {
  	Countdown(os.Stdout)
  }

  func Countdown(out io.Writer) {
  	fmt.Fprint(out, "3")
  }
  ```

- Now we have completed step 1. We print 3 to stdout in main and print it to a
  buffer for testing. It seems trivial, but this is the approach the book author
  recommends. **Take a thin slice of functionality and make it work end-to-end,
  backed by tests.**
- Now let's make it print 2, 1, and then "Go!". First update the test. Note you
  can declare a *raw string literal* surrounded by backticks
  (`` `string` ``), which can include things like newlines:

  ```go
  // 10-mocking/countdown_test.go
  	got := buffer.String()
  	want := `3
  2
  1
  Go!`

  // And update the code to print the new output
  // 10-mocking/main.go
  func Countdown(out io.Writer) {
  	for i := 3; i > 0; i-- {
  		fmt.Fprintln(out, i)
  	}
  	fmt.Fprint(out, "Go!")
  }
  ```

- After pulling out some constants and adding the pause, here is our final code:

  ```go
  // 10-mocking/main.go
  package main

  import (
  	"fmt"
  	"io"
  	"os"
  	"time"
  )

  const finalWord = "Go!"
  const countdownStart = 3

  func main() {
  	Countdown(os.Stdout)
  }

  func Countdown(out io.Writer) {
  	for i := countdownStart; i > 0; i-- {
  		fmt.Fprintln(out, i)
  		time.Sleep(1 * time.Second)
  	}
  	fmt.Fprint(out, finalWord)
  }
  ```

- This works well, with a few problems. Now our test takes 3 seconds to run.
  Slow tests ruin developer productivity. What if we had to add functionality
  and wait for these tests with every change? We also haven't tested our pause,
  which is an important part of the application requirements. So we need to
  extract our dependency on `Sleep`ing. If we *mock* `time.Sleep`, we can use
  *dependency injection* to use it instead of a "real" `time.Sleep`, and then we
  can **spy on the calls** to make assertions on them. We will start with the
  tests:

  ```go
  // 10-mocking/countdown_test.go
  package main

  import (
  	"bytes"
  	"testing"
  )

  func TestCountdown(t *testing.T) {
  	buffer := &bytes.Buffer{}
  	spySleeper := &SpySleeper{}

  	Countdown(buffer, spySleeper)

  	got := buffer.String()
  	want := `3
  2
  1
  Go!`

  	if got != want {
  		t.Errorf("got %q want %q", got, want)
  	}

  	if spySleeper.Calls != 3 {
  		t.Errorf("not enough calls to sleeper, want 3 got %d", spySleeper.Calls)
  	}
  }

  type SpySleeper struct {
  	Calls int
  }

  func (s *SpySleeper) Sleep() {
  	s.Calls++
  }

  // and after we get our compiler errors, we fix our main.go
  // 10-mocking/main.go
  package main

  import (
  	"fmt"
  	"io"
  	"os"
  	"time"
  )

  const finalWord = "Go!"
  const countdownStart = 3

  type Sleeper interface {
  	Sleep()
  }

  type DefaultSleeper struct{}

  func (d *DefaultSleeper) Sleep() {
  	time.Sleep(1 * time.Second)
  }

  func main() {
  	sleeper := &DefaultSleeper{}
  	Countdown(os.Stdout, sleeper)
  }

  func Countdown(out io.Writer, sleeper Sleeper) {
  	for i := countdownStart; i > 0; i-- {
  		fmt.Fprintln(out, i)
  		sleeper.Sleep()
  	}
  	fmt.Fprint(out, finalWord)
  }
  ```

- *Spies* are a kind of *mock* that can record how a dependency is used. They can
  record the arguments sent in, how many times it has been called, etc. In our
  case, we're keeping track of how many times `Sleep()` is called so we can check
  it in our test.
- So our latest test is a marked improvement. It no longer takes 3 seconds to run
  and it verified `Sleep` was called 3 times. But there's another important
  property we haven't tested. We are supposed to go Print, Sleep, Print, Sleep,
  etc. For all we know, it might be sleeping 3 seconds then printing everything
  at once. When writing tests, if you're not confident that your tests are
  testing everything, just break it! (after committing your work to source
  control, of course). If we change it to sleep 3 seconds and print everything
  at once, we will see our tests still pass. We will use spying again with a new
  test to check this. We have two different dependencies and we want to record
  all of their operations into one list, so we'll create one spy for them both.
  Our spy needs to implement both the `Sleeper` and `io.Writer` interfaces. For
  this test, we're only concerned about the order of operations, so just
  recording them as a list of named operations is sufficient.

  ```go
  // 10-mocking/countdown_test.go
  package main

  import (
  	"bytes"
  	"reflect"
  	"testing"
  )

  func TestCountdown(t *testing.T) {
  	t.Run("prints 3 to Go!", func(t *testing.T) {
  		buffer := &bytes.Buffer{}
  		Countdown(buffer, &SpyCountdownOperations{})

  		got := buffer.String()
  		want := `3
  2
  1
  Go!`

  		if got != want {
  			t.Errorf("got %q want %q", got, want)
  		}

  	})

  	t.Run("sleep before every print", func(t *testing.T) {
  		spySleepPrinter := &SpyCountdownOperations{}
  		Countdown(spySleepPrinter, spySleepPrinter)

  		want := []string{
  			write,
  			sleep,
  			write,
  			sleep,
  			write,
  			sleep,
  			write,
  		}

  		if !reflect.DeepEqual(want, spySleepPrinter.Calls) {
  			t.Errorf("wanted calls %v got %v", want, spySleepPrinter.Calls)
  		}
  	})
  }

  type SpyCountdownOperations struct {
  	Calls []string
  }

  func (s *SpyCountdownOperations) Sleep() {
  	s.Calls = append(s.Calls, sleep)
  }

  func (s *SpyCountdownOperations) Write(p []byte) (n int, err error) {
  	s.Calls = append(s.Calls, write)
  	return
  }

  const sleep = "sleep"
  const write = "write"
  ```

- Our new test fails if we sleep 3 seconds and rush to print, and succeeds when
  we revert `Countdown` back to the way it is supposed to work. It would be nice
  for our `Sleeper` to be configurable in case requirements change. We're going
  to give the `sleep` field the same function type as `time.Sleep`,
  `func(time.Duration)`, so we can easily assign it.

  ```go
  // 10-mocking/main.go
  type ConfigurableSleeper struct {
  	duration time.Duration
  	sleep    func(time.Duration)
  }

  func (c *ConfigurableSleeper) Sleep() {
  	c.sleep(c.duration)
  }

  func main() {
  	sleeper := &ConfigurableSleeper{1 * time.Second, time.Sleep}
  	Countdown(os.Stdout, sleeper)
  }

  // 10-mocking/countdown_test.go
  func TestConfigurableSleeper(t *testing.T) {
  	sleepTime := 5 * time.Second

  	spyTime := &SpyTime{}
  	sleeper := ConfigurableSleeper{sleepTime, spyTime.SetDurationSlept}
  	sleeper.Sleep()

  	if spyTime.durationSlept != sleepTime {
  		t.Errorf("should have slept for %v but slept for %v", sleepTime, spyTime.durationSlept)
  	}
  }

  type SpyTime struct {
  	durationSlept time.Duration
  }

  func (s *SpyTime) SetDurationSlept(duration time.Duration) {
  	s.durationSlept = duration
  }
  ```

- When we get this done, we can delete the `DefaultSleeper` implementation.
- Some people consider mocking evil. This is because people normally get into a
  bad state when they don't *listen to their tests* and are *not respecting the
  refactoring stage*. If your mocking code is becoming complicated or you are
  having to mock out lots of things to test something, you should *listen* to that
  bad feeling and think about your code. It is usually a sign of:
  - The thing you are testing is having to do too many things because it has too
    many dependencies to mock
    - Break the module apart so it does less
  - Its dependencies are too fine-grained
    - Think about how you can consolidate some of these dependencies into one
      meaningful module
  - Your test is too concerned with implementation details
    - Favour testing expected behaviour rather than the implementation
- Normally a lot of mocking points to *bad abstraction* in your code. Well-designed
  code is easy to test.
- If you make changes and break lots of tests, this usually is a sign that you are
  testing too much *implementation detail*. Try to make it so your tests are
  testing *useful behaviour* unless the implementation is really important to how
  the system runs.
- It is sometimes hard to know *what level* to test exactly but here are some
  thought processes and rules the author follows:
  - **The definition of refactoring is that the code changes but the behaviour
    stays the same.** If you have decided to do some refactoring, in theory you
    should be able to make the commit without any test changes. So when writing
    a test, ask yourself:
    - Am I testing the behaviour I want, or the implementation details?
    - If I were to refactor this code, would I have to make lots of changes to the
      tests?
  - Although Go lets you test private functions, I would avoid it, as private
    functions are implementation detail to support public behaviour. Test the
    public behaviour. Sandi Metz describes private functions as being "less
    stable" and you don't want to couple your tests to them.
  - I feel like if a test is working with **more than 3 mocks then it is a red
    flag** - time for a rethink on the design
  - Use spies with caution. Spies let you see the insides of the algorithms you
    are writing, which can be very useful, but that means a tighter coupling
    between your test code and the implementation. **Be sure you actually care
    about these details if you're going to spy on them.**

- Final code

  ```go
  // 10-mocking/countdown_test.go
  package main

  import (
  	"bytes"
  	"reflect"
  	"testing"
  	"time"
  )

  func TestCountdown(t *testing.T) {
  	t.Run("prints 3 to Go!", func(t *testing.T) {
  		buffer := &bytes.Buffer{}
  		Countdown(buffer, &SpyCountdownOperations{})

  		got := buffer.String()
  		want := `3
  2
  1
  Go!`

  		if got != want {
  			t.Errorf("got %q want %q", got, want)
  		}

  	})

  	t.Run("sleep before every print", func(t *testing.T) {
  		spySleepPrinter := &SpyCountdownOperations{}
  		Countdown(spySleepPrinter, spySleepPrinter)

  		want := []string{
  			write,
  			sleep,
  			write,
  			sleep,
  			write,
  			sleep,
  			write,
  		}

  		if !reflect.DeepEqual(want, spySleepPrinter.Calls) {
  			t.Errorf("wanted calls %v got %v", want, spySleepPrinter.Calls)
  		}
  	})
  }

  func TestConfigurableSleeper(t *testing.T) {
  	sleepTime := 5 * time.Second

  	spyTime := &SpyTime{}
  	sleeper := ConfigurableSleeper{sleepTime, spyTime.SetDurationSlept}
  	sleeper.Sleep()

  	if spyTime.durationSlept != sleepTime {
  		t.Errorf("should have slept for %v but slept for %v", sleepTime, spyTime.durationSlept)
  	}
  }

  type SpyCountdownOperations struct {
  	Calls []string
  }

  func (s *SpyCountdownOperations) Sleep() {
  	s.Calls = append(s.Calls, sleep)
  }

  func (s *SpyCountdownOperations) Write(p []byte) (n int, err error) {
  	s.Calls = append(s.Calls, write)
  	return
  }

  const sleep = "sleep"
  const write = "write"

  type SpyTime struct {
  	durationSlept time.Duration
  }

  func (s *SpyTime) SetDurationSlept(duration time.Duration) {
  	s.durationSlept = duration
  }

  // 10-mocking/main.go
  package main

  import (
  	"fmt"
  	"io"
  	"os"
  	"time"
  )

  const finalWord = "Go!"
  const countdownStart = 3

  // Sleeper allows you to put delays.
  type Sleeper interface {
  	Sleep()
  }

  // ConfigurableSleeper is an implementation of Sleeper with a defined delay.
  type ConfigurableSleeper struct {
  	duration time.Duration
  	sleep    func(time.Duration)
  }

  // Sleep will pause execution for the defined Duration.
  func (c *ConfigurableSleeper) Sleep() {
  	c.sleep(c.duration)
  }

  func main() {
  	sleeper := &ConfigurableSleeper{1 * time.Second, time.Sleep}
  	Countdown(os.Stdout, sleeper)
  }

  // Countdown prints a countdown from 3 to out with a delay between count
  // provided by Sleeper.
  func Countdown(out io.Writer, sleeper Sleeper) {
  	for i := countdownStart; i > 0; i-- {
  		fmt.Fprintln(out, i)
  		sleeper.Sleep()
  	}
  	fmt.Fprint(out, finalWord)
  }
  ```

- Wrapping up
  - More on TDD approach
    - When faced with less trivial examples, break the problem down into "thin
      vertical slices". Try to get to a point where you have *working software
      backed by tests* as soon as you can, to avoid getting in rabbit holes and
      taking a "big bang" approach.
    - Once you have some working software it should be easier to *iterate with
      small steps* until you arrive at the software you need.
    - "When to use iterative development? You should use iterative development
      only on projects that you want to succeed." --Martin Fowler
  - Mocking
    - **Without mocking important areas of your code will be untested.** In our
      case we would not be able to test that our code paused between each print,
      but there are countless other examples. Calling a service that *can* fail?
      Wanting to test your system in a particular state? It is very hard to test
      these scenarios without mocking.
    - Without mocks you may have to set up databases and other third party things
      just to test simple business rules. You're likely to have slow tests,
      resulting in **slow feedback loops**.
    - By having to spin up a database or a webservice to test something you're
      likely to have **fragile tests** due to the unreliability of such services.
  - Once a developer learns about mocking it becomes very easy to over-test every
    single facet of a system in terms of the *way it works* rather than *what it
    does*. Always be mindful about **the value of your tests** and what impact
    they would have in future refactoring.
  - We have only covered **Spies**, which are a type of *test double*. Test
    double is a generic term for any case where you replace a production object
    for testing purposes. Under test doubles, there are various types like
    stubs, spies, and indeed mocks!

## Chapter 11 - Concurrency

- To tell Go to start a new goroutine we turn a function call into a `go`
  statement by putting the keyword `go` in front of it: `go doSomething()`.
  Because the only way to start a goroutine is to put `go` in front of a function
  call, we often use *anonymous functions* when we want to start a goroutine.
  An anonymous function literal looks just the same as a normal function
  declaration, but without a name. An anonymous function can be called when
  declared by putting `()` at it's closing brace. They maintain the lexical scope
  in which they are defined - all the variables that are available at the point
  when you declare the anonymous function are also available in the body of the
  function.

  ```go
  // 11-concurrency/check_websites.go
  package concurrency

  type WebsiteChecker func(string) bool

  func CheckWebsites(wc WebsiteChecker, urls []string) map[string]bool {
  	results := make(map[string]bool)

  	for _, url := range urls {
  		go func() {
  			results[url] = wc(url)
  		}()
  	}
  
  	return results
  }

  // 11-concurrency/check_websites_test.go
  package concurrency

  import (
  	"reflect"
  	"testing"
  )

  func mockWebsiteChecker(url string) bool {
  	return url != "waat://furhurterwe.geds"
  }

  func TestCheckWebsites(t *testing.T) {
  	websites := []string{
  		"http://google.com",
  		"http://blog.gypsydave5.com",
  		"waat://furhurterwe.geds",
  	}

  	want := map[string]bool{
  		"http://google.com":          true,
  		"http://blog.gypsydave5.com": true,
  		"waat://furhurterwe.geds":    false,
  	}

  	got := CheckWebsites(mockWebsiteChecker, websites)

  	if !reflect.DeepEqual(want, got) {
  		t.Fatalf("wanted %v, got %v", want, got)
  	}
  }

  // 11-concurrency/check_websites_benchmark_test.go
  package concurrency

  import (
  	"testing"
  	"time"
  )

  func slowStubWebsiteChecker(_ string) bool {
  	time.Sleep(20 * time.Millisecond)
  	return true
  }

  func BenchmarkCheckWebsites(b *testing.B) {
  	urls := make([]string, 100)
  	for i := 0; i < len(urls); i++ {
  		urls[i] = "a url"
  	}

  	for b.Loop() {
  		CheckWebsites(slowStubWebsiteChecker, urls)
  	}
  }
  ```

- Go maps are not safe for concurrent writes, so sometimes our tests crash and our   benchmark always crashes. This is a *data race*. You can use Go's race detector
  by running `go test -race`. We can solve this by coordinating using channels.
- *Channels* are a Go data structures that can both receive and send values. They
  allow communication between different processes. In this case, we want to
  communicae between the parent process and each of the goroutines that it makes
  to do the work of running the `WebsiteChecker` function with the url.
- Note if your project `go.mod` declares a go version *older* than 1.22, you will
  need to explicitly pass `url string` into your anoanymous func and call it with
  `(url)` instead of `()`.
- We made the fields of our `result` struct anonymous in the fixed code below.

  ```go
  // 11-concurrency/check_websites.go
  package concurrency

  type WebsiteChecker func(string) bool
  type result struct {
  	string
  	bool
  }

  func CheckWebsites(wc WebsiteChecker, urls []string) map[string]bool {
  	results := make(map[string]bool)
  	resultChannel := make(chan result)

  	for _, url := range urls {
  		go func() {
  			resultChannel <- result{url, wc(url)}
  		}()
  	}

  	for i := 0; i < len(urls); i++ {
  		r := <-resultChannel
  		results[r.string] = r.bool
  	}

  	return results
  }
  ```

- Instead of writing the results directly into the map, we are using a *send
  statement* to send a `result` struct for each call to `wc` on the
  `resultChannel`.

  ```go
  // Send statement
  resultChannel <- result{url, wc(url)}
  ```

- This uses the `<-` operator, taking a channel on the left and a value on the
  right. The next `for` loop iterates once for each of the urls. Inside we're
  using a *receive expression*, which assigns a value received from a channel
  to a variable, which then use to update our inital map. This also uses the 
  `<-` operator, but
  with the two operands reversed: the channel is now on the right and the variable
  we are assigning to is on the left:

  ```go
  // Receive expression
  r := <-resultChannel
  ```

- By using the channel we can control the timing of each write into the `results`
  map, ensuring that it happens one at a time.
- Wrapping up
  - We have done one large refactor of the `CheckWebsites` function; the inputs
    and outputs never changed; it just got faster. The tests we had in place
    allowed us to maintain confidence the software was still working and the
    benchmark displayed it had gotten about 100x faster.
  - In making it faster we learned about
    - *goroutines*, the basic unit of concurrency in Go, which let us manage more
      than one website check request.
    - *anonymous functions*, which we used to start each of the concurrent
      processes that check websites.
    - *channels*, to help organize and control the communication between the
      different processes, allowing us to avoid a *race condition* bug.
    - *the race detector* which helped us debug problems with concurrent code
  - Make it work, make it right, make it fast
    - Where 'work' is making the tests pass, 'right' is refactoring the code, and
      'fast' is optimizing the code to make it run quickly. We can only 'make it
      fast' once we've made it work and made it right. We should never try to 'make
      it fast' before the other two steps have been performed.

## Chapter 12 - Select

- We have been asked to make a function called `WebsiteRacer` which takes two URLs
  and "races" them by hitting them with an HTTP GET request and returning the URL
  which returned first. If none of them return within 10 seconds then it should
  return an `error`. For this we will be using:
  - `net/http` to make the HTTP calls.
  - `net/http/httptest` to help us test them.
  - goroutines
  - `select` to synchornize processes.
