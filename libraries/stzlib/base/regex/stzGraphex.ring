# stzGraphex with Alternation Support, 1-Indexing, Robust Parsing, and Optimized Loops
# Fixed: Alternation parsing now strips outer parentheses correctly
class stzGraphex from stzGraph
	@cPattern		# Pattern string, e.g., "{@Node(start) -> (@Edge(flows)|@Edge(completes)) -> @Node(end)}"
	@bDebugMode = FALSE
	@oTargetGraph		# Target graph to match against

	# Match-result cache, keyed by target-graph signature.
	@aMatchCache = []	# list of [ signature, result ] pairs
	@nCacheHits = 0

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
							:negated = iff(aAltToken[:negated], "TRUE", "FALSE") ]
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
						:negated = iff(aToken[:negated], "TRUE", "FALSE") ]
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
		nBraceStart = StzFind(cTokenStr, "{")
		if nBraceStart > 0
			nBraceEnd = StzFind(cTokenStr, "}")
			if nBraceEnd > nBraceStart
	
				cSetContent = @StzMid(cTokenStr, nBraceStart + 1, nBraceEnd)
				
				# Check for U after closing brace
				if nBraceEnd < len(cTokenStr) and @StzMid(cTokenStr, nBraceEnd + 1, nBraceEnd + 2) = "U"
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
			nParenStart = StzFind(cTokenStr, "(")
			if nParenStart > 0
				nParenEnd = StzFind(cTokenStr, ")")
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
				[ "negated", bNegated ]
			]
			
		but startsWith(cTokenLower, "@edge")
			
			# Manual extraction: @Edge(label){props}
			nParenStart = StzFind(cTokenStr, "(")
			if nParenStart > 0
				nParenEnd = StzFind(cTokenStr, ")")
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
				[ "negated", bNegated ]
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
				[ "negated", bNegated ]
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
				[ "negated", bNegated ]
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
			
			# Extract labels and check for negations
			aPatternLabels = []
			aForbiddenLabels = []
			nLenPattern = len(aPatternBranch)
			
			for j = 1 to nLenPattern
				cToken = aPatternBranch[j]
				cLabel = ""
				
				nParenPos = StzFind(cToken, "(")
				if nParenPos > 0
					nClosePos = StzFind(cToken, ")")
					if nClosePos > nParenPos
						cLabel = @StzMid(cToken, nParenPos + 1, nClosePos - 1)
					ok
				ok

				# Check if negated
				aNodeFromPattern = This.Node(":p" + j)
				bIsNegated = FALSE
				if aNodeFromPattern != ""
					acProps = aNodeFromPattern[:properties]
					_nPropsLen_ = len(acProps)
					for k = 1 to _nPropsLen_
						if acProps[k] = "negated=TRUE"
							bIsNegated = TRUE
							exit
						ok
					next
				ok
				
				if cLabel != ""
					if bIsNegated
						aForbiddenLabels + cLabel
					else
						aPatternLabels + cLabel
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
						if aForbiddenLabels[m] = aTargetBranch[n]
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
				if This.IsSubsequenceSimple(aPatternLabels, aTargetBranch)
					if @bDebugMode
					ok
					return TRUE
				ok
			next
		next
		
		if @bDebugMode
		ok
		
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
				nParenPos = StzFind(cToken, "(")
				if nParenPos > 0
					nClosePos = StzFind(cToken, ")")
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
