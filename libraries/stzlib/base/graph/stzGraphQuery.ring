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

class stzGraphQuery from stzObject
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
	
	# The graph this query runs against -- an OBJECT, hence Q.
	def GraphQ()
		return @oGraph

	# ... and its NAME, for a reader who only wants to know which graph.
	def Graph()
		return @oGraph.Name()

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
		_aInternal_ = [ ["type", :node], ["alias", "node"], ["label", ""], ["props", []] ]
		
		if isList(paParams)
			# Check for simple [:nodes] or first element patterns
			if len(paParams) > 0 and (paParams[1] = :nodes or paParams[1] = :node)
				# Look for :where, :labeled, :props in subsequent elements
				_nParamsLen_3 = len(paParams)
				for i = 2 to _nParamsLen_3
					if isList(paParams[i]) and len(paParams[i]) >= 2
						if paParams[i][1] = :where
							_aWhere_ = paParams[i][2]
							_aInternalCond_ = This._NormalizeCondition(_aWhere_, _aInternal_["alias"])
							_aInternal_["where"] = _aInternalCond_
						but paParams[i][1] = :labeled
							_aInternal_["label"] = paParams[i][2]
						but paParams[i][1] = :props or paParams[i][1] = :properties
							_aInternal_["props"] = paParams[i][2]
						ok
					ok
				next
				
				@aDefinition["match_patterns"] + _aInternal_
				return
			ok
			
			# Extract node alias if specified
			if HasKey(paParams, :node)
				_aInternal_["alias"] = paParams[:node]
			ok
			
			# Extract label
			if HasKey(paParams, :labeled)
				_aInternal_["label"] = paParams[:labeled]
			ok
			
			# Extract properties
			if HasKey(paParams, :props) or HasKey(paParams, :properties)
				_aProps_ = paParams[:props]
				if _aProps_ = ""
					_aProps_ = paParams[:properties]
				ok
				_aInternal_["props"] = _aProps_
			ok
			
			# Auto-add where condition to pattern
			if HasKey(paParams, :where)
				_aWhere_ = paParams[:where]
				_aInternalCond_ = This._NormalizeCondition(_aWhere_, _aInternal_["alias"])
				_aInternal_["where"] = _aInternalCond_
			ok
		ok
		
		@aDefinition["match_patterns"] + _aInternal_
	
		def MatchQ(paParams)
			This.Match(paParams)
			return This

	def MatchEdge(paParams)
		# Build internal hashlist
		_aInternal_ = [ 
			["type", :edge], 
			["from", "from_node"], 
			["to", "to_node"], 
			["label", ""], 
			["props", []] 
		]
		
		if isList(paParams)
			# Extract from list format
			_nParamsLen_2 = len(paParams)
			for i = 1 to _nParamsLen_2
				if isList(paParams[i]) and len(paParams[i]) >= 2
					if paParams[i][1] = :from
						_aInternal_["from"] = paParams[i][2]
					but paParams[i][1] = :to
						_aInternal_["to"] = paParams[i][2]
					but paParams[i][1] = :labeled
						_aInternal_["label"] = paParams[i][2]
					but paParams[i][1] = :props or paParams[i][1] = :properties
						_aInternal_["props"] = paParams[i][2]
					but paParams[i][1] = :where
						_aWhere_ = paParams[i][2]
						_aInternalCond_ = This._NormalizeCondition(_aWhere_, "edge_data")
						_aInternal_["where"] = _aInternalCond_
					ok
				ok
			next
		ok
		
		@aDefinition["match_patterns"] + _aInternal_
	
		def MatchEdgeQ(paParams)
			This.MatchEdge(paParams)
			return This

	def Where(paCondition)
		if @IsFunction(paCondition)
			# Add to last pattern if exists, otherwise global
			if len(@aDefinition["match_patterns"]) > 0
				_nLast_ = len(@aDefinition["match_patterns"])
				@aDefinition["match_patterns"][_nLast_]["where"] = paCondition
			else
				@aDefinition["where_conditions"] + paCondition
			ok
			return
		ok
		
		# Convert natural condition to internal hashlist format
		_aInternalCond_ = This._NormalizeCondition(paCondition, "node")
		
		# Add to last pattern if exists, otherwise global
		if len(@aDefinition["match_patterns"]) > 0
			_nLast_ = len(@aDefinition["match_patterns"])
			# Get variable name from last pattern
			_cVar_ = "node"
			if HasKey(@aDefinition["match_patterns"][_nLast_], "alias")
				_cVar_ = @aDefinition["match_patterns"][_nLast_]["alias"]
			ok
			_aInternalCond_ = This._NormalizeCondition(paCondition, _cVar_)
			@aDefinition["match_patterns"][_nLast_]["where"] = _aInternalCond_
		else
			@aDefinition["where_conditions"] + _aInternalCond_
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
			_cProp_ = paCondition[1]
			_cOp_ = paCondition[2]
			pValue = paCondition[3]
			
			# Convert operator
			_cInternalOp_ = This._ConvertOp(_cOp_)
			
			# Add implicit variable if needed
			if isString(_cProp_) and NOT StzFindFirst(".", _cProp_)
				_cProp_ = pcVarName + "." + _cProp_
			ok
			
			return [ ["op", _cInternalOp_], ["left", _cProp_], ["right", pValue] ]
		ok
		
		# Compound condition
		if len(paCondition) > 3
			_nLogicPos_ = 0
			_nLen_ = len(paCondition)
			for i = 1 to _nLen_
				if paCondition[i] = :and or paCondition[i] = :or
					_nLogicPos_ = i
					exit
				ok
			next
			
			if _nLogicPos_ > 0
				_aLeft_ = []
				for i = 1 to _nLogicPos_ - 1
					_aLeft_ + paCondition[i]
				next
				
				_aRight_ = []
				for i = _nLogicPos_ + 1 to _nLen_
					_aRight_ + paCondition[i]
				next
				
				_cLogic_ = paCondition[_nLogicPos_]
				
				return [ 
					["op", _cLogic_],
					["left", This._NormalizeCondition(_aLeft_, pcVarName)],
					["right", This._NormalizeCondition(_aRight_, pcVarName)]
				]
			ok
		ok
		
		return paCondition
	
	def _ConvertOp(_cOp_)
		if _cOp_ = ">"
			return :gt
		but _cOp_ = "<"
			return :lt
		but _cOp_ = ">="
			return :gte
		but _cOp_ = "<="
			return :lte
		but _cOp_ = "="
			return :equals
		but _cOp_ = "!="
			return :not_equals
		but _cOp_ = :contains
			return :contains
		but _cOp_ = :startswith
			return :startswith
		but _cOp_ = :endswith
			return :endswith
		but _cOp_ = :in
			return :in
		but _cOp_ = :not_in
			return :not_in
		ok
		
		return _cOp_

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
	        _acVars_ = []
	        _nLen_ = len(@aDefinition["match_patterns"])
	        for i = 1 to _nLen_
	            _aPattern_ = @aDefinition["match_patterns"][i]
	            if _aPattern_["type"] = :node
	                _cVar_ = _aPattern_["alias"]
	                if StzFindFirst(_cVar_, _acVars_) = 0
	                    _acVars_ + _cVar_
	                ok
	            but _aPattern_["type"] = :edge
	                _cFrom_ = _aPattern_["from"]
	                _cTo_ = _aPattern_["to"]
	                if StzFindFirst(_cFrom_, _acVars_) = 0
	                    _acVars_ + _cFrom_
	                ok
	                if StzFindFirst(_cTo_, _acVars_) = 0
	                    _acVars_ + _cTo_
	                ok
	            ok
	        next
	        
	        # Add all variables to select fields
	        _nLen_ = len(_acVars_)
	        for i = 1 to _nLen_
	            @aDefinition["select_fields"] + _acVars_[i]
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
	            _cField_ = paFields[1]
	            _cAlias_ = paFields[2][2]
	            
	            @aDefinition["select_fields"] + [ ["field", _cField_], ["alias", _cAlias_] ]
	            This._Execute()  # Add this line
	            return @aResult   # Add this line
	        ok
	    ok
	    
	    # List of field names
	    _nLen_ = len(paFields)
	    for i = 1 to _nLen_
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

		pcDirection = StzLower(pcDirection)

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
		
		_cType_ = :node
		if paParams[1] = :node or paParams[1] = :nodes
			_cType_ = :node
		but paParams[1] = :edge or paParams[1] = :edges
			_cType_ = :edge
		ok
		
		if _cType_ = :node
			_aInternal_ = [ ["type", :node], ["label", ""], ["props", []] ]
			
			if HasKey(paParams, :labeled)
				_aInternal_["label"] = paParams[:labeled]
			ok
			
			if HasKey(paParams, :props) or HasKey(paParams, :properties)
				_aProps_ = paParams[:props]
				if _aProps_ = ""
					_aProps_ = paParams[:properties]
				ok
				_aInternal_["props"] = _aProps_
			ok
			
			@aDefinition["create_patterns"] + _aInternal_
		
		but _cType_ = :edge
			_aInternal_ = [ 
				["type", :edge], 
				["from", ""], 
				["to", ""], 
				["label", ""], 
				["props", []] 
			]
			
			# Extract from list format
			_nParamsLen_ = len(paParams)
			for i = 2 to _nParamsLen_
				if isList(paParams[i]) and len(paParams[i]) >= 2
					if paParams[i][1] = :from
						_aInternal_["from"] = paParams[i][2]
					but paParams[i][1] = :to
						_aInternal_["to"] = paParams[i][2]
					but paParams[i][1] = :labeled
						_aInternal_["label"] = paParams[i][2]
					but paParams[i][1] = :props or paParams[i][1] = :properties
						_aInternal_["props"] = paParams[i][2]
					ok
				ok
			next
			
			@aDefinition["create_patterns"] + _aInternal_
		ok
	
		def CreateQ(paParams)
			This.Create(paParams)
			return This

	def Delete(paTargets)
		if isString(paTargets)
			@aDefinition["delete_targets"] + paTargets

		but isList(paTargets)
			_nLen_ = len(paTargets)
			for i = 1 to _nLen_
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
		_aBindings_ = []
		
		if len(@aDefinition["match_patterns"]) > 0
			_aBindings_ = This._ExecuteMatch()
		ok
	
		@aBindings = _aBindings_  # NEW - store for ToGraph()
		
		if len(@aDefinition["create_patterns"]) > 0
			This._ExecuteCreate(_aBindings_)
		ok
		
		if len(@aDefinition["set_operations"]) > 0
			This._ExecuteSet(_aBindings_)
		ok
	
		# NEW - Execute rule triggers
		if len(@aDefinition["rule_triggers"]) > 0
			This._ExecuteRuleTriggers(_aBindings_)
		ok
		
		if len(@aDefinition["delete_targets"]) > 0
			This._ExecuteDelete(_aBindings_)
		ok
		
		if len(@aDefinition["select_fields"]) > 0
			_aBindings_ = This._ExecuteSelect(_aBindings_)
		ok
		
		if len(@aDefinition["order_by"]) > 0
			_aBindings_ = This._ApplyOrderBy(_aBindings_)
		ok
		
		if @aDefinition["skip"] > 0
			_aBindings_ = This._ApplySkip(_aBindings_)
		ok
		
		if @aDefinition["limit"] > 0
			_aBindings_ = This._ApplyLimit(_aBindings_)
		ok
		
		@aResult = _aBindings_
		return TRUE

	def Result()
		return @aResult

	#--------------------------#
	#  RULE TRIGGER EXECUTION  #
	#--------------------------#
	
	def _ExecuteRuleTriggers(_aBindings_)
		_nLen_ = len(@aDefinition["rule_triggers"])
		
		for i = 1 to _nLen_
			_aTrigger_ = @aDefinition["rule_triggers"][i]
			_cType_ = _aTrigger_[:type]
			
			if _cType_ = :apply
				This._ApplyRuleToBindings(_aTrigger_[:rule], _aBindings_)
			
			but _cType_ = :enforce
				This._EnforceRuleOnBindings(_aTrigger_[:rule], _aBindings_)
			
			but _cType_ = :validate
				This._ValidateBindings(_aTrigger_[:validators], _aBindings_)
	
			but _cType_ = :derive
				This._DeriveFromBindings(_aTrigger_[:rule], _aBindings_)
			ok
		next
	
	def _ApplyRuleToBindings(pcRuleName, _aBindings_)
		_aRule_ = This._FindRuleInGraph(pcRuleName)
		
		if _aRule_ = NULL
			stzraise("Rule '" + pcRuleName + "' not found!")
		ok
	
		if _aRule_[:type] != :Derivation
			stzraise("Rule must be Derivation type!")
		ok
	
		_acNodeIds_ = This._ExtractNodeIdsFromBindings(_aBindings_)
		_oSubgraph_ = This._CreateSubgraphView(_acNodeIds_)
		
		pFunc = _aRule_[:function]
		paParams = _aRule_[:params]
		_aNewEdges_ = call pFunc(_oSubgraph_, paParams)
		
		_nLen_ = len(_aNewEdges_)
		for i = 1 to _nLen_
			_aEdge_ = _aNewEdges_[i]
			@oGraph.AddEdgeXTT(_aEdge_[1], _aEdge_[2], _aEdge_[3], _aEdge_[4])
		next
	
	def _EnforceRuleOnBindings(pcRuleName, _aBindings_)
		_aRule_ = This._FindRuleInGraph(pcRuleName)
		
		if _aRule_ = NULL
			stzraise("Rule '" + pcRuleName + "' not found!")
		ok
	
		if _aRule_[:type] != :Constraint
			stzraise("Rule must be Constraint type!")
		ok
	
		pFunc = _aRule_[:function]
		paParams = _aRule_[:params]
		
		_nLen_ = len(_aBindings_)
		for i = 1 to _nLen_
			_aBinding_ = _aBindings_[i]
			_aOpParams_ = This._BuildOpParamsFromBinding(_aBinding_)
			_aResult_ = call pFunc(@oGraph, paParams, _aOpParams_)
			
			if _aResult_[1]
				stzraise("Constraint violated: " + _aResult_[2])
			ok
		next
	
	def _ValidateBindings(paValidators, _aBindings_)
		_acNodeIds_ = This._ExtractNodeIdsFromBindings(_aBindings_)
		_oSubgraph_ = This._CreateSubgraphView(_acNodeIds_)
		_aResult_ = _oSubgraph_.ValidateXT(paValidators)
		
		if _aResult_[:status] = "fail"
			_cMsg_ = "Validation failed:" + NL
			_nLen_ = len(_aResult_[:issues])
			for i = 1 to _nLen_
				_cMsg_ += "  - " + _aResult_[:issues][i] + NL
			next
			stzraise(_cMsg_)
		ok
	
	def _DeriveFromBindings(pcRuleName, _aBindings_)
		This._ApplyRuleToBindings(pcRuleName, _aBindings_)
	
	def _FindRuleInGraph(pcRuleName)
		pcRuleName = UPPER(pcRuleName)
		
		_aLists_ = [
			@oGraph.@aConstraintRules,
			@oGraph.@aDerivationRules,
			@oGraph.@aValidationRules
		]
		
		_nListLen_ = len(_aLists_)
		for i = 1 to _nListLen_
			_aRules_ = _aLists_[i]
			_nLen_ = len(_aRules_)
			for j = 1 to _nLen_
				if _aRules_[j][:name] = pcRuleName
					return _aRules_[j]
				ok
			next
		next
		
		return NULL
	
	def _ExtractNodeIdsFromBindings(_aBindings_)
		_acNodeIds_ = []
		
		_nLen_ = len(_aBindings_)
		for i = 1 to _nLen_
			_aBinding_ = _aBindings_[i]
			_acKeys_ = keys(_aBinding_)
			
			_nKeyLen_ = len(_acKeys_)
			for j = 1 to _nKeyLen_
				pValue = _aBinding_[_acKeys_[j]]
				
				if isList(pValue) and HasKey(pValue, :id)
					_cId_ = pValue[:id]
					if StzFindFirst(_cId_, _acNodeIds_) = 0
						_acNodeIds_ + _cId_
					ok
				ok
			next
		next
		
		return _acNodeIds_
	
	def _BuildOpParamsFromBinding(_aBinding_)
		_aOpParams_ = []
		
		_acKeys_ = keys(_aBinding_)
		_nLen_ = len(_acKeys_)
		
		for i = 1 to _nLen_
			_cKey_ = _acKeys_[i]
			pValue = _aBinding_[_cKey_]
			
			if isList(pValue) and HasKey(pValue, :id)
				_aOpParams_[_cKey_] = pValue[:id]
			else
				_aOpParams_[_cKey_] = pValue
			ok
		next
		
		return _aOpParams_
	
	def _CreateSubgraphView(_acNodeIds_)
		return new stzGraphView(@oGraph, _acNodeIds_)

	#--------------------#
	#  GRAPH PROJECTION  #
	#--------------------#
	
	def ToGraphQ()
		if NOT @bExecuted
			This._Execute()
		ok
	
		_oResultGraph_ = new stzGraph("query_result_" + UUID())
		_aSeenNodes_ = []
		
		_nLen_ = len(@aBindings)
		for i = 1 to _nLen_
			_aBinding_ = @aBindings[i]
			_acKeys_ = keys(_aBinding_)
			
			_nKeyLen_ = len(_acKeys_)
			for j = 1 to _nKeyLen_
				pValue = _aBinding_[_acKeys_[j]]
				
				if _acKeys_[j] = "edge_data"
					loop
				ok
				
				if isList(pValue) and HasKey(pValue, :id)
					_cNodeId_ = pValue[:id]
					
					if StzFindFirst(_cNodeId_, _aSeenNodes_) = 0
						_aSeenNodes_ + _cNodeId_
						
						_cLabel_ = ""
						if HasKey(pValue, :label)
							_cLabel_ = pValue[:label]
						ok
						
						_aProps_ = []
						if HasKey(pValue, :properties)
							_aProps_ = pValue[:properties]
						ok
						
						_oResultGraph_.AddNodeXTT(_cNodeId_, _cLabel_, _aProps_)
					ok
				ok
			next
		next
		
		_aEdges_ = @oGraph.Edges()
		_nEdgeLen_ = len(_aEdges_)
		
		for i = 1 to _nEdgeLen_
			_aEdge_ = _aEdges_[i]
			_cFrom_ = _aEdge_[:from]
			_cTo_ = _aEdge_[:to]
			
			if StzFindFirst(_cFrom_, _aSeenNodes_) > 0 and StzFindFirst(_cTo_, _aSeenNodes_) > 0
				_cLabel_ = ""
				if HasKey(_aEdge_, :label)
					_cLabel_ = _aEdge_[:label]
				ok
				
				_aProps_ = []
				if HasKey(_aEdge_, :properties)
					_aProps_ = _aEdge_[:properties]
				ok
				
				_oResultGraph_.AddEdgeXTT(_cFrom_, _cTo_, _cLabel_, _aProps_)
			ok
		next
		
		return _oResultGraph_
	
		def ToStzGraph()
			return This.ToGraphQ()

	def ToViewQ()
		if NOT @bExecuted
			This._Execute()
		ok
	
		_acNodeIds_ = This._ExtractNodeIdsFromBindings(@aBindings)
		return new stzGraphView(@oGraph, _acNodeIds_)
	
		def ToStzGraphView()
			return This.ToViewQ()
	
		def ToView()
			return This.ToViewQ()

	#-----------------------#
	#  PATTERN MATCHING     #
	#-----------------------#
	
	def _ExecuteMatch()
		_aAllBindings_ = []
		
		_nLen_ = len(@aDefinition["match_patterns"])
		for i = 1 to _nLen_
			_aPattern_ = @aDefinition["match_patterns"][i]
			_cPatternType_ = _aPattern_["type"]
			
			if _cPatternType_ = :node
				_aNodeBindings_ = This._MatchNode(_aPattern_)
				if i = 1
					_aAllBindings_ = _aNodeBindings_
				else
					_aAllBindings_ = This._MergeBindings(_aAllBindings_, _aNodeBindings_)
				ok
				
			but _cPatternType_ = :edge
				_aEdgeBindings_ = This._MatchEdge(_aPattern_)
				if i = 1
					_aAllBindings_ = _aEdgeBindings_
				else
					_aAllBindings_ = This._MergeBindings(_aAllBindings_, _aEdgeBindings_)
				ok
			ok
		next
		
		return _aAllBindings_
	
	def _MatchNode(_aPattern_)
		_cVarName_ = _aPattern_["alias"]
		_cLabel_ = _aPattern_["label"]
		_aProps_ = _aPattern_["props"]
		pWhere = NULL
		
		if HasKey(_aPattern_, "where")
			pWhere = _aPattern_["where"]
		ok
		
		_aBindings_ = []
		_aNodes_ = @oGraph.Nodes()
		_nLen_ = len(_aNodes_)
		
		for i = 1 to _nLen_
			_aNode_ = _aNodes_[i]
			_bMatch_ = TRUE
			
			# Check label
			if _cLabel_ != "" and HasKey(_aNode_, :label)
				if _aNode_[:label] != _cLabel_
					_bMatch_ = FALSE
				ok
			ok
			
			# Check properties
			if isList(_aProps_) and len(_aProps_) > 0
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					pValue = _aProps_[_cKey_]
					
					if _cKey_ = "id"
						if _aNode_[:id] != pValue
							_bMatch_ = FALSE
							exit
						ok
					else
						if NOT This._NodeHasProperty(_aNode_, _cKey_, pValue)
							_bMatch_ = FALSE
							exit
						ok
					ok
				next
			ok
			
			# Apply pattern-specific WHERE condition
			if _bMatch_ and pWhere != NULL
				_aBinding_ = [ [_cVarName_, _aNode_] ]
				if NOT This._EvaluateCondition(pWhere, _aBinding_)
					_bMatch_ = FALSE
				ok
			ok
			
			if _bMatch_
				_aBinding_ = [ [_cVarName_, _aNode_] ]
				_aBindings_ + _aBinding_
			ok
		next
		
		return _aBindings_
	
	def _MatchEdge(_aPattern_)
		_cFromVar_ = _aPattern_["from"]
		_cToVar_ = _aPattern_["to"]
		_cLabel_ = _aPattern_["label"]
		_aProps_ = _aPattern_["props"]
		pWhere = NULL
		
		if HasKey(_aPattern_, "where")
			pWhere = _aPattern_["where"]
		ok
		
		_aBindings_ = []
		_aEdges_ = @oGraph.Edges()
		_nLen_ = len(_aEdges_)
		
		for i = 1 to _nLen_
			_aEdge_ = _aEdges_[i]
			_bMatch_ = TRUE
			
			# Check label
			if _cLabel_ != "" and HasKey(_aEdge_, :label)
				if _aEdge_[:label] != _cLabel_
					_bMatch_ = FALSE
				ok
			ok
			
			# Check properties
			if isList(_aProps_) and len(_aProps_) > 0
				_acKeys_ = keys(_aProps_)
				_nKeyLen_ = len(_acKeys_)
				
				for j = 1 to _nKeyLen_
					_cKey_ = _acKeys_[j]
					if NOT This._EdgeHasProperty(_aEdge_, _cKey_, _aProps_[_cKey_])
						_bMatch_ = FALSE
						exit
					ok
				next
			ok
			
			# Apply pattern-specific WHERE condition
			if _bMatch_ and pWhere != NULL
				_aBinding_ = [
					[_cFromVar_, @oGraph.Node(_aEdge_[:from])],
					[_cToVar_, @oGraph.Node(_aEdge_[:to])],
					["edge_data", _aEdge_]
				]
				if NOT This._EvaluateCondition(pWhere, _aBinding_)
					_bMatch_ = FALSE
				ok
			ok
			
			if _bMatch_
				_aBinding_ = [
					[_cFromVar_, @oGraph.Node(_aEdge_[:from])],
					[_cToVar_, @oGraph.Node(_aEdge_[:to])],
					["edge_data", _aEdge_]
				]
				_aBindings_ + _aBinding_
			ok
		next
		
		return _aBindings_
	
	def _MergeBindings(aExisting, aNew)
		if len(aExisting) = 0
			return aNew
		ok
		
		if len(aNew) = 0
			return aExisting
		ok
		
		_aMerged_ = []
		_nExistLen_ = len(aExisting)
		_nNewLen_ = len(aNew)
		
		for i = 1 to _nExistLen_
			_aExistBinding_ = aExisting[i]
			
			for j = 1 to _nNewLen_
				_aNewBinding_ = aNew[j]
				
				# Check if bindings are compatible
				if This._BindingsCompatible(_aExistBinding_, _aNewBinding_)
					_aCombined_ = []
					
					# Add existing bindings
					_acExistKeys_ = keys(_aExistBinding_)
					_nKeyLen_ = len(_acExistKeys_)
					for k = 1 to _nKeyLen_
						_aCombined_ + [_acExistKeys_[k], _aExistBinding_[_acExistKeys_[k]]]
					next
					
					# Add new bindings (avoid duplicates)
					_acNewKeys_ = keys(_aNewBinding_)
					_nKeyLen_ = len(_acNewKeys_)
					for k = 1 to _nKeyLen_
						if NOT HasKey(_aCombined_, _acNewKeys_[k])
							_aCombined_ + [_acNewKeys_[k], _aNewBinding_[_acNewKeys_[k]]]
						ok
					next
					
					_aMerged_ + _aCombined_
				ok
			next
		next
		
		return _aMerged_
	
	def _BindingsCompatible(aBinding1, aBinding2)
		_acKeys1_ = keys(aBinding1)
		_acKeys2_ = keys(aBinding2)
		
		_nLen1_ = len(_acKeys1_)
		for i = 1 to _nLen1_
			_cKey_ = _acKeys1_[i]
			if HasKey(aBinding2, _cKey_)
				_aVal1_ = aBinding1[_cKey_]
				_aVal2_ = aBinding2[_cKey_]
				
				if HasKey(_aVal1_, :id) and HasKey(_aVal2_, :id)
					if _aVal1_[:id] != _aVal2_[:id]
						return FALSE
					ok
				ok
			ok
		next
		
		return TRUE
	
	#------------------#
	#  WHERE FILTERS   #
	#------------------#
	
	def _EvaluateCondition(pCondition, _aBinding_)
		if @IsFunction(pCondition)
			return call pCondition(_aBinding_)
		ok
		
		if NOT isList(pCondition)
			return TRUE
		ok
		
		_cOp_ = pCondition["op"]
		
		if _cOp_ = :equals
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = pCondition["right"]
			
			if isString(pRight) and StzFindFirst(".", pRight) > 0
				pRight = This._ResolveValue(pRight, _aBinding_)
			ok
			
			return pLeft = pRight
			
		but _cOp_ = :gt
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isNumber(pLeft) and isNumber(pRight) and pLeft > pRight
			
		but _cOp_ = :lt
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isNumber(pLeft) and isNumber(pRight) and pLeft < pRight
			
		but _cOp_ = :gte
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isNumber(pLeft) and isNumber(pRight) and pLeft >= pRight
			
		but _cOp_ = :lte
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isNumber(pLeft) and isNumber(pRight) and pLeft <= pRight
			
		but _cOp_ = :not_equals
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return pLeft != pRight
			
		but _cOp_ = :contains
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isString(pLeft) and isString(pRight) and StzFindFirst(StzLower(pRight), StzLower(pLeft)) > 0
			
		but _cOp_ = :startswith
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isString(pLeft) and isString(pRight) and StzLeft(StzLower(pLeft), StzLen(pRight)) = StzLower(pRight)

		but _cOp_ = :endswith
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			pRight = This._ResolveValue(pCondition["right"], _aBinding_)
			return isString(pLeft) and isString(pRight) and StzRight(StzLower(pLeft), StzLen(pRight)) = StzLower(pRight)
			
		but _cOp_ = :and
			return This._EvaluateCondition(pCondition["left"], _aBinding_) and
				   This._EvaluateCondition(pCondition["right"], _aBinding_)
				   
		but _cOp_ = :or
			return This._EvaluateCondition(pCondition["left"], _aBinding_) or
				   This._EvaluateCondition(pCondition["right"], _aBinding_)
				   
		but _cOp_ = :not
			return NOT This._EvaluateCondition(pCondition["left"], _aBinding_)
			
		but _cOp_ = :in
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			_aRight_ = pCondition["right"]
			return isList(_aRight_) and StzFindFirst(pLeft, _aRight_) > 0
			
		but _cOp_ = :not_in
			pLeft = This._ResolveValue(pCondition["left"], _aBinding_)
			_aRight_ = pCondition["right"]
			return isList(_aRight_) and StzFindFirst(pLeft, _aRight_) = 0
		ok
		
		return TRUE
	
	def _ResolveValue(pValue, _aBinding_)
		if isString(pValue)
			if StzFindFirst(".", pValue) > 0
				_acParts_ = @split(pValue, ".")
				_cVar_ = _acParts_[1]
				_cProp_ = _acParts_[2]
				
				# Handle edge_data specially
				if _cVar_ = "edge_data" and HasKey(_aBinding_, "edge_data")
					_aEdge_ = _aBinding_["edge_data"]
					if HasKey(_aEdge_, :properties)
						_aProps_ = _aEdge_[:properties]
						if isList(_aProps_) and len(_aProps_) > 0
							if HasKey(_aProps_, _cProp_)
								return _aProps_[_cProp_]
							ok
						ok
					ok
					return NULL
				ok
				
				if HasKey(_aBinding_, _cVar_)
					_aNode_ = _aBinding_[_cVar_]
					
					if _cProp_ = "id" and HasKey(_aNode_, :id)
						return _aNode_[:id]
					ok
				
				if HasKey(_aNode_, :properties)
					_aProps_ = _aNode_[:properties]
					if isList(_aProps_) and len(_aProps_) > 0
						if HasKey(_aProps_, _cProp_)
							return _aProps_[_cProp_]
						ok
					ok
				ok
			ok
			
			# Check edge_data for edge properties (fallback)
			if _cVar_ = "node" and HasKey(_aBinding_, "edge_data")
				_aEdge_ = _aBinding_["edge_data"]
				if HasKey(_aEdge_, :properties)
					_aProps_ = _aEdge_[:properties]
					if isList(_aProps_) and len(_aProps_) > 0
						if HasKey(_aProps_, _cProp_)
							return _aProps_[_cProp_]
						ok
					ok
				ok
			ok
			
			return NULL
		ok
		
		if HasKey(_aBinding_, pValue)
			return _aBinding_[pValue]
		ok
	ok
	
	return pValue

