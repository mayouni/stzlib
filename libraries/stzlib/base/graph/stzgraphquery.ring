#========================================#
# stzGraphQuery - Keep Separate (Works)  #
#========================================#

class stzGraphQuery
	@oGraph
	@cTarget
	@aFilters = []
	
	def init(oGraph, cTarget)
		@oGraph = oGraph
		@cTarget = lower(cTarget)
		@aFilters = []
	
	def Where(pcKey, pCondition, pValue)
		@aFilters + [:where, pcKey, pCondition, pValue]
		return This
	
		def WhereQ(pcKey, pCondition, pValue)
			return This.Where(pcKey, pCondition, pValue)

	def Having(pcKey, pValue)
		@aFilters + [:where, pcKey, :equals, pValue]
		return This
	
		def HavingQ(pcKey, pValue)
			return This.Having(pcKey, pValue)

	def WithProperty(pcKey)
		@aFilters + [:hasprop, pcKey]
		return This

		def WithPropertyQ(pcKey)
			return This.WithProperty(pcKey)

	def WithTag(pcTag)
		@aFilters + [:tag, pcTag]
		return This
	
		def WithTagQ(pcTag)
			return This.WithTag(pcTag)

	def Run()
		if @cTarget = "nodes"
			return This._QueryNodes()
		but @cTarget = "edges"
			return This._QueryEdges()
		ok
		return []
	
		def Execute()
			return This.Run()
	
	def _QueryNodes()
		acResult = []
		aNodes = @oGraph.Nodes()
		
		for aNode in aNodes
			if This._NodeMatches(aNode)
				acResult + aNode[:id]
			ok
		end
		
		return acResult
	
	def _QueryEdges()
		acResult = []
		aEdges = @oGraph.Edges()
		
		for aEdge in aEdges
			if This._EdgeMatches(aEdge)
				acResult + [ aEdge[:from], aEdge[:to] ]
			ok
		end
		return acResult
	
	def _NodeMatches(aNode)
		for aFilter in @aFilters
			cType = aFilter[1]
			
			if cType = :where
				pcKey = aFilter[2]
				pCondition = aFilter[3]
				pValue = aFilter[4]
				
				pActual = This._GetNestedValue(aNode, pcKey)
				if pActual = ""
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but cType = :hasprop
				pcKey = aFilter[2]
				if This._GetNestedValue(aNode, pcKey) = ""
					return FALSE
				ok
				
			but cType = :tag
				pcTag = aFilter[2]
				if NOT HasKey(aNode, "properties") or 
				   NOT HasKey(aNode["properties"], "tags") or
				   ring_find(aNode["properties"]["tags"], pcTag) = 0
					return FALSE
				ok
			ok
		end
		return TRUE
	
	def _EdgeMatches(aEdge)
		for aFilter in @aFilters
			cType = aFilter[1]
			
			if cType = :where
				pcKey = aFilter[2]
				pCondition = aFilter[3]
				pValue = aFilter[4]
				
				pActual = This._GetNestedValue(aEdge, pcKey)
				if pActual = ""
					return FALSE
				ok
				
				if NOT This._Matches(pActual, pCondition, pValue)
					return FALSE
				ok
				
			but cType = :hasprop
				pcKey = aFilter[2]
				if This._GetNestedValue(aEdge, pcKey) = ""
					return FALSE
				ok
				
			but cType = :tag
				pcTag = aFilter[2]
				if NOT HasKey(aEdge, "properties") or 
				   NOT HasKey(aEdge["properties"], "tags") or
				   ring_find(aEdge["properties"]["tags"], pcTag) = 0
					return FALSE
				ok
			ok
		end
		return TRUE
	
	def _GetNestedValue(aElement, pcKey)
		bIsNested = (substr(pcKey, ".") > 0)
		
		if bIsNested
			acPath = split(pcKey, ".")
			pValue = aElement
			
			if HasKey(aElement, acPath[1])
				pValue = aElement[acPath[1]]
				for i = 2 to len(acPath)
					if isList(pValue) and HasKey(pValue, acPath[i])
						pValue = pValue[acPath[i]]
					else
						return "" # TODO Is it safer to raise an error?
					ok
				end
				return pValue
				
			but HasKey(aElement, "properties")
				pValue = aElement["properties"]
				for i = 1 to len(acPath)
					if isList(pValue) and HasKey(pValue, acPath[i])
						pValue = pValue[acPath[i]]
					else
						return "" # TODO Is it safer to raise an error?
					ok
				end
				return pValue
			ok
			return "" # TODO Is it safer to raise an error?
		ok
		
		if HasKey(aElement, pcKey)
			return aElement[pcKey]

		but HasKey(aElement, "properties") and HasKey(aElement["properties"], pcKey)
			return aElement["properties"][pcKey]
		ok
		return "" # TODO Is it safer to raise an error?
	
	def _Matches(pActual, pCondition, pValue)
		cCond = lower(pCondition)
		
		if cCond = "equals" or cCond = ":equals" or cCond = "="
			return pActual = pValue
			
		but cCond = "greaterthan" or cCond = ":greaterthan" or cCond = ">"
			return isNumber(pActual) and isNumber(pValue) and pActual > pValue
			
		but cCond = "lessthan" or cCond = ":lessthan" or cCond = "<"
			return isNumber(pActual) and isNumber(pValue) and pActual < pValue
			
		but cCond = "contains" or cCond = ":contains"
			return isString(pActual) and isString(pValue) and 
			       substr(lower(pActual), lower(pValue)) > 0
			       
		but cCond = "insection" or cCond = ":insection" or cCond = "between" or cCond = ":between"
			return isNumber(pActual) and isList(pValue) and len(pValue) = 2 and
			       pActual >= pValue[1] and pActual <= pValue[2]
		ok
		return FALSE
