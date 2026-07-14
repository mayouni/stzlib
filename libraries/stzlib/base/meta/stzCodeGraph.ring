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
# HONESTY: this is the DECLARATION graph (defines/inherits). CALL edges
# (who calls whom -> DeadCode()/CyclicCalls()) need body parsing and land
# in the next R2 slice -- refused loudly until then, never faked.

class stzCodeGraph from stzObject

	@oGraph = NULL       # class nodes + :inherits edges (stzGraph)
	@aMethods = []       # [ [ class, method, file, line ] ... ]
	@acClasses = []      # [ [ class, parent, file ] ... ]
	@cRoot = ""

	def init(pcRootPath)
		@cRoot = pcRootPath
		@oGraph = new stzGraph("codegraph")
		This._Scan(pcRootPath)
		This._BuildGraph()

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
			but StzLower(StzLeft(_cL_, 4)) = "def " and _cCurClass_ != ""
				_acNm_ = StzSplit(_cL_, "(")
				_cM_ = ring_trim(StzReplace(_acNm_[1], "def ", ""))
				if _cM_ != "" and len(StzFind(" ", _cM_)) = 0
					@aMethods + [ _cCurClass_, _cM_, pcFile, _i_ ]
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

	# refused loudly until CALL edges land (next R2 slice)
	def DeadCode()
		stzraise("DeadCode() needs CALL edges (body parsing) -- the declaration graph only has defines/inherits. Lands in the next R2 slice; refusing rather than guessing (LAW 3).")

	def CyclicCalls()
		stzraise("CyclicCalls() needs CALL edges (body parsing) -- lands in the next R2 slice; refusing rather than guessing (LAW 3).")

	def Stats()
		return [
			:root = @cRoot,
			:classes = len(@acClasses),
			:methods = len(@aMethods),
			:inheritsEdges = @oGraph.EdgeCount()
		]