#---------------------#
#  SELECT PROJECTION  #
#---------------------#

def _ExecuteSelect(_aBindings_)
	_aResults_ = []
	_nLen_ = len(_aBindings_)
	
	for i = 1 to _nLen_
		_aBinding_ = _aBindings_[i]
		_aResult_ = []
		
		_nFieldLen_ = len(@aDefinition["select_fields"])
		
		for j = 1 to _nFieldLen_
			pField = @aDefinition["select_fields"][j]
			
			if isString(pField)
				pValue = This._ResolveValue(pField, _aBinding_)
				_aResult_ + [pField, pValue]
			
			but isList(pField) and HasKey(pField, "alias")
				_cField_ = pField["field"]
				_cAlias_ = pField["alias"]
				pValue = This._ResolveValue(_cField_, _aBinding_)
				_aResult_ + [_cAlias_, pValue]
			ok
		next

		_aResults_ + _aResult_
	next
	
	if @aDefinition["distinct"]
		_aResults_ = This._ApplyDistinct(_aResults_)
	ok
	
	return _aResults_

def _ApplyDistinct(_aResults_)
	_aUnique_ = []
	_nLen_ = len(_aResults_)
	
	for i = 1 to _nLen_
		_aResult_ = _aResults_[i]
		_bFound_ = FALSE
		
		_nUniqueLen_ = len(_aUnique_)
		for j = 1 to _nUniqueLen_
			if This._ResultsEqual(_aResult_, _aUnique_[j])
				_bFound_ = TRUE
				exit
			ok
		next
		
		if NOT _bFound_
			_aUnique_ + _aResult_
		ok
	next
	
	return _aUnique_

