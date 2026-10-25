package sync

import "sync/atomic"

// Counter will increment a number.
type Counter struct {
	value atomic.Int64
}

// NewCounter returns a new Counter.
func NewCounter() *Counter {
	return &Counter{}
}

// Inc the count.
func (c *Counter) Inc() {
	c.value.Add(1)
}

// Value returns the current count.
func (c *Counter) Value() int {
	return int(c.value.Load())
}
