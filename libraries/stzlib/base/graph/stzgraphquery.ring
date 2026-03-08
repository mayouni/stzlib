#====================================================#
#  stzGraphQuery - Natural Softanza Query System    #
#====================================================#

# The class has been refactored fellowing those principles:
#
# 1. Single source of truth:
# `@aDefinition` is now the only state container
# 
# 2. All methods modify `@aDefinition`:
# Every query-building method (`Match`, `Where`, `Select`, etc.)
# operates on `@aDefinition`

# 3. Execution reads from `@aDefinition`:
# `_Execute()` and all its helpers read only from `@aDefinition`
# 
# 4. Manual modification enabled: `SetDefinition()` allows
# external definition loading

# 5. State consistency:
# Changing definition resets execution state


$aDefaultQueryDefinition = [
	["match_patterns", []],
	["where_conditions", []],
	["select_fields", []],
	["create_patterns", []],
	["set_operations", []],
	["delete_targets", []],
	["rule_triggers", []],
	["order_by", []],
	["skip", 0],
	["limit", 0],
	["distinct", FALSE]
]

func StzGraphQueryQ(oGraph)
	return new stzGraphQuery(oGraph)

class stzGraphQuery
	@oGraph
	
	# Single source of truth - all state lives here
	@aDefinition = [
		["match_patterns", []],
		["where_conditions", []],
		["select_fields", []],
		["create_patterns", []],
		["set_operations", []],
		["delete_targets", []],
		["rule_triggers", []],
		["order_by", []],
		["skip", 0],
		["limit", 0],
		["distinct", FALSE]
	]
	
	@aResult = []
	@bExecuted = FALSE
	@aBindings = []

	def init(oGraph)
		if NOT @IsStzGraph(oGraph)
			stzraise("Parameter must be a stzGraph object!")
		ok
		@oGraph = ref(oGraph)
	
	def GraphObject()
		return @oGraph
		
		def GraphQ()
			return @oGraph

	#---------------------------#
	#  DEFINITION MANAGEMENT    #
	#---------------------------#
	
	def Query()
		return @aDefinition

		def Definition()
			return This.Query()
		
		def AST()
			return This.Query()
		
		def QueryDefinition()
			return This.Query()
		
		def Structure()
			return This.Query()

	def SetDefinition(aNewDef)
		# Validate structure
		if NOT isList(aNewDef)
			stzraise("Definition must be a list!")
		ok
		
		# Reset execution state
		@bExecuted = FALSE
		@aResult = []
		
		# Accept new definition
		@aDefinition = aNewDef

		def LoadDefinition(aNewDef)
			This.SetDefinition(aNewDef)

		def ImportDefinition(aNewDef)
			This.SetDefinition(aNewDef)

	def ResetDefinition()
		@aDefinition = $aDefaultQueryDefinition
		@bExecuted = FALSE
		@aResult = []
		@aBindings = []

		def ClearDefinition()
			This.ResetDefinition()

	#-----------------------#
	#  RULE TRIGGER METHODS #
	#-----------------------#
	
	def ThenApplyRule(pcRuleName)
		@aDefinition["rule_triggers"] + [
			:type = :apply,
			:rule = UPPER(pcRuleName),
			:scope = :matched_bindings
		]

		def ThenApplyRuleQ(pcRuleName)
			This.ThenApplyRule(pcRuleName)
			return This
	
	def EnforceRule(pcRuleName)
		@aDefinition["rule_triggers"] + [
			:type = :enforce,
			:rule = UPPER(pcRuleName),
			:scope = :matched_bindings
		]

		def EnforceRuleQ(pcRuleName)
			This.EnforceRule(pcRuleName)
			return This
	
	def ValidateWith(paValidators)
		if isString(paValidators)
			paValidators = [paValidators]
		ok
	
		@aDefinition["rule_triggers"] + [
			:type = :validate,
			:validators = paValidators,
			:scope = :matched_bindings
		]

		def ValidateWithQ(paValidators)
			This.ValidateWith(paValidators)
			return This

	def DeriveUsing(pcRuleName)
		@aDefinition["rule_triggers"] + [
			:type = :derive,
			:rule = UPPER(pcRuleName),
			:scope = :matched_bindings
		]

		def DeriveUsingQ(pcRuleName)
			This.DeriveUsing(pcRuleName)
			return This

	#------------------#
	#  MATCH PATTERNS  #
	#------------------#
		
	def Match(paParams)
		# Simple atom - match all nodes
		if paParams = :nodes or paParams = :node
			@aDefinition["match_patterns"] + [ ["type", :node], ["alias", "node"], ["label", ""], ["props", []] ]
			return
		ok
		
		# Build internal hashlist
		aInternal = [ ["type", :node], ["alias", "node"], ["label", ""], ["props", []] ]
		
		if isList(paParams)
			# Check for simple [:nodes] or first element patterns
			if len(paParams) > 0 and (paParams[1] = :nodes or paParams[1] = :node)
				# Look for :where, :labeled, :props in subsequent elements
				for i = 2 to len(paParams)
					if isList(paParams[i]) and len(paParams[i]) >= 2
						if paParams[i][1] = :where
							aWhere = paParams[i][2]
							aInternalCond = This._NormalizeCondition(aWhere, aInternal["alias"])
							aInternal["where"] = aInternalCond
						but paParams[i][1] = :labeled
							aInternal["label"] = paParams[i][2]
						but paParams[i][1] = :props or paParams[i][1] = :properties
							aInternal["props"] = paParams[i][2]
						ok
					ok
				next
				
				@aDefinition["match_patterns"] + aInternal
				return
			ok
			
			# Extract node alias if specified
			if HasKey(paParams, :node)
				aInternal["alias"] = paParams[:node]
			ok
			
			# Extract label
			if HasKey(paParams, :labeled)
				aInternal["label"] = paParams[:labeled]
			ok
			
			# Extract properties
			if HasKey(paParams, :props) or HasKey(paParams, :properties)
				aProps = paParams[:props]
				if aProps = ""
					aProps = paParams[:properties]
				ok
				aInternal["props"] = aProps
			ok
			
			# Auto-add where condition to pattern
			if HasKey(paParams, :where)
				aWhere = paParams[:where]
				aInternalCond = This._NormalizeCondition(aWhere, aInternal["alias"])
				aInternal["where"] = aInternalCond
			ok
		ok
		
		@aDefinition["match_patterns"] + aInternal
	
		def MatchQ(paParams)
			This.Match(paParams)
			return This

	def MatchEdge(paParams)
		# Build internal hashlist
		aInternal = [ 
			["type", :edge], 
			["from", "from_node"], 
			["to", "to_node"], 
			["label", ""], 
			["props", []] 
		]
		
		if isList(paParams)
			# Extract from list format
			for i = 1 to len(paParams)
				if isList(paParams[i]) and len(paParams[i]) >= 2
					if paParams[i][1] = :from
						aInternal["from"] = paParams[i][2]
					but paParams[i][1] = :to
						aInternal["to"] = paParams[i][2]
					but paParams[i][1] = :labeled
						aInternal["label"] = paParams[i][2]
					but paParams[i][1] = :props or paParams[i][1] = :properties
						aInternal["props"] = paParams[i][2]
					but paParams[i][1] = :where
						aWhere = paParams[i][2]
						aInternalCond = This._NormalizeCondition(aWhere, "edge_data")
						aInternal["where"] = aInternalCond
					ok
				ok
			next
		ok
		
		@aDefinition["match_patterns"] + aInternal
	
		def MatchEdgeQ(paParams)
			This.MatchEdge(paParams)
			return This

	def Where(paCondition)
		if @IsFunction(paCondition)
			# Add to last pattern if exists, otherwise global
			if len(@aDefinition["match_patterns"]) > 0
				nLast = len(@aDefinition["match_patterns"])
				@aDefinition["match_patterns"][nLast]["where"] = paCondition
			else
				@aDefinition["where_conditions"] + paCondition
			ok
			return
		ok
		
		# Convert natural condition to internal hashlist format
		aInternalCond = This._NormalizeCondition(paCondition, "node")
		
		# Add to last pattern if exists, otherwise global
		if len(@aDefinition["match_patterns"]) > 0
			nLast = len(@aDefinition["match_patterns"])
			# Get variable name from last pattern
			cVar = "node"
			if HasKey(@aDefinition["match_patterns"][nLast], "alias")
				cVar = @aDefinition["match_patterns"][nLast]["alias"]
			ok
			aInternalCond = This._NormalizeCondition(paCondition, cVar)
			@aDefinition["match_patterns"][nLast]["where"] = aInternalCond
		else
			@aDefinition["where_conditions"] + aInternalCond
		ok

		def WhereQ(paCondition)
			This.Where(paCondition)
			return This

		def WhereF(pCondition)
			This.Where(pCondition)

			def WhereFQ(pCondition)
				This.WhereF(pCondition)
				return This

	def _NormalizeCondition(paCondition, pcVarName)
		if NOT isList(paCondition)
			return paCondition
		ok
		
		if pcVarName = ""
			pcVarName = "node"
		ok
		
		# Simple condition: [prop, op, value]
		if len(paCondition) = 3
			cProp = paCondition[1]
			cOp = paCondition[2]
			pValue = paCondition[3]
			
			# Convert operator
			cInternalOp = This._ConvertOp(cOp)
			
			# Add implicit variable if needed
			if isString(cProp) and NOT substr(cProp, ".")
				cProp = pcVarName + "." + cProp
			ok
			
			return [ ["op", cInternalOp], ["left", cProp], ["right", pValue] ]
		ok
		
		# Compound condition
		if len(paCondition) > 3
			nLogicPos = 0
			nLen = len(paCondition)
			for i = 1 to nLen
				if paCondition[i] = :and or paCondition[i] = :or
					nLogicPos = i
					exit
				ok
			next
			
			if nLogicPos > 0
				aLeft = []
				for i = 1 to nLogicPos - 1
					aLeft + paCondition[i]
				next
				
				aRight = []
				for i = nLogicPos + 1 to nLen
					aRight + paCondition[i]
				next
				
				cLogic = paCondition[nLogicPos]
				
				return [ 
					["op", cLogic],
					["left", This._NormalizeCondition(aLeft, pcVarName)],
					["right", This._NormalizeCondition(aRight, pcVarName)]
				]
			ok
		ok
		
		return paCondition
	
	def _ConvertOp(cOp)
		if cOp = ">"
			return :gt
		but cOp = "<"
			return :lt
		but cOp = ">="
			return :gte
		but cOp = "<="
			return :lte
		but cOp = "="
			return :equals
		but cOp = "!="
			return :not_equals
		but cOp = :contains
			return :contains
		but cOp = :startswith
			return :startswith
		but cOp = :endswith
			return :endswith
		but cOp = :in
			return :in
		but cOp = :not_in
			return :not_in
		ok
		
		return cOp

	def SelectXT(paFields)
		This.Select(paFields)
		return This._Execute()

		def SelectAndExecute(paFields)
			return This.SelectXT(paFields)

		def SelectAndRun(paFields)
			return This.SelectXT(paFields)

	def Select(paFields)
	    # Handle "*" for all matched variables
	    if paFields = "*"
	        # Collect all variable names from match patterns
	        acVars = []
	        nLen = len(@aDefinition["match_patterns"])
	        for i = 1 to nLen
	            aPattern = @aDefinition["match_patterns"][i]
	            if aPattern["type"] = :node
	                cVar = aPattern["alias"]
	                if ring_find(acVars, cVar) = 0
	                    acVars + cVar
	                ok
	            but aPattern["type"] = :edge
	                cFrom = aPattern["from"]
	                cTo = aPattern["to"]
	                if ring_find(acVars, cFrom) = 0
	                    acVars + cFrom
	                ok
	                if ring_find(acVars, cTo) = 0
	                    acVars + cTo
	                ok
	            ok
	        next
	        
	        # Add all variables to select fields
	        nLen = len(acVars)
	        for i = 1 to nLen
	            @aDefinition["select_fields"] + acVars[i]
	        next
	        
	        This._Execute()  # Add this line
	        return @aResult   # Add this line
	    ok
	    
	    if isString(paFields)
	        @aDefinition["select_fields"] + paFields
	        This._Execute()  # Add this line
	        return @aResult   # Add this line
	    ok
	    
	    if NOT isList(paFields)
	        This._Execute()  # Add this line
	        return @aResult   # Add this line
	    ok
	    
	    # Check for :as syntax
	    if len(paFields) = 2 and isList(paFields[2]) and len(paFields[2]) = 2
	        if paFields[2][1] = :as
	            cField = paFields[1]
	            cAlias = paFields[2][2]
	            
	            @aDefinition["select_fields"] + [ ["field", cField], ["alias", cAlias] ]
	            This._Execute()  # Add this line
	            return @aResult   # Add this line
	        ok
	    ok
	    
	    # List of field names
	    nLen = len(paFields)
	    for i = 1 to nLen
	        pField = paFields[i]
	        if isString(pField)
	            @aDefinition["select_fields"] + pField
	        but isList(pField)
	            @aDefinition["select_fields"] + pField
	        ok
	    next
	    
	    This._Execute()  # Add this line
	    return @aResult   # Add this line
	
		def SelectQ(paFields)
			This.Select(paFields)
			return This

	def Distinct()
		@aDefinition["distinct"] = TRUE
	
		def DistinctQ()
			This.Distinct()
			return This

	def OrderBy(pcField, pcDirection)
		if NOT isString(pcDirection)
			pcDirection = "asc"
		ok

		pcDirection = lower(pcDirection)

		if pcDirection = "inascending" or pcDirection = "ascending"
			pcDirection = "asc"
		but pcDirection = "indescending" or pcDirection = "descending"
			pcDirection = "desc"
		ok

		if pcDirection != "asc" and pcDirection != "desc"
			pcDirection = "asc"
		ok

		@aDefinition["order_by"] + [ ["field", pcField], ["direction", pcDirection] ]

		def OrderByQ(pcField, pcDirection)
			This.OrderBy(pcField, pcDirection)
			return This

	def Limit(pnLimit)
		@aDefinition["limit"] = pnLimit
	
		def LimitQ(pnLimit)
			This.Limit(pnLimit)
			return This

	def Skip(pnSkip)
		@aDefinition["skip"] = pnSkip
	
		def SkipQ(pnSkip)
			This.Skip(pnSkip)
			return This

	def Set(pcProperty, paValue)
		pValue = paValue
		
		if isList(paValue) and HasKey(paValue, :to)
			pValue = paValue[:to]
		ok
		
		@aDefinition["set_operations"] + [ ["op", :set], ["property", pcProperty], ["value", pValue] ]
	
		def SetQ(pcProperty, paValue)
			This.Set(pcProperty, paValue)
			return This

	def Create(paParams)
		if NOT isList(paParams)
			return
		ok
		
		cType = :node
		if paParams[1] = :node or paParams[1] = :nodes
			cType = :node
		but paParams[1] = :edge or paParams[1] = :edges
			cType = :edge
		ok
		
		if cType = :node
			aInternal = [ ["type", :node], ["label", ""], ["props", []] ]
			
			if HasKey(paParams, :labeled)
				aInternal["label"] = paParams[:labeled]
			ok
			
			if HasKey(paParams, :props) or HasKey(paParams, :properties)
				aProps = paParams[:props]
				if aProps = ""
					aProps = paParams[:properties]
				ok
				aInternal["props"] = aProps
			ok
			
			@aDefinition["create_patterns"] + aInternal
		
		but cType = :edge
			aInternal = [ 
				["type", :edge], 
				["from", ""], 
				["to", ""], 
				["label", ""], 
				["props", []] 
			]
			
			# Extract from list format
			for i = 2 to len(paParams)
				if isList(paParams[i]) and len(paParams[i]) >= 2
					if paParams[i][1] = :from
						aInternal["from"] = paParams[i][2]
					but paParams[i][1] = :to
						aInternal["to"] = paParams[i][2]
					but paParams[i][1] = :labeled
						aInternal["label"] = paParams[i][2]
					but paParams[i][1] = :props or paParams[i][1] = :properties
						aInternal["props"] = paParams[i][2]
					ok
				ok
			next
			
			@aDefinition["create_patterns"] + aInternal
		ok
	
		def CreateQ(paParams)
			This.Create(paParams)
			return This

	def Delete(paTargets)
		if isString(paTargets)
			@aDefinition["delete_targets"] + paTargets

		but isList(paTargets)
			nLen = len(paTargets)
			for i = 1 to nLen
				@aDefinition["delete_targets"] + paTargets[i]
			next
		ok
	
		def DeleteQ(paTargets)
			This.Delete(paTargets)
			return This

	#-------------------#
	#  QUERY EXECUTION  #
	#-------------------#
	
	def Execute()
		@bExecuted = This._Execute()
		return @bExecuted

		def Run()
			return This.Execute()

		def Exec()
			return This.Execute()

		def Executed()
			return This.Execute()

		def Runned()
			return This.Execute()

	def _Execute()
		@aResult = []
		aBindings = []
		
		if len(@aDefinition["match_patterns"]) > 0
			aBindings = This._ExecuteMatch()
		ok
	
		@aBindings = aBindings  # NEW - store for ToGraph()
		
		if len(@aDefinition["create_patterns"]) > 0
			This._ExecuteCreate(aBindings)
		ok
		
		if len(@aDefinition["set_operations"]) > 0
			This._ExecuteSet(aBindings)
		ok
	
		# NEW - Execute rule triggers
		if len(@aDefinition["rule_triggers"]) > 0
			This._ExecuteRuleTriggers(aBindings)
		ok
		
		if len(@aDefinition["delete_targets"]) > 0
			This._ExecuteDelete(aBindings)
		ok
		
		if len(@aDefinition["select_fields"]) > 0
			aBindings = This._ExecuteSelect(aBindings)
		ok
		
		if len(@aDefinition["order_by"]) > 0
			aBindings = This._ApplyOrderBy(aBindings)
		ok
		
		if @aDefinition["skip"] > 0
			aBindings = This._ApplySkip(aBindings)
		ok
		
		if @aDefinition["limit"] > 0
			aBindings = This._ApplyLimit(aBindings)
		ok
		
		@aResult = aBindings
		return TRUE

	def Result()
		return @aResult

	#--------------------------#
	#  RULE TRIGGER EXECUTION  #
	#--------------------------#
	
	def _ExecuteRuleTriggers(aBindings)
		nLen = len(@aDefinition["rule_triggers"])
		
		for i = 1 to nLen
			aTrigger = @aDefinition["rule_triggers"][i]
			cType = aTrigger[:type]
			
			if cType = :apply
				This._ApplyRuleToBindings(aTrigger[:rule], aBindings)
			
			but cType = :enforce
				This._EnforceRuleOnBindings(aTrigger[:rule], aBindings)
			
			but cType = :validate
				This._ValidateBindings(aTrigger[:validators], aBindings)
	
			but cType = :derive
				This._DeriveFromBindings(aTrigger[:rule], aBindings)
			ok
		next
	
	def _ApplyRuleToBindings(pcRuleName, aBindings)
		aRule = This._FindRuleInGraph(pcRuleName)
		
		if aRule = NULL
			stzraise("Rule '" + pcRuleName + "' not found!")
		ok
	
		if aRule[:type] != :Derivation
			stzraise("Rule must be Derivation type!")
		ok
	
		acNodeIds = This._ExtractNodeIdsFromBindings(aBindings)
		oSubgraph = This._CreateSubgraphView(acNodeIds)
		
		pFunc = aRule[:function]
		paParams = aRule[:params]
		aNewEdges = call pFunc(oSubgraph, paParams)
		
		nLen = len(aNewEdges)
		for i = 1 to nLen
			aEdge = aNewEdges[i]
			@oGraph.AddEdgeXTT(aEdge[1], aEdge[2], aEdge[3], aEdge[4])
		next
	
	def _EnforceRuleOnBindings(pcRuleName, aBindings)
		aRule = This._FindRuleInGraph(pcRuleName)
		
		if aRule = NULL
			stzraise("Rule '" + pcRuleName + "' not found!")
		ok
	
		if aRule[:type] != :Constraint
			stzraise("Rule must be Constraint type!")
		ok
	
		pFunc = aRule[:function]
		paParams = aRule[:params]
		
		nLen = len(aBindings)
		for i = 1 to nLen
			aBinding = aBindings[i]
			aOpParams = This._BuildOpParamsFromBinding(aBinding)
			aResult = call pFunc(@oGraph, paParams, aOpParams)
			
			if aResult[1]
				stzraise("Constraint violated: " + aResult[2])
			ok
		next
	
	def _ValidateBindings(paValidators, aBindings)
		acNodeIds = This._ExtractNodeIdsFromBindings(aBindings)
		oSubgraph = This._CreateSubgraphView(acNodeIds)
		aResult = oSubgraph.ValidateXT(paValidators)
		
		if aResult[:status] = "fail"
			cMsg = "Validation failed:" + NL
			nLen = len(aResult[:issues])
			for i = 1 to nLen
				cMsg += "  - " + aResult[:issues][i] + NL
			next
			stzraise(cMsg)
		ok
	
	def _DeriveFromBindings(pcRuleName, aBindings)
		This._ApplyRuleToBindings(pcRuleName, aBindings)
	
	def _FindRuleInGraph(pcRuleName)
		pcRuleName = UPPER(pcRuleName)
		
		aLists = [
			@oGraph.@aConstraintRules,
			@oGraph.@aDerivationRules,
			@oGraph.@aValidationRules
		]
		
		nListLen = len(aLists)
		for i = 1 to nListLen
			aRules = aLists[i]
			nLen = len(aRules)
			for j = 1 to nLen
				if aRules[j][:name] = pcRuleName
					return aRules[j]
				ok
			next
		next
		
		return NULL
	
	def _ExtractNodeIdsFromBindings(aBindings)
		acNodeIds = []
		
		nLen = len(aBindings)
		for i = 1 to nLen
			aBinding = aBindings[i]
			acKeys = keys(aBinding)
			
			nKeyLen = len(acKeys)
			for j = 1 to nKeyLen
				pValue = aBinding[acKeys[j]]
				
				if isList(pValue) and HasKey(pValue, :id)
					cId = pValue[:id]
					if ring_find(acNodeIds, cId) = 0
						acNodeIds + cId
					ok
				ok
			next
		next
		
		return acNodeIds
	
	def _BuildOpParamsFromBinding(aBinding)
		aOpParams = []
		
		acKeys = keys(aBinding)
		nLen = len(acKeys)
		
		for i = 1 to nLen
			cKey = acKeys[i]
			pValue = aBinding[cKey]
			
			if isList(pValue) and HasKey(pValue, :id)
				aOpParams[cKey] = pValue[:id]
			else
				aOpParams[cKey] = pValue
			ok
		next
		
		return aOpParams
	
	def _CreateSubgraphView(acNodeIds)
		return new stzGraphView(@oGraph, acNodeIds)

	#--------------------#
	#  GRAPH PROJECTION  #
	#--------------------#
	
	def ToGraphQ()
		if NOT @bExecuted
			This._Execute()
		ok
	
		oResultGraph = new stzGraph("query_result_" + UUID())
		aSeenNodes = []
		
		nLen = len(@aBindings)
		for i = 1 to nLen
			aBinding = @aBindings[i]
			acKeys = keys(aBinding)
			
			nKeyLen = len(acKeys)
			for j = 1 to nKeyLen
				pValue = aBinding[acKeys[j]]
				
				if acKeys[j] = "edge_data"
					loop
				ok
				
				if isList(pValue) and HasKey(pValue, :id)
					cNodeId = pValue[:id]
					
					if ring_find(aSeenNodes, cNodeId) = 0
						aSeenNodes + cNodeId
						
						cLabel = ""
						if HasKey(pValue, :label)
							cLabel = pValue[:label]
						ok
						
						aProps = []
						if HasKey(pValue, :properties)
							aProps = pValue[:properties]
						ok
						
						oResultGraph.AddNodeXTT(cNodeId, cLabel, aProps)
					ok
				ok
			next
		next
		
		aEdges = @oGraph.Edges()
		nEdgeLen = len(aEdges)
		
		for i = 1 to nEdgeLen
			aEdge = aEdges[i]
			cFrom = aEdge[:from]
			cTo = aEdge[:to]
			
			if ring_find(aSeenNodes, cFrom) > 0 and ring_find(aSeenNodes, cTo) > 0
				cLabel = ""
				if HasKey(aEdge, :label)
					cLabel = aEdge[:label]
				ok
				
				aProps = []
				if HasKey(aEdge, :properties)
					aProps = aEdge[:properties]
				ok
				
				oResultGraph.AddEdgeXTT(cFrom, cTo, cLabel, aProps)
			ok
		next
		
		return oResultGraph
	
		def ToStzGraph()
			return This.ToGraphQ()

	def ToViewQ()
		if NOT @bExecuted
			This._Execute()
		ok
	
		acNodeIds = This._ExtractNodeIdsFromBindings(@aBindings)
		return new stzGraphView(@oGraph, acNodeIds)
	
		def ToStzGraphView()
			return This.ToViewQ()
	
		def ToView()
			return This.ToViewQ()

	#-----------------------#
	#  PATTERN MATCHING     #
	#-----------------------#
	
	def _ExecuteMatch()
		aAllBindings = []
		
		nLen = len(@aDefinition["match_patterns"])
		for i = 1 to nLen
			aPattern = @aDefinition["match_patterns"][i]
			cPatternType = aPattern["type"]
			
			if cPatternType = :node
				aNodeBindings = This._MatchNode(aPattern)
				if i = 1
					aAllBindings = aNodeBindings
				else
					aAllBindings = This._MergeBindings(aAllBindings, aNodeBindings)
				ok
				
			but cPatternType = :edge
				aEdgeBindings = This._MatchEdge(aPattern)
				if i = 1
					aAllBindings = aEdgeBindings
				else
					aAllBindings = This._MergeBindings(aAllBindings, aEdgeBindings)
				ok
			ok
		next
		
		return aAllBindings
	
	def _MatchNode(aPattern)
		cVarName = aPattern["alias"]
		cLabel = aPattern["label"]
		aProps = aPattern["props"]
		pWhere = NULL
		
		if HasKey(aPattern, "where")
			pWhere = aPattern["where"]
		ok
		
		aBindings = []
		aNodes = @oGraph.Nodes()
		nLen = len(aNodes)
		
		for i = 1 to nLen
			aNode = aNodes[i]
			bMatch = TRUE
			
			# Check label
			if cLabel != "" and HasKey(aNode, :label)
				if aNode[:label] != cLabel
					bMatch = FALSE
				ok
			ok
			
			# Check properties
			if isList(aProps) and len(aProps) > 0
				acKeys = keys(aProps)
				nKeyLen = len(acKeys)
				
				for j = 1 to nKeyLen
					cKey = acKeys[j]
					pValue = aProps[cKey]
					
					if cKey = "id"
						if aNode[:id] != pValue
							bMatch = FALSE
							exit
						ok
					else
						if NOT This._NodeHasProperty(aNode, cKey, pValue)
							bMatch = FALSE
							exit
						ok
					ok
				next
			ok
			
			# Apply pattern-specific WHERE condition
			if bMatch and pWhere != NULL
				aBinding = [ [cVarName, aNode] ]
				if NOT This._EvaluateCondition(pWhere, aBinding)
					bMatch = FALSE
				ok
			ok
			
			if bMatch
				aBinding = [ [cVarName, aNode] ]
				aBindings + aBinding
			ok
		next
		
		return aBindings
	
	def _MatchEdge(aPattern)
		cFromVar = aPattern["from"]
		cToVar = aPattern["to"]
		cLabel = aPattern["label"]
		aProps = aPattern["props"]
		pWhere = NULL
		
		if HasKey(aPattern, "where")
			pWhere = aPattern["where"]
		ok
		
		aBindings = []
		aEdges = @oGraph.Edges()
		nLen = len(aEdges)
		
		for i = 1 to nLen
			aEdge = aEdges[i]
			bMatch = TRUE
			
			# Check label
			if cLabel != "" and HasKey(aEdge, :label)
				if aEdge[:label] != cLabel
					bMatch = FALSE
				ok
			ok
			
			# Check properties
			if isList(aProps) and len(aProps) > 0
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
			
			# Apply pattern-specific WHERE condition
			if bMatch and pWhere != NULL
				aBinding = [
					[cFromVar, @oGraph.Node(aEdge[:from])],
					[cToVar, @oGraph.Node(aEdge[:to])],
					["edge_data", aEdge]
				]
				if NOT This._EvaluateCondition(pWhere, aBinding)
					bMatch = FALSE
				ok
			ok
			
			if bMatch
				aBinding = [
					[cFromVar, @oGraph.Node(aEdge[:from])],
					[cToVar, @oGraph.Node(aEdge[:to])],
					["edge_data", aEdge]
				]
				aBindings + aBinding
			ok
		next
		
		return aBindings
	
	def _MergeBindings(aExisting, aNew)
		if len(aExisting) = 0
			return aNew
		ok
		
		if len(aNew) = 0
			return aExisting
		ok
		
		aMerged = []
		nExistLen = len(aExisting)
		nNewLen = len(aNew)
		
		for i = 1 to nExistLen
			aExistBinding = aExisting[i]
			
			for j = 1 to nNewLen
				aNewBinding = aNew[j]
				
				# Check if bindings are compatible
				if This._BindingsCompatible(aExistBinding, aNewBinding)
					aCombined = []
					
					# Add existing bindings
					acExistKeys = keys(aExistBinding)
					nKeyLen = len(acExistKeys)
					for k = 1 to nKeyLen
						aCombined + [acExistKeys[k], aExistBinding[acExistKeys[k]]]
					next
					
					# Add new bindings (avoid duplicates)
					acNewKeys = keys(aNewBinding)
					nKeyLen = len(acNewKeys)
					for k = 1 to nKeyLen
						if NOT HasKey(aCombined, acNewKeys[k])
							aCombined + [acNewKeys[k], aNewBinding[acNewKeys[k]]]
						ok
					next
					
					aMerged + aCombined
				ok
			next
		next
		
		return aMerged
	
	def _BindingsCompatible(aBinding1, aBinding2)
		acKeys1 = keys(aBinding1)
		acKeys2 = keys(aBinding2)
		
		nLen1 = len(acKeys1)
		for i = 1 to nLen1
			cKey = acKeys1[i]
			if HasKey(aBinding2, cKey)
				aVal1 = aBinding1[cKey]
				aVal2 = aBinding2[cKey]
				
				if HasKey(aVal1, :id) and HasKey(aVal2, :id)
					if aVal1[:id] != aVal2[:id]
						return FALSE
					ok
				ok
			ok
		next
		
		return TRUE
	
	#------------------#
	#  WHERE FILTERS   #
	#------------------#
	
	def _EvaluateCondition(pCondition, aBinding)
		if @IsFunction(pCondition)
			return call pCondition(aBinding)
		ok
		
		if NOT isList(pCondition)
			return TRUE
		ok
		
		cOp = pCondition["op"]
		
		if cOp = :equals
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = pCondition["right"]
			
			if isString(pRight) and substr(pRight, ".") > 0
				pRight = This._ResolveValue(pRight, aBinding)
			ok
			
			return pLeft = pRight
			
		but cOp = :gt
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft > pRight
			
		but cOp = :lt
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft < pRight
			
		but cOp = :gte
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft >= pRight
			
		but cOp = :lte
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isNumber(pLeft) and isNumber(pRight) and pLeft <= pRight
			
		but cOp = :not_equals
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return pLeft != pRight
			
		but cOp = :contains
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isString(pLeft) and isString(pRight) and substr(lower(pLeft), lower(pRight)) > 0
			
		but cOp = :startswith
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isString(pLeft) and isString(pRight) and left(lower(pLeft), len(pRight)) = lower(pRight)
			
		but cOp = :endswith
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			pRight = This._ResolveValue(pCondition["right"], aBinding)
			return isString(pLeft) and isString(pRight) and right(lower(pLeft), len(pRight)) = lower(pRight)
			
		but cOp = :and
			return This._EvaluateCondition(pCondition["left"], aBinding) and
				   This._EvaluateCondition(pCondition["right"], aBinding)
				   
		but cOp = :or
			return This._EvaluateCondition(pCondition["left"], aBinding) or
				   This._EvaluateCondition(pCondition["right"], aBinding)
				   
		but cOp = :not
			return NOT This._EvaluateCondition(pCondition["left"], aBinding)
			
		but cOp = :in
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			aRight = pCondition["right"]
			return isList(aRight) and ring_find(aRight, pLeft) > 0
			
		but cOp = :not_in
			pLeft = This._ResolveValue(pCondition["left"], aBinding)
			aRight = pCondition["right"]
			return isList(aRight) and ring_find(aRight, pLeft) = 0
		ok
		
		return TRUE
	
	def _ResolveValue(pValue, aBinding)
		if isString(pValue)
			if substr(pValue, ".") > 0
				acParts = @split(pValue, ".")
				cVar = acParts[1]
				cProp = acParts[2]
				
				# Handle edge_data specially
				if cVar = "edge_data" and HasKey(aBinding, "edge_data")
					aEdge = aBinding["edge_data"]
					if HasKey(aEdge, :properties)
						aProps = aEdge[:properties]
						if isList(aProps) and len(aProps) > 0
							if HasKey(aProps, cProp)
								return aProps[cProp]
							ok
						ok
					ok
					return NULL
				ok
				
				if HasKey(aBinding, cVar)
					aNode = aBinding[cVar]
					
					if cProp = "id" and HasKey(aNode, :id)
						return aNode[:id]
					ok
				
				if HasKey(aNode, :properties)
					aProps = aNode[:properties]
					if isList(aProps) and len(aProps) > 0
						if HasKey(aProps, cProp)
							return aProps[cProp]
						ok
					ok
				ok
			ok
			
			# Check edge_data for edge properties (fallback)
			if cVar = "node" and HasKey(aBinding, "edge_data")
				aEdge = aBinding["edge_data"]
				if HasKey(aEdge, :properties)
					aProps = aEdge[:properties]
					if isList(aProps) and len(aProps) > 0
						if HasKey(aProps, cProp)
							return aProps[cProp]
						ok
					ok
				ok
			ok
			
			return NULL
		ok
		
		if HasKey(aBinding, pValue)
			return aBinding[pValue]
		ok
	ok
	
	return pValue

