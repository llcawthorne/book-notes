package compiler

import (
	"fmt"
	"monkey/ast"
	"monkey/code"
	"monkey/lexer"
	"monkey/object"
	"monkey/parser"
	"testing"
)

type compilerTestCase struct {
	input                string
	expectedConstants    []interface{}
	expectedInstructions []code.Instructions
}

func TestIntegerArithmetic(t *testing.T) {
	tests := []compilerTestCase{
		{
			input:             "1 + 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpAdd), //ch2
				code.Make(code.OpPop), //ch3
			},
		},
		{
			input:             "1; 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpPop),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "1 - 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpSub),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "1 * 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpMul),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "2 / 1",
			expectedConstants: []interface{}{2, 1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpDiv),
				code.Make(code.OpPop),
			},
		},
		//
		{
			input:             "true",
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpTrue),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "false",
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpFalse),
				code.Make(code.OpPop),
			},
		},
		//
		{
			input:             "1 > 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpGreaterThan),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "1 < 2",
			expectedConstants: []interface{}{2, 1}, //順序對調
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpGreaterThan),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "1 == 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpEqual),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "1 != 2",
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpNotEqual),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "true == false",
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpTrue),
				code.Make(code.OpFalse),
				code.Make(code.OpEqual),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "true != false",
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpTrue),
				code.Make(code.OpFalse),
				code.Make(code.OpNotEqual),
				code.Make(code.OpPop),
			},
		},
		//
		{
			input:             "-1",
			expectedConstants: []interface{}{1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpMinus),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "!true",
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpTrue),
				code.Make(code.OpBang),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestConditionals(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `
			if (true) { 10; }; 3333;
			`,
			expectedConstants: []interface{}{10, 3333},
			expectedInstructions: []code.Instructions{
				//0000
				code.Make(code.OpTrue),
				//0001
				code.Make(code.OnJumpNotTruthy, 10),
				//0004
				code.Make(code.OpConstant, 0),
				//0007
				code.Make(code.OpJump, 11),
				//0010
				code.Make(code.OpNull),
				//0011
				code.Make(code.OpPop),
				//0012
				code.Make(code.OpConstant, 1),
				//0013
				code.Make(code.OpPop),
			},
		},
		//else
		{
			input: `
			if (true) { 10 } else { 20 }; 3333;
			`,
			expectedConstants: []interface{}{10, 20, 3333},
			expectedInstructions: []code.Instructions{
				//0000
				code.Make(code.OpTrue),
				//0001
				code.Make(code.OnJumpNotTruthy, 10),
				//0004
				code.Make(code.OpConstant, 0),
				//0007
				code.Make(code.OpJump, 13),
				//0010
				code.Make(code.OpConstant, 1),
				//0013
				code.Make(code.OpPop),
				//0014
				code.Make(code.OpConstant, 2),
				//0017
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestGlobalLetStatement(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `
			let one = 1;
			let two = 2;
			`,
			expectedConstants: []interface{}{1, 2},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpSetGlobal, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpSetGlobal, 1),
			},
		},
		{
			input: `
			let one = 1;
			one;
			`,
			expectedConstants: []interface{}{1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpSetGlobal, 0),
				code.Make(code.OpGetGlobal, 0),
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			let one = 1;
			let two = one;
			two;
			`,
			expectedConstants: []interface{}{1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpSetGlobal, 0),
				code.Make(code.OpGetGlobal, 0),
				code.Make(code.OpSetGlobal, 1),
				code.Make(code.OpGetGlobal, 1),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestStringExpression(t *testing.T) {
	tests := []compilerTestCase{
		{
			input:             `"monkey"`,
			expectedConstants: []interface{}{"monkey"},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpPop),
			},
		},
		{
			input:             `"mon" + "key"`,
			expectedConstants: []interface{}{"mon", "key"},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpAdd),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestArrayLiterals(t *testing.T) {
	tests := []compilerTestCase{
		{
			input:             `[]`,
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpArray, 0),
				code.Make(code.OpPop),
			},
		},
		{
			input:             `[1, 2, 3]`,
			expectedConstants: []interface{}{1, 2, 3},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpConstant, 2),
				code.Make(code.OpArray, 3),
				code.Make(code.OpPop),
			},
		},
		{
			input:             `[1 + 2, 3 - 4, 5 * 6]`,
			expectedConstants: []interface{}{1, 2, 3, 4, 5, 6},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpAdd),
				code.Make(code.OpConstant, 2),
				code.Make(code.OpConstant, 3),
				code.Make(code.OpSub),
				code.Make(code.OpConstant, 4),
				code.Make(code.OpConstant, 5),
				code.Make(code.OpMul),
				code.Make(code.OpArray, 3),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestHashLiterals(t *testing.T) {
	tests := []compilerTestCase{
		{
			input:             "{}",
			expectedConstants: []interface{}{},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpHash, 0),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "{1: 2, 3: 4, 5: 6}",
			expectedConstants: []interface{}{1, 2, 3, 4, 5, 6},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpConstant, 2),
				code.Make(code.OpConstant, 3),
				code.Make(code.OpConstant, 4),
				code.Make(code.OpConstant, 5),
				code.Make(code.OpHash, 6),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "{1: 2 + 3, 4: 5 * 6}",
			expectedConstants: []interface{}{1, 2, 3, 4, 5, 6},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpConstant, 2),
				code.Make(code.OpAdd),
				code.Make(code.OpConstant, 3),
				code.Make(code.OpConstant, 4),
				code.Make(code.OpConstant, 5),
				code.Make(code.OpMul),
				code.Make(code.OpHash, 4),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestIndexExpressions(t *testing.T) {
	tests := []compilerTestCase{
		{
			input:             "[1, 2, 3][1 + 1]",
			expectedConstants: []interface{}{1, 2, 3, 1, 1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpConstant, 2),
				code.Make(code.OpArray, 3),
				code.Make(code.OpConstant, 3),
				code.Make(code.OpConstant, 4),
				code.Make(code.OpAdd),
				code.Make(code.OpIndex),
				code.Make(code.OpPop),
			},
		},
		{
			input:             "{1: 2}[2 - 1]",
			expectedConstants: []interface{}{1, 2, 2, 1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpConstant, 1),
				code.Make(code.OpHash, 2),
				code.Make(code.OpConstant, 2),
				code.Make(code.OpConstant, 3),
				code.Make(code.OpSub),
				code.Make(code.OpIndex),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestFunction(t *testing.T) {
	tests := []compilerTestCase{
		//explicity return value
		{
			input: `fn() { return 5 + 10 }`,
			expectedConstants: []interface{}{5, 10,
				[]code.Instructions{
					code.Make(code.OpConstant, 0),
					code.Make(code.OpConstant, 1),
					code.Make(code.OpAdd),
					code.Make(code.OpReturnValue),
				}},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 2),
				code.Make(code.OpClosure, 2, 0),
				code.Make(code.OpPop),
			},
		},
		//implicity return value, 最後一個函數內的OnPop 應該是 OnReturnValue
		{
			input: `fn() { 5 + 10 }`,
			expectedConstants: []interface{}{5, 10,
				[]code.Instructions{
					code.Make(code.OpConstant, 0),
					code.Make(code.OpConstant, 1),
					code.Make(code.OpAdd),
					code.Make(code.OpReturnValue),
				}},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 2),
				code.Make(code.OpClosure, 2, 0),
				code.Make(code.OpPop),
			},
		},
		{
			input: `fn() { 1; 2 }`,
			expectedConstants: []interface{}{1, 2,
				[]code.Instructions{
					code.Make(code.OpConstant, 0),
					code.Make(code.OpPop),
					code.Make(code.OpConstant, 1),
					code.Make(code.OpReturnValue),
				}},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 2),
				code.Make(code.OpClosure, 2, 0),
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestFunctionsWithoutReturnValue(t *testing.T) {
	tests := []compilerTestCase{
		//empty return
		{
			input: `fn() { }`,
			expectedConstants: []interface{}{
				[]code.Instructions{
					code.Make(code.OpReturn),
				}},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpClosure, 0), //被編譯的函數 放閉包
				code.Make(code.OpPop),
			},
		},
	}
	runCompilerTests(t, tests)
}

func TestCompilerScopes(t *testing.T) {
	compiler := New()
	if compiler.scopeIndex != 0 {
		t.Errorf("scopeIndex wrong. got=%d, want=%d", compiler.scopeIndex, 0)
	}

	//補上Global symbol table
	globalSymbolTable := compiler.symbolTable

	compiler.emit(code.OpMul)
	compiler.enterScope()

	if compiler.scopeIndex != 1 {
		t.Errorf("scopeIndex wrong. got=%d, want=%d", compiler.scopeIndex, 1)
	}

	compiler.emit(code.OpSub)

	if len(compiler.scopes[compiler.scopeIndex].instructions) != 1 {
		t.Errorf("instructions length wrong. got=%d",
			len(compiler.scopes[compiler.scopeIndex].instructions))
	}

	last := compiler.scopes[compiler.scopeIndex].lastInstruction
	if last.Opcode != code.OpSub {
		t.Errorf("lastInstruction.Opcode wrong. got=%d, want=%d",
			last.Opcode, code.OpSub)
	}

	//補上inner Symbol Table
	if compiler.symbolTable.Outer != globalSymbolTable {
		t.Errorf("compiler did not enclose symbolTable")
	}

	compiler.leaveScope()

	if compiler.scopeIndex != 0 {
		t.Errorf("scopeIndex wrong. got=%d, want=%d",
			compiler.scopeIndex, 0)
	}

	//補上inner Symbol Table
	if compiler.symbolTable != globalSymbolTable {
		t.Errorf("compiler did not restore global symbol table")
	}

	if compiler.symbolTable.Outer != nil {
		t.Errorf("compiler modified global symbol table incorrectly")
	}

	compiler.emit(code.OpAdd)

	if len(compiler.scopes[compiler.scopeIndex].instructions) != 2 {
		t.Errorf("instructions length wrong. got=%d",
			len(compiler.scopes[compiler.scopeIndex].instructions))
	}

	last = compiler.scopes[compiler.scopeIndex].lastInstruction
	if last.Opcode != code.OpAdd {
		t.Errorf("lastInstruction.Opcode wrong. got=%d, want=%d",
			last.Opcode, code.OpAdd)
	}

	pervious := compiler.scopes[compiler.scopeIndex].previousInstruction
	if pervious.Opcode != code.OpMul {
		t.Errorf("perviousInstruction.Opcode wrong. got=%d, want=%d",
			pervious.Opcode, code.OpMul)

	}
}

func TestFunctionCalls(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `fn() { 24 }()`,
			expectedConstants: []interface{}{
				24,
				[]code.Instructions{
					code.Make(code.OpConstant, 0), //字面24
					code.Make(code.OpReturnValue),
				},
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 1), //被編譯的函數
				code.Make(code.OpClosure, 1, 0), //現在被編譯的函數放入閉包
				code.Make(code.OpCall, 0),
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			let noArg = fn() { 24 };
			noArg();
			`,
			expectedConstants: []interface{}{
				24,
				[]code.Instructions{
					code.Make(code.OpConstant, 0), //字面24
					code.Make(code.OpReturnValue),
				},
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 1),  //被編譯的函數
				code.Make(code.OpClosure, 1, 0), //被編譯的函數, 放閉包
				code.Make(code.OpSetGlobal, 0),  //set noArg
				code.Make(code.OpGetGlobal, 0),  //get noArg
				code.Make(code.OpCall, 0),
				code.Make(code.OpPop),
			},
		},
		//argument
		{
			input: `
			let oneArg = fn(a) { a };
			oneArg(24);
			`,
			expectedConstants: []interface{}{
				[]code.Instructions{
					code.Make(code.OpGetLocal, 0),
					code.Make(code.OpReturnValue), //沒有回傳值
				},
				24,
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 0),  //被編譯的函數
				code.Make(code.OpClosure, 0, 0), //被編譯的函數 放閉包
				code.Make(code.OpSetGlobal, 0),  //函數放入Global
				code.Make(code.OpGetGlobal, 0),  //取出函數
				code.Make(code.OpConstant, 1),   //放入24
				code.Make(code.OpCall, 1),       //呼叫函數
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			let manyArg = fn(a, b, c) { a; b; c; };
			manyArg(24, 25, 26);
			`,
			expectedConstants: []interface{}{
				[]code.Instructions{
					code.Make(code.OpGetLocal, 0), //argument1
					code.Make(code.OpPop),
					code.Make(code.OpGetLocal, 1), //arg2
					code.Make(code.OpPop),
					code.Make(code.OpGetLocal, 2), //arg3
					code.Make(code.OpReturnValue), //沒有回傳值
				},
				24,
				25,
				26,
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 0),  //被編譯的函數
				code.Make(code.OpClosure, 0, 0), //被編譯的函數 放閉包
				code.Make(code.OpSetGlobal, 0),  //函數放入Global
				code.Make(code.OpGetGlobal, 0),  //取出函數
				code.Make(code.OpConstant, 1),   //放入24
				code.Make(code.OpConstant, 2),   //放入25
				code.Make(code.OpConstant, 3),   //放入26
				code.Make(code.OpCall, 3),       //呼叫函數
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestLetStatementScope(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `
			let num = 55;
			fn () { num; }`,
			expectedConstants: []interface{}{
				55,
				[]code.Instructions{
					code.Make(code.OpGetGlobal, 0), //抓出字面55
					code.Make(code.OpReturnValue),  //回傳字面55
				},
			},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),  //被編譯的函數
				code.Make(code.OpSetGlobal, 0), //55放入global
				//code.Make(code.OpConstant, 1),  //implicty 55 return value => 被編譯的函數
				code.Make(code.OpClosure, 1, 0), //implicty 55 return value => 被編譯的函數
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			fn () {
				let num = 55;
				num
			}
			`,
			expectedConstants: []interface{}{
				55,
				[]code.Instructions{
					code.Make(code.OpConstant, 0), //字面55
					code.Make(code.OpSetLocal, 0), //55放入local
					code.Make(code.OpGetLocal, 0), //55抓出
					code.Make(code.OpReturnValue), //回傳值
				},
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 1), //抓出回傳值 55 => 被編譯的函數
				code.Make(code.OpClosure, 1, 0), //抓出回傳值 55 => 被編譯的函數
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			fn () {
				let a = 55;
				let b = 77;
				a+b
			}
			`,
			expectedConstants: []interface{}{
				55,
				77,
				[]code.Instructions{
					code.Make(code.OpConstant, 0), //字面55
					code.Make(code.OpSetLocal, 0), //55放local
					code.Make(code.OpConstant, 1), //字面77
					code.Make(code.OpSetLocal, 1), //77放local
					code.Make(code.OpGetLocal, 0), //抓出55
					code.Make(code.OpGetLocal, 1), //抓出77
					code.Make(code.OpAdd),         //55 + 77
					code.Make(code.OpReturnValue),
				},
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 2), //55 + 77 的回傳值 被編譯的函數
				code.Make(code.OpClosure, 2, 0), //55 + 77 的回傳值 被編譯的函數
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestBuiltins(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `
			len([]);
			push([], 1);
			`,
			expectedConstants: []interface{}{1},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpGetBuiltin, 0), //抓第一個len builtin
				code.Make(code.OpArray, 0),      //陣列 0個
				code.Make(code.OpCall, 1),       //call函數 1個參數
				code.Make(code.OpPop),
				code.Make(code.OpGetBuiltin, 5), //抓最後一個push
				code.Make(code.OpArray, 0),      //array 0元素
				code.Make(code.OpConstant, 0),   //1 常數
				code.Make(code.OpCall, 2),       //callc函數兩個參數
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			fn () { len([]) }
			`,
			expectedConstants: []interface{}{
				[]code.Instructions{
					code.Make(code.OpGetBuiltin, 0), //第1個len
					code.Make(code.OpArray, 0),      //array 0元素
					code.Make(code.OpCall, 1),       //len 放入 array
					code.Make(code.OpReturnValue),   //implicity return
				},
			},
			expectedInstructions: []code.Instructions{
				//code.Make(code.OpConstant, 0), //回傳值 常數
				code.Make(code.OpClosure, 0, 0), //回傳值 常數
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestClosures(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `
			fn (a){
				fn(b){
					a+b
				}
			}
			`,
			expectedConstants: []interface{}{
				[]code.Instructions{
					code.Make(code.OpGetFree, 0),  //a arg
					code.Make(code.OpGetLocal, 0), //b local var
					code.Make(code.OpAdd),         //a+b
					code.Make(code.OpReturnValue), //回傳
				},
				[]code.Instructions{
					code.Make(code.OpGetLocal, 0),   //a arg
					code.Make(code.OpClosure, 0, 1), //b 被封裝成函數
					code.Make(code.OpReturnValue),   //回傳 fn(b)
				},
			},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpClosure, 1, 0), //創建閉包
				code.Make(code.OpPop),
			},
		},
		{
			input: `
			fn (a){
				fn(b){
					fn(c){
						a + b + c
					}
				}
			}
			`,
			expectedConstants: []interface{}{
				[]code.Instructions{
					code.Make(code.OpGetFree, 0),  //a arg
					code.Make(code.OpGetFree, 1),  //b arg
					code.Make(code.OpAdd),         //相加
					code.Make(code.OpGetLocal, 0), //c local var
					code.Make(code.OpAdd),         //a+b+c
					code.Make(code.OpReturnValue), //回傳fn(c)
				},
				[]code.Instructions{
					code.Make(code.OpGetFree, 0),    //a arg
					code.Make(code.OpGetLocal, 0),   //b arg
					code.Make(code.OpClosure, 0, 2), //c 被封裝成函數
					code.Make(code.OpReturnValue),   //回傳 fn(b)
				},
				[]code.Instructions{
					code.Make(code.OpGetLocal, 0),   //a arg
					code.Make(code.OpClosure, 1, 1), //b 被封裝成函數
					code.Make(code.OpReturnValue),   //回傳fn(a)
				},
			},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpClosure, 2, 0), //創建閉包
				code.Make(code.OpPop),
			},
		},

		{
			input: `
			let global = 55;

			fn (){
				let a = 66;

				fn(){
					let b = 77;

					fn(){
						let c = 88;

						global + a + b + c
					}
				}
			}
			`,
			expectedConstants: []interface{}{
				55, 66, 77, 88,
				[]code.Instructions{
					code.Make(code.OpConstant, 3),  //三個常數
					code.Make(code.OpSetLocal, 0),  //c local var
					code.Make(code.OpGetGlobal, 0), //global var
					code.Make(code.OpGetFree, 0),   //a
					code.Make(code.OpAdd),          //相加
					code.Make(code.OpGetFree, 1),   //b
					code.Make(code.OpAdd),          //相加
					code.Make(code.OpGetLocal, 0),  //c local var
					code.Make(code.OpAdd),          //a+b+c
					code.Make(code.OpReturnValue),  //global + a + b + c
				},
				[]code.Instructions{
					code.Make(code.OpConstant, 2),   //兩個常數
					code.Make(code.OpSetLocal, 0),   //b local var
					code.Make(code.OpGetFree, 0),    //a arg
					code.Make(code.OpGetLocal, 0),   //b local var
					code.Make(code.OpClosure, 4, 2), //有c local var回傳的函數 4個常數2個自由變數
					code.Make(code.OpReturnValue),   //回傳 有c local var的函數
				},
				[]code.Instructions{
					code.Make(code.OpConstant, 1),   //兩個常數
					code.Make(code.OpSetLocal, 0),   //a local var
					code.Make(code.OpGetLocal, 0),   //a local var
					code.Make(code.OpClosure, 5, 1), //有b local var回傳的函數 5個常數1個自由變數 b 被封裝成函數
					code.Make(code.OpReturnValue),   //回傳 有b local var的函數
				},
			},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpConstant, 0),
				code.Make(code.OpSetGlobal, 0),
				code.Make(code.OpClosure, 6, 0), //創建閉包, 6個常數, 0自由變數
				code.Make(code.OpPop),
			},
		},
	}

	runCompilerTests(t, tests)
}

