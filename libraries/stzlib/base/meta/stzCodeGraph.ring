# R2 -- stzCodeGraph: THE LIBRARY'S STRUCTURE AS A GRAPH
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.1 latent -> R2: the harvested
#  corpus becomes NODES and EDGES instead of flat records.)
#
# Built from SOURCE TRUTH: the scanner walks the .ring files, reads the
# class declarations (nodes + :inherits edges on a real stzGraph) and
# the method definitions (a fast flat registry: [class, method, file,
# line]). Queries answer over STRUCTURE:
#
#   oCG = new stzCodeGraph("D:/GitHub/stzlib/libraries/stzlib/base")
#   ? oCG.OwnersOf("Uppercase")      # every class defining it
#   ? oCG.AncestryOf("stzString")    # ... -> stzObject
#   ? oCG.ImpactOf("Trimmed")        # owners + subclasses that inherit it
#   ? oCG.Cascade("stzObject")       # the blast radius of touching it
#
# The DECLARATION graph (defines/inherits) is joined by a CALL graph built
# from method-body parsing: CallEdges/CallersOf/CalleesOf, and DeadCode()/
# CyclicCalls(). HONESTY: the call graph is NAME-BASED -- an edge is "a
# method body calls SOME method of this name", not a type-resolved target
# (no receiver-type inference). So DeadCode() is scoped to PRIVATE helpers
# (only ever called internally) whose name is unreferenced, and CyclicCalls()
# to intra-class MUTUAL RECURSION -- the high-confidence signals a name-based
# graph can assert without guessing. String literals + comments are stripped
# before parsing so "Foo(" in a message is never a call.

