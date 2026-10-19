package vm

import (
	"monkey/code"
	"monkey/object"
)

/*
fn -> 已編譯函數
ip -> 該幀的指令指針
*/
type Frame struct {
	fn          *object.CompiledFunction
	ip          int
	basePointer int
}

func NewFrame(fn *object.CompiledFunction, basePointer int) *Frame {
	return &Frame{fn: fn, ip: -1, basePointer: basePointer}
}

func (f *Frame) Instructions() code.Instructions {
	return f.fn.Instructions
}
