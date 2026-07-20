//go:build inmemory
// +build inmemory

package cmd

import (
	"pragprog.com/rggo/ch10/persistentDataSQL/pomo/pomodoro"
	"pragprog.com/rggo/ch10/persistentDataSQL/pomo/pomodoro/repository"
)

func getRepo() (pomodoro.Repository, error) {
	return repository.NewInMemoryRepo(), nil
}