#---------------------#
#  SELECT PROJECTION  #
#---------------------#

def _ExecuteSelect(aBindings)
	aResults = []
	nLen = len(aBindings)
	
	for i = 1 to nLen
		aBinding = aBindings[i]
		aResult = []
		
		nFieldLen = len(@aDefinition["select_fields"])
		
		for j = 1 to nFieldLen
			pField = @aDefinition["select_fields"][j]
			
			if isString(pField)
				pValue = This._ResolveValue(pField, aBinding)
				aResult + [pField, pValue]
			
			but isList(pField) and HasKey(pField, "alias")
				cField = pField["field"]
				cAlias = pField["alias"]
				pValue = This._ResolveValue(cField, aBinding)
				aResult + [cAlias, pValue]
			ok
		next

		aResults + aResult
	next
	
	if @aDefinition["distinct"]
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
		
		if isList(pVal1) and isList(pVal2) and HasKey(pVal1, :id) and HasKey(pVal2, :id)
			if pVal1[:id] != pVal2[:id]
				return FALSE
			ok
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
	nLen = len(@aDefinition["create_patterns"])
	for i = 1 to nLen
		aPattern = @aDefinition["create_patterns"][i]
		cPatternType = aPattern["type"]
		
		if cPatternType = :node
			This._CreateNode(aPattern)
		but cPatternType = :edge
			This._CreateEdge(aPattern, aBindings)
		ok
	next

