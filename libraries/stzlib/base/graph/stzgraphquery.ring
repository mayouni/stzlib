#====================================================#
#  stzGraphQuery - OpenCypher-oriented Query System  #
#  Elegant graph pattern matching for stzGraph       #
#====================================================#

func StzGraphQueryQ(oGraph)
	return new stzGraphQuery(oGraph)

class stzGraphQuery
	@oGraph
	@aMatchPatterns = []
	@aWhereConditions = []
	@aReturnFields = []
	@aCreatePatterns = []
	@aSetOperations = []
	@aDeleteTargets = []
	@nLimit = ""
	@nSkip = 0
	@aOrderBy = []
	@bDistinct = FALSE
	
	def init(oGraph)
		if NOT @IsStzGraph(oGraph)
			stzraise("Parameter must be a stzGraph object!")
		ok
		@oGraph = ref(oGraph) # The query could change the graph
	
	def GraphObject()
		return @oGraph

		def GraphQ()
			return @oGraph

	#------------------#
	#  MATCH PATTERNS  #
	#------------------#
	
	def Match(paPattern)
		# Pattern formats:
		# [:node, "varname"]
		# [:node, "varname", "label"]
		# [:node, "varname", [:prop = val]]
		# [:rel, "var1", "var2", "label"]
		# [:rel, "var1", "var2", [:type = "KNOWS"]]
		# [:path, "var1", "rel", "var2"]
		
		@aMatchPatterns + paPattern
	
		def MatchQ(paPattern)
			This.Match(paPattern)
			return This

	def Where(pCondition)
		# Condition formats:
		# [:equals, "n.age", 25]
		# [:gt, "n.salary", 50000]
		# [:contains, "n.name", "John"]
		# [:and, cond1, cond2]
		# [:or, cond1, cond2]
		# [:not, cond]
		# Or function: func(aBindings) { ... }
		
		@aWhereConditions + pCondition

		def WhereQ(pCondition)
			This.Where(pCondition)
			return This

		def WhereF(pCondition)
			This.Where(pCondition)

			def WhereFQ(pCondition)
				return This.WhereQ(pCondition)

	def Return_(paFields)
		# Field formats:
		# "n"
		# "n.name"
		# [:as, "n.age", "years"]
		# [:count, "n"]
		# [:distinct, "n.type"]
		
		if isString(paFields)
			@aReturnFields + paFields
	
		but isList(paFields)
			# Check if it's a single pattern like [:as, "n.age", "years"]
			# or a list of field names like ["a", "b"]
			if len(paFields) > 0
				pFirst = paFields[1]
				# Check if first element is a keyword (as, count, distinct)
				if pFirst = "as" or pFirst = "count" or pFirst = "distinct"
					# It's a single special pattern - add as-is
					@aReturnFields + paFields
				else
					# It's a list of field names - add each one
					nLen = len(paFields)
					for i = 1 to nLen
						@aReturnFields + paFields[i]
					next
				ok
			ok
		ok
	
		def ReturnQ(paFields)
			This.Return_(paFields)
			return This

	def Distinct()
		@bDistinct = TRUE
	
		def DistinctQ()
			This.Distinct()
			return This

	def OrderBy(pcField, pcDirection)
		if NOT isString(pcDirection)
			pcDirection = :asc
		ok
		@aOrderBy + [pcField, lower(pcDirection)]
	
		def OrderByQ(pcField, pcDirection)
			This.OrderBy(pcField, pcDirection)
			return This

	def Limit(pnLimit)
		@nLimit = pnLimit
	
		def LimitQ(pnLimit)
			This.Limit(pnLimit)
			return This

	def Skip(pnSkip)
		@nSkip = pnSkip
	
		def SkipQ(pnSkip)
			This.Skip(pnSkip)
			return This

	#------------------#
	#  CREATE/UPDATE   #
	#------------------#
	
	def Create(paPattern)
		@aCreatePatterns + paPattern
	
		def CreateQ(paPattern)
			This.Create(paPattern)
			return This

	def Set(paOperation)
		# Operation formats:
		# [:set, "n.age", 26]
		# [:set, "n", [:status = "active"]]
		# [:remove, "n.temp"]
		
		@aSetOperations + paOperation
	
		def SetQ(paOperation)
			This.Set(paOperation)
			return This

	def Delete(paTargets)
		if isString(paTargets)
			@aDeleteTargets + paTargets

		but isList(paTargets)
			nLen = len(paTargets)
			for i = 1 to nLen
				@aDeleteTargets + paTargets[i]
			next
		ok
	
		def DeleteQ(paTargets)
			This.Delete(paTargets)
			return This

	#-------------------#
	#  QUERY EXECUTION  #
	#-------------------#
	
	def Run()
		# Execute the query and return results
		aBindings = []
		
		# Phase 1: MATCH - Find matching patterns
		if len(@aMatchPatterns) > 0
			aBindings = This._ExecuteMatch()
		ok
		
		# Phase 2: WHERE - Filter bindings
		if len(@aWhereConditions) > 0
			aBindings = This._ApplyWhere(aBindings)
		ok
		
		# Phase 3: CREATE - Create new elements
		if len(@aCreatePatterns) > 0
			This._ExecuteCreate(aBindings)
		ok
		
		# Phase 4: SET - Update properties
		if len(@aSetOperations) > 0
			This._ExecuteSet(aBindings)
		ok
		
		# Phase 5: DELETE - Remove elements
		if len(@aDeleteTargets) > 0
			This._ExecuteDelete(aBindings)
		ok
		
		# Phase 6: RETURN - Project results
		if len(@aReturnFields) > 0
			aBindings = This._ExecuteReturn(aBindings)
		ok
		
		# Phase 7: ORDER BY
		if len(@aOrderBy) > 0
			aBindings = This._ApplyOrderBy(aBindings)
		ok
		
		# Phase 8: SKIP
		if @nSkip > 0
			aBindings = This._ApplySkip(aBindings)
		ok
		
		# Phase 9: LIMIT
		if @nLimit != ""
			aBindings = This._ApplyLimit(aBindings)
		ok
		
		return aBindings
	
		def Execute()
			return This.Run()
	
	#-----------------------#
	#  PATTERN MATCHING     #
	#-----------------------#
	
	def _ExecuteMatch()
		aAllBindings = []
		
		nLen = len(@aMatchPatterns)
		for i = 1 to nLen
			aPattern = @aMatchPatterns[i]
			cPatternType = aPattern[1]
			
			if cPatternType = :node
				aNodeBindings = This._MatchNode(aPattern)
				aAllBindings = This._MergeBindings(aAllBindings, aNodeBindings)
				
			but cPatternType = :rel or cPatternType = :relationship
				aRelBindings = This._MatchRelationship(aPattern)
				aAllBindings = This._MergeBindings(aAllBindings, aRelBindings)
				
			but cPatternType = :path
				aPathBindings = This._MatchPath(aPattern)
				aAllBindings = This._MergeBindings(aAllBindings, aPathBindings)
			ok
		next
		
		return aAllBindings
	
	def _MatchNode(aPattern)
		cVarName = aPattern[2]
		aBindings = []
		
		aNodes = @oGraph.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			bMatch = TRUE
			
			if len(aPattern) >= 3 and isString(aPattern[3])
				if aNode[:label] != aPattern[3]
					bMatch = FALSE
				ok
			ok
			
			if len(aPattern) >= 3 and isList(aPattern[3])
				aProps = aPattern[3]
				acKeys = keys(aProps)
				nKeyLen = len(acKeys)
				
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					pValue = aProps[cKey]
					
					# Check if it's matching the node ID (special case)
					if cKey = "id"
						if aNode[:id] != pValue
							bMatch = FALSE
							exit
						ok
					# Otherwise check properties
					else
						if NOT This._NodeHasProperty(aNode, cKey, pValue)
							bMatch = FALSE
							exit
						ok
					ok
				next
			ok
			
			if bMatch
				aBinding = []
				aBinding[cVarName] = aNode
				aBindings + aBinding
			ok
		next
		
		return aBindings
	
	def _MatchRelationship(aPattern)
		# Pattern: [:rel, "fromVar", "toVar", label_or_props]
		cFromVar = aPattern[2]
		cToVar = aPattern[3]
		aBindings = []
		
		# Get all edges
		aEdges = @oGraph.Edges()
		nLen = len(aEdges)
		
		for i = 1 to nLen
			aEdge = aEdges[i]
			bMatch = TRUE
			
			# Check label/type if specified
			if len(aPattern) >= 4 and isString(aPattern[4])
				if aEdge[:label] != aPattern[4]
					bMatch = FALSE
				ok
			ok
			
			# Check properties if specified
			if len(aPattern) >= 4 and isList(aPattern[4])
				aProps = aPattern[4]
				acKeys = keys(aProps)
				nKeyLen = len(acKeys)
				
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					if NOT This._EdgeHasProperty(aEdge, cKey, aProps[cKey])
						bMatch = FALSE
						exit
					ok
				next
			ok
			
			if bMatch
				aBinding = []
				aBinding[cFromVar] = @oGraph.Node(aEdge[:from])
				aBinding[cToVar] = @oGraph.Node(aEdge[:to])
				aBinding["_rel_"] = aEdge
				aBindings + aBinding
			ok
		next
		
		return aBindings
	
	def _MatchPath(aPattern)
		# Pattern: [:path, "startVar", "relVar", "endVar"]
		cStartVar = aPattern[2]
		cRelVar = aPattern[3]
		cEndVar = aPattern[4]
		aBindings = []
		
		# Get all edges for path matching
		aEdges = @oGraph.Edges()
		nLen = len(aEdges)
		
		for i = 1 to nLen
			aEdge = aEdges[i]
			aBinding = []
			aBinding[cStartVar] = @oGraph.Node(aEdge[:from])
			aBinding[cRelVar] = aEdge
			aBinding[cEndVar] = @oGraph.Node(aEdge[:to])
			aBindings + aBinding
		next
		
		return aBindings
	
	def _MergeBindings(aExisting, aNew)
		if len(aExisting) = 0
			return aNew
		ok
		
		if len(aNew) = 0
			return aExisting
		ok
		
		# Cross product with compatibility check
		aMerged = []
		nExistLen = len(aExisting)
		nNewLen = len(aNew)
		
		for i = 1 to nExistLen
			aExistBinding = aExisting[i]
			
			for j = 1 to nNewLen
				aNewBinding = aNew[j]
				
				# Check if bindings are compatible
				if This._BindingsCompatible(aExistBinding, aNewBinding)
					# Merge them
					aCombined = []
					acExistKeys = keys(aExistBinding)
					nKeyLen = len(acExistKeys)
					
					for k = 1 to nKeyLen
						aCombined[acExistKeys[k]] = aExistBinding[acExistKeys[k]]
					next
					
					acNewKeys = keys(aNewBinding)
					nKeyLen = len(acNewKeys)
					
					for k = 1 to nKeyLen
						if NOT HasKey(aCombined, acNewKeys[k])
							aCombined[acNewKeys[k]] = aNewBinding[acNewKeys[k]]
						ok
					next
					
					aMerged + aCombined
				ok
			next
		next
		
		return aMerged
	
	def _BindingsCompatible(aBinding1, aBinding2)
		# Check if two bindings can be merged
		acKeys1 = keys(aBinding1)
		acKeys2 = keys(aBinding2)
		
		nLen1 = len(acKeys1)
		for i = 1 to nLen1
			cKey = acKeys1[i]
			if HasKey(aBinding2, cKey)
				# Same variable must bind to same value
				if aBinding1[cKey][:id] != aBinding2[cKey][:id]
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	#------------------#
	#  WHERE FILTERS   #
	#------------------#
	
	def _ApplyWhere(aBindings)
		
		aFiltered = []
		nLen = len(aBindings)
		
		for i = 1 to nLen
			aBinding = aBindings[i]
			bPass = TRUE
			
			nCondLen = len(@aWhereConditions)
			for j = 1 to nCondLen
				if NOT This._EvaluateCondition(@aWhereConditions[j], aBinding)
					bPass = FALSE
					exit
				ok
			next
			
			if bPass
				aFiltered + aBinding
			ok
		next

		return aFiltered
	
	def _EvaluateCondition(pCondition, aBinding)
	
		if @IsFunction(pCondition)
			return call pCondition(aBinding)
		ok
		
		if NOT isList(pCondition)
			return TRUE
		ok
		
		cOp = pCondition[1]
		
		if cOp = :equals or cOp = "="
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = pCondition[3]  # Don't resolve - keep as literal
			
			# If right side looks like a property path, resolve it
			if isString(pRight) and substr(pRight, ".") > 0
				pRight = This._ResolveValue(pRight, aBinding)
			ok
			
			return pLeft = pRight
			
		but cOp = :gt or cOp = ">"
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft > pRight
			
		but cOp = :lt or cOp = "<"
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft < pRight
			
		but cOp = :gte or cOp = ">="
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft >= pRight
			
		but cOp = :lte or cOp = "<="
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft <= pRight
			
		but cOp = :contains
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isString(pLeft) and isString(pRight) and substr(lower(pLeft), lower(pRight)) > 0
			
		but cOp = :startswith
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isString(pLeft) and isString(pRight) and left(lower(pLeft), len(pRight)) = lower(pRight)
			
		but cOp = :endswith
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			pRight = This._ResolveValue(pCondition[3], aBinding)
			return isString(pLeft) and isString(pRight) and right(lower(pLeft), len(pRight)) = lower(pRight)
			
		but cOp = :and
			return This._EvaluateCondition(pCondition[2], aBinding) and
			       This._EvaluateCondition(pCondition[3], aBinding)
			       
		but cOp = :or
			return This._EvaluateCondition(pCondition[2], aBinding) or
			       This._EvaluateCondition(pCondition[3], aBinding)
			       
		but cOp = :not
			return NOT This._EvaluateCondition(pCondition[2], aBinding)
			
		but cOp = "in"
			pLeft = This._ResolveValue(pCondition[2], aBinding)
			aRight = pCondition[3]  # Literal list, don't resolve
			return isList(aRight) and ring_find(aRight, pLeft) > 0
		ok
		
		return TRUE
	
	def _ResolveValue(pValue, aBinding)
		if isString(pValue)
			# Check if it's a variable reference like "n.age" or "m.id"
			if substr(pValue, ".") > 0
				acParts = @split(pValue, ".")
				cVar = acParts[1]
				cProp = acParts[2]
				
				if HasKey(aBinding, cVar)
					aNode = aBinding[cVar]
					
					# Special case: accessing .id gets the node's top-level id
					if cProp = "id"
						if HasKey(aNode, :id)
							return aNode[:id]
						ok
					ok
					
					# Regular property access
					if HasKey(aNode, :properties) and HasKey(aNode[:properties], cProp)
						return aNode[:properties][cProp]
					ok
				ok
				return NULL
			ok
			
			# Check if it's just a variable
			if HasKey(aBinding, pValue)
				return aBinding[pValue]
			ok
		ok
		
		# Return as-is (literal value)
		return pValue
	
	#---------------------#
	#  RETURN PROJECTION  #
	#---------------------#
	
	def _ExecuteReturn(aBindings)
		aResults = []
		nLen = len(aBindings)
		
		for i = 1 to nLen
			aBinding = aBindings[i]
			aResult = []
			
			nFieldLen = len(@aReturnFields)
			for j = 1 to nFieldLen
				pField = @aReturnFields[j]
				
				if isString(pField)
					# Simple field: "n" or "n.age"
					pValue = This._ResolveValue(pField, aBinding)
					aResult[pField] = pValue
				
				but isList(pField) and pField[1] = :as
					# Aliased field: [:as, "n.age", "years"]
					pValue = This._ResolveValue(pField[2], aBinding)
					aResult[pField[3]] = pValue
					
				but isList(pField) and pField[1] = :count
					# Aggregation handled separately
					loop
				ok
			next
			
			aResults + aResult
		next
		
		# Handle DISTINCT
		if @bDistinct
			aResults = This._ApplyDistinct(aResults)
		ok
		
		return aResults
	
	def _ApplyDistinct(aResults)
		aUnique = []
		nLen = len(aResults)
		
		for i = 1 to nLen
			aResult = aResults[i]
			bFound = FALSE
			
			nUniqueLen = len(aUnique)
			for j = 1 to nUniqueLen
				if This._ResultsEqual(aResult, aUnique[j])
					bFound = TRUE
					exit
				ok
			next
			
			if NOT bFound
				aUnique + aResult
			ok
		next
		
		return aUnique
	
	def _ResultsEqual(aResult1, aResult2)
		acKeys1 = keys(aResult1)
		acKeys2 = keys(aResult2)
		
		if len(acKeys1) != len(acKeys2)
			return FALSE
		ok
		
		nLen = len(acKeys1)
		for i = 1 to nLen
			cKey = acKeys1[i]
			if NOT HasKey(aResult2, cKey)
				return FALSE
			ok
			
			pVal1 = aResult1[cKey]
			pVal2 = aResult2[cKey]
			
			# If values are nodes, compare by ID
			if isList(pVal1) and isList(pVal2) and HasKey(pVal1, :id) and HasKey(pVal2, :id)
				if pVal1[:id] != pVal2[:id]
					return FALSE
				ok
			# Otherwise compare directly
			else
				if pVal1 != pVal2
					return FALSE
				ok
			ok
		next
		
		return TRUE
	
	#------------------#
	#  CREATE/UPDATE   #
	#------------------#
	
	def _ExecuteCreate(aBindings)
		
		nLen = len(@aCreatePatterns)
		for i = 1 to nLen
			aPattern = @aCreatePatterns[i]
			cPatternType = aPattern[1]
			
			if cPatternType = :node
				This._CreateNode(aPattern)
			but cPatternType = :rel or cPatternType = :relationship
				This._CreateRelationship(aPattern, aBindings)
			ok
		next
	
	def _CreateNode(aPattern)
		# Pattern: [:node, "varname", label, properties]
		cLabel = ""
		aProps = []
		
		if len(aPattern) >= 3 and isString(aPattern[3])
			cLabel = aPattern[3]
		ok
		
		if len(aPattern) >= 4 and isList(aPattern[4])
			aProps = aPattern[4]
		ok
		
		# Generate unique ID
		cNodeId = "node_" + UUID()
		@oGraph.AddNodeXTT(cNodeId, cLabel, aProps)

	def _CreateRelationship(aPattern, aBindings)
		cFromVar = aPattern[2]
		cToVar = aPattern[3]
		cLabel = ""
		aProps = []
		
		if len(aPattern) >= 4 and isString(aPattern[4])
			cLabel = aPattern[4]
		ok
		
		if len(aPattern) >= 5 and isList(aPattern[5])
			aProps = aPattern[5]
		ok
		
		nLen = len(aBindings)
		for i = 1 to nLen
			aBinding = aBindings[i]
			
			if HasKey(aBinding, cFromVar) and HasKey(aBinding, cToVar)
				cFromId = aBinding[cFromVar][:id]
				cToId = aBinding[cToVar][:id]
				@oGraph.AddEdgeXTT(cFromId, cToId, cLabel, aProps)
			ok
		next
	
	def _ExecuteSet(aBindings)
		nLen = len(@aSetOperations)
		
		for i = 1 to nLen
			aOp = @aSetOperations[i]
			cOpType = aOp[1]
			
			if cOpType = :set
				This._ExecuteSetProperty(aOp, aBindings)
				
			but cOpType = :remove
				This._ExecuteRemoveProperty(aOp, aBindings)
			ok
		next
	
	def _ExecuteSetProperty(aOp, aBindings)
		# Operation: [:set, "n.age", 26]
		cTarget = aOp[2]
		pValue = aOp[3]
		
		nLen = len(aBindings)
		for i = 1 to nLen
			aBinding = aBindings[i]
			
			if substr(cTarget, ".") > 0
				acParts = @split(cTarget, ".")
				cVar = acParts[1]
				cProp = acParts[2]
				
				if HasKey(aBinding, cVar)
					aNode = aBinding[cVar]
					@oGraph.SetNodeProperty(aNode[:id], cProp, pValue)
				ok
			ok
		next
	
	def _ExecuteRemoveProperty(aOp, aBindings)
		# Operation: [:remove, "n.temp"]
		cTarget = aOp[2]
		
		nLen = len(aBindings)
		for i = 1 to nLen
			aBinding = aBindings[i]
			
			if substr(cTarget, ".") > 0
				acParts = @split(cTarget, ".")
				cVar = acParts[1]
				cProp = acParts[2]
				
				if HasKey(aBinding, cVar)
					aNode = aBinding[cVar]
					# Remove property (set to NULL or empty)
					@oGraph.SetNodeProperty(aNode[:id], cProp, NULL)
				ok
			ok
		next
	
	def _ExecuteDelete(aBindings)
		acToDelete = []
		
		nLen = len(aBindings)
		for i = 1 to nLen
			aBinding = aBindings[i]
			
			nTargetLen = len(@aDeleteTargets)
			for j = 1 to nTargetLen
				cTarget = @aDeleteTargets[j]
				
				if HasKey(aBinding, cTarget)
					aNode = aBinding[cTarget]
					if ring_find(acToDelete, aNode[:id]) = 0
						acToDelete + aNode[:id]
					ok
				ok
			next
		next
		
		# Delete nodes
		nLen = len(acToDelete)
		for i = 1 to nLen
			@oGraph.RemoveThisNode(acToDelete[i])
		next
	
	#------------------#
	#  ORDERING/LIMIT  #
	#------------------#
	
	def _ApplyOrderBy(aResults)
		if len(@aOrderBy) = 0
			return aResults
		ok
		
		aOrderField = @aOrderBy[1]
		cField = aOrderField[1]
		cDirection = aOrderField[2]
		
		# Simple bubble sort
		nLen = len(aResults)
		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				pVal1 = This._GetResultValue(aResults[i], cField)
				pVal2 = This._GetResultValue(aResults[j], cField)

				bSwap = FALSE
				if cDirection = "asc"
					if isNumber(pVal1) and isNumber(pVal2)
						bSwap = (pVal1 > pVal2)
					but isString(pVal1) and isString(pVal2)
						bSwap = (pVal1 > pVal2)
					ok
				else
					if isNumber(pVal1) and isNumber(pVal2)
						bSwap = (pVal1 < pVal2)
					but isString(pVal1) and isString(pVal2)
						bSwap = (pVal1 < pVal2)
					ok
				ok
				
				if bSwap
					aTemp = aResults[i]
					aResults[i] = aResults[j]
					aResults[j] = aTemp
				ok
			next
		next
		
		return aResults
	
	def _GetResultValue(aResult, cField)
		# Handle nested property access like "n.age"
		if substr(cField, ".") > 0
			acParts = @split(cField, ".")
			cVar = acParts[1]
			cProp = acParts[2]
			
			# Get the node/object first
			if HasKey(aResult, cVar)
				aNode = aResult[cVar]
				# Then get the property from it
				if isList(aNode) and HasKey(aNode, :properties) and HasKey(aNode[:properties], cProp)
					return aNode[:properties][cProp]
				ok
			ok
			return NULL
		ok
		
		# Simple field access
		if HasKey(aResult, cField)
			return aResult[cField]
		ok
		
		return NULL
	
	def _ApplySkip(aResults)
		if @nSkip = 0 or @nSkip >= len(aResults)
			return []
		ok
		
		aSkipped = []
		nLen = len(aResults)
		for i = @nSkip + 1 to nLen
			aSkipped + aResults[i]
		next
		
		return aSkipped
	
	def _ApplyLimit(aResults)
		if @nLimit = NULL or @nLimit >= len(aResults)
			return aResults
		ok
		
		aLimited = []
		for i = 1 to @nLimit
			aLimited + aResults[i]
		next
		
		return aLimited
	
	#-------------------------------------------#
	#  EXPLANATION OF THE QUERY EXECUTION PLAN  #
	#-------------------------------------------#
	
	def Explain()
		# Returns a structured explanation as a hashlist
		aExplanation = []
		
		# Phase 1: MATCH
		if len(@aMatchPatterns) > 0
			acMatch = []
			nLen = len(@aMatchPatterns)
			for i = 1 to nLen
				aPattern = @aMatchPatterns[i]
				cType = aPattern[1]
				
				if cType = :node
					cVar = aPattern[2]
					cDesc = "Scan all nodes, bind to variable '" + cVar + "'"
					
					if len(aPattern) >= 3 and isString(aPattern[3])
						cDesc += " with label '" + aPattern[3] + "'"
					ok
					
					if len(aPattern) >= 3 and isList(aPattern[3])
						cDesc += " with properties " + This._FormatProps(aPattern[3])
					ok
					
					acMatch + cDesc
					
				but cType = :rel or cType = :relationship
					cFrom = aPattern[2]
					cTo = aPattern[3]
					cDesc = "Match relationships: (" + cFrom + ")-[]->("  + cTo + ")"
					
					if len(aPattern) >= 4 and isString(aPattern[4])
						cDesc += " of type '" + aPattern[4] + "'"
					ok
					
					acMatch + cDesc
					
				but cType = :path
					cStart = aPattern[2]
					cRel = aPattern[3]
					cEnd = aPattern[4]
					acMatch + ( "Match path: (" + cStart + ")-[" + cRel + "]->(" + cEnd + ")" )
				ok
			next
			aExplanation + ["match", acMatch]
		ok
		
		# Phase 2: WHERE
		if len(@aWhereConditions) > 0
			acWhere = []
			nLen = len(@aWhereConditions)
			for i = 1 to nLen
				cCondDesc = This._ExplainCondition(@aWhereConditions[i])
				acWhere + ("Filter bindings using conditions: " + cCondDesc)
			next
			aExplanation + ["where", acWhere]
		ok
		
		# Phase 3: CREATE
		if len(@aCreatePatterns) > 0
			acCreate = []
			nLen = len(@aCreatePatterns)
			for i = 1 to nLen
				aPattern = @aCreatePatterns[i]
				cType = aPattern[1]
				
				if cType = :node
					acCreate + "Create new node"
				but cType = :rel or cType = :relationship
					acCreate + "Create new relationship"
				ok
			next
			aExplanation + ["create", acCreate]
		ok
		
		# Phase 4: SET
		if len(@aSetOperations) > 0
			acSet = []
			nLen = len(@aSetOperations)
			for i = 1 to nLen
				aOp = @aSetOperations[i]
				cOpType = aOp[1]
				
				if cOpType = :set
					acSet + ( "Set property: " + aOp[2] + " = " + This._FormatValue(aOp[3]) )
				but cOpType = :remove
					acSet + ( "Remove property: " + aOp[2] )
				ok
			next
			aExplanation + ["set", acSet]
		ok
		
		# Phase 5: DELETE
		if len(@aDeleteTargets) > 0
			acDelete = []
			nLen = len(@aDeleteTargets)
			for i = 1 to nLen
				acDelete + ( "Delete node: " + @aDeleteTargets[i] )
			next
			aExplanation + ["delete", acDelete]
		ok
		
		# Phase 6: RETURN
		if len(@aReturnFields) > 0
			acReturn = []
			
			if @bDistinct
				acReturn + "Apply DISTINCT filter"
			ok
			
			cFields = "Project fields: "
			nLen = len(@aReturnFields)
			for i = 1 to nLen
				pField = @aReturnFields[i]
				
				if isString(pField)
					cFields += pField
				but isList(pField) and pField[1] = :as
					cFields += pField[2] + " AS " + pField[3]
				ok
				
				if i < nLen
					cFields += ", "
				ok
			next
			acReturn + cFields
			
			aExplanation + ["return", acReturn]
		ok
		
		# Phase 7: ORDER BY
		if len(@aOrderBy) > 0
			aOrder = @aOrderBy[1]
			cDir = upper(aOrder[2])
			aExplanation + ["orderby", [ ("Sort by: " + aOrder[1] + " " + cDir) ]]
		ok
		
		# Phase 8: SKIP
		if @nSkip > 0
			aExplanation + ["skip", [ ("Skip first " + @nSkip + " results") ]]
		ok
		
		# Phase 9: LIMIT
		if @nLimit != ""
			aExplanation + ["limit", [ ("Return maximum " + @nLimit + " results") ]]
		ok
		
		# Estimated complexity
		acComplexity = []
		nNodeScans = 0
		nEdgeScans = 0
		
		nLen = len(@aMatchPatterns)
		for i = 1 to nLen
			aPattern = @aMatchPatterns[i]
			if aPattern[1] = :node
				nNodeScans++
			but aPattern[1] = :rel or aPattern[1] = :relationship or aPattern[1] = :path
				nEdgeScans++
			ok
		next
		
		if nNodeScans > 0
			acComplexity + ("Node scans: " + nNodeScans)
		ok
		if nEdgeScans > 0
			acComplexity + ("Edge scans: " + nEdgeScans)
		ok
		
		if len(acComplexity) > 0
			aExplanation + ["complexity", acComplexity]
		ok
		
		return aExplanation
	
	def _ExplainCondition(pCondition)
		if @IsFunction(pCondition)
			return "Custom function filter"
		ok
		
		if NOT isList(pCondition)
			return "Always true"
		ok
		
		cOp = pCondition[1]
		
		if cOp = :equals or cOp = "="
			return pCondition[2] + " = " + This._FormatValue(pCondition[3])
			
		but cOp = :gt or cOp = ">"
			return pCondition[2] + " > " + This._FormatValue(pCondition[3])
			
		but cOp = :lt or cOp = "<"
			return pCondition[2] + " < " + This._FormatValue(pCondition[3])
			
		but cOp = :gte or cOp = ">="
			return pCondition[2] + " >= " + This._FormatValue(pCondition[3])
			
		but cOp = :lte or cOp = "<="
			return pCondition[2] + " <= " + This._FormatValue(pCondition[3])
			
		but cOp = :contains
			return pCondition[2] + " CONTAINS " + This._FormatValue(pCondition[3])
			
		but cOp = :startswith
			return pCondition[2] + " STARTS WITH " + This._FormatValue(pCondition[3])
			
		but cOp = :endswith
			return pCondition[2] + " ENDS WITH " + This._FormatValue(pCondition[3])
			
		but cOp = :and
			return "(" + This._ExplainCondition(pCondition[2]) + " AND " +
			       This._ExplainCondition(pCondition[3]) + ")"
			       
		but cOp = :or
			return "(" + This._ExplainCondition(pCondition[2]) + " OR " +
			       This._ExplainCondition(pCondition[3]) + ")"
			       
		but cOp = :not
			return "NOT (" + This._ExplainCondition(pCondition[2]) + ")"
			
		but cOp = :in
			return pCondition[2] + " IN " + This._FormatValue(pCondition[3])
		ok
		
		return "Unknown condition"
	
	def _FormatProps(aProps)
		if NOT isList(aProps)
			return "{}"
		ok
		
		cResult = "{"
		acKeys = keys(aProps)
		nLen = len(acKeys)
		
		for i = 1 to nLen
			cKey = acKeys[i]
			cResult += cKey + ": " + This._FormatValue(aProps[cKey])
			
			if i < nLen
				cResult += ", "
			ok
		next
		
		cResult += "}"
		return cResult

	def _FormatValue(pValue)
		if isString(pValue)
			return '"' + pValue + '"'
		but isNumber(pValue)
			return "" + pValue
		but isList(pValue)
			# Show array contents instead of [...]
			cResult = "["
			nLen = len(pValue)
			for i = 1 to nLen
				cResult += This._FormatValue(pValue[i])
				if i < nLen
					cResult += ", "
				ok
			next
			cResult += "]"
			return cResult
		ok
		return "null"

	#------------------#
	#  HELPER METHODS  #
	#------------------#
	
	def _NodeHasProperty(aNode, cKey, pValue)
		if NOT HasKey(aNode, :properties)
			return FALSE
		ok
		
		if NOT HasKey(aNode[:properties], cKey)
			return FALSE
		ok
		
		return aNode[:properties][cKey] = pValue
	
	def _EdgeHasProperty(aEdge, cKey, pValue)
		if NOT HasKey(aEdge, :properties)
			return FALSE
		ok
		
		if NOT HasKey(aEdge[:properties], cKey)
			return FALSE
		ok
		
		return aEdge[:properties][cKey] = pValue
	
	#----------------------------#
	#  OPENCYPHER IMPORT/EXPORT  #
	#----------------------------#
	
	def ToOpenCypher()
		cCypher = ""
		
		# MATCH clause
		if len(@aMatchPatterns) > 0
			cCypher += "MATCH "
			nLen = len(@aMatchPatterns)
			
			for i = 1 to nLen
				aPattern = @aMatchPatterns[i]
				cCypher += This._PatternToCypher(aPattern)
				
				if i < nLen
					cCypher += ", "
				ok
			next
			cCypher += NL
		ok
		
		# WHERE clause
		if len(@aWhereConditions) > 0
			cCypher += "WHERE "
			nLen = len(@aWhereConditions)
			
			for i = 1 to nLen
				cCypher += This._ConditionToCypher(@aWhereConditions[i])
				
				if i < nLen
					cCypher += " AND "
				ok
			next
			cCypher += NL
		ok
		
		# CREATE clause
		if len(@aCreatePatterns) > 0
			cCypher += "CREATE "
			nLen = len(@aCreatePatterns)
			
			for i = 1 to nLen
				aPattern = @aCreatePatterns[i]
				cCypher += This._PatternToCypher(aPattern)
				
				if i < nLen
					cCypher += ", "
				ok
			next
			cCypher += NL
		ok
		
		# SET clause
		if len(@aSetOperations) > 0
			cCypher += "SET "
			nLen = len(@aSetOperations)
			
			for i = 1 to nLen
				aOp = @aSetOperations[i]
				cCypher += aOp[2] + " = " + This._ValueToCypher(aOp[3])
				
				if i < nLen
					cCypher += ", "
				ok
			next
			cCypher += NL
		ok
		
		# DELETE clause
		if len(@aDeleteTargets) > 0
			cCypher += "DELETE "
			cCypher += JoinXT(@aDeleteTargets, ", ")
			cCypher += NL
		ok
		
		# RETURN clause
		if len(@aReturnFields) > 0
			cCypher += "RETURN "
			if @bDistinct
				cCypher += "DISTINCT "
			ok
			
			nLen = len(@aReturnFields)
			for i = 1 to nLen
				pField = @aReturnFields[i]
				
				if isString(pField)
					cCypher += pField
				but isList(pField) and pField[1] = :as
					cCypher += pField[2] + " AS " + pField[3]
				ok
				
				if i < nLen
					cCypher += ", "
				ok
			next
			cCypher += NL
		ok
		
		# ORDER BY clause
		if len(@aOrderBy) > 0
			cCypher += "ORDER BY "
			aOrder = @aOrderBy[1]
			cCypher += aOrder[1] + " " + UPPER(aOrder[2])
			cCypher += NL
		ok
		
		# SKIP clause
		if @nSkip > 0
			cCypher += "SKIP " + @nSkip + NL
		ok
		
		# LIMIT clause
		if @nLimit != NULL
			cCypher += "LIMIT " + @nLimit + NL
		ok
		
		return cCypher
	
	def _PatternToCypher(aPattern)
		cType = aPattern[1]
		
		if cType = :node
			cVar = aPattern[2]
			cResult = "(" + cVar
			
			if len(aPattern) >= 3 and isString(aPattern[3])
				cResult += ":" + aPattern[3]
			ok
			
			if len(aPattern) >= 3 and isList(aPattern[3])
				cResult += " " + This._PropsToCypher(aPattern[3])
			ok
			
			cResult += ")"
			return cResult
			
		but cType = :rel or cType = :relationship
			cFrom = aPattern[2]
			cTo = aPattern[3]
			cResult = "(" + cFrom + ")"
			
			cResult += "-["
			
			if len(aPattern) >= 4 and isString(aPattern[4])
				cResult += ":" + aPattern[4]
			ok
			
			if len(aPattern) >= 4 and isList(aPattern[4])
				cResult += " " + This._PropsToCypher(aPattern[4])
			ok
			
			cResult += "]->"
			cResult += "(" + cTo + ")"
			return cResult
			
		but cType = :path
			cStart = aPattern[2]
			cRel = aPattern[3]
			cEnd = aPattern[4]
			return "(" + cStart + ")-[" + cRel + "]->(" + cEnd + ")"
		ok
		
		return ""
	
	def _ConditionToCypher(pCondition)
		if NOT isList(pCondition)
			return ""
		ok
		
		cOp = pCondition[1]
		
		if cOp = :equals or cOp = "="
			return pCondition[2] + " = " + This._ValueToCypher(pCondition[3])
			
		but cOp = :gt or cOp = ">"
			return pCondition[2] + " > " + This._ValueToCypher(pCondition[3])
			
		but cOp = :lt or cOp = "<"
			return pCondition[2] + " < " + This._ValueToCypher(pCondition[3])
			
		but cOp = :contains
			return pCondition[2] + " CONTAINS " + This._ValueToCypher(pCondition[3])
			
		but cOp = :and
			return "(" + This._ConditionToCypher(pCondition[2]) + " AND " + 
			       This._ConditionToCypher(pCondition[3]) + ")"
			       
		but cOp = :or
			return "(" + This._ConditionToCypher(pCondition[2]) + " OR " + 
			       This._ConditionToCypher(pCondition[3]) + ")"
			       
		but cOp = :not
			return "NOT " + This._ConditionToCypher(pCondition[2])
		ok
		
		return ""
	
	def _PropsToCypher(aProps)
		cResult = "{"
		acKeys = keys(aProps)
		nLen = len(acKeys)
		
		for i = 1 to nLen
			cKey = acKeys[i]
			cResult += cKey + ": " + This._ValueToCypher(aProps[cKey])
			
			if i < nLen
				cResult += ", "
			ok
		next
		
		cResult += "}"
		return cResult
	
	def _ValueToCypher(pValue)
		if isString(pValue)
			return '"' + pValue + '"'
		but isNumber(pValue)
			return "" + pValue
		but isList(pValue)
			return "[" + JoinXT(pValue, ", ") + "]"
		ok
		return "null"
	
	def LoadFromOpenCypher(cCypherQuery)
		# Parse OpenCypher query and build internal representation
		# This is a simplified parser for common patterns
		
		cQuery = trim(cCypherQuery)
		acLines = @split(cQuery, NL)
		
		nLen = len(acLines)
		for i = 1 to nLen
			cLine = trim(acLines[i])
			
			if left(cLine, 5) = "MATCH"
				This._ParseMatchClause(@substr(cLine, 7, stzlen(cLine)))
				
			but left(cLine, 5) = "WHERE"
				This._ParseWhereClause(@substr(cLine, 7, stzlen(cLine)))
				
			but left(cLine, 6) = "CREATE"
				This._ParseCreateClause(@substr(cLine, 8, stzlen(cLine)))
				
			but left(cLine, 6) = "RETURN"
				This._ParseReturnClause(@substr(cLine, 8, stzlen(cLine)))
				
			but left(cLine, 8) = "ORDER BY"
				This._ParseOrderByClause(@substr(cLine, 10, stzlen(cLine)))
				
			but left(cLine, 5) = "LIMIT"
				@nLimit = 0 + @substr(cLine, 7, stzlen(cLine))
			ok
		next
	
	def _ParseMatchClause(cClause)
		# Simple pattern: (n:Label {prop: val})
		# Or: (a)-[:TYPE]->(b)
		
		if substr(cClause, "->") > 0
			# Relationship pattern
			This._ParseRelPattern(cClause)
		else
			# Node pattern
			This._ParseNodePattern(cClause)
		ok
	
	def _ParseNodePattern(cPattern)
		nStart = substr(cPattern, "(")
		nEnd = substr(cPattern, ")")
		
		if nStart > 0 and nEnd > 0
			cInner = substr(cPattern, nStart + 1, nEnd - nStart - 1)
			
			nColon = substr(cInner, ":")
			if nColon = 0
				# Just variable name
				This.Match([:node, trim(cInner)])
				return
			ok
			
			cVarName = trim(substr(cInner, 1, nColon - 1))
			
			# Get everything after colon
			cRest = substr(cInner, nColon + 1)
			
			# Check for properties
			nBrace = substr(cRest, "{")
			if nBrace > 0
				cLabel = trim(substr(cRest, 1, nBrace - 1))
			else
				cLabel = trim(cRest)
			ok
			
			This.Match([:node, cVarName, cLabel])
		ok
	
	def _ParseRelPattern(cPattern)
		# Extract: (a)-[:TYPE]->(b)
		# This is simplified - full parser would be more complex
		
		nArrow = substr(cPattern, "->")
		if nArrow > 0
			cLeft = @substr(cPattern, 1, nArrow - 1)
			cRight = @substr(cPattern, nArrow + 2, stzlen(cPattern))
			
			# Extract from variable
			nStart = substr(cLeft, "(")
			nEnd = substr(cLeft, ")")
			cFromVar = trim(@substr(cLeft, nStart + 1, nEnd - 2))
			
			# Extract to variable
			nStart = substr(cRight, "(")
			nEnd = substr(cRight, ")")
			cToVar = trim(@substr(cRight, nStart + 1, nEnd - 2))
			
			This.Match([:rel, cFromVar, cToVar])
		ok
	
	def _ParseWhereClause(cClause)
		# Simple: n.age > 25
		if substr(cClause, ">") > 0
			acParts = @split(cClause, ">")
			This.Where([:gt, trim(acParts[1]), 0 + trim(acParts[2])])
		but substr(cClause, "=") > 0
			acParts = @split(cClause, "=")
			This.Where([:equals, trim(acParts[1]), trim(acParts[2])])
		ok
	
	def _ParseReturnClause(cClause)
		acFields = @split(cClause, ",")
		nLen = len(acFields)
		
		for i = 1 to nLen
			cField = trim(acFields[i])
			This.Return_(cField)
		next
	
	def _ParseOrderByClause(cClause)
		acParts = @split(cClause, " ")
		if len(acParts) >= 2
			This.OrderBy(acParts[1], lower(acParts[2]))
		ok
	
	def _ParseCreateClause(cClause)
		# Similar to Match parsing
		This._ParseNodePattern(cClause)
