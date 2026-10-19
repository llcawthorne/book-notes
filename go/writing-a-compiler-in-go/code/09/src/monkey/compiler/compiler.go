package compiler

import (
	"fmt"
	"monkey/ast"
	"monkey/code"
	"monkey/object"
	"sort"
)

// 作用域
type CompilationScope struct {
	instructions        code.Instructions
	lastInstruction     EmittedInstruction
	previousInstruction EmittedInstruction
}

type Compiler struct {
	//instructions code.Instructions
	constants []object.Object

	//lastInstruction     EmittedInstruction
	//previousInstruction EmittedInstruction

	symbolTable *SymbolTable

	//作用域
	scopes     []CompilationScope
	scopeIndex int
}

func New() *Compiler {
	//主作用域
	mainScope := CompilationScope{
		instructions: code.Instructions{},
		//快慢指針
		lastInstruction:     EmittedInstruction{},
		previousInstruction: EmittedInstruction{},
	}

	symbolTable := NewSymbolTable()

	//綁定builtin 函數
	for i, v := range object.Builtins {
		symbolTable.DefineBuiltin(i, v.Name)
	}

	return &Compiler{
		//instructions: code.Instructions{},
		constants: []object.Object{},
		//快慢指針
		//lastInstruction:     EmittedInstruction{}, //最後一個指令
		//previousInstruction: EmittedInstruction{}, //倒數第二個命令
		symbolTable: symbolTable,
		scopes:      []CompilationScope{mainScope},
		scopeIndex:  0,
	}
}

// 現在的instruction
func (c *Compiler) currentInstructions() code.Instructions {
	return c.scopes[c.scopeIndex].instructions
}

func NewWithState(s *SymbolTable, constants []object.Object) *Compiler {
	compiler := New()
	compiler.symbolTable = s
	compiler.constants = constants
	return compiler
}

// 作用域 enter leave
func (c *Compiler) enterScope() {
	scope := CompilationScope{
		instructions:        code.Instructions{},
		lastInstruction:     EmittedInstruction{},
		previousInstruction: EmittedInstruction{},
	}
	//將新的作用域加入scopes array
	c.scopes = append(c.scopes, scope)
	//作用域階數增加
	c.scopeIndex++
	//新增下一層的symboltable => 把SymbolTable推到下一層
	c.symbolTable = NewEnclosedSymbolTable(c.symbolTable)
}

func (c *Compiler) leaveScope() code.Instructions {
	//把目前作用域的當下指令抓出
	instructions := c.currentInstructions()

	//移除目前作用域
	c.scopes = c.scopes[:len(c.scopes)-1]
	//作用域層級-1
	c.scopeIndex--

	//離開該作用域，SymbolTable要退回outer
	c.symbolTable = c.symbolTable.Outer

	//回傳目前的指令
	return instructions
}

