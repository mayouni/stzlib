# stzRingCodeGraph -- RING as a code graph (one language on the polyglot
# code-graph family; a PEER of stzPyCodeGraph / stzJsCodeGraph under
# stzCodeGraph). Keeps Ring's OWN identity:
#   - a SOURCE-TRUTH parser over .ring files: class declarations (nodes +
#     :inherits edges) + a method registry, and a NAME-BASED call graph
#     from method-body parsing (string literals + comments stripped first).
#   - Ring CONVENTIONS in the call-scoped queries: DeadCode() is scoped to
#     PRIVATE helpers (name starts "_") that nothing references; CyclicCalls()
#     to intra-class MUTUAL RECURSION -- the high-confidence signals a
#     name-based graph asserts without guessing.
# The language-agnostic query surface (Classes/MethodsOf/OwnersOf/Ancestry/
# Impact/Cascade/...) is inherited from stzCodeGraph.
#
#   oCG = new stzRingCodeGraph("D:/GitHub/stzlib/libraries/stzlib/base")
#   ? oCG.OwnersOf("Uppercase")   ? oCG.AncestryOf("stzString")
#   ? oCG.CallersOf("AddFact")    ? oCG.DeadCode()   ? oCG.CyclicCalls()

func StzRingCodeGraphQ(pcRootPath)
	return new stzRingCodeGraph(pcRootPath)

func StzRingCodeGraphFromSource(pcSource)
	oG = new stzRingCodeGraph("")
	oG.ScanSource(pcSource, "<source>")
	oG.BuildGraph()
	oG._ResolveCalls()
	return oG


