package blogrenderer

import (
	"embed"
	"html/template"
	"io"
	"strings"

	"github.com/gomarkdown/markdown"
	"github.com/gomarkdown/markdown/parser"
)

var (
	//go:embed "templates/*"
	postTemplates embed.FS
)

// Post is a representation of a post.
type Post struct {
	Title, Description, Body string
	Tags                     []string
}

// SanitizedTitle returns the title of the post with spaces replaced by dashes
// for pleasant URLs.
func (p Post) SanitizedTitle() string {
	return strings.ToLower(strings.ReplaceAll(p.Title, " ", "-"))
}

// PostRenderer renders data into HTML.
type PostRenderer struct {
	templ *template.Template
}

// NewPostRenderer creates a new PostRenderer.
func NewPostRenderer() (*PostRenderer, error) {
	templ, err := template.ParseFS(postTemplates, "templates/*.gohtml")
	if err != nil {
		return nil, err
	}
	return &PostRenderer{templ: templ}, nil
}

// Render renders post into HTML.
func (r *PostRenderer) Render(w io.Writer, p Post) error {
	return r.templ.ExecuteTemplate(w, "blog.gohtml", newPostVM(p))
}

// RenderIndex creates an HTML index page given a collection of posts.
func (r *PostRenderer) RenderIndex(w io.Writer, posts []Post) error {
	return r.templ.ExecuteTemplate(w, "index.gohtml", posts)
}

type postViewModel struct {
	Post
	HTMLBody template.HTML
}

// newPostVM converts the post's markdown Body to HTML. gomarkdown parsers keep
// internal state and panic if reused, so each call makes a fresh one.
func newPostVM(p Post) postViewModel {
	vm := postViewModel{Post: p}
	extensions := parser.CommonExtensions | parser.AutoHeadingIDs
	mdParser := parser.NewWithExtensions(extensions)
	vm.HTMLBody = template.HTML(markdown.ToHTML([]byte(p.Body), mdParser, nil))
	return vm
}
