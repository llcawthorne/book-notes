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
