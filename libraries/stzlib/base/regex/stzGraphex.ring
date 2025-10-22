# stzGraphex with Alternation Support, 1-Indexing, Robust Parsing, and Optimized Loops
# Fixed: Alternation parsing now strips outer parentheses correctly
class stzGraphex from stzGraph
	@cPattern		# Pattern string, e.g., "{@Node(start) -> (@Edge(flows)|@Edge(completes)) -> @Node(end)}"
	@bDebugMode = FALSE
	@oTargetGraph		# Target graph to match against

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
		
//		try
			? "=== INIT DEBUG ==="
			? "Input pattern: " + cPattern
			? "Normalized pattern: " + @cPattern
			? "Building pattern graph..."
			
			This.BuildPatternGraph(@cPattern)
			
			? "After BuildPatternGraph:"
			? "Node count: " + This.NodeCount()
			? "Edge count: " + This.EdgeCount()
			? "All nodes: " + @@(This.Nodes())
			
//		catch
			cError = cCatchError
			? "ERROR in init: " + cError
			raise("Pattern initialization failed: " + cError)
//		done


	def NormalizePattern(cPattern)
		cPattern = trim(cPattern)
		
		if NOT (startsWith(cPattern, "{") and endsWith(cPattern, "}"))
			cPattern = "{" + cPattern + "}"
		ok
		
		return cPattern

	# Build the pattern as a graph: Nodes = tokens, Edges = sequences or alternates
	def BuildPatternGraph(cPattern)

		? "=== BuildPatternGraph Debug ==="
		? "Calling ParsePattern..."
		
		@aPendingAlternationBranches = []
		aTokens = This.ParsePattern(cPattern)
		
		? "ParsePattern returned: " + @@(aTokens)
		? "Number of tokens: " + len(aTokens)
		
		if len(aTokens) = 0
			? "WARNING: No tokens parsed!"
			return
		ok
		
		nNodeCounter = 0
		nPrevNodeId = NULL
		nLenTokens = len(aTokens)
		
		for i = 1 to nLenTokens
			aToken = aTokens[i]
			
			? "Processing token #" + i + ": " + @@(aToken)
			
			# Check if token is valid before accessing [:type]
			if NOT isList(aToken) or len(aToken) = 0
				? "Invalid token at position " + i
				loop
			ok
			
			# Safe key access using HasKey
			if NOT HasKey(aToken, :type)
				? "Token missing :type key at position " + i
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
					acProps = [ "min=" + aAltToken[:min], "max=" + aAltToken[:max], 
							"negated=" + iff(aAltToken[:negated], "TRUE", "FALSE") ]
					if HasKey(aAltToken, :setvalues) and len(aAltToken[:setvalues]) > 0
						acProps + "set={" + JoinXT(aAltToken[:setvalues], ";") + "}" + iff(aAltToken[:unique], "U", "")
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
				acProps = [ "min=" + aToken[:min], "max=" + aToken[:max], 
						"negated=" + iff(aToken[:negated], "TRUE", "FALSE") ]
				if HasKey(aToken, :setvalues) and len(aToken[:setvalues]) > 0
					acProps + "set={" + JoinXT(aToken[:setvalues], ";") + "}" + iff(aToken[:unique], "U", "")
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
		
		? "Pattern graph built with " + This.NodeCount() + " nodes"

	# FIXED: Alternation parsing now correctly strips outer parentheses
	# before processing alternation groups
	def ParsePattern(cPattern)
		? "=== ParsePattern Debug ==="
		? "Input pattern: " + cPattern
		
		oPattern = new stzString(cPattern)
		cInner = oPattern.RemoveFirstAndLastCharsQ().Content()
		
		? "After removing {}: " + cInner
		
		aParts = split(cInner, "->")
		
		? "Parts after split: " + @@(aParts)
		? "Number of parts: " + len(aParts)
		
		aTokens = []
		nLenParts = len(aParts)
		
		for i = 1 to nLenParts
			cPart = trim(aParts[i])
			
			? "Processing part #" + i + ": [" + cPart + "]"
			
			# Skip empty parts
			if cPart = ""
				? "  Skipping empty part"
				loop
			ok
			
			# FIX: Check for alternation group wrapped in parentheses
			# Strip outer parentheses first, then check for pipe
			if startsWith(cPart, "(") and endsWith(cPart, ")")
				# Strip outer parentheses to get the inner content
				cInnerPart = @substr(cPart, 2, len(cPart) - 1)
				
				? "  Stripped parentheses: [" + cInnerPart + "]"
				
				# Now check if the inner content contains alternation
				if contains(cInnerPart, "|")
					? "  Detected alternation"
					# Process as alternation without outer parentheses
					aAltTokens = []
					aAltParts = @split(cInnerPart, "|")
					nLenAltParts = len(aAltParts)
					bValidAlt = TRUE
					
					for j = 1 to nLenAltParts
						cAlt = trim(aAltParts[j])
						? "    Alternation part #" + j + ": [" + cAlt + "]"
						if cAlt != ""
							aToken = This.ParseSingleToken(cAlt)
							if isList(aToken) and len(aToken) > 0
								aAltTokens + aToken
								? "      Token parsed successfully"
							else
								? "      WARNING: Invalid alternation part: " + cAlt
								bValidAlt = FALSE
								exit
							ok
						else
							? "      WARNING: Empty alternation part"
						ok
					next
					
					if bValidAlt and len(aAltTokens) > 0
						? "  Adding alternation token with " + len(aAltTokens) + " alternatives"
						aTokens + [ [ "type", "alternation" ], [ "alternatives", aAltTokens ] ]
					else
						? "  Alternation invalid, using fallback"
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
					? "  No alternation, parsing as single token"
					aResult = This.ParseSingleToken(cInnerPart)
					if isList(aResult) and len(aResult) > 0
						aTokens + aResult
						? "    Token added"
					else
						? "    WARNING: Failed to parse token"
					ok
				ok
			else
				? "  No parentheses, parsing as single token"
				aResult = This.ParseSingleToken(cPart)
				if isList(aResult) and len(aResult) > 0
					aTokens + aResult
					? "    Token added"
				else
					? "    WARNING: Failed to parse token"
				ok
			ok
		next
		
		? "ParsePattern returning " + len(aTokens) + " tokens"
		return aTokens


	def ParseSingleToken(cTokenStr)
		cTokenStr = @trim(cTokenStr)
		
		? "  ==> ParseSingleToken: [" + cTokenStr + "]"
		
		if cTokenStr = ""
			? "      Empty token"
			return []
		ok
		
		bNegated = StartsWith(cTokenStr, "@!")
		if bNegated
			# Remove @! (positions 1-2), keep from position 3 onwards
			cTokenStr = "@" + @substr(cTokenStr, 3, len(cTokenStr))
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
		nBraceStart = substr(cTokenStr, "{")
		if nBraceStart > 0
			nBraceEnd = substr(cTokenStr, "}")
			if nBraceEnd > nBraceStart
	
				cSetContent = @substr(cTokenStr, nBraceStart + 1, nBraceEnd)
				
				# Check for U after closing brace
				if nBraceEnd < len(cTokenStr) and @substr(cTokenStr, nBraceEnd + 1, nBraceEnd + 2) = "U"
					bRequireUnique = TRUE
					cTokenStr = left(cTokenStr, nBraceStart - 1) + @substr(cTokenStr, nBraceEnd + 2, len(cTokenStr))
				else
					cTokenStr = left(cTokenStr, nBraceStart - 1) + @substr(cTokenStr, nBraceEnd + 1, len(cTokenStr))
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
		cTokenLower = lower(cTokenStr)
		? "      cTokenLower = [" + cTokenLower + "]"
		
		if startsWith(cTokenLower, "@node")
			? "      Parsing as @Node"
			
			# Manual extraction: @Node(label){props}
			nParenStart = substr(cTokenStr, "(")
			if nParenStart > 0
				nParenEnd = substr(cTokenStr, ")")
				if nParenEnd > nParenStart
					cLabel = @substr(cTokenStr, nParenStart + 1, nParenEnd - 1)
				ok
			ok
			
			# Props already handled above in set constraints
			
			? "      Matched: label=[" + cLabel + "]"
			
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
			? "      Parsing as @Edge"
			
			# Manual extraction: @Edge(label){props}
			nParenStart = substr(cTokenStr, "(")
			if nParenStart > 0
				nParenEnd = substr(cTokenStr, ")")
				if nParenEnd > nParenStart
					cLabel = @substr(cTokenStr, nParenStart + 1, nParenEnd - 1)
				ok
			ok
			
			? "      Matched: label=[" + cLabel + "]"
			
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
			? "      Parsing as @Cycle"
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
			? "      Parsing as @Path"
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
			? "      WARNING: Invalid token type"
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
					acPaths = oGraph.FindAllPaths(cStartId, cEndId)
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
		if oGraph.CyclicDependencies()
			acCyclicNodes = oGraph._GetCyclicNodes()
			nLenCyclic = len(acCyclicNodes)

			for i = 1 to nLenCyclic
				cNode = acCyclicNodes[i]
				acCyclePaths = oGraph.FindAllPaths(cNode, cNode)
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
//		try
			# For pattern graph, use special traversal
			aPatternBranches = This.ListifyPatternGraph()
			# For target graph, use normal listification
			aTargetBranches = This.ListifyGraph(oTargetGraph)
			
			if @bDebugMode
				? "Pattern branches:"
				? @@(aPatternBranches)
				? "Target branches:"
				? @@(aTargetBranches)
			ok
			
			return This.MatchBranches(aPatternBranches, aTargetBranches)
