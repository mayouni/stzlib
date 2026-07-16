# stzPyCodeGraph -- PYTHON as a code graph (a peer language on the tree-sitter
# substrate). Inherits the whole query surface (classes, methods, multiple-
# inheritance chains, impact, cascade, call edges, DeadCode, CyclicCalls)
# from stzPolyglotCodeGraph; adds only Python's OWN identity:
#   Language()/FileExtension()  -- "python" / ".py"
#   the INDENTATION FLOOR       -- a self-contained, no-dependency structural
#                                  scan (declaration graph only), the default
#                                  for `new stzPyCodeGraph(path/source)`
#   the PYTHON-ast backend      -- shells to a system Python via async spawn
#                                  (a fallback where the engine grammar isn't
#                                  built; same real parse + call edges)
# The PREFERRED real parse is tree-sitter in the engine (no runtime):
#   StzPyCodeGraphFromSourceTS / StzPyCodeGraphTS (inherited scan).
#
#   oPG = new stzPyCodeGraph("path/to/pkg")     # a dir (indentation floor)
#   oPG = StzPyCodeGraphFromSource(cPySource)   # a source string (floor)
#   oPG = StzPyCodeGraphFromSourceTS(cSource)   # tree-sitter (real parse)
#   ? oPG.OwnersOf("speak")  ? oPG.AncestryOf("Puppy")  ? oPG.Cascade("Animal")

$cStzPyExe = "python"     # override if the interpreter is named differently

func StzPyCodeGraph(pcRootPath)
	return new stzPyCodeGraph(pcRootPath)

func StzPyCodeGraphFromSource(pcSource)
	oG = new stzPyCodeGraph("")
	oG.ScanSource(pcSource, "<source>")
	oG.BuildGraph()
	return oG

func StzPyCodeGraphFromSourceTS(pcSource)
	oG = new stzPyCodeGraph("")
	oG.ScanSourceViaTreeSitter(pcSource, "<source>")
	oG.BuildGraph()
	return oG

func StzPyCodeGraphTS(pcRootPath)
	oG = new stzPyCodeGraph("")
	oG.SetRoot(pcRootPath)
	oG._ScanViaTreeSitter(pcRootPath)
	oG.BuildGraph()
	return oG

# --- the Python-ast backend (needs Python on PATH) ---------------------

func StzPyExe()
	return $cStzPyExe

# Is a usable Python interpreter reachable? (spawn `python --version`.)
func StzPyAstAvailable()
	_oRct_ = new stzReactor()
	_oRct_.Spawn([ StzPyExe(), "--version" ], 5000)
	return _oRct_.SpawnLastStatus() = 0

func StzPyCodeGraphFromSourceAst(pcSource)
	oG = new stzPyCodeGraph("")
	oG.ScanSourceViaAst(pcSource, "<source>")
	oG.BuildGraph()
	return oG

func StzPyCodeGraphAst(pcRootPath)
	oG = new stzPyCodeGraph("")
	oG.SetRoot(pcRootPath)
	oG._ScanViaAst(pcRootPath)
	oG.BuildGraph()
	return oG


