# Polyglot code-graph -- JavaScript (the tree-sitter substrate, 2nd language).
#
# Proves the substrate: the whole query surface of stzPyCodeGraph (classes,
# methods, inheritance, impact, cascade, call edges, DeadCode, CyclicCalls)
# is language-agnostic once the source is parsed to the shared line protocol.
# So stzJsCodeGraph INHERITS all of it and overrides only the parse entry --
# calling the engine's tree-sitter JavaScript grammar (no Node runtime).
#
#   oJG = StzJsCodeGraphFromSourceTS(cJsSource)   # a source string
#   oJG = StzJsCodeGraphTS("path/to/pkg")         # a directory of .js
#   ? oJG.OwnersOf("run")   ? oJG.AncestryOf("Worker")   ? oJG.CyclicCalls()

func StzJsCodeGraphFromSourceTS(pcSource)
	oG = new stzJsCodeGraph("")
	oG.ScanSourceViaTreeSitterJs(pcSource, "<source>")
	oG.BuildGraph()
	return oG

func StzJsCodeGraphTS(pcRootPath)
	oG = new stzJsCodeGraph("")
	oG.SetRoot(pcRootPath)
	oG._ScanJsDir(pcRootPath)
	oG.BuildGraph()
	return oG

class stzJsCodeGraph from stzPyCodeGraph

	# Parse JS via the vendored tree-sitter grammar in the engine (no Node).
	# Same line protocol as every language -> inherited _IngestAstLines.
	def ScanSourceViaTreeSitterJs(pcSource, pcFile)
		if $pStzPolyglotHandle = NULL
			stzraise("The tree-sitter engine (stz_polyglot.dll) is not loaded. Build the engine with: zig build -Dring=D:/ring127.")
		ok
		This._IngestAstLines(StzEnginePolyglotParse("javascript", "" + pcSource), pcFile)

	def _ScanJsDir(pcPath)
		_aEntries_ = dir(pcPath)
		_nLen_ = len(_aEntries_)
		for _i_ = 1 to _nLen_
			_cName_ = _aEntries_[_i_][1]
			if _aEntries_[_i_][2]
				if _cName_ != "." and _cName_ != ".."
					This._ScanJsDir(pcPath + "/" + _cName_)
				ok
			else
				if StzLower(StzRight(_cName_, 3)) = ".js"
					This.ScanSourceViaTreeSitterJs(read(pcPath + "/" + _cName_),
						pcPath + "/" + _cName_)
				ok
			ok
		next