def _ResultsEqual(aResult1, aResult2)
	_acKeys1_ = keys(aResult1)
	_acKeys2_ = keys(aResult2)
	
	if len(_acKeys1_) != len(_acKeys2_)
		return FALSE
	ok
	
	_nLen_ = len(_acKeys1_)
	for i = 1 to _nLen_
		_cKey_ = _acKeys1_[i]
		if NOT HasKey(aResult2, _cKey_)
			return FALSE
		ok
		
		pVal1 = aResult1[_cKey_]
		pVal2 = aResult2[_cKey_]
		
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

def _ExecuteCreate(_aBindings_)
	_nLen_ = len(@aDefinition["create_patterns"])
	for i = 1 to _nLen_
		_aPattern_ = @aDefinition["create_patterns"][i]
		_cPatternType_ = _aPattern_["type"]
		
		if _cPatternType_ = :node
			This._CreateNode(_aPattern_)
		but _cPatternType_ = :edge
			This._CreateEdge(_aPattern_, _aBindings_)
		ok
	next

def _CreateNode(_aPattern_)
	_cLabel_ = _aPattern_["label"]
	_aProps_ = _aPattern_["props"]
	
	_cNodeId_ = "node_" + UUID()
	
	if isList(_aProps_) and len(_aProps_) > 0
		@oGraph.AddNodeXTT(_cNodeId_, _cLabel_, _aProps_)
	else
		@oGraph.AddNodeXT(_cNodeId_, _cLabel_)
	ok

