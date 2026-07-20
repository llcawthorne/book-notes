package main

import (
	"log"
	"os"
	"text/template"
)

type Part struct {
	Name  string
	Count int
}

type Subscriber struct {
	Name   string
	Rate   float64
	Active bool
}

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func executeTemplate(text string, data interface{}) {
	tmpl, err := template.New("test").Parse(text)
	check(err)
	err = tmpl.Execute(os.Stdout, data)
	check(err)
}

func main() {
	// static text
	text := "Here's my template!\n"
	// Parse parses a string where ParseFile would parse a file
	tmpl, err := template.New("test").Parse(text)
	check(err)
	err = tmpl.Execute(os.Stdout, nil)
	check(err)

	// simple template with data, used several times
	templateText := "Template start\nAction: {{.}}\nTemplate end\n"
	tmpl, err = template.New("test").Parse(templateText)
	check(err)
	err = tmpl.Execute(os.Stdout, "ABC")
	check(err)
	err = tmpl.Execute(os.Stdout, "42")
	check(err)
	err = tmpl.Execute(os.Stdout, "true")
	check(err)

	// now with helper to define and execute for one time use
	executeTemplate("Dot is: {{.}}!\n", "ABC")
	executeTemplate("Dot is: {{.}}!\n", 123.5)
	// testing a conditional
	executeTemplate("start {{if .}}Dot is true!{{end}} finish\n", true)
	executeTemplate("start {{if .}}Dot is true!{{end}} finish\n", false)
	// and loops
	loopTemplateText := "Before loop: {{.}}\n{{range .}}In loop: {{.}}\n{{end}}After loop: {{.}}\n"
	executeTemplate(loopTemplateText, []string{"do", "re", "mi"})
	executeTemplate(loopTemplateText, []float64{1.25, 0.99, 27})
	executeTemplate(loopTemplateText, nil) // loop is skipped with false-y value
	// templates with structs
	structTemplateText := "Name: {{.Name}}\nCount: {{.Count}}\n"
	executeTemplate(structTemplateText, Part{Name: "Fuses", Count: 5})
	executeTemplate(structTemplateText, Part{Name: "Cables", Count: 2})
	subscriberTemplate := "Name: {{.Name}}\n{{if .Active}}Rate: ${{.Rate}}\n{{end}}"
	subscriber := Subscriber{Name: "Aman Singh", Rate: 4.99, Active: true}
	executeTemplate(subscriberTemplate, subscriber)
	subscriber = Subscriber{Name: "Joy Carr", Rate: 5.99, Active: false}
	executeTemplate(subscriberTemplate, subscriber)
}