def _CreateNode(aPattern)
	cLabel = aPattern["label"]
	aProps = aPattern["props"]
	
	cNodeId = "node_" + UUID()
	
	if isList(aProps) and len(aProps) > 0
		@oGraph.AddNodeXTT(cNodeId, cLabel, aProps)
	else
		@oGraph.AddNodeXT(cNodeId, cLabel)
	ok

def _CreateEdge(aPattern, aBindings)
	cFromVar = aPattern["from"]
	cToVar = aPattern["to"]
	cLabel = aPattern["label"]
	aProps = aPattern["props"]
	
	nLen = len(aBindings)
	for i = 1 to nLen
		aBinding = aBindings[i]
		
		if HasKey(aBinding, cFromVar) and HasKey(aBinding, cToVar)
			aFromNode = aBinding[cFromVar]
			aToNode = aBinding[cToVar]
			
			cFromId = aFromNode[:id]
			cToId = aToNode[:id]
			
			if isList(aProps) and len(aProps) > 0
				@oGraph.AddEdgeXTT(cFromId, cToId, cLabel, aProps)
			else
				@oGraph.AddEdgeXT(cFromId, cToId, cLabel)
			ok
		ok
	next

def _ExecuteSet(aBindings)
	nLen = len(@aDefinition["set_operations"])
	
	for i = 1 to nLen
		aOp = @aDefinition["set_operations"][i]
		cOpType = aOp["op"]
		
		if cOpType = :set
			This._ExecuteSetProperty(aOp, aBindings)
		ok
	next