def _CreateEdge(_aPattern_, _aBindings_)
	_cFromVar_ = _aPattern_["from"]
	_cToVar_ = _aPattern_["to"]
	_cLabel_ = _aPattern_["label"]
	_aProps_ = _aPattern_["props"]
	
	_nLen_ = len(_aBindings_)
	for i = 1 to _nLen_
		_aBinding_ = _aBindings_[i]
		
		if HasKey(_aBinding_, _cFromVar_) and HasKey(_aBinding_, _cToVar_)
			_aFromNode_ = _aBinding_[_cFromVar_]
			_aToNode_ = _aBinding_[_cToVar_]
			
			_cFromId_ = _aFromNode_[:id]
			_cToId_ = _aToNode_[:id]
			
			if isList(_aProps_) and len(_aProps_) > 0
				@oGraph.AddEdgeXTT(_cFromId_, _cToId_, _cLabel_, _aProps_)
			else
				@oGraph.AddEdgeXT(_cFromId_, _cToId_, _cLabel_)
			ok
		ok
	next

def _ExecuteSet(_aBindings_)
	_nLen_ = len(@aDefinition["set_operations"])
	
	for i = 1 to _nLen_
		_aOp_ = @aDefinition["set_operations"][i]
		_cOpType_ = _aOp_["op"]
		
		if _cOpType_ = :set
			This._ExecuteSetProperty(_aOp_, _aBindings_)
		ok
	next

