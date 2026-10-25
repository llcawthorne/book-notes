# Go Snippets

My LuaSnip snippets for Go, defined in `~/.config/nvim/snippets/go.lua` (in
dotfiles) and loaded by one `from_lua` loader line in `init.lua`. Add
`snippets/rust.lua` etc. the same way for other languages.

- Type the trigger in a `.go` file; it shows in the completion menu as a
  snippet. Accept with `Tab` (blink.cmp super-tab preset).
- `Tab` / `Shift-Tab` jump between placeholders. Typing in a placeholder that
  appears twice (like the format verb) updates both.
- `goimports` on save fixes any indentation or missing imports afterwards.

| Trigger   | Expands to                                          |
| --------- | --------------------------------------------------- |
| `gw`      | `if got != want` check with `t.Errorf`              |
| `iferr`   | `if err != nil` with `return err` selected          |
| `trun`    | `t.Run` subtest                                     |
| `tfunc`   | `func TestXxx(t *testing.T)`                        |
| `ttable`  | Table-driven test: cases slice plus `t.Run` loop    |
| `thelper` | Assertion helper with `t.Helper()`                  |

## Expansions

`gw` (placeholder: `%v`, mirrored into both verbs):

```go
if got != want {
	t.Errorf("got %v, want %v", got, want)
}
```

`iferr` (placeholder: `return err`):

```go
if err != nil {
	return err
}
```

`trun` (placeholders: name, then body):

```go
t.Run("", func(t *testing.T) {

})
```

`tfunc` (placeholders: name after `Test`, then body):

```go
func Test(t *testing.T) {

}
```

`ttable` (placeholders: extra fields, first case name, loop body):

```go
cases := []struct {
	name string
	want string
}{
	{name: ""},
}

for _, tt := range cases {
	t.Run(tt.name, func(t *testing.T) {

	})
}
```

`thelper` (placeholders: name suffix, type, verb mirrored into both):

```go
func assertEqual(t testing.TB, got, want string) {
	t.Helper()
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}
```
