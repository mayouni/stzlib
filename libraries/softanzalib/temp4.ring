	  #----------------------------------------------------------------------#
	 #  FINDING ALL OCCURRENCES OF A SUBSTRING VERIFYING A GIVEN CONDITION  #
	#----------------------------------------------------------------------#

	def FindAllW(pcCondition)
		#< @MotherFunction = YES | @RingBased #>

		if isList(pcCondition) and StzListQ(pcCondition).IsWhereNamedParamList()
			pcCondition = pcCondition[2]
		ok

		if isString(pcCondition)
			if Q(pcCondition).ContainsOneOfTheseCS([ "@Char", "@NextChar", "@PreviousChar" ]) and
			   Q(pcCondition).ContainsNoOneOfTheseCS([ "@SubString", "@NextSubString", "@PreviousSubString" ])

				return This.FindAllCharsW(pcCondition)

			but Q(pcCondition).ContainsOneOfTheseCS([ "@Char", "@NextChar", "@PreviousChar" ]) and
			   Q(pcCondition).ContainsOneOfTheseCS([ "@SubString", "@NextSubString", "@PreviousSubString" ])

				StzRaise("Incorrect condition! Condition can't contains chars and substrings keywords.")
			ok
		else
			StzRaise("Incorrect param type! pcCondition must be a string.")
		ok

		if NOT Q(pcCondition).ContainsOneOfTheseCS([ "@SubString", "@NextSubString", "@PreviousSubString" ])
			stzRaise("Incorrect param type! pcCondition must be a string containing keword @SubString.")
		ok
? "--->"
		cCondition = StzCCodeQ(pcCondition).UnifiedFor(:stzString)

		cCode = "bOk = ( " + cCondition + " )"
		oCode = new stzString(cCode)

		acSubStrings = This.SubStrings()
		anResult = []

		for @i = 1 to This.NumberOfChars()
			@char = This[@i]
			bEval = TRUE

			if @i = This.NumberOfChars() and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[@i+1]", :CS = FALSE )

				bEval = FALSE
			ok

			if @i = 1 and
			   oCode.Copy().RemoveSpacesQ().ContainsCS( "This[@i-1]", :CS = FALSE )

				bEval = FALSE
			ok

			if bEval

				eval(cCode)

				if bOk
					anResult + @i
				ok
			ok

		next

		return anResult

		#< @FunctionFluentForm

		def FindAllWQ(pcCondition)
			return This.FindAllWQR(pcCondition, :stzList)

		def FindAllWQR(pcCondition, pcReturnType)
			switch pcReturnType
			on :stzList
				return new stzList( This.FindAllW(pcCondition) )

			on :stzListOfNumbers
				return new stzListOfNumbers( This.FindAllW(pcCondition) )

			other
				return stzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		def FindAllWhere(pcCondition)
			return This.FindAllW(pcCondition)

			def FindAllWhereQ(pcCondition)
				return This.FindAllWhereQR(pcCondition, :stzList)
	
			def FindAllWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindAllWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindAllWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindW(pcCondition)
			return This.FindAllW(pcCondition)

			def FindWQ(pcCondition)
				return This.FindWQR(pcCondition, :stzList)
	
			def FindWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindWhere(pcCondition)
			return This.FindW(pcCondition)

			def FindWhereQ(pcCondition)
				return This.FindWhereQR(pcCondition, :stzList)
	
			def FindWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def SubStringsPositionsW(pCondition)
			return This.FindAllW(pcCondition)

			def SubStringsPositionsWQ(pcCondition)
				return This.SubStringsPositionsWQR(pcCondition, :stzList)
	
			def SubStringsPositionsWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.SubStringsPositionsW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SubStringsPositionsW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def SubStringsPositionsWhere(pCondition)
			return This.FindAllW(pcCondition)

			def SubStringsPositionsWhereQ(pcCondition)
				return This.SubStringsPositionsWhereQR(pcCondition, :stzList)
	
			def SubStringsPositionsWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.SubStringsPositionsWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.SubStringsPositionsWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindSubStringsPositionsW(pcCondition)
			return This.FindAllSubStringsW(pcCondition)

			def FindSubStringsPositionsWQ(pcCondition)
				return This.FindSubStringsPositionsWQR(pcCondition, :stzList)
	
			def FindSubStringsPositionsWQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubStringsPositionsW(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindSubStringsPositionsW(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off

		def FindSubStringsPositionsWhere(pcCondition)
			return This.FindAllSubStringsW(pcCondition)

			def FindSubStringsPositionsWhereQ(pcCondition)
				return This.FindSubStringsPositionsWhereQR(pcCondition, :stzList)
	
			def FindSubStringsPositionsWhereQR(pcCondition, pcReturnType)
				switch pcReturnType
				on :stzList
					return new stzList( This.FindSubStringsPositionsWhere(pcCondition) )
	
				on :stzListOfNumbers
					return new stzListOfNumbers( This.FindSubStringsPositionsWhere(pcCondition) )
	
				other
					return stzRaise("Unsupported return type!")
				off
			
		#>

	def FindNthSubStringW(n, pcCondition)

		anPos = This.FindSubStringsW(pcCondition)
		nLen = len(anPos)

		if isString(n)
			if n = :FirstChar or n = :First
				n = 1
			but n = :LastChar or n = :Last
				n = nLen
			ok
		ok

		if NOT isNumber(n)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		nResult = anPos[n]
		return nResult

	def FindFirstSubStringW(pcCondition)
		return This.FindNthSubStringW(1, pcCondition)

	def FindLastSubStringW(pcCondition)
		return This.FindNthCharW(:LastChar, pcCondition)