class stzCodeGraph from stzObject

	@oGraph = NULL       # class nodes + :inherits edges (stzGraph)
	@aMethods = []       # [ [ class, method, file, line ] ... ]
	@acClasses = []      # [ [ class, parent, file ] ... ]
	@cRoot = ""
	# CALL edges (name-based -- see the HONESTY note): who calls whom
	@aRawCalls = []      # [ callerClass, callerMethod, candidateName ] pre-resolve
	@aCalls = []         # [ callerClass, callerMethod, calleeName ] (known methods only)
	@acMethodNames = []  # unique lowercase method names (resolution set)
	@acCalleeNames = []  # unique lowercase names that ARE called (for DeadCode)

	def init(pcRootPath)
		@cRoot = pcRootPath
		@oGraph = new stzGraph("codegraph")
		This._Scan(pcRootPath)
		This._BuildGraph()
		This._ResolveCalls()

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
				if StzLower(StzRight(_cName_, 5)) = ".ring"
					This._ScanFile(pcPath + "/" + _cName_)
				ok
			ok
		next

	def _ScanFile(pcFile)
		_cContent_ = StzReplace(read(pcFile), char(13), "")
		_acLines_ = StzSplit(_cContent_, char(10))
		_nLen_ = len(_acLines_)
		_cCurClass_ = ""
		_cCurMethod_ = ""
		for _i_ = 1 to _nLen_
			_cL_ = ring_trim(StzReplace(_acLines_[_i_], char(9), " "))
			if StzLower(StzLeft(_cL_, 6)) = "class "
				_acParts_ = This._Tokens(_cL_)
				_cCls_ = ""
				_cParent_ = ""
				if len(_acParts_) >= 2
					_cCls_ = _acParts_[2]
				ok
				if len(_acParts_) >= 4 and StzLower(_acParts_[3]) = "from"
					_cParent_ = _acParts_[4]
				ok
				if _cCls_ != ""
					@acClasses + [ _cCls_, _cParent_, pcFile ]
					_cCurClass_ = _cCls_
				ok
				_cCurMethod_ = ""
			but StzLower(StzLeft(_cL_, 4)) = "def " and _cCurClass_ != ""
				_acNm_ = StzSplit(_cL_, "(")
				_cM_ = ring_trim(StzReplace(_acNm_[1], "def ", ""))
				if _cM_ != "" and len(StzFind(" ", _cM_)) = 0
					@aMethods + [ _cCurClass_, _cM_, pcFile, _i_ ]
					_cCurMethod_ = _cM_
				else
					_cCurMethod_ = ""
				ok
			but StzLower(StzLeft(_cL_, 5)) = "func "
				# a global function -- its body is not a class method's body
				_cCurMethod_ = ""
			else
				# a METHOD BODY line: harvest call candidates (identifiers
				# immediately before "("), resolved against real methods later.
				if _cCurClass_ != "" and _cCurMethod_ != ""
					_aTg_ = This._CallTargets(This._CodeOnly(_cL_))
					_nT_ = len(_aTg_)
					for _t_ = 1 to _nT_
						@aRawCalls + [ _cCurClass_, _cCurMethod_, _aTg_[_t_] ]
					next
				ok
			ok
		next

	def _Tokens(pcLine)
		_acRaw_ = StzSplit(pcLine, " ")
		_acOut_ = []
		_nLen_ = len(_acRaw_)
		for _k_ = 1 to _nLen_
			_cT_ = ring_trim(_acRaw_[_k_])
			if _cT_ != ""
				_acOut_ + _cT_
			ok
		next
		return _acOut_

	#-- call-edge extraction (name-based; see the HONESTY note) -----------

	# Strip a line to CODE ONLY: remove string-literal content (so "Foo(" in
	# a message is not a call) then drop the trailing # comment. No char-index
	# scan (that trap corrupts the Ring VM in class scope) -- uses split/join.
	def _CodeOnly(pcLine)
		_c_ = This._DropQuoted("" + pcLine, '"')
		_c_ = This._DropQuoted(_c_, "'")
		_nH_ = StzFindFirst(_c_, "#")
		if _nH_ > 0  _c_ = StzLeft(_c_, _nH_ - 1)  ok
		return _c_

	# Drop the content INSIDE the given quote char: split on it and keep only
	# the even segments (1,3,5 = outside the quotes).
	def _DropQuoted(pcStr, pcQuote)
		_a_ = StzSplit("" + pcStr, pcQuote)
		_cOut_ = ""
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _i_ % 2 = 1
				_cOut_ += _a_[_i_] + " "
			ok
		next
		return _cOut_

	# The identifiers immediately preceding a "(" in a code line -- the call
	# targets. Separators are flattened to spaces so "This.Foo(" -> "Foo".
	def _CallTargets(pcCode)
		_c_ = "" + pcCode
		_aSep_ = [ ".", "=", "+", "-", "*", "/", "<", ">", ",", "[", "]",
		           "{", "}", ":", "&", "|", "!", "%", ";", ")" ]
		_nS_ = len(_aSep_)
		for _s_ = 1 to _nS_
			_c_ = StzReplace(_c_, _aSep_[_s_], " ")
		next
		_aParts_ = StzSplit(_c_, "(")
		_aOut_ = []
		_nP_ = len(_aParts_)
		for _i_ = 1 to _nP_ - 1
			_cId_ = This._LastToken(_aParts_[_i_])
			if _cId_ != ""
				_aOut_ + _cId_
			ok
		next
		return _aOut_

	def _LastToken(pcStr)
		_a_ = StzSplit("" + pcStr, " ")
		_cLast_ = ""
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_t_ = ring_trim(_a_[_i_])
			if _t_ != ""
				_cLast_ = _t_
			ok
		next
		return _cLast_

	# Resolve raw call candidates against REAL method names: a candidate is a
	# call edge only if some class defines a method of that name. Name-based:
	# the callee is a method NAME (not a type-resolved target). Builds the
	# de-duplicated @aCalls + the set of names that are actually called.
	def _ResolveCalls()
		@acMethodNames = []
		_nMx_ = len(@aMethods)
		for _ix_ = 1 to _nMx_
			_nm_ = StzLower("" + @aMethods[_ix_][2])
			if ring_find(@acMethodNames, _nm_) = 0
				@acMethodNames + _nm_
			ok
		next
		@aCalls = []
		@acCalleeNames = []
		_aSeen_ = []
		_nR_ = len(@aRawCalls)
		for _i_ = 1 to _nR_
			_cand_ = StzLower(@aRawCalls[_i_][3])
			if ring_find(@acMethodNames, _cand_) > 0
				_key_ = StzLower(@aRawCalls[_i_][1]) + "|" +
					StzLower(@aRawCalls[_i_][2]) + "|" + _cand_
				if ring_find(_aSeen_, _key_) = 0
					_aSeen_ + _key_
					@aCalls + [ @aRawCalls[_i_][1], @aRawCalls[_i_][2], @aRawCalls[_i_][3] ]
				ok
				if ring_find(@acCalleeNames, _cand_) = 0
					@acCalleeNames + _cand_
				ok
			ok
		next

	def _BuildGraph()
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if NOT @oGraph.NodeExists(@acClasses[_i_][1])
				@oGraph.AddNode(@acClasses[_i_][1])
			ok
		next
		for _i_ = 1 to _nLen_
			_cParent_ = @acClasses[_i_][2]
			if _cParent_ != ""
				if NOT @oGraph.NodeExists(_cParent_)
					@oGraph.AddNode(_cParent_)
				ok
				if NOT @oGraph.EdgeExists(@acClasses[_i_][1], _cParent_)
					@oGraph.AddEdgeXTT(@acClasses[_i_][1], _cParent_,
						"inherits", [ :type = "inherits" ])
				ok
			ok
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

	# every class that DEFINES this method (structure, not prose)
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

	def FileOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][1]) = _cC_
				return @acClasses[_i_][3]
			ok
		next
		return ""

	def ParentOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][1]) = _cC_
				return @acClasses[_i_][2]
			ok
		next
		return ""

	# the inheritance chain up to the root: [ class, parent, ..., top ]
	def AncestryOf(pcClass)
		_acChain_ = [ "" + pcClass ]
		_cCur_ = "" + pcClass
		_nGuard_ = 0
		while _nGuard_ < 24
			_nGuard_++
			_cUp_ = This.ParentOf(_cCur_)
			if _cUp_ = "" or ring_find(_acChain_, _cUp_) > 0
				exit
			ok
			_acChain_ + _cUp_
			_cCur_ = _cUp_
		end
		return _acChain_

	def SubclassesOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_acOut_ = []
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][2]) = _cC_
				_acOut_ + @acClasses[_i_][1]
			ok
		next
		return _acOut_

	# transitive closure of SubclassesOf
	def DescendantsOf(pcClass)
		_acOut_ = []
		_acFront_ = [ "" + pcClass ]
		_nGuard_ = 0
		while len(_acFront_) > 0 and _nGuard_ < 24
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

	# IMPACT: who feels a change to this METHOD -- the classes defining
	# it, plus every descendant that INHERITS it (does not redefine).
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
					_acInherited_ + _acDesc_[_j_]
				ok
			next
		next
		return [ :owners = _acOwners_, :inheritedBy = _acInherited_ ]

	# CASCADE: the pre-commit review artifact for touching a CLASS --
	# its descendants (they inherit its behavior) with the size of the
	# surface they inherit. "What you read instead of the diff." (5.8)
	def Cascade(pcClass)
		_acDesc_ = This.DescendantsOf(pcClass)
		return [
			:class = "" + pcClass,
			:methodsTouched = len(This.MethodsOf(pcClass)),
			:descendants = _acDesc_,
			:blastRadius = len(_acDesc_)
		]

	#-- call-graph queries (name-based; see the HONESTY note) -------------

	# Every resolved call edge: [ callerClass, callerMethod, calleeName ].
	def CallEdges()
		return @aCalls

	def NumberOfCallEdges()
		return len(@aCalls)

	# Every (class, method) whose body CALLS pcMethod (by name).
	def CallersOf(pcMethod)
		_cM_ = StzLower("" + pcMethod)
		_aOut_ = []
		_aSeen_ = []
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			if StzLower(@aCalls[_i_][3]) = _cM_
				_key_ = StzLower(@aCalls[_i_][1]) + "|" + StzLower(@aCalls[_i_][2])
				if ring_find(_aSeen_, _key_) = 0
					_aSeen_ + _key_
					_aOut_ + [ :class = @aCalls[_i_][1], :method = @aCalls[_i_][2] ]
				ok
			ok
		next
		return _aOut_

	# The method NAMES called from pcClass.pcMethod's body.
	def CalleesOf(pcClass, pcMethod)
		_cC_ = StzLower("" + pcClass)
		_cM_ = StzLower("" + pcMethod)
		_aOut_ = []
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			if StzLower(@aCalls[_i_][1]) = _cC_ and StzLower(@aCalls[_i_][2]) = _cM_
				if ring_find(_aOut_, @aCalls[_i_][3]) = 0
					_aOut_ + @aCalls[_i_][3]
				ok
			ok
		next
		return _aOut_

	# DEAD CODE (honest scope): PRIVATE helpers (name starts "_") whose name
	# is never referenced by any call in the scanned tree. Public methods are
	# excluded -- they may be entry points called from outside this tree.
	# Name-based: a private helper sharing its name with a called method is
	# treated as reachable (conservative -- never a false "dead").
	def DeadCode()
		_aOut_ = []
		_n_ = len(@aMethods)
		for _i_ = 1 to _n_
			_m_ = @aMethods[_i_][2]
			if StzLeft(_m_, 1) = "_"
				if ring_find(@acCalleeNames, StzLower(_m_)) = 0
					_aOut_ + [ :class = @aMethods[_i_][1], :method = _m_,
						:file = @aMethods[_i_][3], :line = @aMethods[_i_][4] ]
				ok
			ok
		next
		return _aOut_

	# CYCLIC CALLS (honest scope): intra-class MUTUAL RECURSION -- method A
	# and B in the same class each call the other (a 2-cycle). Self-recursion
	# (A calls A) is legitimate and not reported. Name-based within one class.
	def CyclicCalls()
		_aOut_ = []
		_aSeen_ = []
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			_cls_ = @aCalls[_i_][1]
			_a_ = @aCalls[_i_][2]
			_b_ = @aCalls[_i_][3]
			if StzLower(_a_) = StzLower(_b_)  loop  ok
			# intra-class both ways: A->B and B->A, both real methods of _cls_
			if This._DefinesMethod(_cls_, _b_) and This._DefinesMethod(_cls_, _a_) and
			   This._HasCallInClass(_cls_, _b_, _a_)
				# canonical de-dup WITHOUT a string '<' (Ring coerces '<' to
				# numeric -> R41): treat "a+b" and "b+a" as the same pair.
				_kab_ = StzLower(_cls_) + "|" + StzLower(_a_) + "+" + StzLower(_b_)
				_kba_ = StzLower(_cls_) + "|" + StzLower(_b_) + "+" + StzLower(_a_)
				if ring_find(_aSeen_, _kab_) = 0 and ring_find(_aSeen_, _kba_) = 0
					_aSeen_ + _kab_
					_aOut_ + [ :class = _cls_, :cycle = [ _a_, _b_ ] ]
				ok
			ok
		next
		return _aOut_

	def _DefinesMethod(pcClass, pcMethod)
		_cM_ = StzLower("" + pcMethod)
		_aM_ = This.MethodsOf(pcClass)
		_n_ = len(_aM_)
		for _i_ = 1 to _n_
			if StzLower(_aM_[_i_]) = _cM_  return TRUE  ok
		next
		return FALSE

	def _HasCallInClass(pcClass, pcCaller, pcCallee)
		_cC_ = StzLower("" + pcClass)
		_ca_ = StzLower("" + pcCaller)
		_ce_ = StzLower("" + pcCallee)
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			if StzLower(@aCalls[_i_][1]) = _cC_ and StzLower(@aCalls[_i_][2]) = _ca_ and
			   StzLower(@aCalls[_i_][3]) = _ce_
				return TRUE
			ok
		next
		return FALSE

	def Stats()
		return [
			:root = @cRoot,
			:classes = len(@acClasses),
			:methods = len(@aMethods),
			:inheritsEdges = @oGraph.EdgeCount(),
			:callEdges = len(@aCalls)
		]
