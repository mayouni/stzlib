# stzCodeGraph -- THE CODE GRAPH, POLYGLOT BY ESSENCE
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.1/5.8: source truth becomes nodes
#  and edges; the family head for code-graphing ANY language.)
#
# A code graph is language-agnostic once source is parsed to the shared line
# protocol (CLASS|/METHOD|/FUNC|/IMPORT|/CALL|). This head owns the model,
# the ingestion, the graph build, and EVERY query -- classes, methods,
# multiple-inheritance chains, impact, cascade, call edges, DeadCode,
# CyclicCalls -- plus the generic tree-sitter scan. Each LANGUAGE is a PEER
# subclass (stzRingCodeGraph, stzPyCodeGraph, stzJsCodeGraph -- Ring is just
# one language among them) that keeps its own identity and declares:
#     def Language()       -> the parser/grammar token ("ring"|"python"|...)
#     def FileExtension()  -> the source extension for directory scans (".py")
# ...plus any language-specific backend it owns (Ring's source-truth parser,
# Python's indentation floor, etc.). So the languages are siblings, never one
# under another; the shared query surface lives here, once.

# Is the vendored tree-sitter engine grammar loaded (stz_polyglot.dll)?
func StzTreeSitterAvailable()
	return $pStzPolyglotHandle != NULL

