package cmd

import (
	"pragprog.com/rggo/ch9/interactiveTools/pomo/pomodoro"
	"pragprog.com/rggo/ch9/interactiveTools/pomo/pomodoro/repository"
)

func getRepo() (pomodoro.Repository, error) {
	return repository.NewInMemoryRepo(), nil
}