class stzPyCodeGraph from stzPolyglotCodeGraph

	# the indentation floor is the default backend for a path/source ctor
	def init(pcRootPath)
		super.init(pcRootPath)
		if pcRootPath != ""
			This._Scan(pcRootPath)
			This.BuildGraph()
		ok

	def Language()
		return "python"

	def FileExtension()
		return ".py"

	#-- the PYTHON-ast backend (real parse + call edges, via async spawn) --

	# Parse one Python source string through Python's real ast; ingest the
	# structured lines it emits. Raises (LAW 3) if Python is unreachable --
	# it never silently degrades to the indentation floor.
	def ScanSourceViaAst(pcSource, pcFile)
		_cDrv_ = tempname()
		_cSrc_ = tempname()
		write(_cDrv_, This._AstDriver())
		write(_cSrc_, "" + pcSource)
		_oR_ = new stzReactor()
		_cOut_ = _oR_.Spawn([ StzPyExe(), _cDrv_, _cSrc_ ], 15000)
		_nStat_ = _oR_.SpawnLastStatus()
		remove(_cDrv_)
		remove(_cSrc_)
		if _nStat_ != 0
			stzraise("Python AST backend failed (exit " + _nStat_ + "). Is '" +
				StzPyExe() + "' on PATH? Use tree-sitter (StzPyCodeGraphFromSourceTS) " +
				"or the indentation floor (new stzPyCodeGraph).")
		ok
		This._IngestAstLines(_cOut_, pcFile)

	def _ScanViaAst(pcPath)
		_aEntries_ = dir(pcPath)
		_nLen_ = len(_aEntries_)
		for _i_ = 1 to _nLen_
			_cName_ = _aEntries_[_i_][1]
			if _aEntries_[_i_][2]
				if _cName_ != "." and _cName_ != ".."
					This._ScanViaAst(pcPath + "/" + _cName_)
				ok
			else
				if StzLower(StzRight(_cName_, 3)) = ".py"
					This.ScanSourceViaAst(read(pcPath + "/" + _cName_),
						pcPath + "/" + _cName_)
				ok
			ok
		next

	# The Python driver, emitted to a temp file and run by the interpreter.
	# Built as an nl-joined list of one-line literals (Ring has no reliable
	# multi-line string); chr(10) inside Python keeps every line quote-safe.
	# Python is indentation-sensitive, so the leading spaces are load-bearing.
	def _AstDriver()
		_a_ = []
		_a_ + 'import ast, sys'
		_a_ + 'src = open(sys.argv[1], "r", encoding="utf-8").read()'
		_a_ + 'try:'
		_a_ + '    tree = ast.parse(src)'
		_a_ + 'except SyntaxError as e:'
		_a_ + '    sys.stdout.write("ERROR|" + str(e).replace("|", " ") + chr(10)); sys.exit(0)'
		_a_ + 'def bn(b):'
		_a_ + '    if isinstance(b, ast.Name): return b.id'
		_a_ + '    if isinstance(b, ast.Attribute):'
		_a_ + '        p = []; c = b'
		_a_ + '        while isinstance(c, ast.Attribute): p.append(c.attr); c = c.value'
		_a_ + '        if isinstance(c, ast.Name): p.append(c.id)'
		_a_ + '        return ".".join(reversed(p))'
		_a_ + '    return None'
		_a_ + 'def cn(n):'
		_a_ + '    f = n.func'
		_a_ + '    if isinstance(f, ast.Name): return f.id'
		_a_ + '    if isinstance(f, ast.Attribute): return f.attr'
		_a_ + '    return None'
		_a_ + 'out = []'
		_a_ + 'class V(ast.NodeVisitor):'
		_a_ + '    def __init__(s): s.cls = []; s.fn = []'
		_a_ + '    def visit_ClassDef(s, n):'
		_a_ + '        bs = [x for x in (bn(b) for b in n.bases) if x]'
		_a_ + '        out.append("CLASS|" + n.name + "|" + ",".join(bs) + "|" + str(n.lineno))'
		_a_ + '        s.cls.append(n.name); s.generic_visit(n); s.cls.pop()'
		_a_ + '    def _f(s, n):'
		_a_ + '        c = s.cls[-1] if s.cls else ""'
		_a_ + '        if c: out.append("METHOD|" + c + "|" + n.name + "|" + str(n.lineno))'
		_a_ + '        elif not s.fn: out.append("FUNC|" + n.name + "|" + str(n.lineno))'
		_a_ + '        s.fn.append(n.name); sv = s.cls; s.cls = []'
		_a_ + '        s.generic_visit(n); s.cls = sv; s.fn.pop()'
		_a_ + '    def visit_FunctionDef(s, n): s._f(n)'
		_a_ + '    def visit_AsyncFunctionDef(s, n): s._f(n)'
		_a_ + '    def visit_Import(s, n):'
		_a_ + '        for a in n.names: out.append("IMPORT|" + a.name)'
		_a_ + '    def visit_ImportFrom(s, n):'
		_a_ + '        if n.module: out.append("IMPORT|" + n.module)'
		_a_ + '        s.generic_visit(n)'
		_a_ + '    def visit_Call(s, n):'
		_a_ + '        c = cn(n)'
		_a_ + '        if c: out.append("CALL|" + (s.fn[-1] if s.fn else "") + "|" + c)'
		_a_ + '        s.generic_visit(n)'
		_a_ + 'V().visit(tree)'
		_a_ + 'sys.stdout.write(chr(10).join(out) + chr(10))'
		return JoinXT(_a_, nl)

	#-- the INDENTATION FLOOR (self-contained, no dependency) --------------
	# 'class Name(Bases):' opens a scope, 'def'/'async def' lines more
	# indented than the class header are its methods, defs at column 0 are
	# module functions, 'import'/'from x import' are dependency edges.
	# Handles MULTIPLE INHERITANCE. Declaration graph only (no call edges).

	def _Scan(pcPath)
		_aEntries_ = dir(pcPath)
		_nLen_ = len(_aEntries_)
		for _i_ = 1 to _nLen_
			_cName_ = _aEntries_[_i_][1]
			if _aEntries_[_i_][2]    # a folder
				if _cName_ != "." and _cName_ != ".."
					This._Scan(pcPath + "/" + _cName_)
				ok
			else
				if StzLower(StzRight(_cName_, 3)) = ".py"
					This.ScanSource(read(pcPath + "/" + _cName_), pcPath + "/" + _cName_)
				ok
			ok
		next

	def ScanSource(pcSource, pcFile)
		_acLines_ = StzSplit(StzReplace("" + pcSource, char(13), ""), char(10))
		_nLen_ = len(_acLines_)
		_cCurClass_ = ""
		_nClassIndent_ = -1
		for _i_ = 1 to _nLen_
			_cRaw_ = StzReplace(_acLines_[_i_], char(9), "    ")   # tab -> 4 sp
			_cL_ = ring_trim(_cRaw_)
			if _cL_ = "" or StzLeft(_cL_, 1) = "#"
				loop   # blank / comment: does not close a class scope
			ok
			_nIndent_ = This._IndentOf(_cRaw_)

			# a line at or below the class header indent closes the scope
			if _cCurClass_ != "" and _nIndent_ <= _nClassIndent_
				_cCurClass_ = ""
				_nClassIndent_ = -1
			ok

			if StzLower(StzLeft(_cL_, 6)) = "class "
				_aCls_ = This._ParseClassHeader(_cL_)
				if _aCls_[1] != ""
					@acClasses + [ _aCls_[1], _aCls_[2], pcFile ]
					_cCurClass_ = _aCls_[1]
					_nClassIndent_ = _nIndent_
				ok
			but This._IsDef(_cL_)
				_cM_ = This._DefName(_cL_)
				if _cM_ != ""
					if _cCurClass_ != "" and _nIndent_ > _nClassIndent_
						@aMethods + [ _cCurClass_, _cM_, pcFile, _i_ ]
					but _nIndent_ = 0
						@aFunctions + [ _cM_, pcFile, _i_ ]
					ok
				ok
			but StzLower(StzLeft(_cL_, 7)) = "import "
				This._RecordImports(StzMidToEnd(_cL_, 8), pcFile)
			but StzLower(StzLeft(_cL_, 5)) = "from "
				_nImp_ = StzFind(" import ", _cL_)
				if len(_nImp_) > 0
					_cMod_ = ring_trim(This._Slice(_cL_, 6, _nImp_[1] - 1))
					@aImports + [ pcFile, _cMod_ ]
				ok
			ok
		next

	def _IndentOf(pcRaw)
		_n_ = 0
		_nLen_ = len(pcRaw)
		for _k_ = 1 to _nLen_
			if pcRaw[_k_] = " "
				_n_++
			else
				exit
			ok
		next
		return _n_

	def _IsDef(pcTrimmed)
		if StzLower(StzLeft(pcTrimmed, 4)) = "def "
			return TRUE
		ok
		if StzLower(StzLeft(pcTrimmed, 10)) = "async def "
			return TRUE
		ok
		return FALSE

	def _DefName(pcTrimmed)
		_cD_ = pcTrimmed
		if StzLower(StzLeft(_cD_, 6)) = "async "
			_cD_ = ring_trim(StzMidToEnd(_cD_, 7))
		ok
		_cD_ = ring_trim(StzMidToEnd(_cD_, 5))   # after "def "
		_nP_ = StzFind("(", _cD_)
		if len(_nP_) = 0
			return ""
		ok
		return ring_trim(This._Slice(_cD_, 1, _nP_[1] - 1))

	# 'class Name(A, B):' -> [ "Name", [ "A", "B" ] ]; 'class Name:' -> [Name,[]]
	def _ParseClassHeader(pcTrimmed)
		_cRest_ = ring_trim(StzMidToEnd(pcTrimmed, 7))   # after "class "
		_cName_ = ""
		_aBases_ = []
		_nP_ = StzFind("(", _cRest_)
		if len(_nP_) > 0
			_cName_ = ring_trim(This._Slice(_cRest_, 1, _nP_[1] - 1))
			_nC_ = StzFind(")", _cRest_)
			if len(_nC_) > 0
				_cInside_ = This._Slice(_cRest_, _nP_[1] + 1, _nC_[1] - 1)
				_acB_ = StzSplit(_cInside_, ",")
				_nB_ = len(_acB_)
				for _b_ = 1 to _nB_
					_cB_ = ring_trim(_acB_[_b_])
					# skip keyword bases like metaclass=... and empty
					if _cB_ != "" and len(StzFind("=", _cB_)) = 0
						_aBases_ + _cB_
					ok
				next
			ok
		else
			# 'class Name:' -- strip a trailing colon
			_cName_ = ring_trim(StzReplace(_cRest_, ":", ""))
		ok
		return [ _cName_, _aBases_ ]

	def _RecordImports(pcRest, pcFile)
		# 'import a, b.c as x' -> modules a and b.c
		_acP_ = StzSplit(pcRest, ",")
		_nLen_ = len(_acP_)
		for _p_ = 1 to _nLen_
			_cItem_ = ring_trim(_acP_[_p_])
			_nAs_ = StzFind(" as ", _cItem_)
			if len(_nAs_) > 0
				_cItem_ = ring_trim(This._Slice(_cItem_, 1, _nAs_[1] - 1))
			ok
			if _cItem_ != ""
				@aImports + [ pcFile, _cItem_ ]
			ok
		next