def _ExecuteSetProperty(_aOp_, _aBindings_)
	_cTarget_ = _aOp_["property"]
	pValue = _aOp_["value"]
	
	_nLen_ = len(_aBindings_)
	for i = 1 to _nLen_
		_aBinding_ = _aBindings_[i]
		
		if StzFindFirst(".", _cTarget_) > 0
			_acParts_ = @split(_cTarget_, ".")
			_cVar_ = _acParts_[1]
			_cProp_ = _acParts_[2]
			
			if HasKey(_aBinding_, _cVar_)
				_aNode_ = _aBinding_[_cVar_]
				@oGraph.SetNodeProperty(_aNode_[:id], _cProp_, pValue)
			ok
		ok
	next

def _ExecuteDelete(_aBindings_)
	_acToDelete_ = []
	
	_nLen_ = len(_aBindings_)
	for i = 1 to _nLen_
		_aBinding_ = _aBindings_[i]
		
		_nTargetLen_ = len(@aDefinition["delete_targets"])
		for j = 1 to _nTargetLen_
			_cTarget_ = @aDefinition["delete_targets"][j]
			
			if HasKey(_aBinding_, _cTarget_)
				_aNode_ = _aBinding_[_cTarget_]
				_cId_ = _aNode_[:id]
				if StzFindFirst(_cId_, _acToDelete_) = 0
					_acToDelete_ + _cId_
				ok
			ok
		next
	next
	
	_nLen_ = len(_acToDelete_)
	for i = 1 to _nLen_
		@oGraph.RemoveThisNode(_acToDelete_[i])
	next