func TestRecursiveFunctions(t *testing.T) {
	tests := []compilerTestCase{
		{
			input: `
			let countDown = fn(x) { countDown(x - 1); };
			countDown(1);
			`,
			expectedConstants: []interface{}{
				1,
				[]code.Instructions{
					code.Make(code.OpCurrentClosure), //當前閉包 fn(x)
					code.Make(code.OpGetLocal, 0),    //x arg
					code.Make(code.OpConstant, 0),    //1 常數
					code.Make(code.OpSub),            //x - 1
					code.Make(code.OpCall, 1),        // countDown(x - 1)
					code.Make(code.OpReturnValue),    //回傳 countDown(x - 1)
				},
				1,
			},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpClosure, 1, 0), //創建閉包
				code.Make(code.OpSetGlobal, 0),  //Closure global var set
				code.Make(code.OpGetGlobal, 0),  //get Closure global var
				code.Make(code.OpConstant, 2),   //常數1
				code.Make(code.OpCall, 1),       //call countDown(1)
				code.Make(code.OpPop),
			},
		},
		//
		{
			input: `
			let wrapper = fn(){
				let countDown = fn(x) { countDown(x - 1); };
				countDown(1);
			};
			wrapper();
			`,
			expectedConstants: []interface{}{
				1,
				[]code.Instructions{
					code.Make(code.OpCurrentClosure), //countDown
					code.Make(code.OpGetLocal, 0),    //x arg
					code.Make(code.OpConstant, 0),    // 1常數
					code.Make(code.OpSub),            //x-1
					code.Make(code.OpCall, 1),        //countDown(x - 1)
					code.Make(code.OpReturnValue),    //回傳countDown(x - 1)
				},
				1,
				[]code.Instructions{
					code.Make(code.OpClosure, 1, 0), //wrapper
					code.Make(code.OpSetLocal, 0),   //countDown local var set
					code.Make(code.OpGetLocal, 0),   //countDown local var get
					code.Make(code.OpConstant, 2),   //1常數
					code.Make(code.OpCall, 1),       //call countDown(1)
					code.Make(code.OpReturnValue),   //回傳 countDown(1)
				},
			},
			expectedInstructions: []code.Instructions{
				code.Make(code.OpClosure, 3, 0), //wrapper
				code.Make(code.OpSetGlobal, 0),  //wrapper global var set
				code.Make(code.OpGetGlobal, 0),  //wrapper global var get
				code.Make(code.OpCall, 0),       //call wrapper(1)
				code.Make(code.OpPop),           //彈出
			},
		},
	}

	runCompilerTests(t, tests)
}