def _ExecuteSetProperty(aOp, aBindings)
	cTarget = aOp["property"]
	pValue = aOp["value"]
	
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

def _ExecuteDelete(aBindings)
	acToDelete = []
	
	nLen = len(aBindings)
	for i = 1 to nLen
		aBinding = aBindings[i]
		
		nTargetLen = len(@aDefinition["delete_targets"])
		for j = 1 to nTargetLen
			cTarget = @aDefinition["delete_targets"][j]
			
			if HasKey(aBinding, cTarget)
				aNode = aBinding[cTarget]
				cId = aNode[:id]
				if ring_find(acToDelete, cId) = 0
					acToDelete + cId
				ok
			ok
		next
	next
	
	nLen = len(acToDelete)
	for i = 1 to nLen
		@oGraph.RemoveThisNode(acToDelete[i])
	next

#------------------#
#  ORDERING/LIMIT  #
#------------------#

def _ApplyOrderBy(aResults)
	if len(@aDefinition["order_by"]) = 0
		return aResults
	ok
	
	aOrderDef = @aDefinition["order_by"][1]
	cField = aOrderDef["field"]
	cDirection = aOrderDef["direction"]
	
	# Extract values for sorting
	aValues = []
	nLen = len(aResults)
	for i = 1 to nLen
		pVal = This._GetResultValue(aResults[i], cField)
		aValues + [i, pVal]
	next
	
	# Sort using Softanza
	@SortOn(aValues, 2)
	
	# Apply descending if needed
	if cDirection = "desc"
		@Reverse(aValues)
	ok
	
	# Rebuild results in sorted order
	aSorted = []
	nLen = len(aValues)
	for i = 1 to nLen
		nOrigIndex = aValues[i][1]
		aSorted + aResults[nOrigIndex]
	next
	
	return aSorted

