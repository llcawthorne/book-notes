package object

import (
	"fmt"
)

var Builtins = []struct {
	Name    string
	Builtin *Builtin
}{
	{
		"len",
		&Builtin{
			Fn: func(args ...Object) Object {
				if len(args) != 1 {
					return newError("wrong number of arguments. got=%d, want=1",
						len(args))
				}

				//取出第一個arg參數
				switch arg := args[0].(type) {
				//添加array
				case *Array:
					return &Integer{Value: int64(len(arg.Elements))}
				case *String:
					//如果是string則回傳長度
					return &Integer{Value: int64(len(arg.Value))}
				default:
					//其他型態不支援
					return newError("argument to `len` not supported, got %s",
						args[0].Type())
				}
			},
		},
	},
	{
		"puts",
		&Builtin{
			Fn: func(args ...Object) Object {
				//分行印出
				for _, arg := range args {
					fmt.Println(arg.Inspect())
				}
				//回傳NULL
				return nil
			},
		},
	},
	{
		"first",
		&Builtin{
			Fn: func(args ...Object) Object {
				if len(args) != 1 {
					return newError("wrong number of arguments. got=%d, want=1",
						len(args))
				}

				//他的type要是array
				if args[0].Type() != ARRAY_OBJ {
					return newError("argument to `first` must be ARRAY, got %s",
						args[0].Type())
				}

				arr := args[0].(*Array)
				if len(arr.Elements) > 0 {
					return arr.Elements[0]
				}

				//改
				return nil
			},
		},
	},
	{
		"last",
		&Builtin{
			Fn: func(args ...Object) Object {
				if len(args) != 1 {
					return newError("wrong number of arguments. got=%d, want=1",
						len(args))
				}

				//他的type要是array
				if args[0].Type() != ARRAY_OBJ {
					return newError("argument to `last` must be ARRAY, got %s",
						args[0].Type())
				}

				arr := args[0].(*Array)
				length := len(arr.Elements)
				if length > 0 {
					//取出最後一個
					return arr.Elements[length-1]
				}

				//改
				return nil
			},
		},
	},
	{
		"rest",
		&Builtin{
			Fn: func(args ...Object) Object {
				if len(args) != 1 {
					return newError("wrong number of arguments. got=%d, want=1",
						len(args))
				}

				//他的type要是array
				if args[0].Type() != ARRAY_OBJ {
					return newError("argument to `rest` must be ARRAY, got %s",
						args[0].Type())
				}

				arr := args[0].(*Array)
				length := len(arr.Elements)
				if length > 0 {
					//建立一個新array
					newElements := make([]Object, length-1, length-1)
					//只copy 第一個到後面
					copy(newElements, arr.Elements[1:length])
					return &Array{Elements: newElements}
				}

				//改
				return nil
			},
		},
	},
	{
		"push",
		&Builtin{
			Fn: func(args ...Object) Object {
				if len(args) != 2 {
					return newError("wrong number of arguments. got=%d, want=1",
						len(args))
				}

				//他的type要是array
				if args[0].Type() != ARRAY_OBJ {
					return newError("argument to `push` must be ARRAY, got %s",
						args[0].Type())
				}

				arr := args[0].(*Array)
				length := len(arr.Elements)

				//建立一個新array
				newElements := make([]Object, length+1, length+1)
				//copy一個新的array
				copy(newElements, arr.Elements)
				//把新的元素推到新copy array的最後一個
				newElements[length] = args[1]
				//回傳
				return &Array{Elements: newElements}
			},
		},
	},
}

func newError(format string, a ...interface{}) *Error {
	return &Error{Message: fmt.Sprintf(format, a...)}
}

func GetBuiltinByName(name string) *Builtin {
	for _, def := range Builtins {
		if def.Name == name {
			return def.Builtin
		}
	}
	return nil
}
