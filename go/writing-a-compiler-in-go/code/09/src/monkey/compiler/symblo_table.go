package compiler

type SymbolScope string

const (
	LocalScope    SymbolScope = "LOCAL"
	GlobalScope   SymbolScope = "GLOBAL"
	BuiltinScope  SymbolScope = "BUILTIN"
	FreeScope     SymbolScope = "FREE"
	FunctionScope SymbolScope = "FUNCTION"
)

type Symbol struct {
	Name  string
	Scope SymbolScope
	Index int
}

type SymbolTable struct {
	Outer          *SymbolTable
	store          map[string]Symbol
	numDefinitions int
	FreeSymbols    []Symbol
}

func NewSymbolTable() *SymbolTable {
	s := make(map[string]Symbol)
	free := []Symbol{}
	return &SymbolTable{
		store:       s,
		FreeSymbols: free,
	}
}

// 新的SymbolTable 給定Outer 為s
func NewEnclosedSymbolTable(outer *SymbolTable) *SymbolTable {
	s := NewSymbolTable()
	s.Outer = outer
	return s
}

func (s *SymbolTable) Define(name string) Symbol {
	symbol := Symbol{Name: name, Index: s.numDefinitions, Scope: GlobalScope}

	//如果有Outer SymbolTable
	if s.Outer == nil {
		//沒有則為Global
		symbol.Scope = GlobalScope
	} else {
		//有的話 則為Local
		symbol.Scope = LocalScope
	}

	s.store[name] = symbol
	s.numDefinitions++
	return symbol
}

// 定義函數名稱
func (s *SymbolTable) DefineFunctionName(name string) Symbol {
	symbol := Symbol{Name: name, Index: 0, Scope: FunctionScope}
	s.store[name] = symbol
	return symbol
}

// 把原先的symbol包裝成freescope
// 封閉作用域的局部變數 = 自由變數
func (s *SymbolTable) defineFree(original Symbol) Symbol {
	s.FreeSymbols = append(s.FreeSymbols, original)

	symbol := Symbol{Name: original.Name, Index: len(s.FreeSymbols) - 1}
	symbol.Scope = FreeScope

	s.store[original.Name] = symbol

	return symbol
}

func (s *SymbolTable) DefineBuiltin(index int, name string) Symbol {
	symbol := Symbol{Name: name, Index: index, Scope: BuiltinScope}
	s.store[name] = symbol
	return symbol
}

func (s *SymbolTable) Resolve(name string) (Symbol, bool) {
	obj, ok := s.store[name]

	//如果我這個Scope找不到 && 有outer scope
	if !ok && s.Outer != nil {
		//往outer scope找找看有沒有變數
		//遞迴
		obj, ok := s.Outer.Resolve(name)
		//外部找不到
		if !ok {
			return obj, ok
		}

		//如果是全域或內置函數的範圍
		if obj.Scope == GlobalScope || obj.Scope == BuiltinScope {
			return obj, ok
		}

		//封閉作用域內的局部變數 = 自由變數
		free := s.defineFree(obj)
		return free, true
	}

	return obj, ok
}