def _GetResultValue(aResult, cField)
	if substr(cField, ".") > 0
		acParts = @split(cField, ".")
		cVar = acParts[1]
		cProp = acParts[2]
		
		if HasKey(aResult, cVar)
			aNode = aResult[cVar]
			if isList(aNode) and HasKey(aNode, :properties)
				aProps = aNode[:properties]
				if HasKey(aProps, cProp)
					return aProps[cProp]
				ok
			ok
		ok
		return NULL
	ok
	
	if HasKey(aResult, cField)
		return aResult[cField]
	ok
	
	return NULL

def _ApplySkip(aResults)
	if @aDefinition["skip"] = 0 or @aDefinition["skip"] >= len(aResults)
		return []
	ok
	
	aSkipped = []
	nLen = len(aResults)
	for i = @aDefinition["skip"] + 1 to nLen
		aSkipped + aResults[i]
	next
	
	return aSkipped

def _ApplyLimit(aResults)
	if @aDefinition["limit"] = 0 or @aDefinition["limit"] >= len(aResults)
		return aResults
	ok
	
	aLimited = []
	for i = 1 to @aDefinition["limit"]
		aLimited + aResults[i]
	next
	
	return aLimited

#------------------#
#  HELPER METHODS  #
#------------------#

def _NodeHasProperty(aNode, cKey, pValue)
	if NOT HasKey(aNode, :properties)
		return FALSE
	ok
	
	aProps = aNode[:properties]
	if NOT HasKey(aProps, cKey)
		return FALSE
	ok
	
	return aProps[cKey] = pValue