// 編譯
func (c *Compiler) Compile(node ast.Node) error {
	switch node := node.(type) {
	case *ast.Program:
		for _, s := range node.Statements {
			err := c.Compile(s)
			if err != nil {
				return err
			}
		}
	case *ast.ExpressionStatement:
		err := c.Compile(node.Expression)
		if err != nil {
			return err
		}
		c.emit(code.OpPop)
	case *ast.InfixExpression:
		//針對 < 的重排序支持
		if node.Operator == "<" {
			//其實就是把左右對調 再比大於 哈哈
			err := c.Compile(node.Right)
			if err != nil {
				return err
			}
			err = c.Compile(node.Left)
			if err != nil {
				return err
			}
			c.emit(code.OpGreaterThan)
			return nil
		}

		err := c.Compile(node.Left)
		if err != nil {
			return err
		}
		err = c.Compile(node.Right)
		if err != nil {
			return err
		}

		switch node.Operator {
		//+的話要發OpAdd指令
		case "+":
			c.emit(code.OpAdd)
		case "-":
			c.emit(code.OpSub)
		case "*":
			c.emit(code.OpMul)
		case "/":
			c.emit(code.OpDiv)
		case ">":
			c.emit(code.OpGreaterThan)
		case "==":
			c.emit(code.OpEqual)
		case "!=":
			c.emit(code.OpNotEqual)
		default:
			//其餘的則error
			return fmt.Errorf("unknown operator %s", node.Operator)
		}
	case *ast.PrefixExpression:
		err := c.Compile(node.Right)
		if err != nil {
			return err
		}

		// ! => 前綴, - 前綴
		switch node.Operator {
		case "!":
			c.emit(code.OpBang)
		case "-":
			c.emit(code.OpMinus)
		default:
			return fmt.Errorf("unknown operator %s", node.Operator)
		}

	case *ast.IntegerLiteral:
		//TODO 如何處理!!!
		integer := &object.Integer{Value: node.Value}
		c.emit(code.OpConstant, c.addConstant(integer))
	case *ast.Boolean:
		if node.Value {
			c.emit(code.OpTrue)
		} else {
			c.emit(code.OpFalse)
		}
	case *ast.IfExpression:
		err := c.Compile(node.Condition)
		if err != nil {
			return nil
		}

		//發出虛假的偏移量的OnJumpNotTruthy
		jumpNotTruthyPos := c.emit(code.OnJumpNotTruthy, 9999)

		err = c.Compile(node.Consequence)
		if err != nil {
			return err
		}

		//if c.lastInstructionIsPop() {
		if c.lastInstructionIs(code.OpPop) {
			c.removeLastPop()
		}

		//發出帶有虛擬偏移量的onjump
		jumpPos := c.emit(code.OpJump, 9999)

		//抓目前作用域
		afterConsequencePos := len(c.currentInstructions())
		//將jumpNotTruthPos 改成 afterConsequencePos
		c.changeOperand(jumpNotTruthyPos, afterConsequencePos)

		//如果沒有else區塊
		if node.Alternative == nil {
			c.emit(code.OpNull)
		} else {
			//afterConsequencePos := len(c.instructions)
			//c.changeOperand(jumpNotTruthyPos, afterConsequencePos)

			err := c.Compile(node.Alternative)
			if err != nil {
				return err
			}

			//if c.lastInstructionIsPop() {
			if c.lastInstructionIs(code.OpPop) {
				c.removeLastPop()
			}

		}

		//抓目前作用域的
		afterAlternativePos := len(c.currentInstructions())
		c.changeOperand(jumpPos, afterAlternativePos)

	case *ast.BlockStatement:
		for _, s := range node.Statements {
			err := c.Compile(s)
			if err != nil {
				return err
			}
		}
	case *ast.LetStatement:
		//因為需要修復遞迴閉包
		//該identifier name的字串名稱
		symbol := c.symbolTable.Define(node.Name.Value)

		err := c.Compile(node.Value)
		if err != nil {
			return err
		}
		//發出setglobal + index
		if symbol.Scope == GlobalScope {
			c.emit(code.OpSetGlobal, symbol.Index)
		} else {
			//如果是localScope => 發opSetLocal
			c.emit(code.OpSetLocal, symbol.Index)
		}
	case *ast.Identifier:
		//遇到ident 先去解析
		symbol, ok := c.symbolTable.Resolve(node.Value)
		if !ok {
			return fmt.Errorf("undefined variable %s", node.Value)
		}
		c.loadSymbol(symbol)
	case *ast.StringLiteral:
		//新增字串 + 發opcode 把字串放constant
		str := &object.String{Value: node.Value}
		c.emit(code.OpConstant, c.addConstant(str))
	case *ast.ArrayLiteral:
		//陣列 每個元素都有可能是expression
		for _, el := range node.Elements {
			err := c.Compile(el)
			if err != nil {
				return err
			}
		}
		//發opArray指令
		c.emit(code.OpArray, len(node.Elements))
	case *ast.HashLiteral:
		keys := []ast.Expression{}
		for k := range node.Pairs {
			keys = append(keys, k)
		}
		//排序使用key的字典順序
		sort.Slice(keys, func(i, j int) bool {
			return keys[i].String() < keys[j].String()
		})

		for _, k := range keys {
			//對key編譯
			err := c.Compile(k)
			if err != nil {
				return err
			}
			//編譯好 對value編譯
			err = c.Compile(node.Pairs[k])
			if err != nil {
				return err
			}
		}

		//發出opHash, 注意key value 數量是偶數
		c.emit(code.OpHash, len(node.Pairs)*2)
	case *ast.IndexExpression:
		err := c.Compile(node.Left)
		if err != nil {
			return err
		}
		err = c.Compile(node.Index)
		if err != nil {
			return err
		}

		c.emit(code.OpIndex)
	case *ast.FunctionLiteral:
		//進入作用域
		c.enterScope()

		//檢查函數名稱
		if node.Name != "" {
			c.symbolTable.DefineFunctionName(node.Name)
		}

		//把parameter 做symboltable註冊
		for _, p := range node.Parameters {
			c.symbolTable.Define(p.Value)
		}

		//編譯函數區塊
		err := c.Compile(node.Body)
		if err != nil {
			return err
		}

		//如果最後一個是OnPop => Expression
		//要把OpPop改OpReturnValue
		if c.lastInstructionIs(code.OpPop) {
			c.replaceLastPopWithReturn()
		}

		//最後一個指令不是ReturnValue => 則發Return
		//有可能裡面空的
		if !c.lastInstructionIs(code.OpReturnValue) {
			c.emit(code.OpReturn)
		}

		//自由變數 封閉作用域的 局部變數
		freeSymbols := c.symbolTable.FreeSymbols

		//抓出該函數有多少個local variable
		numLocals := c.symbolTable.numDefinitions
		//退出作用域
		instructions := c.leaveScope()

		//載入variable scope
		for _, s := range freeSymbols {
			c.loadSymbol(s)
		}

		//把函數編譯成object
		compiledFn := &object.CompiledFunction{
			Instructions:  instructions,
			NumLocals:     numLocals,
			NumParameters: len(node.Parameters),
		}

		//改成發閉包opcode
		fnIndex := c.addConstant(compiledFn)
		//發出closure, 最後的自由變數數量要正確
		c.emit(code.OpClosure, fnIndex, len(freeSymbols))

		//c.emit(code.OpConstant, c.addConstant(compiledFn))
	case *ast.ReturnStatement:
		//回傳值
		err := c.Compile(node.ReturnValue)
		if err != nil {
			return err
		}

		c.emit(code.OpReturnValue)
	case *ast.CallExpression:
		err := c.Compile(node.Function)
		if err != nil {
			return err
		}

		//編譯 argument
		for _, a := range node.Arguments {
			err := c.Compile(a)
			if err != nil {
				return err
			}
		}

		//多加入argument的數量
		c.emit(code.OpCall, len(node.Arguments))
	}

	return nil
}

