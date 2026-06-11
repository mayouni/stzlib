class stzAppRequest
	cMethod = ""
	cPath = ""
	aHeaders = []
	cBody = ""
	aParams = []
	aQuery = []

	def init(cMethodVal, cPathVal, aHeadersVal, cBodyVal)
		cMethod = cMethodVal
		cPath = cPathVal
		aHeaders = aHeadersVal
		cBody = cBodyVal
		This.ParseQuery()

	def Method()
		return cMethod

	def Path()
		return cPath

	def Headers()
		return aHeaders

	def Header(cName)
		_nHeaders1Len_ = ring_len(aHeaders)
		for _iLoopHeaders1_ = 1 to _nHeaders1Len_
			aHeader = aHeaders[_iLoopHeaders1_]
			if StzLower(aHeader[1]) = StzLower(cName)
				return aHeader[2]
			ok
		next
		return ""

	def Body()
		return cBody

	def ParseQuery()
		nQuestion = StzFind(cPath, "?")
		if nQuestion > 0
			cQueryString = @StzMidToEnd(cPath, nQuestion + 1)
			cPath = StzLeft(cPath, nQuestion - 1)
			
			aPairs = @split(cQueryString, "&")
			_nPairs1Len_ = ring_len(aPairs)
			for _iLoopPairs1_ = 1 to _nPairs1Len_
				cPair = aPairs[_iLoopPairs1_]
				nEqual = StzFind(cPair, "=")
				if nEqual > 0
					cKey = StzLeft(cPair, nEqual - 1)
					cValue = @StzMidToEnd(cPair, nEqual + 1)
					aQuery + [cKey, cValue]
				ok
			next
		ok

	def Query(cKey)
		if cKey = NULL return aQuery ok
		
		_nQuery1Len_ = ring_len(aQuery)
		for _iLoopQuery1_ = 1 to _nQuery1Len_
			aParam = aQuery[_iLoopQuery1_]
			if aParam[1] = cKey
				return aParam[2]
			ok
		next
		return ""