def _EdgeHasProperty(aEdge, cKey, pValue)
	if NOT HasKey(aEdge, :properties)
		return FALSE
	ok
	
	aProps = aEdge[:properties]
	if NOT HasKey(aProps, cKey)
		return FALSE
	ok
	
	return aProps[cKey] = pValue

#-------------------------------------------#
#  EXPLANATION OF THE QUERY EXECUTION PLAN  #
#-------------------------------------------#

def Explain()
	aExplanation = []
	
	# Match patterns
	if len(@aDefinition["match_patterns"]) > 0
		acMatch = []
		nLen = len(@aDefinition["match_patterns"])
		for i = 1 to nLen
			aPattern = @aDefinition["match_patterns"][i]
			cType = aPattern["type"]
			
			if cType = :node
				cVar = aPattern["alias"]
				cLabel = aPattern["label"]
				
				cDesc = "Scan all nodes, bind to variable '" + cVar + "'"
				
				if cLabel != ""
					cDesc += " with label '" + cLabel + "'"
				ok
				
				aProps = aPattern["props"]
				if isList(aProps) and len(aProps) > 0
					cDesc += " with properties " + This._FormatProps(aProps)
				ok
				
				# Add WHERE condition if present in pattern
				if HasKey(aPattern, "where")
					cDesc += " where " + This._ExplainCondition(aPattern["where"], "")
				ok
				
				acMatch + cDesc
				
			but cType = :edge
				cFrom = aPattern["from"]
				cTo = aPattern["to"]
				cLabel = aPattern["label"]
				
				cDesc = "Match edges: (" + cFrom + ")-[]->("  + cTo + ")"
				
				if cLabel != ""
					cDesc += " of type '" + cLabel + "'"
				ok
				
				# Add WHERE condition if present in pattern
				if HasKey(aPattern, "where")
					cDesc += " where " + This._ExplainCondition(aPattern["where"], "")
				ok
				
				acMatch + cDesc
			ok
		next
		aExplanation + [ ["step", "match"], ["description", acMatch] ]
	ok
	
	# Global Where conditions (only if any exist)
	if len(@aDefinition["where_conditions"]) > 0
		acWhere = []
		nLen = len(@aDefinition["where_conditions"])
		for i = 1 to nLen
			cCondDesc = This._ExplainCondition(@aDefinition["where_conditions"][i], "")
			acWhere + ("Filter bindings using: " + cCondDesc)
		next
		aExplanation + [ ["step", "where"], ["description", acWhere] ]
	ok
	
	# Create patterns
	if len(@aDefinition["create_patterns"]) > 0
		acCreate = []
		nLen = len(@aDefinition["create_patterns"])
		for i = 1 to nLen
			aPattern = @aDefinition["create_patterns"][i]
			cType = aPattern["type"]
			
			if cType = :node
				acCreate + "Create new node"
			but cType = :edge
				acCreate + "Create new edge"
			ok
		next
		aExplanation + [ ["step", "create"], ["description", acCreate] ]
	ok
	
	# Set operations
	if len(@aDefinition["set_operations"]) > 0
		acSet = []
		nLen = len(@aDefinition["set_operations"])
		for i = 1 to nLen
			aOp = @aDefinition["set_operations"][i]
			cProp = aOp["property"]
			pVal = aOp["value"]
			acSet + ("Set property: " + cProp + " = " + This._FormatValue(pVal))
		next
		aExplanation + [ ["step", "set"], ["description", acSet] ]
	ok
	
	# Delete targets
	if len(@aDefinition["delete_targets"]) > 0
		acDelete = []
		nLen = len(@aDefinition["delete_targets"])
		for i = 1 to nLen
			acDelete + ("Delete node: " + @aDefinition["delete_targets"][i])
		next
		aExplanation + [ ["step", "delete"], ["description", acDelete] ]
	ok
	
	# Select fields
	if len(@aDefinition["select_fields"]) > 0
		acSelect = []
		
		if @aDefinition["distinct"]
			acSelect + "Apply DISTINCT filter"
		ok
		
		cFields = "Project fields: "
		nLen = len(@aDefinition["select_fields"])
		for i = 1 to nLen
			pField = @aDefinition["select_fields"][i]
			
			if isString(pField)
				cFields += pField
			but isList(pField) and HasKey(pField, "alias")
				cFields += pField["field"] + " AS " + pField["alias"]
			ok
			
			if i < nLen
				cFields += ", "
			ok
		next
		acSelect + cFields
		
		aExplanation + [ ["step", "select"], ["description", acSelect] ]
	ok
	
	# Order by
	if len(@aDefinition["order_by"]) > 0
		aOrder = @aDefinition["order_by"][1]
		cField = aOrder["field"]
		cDir = upper(aOrder["direction"])
		aExplanation + [ ["step", "orderby"], ["description", ["Sort by: " + cField + " " + cDir]] ]
	ok
	
	# Skip
	if @aDefinition["skip"] > 0
		aExplanation + [ ["step", "skip"], ["description", ["Skip first " + @aDefinition["skip"] + " results"]] ]
	ok
	
	# Limit
	if @aDefinition["limit"] > 0
		aExplanation + [ ["step", "limit"], ["description", ["Return maximum " + @aDefinition["limit"] + " results"]] ]
	ok
	
	return aExplanation