func runCompilerTests(t *testing.T, tests []compilerTestCase) {
	t.Helper()

	for _, tt := range tests {
		program := parse(tt.input)

		compiler := New()
		err := compiler.Compile(program)
		if err != nil {
			t.Fatalf("compiler error: %s", err)
		}

		bytecode := compiler.Bytecode()

		err = testInstructions(tt.expectedInstructions, bytecode.Instructions)
		if err != nil {
			t.Fatalf("testInstructions failed: %s", err)
		}

		err = testConstants(t, tt.expectedConstants, bytecode.Constants)
		if err != nil {
			t.Fatalf("testConstants failed: %s", err)
		}
	}
}

func parse(input string) *ast.Program {
	l := lexer.New(input)
	p := parser.New(l)
	return p.ParseProgram()
}

func testInstructions(
	expected []code.Instructions,
	actual code.Instructions,
) error {
	concatted := concatInstructions(expected)

	if len(actual) != len(concatted) {
		return fmt.Errorf("wrong instructions length.\nwant=%q\ngot=%q",
			concatted, actual)
	}

	for i, ins := range concatted {
		if actual[i] != ins {
			return fmt.Errorf("wrong instruction at %d.\nwant=%q\ngot=%q",
				i, concatted, actual)
		}
	}

	return nil
}

