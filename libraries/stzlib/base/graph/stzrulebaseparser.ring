#============================================#
#  stzRuleBaseParser - *.stzrulz Parser      #
#  Converts text rules to rule objects      #
#============================================#

class stzRuleBaseParser
	def ParseFile(pcFilename)
		cContent = read(pcFilename)
		return This.Parse(cContent)
	
	def Parse(pcContent)
		oRuleBase = new stzGraphRuleBase("Parsed Rules")
		
		acLines = split(pcContent, NL)
		cSection = ""
		cRuleId = ""
		oCurrentRule = NULL
		cWhenSection = "when"  # "when" or "else"
		
		for cLine in acLines
			cLine = trim(cLine)
			
			# Skip empty and comments
			if cLine = "" or left(cLine, 1) = "#"
				loop
			ok
			
			# Ruleset metadata
			if substr(cLine, "ruleset ")
				cName = This._ExtractQuoted(cLine)
				oRuleBase.SetName(cName)
				
			but substr(cLine, "domain:")
				oRuleBase.SetDomain(This._ExtractValue(cLine))
				
			but substr(cLine, "version:")
				oRuleBase.SetVersion(This._ExtractValue(cLine))
				
			but substr(cLine, "author:")
				oRuleBase.SetAuthor(This._ExtractValue(cLine))
			
			# Rules section
			but cLine = "rules"
				cSection = "rules"
			
			# New rule
			but substr(cLine, "rule ")
				# Save previous rule
				if oCurrentRule != NULL
					oRuleBase.AddRule(oCurrentRule)
				ok
				
				cRuleId = trim(@substr(cLine, 6, len(cLine)))
				oCurrentRule = new stzGraphRule(cRuleId)
				cWhenSection = "when"
			
			# Rule properties
			but substr(cLine, "type:")
				if oCurrentRule != NULL
					oCurrentRule.SetRuleType(This._ExtractValue(cLine))
				ok
				
			but substr(cLine, "level:")
				if oCurrentRule != NULL
					oCurrentRule.SetLevel(This._ExtractValue(cLine))
				ok
				
			but substr(cLine, "severity:")
				if oCurrentRule != NULL
					oCurrentRule.SetSeverity(This._ExtractValue(cLine))
				ok
			
			# Condition/effect markers
			but cLine = "when"
				cWhenSection = "when"
				
			but cLine = "then"
				cWhenSection = "then"
				
			but cLine = "else"
				cWhenSection = "else"
				
			but substr(cLine, "message")
				# Skip to next line for message
			
			# Parse conditions (when section)
			but cWhenSection = "when" and oCurrentRule != NULL
				This._ParseCondition(cLine, oCurrentRule)
			
			# Parse effects (then section)
			but cWhenSection = "then" and oCurrentRule != NULL
				This._ParseEffect(cLine, oCurrentRule, FALSE)
			
			# Parse else effects
			but cWhenSection = "else" and oCurrentRule != NULL
				This._ParseEffect(cLine, oCurrentRule, TRUE)
			ok
		end
		
		# Add last rule
		if oCurrentRule != NULL
			oRuleBase.AddRule(oCurrentRule)
		ok
		
		return oRuleBase
	
	#-----------#
	#  HELPERS  #
	#-----------#
	
	def _ParseCondition(cLine, oRule)
		aTokens = This._Tokenize(cLine)
		
		if len(aTokens) < 2
			return
		ok
		
		# path exists from="A" to="B"
		if aTokens[1] = "path" and len(aTokens) >= 3
			cCondition = aTokens[2]
			cFrom = This._ExtractQuotedValue(cLine, 'from="')
			cTo = This._ExtractQuotedValue(cLine, 'to="')
			oRule.WhenPath(cFrom, cTo, cCondition)
			return
		ok
		
		# tag exists "critical"
		if aTokens[1] = "tag" and len(aTokens) >= 3
			cCondition = aTokens[2]
			cTag = aTokens[3]
			cTag = This._Unquote(cTag)
			oRule.WhenTag(cTag, cCondition)
			return
		ok
		
		# graph mustBe "acyclic"
		if aTokens[1] = "graph" and len(aTokens) >= 3
			cProp = aTokens[2]
			cCondition = aTokens[3]
			oRule.WhenGraph(cProp, cCondition)
			return
		ok
		
		# Standard property conditions
		# department equals "audit"
		if len(aTokens) >= 3
			cKey = aTokens[1]
			cOp = aTokens[2]
			
			if len(aTokens) = 3
				pValue = This._Unquote(aTokens[3])
			but len(aTokens) = 4
				# inSection 0,100
				if cOp = "insection"
					pValue = [0 + aTokens[3], 0 + aTokens[4]]
				else
					pValue = This._Unquote(aTokens[3])
				ok
			else
				pValue = This._Unquote(aTokens[3])
			ok
			
			oRule.When(cKey, cOp, pValue)
		ok
	
	def _ParseEffect(cLine, oRule, bIsElse)
		aTokens = This._Tokenize(cLine)
		
		if len(aTokens) < 2
			return
		ok
		
		# violation add "message"
		if aTokens[1] = "violation" and len(aTokens) >= 3
			cAction = aTokens[2]
			cMessage = This._ExtractQuoted(cLine)
			
			if bIsElse
				oRule.ElseViolation(cMessage)
			else
				oRule.ThenViolation(cMessage)
			ok
			return
		ok
		
		# Standard effects: aspect action value
		# color set "red"
		if len(aTokens) >= 3
			cAspect = aTokens[1]
			cAction = aTokens[2]
			pValue = This._Unquote(aTokens[3])
			
			if bIsElse
				oRule.Else_(cAspect, cAction, pValue)
			else
				oRule.Then(cAspect, cAction, pValue)
			ok
		ok
	
	def _Tokenize(cLine)
		# Split by spaces but preserve quoted strings
		aTokens = []
		cCurrent = ""
		bInQuote = FALSE
		
		nLen = len(cLine)
		for i = 1 to nLen
			cChar = cLine[i]
			
			if cChar = '"'
				bInQuote = NOT bInQuote
				cCurrent += cChar
			but cChar = " " and NOT bInQuote
				if cCurrent != ""
					aTokens + cCurrent
					cCurrent = ""
				ok
			but cChar = "," and NOT bInQuote
				if cCurrent != ""
					aTokens + cCurrent
					cCurrent = ""
				ok
			else
				cCurrent += cChar
			ok
		end
		
		if cCurrent != ""
			aTokens + cCurrent
		ok
		
		return aTokens
	
	def _ExtractQuoted(cLine)
		nStart = substr(cLine, '"')
		if nStart = 0
			return ""
		ok
		
		nEnd = @substr(cLine, nStart + 1, len(cLine))
		nEnd = substr(nEnd, '"')
		if nEnd = 0
			return ""
		ok
		
		return @substr(cLine, nStart + 1, nStart + nEnd - 1)
	
	def _ExtractValue(cLine)
		nPos = substr(cLine, ":")
		if nPos = 0
			return ""
		ok
		
		cValue = trim(@substr(cLine, nPos + 1, len(cLine)))
		return This._Unquote(cValue)
	
	def _ExtractQuotedValue(cLine, cPattern)
		nPos = substr(cLine, cPattern)
		if nPos = 0
			return ""
		ok
		
		nStart = nPos + len(cPattern)
		cRest = @substr(cLine, nStart, len(cLine))
		nEnd = substr(cRest, '"')
		if nEnd = 0
			return cRest
		ok
		
		return @substr(cRest, 1, nEnd - 1)
	
	def _Unquote(cValue)
		if left(cValue, 1) = '"' and right(cValue, 1) = '"'
			return @substr(cValue, 2, len(cValue) - 1)
		ok
		return cValue