def _ExplainCondition(pCondition, pcVarName)
	if @IsFunction(pCondition)
		return "Custom function filter"
	ok
	
	if NOT isList(pCondition)
		return "Always true"
	ok
	
	cOp = pCondition["op"]
	cLeft = pCondition["left"]
	pRight = pCondition["right"]
	
	if cOp = :equals
		return cLeft + " = " + This._FormatValue(pRight)
		
	but cOp = :gt
		return cLeft + " > " + This._FormatValue(pRight)
		
	but cOp = :lt
		return cLeft + " < " + This._FormatValue(pRight)
		
	but cOp = :gte
		return cLeft + " >= " + This._FormatValue(pRight)
		
	but cOp = :lte
		return cLeft + " <= " + This._FormatValue(pRight)
		
	but cOp = :not_equals
		return cLeft + " != " + This._FormatValue(pRight)
		
	but cOp = :contains
		return cLeft + " CONTAINS " + This._FormatValue(pRight)
		
	but cOp = :startswith
		return cLeft + " STARTS WITH " + This._FormatValue(pRight)
		
	but cOp = :endswith
		return cLeft + " ENDS WITH " + This._FormatValue(pRight)
		
	but cOp = :and
		return "(" + This._ExplainCondition(cLeft, "") + " AND " +
			   This._ExplainCondition(pRight, "") + ")"
			   
	but cOp = :or
		return "(" + This._ExplainCondition(cLeft, "") + " OR " +
			   This._ExplainCondition(pRight, "") + ")"
			   
	but cOp = :not
		return "NOT (" + This._ExplainCondition(cLeft, "") + ")"
		
	but cOp = :in
		return cLeft + " IN " + This._FormatValue(pRight)
		
	but cOp = :not_in
		return cLeft + " NOT IN " + This._FormatValue(pRight)
	ok
	
	return "Unknown condition"