// 連接Instruction
func concatInstructions(s []code.Instructions) code.Instructions {
	out := code.Instructions{}

	for _, ins := range s {
		out = append(out, ins...)
	}

	return out
}

func testConstants(
	t *testing.T,
	expected []interface{},
	actual []object.Object,
) error {
	if len(expected) != len(actual) {
		return fmt.Errorf("wrong number of contstants. got=%d, want=%d",
			len(actual), len(expected))
	}

	for i, constant := range expected {
		switch constant := constant.(type) {
		case int:
			err := testIntegerObject(int64(constant), actual[i])
			if err != nil {
				return fmt.Errorf("constant %d - testIntegerObject failed: %s",
					i, err)
			}
		//加入string
		case string:
			err := testStringObject(constant, actual[i])
			if err != nil {
				return fmt.Errorf("constant %d - testStringObject failed: %s", i, err)
			}
			//加入sub instruction
		case []code.Instructions:
			//主要處理是否為CompiledFunction的object
			fn, ok := actual[i].(*object.CompiledFunction)
			if !ok {
				return fmt.Errorf("constant %d - not a function %T",
					i, actual[i])
			}

			err := testInstructions(constant, fn.Instructions)
			if err != nil {
				return fmt.Errorf("constant %d - testInstructions failed: %s",
					i, err)
			}
		}
	}

	return nil
}

func testIntegerObject(expected int64, actual object.Object) error {
	result, ok := actual.(*object.Integer)
	if !ok {
		return fmt.Errorf("object is not Integer. got=%T (%+v)",
			actual, actual)
	}

	if result.Value != expected {
		return fmt.Errorf("object has wrong value. got=%d, want=%d",
			result.Value, expected)
	}

	return nil
}

func testStringObject(expected string, actual object.Object) error {
	result, ok := actual.(*object.String)
	if !ok {
		return fmt.Errorf("object is not String. got=%T (%+v)",
			actual, actual)
	}

	if result.Value != expected {
		return fmt.Errorf("object has wrong value. got=%s, want=%s",
			result.Value, expected)
	}

	return nil
}
