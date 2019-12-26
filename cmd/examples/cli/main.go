// A test program for the cli package.
package main

import (
	"fmt"
	"io"
	"unicode"

	"github.com/elves/elvish/pkg/cli"
	"github.com/elves/elvish/pkg/cli/el"
	"github.com/elves/elvish/pkg/cli/term"
	"github.com/elves/elvish/pkg/ui"
)

type highlighter struct{}

func (highlighter) Get(code string) (ui.Text, []error) {
	t := ui.Text{}
	for _, r := range code {
		var style ui.Styling
		if unicode.IsDigit(r) {
			style = ui.FgGreen
		}
		t = append(t, ui.T(string(r), style)...)
	}
	return t, nil
}

func (highlighter) LateUpdates() <-chan struct{} { return nil }

func main() {
	var app cli.App
	app = cli.NewApp(cli.AppSpec{
		Prompt:      cli.NewConstPrompt(ui.T("> ")),
		Highlighter: highlighter{},
		OverlayHandler: el.MapHandler{
			term.K('D', ui.Ctrl): func() { app.CommitEOF() },
		},
	})

	for {
		code, err := app.ReadCode()
		if err != nil {
			if err != io.EOF {
				fmt.Println("error:", err)
			}
			break
		}
		fmt.Println("got:", code)
	}
}