def _FormatProps(aProps)
	if NOT isList(aProps) or len(aProps) = 0
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

#----------------------------#
#  OPENCYPHER IMPORT/EXPORT  #
#----------------------------#

def ToOpenCypher()
	cCypher = ""
	
	# MATCH clause
	if len(@aDefinition["match_patterns"]) > 0
		cCypher += "MATCH "
		nLen = len(@aDefinition["match_patterns"])
		
		for i = 1 to nLen
			aPattern = @aDefinition["match_patterns"][i]
			cCypher += This._PatternToCypher(aPattern)
			
			if i < nLen
				cCypher += ", "
			ok
		next
		cCypher += NL
	ok
	
	# WHERE clause - check both pattern-level and global conditions
	acWhereConditions = []
	
	# Collect WHERE from patterns
	if len(@aDefinition["match_patterns"]) > 0
		nLen = len(@aDefinition["match_patterns"])
		for i = 1 to nLen
			aPattern = @aDefinition["match_patterns"][i]
			if HasKey(aPattern, "where")
				acWhereConditions + This._ConditionToCypher(aPattern["where"])
			ok
		next
	ok
	
	# Add global WHERE conditions
	nLen = len(@aDefinition["where_conditions"])
	for i = 1 to nLen
		acWhereConditions + This._ConditionToCypher(@aDefinition["where_conditions"][i])
	next
	
	# Output WHERE clause if any conditions exist
	if len(acWhereConditions) > 0
		cCypher += "WHERE "
		nLen = len(acWhereConditions)
		for i = 1 to nLen
			cCypher += acWhereConditions[i]
			if i < nLen
				cCypher += " AND "
			ok
		next
		cCypher += NL
	ok
	
	# CREATE clause
	if len(@aDefinition["create_patterns"]) > 0
		cCypher += "CREATE "
		nLen = len(@aDefinition["create_patterns"])
		
		for i = 1 to nLen
			aPattern = @aDefinition["create_patterns"][i]
			cCypher += This._PatternToCypher(aPattern)
			
			if i < nLen
				cCypher += ", "
			ok
		next
		cCypher += NL
	ok
	
	# SET clause
	if len(@aDefinition["set_operations"]) > 0
		cCypher += "SET "
		nLen = len(@aDefinition["set_operations"])
		
		for i = 1 to nLen
			aOp = @aDefinition["set_operations"][i]
			cProp = aOp["property"]
			pVal = aOp["value"]
			cCypher += cProp + " = " + This._ValueToCypher(pVal)
			
			if i < nLen
				cCypher += ", "
			ok
		next
		cCypher += NL
	ok
	
	# DELETE clause
	if len(@aDefinition["delete_targets"]) > 0
		cCypher += "DELETE "
		cCypher += JoinXT(@aDefinition["delete_targets"], ", ")
		cCypher += NL
	ok
	
	# RETURN clause
	if len(@aDefinition["select_fields"]) > 0
		cCypher += "RETURN "
		if @aDefinition["distinct"]
			cCypher += "DISTINCT "
		ok
		
		nLen = len(@aDefinition["select_fields"])
		for i = 1 to nLen
			pField = @aDefinition["select_fields"][i]
			
			if isString(pField)
				cCypher += pField
			but isList(pField) and HasKey(pField, "alias")
				cCypher += pField["field"] + " AS " + pField["alias"]
			ok
			
			if i < nLen
				cCypher += ", "
			ok
		next
		cCypher += NL
	ok
	
	# ORDER BY clause
	if len(@aDefinition["order_by"]) > 0
		cCypher += "ORDER BY "
		aOrder = @aDefinition["order_by"][1]
		cCypher += aOrder["field"] + " " + UPPER(aOrder["direction"])
		cCypher += NL
	ok
	
	# SKIP clause
	if @aDefinition["skip"] > 0
		cCypher += "SKIP " + @aDefinition["skip"] + NL
	ok
	
	# LIMIT clause
	if @aDefinition["limit"] > 0
		cCypher += "LIMIT " + @aDefinition["limit"] + NL
	ok
	
	return cCypher

def _PatternToCypher(aPattern)
	cType = aPattern["type"]
	
	if cType = :node
		cVar = aPattern["alias"]
		cLabel = aPattern["label"]
		aProps = aPattern["props"]
		
		cResult = "(" + cVar
		
		if cLabel != ""
			cResult += ":" + cLabel
		ok
		
		if isList(aProps) and len(aProps) > 0
			cResult += " " + This._PropsToCypher(aProps)
		ok
		
		cResult += ")"
		return cResult
		
	but cType = :edge
		cFrom = aPattern["from"]
		cTo = aPattern["to"]
		cLabel = aPattern["label"]
		aProps = aPattern["props"]
		
		cResult = "(" + cFrom + ")-["
		
		if cLabel != ""
			cResult += ":" + cLabel
		ok
		
		if isList(aProps) and len(aProps) > 0
			cResult += " " + This._PropsToCypher(aProps)
		ok
		
		cResult += "]->("
		cResult += cTo + ")"
		return cResult
	ok
	
	return ""

def _ConditionToCypher(pCondition)
	if NOT isList(pCondition)
		return ""
	ok
	
	cOp = pCondition["op"]
	pLeft = pCondition["left"]
	pRight = pCondition["right"]
	
	if cOp = :equals
		return pLeft + " = " + This._ValueToCypher(pRight)
		
	but cOp = :gt
		return pLeft + " > " + This._ValueToCypher(pRight)
		
	but cOp = :lt
		return pLeft + " < " + This._ValueToCypher(pRight)
		
	but cOp = :gte
		return pLeft + " >= " + This._ValueToCypher(pRight)
		
	but cOp = :lte
		return pLeft + " <= " + This._ValueToCypher(pRight)
		
	but cOp = :not_equals
		return pLeft + " <> " + This._ValueToCypher(pRight)
		
	but cOp = :contains
		return pLeft + " CONTAINS " + This._ValueToCypher(pRight)
		
	but cOp = :startswith
		return pLeft + " STARTS WITH " + This._ValueToCypher(pRight)
		
	but cOp = :endswith
		return pLeft + " ENDS WITH " + This._ValueToCypher(pRight)
		
	but cOp = :and
		return "(" + This._ConditionToCypher(pLeft) + " AND " + 
			   This._ConditionToCypher(pRight) + ")"
			   
	but cOp = :or
		return "(" + This._ConditionToCypher(pLeft) + " OR " + 
			   This._ConditionToCypher(pRight) + ")"
			   
	but cOp = :not
		return "NOT " + This._ConditionToCypher(pLeft)
		
	but cOp = :in
		return pLeft + " IN " + This._ValueToCypher(pRight)
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
		cResult = "["
		nLen = len(pValue)
		for i = 1 to nLen
			cResult += This._ValueToCypher(pValue[i])
			if i < nLen
				cResult += ", "
			ok
		next
		cResult += "]"
		return cResult
	ok
	return "null"
