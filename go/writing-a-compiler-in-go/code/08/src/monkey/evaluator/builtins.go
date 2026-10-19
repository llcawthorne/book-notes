package evaluator

import (
	"monkey/object"
)

var builtins = map[string]*object.Builtin{
	//內置len函數
	"len": object.GetBuiltinByName("len"),
	//內置puts
	"puts": object.GetBuiltinByName("puts"),
	//內置first
	"first": object.GetBuiltinByName("first"),
	//內置last
	"last": object.GetBuiltinByName("last"),
	//內置rest
	"rest": object.GetBuiltinByName("rest"),
	//內置push
	"push": object.GetBuiltinByName("push"),
}
