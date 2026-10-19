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
	//fn          *object.CompiledFunction
	cl          *object.Closure
	ip          int
	basePointer int
}

func NewFrame(cl *object.Closure, basePointer int) *Frame {
	return &Frame{cl: cl, ip: -1, basePointer: basePointer}
}

func (f *Frame) Instructions() code.Instructions {
	return f.cl.Fn.Instructions
}