#------------------#
#  ORDERING/LIMIT  #
#------------------#

def _ApplyOrderBy(_aResults_)
	if len(@aDefinition["order_by"]) = 0
		return _aResults_
	ok
	
	_aOrderDef_ = @aDefinition["order_by"][1]
	_cField_ = _aOrderDef_["field"]
	_cDirection_ = _aOrderDef_["direction"]
	
	# Extract values for sorting
	_aValues_ = []
	_nLen_ = len(_aResults_)
	for i = 1 to _nLen_
		pVal = This._GetResultValue(_aResults_[i], _cField_)
		_aValues_ + [i, pVal]
	next
	
	# Sort using Softanza
	@SortOn(_aValues_, 2)
	
	# Apply descending if needed
	if _cDirection_ = "desc"
		@Reverse(_aValues_)
	ok
	
	# Rebuild results in sorted order
	_aSorted_ = []
	_nLen_ = len(_aValues_)
	for i = 1 to _nLen_
		_nOrigIndex_ = _aValues_[i][1]
		_aSorted_ + _aResults_[_nOrigIndex_]
	next
	
	return _aSorted_

def _GetResultValue(_aResult_, _cField_)
	if StzFindFirst(".", _cField_) > 0
		_acParts_ = @split(_cField_, ".")
		_cVar_ = _acParts_[1]
		_cProp_ = _acParts_[2]
		
		if HasKey(_aResult_, _cVar_)
			_aNode_ = _aResult_[_cVar_]
			if isList(_aNode_) and HasKey(_aNode_, :properties)
				_aProps_ = _aNode_[:properties]
				if HasKey(_aProps_, _cProp_)
					return _aProps_[_cProp_]
				ok
			ok
		ok
		return NULL
	ok
	
	if HasKey(_aResult_, _cField_)
		return _aResult_[_cField_]
	ok
	
	return NULL

def _ApplySkip(_aResults_)
	if @aDefinition["skip"] = 0 or @aDefinition["skip"] >= len(_aResults_)
		return []
	ok
	
	_aSkipped_ = []
	_nLen_ = len(_aResults_)
	for i = @aDefinition["skip"] + 1 to _nLen_
		_aSkipped_ + _aResults_[i]
	next
	
	return _aSkipped_

def _ApplyLimit(_aResults_)
	if @aDefinition["limit"] = 0 or @aDefinition["limit"] >= len(_aResults_)
		return _aResults_
	ok
	
	_aLimited_ = []
	for i = 1 to @aDefinition["limit"]
		_aLimited_ + _aResults_[i]
	next
	
	return _aLimited_

#------------------#
#  HELPER METHODS  #
#------------------#

def _NodeHasProperty(_aNode_, _cKey_, pValue)
	if NOT HasKey(_aNode_, :properties)
		return FALSE
	ok
	
	_aProps_ = _aNode_[:properties]
	if NOT HasKey(_aProps_, _cKey_)
		return FALSE
	ok
	
	return _aProps_[_cKey_] = pValue

def _EdgeHasProperty(_aEdge_, _cKey_, pValue)
	if NOT HasKey(_aEdge_, :properties)
		return FALSE
	ok
	
	_aProps_ = _aEdge_[:properties]
	if NOT HasKey(_aProps_, _cKey_)
		return FALSE
	ok
	
	return _aProps_[_cKey_] = pValue

#-------------------------------------------#
#  EXPLANATION OF THE QUERY EXECUTION PLAN  #
#-------------------------------------------#

