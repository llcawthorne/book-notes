package clockface

import (
	"math"
	"testing"
	"time"
)

func TestSecondHandPoint(t *testing.T) {
	cases := []struct {
		time  time.Time
		point Point
	}{
		{simpleTime(0, 0, 30), Point{0, -1}},
		{simpleTime(0, 0, 45), Point{-1, 0}},
	}

	for _, tt := range cases {
		t.Run(testName(tt.time), func(t *testing.T) {
			got := secondHandPoint(tt.time)
			if !roughlyEqualPoint(got, tt.point) {
				t.Fatalf("Wanted %v Point, but got %v", tt.point, got)
			}
		})
	}
}

func TestSecondsInRadians(t *testing.T) {
	cases := []struct {
		time  time.Time
		angle float64
	}{
		{simpleTime(0, 0, 30), math.Pi},
		{simpleTime(0, 0, 0), 0},
		{simpleTime(0, 0, 45), (math.Pi / 2) * 3},
		{simpleTime(0, 0, 7), (math.Pi / 30) * 7},
	}

	for _, tt := range cases {
		t.Run(testName(tt.time), func(t *testing.T) {
			got := secondsInRadians(tt.time)
			if !roughlyEqualFloat64(got, tt.angle) {
				t.Fatalf("Wanted %v radians, but got %v", tt.angle, got)
			}
		})
	}
}

func TestMinuteHandPoint(t *testing.T) {
	cases := []struct {
		time  time.Time
		point Point
	}{
		{simpleTime(0, 30, 0), Point{0, -1}},
		{simpleTime(0, 45, 0), Point{-1, 0}},
	}

	for _, tt := range cases {
		t.Run(testName(tt.time), func(t *testing.T) {
			got := minuteHandPoint(tt.time)
			if !roughlyEqualPoint(got, tt.point) {
				t.Fatalf("Wanted %v Point, but got %v", tt.point, got)
			}
		})
	}
}

func TestMinutesInRadians(t *testing.T) {
	cases := []struct {
		time  time.Time
		angle float64
	}{
		{simpleTime(0, 30, 0), math.Pi},
		{simpleTime(0, 0, 7), 7 * (math.Pi / (30 * 60))},
	}

	for _, tt := range cases {
		t.Run(testName(tt.time), func(t *testing.T) {
			got := minutesInRadians(tt.time)
			if !roughlyEqualFloat64(got, tt.angle) {
				t.Fatalf("Wanted %v radians, but got %v", tt.angle, got)
			}
		})
	}
}

func TestHourHandPoint(t *testing.T) {
	cases := []struct {
		time  time.Time
		point Point
	}{
		{simpleTime(6, 0, 0), Point{0, -1}},
		{simpleTime(21, 0, 0), Point{-1, 0}},
	}

	for _, tt := range cases {
		t.Run(testName(tt.time), func(t *testing.T) {
			got := hourHandPoint(tt.time)
			if !roughlyEqualPoint(got, tt.point) {
				t.Fatalf("Wanted %v Point, but got %v", tt.point, got)
			}
		})
	}
}

func TestHoursInRadians(t *testing.T) {
	cases := []struct {
		time  time.Time
		angle float64
	}{
		{simpleTime(0, 0, 0), 0},
		{simpleTime(6, 0, 0), math.Pi},
		{simpleTime(21, 0, 0), math.Pi * 1.5},
		{simpleTime(0, 1, 30), math.Pi / ((6 * 60 * 60) / 90)},
	}

	for _, tt := range cases {
		t.Run(testName(tt.time), func(t *testing.T) {
			got := hoursInRadians(tt.time)
			if !roughlyEqualFloat64(got, tt.angle) {
				t.Fatalf("Wanted %v radians, but got %v", tt.angle, got)
			}
		})
	}
}

func roughlyEqualFloat64(a, b float64) bool {
	const equalityThreshold = 1e-7
	return math.Abs(a-b) < equalityThreshold
}

func roughlyEqualPoint(a, b Point) bool {
	return roughlyEqualFloat64(a.X, b.X) &&
		roughlyEqualFloat64(a.Y, b.Y)
}

func simpleTime(hours, minutes, seconds int) time.Time {
	return time.Date(312, time.October, 28, hours, minutes, seconds, 0, time.UTC)
}

func testName(t time.Time) string {
	return t.Format("15:04:05")
}