/*		catch
			if @bDebugMode
				? "Error during matching: " + cCatchError
			ok
			return FALSE
		done
*/
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
			? "Pattern graph roots: " + @@(acRoots)
			? "Pattern graph nodes: " + nLenNodes
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
			? "=== MatchBranches Debug ==="
			? "Number of pattern branches: " + nLenPatternBranches
			? "Number of target branches: " + len(aTargetBranches)
		ok
		
		for i = 1 to nLenPatternBranches
			aPatternBranch = aPatternBranches[i]
			
			if @bDebugMode
				? "Pattern branch #" + i + ": " + @@(aPatternBranch)
			ok
			
			# Extract labels and check for negations
			aPatternLabels = []
			aForbiddenLabels = []
			nLenPattern = len(aPatternBranch)
			
			for j = 1 to nLenPattern
				cToken = aPatternBranch[j]
				cLabel = ""
				
				nParenPos = substr(cToken, "(")
				if nParenPos > 0
					nClosePos = substr(cToken, ")")
					if nClosePos > nParenPos
						cLabel = @substr(cToken, nParenPos + 1, nClosePos - 1)
					ok
				ok
				
				# Check if negated
				aNodeFromPattern = This.Node(":p" + j)
				bIsNegated = FALSE
				if aNodeFromPattern != ""
					acProps = aNodeFromPattern[:properties]
					for k = 1 to len(acProps)
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
				? "Pattern labels: " + @@(aPatternLabels)
				? "Forbidden labels: " + @@(aForbiddenLabels)
			ok
			
			# Check each target branch
			nLenTargetBranches = len(aTargetBranches)
			for k = 1 to nLenTargetBranches
				aTargetBranch = aTargetBranches[k]
				
				if @bDebugMode
					? "  Testing against target branch #" + k + ": " + @@(aTargetBranch)
				ok
				
				# First check forbidden labels - if any exist in target, skip this branch
				bHasForbidden = FALSE
				for m = 1 to len(aForbiddenLabels)
					for n = 1 to len(aTargetBranch)
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
						? "  Forbidden label found, skipping"
					ok
					loop
				ok
				
				# Check if pattern labels appear as subsequence in target
				if This.IsSubsequenceSimple(aPatternLabels, aTargetBranch)
					if @bDebugMode
						? "  MATCH FOUND!"
					ok
					return TRUE
				ok
			next
		next
		
		if @bDebugMode
			? "No matches found"
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
				nParenPos = substr(cToken, "(")
				if nParenPos > 0
					nClosePos = substr(cToken, ")")
					if nClosePos > nParenPos
						cLabel = @substr(cToken, nParenPos + 1, nClosePos - nParenPos - 1)
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
