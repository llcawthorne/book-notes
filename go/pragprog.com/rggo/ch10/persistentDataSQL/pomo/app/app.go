package app

import (
	"context"
	"image"
	"time"

	"github.com/mum4k/termdash"
	"github.com/mum4k/termdash/terminal/tcell"
	"github.com/mum4k/termdash/terminal/terminalapi"
	"pragprog.com/rggo/ch10/persistentDataSQL/pomo/pomodoro"
)

type App struct {
	ctx        context.Context
	controller *termdash.Controller
	redrawCh   chan bool
	errorCh    chan error
	term       *tcell.Terminal
	size       image.Point
}

func New(config *pomodoro.IntervalConfig) (*App, error) {
	// A cancellation context to close all widgets when app closes
	ctx, cancel := context.WithCancel(context.Background())

	// Q/q to Quit using the cancel from our Context
	quitter := func(k *terminalapi.Keyboard) {
		if k.Key == 'q' || k.Key == 'Q' {
			cancel()
		}
	}

	redrawCh := make(chan bool)
	errorCh := make(chan error)

	w, err := newWidgets(ctx, errorCh)
	if err != nil {
		return nil, err
	}

	s, err := newSummary(ctx, config, redrawCh, errorCh)
	if err != nil {
		return nil, err
	}

	b, err := newButtonSet(ctx, config, w, s, redrawCh, errorCh)
	if err != nil {
		return nil, err
	}

	term, err := tcell.New()
	if err != nil {
		return nil, err
	}

	c, err := newGrid(b, w, s, term)
	if err != nil {
		return nil, err
	}

	// the termdash.Controller gives us manual control over the application
	controller, err := termdash.NewController(term, c,
		termdash.KeyboardSubscriber(quitter))
	if err != nil {
		return nil, err
	}

	return &App{
		ctx:        ctx,
		controller: controller,
		redrawCh:   redrawCh,
		errorCh:    errorCh,
		term:       term,
	}, nil
}

func (a *App) resize() error {
	if a.size.Eq(a.term.Size()) {
		return nil
	}

	a.size = a.term.Size()
	if err := a.term.Clear(); err != nil {
		return err
	}

	return a.controller.Redraw()
}

func (a *App) Run() error {
	defer a.term.Close()
	defer a.controller.Close()

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		// four channels to monitor, either we get a redraw and redraw, we get
		// an error and return the err exiting the App, our context is cancelled
		// by press Q, so we close without err, or our ticket goes off so we
		// check if we need to resize and redraw
		select {
		case <-a.redrawCh:
			if err := a.controller.Redraw(); err != nil {
				return err
			}
		case err := <-a.errorCh:
			if err != nil {
				return err
			}
		case <-a.ctx.Done():
			return nil
		case <-ticker.C:
			if err := a.resize(); err != nil {
				return err
			}
		}
	}
}
