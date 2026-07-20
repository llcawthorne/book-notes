package pomodoro_test

import (
	"testing"

	"pragprog.com/rggo/ch9/interactiveTools/pomo/pomodoro"
	"pragprog.com/rggo/ch9/interactiveTools/pomo/pomodoro/repository"
)

// Returns an in memory Repository and a cleanup function
// This requires no cleanup, so cleanup func is empty
func getRepo(t *testing.T) (pomodoro.Repository, func()) {
	t.Helper()

	return repository.NewInMemoryRepo(), func() {}
}
