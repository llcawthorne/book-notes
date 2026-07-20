//go:build !containers && !disable_notificaiton
// +build !containers,!disable_notificaiton

package app

import "pragprog.com/rggo/ch11/distributing/notify"

func send_notification(msg string) {
	n := notify.New("Pomodoro", msg, notify.SeverityNormal)

	n.Send()
}