class stzCodeGraph from stzObject

	@oGraph = NULL       # class nodes + :inherits edges (stzGraph)
	@aMethods = []       # [ class, method, file, line ]
	@acClasses = []      # [ class, [parents], file ]   (multiple inheritance)
	@aFunctions = []     # [ function, file, line ]     (module-level)
	@aImports = []       # [ file, module ]
	@aCalls = []         # [ callerFunc, callee ]        (real-parse backends)
	@bHasCalls = FALSE   # TRUE once real CALL edges are ingested
	@cRoot = ""

	def init(pcRootPath)
		@cRoot = pcRootPath
		@oGraph = new stzGraph("codegraph")
		@aMethods = []
		@acClasses = []
		@aFunctions = []
		@aImports = []
		@aCalls = []
		@bHasCalls = FALSE

	def SetRoot(pcPath)
		@cRoot = pcPath

	#-- language identity (subclasses override) ---------------------------

	def Language()
		stzraise("stzCodeGraph is abstract for parsing -- use a language subclass (stzRingCodeGraph / stzPyCodeGraph / stzJsCodeGraph) that defines Language().")

	def FileExtension()
		return ""

	#-- tree-sitter scanning (real parse in the engine, no runtime) --------

	# Parse one source string via the vendored tree-sitter grammar for THIS
	# language; ingest the shared line protocol it emits.
	def ScanSourceViaTreeSitter(pcSource, pcFile)
		if $pStzPolyglotHandle = NULL
			stzraise("The tree-sitter engine (stz_polyglot.dll) is not loaded. Build the engine with: zig build -Dring=D:/ring127.")
		ok
		This._IngestAstLines(StzEnginePolyglotParse(This.Language(), "" + pcSource), pcFile)

	def _ScanViaTreeSitter(pcPath)
		_cExt_ = This.FileExtension()
		_nE_ = len(_cExt_)
		_aEntries_ = dir(pcPath)
		_nLen_ = len(_aEntries_)
		for _i_ = 1 to _nLen_
			_cName_ = _aEntries_[_i_][1]
			if _aEntries_[_i_][2]
				if _cName_ != "." and _cName_ != ".."
					This._ScanViaTreeSitter(pcPath + "/" + _cName_)
				ok
			else
				if _nE_ > 0 and StzLower(StzRight(_cName_, _nE_)) = _cExt_
					This.ScanSourceViaTreeSitter(read(pcPath + "/" + _cName_),
						pcPath + "/" + _cName_)
				ok
			ok
		next

	#-- ingestion of the shared line protocol -----------------------------

	def _IngestAstLines(pcOut, pcFile)
		_acLines_ = StzSplit(StzReplace("" + pcOut, char(13), ""), char(10))
		_nLen_ = len(_acLines_)
		for _i_ = 1 to _nLen_
			_cL_ = ring_trim(_acLines_[_i_])
			if _cL_ = ""
				loop
			ok
			_aP_ = StzSplit(_cL_, "|")
			_cKind_ = _aP_[1]
			if _cKind_ = "CLASS"
				_aBases_ = []
				if len(_aP_) >= 3 and _aP_[3] != ""
					_aBases_ = StzSplit(_aP_[3], ",")
				ok
				@acClasses + [ _aP_[2], _aBases_, pcFile ]
			but _cKind_ = "METHOD"
				@aMethods + [ _aP_[2], _aP_[3], pcFile, number(_aP_[4]) ]
			but _cKind_ = "FUNC"
				@aFunctions + [ _aP_[2], pcFile, number(_aP_[3]) ]
			but _cKind_ = "IMPORT"
				@aImports + [ pcFile, _aP_[2] ]
			but _cKind_ = "CALL"
				@aCalls + [ _aP_[2], _aP_[3] ]
				@bHasCalls = TRUE
			but _cKind_ = "ERROR"
				stzraise("The source could not be parsed: " + _aP_[2])
			ok
		next

	def BuildGraph()
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if NOT @oGraph.NodeExists(@acClasses[_i_][1])
				@oGraph.AddNode(@acClasses[_i_][1])
			ok
		next
		for _i_ = 1 to _nLen_
			_aParents_ = @acClasses[_i_][2]
			_nP_ = len(_aParents_)
			for _p_ = 1 to _nP_
				_cParent_ = _aParents_[_p_]
				if NOT @oGraph.NodeExists(_cParent_)
					@oGraph.AddNode(_cParent_)
				ok
				if NOT @oGraph.EdgeExists(@acClasses[_i_][1], _cParent_)
					@oGraph.AddEdgeXTT(@acClasses[_i_][1], _cParent_,
						"inherits", [ :type = "inherits" ])
				ok
			next
		next

	#-- structure queries -------------------------------------------------

	def GraphQ()
		return @oGraph

	def Classes()
		_acOut_ = []
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			_acOut_ + @acClasses[_i_][1]
		next
		return _acOut_

	def NumberOfClasses()
		return len(@acClasses)

	def NumberOfMethods()
		return len(@aMethods)

	def Functions()
		_acOut_ = []
		_nLen_ = len(@aFunctions)
		for _i_ = 1 to _nLen_
			_acOut_ + @aFunctions[_i_][1]
		next
		return _acOut_

	def NumberOfFunctions()
		return len(@aFunctions)

	def MethodsOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_acOut_ = []
		_nLen_ = len(@aMethods)
		for _i_ = 1 to _nLen_
			if StzLower(@aMethods[_i_][1]) = _cC_
				_acOut_ + @aMethods[_i_][2]
			ok
		next
		return _acOut_

	# Every method as [ class, method, line ] -- the locus a code RULE needs
	# (MethodsOf gives names only). @aMethods is [ class, method, file, line ].
	def MethodsWithLines()
		_aOut_ = []
		_nLen_ = len(@aMethods)
		for _i_ = 1 to _nLen_
			_aOut_ + [ @aMethods[_i_][1], @aMethods[_i_][2], @aMethods[_i_][4] ]
		next
		return _aOut_

	# Every module-level function as [ function, line ].
	def FunctionsWithLines()
		_aOut_ = []
		_nLen_ = len(@aFunctions)
		for _i_ = 1 to _nLen_
			_aOut_ + [ @aFunctions[_i_][1], @aFunctions[_i_][3] ]
		next
		return _aOut_

	# every class that DEFINES this method
	def OwnersOf(pcMethod)
		_cM_ = StzLower("" + pcMethod)
		_acOut_ = []
		_nLen_ = len(@aMethods)
		for _i_ = 1 to _nLen_
			if StzLower(@aMethods[_i_][2]) = _cM_
				if ring_find(_acOut_, @aMethods[_i_][1]) = 0
					_acOut_ + @aMethods[_i_][1]
				ok
			ok
		next
		return _acOut_

	def ParentsOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][1]) = _cC_
				return @acClasses[_i_][2]
			ok
		next
		return []

	# convenience: the FIRST parent (single-inheritance languages, or the
	# MRO spine of a multiple-inheritance one), "" if none.
	def ParentOf(pcClass)
		_aP_ = This.ParentsOf(pcClass)
		if len(_aP_) > 0
			return _aP_[1]
		ok
		return ""

	def FileOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][1]) = _cC_
				return @acClasses[_i_][3]
			ok
		next
		return ""

	def ImportsOf(pcFile)
		_acOut_ = []
		_nLen_ = len(@aImports)
		for _i_ = 1 to _nLen_
			if @aImports[_i_][1] = pcFile
				_acOut_ + @aImports[_i_][2]
			ok
		next
		return _acOut_

	def NumberOfImports()
		return len(@aImports)

	# the inheritance chain up to a root, following the FIRST base (the MRO
	# spine); multiple bases are visited by DescendantsOf/ImpactOf.
	def AncestryOf(pcClass)
		_acChain_ = [ "" + pcClass ]
		_cCur_ = "" + pcClass
		_nGuard_ = 0
		while _nGuard_ < 40
			_nGuard_++
			_aP_ = This.ParentsOf(_cCur_)
			if len(_aP_) = 0  exit  ok
			_cUp_ = _aP_[1]
			if _cUp_ = "" or ring_find(_acChain_, _cUp_) > 0  exit  ok
			_acChain_ + _cUp_
			_cCur_ = _cUp_
		end
		return _acChain_

	def SubclassesOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_acOut_ = []
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			_aP_ = @acClasses[_i_][2]
			_nP_ = len(_aP_)
			for _p_ = 1 to _nP_
				if StzLower(_aP_[_p_]) = _cC_
					_acOut_ + @acClasses[_i_][1]
				ok
			next
		next
		return _acOut_

	def DescendantsOf(pcClass)
		_acOut_ = []
		_acFront_ = [ "" + pcClass ]
		_nGuard_ = 0
		while len(_acFront_) > 0 and _nGuard_ < 40
			_nGuard_++
			_acNext_ = []
			_nF_ = len(_acFront_)
			for _f_ = 1 to _nF_
				_acSubs_ = This.SubclassesOf(_acFront_[_f_])
				_nS_ = len(_acSubs_)
				for _s_ = 1 to _nS_
					if ring_find(_acOut_, _acSubs_[_s_]) = 0
						_acOut_ + _acSubs_[_s_]
						_acNext_ + _acSubs_[_s_]
					ok
				next
			next
			_acFront_ = _acNext_
		end
		return _acOut_

	# IMPACT: classes defining the method + every descendant that INHERITS
	# it (does not redefine).
	def ImpactOf(pcMethod)
		_acOwners_ = This.OwnersOf(pcMethod)
		_acInherited_ = []
		_nO_ = len(_acOwners_)
		for _i_ = 1 to _nO_
			_acDesc_ = This.DescendantsOf(_acOwners_[_i_])
			_nD_ = len(_acDesc_)
			for _j_ = 1 to _nD_
				if ring_find(_acOwners_, _acDesc_[_j_]) = 0 and
				   ring_find(_acInherited_, _acDesc_[_j_]) = 0
					if ring_find(This.MethodsOf(_acDesc_[_j_]), pcMethod) = 0
						_acInherited_ + _acDesc_[_j_]
					ok
				ok
			next
		next
		return [ :owners = _acOwners_, :inheritedBy = _acInherited_ ]

	def Cascade(pcClass)
		_acDesc_ = This.DescendantsOf(pcClass)
		return [
			:class = "" + pcClass,
			:methodsTouched = len(This.MethodsOf(pcClass)),
			:descendants = _acDesc_,
			:blastRadius = len(_acDesc_)
		]

	#-- CALL edges (present only with a real-parse backend) ---------------

	def HasCallEdges()
		return @bHasCalls

	def CallEdges()
		return @aCalls

	def CallersOf(pcCallee)
		_cC_ = StzLower("" + pcCallee)
		_ac_ = []
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			if StzLower(@aCalls[_i_][2]) = _cC_
				if @aCalls[_i_][1] != "" and ring_find(_ac_, @aCalls[_i_][1]) = 0
					_ac_ + @aCalls[_i_][1]
				ok
			ok
		next
		return _ac_

	def CalleesOf(pcCaller)
		_cC_ = StzLower("" + pcCaller)
		_ac_ = []
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			if StzLower(@aCalls[_i_][1]) = _cC_
				if ring_find(_ac_, @aCalls[_i_][2]) = 0
					_ac_ + @aCalls[_i_][2]
				ok
			ok
		next
		return _ac_

	def _AllDefinedNames()
		_ac_ = []
		_n_ = len(@aFunctions)
		for _i_ = 1 to _n_
			if ring_find(_ac_, @aFunctions[_i_][1]) = 0
				_ac_ + @aFunctions[_i_][1]
			ok
		next
		_n_ = len(@aMethods)
		for _i_ = 1 to _n_
			if ring_find(_ac_, @aMethods[_i_][2]) = 0
				_ac_ + @aMethods[_i_][2]
			ok
		next
		return _ac_

	# every DEFINED function/method that NO recorded call reaches (a dead-code
	# candidate). dunder methods are runtime entry points, never dead. Name-
	# based over the call edges -- honest about dynamic dispatch (a call
	# through a variable can't be seen), so it names candidates, not proof.
	def DeadCode()
		if NOT @bHasCalls
			stzraise("DeadCode() needs CALL edges -- use a real-parse backend (tree-sitter / ...FromSourceTS). A declaration-only graph has no call edges; refusing rather than guessing (LAW 3).")
		ok
		_aDefs_ = This._AllDefinedNames()
		_acDead_ = []
		_nD_ = len(_aDefs_)
		for _i_ = 1 to _nD_
			_cName_ = _aDefs_[_i_]
			if StzLeft(_cName_, 2) = "__"
				loop
			ok
			if len(This.CallersOf(_cName_)) = 0
				if ring_find(_acDead_, _cName_) = 0
					_acDead_ + _cName_
				ok
			ok
		next
		return _acDead_

	# every DEFINED function/method that can reach ITSELF through >=1 call
	# (i.e. participates in a call cycle, direct or indirect recursion).
	def CyclicCalls()
		if NOT @bHasCalls
			stzraise("CyclicCalls() needs CALL edges -- use a real-parse backend (tree-sitter / ...FromSourceTS). Refusing rather than guessing (LAW 3).")
		ok
		_aDefs_ = This._AllDefinedNames()
		_acCyclic_ = []
		_nD_ = len(_aDefs_)
		for _i_ = 1 to _nD_
			if This._Reaches(_aDefs_[_i_], _aDefs_[_i_])
				_acCyclic_ + _aDefs_[_i_]
			ok
		next
		return _acCyclic_

	# can pcFrom reach pcTarget through >= 1 call edge? (BFS over callees)
	def _Reaches(pcFrom, pcTarget)
		_cTgt_ = StzLower("" + pcTarget)
		_acSeen_ = []
		_acFront_ = This.CalleesOf(pcFrom)
		_nGuard_ = 0
		while len(_acFront_) > 0 and _nGuard_ < 2000
			_nGuard_++
			_acNext_ = []
			_nF_ = len(_acFront_)
			for _f_ = 1 to _nF_
				_cN_ = _acFront_[_f_]
				if StzLower(_cN_) = _cTgt_
					return TRUE
				ok
				if ring_find(_acSeen_, _cN_) = 0
					_acSeen_ + _cN_
					_acCallees_ = This.CalleesOf(_cN_)
					_nC_ = len(_acCallees_)
					for _c_ = 1 to _nC_
						_acNext_ + _acCallees_[_c_]
					next
				ok
			next
			_acFront_ = _acNext_
		end
		return FALSE

	def Stats()
		return [
			:root = @cRoot,
			:language = This.Language(),
			:classes = len(@acClasses),
			:methods = len(@aMethods),
			:functions = len(@aFunctions),
			:imports = len(@aImports),
			:inheritsEdges = @oGraph.EdgeCount()
		]

	#-- internals ---------------------------------------------------------

	def _Slice(pcS, nA, nB)
		if nB < nA  return ""  ok
		return StzMid(pcS, nA, nB - nA + 1)