// 給 Compile *ast.Identifier 去call的load symbol函數
func (c *Compiler) loadSymbol(s Symbol) {
	//發出getglobal + index
	switch s.Scope {
	case GlobalScope:
		c.emit(code.OpGetGlobal, s.Index)
	case LocalScope:
		//如果是local scope 發OpGetLocal
		c.emit(code.OpGetLocal, s.Index)
	case BuiltinScope:
		c.emit(code.OpGetBuiltin, s.Index)
	case FreeScope:
		//如果是free scope 發OpGetFree
		c.emit(code.OpGetFree, s.Index)
	case FunctionScope:
		//如果是函數scope
		c.emit(code.OpCurrentClosure)
	}
}

func (c *Compiler) addConstant(obj object.Object) int {
	c.constants = append(c.constants, obj)
	return len(c.constants) - 1
}

func (c *Compiler) emit(op code.Opcode, operands ...int) int {
	ins := code.Make(op, operands...)
	pos := c.addInstruction(ins)

	c.setLastInstruction(op, pos)

	return pos
}

func (c *Compiler) addInstruction(ins []byte) int {
	posNewInstruction := len(c.currentInstructions())
	updateInstruction := append(c.currentInstructions(), ins...)

	//目前的作用域 修改該instruction list
	c.scopes[c.scopeIndex].instructions = updateInstruction

	return posNewInstruction
}

func (c *Compiler) setLastInstruction(op code.Opcode, pos int) {
	//改成目前的作用域
	previous := c.scopes[c.scopeIndex].lastInstruction
	last := EmittedInstruction{Opcode: op, Position: pos}

	c.scopes[c.scopeIndex].previousInstruction = previous
	c.scopes[c.scopeIndex].lastInstruction = last
}

// 如果最後一個是OpPop
func (c *Compiler) lastInstructionIsPop() bool {
	//目前作用域
	return c.scopes[c.scopeIndex].lastInstruction.Opcode == code.OpPop
}

// 目前作用域最後一個op指令是
func (c *Compiler) lastInstructionIs(op code.Opcode) bool {
	if len(c.currentInstructions()) == 0 {
		return false
	}

	return c.scopes[c.scopeIndex].lastInstruction.Opcode == op
}

// 把最後一個砍掉
func (c *Compiler) removeLastPop() {
	//抓目前作用域的 到數最後一個 + 倒數最後第二個指令
	last := c.scopes[c.scopeIndex].lastInstruction
	previous := c.scopes[c.scopeIndex].previousInstruction

	//old = 目前的指令
	old := c.currentInstructions()

	//new = 去掉最後一個指令
	new := old[:last.Position]

	//指令集 = new, 原先倒數最後二個指令變 倒數第一個指令
	c.scopes[c.scopeIndex].instructions = new
	c.scopes[c.scopeIndex].lastInstruction = previous
}

// 取代instruction 修改指定的偏移量
func (c *Compiler) replaceInstruction(pos int, newInstruction []byte) {
	//抓目前作用域的當前指令
	ins := c.currentInstructions()
	for i := 0; i < len(newInstruction); i++ {
		ins[pos+i] = newInstruction[i]
	}
}

// 如果當前作用域的最後一個是Pop
// 那就把最後一個指令改為OpReturnValue
// implicity return value
func (c *Compiler) replaceLastPopWithReturn() {
	lastPos := c.scopes[c.scopeIndex].lastInstruction.Position
	c.replaceInstruction(lastPos, code.Make(code.OpReturnValue))

	c.scopes[c.scopeIndex].lastInstruction.Opcode = code.OpReturnValue
}

func (c *Compiler) changeOperand(onPos int, operand int) {
	//抓目前作用域的當前指令
	op := code.Opcode(c.currentInstructions()[onPos])
	newInstruction := code.Make(op, operand)

	c.replaceInstruction(onPos, newInstruction)
}

func (c *Compiler) Bytecode() *Bytecode {
	return &Bytecode{
		//抓目前作用域
		Instructions: c.currentInstructions(),
		Constants:    c.constants,
	}
}

type Bytecode struct {
	Instructions code.Instructions
	Constants    []object.Object
}

type EmittedInstruction struct {
	Opcode   code.Opcode
	Position int
}
