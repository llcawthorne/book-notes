package vm

import (
	"fmt"
	"monkey/code"
	"monkey/compiler"
	"monkey/object"
)

const StackSize = 2048
const GlobalSize = 65536 //2 byte = 16 bit = 2^16 = 65535

var True = &object.Boolean{Value: true}
var False = &object.Boolean{Value: false}
var Null = &object.Null{}

type VM struct {
	constants []object.Object
	//instructions code.Instructions
	stack   []object.Object
	sp      int //始終指向stack下一個空閒的巢位, stack top value 是stack[sp-1]
	globals []object.Object

	//虛擬機中的frame
	frames      []*Frame
	framesIndex int
}

func (vm *VM) currentFrame() *Frame {
	return vm.frames[vm.framesIndex-1]
}

// 最後一個加入 frame
func (vm *VM) pushFrame(f *Frame) {
	vm.frames[vm.framesIndex] = f
	vm.framesIndex++
}

// 最後一個退出
func (vm *VM) popFrame() *Frame {
	vm.framesIndex--
	return vm.frames[vm.framesIndex]
}

// 不要嵌套超過1024個
const MaxFrames = 1024

func New(bytecode *compiler.Bytecode) *VM {
	//主要幀
	mainFn := &object.CompiledFunction{Instructions: bytecode.Instructions}
	mainFrame := NewFrame(mainFn, 0) //基底指針為0

	//先配置幀的array
	frames := make([]*Frame, MaxFrames)
	//第一個放主要幀
	frames[0] = mainFrame

	return &VM{
		//instructions: bytecode.Instructions,
		constants: bytecode.Constants,

		stack:   make([]object.Object, StackSize),
		sp:      0,
		globals: make([]object.Object, GlobalSize), //全域變數

		//幀
		frames:      frames,
		framesIndex: 1,
	}
}

func NewWithGlobalStore(bytecode *compiler.Bytecode, s []object.Object) *VM {
	vm := New(bytecode)
	vm.globals = s
	return vm
}

func (vm *VM) StackTop() object.Object {
	//如果sp = 0代表目前stack沒東西
	if vm.sp == 0 {
		return nil
	}
	return vm.stack[vm.sp-1]
}

