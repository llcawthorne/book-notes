package main

import (
	"bytes"     // to manipulate raw byte data
	"io/ioutil" // to read data from files - deprecated
	"os"        // to delete files

	"strings" // to TrimSpace our mockStdOut
	"testing" // used by all Go tests
)

// We are using the "golden files" approach where the expected results are
// saved into files that are loading during the tests to validate output.
// `testdata` is a special directory that is ignored by go build tools.
const (
	inputFile      = "./testdata/test1.md"
	goldenFile     = "./testdata/test1.md.html"
	templateFile   = "./template-fmt.html.tmpl"
	templateOutput = "./testdata/test1-template.md.html"
)

func TestParseContent(t *testing.T) {
	input, err := ioutil.ReadFile(inputFile)
	if err != nil {
		t.Fatal(err)
	}

	result, err := parseContent(input, "")
	if err != nil {
		t.Fatal(err)
	}

	expected, err := ioutil.ReadFile(goldenFile)
	if err != nil {
		t.Fatal(err)
	}

	if !bytes.Equal(expected, result) {
		t.Logf("golden:\n%s\n", expected)
		t.Logf("result:\n%s\n", result)
		t.Error("Result content does not match golden file")
	}
}

func TestRun(t *testing.T) {
	var mockStdOut bytes.Buffer

	if err := run(inputFile, "", &mockStdOut, true); err != nil {
		t.Fatal(err)
	}

	resultFile := strings.TrimSpace(mockStdOut.String())

	result, err := ioutil.ReadFile(resultFile)
	if err != nil {
		t.Fatal(err)
	}

	expected, err := ioutil.ReadFile(goldenFile)
	if err != nil {
		t.Fatal(err)
	}

	if !bytes.Equal(expected, result) {
		t.Logf("golden:|n%s|n", expected)
		t.Logf("result:|n%s|n", result)
		t.Error("Result content does not match golden file")
	}

	os.Remove(resultFile)
}

func TestRunWithTemplate(t *testing.T) {
	var mockStdOut bytes.Buffer

	if err := run(inputFile, templateFile, &mockStdOut, true); err != nil {
		t.Fatal(err)
	}

	resultFile := strings.TrimSpace(mockStdOut.String())

	result, err := ioutil.ReadFile(resultFile)
	if err != nil {
		t.Fatal(err)
	}

	expected, err := ioutil.ReadFile(templateOutput)
	if err != nil {
		t.Fatal(err)
	}

	if !bytes.Equal(expected, result) {
		t.Logf("golden:|n%s|n", expected)
		t.Logf("result:|n%s|n", result)
		t.Error("Result content does not match golden file")
	}

	os.Remove(resultFile)
}
