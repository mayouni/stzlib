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
		for aHeader in aHeaders
			if lower(aHeader[1]) = lower(cName)
				return aHeader[2]
			ok
		next
		return ""

	def Body()
		return cBody

	def ParseQuery()
		nQuestion = substr(cPath, "?")
		if nQuestion > 0
			cQueryString = @substr(cPath, nQuestion + 1)
			cPath = left(cPath, nQuestion - 1)
			
			aPairs = @split(cQueryString, "&")
			for cPair in aPairs
				nEqual = substr(cPair, "=")
				if nEqual > 0
					cKey = left(cPair, nEqual - 1)
					cValue = @substr(cPair, nEqual + 1)
					aQuery + [cKey, cValue]
				ok
			next
		ok

	def Query(cKey)
		if cKey = NULL return aQuery ok
		
		for aParam in aQuery
			if aParam[1] = cKey
				return aParam[2]
			ok
		next
		return ""