func (vm *VM) Run() error {
	var ip int
	var ins code.Instructions
	var op code.Opcode //先定義

	for vm.currentFrame().ip < len(vm.currentFrame().Instructions())-1 {
		vm.currentFrame().ip++

		ip = vm.currentFrame().ip
		ins = vm.currentFrame().Instructions()
		op = code.Opcode(ins[ip])

		switch op {
		case code.OpConstant:
			//不使用code.Lookup的原因是速度!
			//ip指向操作馬 非操作數
			constIndex := code.ReadUint16(ins[ip+1:])
			vm.currentFrame().ip += 2
			err := vm.push(vm.constants[constIndex])
			if err != nil {
				return err
			}
		case code.OpAdd, code.OpSub, code.OpMul, code.OpDiv:
			err := vm.executeBinaryOpeartion(op)
			if err != nil {
				return err
			}
		case code.OpPop:
			vm.pop() //跳出stack
		case code.OpTrue: //如果遇到optrue
			err := vm.push(True)
			if err != nil {
				return err
			}
		case code.OpFalse: //如果遇到Opfalse
			err := vm.push(False)
			if err != nil {
				return err
			}
		case code.OpEqual, code.OpNotEqual, code.OpGreaterThan:
			err := vm.executeComparsion(op)
			if err != nil {
				return err
			}
		case code.OpBang:
			err := vm.excuteBangOperator()
			if err != nil {
				return err
			}
		case code.OpMinus:
			err := vm.excuteMinusOperator()
			if err != nil {
				return err
			}
		case code.OpJump:
			pos := int(code.ReadUint16(ins[ip+1:]))
			vm.currentFrame().ip = pos - 1
		case code.OnJumpNotTruthy:
			pos := int(code.ReadUint16(ins[ip+1:]))
			vm.currentFrame().ip += 2

			condition := vm.pop()
			if !isTruthy(condition) {
				vm.currentFrame().ip = pos - 1
			}
		case code.OpNull:
			err := vm.push(Null)
			if err != nil {
				return err
			}
		case code.OpSetGlobal:
			//從下個指令開始讀
			globalIndex := code.ReadUint16(ins[ip+1:])
			vm.currentFrame().ip += 2          //因為一個OpSetGlobal 使用2byte存 global index
			vm.globals[globalIndex] = vm.pop() //stack top 綁定該global variable
		case code.OpGetGlobal:
			//從下個指令開始讀
			globalIndex := code.ReadUint16(ins[ip+1:])
			vm.currentFrame().ip += 2
			//如果globalIndex超出GlobalSize 就要跳
			//把目前的全域變數取出 塞入stack中
			err := vm.push(vm.globals[globalIndex])

			if err != nil {
				return err
			}
		case code.OpArray:
			numElements := int(code.ReadUint16(ins[ip+1:]))
			vm.currentFrame().ip += 2

			array := vm.buildArray(vm.sp-numElements, vm.sp)
			vm.sp = vm.sp - numElements

			err := vm.push(array)
			if err != nil {
				return err
			}
		case code.OpHash:
			numElements := int(code.ReadUint16(ins[ip+1:]))
			vm.currentFrame().ip += 2

			//取那一段指令到buildhash
			hash, err := vm.buildHash(vm.sp-numElements, vm.sp)
			if err != nil {
				return err
			}
			vm.sp = vm.sp - numElements
			err = vm.push(hash)
			if err != nil {
				return err
			}
		case code.OpIndex:
			index := vm.pop()
			left := vm.pop()

			err := vm.executeIndexExpression(left, index)
			if err != nil {
				return err
			}
		case code.OpCall:
			//抓出parameter
			numArgs := code.ReadUint8(ins[ip+1:])
			vm.currentFrame().ip += 1 // 先跳過那個1 byte index

			//加入內置函數
			err := vm.executeCall(int(numArgs))
			if err != nil {
				return err
			}
		case code.OpReturnValue:
			//把return value彈出
			returnValue := vm.pop()

			//把frame彈出
			frame := vm.popFrame()
			//把compiled function隱性的談走
			//vm.pop()
			//當前sp 就改成基底pointer - 1
			//不pop
			//因為TestCallFunctionWithBindings 是直call 函數
			vm.sp = frame.basePointer - 1

			//推入stack top
			err := vm.push(returnValue)
			if err != nil {
				return err
			}
		case code.OpReturn:
			//把frame彈出
			frame := vm.popFrame()
			//彈出opreturn
			//vm.pop()
			//不彈出fun, 改sp為basepointer - 1
			//因為TestCallFunctionWithBindings 是直call 函數
			vm.sp = frame.basePointer - 1

			//放入null
			err := vm.push(Null)
			if err != nil {
				return err
			}
		case code.OpSetLocal:
			//抓出local instruction的index
			localIndex := code.ReadUint8(ins[ip+1:])
			//注意 OpSetLocal 為 1 byte 長度 index
			vm.currentFrame().ip += 1

			frame := vm.currentFrame()

			//把local variable 塞入stack
			vm.stack[frame.basePointer+int(localIndex)] = vm.pop()
		case code.OpGetLocal:
			//抓localindex
			localIndex := code.ReadUint8(ins[ip+1:])
			//opgetlocal 只有1byte長index
			vm.currentFrame().ip += 1

			frame := vm.currentFrame()

			//把local variable放入vm中
			err := vm.push(vm.stack[frame.basePointer+int(localIndex)])
			if err != nil {
				return err
			}
		case code.OpGetBuiltin:
			builtinIndex := code.ReadUint8(ins[ip+1:])
			vm.currentFrame().ip += 1 //因為builtin 1byte長度

			//抓出內置函數
			definition := object.Builtins[builtinIndex]

			//推入stack top
			err := vm.push(definition.Builtin)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func (vm *VM) callFunction(fn *object.CompiledFunction, numArgs int) error {
	//前面已有executeCall
	//注意 不單compiledFunction入stack, 連同argument也入stack了
	//sp多-1 代表sp本身代表stack top 的下一個
	/*fn, ok := vm.stack[vm.sp-1-numArgs].(*object.CompiledFunction)
	if !ok {
		return fmt.Errorf("calling non-function")
	}*/

	//先檢查parameters數量對不對
	if numArgs != fn.NumParameters {
		return fmt.Errorf("wrong number of arguments: want=%d, got=%d",
			fn.NumParameters, numArgs)
	}

	//此時進入函數前的基底指針為 vm.sp
	//記得 vm.sp - numArgs => 代表
	frame := NewFrame(fn, vm.sp-numArgs)
	vm.pushFrame(frame)
	//目前stack內先 預留 基底指針+該函數有多少local variable
	vm.sp = frame.basePointer + fn.NumLocals

	return nil
}

func (vm *VM) callBuiltin(builtin *object.Builtin, numArgs int) error {
	//取出參數 vm.sp等於stack top下一個
	//這樣為[top下一個-numArgs, top下一個)
	args := vm.stack[vm.sp-numArgs : vm.sp]

	//call內置函數
	result := builtin.Fn(args...)
	//call完就把 stack top 下一個減掉 參數+builtin函數本身
	vm.sp = vm.sp - numArgs - 1

	//有成果則是把結果推入stack top
	if result != nil {
		vm.push(result)
	} else {
		//沒有則Null
		vm.push(Null)
	}

	return nil
}

func (vm *VM) executeCall(numArgs int) error {
	callee := vm.stack[vm.sp-1-numArgs]
	switch callee := callee.(type) {
	case *object.CompiledFunction:
		return vm.callFunction(callee, numArgs)
	case *object.Builtin:
		return vm.callBuiltin(callee, numArgs)
	default:
		return fmt.Errorf("calling non-function and non-built-in")
	}
}

func (vm *VM) buildArray(startIndex, endIndex int) object.Object {
	elements := make([]object.Object, endIndex-startIndex)

	//我的解讀是遠使stack是有index下標得
	//只是放到elements裡面得要扣掉該下標
	for i := startIndex; i < endIndex; i++ {
		elements[i-startIndex] = vm.stack[i]
	}

	return &object.Array{Elements: elements}
}

func (vm *VM) buildHash(startIndex, endIndex int) (object.Object, error) {
	//用map來存取hash key
	hashedPairs := make(map[object.HashKey]object.HashPair)

	for i := startIndex; i < endIndex; i += 2 {
		//key 取 i下標, value 取i+1下標
		key := vm.stack[i]
		value := vm.stack[i+1]

		//建立key pair
		pair := object.HashPair{Key: key, Value: value}
		hashKey, ok := key.(object.Hashable)
		if !ok {
			return nil, fmt.Errorf("unusable as hash key: %s", key.Type())
		}

		hashedPairs[hashKey.HashKey()] = pair
	}

	return &object.Hash{Pairs: hashedPairs}, nil
}

func isTruthy(obj object.Object) bool {
	switch obj := obj.(type) {
	case *object.Boolean:
		return obj.Value
	case *object.Null: //如果condition遇到null 就要跳
		return false
	default:
		return true
	}
}

func (vm *VM) push(o object.Object) error {
	//如果超出stack的大小
	if vm.sp >= StackSize {
		return fmt.Errorf("stack overflow")
	}

	vm.stack[vm.sp] = o
	vm.sp++

	return nil
}

func (vm *VM) pop() object.Object {
	o := vm.stack[vm.sp-1]
	vm.sp--
	return o
}

func (vm *VM) LastPoppedStackElem() object.Object {
	return vm.stack[vm.sp]
}

func (vm *VM) executeBinaryOpeartion(op code.Opcode) error {
	right := vm.pop()
	left := vm.pop()

	leftType := left.Type()
	rightType := right.Type()

	switch {
	//雙方都是整數
	case leftType == object.INTEGER_OBJ && rightType == object.INTEGER_OBJ:
		return vm.executeBinaryIntegerOpeartion(op, left, right)

	//雙方都是字串 +
	case leftType == object.STRING_OBJ && rightType == object.STRING_OBJ:
		return vm.excuteBinaryStringOperation(op, left, right)
	default:
		//非整數
		return fmt.Errorf("unsupported types for binary operation: %s %s",
			leftType, rightType)

	}
}

func (vm *VM) executeBinaryIntegerOpeartion(op code.Opcode, left, right object.Object) error {
	leftValue := left.(*object.Integer).Value
	rightValue := right.(*object.Integer).Value

	var result int64

	//+-*/
	switch op {
	case code.OpAdd:
		result = leftValue + rightValue
	case code.OpSub:
		result = leftValue - rightValue
	case code.OpMul:
		result = leftValue * rightValue
	case code.OpDiv:
		result = leftValue / rightValue
	default:
		return fmt.Errorf("unknown integer operator: %d", op)
	}

	return vm.push(&object.Integer{Value: result})
}

func (vm *VM) excuteBinaryStringOperation(op code.Opcode, left, right object.Object) error {
	//如果不是opAdd 不允許字串的infix
	if op != code.OpAdd {
		return fmt.Errorf("unknown string operator: %d", op)
	}

	leftValue := left.(*object.String).Value
	rightValue := right.(*object.String).Value

	return vm.push(&object.String{Value: leftValue + rightValue})
}

func (vm *VM) executeComparsion(op code.Opcode) error {
	right := vm.pop()
	left := vm.pop()

	//雙方都是整數
	if left.Type() == object.INTEGER_OBJ && right.Type() == object.INTEGER_OBJ {
		return vm.executeIntegerComparsion(op, left, right)
	}

	//可能是布林數
	switch op {
	case code.OpEqual:
		return vm.push(nativeBoolToBooleanObject(right == left))
	case code.OpNotEqual:
		return vm.push(nativeBoolToBooleanObject(right != left))
	default:
		return fmt.Errorf("unknown operator: %d (%s %s)",
			op, left.Type(), right.Type())
	}
}

func (vm *VM) executeIntegerComparsion(
	op code.Opcode,
	left, right object.Object,
) error {
	leftValue := left.(*object.Integer).Value
	rightValue := right.(*object.Integer).Value

	switch op {
	case code.OpEqual:
		return vm.push(nativeBoolToBooleanObject(rightValue == leftValue))
	case code.OpNotEqual:
		return vm.push(nativeBoolToBooleanObject(rightValue != leftValue))
	case code.OpGreaterThan:
		return vm.push(nativeBoolToBooleanObject(leftValue > rightValue))
	default:
		return fmt.Errorf("unknown operator: %d", op)
	}
}

func nativeBoolToBooleanObject(input bool) *object.Boolean {
	if input {
		return True
	}
	return False
}

// 前綴 !，true -> false, false -> true, null 反向-> true
func (vm *VM) excuteBangOperator() error {
	operand := vm.pop()

	switch operand {
	case True:
		return vm.push(False)
	case False:
		return vm.push(True)
	case Null:
		return vm.push(True)
	default:
		return vm.push(False)
	}
}

// 前綴 -
func (vm *VM) excuteMinusOperator() error {
	operand := vm.pop()

	if operand.Type() != object.INTEGER_OBJ {
		return fmt.Errorf("unsupported type for negation: %s", operand.Type())
	}

	value := operand.(*object.Integer).Value

	return vm.push(&object.Integer{Value: -value})
}

func (vm *VM) executeIndexExpression(left, index object.Object) error {
	switch {
	case left.Type() == object.ARRAY_OBJ && index.Type() == object.INTEGER_OBJ:
		return vm.executeArrayIndex(left, index)
	case left.Type() == object.HASH_OBJ:
		return vm.executeHashIndex(left, index)
	default:
		return fmt.Errorf("index operator not supported: %s", left.Type())
	}
}

func (vm *VM) executeArrayIndex(array, index object.Object) error {
	arrayObject := array.(*object.Array)
	i := index.(*object.Integer).Value
	max := int64(len(arrayObject.Elements) - 1)

	//檢查index範圍
	if i < 0 || i > max {
		return vm.push(Null)
	}

	return vm.push(arrayObject.Elements[i])
}

func (vm *VM) executeHashIndex(hash, index object.Object) error {
	hashObject := hash.(*object.Hash)

	key, ok := index.(object.Hashable)
	if !ok {
		return fmt.Errorf("unusable as hash key: %s", index.Type())
	}

	pair, ok := hashObject.Pairs[key.HashKey()]
	if !ok {
		return vm.push(Null)
	}

	return vm.push(pair.Value)
}
