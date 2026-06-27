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

	def init(cPattern, oTargetGraph)
		super.init("PatternGraph")
		
		if NOT isString(cPattern) or NOT @IsStzGraph(oTargetGraph)
			raise("Error: Pattern must be a string and graph must be stzGraph")
		ok
		
		@cPattern = This.NormalizePattern(cPattern)
		@oTargetGraph = oTargetGraph

		try
			This.BuildPatternGraph(@cPattern)
		catch
			raise("Pattern initialization failed: " + cCatchError)
		done


	def NormalizePattern(cPattern)
		cPattern = trim(cPattern)
		
		if NOT (startsWith(cPattern, "{") and endsWith(cPattern, "}"))
			cPattern = "{" + cPattern + "}"
		ok
		
		return cPattern

	# Build the pattern as a graph: Nodes = tokens, Edges = sequences or alternates
	def BuildPatternGraph(cPattern)

		
		@aPendingAlternationBranches = []
		aTokens = This.ParsePattern(cPattern)
		
		
		if len(aTokens) = 0
			return
		ok
		
		nNodeCounter = 0
		nPrevNodeId = NULL
		nLenTokens = len(aTokens)
		
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			
			# Check if token is valid before accessing [:type]
			if NOT isList(aToken) or len(aToken) = 0
				loop
			ok
			
			# Safe key access using HasKey
			if NOT HasKey(aToken, :type)
				loop
			ok
			
			if aToken[:type] = "alternation"
				aAltNodes = []
				nLenAlternatives = len(aToken[:alternatives])
				
				for j = 1 to nLenAlternatives
					nNodeCounter++
					cAltNodeId = ":p" + nNodeCounter
					aAltToken = aToken[:alternatives][j]
					cLabel = aAltToken[:type] + iff(HasKey(aAltToken, :label) and aAltToken[:label] != "", "(" + aAltToken[:label] + ")", "")
					acProps = [ :min = aAltToken[:min], :max = aAltToken[:max],
							:negated = iff(aAltToken[:negated], "TRUE", "FALSE"),
							:cs = iff(HasKey(aAltToken, :cs) and aAltToken[:cs], "TRUE", "FALSE") ]
					if HasKey(aAltToken, :setvalues) and len(aAltToken[:setvalues]) > 0
						acProps + [ "set", "{" + JoinXT(aAltToken[:setvalues], ";") + "}" + iff(aAltToken[:unique], "U", "") ]
					ok
					This.AddNodeXTT(cAltNodeId, cLabel, acProps)
					
					# Connect to previous node
					if nPrevNodeId != NULL
						This.AddEdgeXT(nPrevNodeId, cAltNodeId, "sequences")
					ok
					
					aAltNodes + cAltNodeId
				next
				
				# Store all alternation branches - next node will connect from ALL of them
				@aPendingAlternationBranches = aAltNodes
				nPrevNodeId = NULL  # Signal that we need to connect from multiple nodes
			
			else
				# Regular node processing
				nNodeCounter++
				cNodeId = ":p" + nNodeCounter
				cLabel = aToken[:type]
				if HasKey(aToken, :label) and aToken[:label] != ""
					cLabel += "(" + aToken[:label] + ")"
				ok
				acProps = [ :min = aToken[:min], :max = aToken[:max],
						:negated = iff(aToken[:negated], "TRUE", "FALSE"),
						:cs = iff(HasKey(aToken, :cs) and aToken[:cs], "TRUE", "FALSE") ]
				if HasKey(aToken, :setvalues) and len(aToken[:setvalues]) > 0
					acProps + [ "set", "{" + JoinXT(aToken[:setvalues], ";") + "}" + iff(aToken[:unique], "U", "") ]
				ok
				This.AddNodeXTT(cNodeId, cLabel, acProps)
				
				# Connect from previous node
				if nPrevNodeId != NULL
					This.AddEdgeXT(nPrevNodeId, cNodeId, "sequences")
				ok
				
				# Connect from all pending alternation branches
				if len(@aPendingAlternationBranches) > 0
					nLenPending = len(@aPendingAlternationBranches)
					for k = 1 to nLenPending
						This.AddEdgeXT(@aPendingAlternationBranches[k], cNodeId, "sequences")
					next
					@aPendingAlternationBranches = []
				ok
				
				nPrevNodeId = cNodeId
			ok
		next
		

	# FIXED: Alternation parsing now correctly strips outer parentheses
	# before processing alternation groups
	def ParsePattern(cPattern)
		
		oPattern = new stzString(cPattern)
		cInner = oPattern.RemoveFirstAndLastCharsQ().Content()
		
		
		aParts = split(cInner, "->")
		
		
		aTokens = []
		nLenParts = len(aParts)
		
		for i = 1 to nLenParts
			cPart = trim(aParts[i])
			
			
			# Skip empty parts
			if cPart = ""
				loop
			ok
			
			# Check for alternation group wrapped in parentheses
			# Strip outer parentheses first, then check for pipe
			if startsWith(cPart, "(") and endsWith(cPart, ")")
				# Strip outer parentheses to get the inner content
				cInnerPart = @StzMid(cPart, 2, len(cPart) - 1)
				
				
				# Now check if the inner content contains alternation
				if contains(cInnerPart, "|")
					# Process as alternation without outer parentheses
					aAltTokens = []
					aAltParts = @split(cInnerPart, "|")
					nLenAltParts = len(aAltParts)
					bValidAlt = TRUE
					
					for j = 1 to nLenAltParts
						cAlt = trim(aAltParts[j])
						if cAlt != ""
							aToken = This.ParseSingleToken(cAlt)
							if isList(aToken) and len(aToken) > 0
								aAltTokens + aToken
							else
								bValidAlt = FALSE
								exit
							ok
						else
						ok
					next
					
					if bValidAlt and len(aAltTokens) > 0
						aTokens + [ [ "type", "alternation" ], [ "alternatives", aAltTokens ] ]
					else
						if len(aAltTokens) > 0
							aTokens + aAltTokens[1]
						else
							aFallback = This.ParseSingleToken(cPart)
							if isList(aFallback) and len(aFallback) > 0
								aTokens + aFallback
							ok
						ok
					ok
				else
					aResult = This.ParseSingleToken(cInnerPart)
					if isList(aResult) and len(aResult) > 0
						aTokens + aResult
					else
					ok
				ok
			else
				aResult = This.ParseSingleToken(cPart)
				if isList(aResult) and len(aResult) > 0
					aTokens + aResult
				else
				ok
			ok
		next
		
		return aTokens


	def ParseSingleToken(cTokenStr)
		cTokenStr = @trim(cTokenStr)
		
		
		if cTokenStr = ""
			return []
		ok
		
		bNegated = StartsWith(cTokenStr, "@!")
		if bNegated
			# Remove @! (positions 1-2), keep from position 3 onwards
			cTokenStr = "@" + @StzMid(cTokenStr, 3, len(cTokenStr))
		ok

		# Per-token case-sensitivity marker: a leading "@cs:" makes this
		# token match the target label case-sensitively. Default (no
		# marker) is case-insensitive. Strip it before type detection,
		# else startsWith(.., "@node") never fires on "@cs:@Node(..)".
		bCaseSensitive = FALSE
		if StartsWith(StzLower(cTokenStr), "@cs:")
			bCaseSensitive = TRUE
			cTokenStr = @StzMid(cTokenStr, 5, len(cTokenStr))
		ok

		# Now process cTokenStr normally with bNegated flag set...
		
		nMin = 1
		nMax = 1
		aSetValues = []
		bRequireUnique = FALSE
		cLabel = ""
		cProps = ""
	
		# Process quantifiers - look for +, *, ? at the end
		cLastChar = Right(cTokenStr, 1)
		if cLastChar = "+" or cLastChar = "*" or cLastChar = "?"
			switch cLastChar
			on "+"
				nMin = 1
				nMax = 999999
			on "*"
				nMin = 0
				nMax = 999999
			on "?"
				nMin = 0
				nMax = 1
			off
			cTokenStr = Left(cTokenStr, len(cTokenStr) - 1)
		ok
	
		# Process set constraints - look for {...}U or {...}
		nBraceStart = StzFindFirst(cTokenStr, "{")
		if nBraceStart > 0
			nBraceEnd = StzFindFirst(cTokenStr, "}")
			if nBraceEnd > nBraceStart
	
				# span BETWEEN the braces, not the absolute end index
				# (the old nBraceEnd count leaked the '}' into the set).
				cSetContent = @StzMid(cTokenStr, nBraceStart + 1, nBraceEnd - nBraceStart - 1)

				# Check for U after closing brace (single char lookahead)
				if nBraceEnd < len(cTokenStr) and @StzMid(cTokenStr, nBraceEnd + 1, 1) = "U"
					bRequireUnique = TRUE
					cTokenStr = StzLeft(cTokenStr, nBraceStart - 1) + @StzMid(cTokenStr, nBraceEnd + 2, len(cTokenStr))
				else
					cTokenStr = StzLeft(cTokenStr, nBraceStart - 1) + @StzMid(cTokenStr, nBraceEnd + 1, len(cTokenStr))
				ok
				
				# Parse set values
				if contains(cSetContent, ";")
					aSetValues = @split(cSetContent, ";")
				else
					aSetValues = [cSetContent]
				ok
			ok
		ok
	
		# Parse token type
		cTokenLower = StzLower(cTokenStr)
		
		if startsWith(cTokenLower, "@node")
			
			# Manual extraction: @Node(label){props}
			nParenStart = StzFindFirst(cTokenStr, "(")
			if nParenStart > 0
				nParenEnd = StzFindFirst(cTokenStr, ")")
				if nParenEnd > nParenStart
					cLabel = @StzMid(cTokenStr, nParenStart + 1, nParenEnd - nParenStart - 1)
				ok
			ok

			# Props already handled above in set constraints


			return [
				[ "type", "node" ],
				[ "label", cLabel ],
				[ "properties", cProps ],
				[ "min", nMin ],
				[ "max", nMax ],
				[ "setvalues", aSetValues ],
				[ "unique", bRequireUnique ],
				[ "negated", bNegated ],
				[ "cs", bCaseSensitive ]
			]
			
		but startsWith(cTokenLower, "@edge")
			
			# Manual extraction: @Edge(label){props}
			nParenStart = StzFindFirst(cTokenStr, "(")
			if nParenStart > 0
				nParenEnd = StzFindFirst(cTokenStr, ")")
				if nParenEnd > nParenStart
					cLabel = @StzMid(cTokenStr, nParenStart + 1, nParenEnd - nParenStart - 1)
				ok
			ok


			return [
				[ "type", "edge" ],
				[ "label", cLabel ],
				[ "properties", cProps ],
				[ "min", nMin ],
				[ "max", nMax ],
				[ "setvalues", aSetValues ],
				[ "unique", bRequireUnique ],
				[ "negated", bNegated ],
				[ "cs", bCaseSensitive ]
			]
			
		but startsWith(cTokenLower, "@cycle")
			return [
				[ "type", "cycle" ],
				[ "label", "" ],
				[ "properties", "" ],
				[ "min", nMin ],
				[ "max", nMax ],
				[ "setvalues", aSetValues ],
				[ "unique", bRequireUnique ],
				[ "negated", bNegated ],
				[ "cs", bCaseSensitive ]
			]
			
		but startsWith(cTokenLower, "@path")
			return [
				[ "type", "path" ],
				[ "label", "" ],
				[ "properties", "" ],
				[ "min", nMin ],
				[ "max", nMax ],
				[ "setvalues", aSetValues ],
				[ "unique", bRequireUnique ],
				[ "negated", bNegated ],
				[ "cs", bCaseSensitive ]
			]
			
		else
			return []
		ok


	def ListifyGraph(oGraph)
		aBranches = []
		acNodes = oGraph.Nodes()
		nLenNodes = len(acNodes)
		
		# Handle single isolated nodes
		for i = 1 to nLenNodes
			aNode = acNodes[i]
			cNodeId = aNode[:id]
			acNeighbors = oGraph.Neighbors(cNodeId)
			acIncoming = oGraph.Incoming(cNodeId)
			
			# If node has no connections, add it as single-node branch
			if len(acNeighbors) = 0 and len(acIncoming) = 0
				aBranches + [aNode[:label]]
			ok
		next
		
		# Process paths between connected nodes
		for i = 1 to nLenNodes
			aNode = acNodes[i]
			cStartId = aNode[:id]
			acReachable = oGraph.ReachableFrom(cStartId)
			nLenReachable = len(acReachable)
			for j = 1 to nLenReachable
				cEndId = acReachable[j]
				if cEndId != cStartId
					acPaths = oGraph.PathsXT(cStartId, cEndId)
					nLenPaths = len(acPaths)
					for k = 1 to nLenPaths
						aPath = acPaths[k]
						aBranch = []
						nLenPath = len(aPath)
						for m = 1 to nLenPath-1
							cFrom = aPath[m]
							cTo = aPath[m+1]
							# Get node by ID
							aNodeFrom = NULL
							nLenNodes = len(oGraph.Nodes())
							for n = 1 to nLenNodes
								if oGraph.Nodes()[n][:id] = cFrom
									aNodeFrom = oGraph.Nodes()[n]
									exit
								ok
							next
							if aNodeFrom != NULL
								aBranch + aNodeFrom[:label]
							ok
							aEdge = oGraph.Edge(cFrom, cTo)
							if aEdge != ""
								aBranch + aEdge[:label]
							ok
						next
						# Add final node
						aNodeTo = NULL
						nLenNodes = len(oGraph.Nodes())
						for n = 1 to nLenNodes
							if oGraph.Nodes()[n][:id] = aPath[nLenPath]
								aNodeTo = oGraph.Nodes()[n]
								exit
							ok
						next
						if aNodeTo != NULL
							aBranch + aNodeTo[:label]
						ok
						if len(aBranch) > 0
							aBranches + aBranch
						ok
					next
				ok
			next
		next
		
		# Handle cycles
		if oGraph.HasCyclicDependencies()
			acCyclicNodes = oGraph.CyclicNodes()
			nLenCyclic = len(acCyclicNodes)

			for i = 1 to nLenCyclic
				cNode = acCyclicNodes[i]
				acCyclePaths = oGraph.PathsXT(cNode, cNode)
				nLenCyclePaths = len(acCyclePaths)

				for j = 1 to nLenCyclePaths
					aPath = acCyclePaths[j]

					if len(aPath) > 1
						aBranch = ["@Cycle"]
						nLenPath = len(aPath)

						for k = 1 to nLenPath-1
							cFrom = aPath[k]
							cTo = aPath[k+1]
							# Get node by ID
							aNodeFrom = NULL
							nLenNodes = len(oGraph.Nodes())

							for n = 1 to nLenNodes
								if oGraph.Nodes()[n][:id] = cFrom
									aNodeFrom = oGraph.Nodes()[n]
									exit
								ok
							next

							if aNodeFrom != NULL
								aBranch + aNodeFrom[:label]
							ok

							aEdge = oGraph.Edge(cFrom, cTo)
							if aEdge != ""
								aBranch + aEdge[:label]
							ok

						next

						# Add final node
						aNodeTo = NULL
						nLenNodes = len(oGraph.Nodes())
						for n = 1 to nLenNodes
							if oGraph.Nodes()[n][:id] = aPath[nLenPath]
								aNodeTo = oGraph.Nodes()[n]
								exit
							ok
						next

						if aNodeTo != NULL
							aBranch + aNodeTo[:label]
						ok

						aBranches + aBranch
					ok
				next
			next
		ok

		return aBranches

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

		aPatternBranches = This.ListifyPatternGraph()
		aTargetBranches = This.ListifyGraph(oTargetGraph)

		if @bDebugMode
		ok

		_result_ = This.MatchBranches(aPatternBranches, aTargetBranches)

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
		aBranches = []
		acNodes = This.Nodes()
		nLenNodes = len(acNodes)
		
		if nLenNodes = 0
			return []
		ok
		
		# Find root nodes (no incoming edges)
		acRoots = []
		for i = 1 to nLenNodes
			aNode = acNodes[i]
			acIncoming = This.Incoming(aNode[:id])
			if len(acIncoming) = 0
				acRoots + aNode[:id]
			ok
		next
		
		if len(acRoots) = 0
			acRoots + acNodes[1][:id]
		ok
		
		if @bDebugMode
		ok
		
		# Traverse from each root
		nLenRoots = len(acRoots)
		for i = 1 to nLenRoots
			cRoot = acRoots[i]
			This.TraversePatternNode(cRoot, [], aBranches, [])
		next
		
		return aBranches
	
	def TraversePatternNode(cNodeId, aCurrentPath, aBranches, acVisited)
		aNode = This.Node(cNodeId)
		
		if aNode = ""
			return
		ok
		
		cLabel = aNode[:label]
		
		# Handle alternation nodes specially
		if cLabel = "Alternation"
			# Get alternation branches and continuation
			acNeighbors = This.Neighbors(cNodeId)
			nLenNeighbors = len(acNeighbors)
			
			# Find alternation branches (edges labeled "alternates")
			acAltBranches = []
			cContinuation = NULL
			
			for i = 1 to nLenNeighbors
				cNeighbor = acNeighbors[i]
				aEdge = This.Edge(cNodeId, cNeighbor)
				if aEdge[:label] = "alternates"
					acAltBranches + cNeighbor
				but aEdge[:label] = "sequences"
					cContinuation = cNeighbor
				ok
			next
			
			# Process each alternation branch
			nLenAlt = len(acAltBranches)
			for i = 1 to nLenAlt
				cAltNode = acAltBranches[i]
				aAltNode = This.Node(cAltNode)
				
				if aAltNode != ""
					# Create path with alternation branch
					aNewPath = []
					nLenPath = len(aCurrentPath)
					for j = 1 to nLenPath
						aNewPath + aCurrentPath[j]
					next
					aNewPath + aAltNode[:label]
					
					# Continue to the node after alternation if exists
					if cContinuation != NULL
						This.TraversePatternNode(cContinuation, aNewPath, aBranches, [])
					else
						# No continuation, this is the end
						if len(aNewPath) > 0
							aBranches + aNewPath
						ok
					ok
				ok
			next
		else
			# Regular node - add label to path
			aNewPath = []
			nLenPath = len(aCurrentPath)
			for j = 1 to nLenPath
				aNewPath + aCurrentPath[j]
			next
			aNewPath + cLabel
			
			# Get neighbors
			acNeighbors = This.Neighbors(cNodeId)
			
			if len(acNeighbors) = 0
				# End of path
				if len(aNewPath) > 0
					aBranches + aNewPath
				ok
			else
				# Continue traversal
				nLenNeighbors = len(acNeighbors)
				for i = 1 to nLenNeighbors
					This.TraversePatternNode(acNeighbors[i], aNewPath, aBranches, acVisited)
				next
			ok
		ok

	def MatchBranches(aPatternBranches, aTargetBranches)
		nLenPatternBranches = len(aPatternBranches)
		
		if @bDebugMode
		ok
		
		for i = 1 to nLenPatternBranches
			aPatternBranch = aPatternBranches[i]
			
			if @bDebugMode
			ok
			
			# Extract labels with per-token case-sensitivity + negation.
			# aPatternCS[j] / aForbiddenCS[j] carry whether that label
			# must match case-sensitively (the token had a @cs: marker).
			aPatternLabels = []
			aPatternCS = []
			aForbiddenLabels = []
			aForbiddenCS = []
			nLenPattern = len(aPatternBranch)

			for j = 1 to nLenPattern
				cToken = aPatternBranch[j]
				cLabel = ""

				nParenPos = StzFindFirst(cToken, "(")
				if nParenPos > 0
					nClosePos = StzFindFirst(cToken, ")")
					if nClosePos > nParenPos
						# count is the span BETWEEN the parens, not nClosePos-1
						# (which leaked the ')' into the label -> "start)").
						cLabel = @StzMid(cToken, nParenPos + 1, nClosePos - nParenPos - 1)
					ok
				ok

				# Read the pattern node's :negated / :cs flags from its
				# properties hashlist (the props are [ :min, :max,
				# :negated, :cs ], not "key=value" strings).
				bIsNegated = FALSE
				bIsCS = FALSE
				aNodeFromPattern = This.Node(":p" + j)
				if isList(aNodeFromPattern) and HasKey(aNodeFromPattern, :properties)
					acProps = aNodeFromPattern[:properties]
					if isList(acProps)
						if HasKey(acProps, :negated) and acProps[:negated] = "TRUE"
							bIsNegated = TRUE
						ok
						if HasKey(acProps, :cs) and acProps[:cs] = "TRUE"
							bIsCS = TRUE
						ok
					ok
				ok

				if cLabel != ""
					if bIsNegated
						aForbiddenLabels + cLabel
						aForbiddenCS + bIsCS
					else
						aPatternLabels + cLabel
						aPatternCS + bIsCS
					ok
				ok
			next

			if @bDebugMode
			ok

			# Check each target branch
			nLenTargetBranches = len(aTargetBranches)
			for k = 1 to nLenTargetBranches
				aTargetBranch = aTargetBranches[k]

				if @bDebugMode
				ok

				# First check forbidden labels - if any exist in target, skip this branch
				bHasForbidden = FALSE
				_nForbiddenLabelsLen_ = len(aForbiddenLabels)
				for m = 1 to _nForbiddenLabelsLen_
					_nTargetBranchLen_ = len(aTargetBranch)
					for n = 1 to _nTargetBranchLen_
						if This._LabelEq(aForbiddenLabels[m], aTargetBranch[n], aForbiddenCS[m])
							bHasForbidden = TRUE
							exit
						ok
					next
					if bHasForbidden
						exit
					ok
				next

				if bHasForbidden
					if @bDebugMode
					ok
					loop
				ok

				# Check if pattern labels appear as subsequence in target
				if This.IsSubsequenceCS(aPatternLabels, aPatternCS, aTargetBranch)
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
	def _LabelEq(c1, c2, bCS)
		if bCS
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
		aPatNodes = This.Nodes()
		aTgtNodes = oTargetGraph.Nodes()
		nLenPat = len(aPatNodes)

		for i = 1 to nLenPat
			aPat = aPatNodes[i]
			if NOT (isList(aPat) and HasKey(aPat, :properties))
				loop
			ok
			aProps = aPat[:properties]
			if NOT (isList(aProps) and HasKey(aProps, :set))
				loop
			ok

			aConstraints = This._ParseSetConstraints(aProps[:set])
			if len(aConstraints) = 0
				loop
			ok

			cPatLabel = This._BareLabel(aPat[:label])
			bCS = (HasKey(aProps, :cs) and aProps[:cs] = "TRUE")

			bFound = FALSE
			nLenTgt = len(aTgtNodes)
			for j = 1 to nLenTgt
				aTgt = aTgtNodes[j]
				if cPatLabel != "" and NOT This._LabelEq(cPatLabel, aTgt[:label], bCS)
					loop
				ok
				if This._NodeSatisfiesConstraints(aTgt[:properties], aConstraints)
					bFound = TRUE
					exit
				ok
			next

			if NOT bFound
				return FALSE
			ok
		next

		return TRUE

	# "node(Alice)" -> "Alice"; "node" (no parens) -> "".
	def _BareLabel(cLabel)
		if NOT isString(cLabel)
			return ""
		ok
		np = StzFindFirst(cLabel, "(")
		if np > 0
			nc = StzFindFirst(cLabel, ")")
			if nc > np
				return @StzMid(cLabel, np + 1, nc - np - 1)
			ok
		ok
		return ""

	# "{age:>:25;score:>:80}U" -> [ ["age",">","25"], ["score",">","80"] ]
	def _ParseSetConstraints(cSet)
		aOut = []
		if NOT isString(cSet)
			return aOut
		ok
		c = cSet
		if StartsWith(c, "{")
			c = @StzMid(c, 2, len(c))
		ok
		if EndsWith(c, "U")
			c = StzLeft(c, len(c) - 1)
		ok
		if EndsWith(c, "}")
			c = StzLeft(c, len(c) - 1)
		ok
		if c = ""
			return aOut
		ok

		aParts = StzSplit(c, ";")
		nP = len(aParts)
		for i = 1 to nP
			aC = This._ParseOneConstraint(aParts[i])
			if len(aC) > 0
				aOut + aC
			ok
		next
		return aOut

	# "age:>:25" -> ["age",">","25"]; a plain value (no comparator) -> [].
	def _ParseOneConstraint(cPart)
		if len(StzFindCS(":", cPart, TRUE)) = 0
			return []
		ok
		aSeg = StzSplit(cPart, ":")
		if len(aSeg) < 3
			return []
		ok
		return [ aSeg[1], aSeg[2], aSeg[3] ]

	def _NodeSatisfiesConstraints(aNodeProps, aConstraints)
		if NOT isList(aNodeProps)
			return FALSE
		ok
		nC = len(aConstraints)
		for i = 1 to nC
			aC = aConstraints[i]
			cKey = aC[1]
			cOp  = aC[2]
			cVal = aC[3]
			if NOT HasKey(aNodeProps, cKey)
				return FALSE
			ok
			if NOT This._CompareValues(aNodeProps[cKey], cOp, cVal)
				return FALSE
			ok
		next
		return TRUE

	def _CompareValues(vActual, cOp, cExpected)
		# Node property values are stored as real numbers (e.g. [:age = 30]);
		# do a numeric compare when the actual value is numeric, else fall
		# back to (case-insensitive) string (in)equality.
		if isNumber(vActual)
			nA = vActual
			nE = number("" + cExpected)
			switch cOp
			on ">"  return nA > nE
			on "<"  return nA < nE
			on "="  return nA = nE
			on ">=" return nA >= nE
			on "<=" return nA <= nE
			on "!=" return nA != nE
			off
			return FALSE
		ok

		cA = "" + vActual
		switch cOp
		on "="  return This._LabelEq(cA, cExpected, FALSE)
		on "!=" return NOT This._LabelEq(cA, cExpected, FALSE)
		off
		return FALSE

	# Subsequence test with a parallel per-element case-sensitivity
	# vector. Default graphex matching is case-insensitive.
	def IsSubsequenceCS(aPattern, aPatternCS, aTarget)
		nPatternLen = len(aPattern)
		nTargetLen = len(aTarget)

		if nPatternLen = 0
			return TRUE
		ok

		if nPatternLen > nTargetLen
			return FALSE
		ok

		nPatternIdx = 1

		for i = 1 to nTargetLen
			if This._LabelEq(aPattern[nPatternIdx], aTarget[i], aPatternCS[nPatternIdx])
				nPatternIdx++
				if nPatternIdx > nPatternLen
					return TRUE
				ok
			ok
		next

		return FALSE

	def IsSubsequenceSimple(aPattern, aTarget)
		nPatternLen = len(aPattern)
		nTargetLen = len(aTarget)

		if nPatternLen = 0
			return TRUE
		ok

		if nPatternLen > nTargetLen
			return FALSE
		ok

		nPatternIdx = 1

		for i = 1 to nTargetLen
			if aPattern[nPatternIdx] = aTarget[i]
				nPatternIdx++
				if nPatternIdx > nPatternLen
					return TRUE
				ok
			ok
		next

		return FALSE
	
	def IsSubsequence(aPattern, aTarget, aPatternNegations)
		nPatternLen = len(aPattern)
		nTargetLen = len(aTarget)
		
		if nPatternLen = 0
			return TRUE
		ok
		
		nPatternIdx = 1
		
		for i = 1 to nTargetLen
			if nPatternIdx <= nPatternLen
				bNegated = aPatternNegations[nPatternIdx]
				bMatches = (aPattern[nPatternIdx] = aTarget[i])
				
				if bNegated
					# Negated: if this label appears anywhere in target, fail
					if bMatches
						return FALSE
					ok
					# Skip to next pattern element (negation doesn't consume target element)
					nPatternIdx++
				else
					# Normal: advance when matched
					if bMatches
						nPatternIdx++
					ok
				ok
			ok
		next
		
		# Success if we processed all pattern elements
		return nPatternIdx > nPatternLen


	# Enhanced: Better handling of token conversion to stzListex patterns
	def TokensToListexPattern(aBranch)
		aPattern = []
		nLenBranch = len(aBranch)
		
		for i = 1 to nLenBranch
			cToken = aBranch[i]
			
			if isString(cToken)
				# Extract label from "edge(flows)" -> "flows"
				nParenPos = StzFindFirst(cToken, "(")
				if nParenPos > 0
					nClosePos = StzFindFirst(cToken, ")")
					if nClosePos > nParenPos
						cLabel = @StzMid(cToken, nParenPos + 1, nClosePos - nParenPos - 1)
						aPattern + cLabel
					else
						aPattern + :Any
					ok
				else
					aPattern + :Any
				ok
			else
				aPattern + :Any
			ok
		next
		
		return aPattern

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
