# stzGraphex with Alternation Support, 1-Indexing, Robust Parsing, and Optimized Loops
# Fixed: Alternation parsing now strips outer parentheses correctly
class stzGraphex from stzGraph
	@cPattern		# Pattern string, e.g., "{@Node(start) -> (@Edge(flows)|@Edge(completes)) -> @Node(end)}"
	@bDebugMode = FALSE
	@oTargetGraph		# Target graph to match against

	# Match-result cache, keyed by target-graph signature.
	@aMatchCache = []	# list of [ signature, result ] pairs
	@nCacheHits = 0
	@nMaxCacheSize = 100	# bound; oldest entry evicted past this

	# Patterns for parsing tokens
	@cNodePattern = '@Node(?:\((.*?)\))?(?:\{(.*?)\})?'
	@cEdgePattern = '@Edge(?:\((.*?)\))?(?:\{(.*?)\})?'
	@cQuantifierPattern = '([+*?]|\d+|\d+-\d+)(.*)'
	@cNegationPattern = '@!(Node|Edge|Cycle|Path)(.*)'
	@cSetPattern = '\{(.*?)\}(U)?'
	# Enhanced alternation pattern to handle nested parentheses better
	@cAlternationPattern = '^\((.*)\)$'

	def init(_cPattern_, oTargetGraph)
		super.init("PatternGraph")
		
		if NOT isString(_cPattern_) or NOT @IsStzGraph(oTargetGraph)
			raise("Error: Pattern must be a string and graph must be stzGraph")
		ok
		
		@cPattern = This.NormalizePattern(_cPattern_)
		@oTargetGraph = oTargetGraph

		try
			This.BuildPatternGraph(@cPattern)
		catch
			raise("Pattern initialization failed: " + cCatchError)
		done


	def NormalizePattern(_cPattern_)
		_cPattern_ = trim(_cPattern_)
		
		if NOT (startsWith(_cPattern_, "{") and endsWith(_cPattern_, "}"))
			_cPattern_ = "{" + _cPattern_ + "}"
		ok
		
		return _cPattern_

	# Build the pattern as a graph: Nodes = tokens, Edges = sequences or alternates
	def BuildPatternGraph(_cPattern_)

		
		@aPendingAlternationBranches = []
		_aTokens_ = This.ParsePattern(_cPattern_)
		
		
		if len(_aTokens_) = 0
			return
		ok
		
		_nNodeCounter_ = 0
		_nPrevNodeId_ = NULL
		_nLenTokens_ = len(_aTokens_)
		
		for i = 1 to _nLenTokens_
			_aToken_ = _aTokens_[i]
			
			
			# Check if token is valid before accessing [:type]
			if NOT isList(_aToken_) or len(_aToken_) = 0
				loop
			ok
			
			# Safe key access using HasKey
			if NOT HasKey(_aToken_, :type)
				loop
			ok
			
			if _aToken_[:type] = "alternation"
				_aAltNodes_ = []
				_nLenAlternatives_ = len(_aToken_[:alternatives])
				
				for j = 1 to _nLenAlternatives_
					_nNodeCounter_++
					_cAltNodeId_ = ":p" + _nNodeCounter_
					_aAltToken_ = _aToken_[:alternatives][j]
					_cLabel_ = _aAltToken_[:type] + iff(HasKey(_aAltToken_, :label) and _aAltToken_[:label] != "", "(" + _aAltToken_[:label] + ")", "")
					_acProps_ = [ :min = _aAltToken_[:min], :max = _aAltToken_[:max],
							:negated = iff(_aAltToken_[:negated], "TRUE", "FALSE"),
							:cs = iff(HasKey(_aAltToken_, :cs) and _aAltToken_[:cs], "TRUE", "FALSE") ]
					if HasKey(_aAltToken_, :setvalues) and len(_aAltToken_[:setvalues]) > 0
						_acProps_ + [ "set", "{" + JoinXT(_aAltToken_[:setvalues], ";") + "}" + iff(_aAltToken_[:unique], "U", "") ]
					ok
					This.AddNodeXTT(_cAltNodeId_, _cLabel_, _acProps_)
					
					# Connect to previous node
					if _nPrevNodeId_ != NULL
						This.AddEdgeXT(_nPrevNodeId_, _cAltNodeId_, "sequences")
					ok
					
					_aAltNodes_ + _cAltNodeId_
				next
				
				# Store all alternation branches - next node will connect from ALL of them
				@aPendingAlternationBranches = _aAltNodes_
				_nPrevNodeId_ = NULL  # Signal that we need to connect from multiple nodes
			
			else
				# Regular node processing
				_nNodeCounter_++
				_cNodeId_ = ":p" + _nNodeCounter_
				_cLabel_ = _aToken_[:type]
				if HasKey(_aToken_, :label) and _aToken_[:label] != ""
					_cLabel_ += "(" + _aToken_[:label] + ")"
				ok
				_acProps_ = [ :min = _aToken_[:min], :max = _aToken_[:max],
						:negated = iff(_aToken_[:negated], "TRUE", "FALSE"),
						:cs = iff(HasKey(_aToken_, :cs) and _aToken_[:cs], "TRUE", "FALSE") ]
				if HasKey(_aToken_, :setvalues) and len(_aToken_[:setvalues]) > 0
					_acProps_ + [ "set", "{" + JoinXT(_aToken_[:setvalues], ";") + "}" + iff(_aToken_[:unique], "U", "") ]
				ok
				This.AddNodeXTT(_cNodeId_, _cLabel_, _acProps_)
				
				# Connect from previous node
				if _nPrevNodeId_ != NULL
					This.AddEdgeXT(_nPrevNodeId_, _cNodeId_, "sequences")
				ok
				
				# Connect from all pending alternation branches
				if len(@aPendingAlternationBranches) > 0
					_nLenPending_ = len(@aPendingAlternationBranches)
					for k = 1 to _nLenPending_
						This.AddEdgeXT(@aPendingAlternationBranches[k], _cNodeId_, "sequences")
					next
					@aPendingAlternationBranches = []
				ok
				
				_nPrevNodeId_ = _cNodeId_
			ok
		next
		

	# FIXED: Alternation parsing now correctly strips outer parentheses
	# before processing alternation groups
	def ParsePattern(_cPattern_)
		
		_oPattern_ = new stzString(_cPattern_)
		_cInner_ = _oPattern_.RemoveFirstAndLastCharsQ().Content()
		
		
		_aParts_ = split(_cInner_, "->")
		
		
		_aTokens_ = []
		_nLenParts_ = len(_aParts_)
		
		for i = 1 to _nLenParts_
			_cPart_ = trim(_aParts_[i])
			
			
			# Skip empty parts
			if _cPart_ = ""
				loop
			ok
			
			# Check for alternation group wrapped in parentheses
			# Strip outer parentheses first, then check for pipe
			if startsWith(_cPart_, "(") and endsWith(_cPart_, ")")
				# Strip outer parentheses to get the inner content
				_cInnerPart_ = @StzMid(_cPart_, 2, StzLen(_cPart_) - 1)
				
				
				# Now check if the inner content contains alternation
				if contains(_cInnerPart_, "|")
					# Process as alternation without outer parentheses
					_aAltTokens_ = []
					_aAltParts_ = @split(_cInnerPart_, "|")
					_nLenAltParts_ = len(_aAltParts_)
					_bValidAlt_ = TRUE
					
					for j = 1 to _nLenAltParts_
						_cAlt_ = trim(_aAltParts_[j])
						if _cAlt_ != ""
							_aToken_ = This.ParseSingleToken(_cAlt_)
							if isList(_aToken_) and len(_aToken_) > 0
								_aAltTokens_ + _aToken_
							else
								_bValidAlt_ = FALSE
								exit
							ok
						else
						ok
					next
					
					if _bValidAlt_ and len(_aAltTokens_) > 0
						_aTokens_ + [ [ "type", "alternation" ], [ "alternatives", _aAltTokens_ ] ]
					else
						if len(_aAltTokens_) > 0
							_aTokens_ + _aAltTokens_[1]
						else
							_aFallback_ = This.ParseSingleToken(_cPart_)
							if isList(_aFallback_) and len(_aFallback_) > 0
								_aTokens_ + _aFallback_
							ok
						ok
					ok
				else
					_aResult_ = This.ParseSingleToken(_cInnerPart_)
					if isList(_aResult_) and len(_aResult_) > 0
						_aTokens_ + _aResult_
					else
					ok
				ok
			else
				_aResult_ = This.ParseSingleToken(_cPart_)
				if isList(_aResult_) and len(_aResult_) > 0
					_aTokens_ + _aResult_
				else
				ok
			ok
		next
		
		return _aTokens_


	def ParseSingleToken(_cTokenStr_)
		_cTokenStr_ = @trim(_cTokenStr_)
		
		
		if _cTokenStr_ = ""
			return []
		ok
		
		_bNegated_ = StartsWith(_cTokenStr_, "@!")
		if _bNegated_
			# Remove @! (positions 1-2), keep from position 3 onwards
			_cTokenStr_ = "@" + @StzMid(_cTokenStr_, 3, StzLen(_cTokenStr_))
		ok

		# Per-token case-sensitivity marker: a leading "@cs:" makes this
		# token match the target label case-sensitively. Default (no
		# marker) is case-insensitive. Strip it before type detection,
		# else startsWith(.., "@node") never fires on "@cs:@Node(..)".
		_bCaseSensitive_ = FALSE
		if StartsWith(StzLower(_cTokenStr_), "@cs:")
			_bCaseSensitive_ = TRUE
			_cTokenStr_ = @StzMid(_cTokenStr_, 5, StzLen(_cTokenStr_))
		ok

		# Now process cTokenStr normally with bNegated flag set...
		
		_nMin_ = 1
		_nMax_ = 1
		_aSetValues_ = []
		_bRequireUnique_ = FALSE
		_cLabel_ = ""
		_cProps_ = ""
	
		# Process quantifiers - look for +, *, ? at the end
		_cLastChar_ = Right(_cTokenStr_, 1)
		if _cLastChar_ = "+" or _cLastChar_ = "*" or _cLastChar_ = "?"
			switch _cLastChar_
			on "+"
				_nMin_ = 1
				_nMax_ = 999999
			on "*"
				_nMin_ = 0
				_nMax_ = 999999
			on "?"
				_nMin_ = 0
				_nMax_ = 1
			off
			_cTokenStr_ = Left(_cTokenStr_, len(_cTokenStr_) - 1)
		ok
	
		# Process set constraints - look for {...}U or {...}
		_nBraceStart_ = StzFindFirst("{", _cTokenStr_)
		if _nBraceStart_ > 0
			_nBraceEnd_ = StzFindFirst("}", _cTokenStr_)
			if _nBraceEnd_ > _nBraceStart_
	
				# span BETWEEN the braces, not the absolute end index
				# (the old nBraceEnd count leaked the '}' into the set).
				_cSetContent_ = @StzMid(_cTokenStr_, _nBraceStart_ + 1, _nBraceEnd_ - _nBraceStart_ - 1)

				# Check for U after closing brace (single char lookahead)
				if _nBraceEnd_ < StzLen(_cTokenStr_) and @StzMid(_cTokenStr_, _nBraceEnd_ + 1, 1) = "U"
					_bRequireUnique_ = TRUE
					_cTokenStr_ = StzLeft(_cTokenStr_, _nBraceStart_ - 1) + @StzMid(_cTokenStr_, _nBraceEnd_ + 2, StzLen(_cTokenStr_))
				else
					_cTokenStr_ = StzLeft(_cTokenStr_, _nBraceStart_ - 1) + @StzMid(_cTokenStr_, _nBraceEnd_ + 1, StzLen(_cTokenStr_))
				ok
				
				# Parse set values
				if contains(_cSetContent_, ";")
					_aSetValues_ = @split(_cSetContent_, ";")
				else
					_aSetValues_ = [_cSetContent_]
				ok
			ok
		ok
	
		# Parse token type
		_cTokenLower_ = StzLower(_cTokenStr_)
		
		if startsWith(_cTokenLower_, "@node")
			
			# Manual extraction: @Node(label){props}
			_nParenStart_ = StzFindFirst("(", _cTokenStr_)
			if _nParenStart_ > 0
				_nParenEnd_ = StzFindFirst(")", _cTokenStr_)
				if _nParenEnd_ > _nParenStart_
					_cLabel_ = @StzMid(_cTokenStr_, _nParenStart_ + 1, _nParenEnd_ - _nParenStart_ - 1)
				ok
			ok

			# Props already handled above in set constraints


			return [
				[ "type", "node" ],
				[ "label", _cLabel_ ],
				[ "properties", _cProps_ ],
				[ "min", _nMin_ ],
				[ "max", _nMax_ ],
				[ "setvalues", _aSetValues_ ],
				[ "unique", _bRequireUnique_ ],
				[ "negated", _bNegated_ ],
				[ "cs", _bCaseSensitive_ ]
			]
			
		but startsWith(_cTokenLower_, "@edge")
			
			# Manual extraction: @Edge(label){props}
			_nParenStart_ = StzFindFirst("(", _cTokenStr_)
			if _nParenStart_ > 0
				_nParenEnd_ = StzFindFirst(")", _cTokenStr_)
				if _nParenEnd_ > _nParenStart_
					_cLabel_ = @StzMid(_cTokenStr_, _nParenStart_ + 1, _nParenEnd_ - _nParenStart_ - 1)
				ok
			ok


			return [
				[ "type", "edge" ],
				[ "label", _cLabel_ ],
				[ "properties", _cProps_ ],
				[ "min", _nMin_ ],
				[ "max", _nMax_ ],
				[ "setvalues", _aSetValues_ ],
				[ "unique", _bRequireUnique_ ],
				[ "negated", _bNegated_ ],
				[ "cs", _bCaseSensitive_ ]
			]
			
		but startsWith(_cTokenLower_, "@cycle")
			return [
				[ "type", "cycle" ],
				[ "label", "" ],
				[ "properties", "" ],
				[ "min", _nMin_ ],
				[ "max", _nMax_ ],
				[ "setvalues", _aSetValues_ ],
				[ "unique", _bRequireUnique_ ],
				[ "negated", _bNegated_ ],
				[ "cs", _bCaseSensitive_ ]
			]
			
		but startsWith(_cTokenLower_, "@path")
			return [
				[ "type", "path" ],
				[ "label", "" ],
				[ "properties", "" ],
				[ "min", _nMin_ ],
				[ "max", _nMax_ ],
				[ "setvalues", _aSetValues_ ],
				[ "unique", _bRequireUnique_ ],
				[ "negated", _bNegated_ ],
				[ "cs", _bCaseSensitive_ ]
			]
			
		else
			return []
		ok


	def ListifyGraph(oGraph)
		_aBranches_ = []
		_acNodes_ = oGraph.Nodes()
		_nLenNodes_ = len(_acNodes_)
		
		# Handle single isolated nodes
		for i = 1 to _nLenNodes_
			_aNode_ = _acNodes_[i]
			_cNodeId_ = _aNode_[:id]
			_acNeighbors_ = oGraph.Neighbors(_cNodeId_)
			_acIncoming_ = oGraph.Incoming(_cNodeId_)
			
			# If node has no connections, add it as single-node branch
			if len(_acNeighbors_) = 0 and len(_acIncoming_) = 0
				_aBranches_ + [_aNode_[:label]]
			ok
		next
		
		# Process paths between connected nodes
		for i = 1 to _nLenNodes_
			_aNode_ = _acNodes_[i]
			_cStartId_ = _aNode_[:id]
			_acReachable_ = oGraph.ReachableFrom(_cStartId_)
			_nLenReachable_ = len(_acReachable_)
			for j = 1 to _nLenReachable_
				_cEndId_ = _acReachable_[j]
				if _cEndId_ != _cStartId_
					_acPaths_ = oGraph.PathsXT(_cStartId_, _cEndId_)
					_nLenPaths_ = len(_acPaths_)
					for k = 1 to _nLenPaths_
						_aPath_ = _acPaths_[k]
						_aBranch_ = []
						_nLenPath_ = len(_aPath_)
						for m = 1 to _nLenPath_-1
							_cFrom_ = _aPath_[m]
							_cTo_ = _aPath_[m+1]
							# Get node by ID
							_aNodeFrom_ = NULL
							_nLenNodes_ = len(oGraph.Nodes())
							for n = 1 to _nLenNodes_
								if oGraph.Nodes()[n][:id] = _cFrom_
									_aNodeFrom_ = oGraph.Nodes()[n]
									exit
								ok
							next
							if _aNodeFrom_ != NULL
								_aBranch_ + _aNodeFrom_[:label]
							ok
							_aEdge_ = oGraph.Edge(_cFrom_, _cTo_)
							if _aEdge_ != ""
								_aBranch_ + _aEdge_[:label]
							ok
						next
						# Add final node
						_aNodeTo_ = NULL
						_nLenNodes_ = len(oGraph.Nodes())
						for n = 1 to _nLenNodes_
							if oGraph.Nodes()[n][:id] = _aPath_[_nLenPath_]
								_aNodeTo_ = oGraph.Nodes()[n]
								exit
							ok
						next
						if _aNodeTo_ != NULL
							_aBranch_ + _aNodeTo_[:label]
						ok
						if len(_aBranch_) > 0
							_aBranches_ + _aBranch_
						ok
					next
				ok
			next
		next
		
		# Handle cycles
		if oGraph.HasCyclicDependencies()
			_acCyclicNodes_ = oGraph.CyclicNodes()
			_nLenCyclic_ = len(_acCyclicNodes_)

			for i = 1 to _nLenCyclic_
				_cNode_ = _acCyclicNodes_[i]
				_acCyclePaths_ = oGraph.PathsXT(_cNode_, _cNode_)
				_nLenCyclePaths_ = len(_acCyclePaths_)

				for j = 1 to _nLenCyclePaths_
					_aPath_ = _acCyclePaths_[j]

					if len(_aPath_) > 1
						_aBranch_ = ["@Cycle"]
						_nLenPath_ = len(_aPath_)

						for k = 1 to _nLenPath_-1
							_cFrom_ = _aPath_[k]
							_cTo_ = _aPath_[k+1]
							# Get node by ID
							_aNodeFrom_ = NULL
							_nLenNodes_ = len(oGraph.Nodes())

							for n = 1 to _nLenNodes_
								if oGraph.Nodes()[n][:id] = _cFrom_
									_aNodeFrom_ = oGraph.Nodes()[n]
									exit
								ok
							next

							if _aNodeFrom_ != NULL
								_aBranch_ + _aNodeFrom_[:label]
							ok

							_aEdge_ = oGraph.Edge(_cFrom_, _cTo_)
							if _aEdge_ != ""
								_aBranch_ + _aEdge_[:label]
							ok

						next

						# Add final node
						_aNodeTo_ = NULL
						_nLenNodes_ = len(oGraph.Nodes())
						for n = 1 to _nLenNodes_
							if oGraph.Nodes()[n][:id] = _aPath_[_nLenPath_]
								_aNodeTo_ = oGraph.Nodes()[n]
								exit
							ok
						next

						if _aNodeTo_ != NULL
							_aBranch_ + _aNodeTo_[:label]
						ok

						_aBranches_ + _aBranch_
					ok
				next
			next
		ok

		return _aBranches_

	def Match(oTargetGraph)
		@oTargetGraph = oTargetGraph

		# Return a cached result when this target graph's signature was seen
		# before; otherwise compute, cache and return.
		_cSig_ = This._GraphSignature(oTargetGraph)
		_nLenCache_ = len(@aMatchCache)
		for _iC_ = 1 to _nLenCache_
			if @aMatchCache[_iC_][1] = _cSig_
				@nCacheHits++
				return @aMatchCache[_iC_][2]
			ok
		next

		_aPatternBranches_ = This.ListifyPatternGraph()
		_aTargetBranches_ = This.ListifyGraph(oTargetGraph)

		if @bDebugMode
		ok

		_result_ = This.MatchBranches(_aPatternBranches_, _aTargetBranches_)

		# Property constraints (e.g. @Node{age:>:25}) are not expressible
		# as label subsequences -- enforce them on the actual target nodes
		# once the structural match holds.
		if _result_
			_result_ = This._CheckPropertyConstraints(oTargetGraph)
		ok

		# Store, evicting the oldest entry when the cache is full (FIFO).
		if @nMaxCacheSize > 0 and len(@aMatchCache) >= @nMaxCacheSize
			del(@aMatchCache, 1)
		ok
		@aMatchCache + [ _cSig_, _result_ ]
		return _result_

	# Signature of a target graph for cache keying: node + edge counts plus
	# the (insertion-order) node ids.
	def _GraphSignature(oGraph)
		_cSig_ = "" + oGraph.NumberOfNodes() + ":" + oGraph.NumberOfEdges()
		_aIds_ = oGraph.NodesIds()
		_nLenIds_ = len(_aIds_)
		for _iS_ = 1 to _nLenIds_
			_cSig_ += "|" + _aIds_[_iS_]
		next
		return _cSig_

	# Cache statistics: number of distinct cached graph signatures + hits.
	def CacheStats()
		return [ :entries = len(@aMatchCache), :hits = @nCacheHits ]

		def CacheEntries()
			return len(@aMatchCache)

		def ClearCache()
			@aMatchCache = []
			@nCacheHits = 0

		# Bound the match cache; 0 or negative disables eviction.
		def SetCacheSize(nSize)
			if isNumber(nSize)
				@nMaxCacheSize = nSize
			ok
			return self

		def CacheInfo()
			return [ :entries = len(@aMatchCache), :maxsize = @nMaxCacheSize, :hits = @nCacheHits ]

	# Special listification for pattern graph that handles alternations
	def ListifyPatternGraph()
		_aBranches_ = []
		_acNodes_ = This.Nodes()
		_nLenNodes_ = len(_acNodes_)
		
		if _nLenNodes_ = 0
			return []
		ok
		
		# Find root nodes (no incoming edges)
		_acRoots_ = []
		for i = 1 to _nLenNodes_
			_aNode_ = _acNodes_[i]
			_acIncoming_ = This.Incoming(_aNode_[:id])
			if len(_acIncoming_) = 0
				_acRoots_ + _aNode_[:id]
			ok
		next
		
		if len(_acRoots_) = 0
			_acRoots_ + _acNodes_[1][:id]
		ok
		
		if @bDebugMode
		ok
		
		# Traverse from each root
		_nLenRoots_ = len(_acRoots_)
		for i = 1 to _nLenRoots_
			_cRoot_ = _acRoots_[i]
			This.TraversePatternNode(_cRoot_, [], _aBranches_, [])
		next
		
		return _aBranches_
	
	def TraversePatternNode(_cNodeId_, aCurrentPath, _aBranches_, acVisited)
		_aNode_ = This.Node(_cNodeId_)
		
		if _aNode_ = ""
			return
		ok
		
		_cLabel_ = _aNode_[:label]
		
		# Handle alternation nodes specially
		if _cLabel_ = "Alternation"
			# Get alternation branches and continuation
			_acNeighbors_ = This.Neighbors(_cNodeId_)
			_nLenNeighbors_ = len(_acNeighbors_)
			
			# Find alternation branches (edges labeled "alternates")
			_acAltBranches_ = []
			_cContinuation_ = NULL
			
			for i = 1 to _nLenNeighbors_
				_cNeighbor_ = _acNeighbors_[i]
				_aEdge_ = This.Edge(_cNodeId_, _cNeighbor_)
				if _aEdge_[:label] = "alternates"
					_acAltBranches_ + _cNeighbor_
				but _aEdge_[:label] = "sequences"
					_cContinuation_ = _cNeighbor_
				ok
			next
			
			# Process each alternation branch
			_nLenAlt_ = len(_acAltBranches_)
			for i = 1 to _nLenAlt_
				_cAltNode_ = _acAltBranches_[i]
				_aAltNode_ = This.Node(_cAltNode_)
				
				if _aAltNode_ != ""
					# Create path with alternation branch
					_aNewPath_ = []
					_nLenPath_ = len(aCurrentPath)
					for j = 1 to _nLenPath_
						_aNewPath_ + aCurrentPath[j]
					next
					_aNewPath_ + _aAltNode_[:label]
					
					# Continue to the node after alternation if exists
					if _cContinuation_ != NULL
						This.TraversePatternNode(_cContinuation_, _aNewPath_, _aBranches_, [])
					else
						# No continuation, this is the end
						if len(_aNewPath_) > 0
							_aBranches_ + _aNewPath_
						ok
					ok
				ok
			next
		else
			# Regular node - add label to path
			_aNewPath_ = []
			_nLenPath_ = len(aCurrentPath)
			for j = 1 to _nLenPath_
				_aNewPath_ + aCurrentPath[j]
			next
			_aNewPath_ + _cLabel_
			
			# Get neighbors
			_acNeighbors_ = This.Neighbors(_cNodeId_)
			
			if len(_acNeighbors_) = 0
				# End of path
				if len(_aNewPath_) > 0
					_aBranches_ + _aNewPath_
				ok
			else
				# Continue traversal
				_nLenNeighbors_ = len(_acNeighbors_)
				for i = 1 to _nLenNeighbors_
					This.TraversePatternNode(_acNeighbors_[i], _aNewPath_, _aBranches_, acVisited)
				next
			ok
		ok

	def MatchBranches(_aPatternBranches_, _aTargetBranches_)
		_nLenPatternBranches_ = len(_aPatternBranches_)
		
		if @bDebugMode
		ok
		
		for i = 1 to _nLenPatternBranches_
			_aPatternBranch_ = _aPatternBranches_[i]
			
			if @bDebugMode
			ok
			
			# Extract labels with per-token case-sensitivity + negation.
			# aPatternCS[j] / aForbiddenCS[j] carry whether that label
			# must match case-sensitively (the token had a @cs: marker).
			_aPatternLabels_ = []
			_aPatternCS_ = []
			_aForbiddenLabels_ = []
			_aForbiddenCS_ = []
			_nLenPattern_ = len(_aPatternBranch_)

			for j = 1 to _nLenPattern_
				_cToken_ = _aPatternBranch_[j]
				_cLabel_ = ""

				_nParenPos_ = StzFindFirst("(", _cToken_)
				if _nParenPos_ > 0
					_nClosePos_ = StzFindFirst(")", _cToken_)
					if _nClosePos_ > _nParenPos_
						# count is the span BETWEEN the parens, not nClosePos-1
						# (which leaked the ')' into the label -> "start)").
						_cLabel_ = @StzMid(_cToken_, _nParenPos_ + 1, _nClosePos_ - _nParenPos_ - 1)
					ok
				ok

				# Read the pattern node's :negated / :cs flags from its
				# properties hashlist (the props are [ :min, :max,
				# :negated, :cs ], not "key=value" strings).
				_bIsNegated_ = FALSE
				_bIsCS_ = FALSE
				_aNodeFromPattern_ = This.Node(":p" + j)
				if isList(_aNodeFromPattern_) and HasKey(_aNodeFromPattern_, :properties)
					_acProps_ = _aNodeFromPattern_[:properties]
					if isList(_acProps_)
						if HasKey(_acProps_, :negated) and _acProps_[:negated] = "TRUE"
							_bIsNegated_ = TRUE
						ok
						if HasKey(_acProps_, :cs) and _acProps_[:cs] = "TRUE"
							_bIsCS_ = TRUE
						ok
					ok
				ok

				if _cLabel_ != ""
					if _bIsNegated_
						_aForbiddenLabels_ + _cLabel_
						_aForbiddenCS_ + _bIsCS_
					else
						_aPatternLabels_ + _cLabel_
						_aPatternCS_ + _bIsCS_
					ok
				ok
			next

			if @bDebugMode
			ok

			# Check each target branch
			_nLenTargetBranches_ = len(_aTargetBranches_)
			for k = 1 to _nLenTargetBranches_
				_aTargetBranch_ = _aTargetBranches_[k]

				if @bDebugMode
				ok

				# First check forbidden labels - if any exist in target, skip this branch
				_bHasForbidden_ = FALSE
				_nForbiddenLabelsLen_ = len(_aForbiddenLabels_)
				for m = 1 to _nForbiddenLabelsLen_
					_nTargetBranchLen_ = len(_aTargetBranch_)
					for n = 1 to _nTargetBranchLen_
						if This._LabelEq(_aForbiddenLabels_[m], _aTargetBranch_[n], _aForbiddenCS_[m])
							_bHasForbidden_ = TRUE
							exit
						ok
					next
					if _bHasForbidden_
						exit
					ok
				next

				if _bHasForbidden_
					if @bDebugMode
					ok
					loop
				ok

				# Check if pattern labels appear as subsequence in target
				if This.IsSubsequenceCS(_aPatternLabels_, _aPatternCS_, _aTargetBranch_)
					if @bDebugMode
					ok
					return TRUE
				ok
			next
		next

		if @bDebugMode
		ok

		return FALSE

	# Codepoint-safe label equality. Case-sensitive when bCS is TRUE
	# (Ring's = is already case-sensitive); otherwise fold both sides
	# with StzLower (engine-backed, Unicode-correct).
	def _LabelEq(c1, c2, _bCS_)
		if _bCS_
			return (c1 = c2)
		ok
		return (StzLower(c1) = StzLower(c2))

	#-- Property-constraint evaluation -----------------------------------
	# Pattern nodes may carry set constraints like {age:>:25;score:>:80}.
	# A structural (label) match must additionally satisfy them on the
	# real target nodes: every constrained pattern node needs at least
	# one target node (matching its label, if any) that obeys all of its
	# constraints.

	def _CheckPropertyConstraints(oTargetGraph)
		_aPatNodes_ = This.Nodes()
		_aTgtNodes_ = oTargetGraph.Nodes()
		_nLenPat_ = len(_aPatNodes_)

		for i = 1 to _nLenPat_
			_aPat_ = _aPatNodes_[i]
			if NOT (isList(_aPat_) and HasKey(_aPat_, :properties))
				loop
			ok
			_aProps_ = _aPat_[:properties]
			if NOT (isList(_aProps_) and HasKey(_aProps_, :set))
				loop
			ok

			_aConstraints_ = This._ParseSetConstraints(_aProps_[:set])
			if len(_aConstraints_) = 0
				loop
			ok

			_cPatLabel_ = This._BareLabel(_aPat_[:label])
			_bCS_ = (HasKey(_aProps_, :cs) and _aProps_[:cs] = "TRUE")

			_bFound_ = FALSE
			_nLenTgt_ = len(_aTgtNodes_)
			for j = 1 to _nLenTgt_
				_aTgt_ = _aTgtNodes_[j]
				if _cPatLabel_ != "" and NOT This._LabelEq(_cPatLabel_, _aTgt_[:label], _bCS_)
					loop
				ok
				if This._NodeSatisfiesConstraints(_aTgt_[:properties], _aConstraints_)
					_bFound_ = TRUE
					exit
				ok
			next

			if NOT _bFound_
				return FALSE
			ok
		next

		return TRUE

	# "node(Alice)" -> "Alice"; "node" (no parens) -> "".
	def _BareLabel(_cLabel_)
		if NOT isString(_cLabel_)
			return ""
		ok
		_np_ = StzFindFirst("(", _cLabel_)
		if _np_ > 0
			_nc_ = StzFindFirst(")", _cLabel_)
			if _nc_ > _np_
				return @StzMid(_cLabel_, _np_ + 1, _nc_ - _np_ - 1)
			ok
		ok
		return ""

	# "{age:>:25;score:>:80}U" -> [ ["age",">","25"], ["score",">","80"] ]
	def _ParseSetConstraints(cSet)
		_aOut_ = []
		if NOT isString(cSet)
			return _aOut_
		ok
		_c_ = cSet
		if StartsWith(_c_, "{")
			_c_ = @StzMid(_c_, 2, StzLen(_c_))
		ok
		if EndsWith(_c_, "U")
			_c_ = StzLeft(_c_, StzLen(_c_) - 1)
		ok
		if EndsWith(_c_, "}")
			_c_ = StzLeft(_c_, StzLen(_c_) - 1)
		ok
		if _c_ = ""
			return _aOut_
		ok

		_aParts_ = StzSplit(_c_, ";")
		_np_ = len(_aParts_)
		for i = 1 to _np_
			_aC_ = This._ParseOneConstraint(_aParts_[i])
			if len(_aC_) > 0
				_aOut_ + _aC_
			ok
		next
		return _aOut_

	# "age:>:25" -> ["age",">","25"]; a plain value (no comparator) -> [].
	def _ParseOneConstraint(_cPart_)
		if len(StzFindCS(":", _cPart_, TRUE)) = 0
			return []
		ok
		_aSeg_ = StzSplit(_cPart_, ":")
		if len(_aSeg_) < 3
			return []
		ok
		return [ _aSeg_[1], _aSeg_[2], _aSeg_[3] ]

	def _NodeSatisfiesConstraints(aNodeProps, _aConstraints_)
		if NOT isList(aNodeProps)
			return FALSE
		ok
		_nc_ = len(_aConstraints_)
		for i = 1 to _nc_
			_aC_ = _aConstraints_[i]
			_cKey_ = _aC_[1]
			_cOp_  = _aC_[2]
			_cVal_ = _aC_[3]
			if NOT HasKey(aNodeProps, _cKey_)
				return FALSE
			ok
			if NOT This._CompareValues(aNodeProps[_cKey_], _cOp_, _cVal_)
				return FALSE
			ok
		next
		return TRUE

	def _CompareValues(vActual, _cOp_, cExpected)
		# Node property values are stored as real numbers (e.g. [:age = 30]);
		# do a numeric compare when the actual value is numeric, else fall
		# back to (case-insensitive) string (in)equality.
		if isNumber(vActual)
			_nA_ = vActual
			_nE_ = number("" + cExpected)
			switch _cOp_
			on ">"  return _nA_ > _nE_
			on "<"  return _nA_ < _nE_
			on "="  return _nA_ = _nE_
			on ">=" return _nA_ >= _nE_
			on "<=" return _nA_ <= _nE_
			on "!=" return _nA_ != _nE_
			off
			return FALSE
		ok

		_cA_ = "" + vActual
		switch _cOp_
		on "="  return This._LabelEq(_cA_, cExpected, FALSE)
		on "!=" return NOT This._LabelEq(_cA_, cExpected, FALSE)
		off
		return FALSE

	# Subsequence test with a parallel per-element case-sensitivity
	# vector. Default graphex matching is case-insensitive.
	def IsSubsequenceCS(_aPattern_, _aPatternCS_, aTarget)
		_nPatternLen_ = len(_aPattern_)
		_nTargetLen_ = len(aTarget)

		if _nPatternLen_ = 0
			return TRUE
		ok

		if _nPatternLen_ > _nTargetLen_
			return FALSE
		ok

		_nPatternIdx_ = 1

		for i = 1 to _nTargetLen_
			if This._LabelEq(_aPattern_[_nPatternIdx_], aTarget[i], _aPatternCS_[_nPatternIdx_])
				_nPatternIdx_++
				if _nPatternIdx_ > _nPatternLen_
					return TRUE
				ok
			ok
		next

		return FALSE

	def IsSubsequenceSimple(_aPattern_, aTarget)
		_nPatternLen_ = len(_aPattern_)
		_nTargetLen_ = len(aTarget)

		if _nPatternLen_ = 0
			return TRUE
		ok

		if _nPatternLen_ > _nTargetLen_
			return FALSE
		ok

		_nPatternIdx_ = 1

		for i = 1 to _nTargetLen_
			if _aPattern_[_nPatternIdx_] = aTarget[i]
				_nPatternIdx_++
				if _nPatternIdx_ > _nPatternLen_
					return TRUE
				ok
			ok
		next

		return FALSE
	
	def IsSubsequence(_aPattern_, aTarget, aPatternNegations)
		_nPatternLen_ = len(_aPattern_)
		_nTargetLen_ = len(aTarget)
		
		if _nPatternLen_ = 0
			return TRUE
		ok
		
		_nPatternIdx_ = 1
		
		for i = 1 to _nTargetLen_
			if _nPatternIdx_ <= _nPatternLen_
				_bNegated_ = aPatternNegations[_nPatternIdx_]
				_bMatches_ = (_aPattern_[_nPatternIdx_] = aTarget[i])
				
				if _bNegated_
					# Negated: if this label appears anywhere in target, fail
					if _bMatches_
						return FALSE
					ok
					# Skip to next pattern element (negation doesn't consume target element)
					_nPatternIdx_++
				else
					# Normal: advance when matched
					if _bMatches_
						_nPatternIdx_++
					ok
				ok
			ok
		next
		
		# Success if we processed all pattern elements
		return _nPatternIdx_ > _nPatternLen_


	# Enhanced: Better handling of token conversion to stzListex patterns
	def TokensToListexPattern(_aBranch_)
		_aPattern_ = []
		_nLenBranch_ = len(_aBranch_)
		
		for i = 1 to _nLenBranch_
			_cToken_ = _aBranch_[i]
			
			if isString(_cToken_)
				# Extract label from "edge(flows)" -> "flows"
				_nParenPos_ = StzFindFirst("(", _cToken_)
				if _nParenPos_ > 0
					_nClosePos_ = StzFindFirst(")", _cToken_)
					if _nClosePos_ > _nParenPos_
						_cLabel_ = @StzMid(_cToken_, _nParenPos_ + 1, _nClosePos_ - _nParenPos_ - 1)
						_aPattern_ + _cLabel_
					else
						_aPattern_ + :Any
					ok
				else
					_aPattern_ + :Any
				ok
			else
				_aPattern_ + :Any
			ok
		next
		
		return _aPattern_

	def ShowPatternGraph()
		This.Show()

	def EnableDebugMode()
		@bDebugMode = TRUE

		def EnableDebug()
			@bDebugMode = TRUE

	def DisableDebugMode()
		@bDebugMode = FALSE

		def DisableDebug()
			@bDebugMode = FALSE

	def SetDebugMode(pOnOff)
		if IsTrue(pOnOff)
			@bDebugMode = TRUE
		else
			@bDebugMode = FALSE
		ok

		def SetDebug(pOnOff)
			This.SetDebugMode(pOnOff)