def Explain()
	_aExplanation_ = []
	
	# Match patterns
	if len(@aDefinition["match_patterns"]) > 0
		_acMatch_ = []
		_nLen_ = len(@aDefinition["match_patterns"])
		for i = 1 to _nLen_
			_aPattern_ = @aDefinition["match_patterns"][i]
			_cType_ = _aPattern_["type"]
			
			if _cType_ = :node
				_cVar_ = _aPattern_["alias"]
				_cLabel_ = _aPattern_["label"]
				
				_cDesc_ = "Scan all nodes, bind to variable '" + _cVar_ + "'"
				
				if _cLabel_ != ""
					_cDesc_ += " with label '" + _cLabel_ + "'"
				ok
				
				_aProps_ = _aPattern_["props"]
				if isList(_aProps_) and len(_aProps_) > 0
					_cDesc_ += " with properties " + This._FormatProps(_aProps_)
				ok
				
				# Add WHERE condition if present in pattern
				if HasKey(_aPattern_, "where")
					_cDesc_ += " where " + This._ExplainCondition(_aPattern_["where"], "")
				ok
				
				_acMatch_ + _cDesc_
				
			but _cType_ = :edge
				_cFrom_ = _aPattern_["from"]
				_cTo_ = _aPattern_["to"]
				_cLabel_ = _aPattern_["label"]
				
				_cDesc_ = "Match edges: (" + _cFrom_ + ")-[]->("  + _cTo_ + ")"
				
				if _cLabel_ != ""
					_cDesc_ += " of type '" + _cLabel_ + "'"
				ok
				
				# Add WHERE condition if present in pattern
				if HasKey(_aPattern_, "where")
					_cDesc_ += " where " + This._ExplainCondition(_aPattern_["where"], "")
				ok
				
				_acMatch_ + _cDesc_
			ok
		next
		_aExplanation_ + [ ["step", "match"], ["description", _acMatch_] ]
	ok
	
	# Global Where conditions (only if any exist)
	if len(@aDefinition["where_conditions"]) > 0
		_acWhere_ = []
		_nLen_ = len(@aDefinition["where_conditions"])
		for i = 1 to _nLen_
			_cCondDesc_ = This._ExplainCondition(@aDefinition["where_conditions"][i], "")
			_acWhere_ + ("Filter bindings using: " + _cCondDesc_)
		next
		_aExplanation_ + [ ["step", "where"], ["description", _acWhere_] ]
	ok
	
	# Create patterns
	if len(@aDefinition["create_patterns"]) > 0
		_acCreate_ = []
		_nLen_ = len(@aDefinition["create_patterns"])
		for i = 1 to _nLen_
			_aPattern_ = @aDefinition["create_patterns"][i]
			_cType_ = _aPattern_["type"]
			
			if _cType_ = :node
				_acCreate_ + "Create new node"
			but _cType_ = :edge
				_acCreate_ + "Create new edge"
			ok
		next
		_aExplanation_ + [ ["step", "create"], ["description", _acCreate_] ]
	ok
	
	# Set operations
	if len(@aDefinition["set_operations"]) > 0
		_acSet_ = []
		_nLen_ = len(@aDefinition["set_operations"])
		for i = 1 to _nLen_
			_aOp_ = @aDefinition["set_operations"][i]
			_cProp_ = _aOp_["property"]
			pVal = _aOp_["value"]
			_acSet_ + ("Set property: " + _cProp_ + " = " + This._FormatValue(pVal))
		next
		_aExplanation_ + [ ["step", "set"], ["description", _acSet_] ]
	ok
	
	# Delete targets
	if len(@aDefinition["delete_targets"]) > 0
		_acDelete_ = []
		_nLen_ = len(@aDefinition["delete_targets"])
		for i = 1 to _nLen_
			_acDelete_ + ("Delete node: " + @aDefinition["delete_targets"][i])
		next
		_aExplanation_ + [ ["step", "delete"], ["description", _acDelete_] ]
	ok
	
	# Select fields
	if len(@aDefinition["select_fields"]) > 0
		_acSelect_ = []
		
		if @aDefinition["distinct"]
			_acSelect_ + "Apply DISTINCT filter"
		ok
		
		_cFields_ = "Project fields: "
		_nLen_ = len(@aDefinition["select_fields"])
		for i = 1 to _nLen_
			pField = @aDefinition["select_fields"][i]
			
			if isString(pField)
				_cFields_ += pField
			but isList(pField) and HasKey(pField, "alias")
				_cFields_ += pField["field"] + " AS " + pField["alias"]
			ok
			
			if i < _nLen_
				_cFields_ += ", "
			ok
		next
		_acSelect_ + _cFields_
		
		_aExplanation_ + [ ["step", "select"], ["description", _acSelect_] ]
	ok
	
	# Order by
	if len(@aDefinition["order_by"]) > 0
		_aOrder_ = @aDefinition["order_by"][1]
		_cField_ = _aOrder_["field"]
		_cDir_ = StzUpper(_aOrder_["direction"])
		_aExplanation_ + [ ["step", "orderby"], ["description", ["Sort by: " + _cField_ + " " + _cDir_]] ]
	ok
	
	# Skip
	if @aDefinition["skip"] > 0
		_aExplanation_ + [ ["step", "skip"], ["description", ["Skip first " + @aDefinition["skip"] + " results"]] ]
	ok
	
	# Limit
	if @aDefinition["limit"] > 0
		_aExplanation_ + [ ["step", "limit"], ["description", ["Return maximum " + @aDefinition["limit"] + " results"]] ]
	ok
	
	return _aExplanation_

def _ExplainCondition(pCondition, pcVarName)
	if @IsFunction(pCondition)
		return "Custom function filter"
	ok
	
	if NOT isList(pCondition)
		return "Always true"
	ok
	
	_cOp_ = pCondition["op"]
	_cLeft_ = pCondition["left"]
	pRight = pCondition["right"]
	
	if _cOp_ = :equals
		return _cLeft_ + " = " + This._FormatValue(pRight)
		
	but _cOp_ = :gt
		return _cLeft_ + " > " + This._FormatValue(pRight)
		
	but _cOp_ = :lt
		return _cLeft_ + " < " + This._FormatValue(pRight)
		
	but _cOp_ = :gte
		return _cLeft_ + " >= " + This._FormatValue(pRight)
		
	but _cOp_ = :lte
		return _cLeft_ + " <= " + This._FormatValue(pRight)
		
	but _cOp_ = :not_equals
		return _cLeft_ + " != " + This._FormatValue(pRight)
		
	but _cOp_ = :contains
		return _cLeft_ + " CONTAINS " + This._FormatValue(pRight)
		
	but _cOp_ = :startswith
		return _cLeft_ + " STARTS WITH " + This._FormatValue(pRight)
		
	but _cOp_ = :endswith
		return _cLeft_ + " ENDS WITH " + This._FormatValue(pRight)
		
	but _cOp_ = :and
		return "(" + This._ExplainCondition(_cLeft_, "") + " AND " +
			   This._ExplainCondition(pRight, "") + ")"
			   
	but _cOp_ = :or
		return "(" + This._ExplainCondition(_cLeft_, "") + " OR " +
			   This._ExplainCondition(pRight, "") + ")"
			   
	but _cOp_ = :not
		return "NOT (" + This._ExplainCondition(_cLeft_, "") + ")"
		
	but _cOp_ = :in
		return _cLeft_ + " IN " + This._FormatValue(pRight)
		
	but _cOp_ = :not_in
		return _cLeft_ + " NOT IN " + This._FormatValue(pRight)
	ok
	
	return "Unknown condition"

def _FormatProps(_aProps_)
	if NOT isList(_aProps_) or len(_aProps_) = 0
		return "{}"
	ok
	
	_cResult_ = "{"
	_acKeys_ = keys(_aProps_)
	_nLen_ = len(_acKeys_)
	
	for i = 1 to _nLen_
		_cKey_ = _acKeys_[i]
		_cResult_ += _cKey_ + ": " + This._FormatValue(_aProps_[_cKey_])
		
		if i < _nLen_
			_cResult_ += ", "
		ok
	next
	
	_cResult_ += "}"
	return _cResult_

def _FormatValue(pValue)
	if isString(pValue)
		return '"' + pValue + '"'
	but isNumber(pValue)
		return "" + pValue
	but isList(pValue)
		_cResult_ = "["
		_nLen_ = len(pValue)
		for i = 1 to _nLen_
			_cResult_ += This._FormatValue(pValue[i])
			if i < _nLen_
				_cResult_ += ", "
			ok
		next
		_cResult_ += "]"
		return _cResult_
	ok
	return "null"

#----------------------------#
#  OPENCYPHER IMPORT/EXPORT  #
#----------------------------#

