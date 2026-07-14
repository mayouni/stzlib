# R6 (polyglot refinement) -- stzPyCodeGraph: PYTHON STRUCTURE AS A GRAPH
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.8 polyglot refinement: the
#  code-graph, one language over.) The polyglot sibling of stzCodeGraph:
#  same query surface (classes, methods, inheritance, impact, cascade)
#  over PYTHON source, so cross-language impact analysis and refinement
#  reasoning work on a Python codebase too.
#
#   oPG = new stzPyCodeGraph("path/to/pkg")     # a dir, or...
#   oPG = StzPyCodeGraphFromSource(cPySource)   # ...a single source string
#   ? oPG.OwnersOf("speak")        # every class defining speak()
#   ? oPG.AncestryOf("Puppy")      # Puppy -> Dog -> Animal
#   ? oPG.ImpactOf("speak")        # owners + descendants that inherit it
#   ? oPG.Cascade("Animal")        # the blast radius of touching it
#   ? oPG.ImportsOf(cFile)         # module dependencies
#
# PARSER: an INDENTATION-AWARE structural scan (Python has no braces) --
# 'class Name(Bases):' opens a scope, 'def'/'async def' lines more
# indented than the class header are its methods, defs at column 0 are
# module functions, 'import'/'from x import' are dependency edges.
# Handles MULTIPLE INHERITANCE (class C(A, B)). This is the DECLARATION
# graph (defines/inherits/imports); CALL edges (who-calls-whom) need
# full-body parsing and are refused loudly, never faked (LAW 3).
#
# NOTE: a richer backend that shells to Python's real `ast` module is
# the natural extension once async spawn lands (roadmap) -- this floor
# is self-contained and deterministic so tests never need Python.

func StzPyCodeGraph(pcRootPath)
	return new stzPyCodeGraph(pcRootPath)

func StzPyCodeGraphFromSource(pcSource)
	oG = new stzPyCodeGraph("")
	oG.ScanSource(pcSource, "<source>")
	oG.BuildGraph()
	return oG

class stzPyCodeGraph from stzObject

	@oGraph = NULL       # class nodes + :inherits edges (stzGraph)
	@aMethods = []       # [ class, method, file, line ]
	@acClasses = []      # [ class, [parents], file ]
	@aFunctions = []     # [ function, file, line ]  (module-level)
	@aImports = []       # [ file, module ]
	@cRoot = ""

	def init(pcRootPath)
		@cRoot = pcRootPath
		@oGraph = new stzGraph("pycodegraph")
		if pcRootPath != ""
			This._Scan(pcRootPath)
			This.BuildGraph()
		ok

	#-- scanning ----------------------------------------------------------

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

	# Parse one Python source string. Indentation-aware: the class scope
	# holds while lines are more-indented than the class header.
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

	def Graph()
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

	# the inheritance chain up to a root, following the FIRST base (Python
	# MRO's spine); multiple bases are visited by DescendantsOf/ImpactOf.
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

	# IMPACT: classes defining the method + every descendant that
	# INHERITS it (does not redefine).
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
					# only if this descendant does NOT itself redefine it
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

	# refused loudly until CALL edges land (needs full-body parsing)
	def DeadCode()
		stzraise("DeadCode() needs CALL edges (full-body/ast parsing) -- the declaration graph only has defines/inherits/imports. Refusing rather than guessing (LAW 3).")

	def CyclicCalls()
		stzraise("CyclicCalls() needs CALL edges (full-body/ast parsing) -- refusing rather than guessing (LAW 3).")

	def Stats()
		return [
			:root = @cRoot,
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