# Holds Ring source as a code graph: classes with their parent, methods and a name-based graph of the calls between them.
#
# Its parser reads the Ring source itself: class headers with a single parent, def lines, and the
# calls in method bodies, found as an identifier before an open parenthesis once string literals and
# comments are stripped. A call is an edge only when some class defines a method of that name, so
# the graph is name-based and honest about it. DeadCode is scoped to private helpers that nothing
# references, and CyclicCalls to two methods of one class that call each other, the signals a name-
# based graph can assert without guessing. The query surface of the family (classes, owners,
# ancestry, impact, cascade) is inherited from stzCodeGraph. Build one from a folder with new
# stzRingCodeGraph(path) or from text with StzRingCodeGraphFromSource.
#
#   receiver   o1 = StzRingCodeGraphFromSource("class Animal" + nl + "def Speak()" + nl + "return
#              This._Sound()" + nl + "def _Sound()" + nl + "return 1" + nl + "def _Unused()" + nl +
#              "return 2" + nl + "class Dog from Animal" + nl + "def Fetch()" + nl + "return
#              This.Speak()" + nl)
#   example    ? @@( o1.AncestryOf("Dog") )
#              #--> [ "Dog", "Animal" ]
#              ? @@( o1.CallEdges() )
#              #--> [ [ "Animal", "Speak", "_Sound" ], [ "Dog", "Fetch", "Speak" ] ]
#              ? @@( o1.CalleesOf("Dog", "Fetch") )
#              #--> [ "Speak" ]
#              ? o1.DeadCode()[1][:method]
#              #--> _Unused
#   see        stzCodeGraph, stzPyCodeGraph, stzCodeRuleSet
class stzRingCodeGraph from stzCodeGraph

	@aRawCalls = []      # [ callerClass, callerMethod, candidateName, line ] pre-resolve
	@acMethodNames = []  # unique lowercase method names (resolution set)
	@acCalleeNames = []  # unique lowercase names that ARE called (for DeadCode)

	# Builds a Ring code graph, scanning every .ring file of a folder, or an empty graph when the path is empty.
	#
	#   pcRootPath   the folder to scan, below which every sub-folder is scanned too
	#   returns      nothing; the object is built
	#   warning      a path that is not a folder raises the file-system error of dir
	#   see          ScanSource, StzRingCodeGraphFromSource
	def init(pcRootPath)
		super.init(pcRootPath)
		@aRawCalls = []
		@acMethodNames = []
		@acCalleeNames = []
		if pcRootPath != ""
			This._Scan(pcRootPath)
			This.BuildGraph()
			This._ResolveCalls()
		ok

	# Returns the name of the language this graph models.
	#
	#   returns    the text ring
	#   see        FileExtension
	def Language()
		return "ring"

	# Returns the file extension of the source files it scans, with the dot.
	#
	#   returns    the text .ring
	#   see        Language
	def FileExtension()
		return ".ring"

	#-- scanning (Ring source truth) --------------------------------------

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
		This.ScanSource(StzReplace(read(pcFile), char(13), ""), pcFile)

	# Scans one Ring source text: class headers with their parent, methods, and the calls found in method bodies.
	#
	#   pcContent   the Ring source text
	#   pcFile      the file name recorded for what it finds
	#   returns     nothing
	#   note        call edges appear only after BuildGraph and the private resolve step that
	#               StzRingCodeGraphFromSource and the folder constructor run, so a graph filled by
	#               hand through ScanSource shows none
	#   see         init, CallEdges
	#@ aka  Parse one Ring source string: class headers (with single-inheritance 'from X', stored in the shared MULTIPLE-inheritance shape as [X] or []), 'def' method registry, and body-line call candidates.
	def ScanSource(pcContent, pcFile)
		_acLines_ = StzSplit("" + pcContent, char(10))
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
					_aP_ = []
					if _cParent_ != ""
						_aP_ + _cParent_
					ok
					@acClasses + [ _cCls_, _aP_, pcFile ]
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
						@aRawCalls + [ _cCurClass_, _cCurMethod_, _aTg_[_t_], _i_ ]
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
		_nH_ = StzFindFirst("#", _c_)
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
	# call edge only if some class defines a method of that name. Name-based.
	# Builds the de-duplicated @aCalls + the set of names that are called.
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
		@bHasCalls = 1

	# Returns the resolved calls between defined methods, as the class, the calling method and the name called.
	#
	#   returns    a list of [ class, method, callee ] triples, without repeats
	#   note       a call to something no class defines, such as a builtin, is not an edge
	#   see        RawCallEntries, CallersOf, CalleesOf
	#@ aka  -- Ring-specific call queries (a class-qualified 3-tuple model) -------
	def CallEdges()
		return @aCalls

	# Returns how many call edges were resolved.
	#
	#   returns    a number
	#   see        CallEdges
	def NumberOfCallEdges()
		return len(@aCalls)

	# Returns every call found in a method body, defined or not, builtins included, with the line of the call.
	#
	#   returns    a list of [ class, method, callee, line ] rows
	#   note       strings and comments are stripped first, so a name in a message is not a call; a
	#              definition is not a call
	#   see        CallEdges
	#@ aka  The UNRESOLVED call targets, [ class, method, callee, line ] -- every identifier called in a method body, builtins included. CallEdges() keeps only calls to DEFINED methods (so it drops builtins like substr); a rule like engine-first needs to SEE the builtin calls, so it reads these. The line is the CALL SITE, and a `def substr(` is a definition (not harvested here), so this distinguishes a call f
	def RawCallEntries()
		return @aRawCalls

	# Returns the methods whose body calls the named method, by name.
	#
	#   pcMethod   the name of the method that is called
	#   returns    a list of hash lists [ :class, :method ], without repeats
	#   note       the name is matched without regard to case
	#   see        CalleesOf, CallEdges
	#@ aka  Every (class, method) whose body CALLS pcMethod (by name).
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

	# Returns the names of the defined methods that one method calls.
	#
	#   pcClass    the class of the calling method
	#   pcMethod   the calling method
	#   returns    a list of text
	#   note       the class and method are matched without regard to case; an unknown pair answers
	#              an empty list
	#   see        CallersOf, CallEdges
	#@ aka  The method NAMES called from pcClass.pcMethod's body.
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

	# Returns the private helpers, whose names start with an underscore, that no call in the scanned tree reaches.
	#
	#   returns    a list of hash lists [ :class, :method, :file, :line ]
	#   note       public methods are never reported, since they may be entry points called from
	#              outside the tree; calls through a variable are invisible to a name-based graph
	#   see        CallersOf, CyclicCalls
	#@ aka  DEAD CODE (honest scope): PRIVATE helpers (name starts "_") whose name is never referenced by any call in the scanned tree. Public methods are excluded -- they may be entry points called from outside this tree.
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

	# Returns pairs of methods of one class that call each other, a mutual recursion.
	#
	#   returns    a list of hash lists [ :class, :cycle = [ a, b ] ]
	#   note       a method calling itself is legitimate and not reported
	#   see        CallersOf, DeadCode
	#@ aka  CYCLIC CALLS (honest scope): intra-class MUTUAL RECURSION -- method A and B in the same class each call the other (a 2-cycle). Self-recursion (A calls A) is legitimate and not reported. Name-based within one class.
	def CyclicCalls()
		_aOut_ = []
		_aSeen_ = []
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			_cls_ = @aCalls[_i_][1]
			_a_ = @aCalls[_i_][2]
			_b_ = @aCalls[_i_][3]
			if StzLower(_a_) = StzLower(_b_)  loop  ok
			if This._DefinesMethod(_cls_, _b_) and This._DefinesMethod(_cls_, _a_) and
			   This._HasCallInClass(_cls_, _b_, _a_)
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
			if StzLower(_aM_[_i_]) = _cM_  return 1  ok
		next
		return 0

	def _HasCallInClass(pcClass, pcCaller, pcCallee)
		_cC_ = StzLower("" + pcClass)
		_ca_ = StzLower("" + pcCaller)
		_ce_ = StzLower("" + pcCallee)
		_n_ = len(@aCalls)
		for _i_ = 1 to _n_
			if StzLower(@aCalls[_i_][1]) = _cC_ and StzLower(@aCalls[_i_][2]) = _ca_ and
			   StzLower(@aCalls[_i_][3]) = _ce_
				return 1
			ok
		next
		return 0

	# Returns the size of the graph: root, language, classes, methods, inheritance edges and call edges.
	#
	#   returns    a hash list; its keys come back in lower case, such as inheritsedges and
	#              calledges
	#   see        NumberOfCallEdges
	def Stats()
		return [
			:root = @cRoot,
			:language = "ring",
			:classes = len(@acClasses),
			:methods = len(@aMethods),
			:inheritsEdges = @oGraph.EdgeCount(),
			:callEdges = len(@aCalls)
		]