def ToOpenCypher()
	_cCypher_ = ""
	
	# MATCH clause
	if len(@aDefinition["match_patterns"]) > 0
		_cCypher_ += "MATCH "
		_nLen_ = len(@aDefinition["match_patterns"])
		
		for i = 1 to _nLen_
			_aPattern_ = @aDefinition["match_patterns"][i]
			_cCypher_ += This._PatternToCypher(_aPattern_)
			
			if i < _nLen_
				_cCypher_ += ", "
			ok
		next
		_cCypher_ += NL
	ok
	
	# WHERE clause - check both pattern-level and global conditions
	_acWhereConditions_ = []
	
	# Collect WHERE from patterns
	if len(@aDefinition["match_patterns"]) > 0
		_nLen_ = len(@aDefinition["match_patterns"])
		for i = 1 to _nLen_
			_aPattern_ = @aDefinition["match_patterns"][i]
			if HasKey(_aPattern_, "where")
				_acWhereConditions_ + This._ConditionToCypher(_aPattern_["where"])
			ok
		next
	ok
	
	# Add global WHERE conditions
	_nLen_ = len(@aDefinition["where_conditions"])
	for i = 1 to _nLen_
		_acWhereConditions_ + This._ConditionToCypher(@aDefinition["where_conditions"][i])
	next
	
	# Output WHERE clause if any conditions exist
	if len(_acWhereConditions_) > 0
		_cCypher_ += "WHERE "
		_nLen_ = len(_acWhereConditions_)
		for i = 1 to _nLen_
			_cCypher_ += _acWhereConditions_[i]
			if i < _nLen_
				_cCypher_ += " AND "
			ok
		next
		_cCypher_ += NL
	ok
	
	# CREATE clause
	if len(@aDefinition["create_patterns"]) > 0
		_cCypher_ += "CREATE "
		_nLen_ = len(@aDefinition["create_patterns"])
		
		for i = 1 to _nLen_
			_aPattern_ = @aDefinition["create_patterns"][i]
			_cCypher_ += This._PatternToCypher(_aPattern_)
			
			if i < _nLen_
				_cCypher_ += ", "
			ok
		next
		_cCypher_ += NL
	ok
	
	# SET clause
	if len(@aDefinition["set_operations"]) > 0
		_cCypher_ += "SET "
		_nLen_ = len(@aDefinition["set_operations"])
		
		for i = 1 to _nLen_
			_aOp_ = @aDefinition["set_operations"][i]
			_cProp_ = _aOp_["property"]
			pVal = _aOp_["value"]
			_cCypher_ += _cProp_ + " = " + This._ValueToCypher(pVal)
			
			if i < _nLen_
				_cCypher_ += ", "
			ok
		next
		_cCypher_ += NL
	ok
	
	# DELETE clause
	if len(@aDefinition["delete_targets"]) > 0
		_cCypher_ += "DELETE "
		_cCypher_ += JoinXT(@aDefinition["delete_targets"], ", ")
		_cCypher_ += NL
	ok
	
	# RETURN clause
	if len(@aDefinition["select_fields"]) > 0
		_cCypher_ += "RETURN "
		if @aDefinition["distinct"]
			_cCypher_ += "DISTINCT "
		ok
		
		_nLen_ = len(@aDefinition["select_fields"])
		for i = 1 to _nLen_
			pField = @aDefinition["select_fields"][i]
			
			if isString(pField)
				_cCypher_ += pField
			but isList(pField) and HasKey(pField, "alias")
				_cCypher_ += pField["field"] + " AS " + pField["alias"]
			ok
			
			if i < _nLen_
				_cCypher_ += ", "
			ok
		next
		_cCypher_ += NL
	ok
	
	# ORDER BY clause
	if len(@aDefinition["order_by"]) > 0
		_cCypher_ += "ORDER BY "
		_aOrder_ = @aDefinition["order_by"][1]
		_cCypher_ += _aOrder_["field"] + " " + UPPER(_aOrder_["direction"])
		_cCypher_ += NL
	ok
	
	# SKIP clause
	if @aDefinition["skip"] > 0
		_cCypher_ += "SKIP " + @aDefinition["skip"] + NL
	ok
	
	# LIMIT clause
	if @aDefinition["limit"] > 0
		_cCypher_ += "LIMIT " + @aDefinition["limit"] + NL
	ok
	
	return _cCypher_

def _PatternToCypher(_aPattern_)
	_cType_ = _aPattern_["type"]
	
	if _cType_ = :node
		_cVar_ = _aPattern_["alias"]
		_cLabel_ = _aPattern_["label"]
		_aProps_ = _aPattern_["props"]
		
		_cResult_ = "(" + _cVar_
		
		if _cLabel_ != ""
			_cResult_ += ":" + _cLabel_
		ok
		
		if isList(_aProps_) and len(_aProps_) > 0
			_cResult_ += " " + This._PropsToCypher(_aProps_)
		ok
		
		_cResult_ += ")"
		return _cResult_
		
	but _cType_ = :edge
		_cFrom_ = _aPattern_["from"]
		_cTo_ = _aPattern_["to"]
		_cLabel_ = _aPattern_["label"]
		_aProps_ = _aPattern_["props"]
		
		_cResult_ = "(" + _cFrom_ + ")-["
		
		if _cLabel_ != ""
			_cResult_ += ":" + _cLabel_
		ok
		
		if isList(_aProps_) and len(_aProps_) > 0
			_cResult_ += " " + This._PropsToCypher(_aProps_)
		ok
		
		_cResult_ += "]->("
		_cResult_ += _cTo_ + ")"
		return _cResult_
	ok
	
	return ""

def _ConditionToCypher(pCondition)
	if NOT isList(pCondition)
		return ""
	ok
	
	_cOp_ = pCondition["op"]
	pLeft = pCondition["left"]
	pRight = pCondition["right"]
	
	if _cOp_ = :equals
		return pLeft + " = " + This._ValueToCypher(pRight)
		
	but _cOp_ = :gt
		return pLeft + " > " + This._ValueToCypher(pRight)
		
	but _cOp_ = :lt
		return pLeft + " < " + This._ValueToCypher(pRight)
		
	but _cOp_ = :gte
		return pLeft + " >= " + This._ValueToCypher(pRight)
		
	but _cOp_ = :lte
		return pLeft + " <= " + This._ValueToCypher(pRight)
		
	but _cOp_ = :not_equals
		return pLeft + " <> " + This._ValueToCypher(pRight)
		
	but _cOp_ = :contains
		return pLeft + " CONTAINS " + This._ValueToCypher(pRight)
		
	but _cOp_ = :startswith
		return pLeft + " STARTS WITH " + This._ValueToCypher(pRight)
		
	but _cOp_ = :endswith
		return pLeft + " ENDS WITH " + This._ValueToCypher(pRight)
		
	but _cOp_ = :and
		return "(" + This._ConditionToCypher(pLeft) + " AND " + 
			   This._ConditionToCypher(pRight) + ")"
			   
	but _cOp_ = :or
		return "(" + This._ConditionToCypher(pLeft) + " OR " + 
			   This._ConditionToCypher(pRight) + ")"
			   
	but _cOp_ = :not
		return "NOT " + This._ConditionToCypher(pLeft)
		
	but _cOp_ = :in
		return pLeft + " IN " + This._ValueToCypher(pRight)
	ok
	
	return ""

def _PropsToCypher(_aProps_)
	_cResult_ = "{"
	_acKeys_ = keys(_aProps_)
	_nLen_ = len(_acKeys_)
	
	for i = 1 to _nLen_
		_cKey_ = _acKeys_[i]
		_cResult_ += _cKey_ + ": " + This._ValueToCypher(_aProps_[_cKey_])
		
		if i < _nLen_
			_cResult_ += ", "
		ok
	next
	
	_cResult_ += "}"
	return _cResult_

def _ValueToCypher(pValue)
	if isString(pValue)
		return '"' + pValue + '"'
	but isNumber(pValue)
		return "" + pValue
	but isList(pValue)
		_cResult_ = "["
		_nLen_ = len(pValue)
		for i = 1 to _nLen_
			_cResult_ += This._ValueToCypher(pValue[i])
			if i < _nLen_
				_cResult_ += ", "
			ok
		next
		_cResult_ += "]"
		return _cResult_
	ok
	return "null"
