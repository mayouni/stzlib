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
	return $pStzPolyglotHandle != ""

# Turns source code into a graph of classes, methods, functions, imports and calls, and answers questions about inheritance and impact.
#
# This is the shared head of the code graph family: it holds the model and every query, and each
# language is a subclass that knows how to read its source (stzRingCodeGraph, stzPyCodeGraph,
# stzJsCodeGraph). Build a graph with one of their functions, such as StzPyCodeGraphFromSource, then
# ask: Classes, MethodsOf, OwnersOf, AncestryOf, SubclassesOf, DescendantsOf, ImpactOf (who defines
# a method and who inherits it) and Cascade (how far a change to a class reaches). The call
# questions, CallersOf, CalleesOf, DeadCode and CyclicCalls, need call edges, which only a real
# parse such as ScanSourceViaTreeSitter records; without them DeadCode and CyclicCalls raise an
# error instead of guessing. The base class cannot parse by itself: Language raises, and so do Stats
# and any scan. CheckRules and RulesAreSound work on a Ring graph only.
#
#   receiver   o1 = StzPyCodeGraphFromSource('class Animal:' + char(10) + '    def speak(self):' +
#              char(10) + '        return 1' + char(10) + 'class Dog(Animal):' + char(10) + '    def
#              speak(self):' + char(10) + '        return 2' + char(10) + 'class Puppy(Dog):' +
#              char(10) + '    pass')
#   example    ? @@( o1.Classes() )
#              #--> [ "Animal", "Dog", "Puppy" ]
#              ? @@( o1.AncestryOf("Puppy") )
#              #--> [ "Puppy", "Dog", "Animal" ]
#              ? @@( o1.DescendantsOf("Animal") )
#              #--> [ "Dog", "Puppy" ]
#              ? @@( o1.OwnersOf("speak") )
#              #--> [ "Animal", "Dog" ]
#              ? @@( o1.ImpactOf("speak")[:inheritedBy] )
#              #--> [ "Puppy" ]
#              ? o1.Cascade("Animal")[:blastRadius]
#              #--> 2
#   see        stzRingCodeGraph, stzPyCodeGraph, stzJsCodeGraph, stzGraph
class stzCodeGraph from stzObject

	@oGraph = ""       # class nodes + :inherits edges (stzGraph)
	@aMethods = []       # [ class, method, file, line ]
	@acClasses = []      # [ class, [parents], file ]   (multiple inheritance)
	@aFunctions = []     # [ function, file, line ]     (module-level)
	@aImports = []       # [ file, module ]
	@aCalls = []         # [ callerFunc, callee ]        (real-parse backends)
	@bHasCalls = 0   # TRUE once real CALL edges are ingested
	@cRoot = ""

	# Builds an empty code graph for a root folder; this base class does not scan the folder, and the language subclasses do.
	#
	#   pcRootPath   the folder of the source, kept for Stats and for the subclasses' scans
	#   returns      nothing; the object is built
	#   warning      stzCodeGraph itself cannot parse: Language raises, so build one of its language
	#                subclasses (stzRingCodeGraph, stzPyCodeGraph, stzJsCodeGraph) or a function
	#                such as StzPyCodeGraphFromSource
	#   see          SetRoot, ScanSourceViaTreeSitter, BuildGraph
	def init(pcRootPath)
		@cRoot = pcRootPath
		@oGraph = new stzGraph("codegraph")
		@aMethods = []
		@acClasses = []
		@aFunctions = []
		@aImports = []
		@aCalls = []
		@bHasCalls = 0

	# Sets the root folder that Stats reports and that directory scans start from.
	#
	#   pcPath     the folder of the source
	#   returns    nothing
	#   see        init, Stats
	def SetRoot(pcPath)
		@cRoot = pcPath

	# Returns the grammar name of the language, such as ring or python; the base class raises an error because only a subclass knows it.
	#
	#   returns    a text in a subclass; raises an error on stzCodeGraph itself
	#   warning    stzCodeGraph itself raises stzCodeGraph is abstract for parsing
	#   see        FileExtension, Stats
	#@ aka  -- language identity (subclasses override) ---------------------------
	def Language()
		stzraise("stzCodeGraph is abstract for parsing -- use a language subclass (stzRingCodeGraph / stzPyCodeGraph / stzJsCodeGraph) that defines Language().")

	# Returns the extension of the language's source files, such as .py, which a directory scan uses; empty in the base class.
	#
	#   returns    a text such as .py; empty text in the base class
	#   see        Language
	def FileExtension()
		return ""

	# Parses one source text with the language's tree-sitter grammar and adds its classes, methods, functions, imports and calls.
	#
	#   pcSource   the source code as text
	#   pcFile     the name to record for it, such as f1.py
	#   returns    nothing
	#   note       a source with syntax errors was tested and did not raise
	#   warning    raises an error when the tree-sitter engine is not loaded; call BuildGraph
	#              afterwards so the inheritance edges exist
	#   see        BuildGraph, DeadCode, FileOf
	#@ aka  -- tree-sitter scanning (real parse in the engine, no runtime) --------
	def ScanSourceViaTreeSitter(pcSource, pcFile)
		if $pStzPolyglotHandle = ""
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
				@bHasCalls = 1
			but _cKind_ = "ERROR"
				stzraise("The source could not be parsed: " + _aP_[2])
			ok
		next

	# Builds the inheritance graph from the classes scanned: one node per class, and one edge from each class to each of its parents.
	#
	#   returns    nothing
	#   note       a parent that was never scanned still gets a node
	#   see        GraphQ, ScanSourceViaTreeSitter
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

	# Returns the stzGraph that holds the classes as nodes and the inheritance as edges.
	#
	#   returns    a stzGraph
	#   note       it stays empty until BuildGraph runs
	#   see        BuildGraph, Stats
	#@ aka  -- structure queries -------------------------------------------------
	def GraphQ()
		return @oGraph

	# Returns the names of the scanned classes, in scan order.
	#
	#   returns    a list of text
	#   see        NumberOfClasses, MethodsOf
	def Classes()
		_acOut_ = []
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			_acOut_ + @acClasses[_i_][1]
		next
		return _acOut_

	# Returns how many classes were scanned.
	#
	#   returns    a number
	#   see        Classes
	def NumberOfClasses()
		return len(@acClasses)

	# Returns how many methods were scanned, over all the classes.
	#
	#   returns    a number
	#   see        MethodsOf, NumberOfFunctions
	def NumberOfMethods()
		return len(@aMethods)

	# Returns the names of the scanned module-level functions, in scan order.
	#
	#   returns    a list of text
	#   see        NumberOfFunctions, FunctionsWithLines
	def Functions()
		_acOut_ = []
		_nLen_ = len(@aFunctions)
		for _i_ = 1 to _nLen_
			_acOut_ + @aFunctions[_i_][1]
		next
		return _acOut_

	# Returns how many module-level functions were scanned.
	#
	#   returns    a number
	#   see        Functions
	def NumberOfFunctions()
		return len(@aFunctions)

	# Returns the names of the methods a class defines itself, without the inherited ones.
	#
	#   pcClass    the class name, matched without regard to case
	#   returns    a list of text; empty for an unknown class
	#   see        OwnersOf, MethodsWithLines
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

	# Checks the whole graph against the code rule set and returns the findings in the common rule shape.
	#
	#   returns    a list of findings; empty when none
	#   note       the same findings can be collected by a stzRuleReport
	#   warning    works on a Ring graph only: on a Python graph it raises error R14 Calling Method
	#              without definition: rawcallentries
	#   see        RulesAreSound, MethodsWithLines
	#@ aka  Every method as [ class, method, line ] -- the locus a code RULE needs (MethodsOf gives names only). @aMethods is [ class, method, file, line ]. The uniform graph-owned verb: the code graph checks ITSELF against the code rule set, in the unified finding shape -- so an stzRuleReport can Collect it like any other graph. (StzCheckCode remains the per-line adapter for source snippets; this is the whol
	def CheckRules()
		return StzCodeRuleSetQ().Check(This)

	# TRUE if the code rule set finds nothing wrong in the graph.
	#
	#   returns    1 or 0
	#   warning    works on a Ring graph only: on a Python graph it raises error R14 Calling Method
	#              without definition: rawcallentries
	#   see        CheckRules
	def RulesAreSound()
		return StzCodeRuleSetQ().IsSound(This)

	# Returns every method with the class that defines it and its line.
	#
	#   returns    a list of [ class, method, line ] triples
	#   see        MethodsOf, FunctionsWithLines
	def MethodsWithLines()
		_aOut_ = []
		_nLen_ = len(@aMethods)
		for _i_ = 1 to _nLen_
			_aOut_ + [ @aMethods[_i_][1], @aMethods[_i_][2], @aMethods[_i_][4] ]
		next
		return _aOut_

	# Returns every module-level function with its line.
	#
	#   returns    a list of [ function, line ] pairs
	#   see        Functions, MethodsWithLines
	#@ aka  Every module-level function as [ function, line ].
	def FunctionsWithLines()
		_aOut_ = []
		_nLen_ = len(@aFunctions)
		for _i_ = 1 to _nLen_
			_aOut_ + [ @aFunctions[_i_][1], @aFunctions[_i_][3] ]
		next
		return _aOut_

	# Returns the classes that define a method themselves, each once.
	#
	#   pcMethod   the method name, matched without regard to case
	#   returns    a list of text; empty when none
	#   see        MethodsOf, ImpactOf
	#@ aka  every class that DEFINES this method
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

	# Returns the base classes a class declares, in order.
	#
	#   pcClass    the class name, matched without regard to case
	#   returns    a list of text; empty for a root class or an unknown class
	#   see        ParentOf, SubclassesOf
	def ParentsOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][1]) = _cC_
				return @acClasses[_i_][2]
			ok
		next
		return []

	# Returns the first base class of a class.
	#
	#   pcClass    the class name, matched without regard to case
	#   returns    a text; empty when it has none
	#   see        ParentsOf, AncestryOf
	#@ aka  convenience: the FIRST parent (single-inheritance languages, or the MRO spine of a multiple-inheritance one), "" if none.
	def ParentOf(pcClass)
		_aP_ = This.ParentsOf(pcClass)
		if len(_aP_) > 0
			return _aP_[1]
		ok
		return ""

	# Returns the file in which a class was scanned.
	#
	#   pcClass    the class name, matched without regard to case
	#   returns    a text; empty for an unknown class
	#   see        Classes
	def FileOf(pcClass)
		_cC_ = StzLower("" + pcClass)
		_nLen_ = len(@acClasses)
		for _i_ = 1 to _nLen_
			if StzLower(@acClasses[_i_][1]) = _cC_
				return @acClasses[_i_][3]
			ok
		next
		return ""

	# Returns the modules a file imports.
	#
	#   pcFile     the file name exactly as given at scan time, with case
	#   returns    a list of text; empty when none
	#   see        NumberOfImports
	def ImportsOf(pcFile)
		_acOut_ = []
		_nLen_ = len(@aImports)
		for _i_ = 1 to _nLen_
			if @aImports[_i_][1] = pcFile
				_acOut_ + @aImports[_i_][2]
			ok
		next
		return _acOut_

	# Returns how many imports were scanned, over all the files.
	#
	#   returns    a number
	#   see        ImportsOf
	def NumberOfImports()
		return len(@aImports)

	# Returns a class followed by its first parent, then that parent's first parent, up to a root.
	#
	#   pcClass    the class name
	#   returns    a list of text starting with the class itself; only the class itself for an
	#              unknown class
	#   note       the walk is cut after 40 steps and stops on a loop
	#   warning    only the first base of each class is followed, so a second base is not in the
	#              chain
	#   see        ParentOf, DescendantsOf
	#@ aka  the inheritance chain up to a root, following the FIRST base (the MRO spine); multiple bases are visited by DescendantsOf/ImpactOf.
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

	# Returns the classes that name this class as a base, one level down.
	#
	#   pcClass    the class name, matched without regard to case
	#   returns    a list of text; empty when none
	#   see        DescendantsOf, ParentsOf
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

	# Returns every class below a class, level by level, each once.
	#
	#   pcClass    the class name
	#   returns    a list of text; empty when none
	#   see        SubclassesOf, Cascade
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

	# Returns the classes that define a method and the descendants that inherit it without redefining it.
	#
	#   pcMethod   the method name
	#   returns    a hashlist with the keys owners and inheritedBy
	#   note       the keys are lower case when listed
	#   see        OwnersOf, Cascade
	#@ aka  IMPACT: classes defining the method + every descendant that INHERITS it (does not redefine).
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

	# Returns how far a change to a class reaches: its method count, its descendants and how many they are.
	#
	#   pcClass    the class name
	#   returns    a hashlist with the keys class, methodsTouched, descendants and blastRadius
	#   note       the keys are lower case when listed
	#   see        DescendantsOf, ImpactOf
	def Cascade(pcClass)
		_acDesc_ = This.DescendantsOf(pcClass)
		return [
			:class = "" + pcClass,
			:methodsTouched = len(This.MethodsOf(pcClass)),
			:descendants = _acDesc_,
			:blastRadius = len(_acDesc_)
		]

	# TRUE if calls were scanned, which only a real parse such as tree-sitter provides.
	#
	#   returns    1 or 0
	#   see        CallEdges, DeadCode
	#@ aka  -- CALL edges (present only with a real-parse backend) ---------------
	def HasCallEdges()
		return @bHasCalls

	# Returns every recorded call as a pair of caller and callee.
	#
	#   returns    a list of [ caller, callee ] pairs
	#   note       the Ring subclass answers triples of class, method and callee
	#   see        CallersOf, CalleesOf
	def CallEdges()
		return @aCalls

	# Returns the functions and methods that call a name, each once.
	#
	#   pcCallee   the called name, matched without regard to case
	#   returns    a list of text; empty when none
	#   note       the Ring subclass answers hashlists with the class and the method
	#   see        CalleesOf, DeadCode
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

	# Returns the names that a function or method calls, each once.
	#
	#   pcCaller   the calling name, matched without regard to case
	#   returns    a list of text; empty when none
	#   warning    the Ring subclass takes a second argument, so a call with one argument raises
	#              error R19 there
	#   see        CallersOf, CyclicCalls
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

	# Returns the defined functions and methods that no recorded call reaches, except the double-underscore ones.
	#
	#   returns    a list of text
	#   note       the result names candidates: a call through a variable cannot be seen
	#   warning    raises an error when no call edges were scanned, rather than guess
	#   see        CallersOf, CyclicCalls
	#@ aka  every DEFINED function/method that NO recorded call reaches (a dead-code candidate). dunder methods are runtime entry points, never dead. Name- based over the call edges -- honest about dynamic dispatch (a call through a variable can't be seen), so it names candidates, not proof.
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

	# Returns the defined functions and methods that can reach themselves through calls, directly or through others.
	#
	#   returns    a list of text
	#   warning    raises an error when no call edges were scanned, rather than guess
	#   see        DeadCode, CallEdges
	#@ aka  every DEFINED function/method that can reach ITSELF through >=1 call (i.e. participates in a call cycle, direct or indirect recursion).
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
					return 1
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
		return 0

	# Returns the root, the language and the counts of classes, methods, functions, imports and inheritance edges.
	#
	#   returns    a hashlist with the keys root, language, classes, methods, functions, imports and
	#              inheritsEdges
	#   note       the keys are lower case when listed; the Ring subclass reports calledges as well
	#   warning    raises the abstract error on stzCodeGraph itself, because it asks the language
	#   see        Language, GraphQ
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
