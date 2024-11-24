def ContainsCSXT(p1, p2, pCaseSensitive)
	oP1 = Q(p1)
	oP2 = Q(p2)

	#=== EMPTY STRING AND BASIC CASES ===
	
	# Empty string cases

	if This.String() = "" and isString(p1) = :Chars and
	   (  (isList(p2)   and len(p2) = 0) or
	      (isString(p2) and p2 = ""    ) or
	      (isNumber(p2) and p2 = 0     )    )

		return FALSE
	ok

	if ( (isList(p1)   and len(p1) = 0) or
	     (isString(p1) and p1 = ""    ) or
	     (isNumber(p1) and p1 = 0     )    ) and
	   isString(p2) and p2 = :Chars

		return FALSE
	ok

	# Direct string comparison

	if isString(p1) and isString(p2) and
	   NOT ring_find([
		:CharsW, :CharsWhere, :SubStringsW, :SubStringsWhere
	   ], p1) > 0

		return This.ContainsTheseCS([p1, p2], pCaseSensitive)
	ok

	# Simple string pairs

	if isString(p1) and isList(p2)

		if oP2.IsPairOfStrings() and p2[1] = :And
			return This.ContainsTheseCS([p1, p2[2]], pCaseSensitive)

			but oP2.IsAtPositionNamedParam() and isNumber(p2[2])
				if ring_find(This.FindCS(p1, pCaseSensitive), p2[2]) > 0
					return TRUE
				else
					return FALSE
				ok
			ok
	ok

	#=== NUMERIC OCCURRENCES ===

	if isNumber(p1) and isString(p2)
		return This.ContainsNOccurrencesCS(p1, p2, pCaseSensitive)
	ok

	if isList(p1)

		if oP1.IsExactlyNamedParam()
			return This.ContainsNOccurrencesCS(p1[2], p2, pCaseSensitive)
		ok

		if oP1.IsMoreThenNamedParam()
			return This.ContainsMoreThenNOccurrencesCS(p1[2], p2, pCaseSensitive)
		ok

		if oP1.IsLessThenNamedParam()
			return This.ContainsLessThenNOccurrencesCS(p1[2], p2, pCaseSensitive)
		ok
	ok

	#=== BOUNDED AND BETWEEN CASES ===

	# Handle bounded strings

	if ( isString(p1) or
	     ( isList(p1) and oP1.IsSubStringNamedParam() and isString(p1[2]) ) ) and
	   isList(p2)

		if isList(p1)
			cString = p1[2]
		else
			cString = p1
		ok

		if oP2.IsBoundedByNamedParam()
			return This.ContainsSubStringBoundedByCS(cString, p2[2], pCaseSensitive)
		ok

		if oP2.IsBoundedByIBNamedParam()
			return This.ContainsSubStringBoundedByCSIB(cString, p2[2], pCaseSensitive)
		ok

		if oP2.IsBetweenNamedParam() or oP2.IsBetweenIBNamedParam()

			if Q(p2[2][2]).IsAndNamedParam()
				aTemp = []
				aTemp + p2[2][1] + p2[2][2][2]
				p2[2] = aTemp
			ok

			oP22 = Q(p2[2])

			if oP22.isListOfStrings()

				if oP2.IsBetweenNamedParam()
					return This.ContainsSubStringBetweenCS(cString, p2[2][1], p2[2][2], pCaseSensitive) :
				else
					return This.ContainsSubStringBetweenCSIB(cString, p2[2][1], p2[2][2], pCaseSensitive)
				ok
			ok

			if oP22.isListOfNumbers()
				return This.ContainsSubStringBetweenPositionsCS(cString, p2[2][1], p2[2][2], pCaseSensitive)
			ok
		ok
	ok

	#=== CHARACTER OPERATIONS ===

	if isString(p1) and isList(p2) and oP2.IsListOfChars()

		switch p1

		case :Chars
			return This.ContainsTheseSubStrings(p2)
		case :TheseChars
			return This.ContainsTheseSubStrings(p2)
		
		case :SomeOfTheseChars
			return This.ContainsSomeOfTheseSubStrings(p2)

		case :OneOfTheseChars
			return This.ContainsOneOfTheseSubStrings(p2)

		case :NoneOfTheseChars
			return This.ContainsNoneOfTheseSubStrings(p2)
		off
	ok

	if isString(p1) and (p1 = :CharsWhere or p1 = :CharsW) and isString(p2)
		return This.ContainsCharsWXT(p2)
	ok

	if isString(p1) and p1 = :Chars and
	   isList(p2) and oP2.IsPairOfStrings() and p2[1] = :Where

		return this.ContainsCharsWXT(p2[2])
	ok

	#=== SUBSTRING OPERATIONS ===

	if isString(p1) and isList(p2) and oP2.IsListOfStrings()

		switch p1

		case :SubStrings
			return This.ContainsTheseSubStringsCS(p2, pCaseSensitive)
		case :TheseSubStrings
			return This.ContainsTheseSubStringsCS(p2, pCaseSensitive)

		case :SomeOfTheseSubStrings
			return This.ContainsSomeOfTheseSubStringsCS(p2, pCaseSensitive)
		case :SomeOfThese
			return This.ContainsSomeOfTheseSubStringsCS(p2, pCaseSensitive)

		case :OneOfTheseSubStrings
			return This.ContainsOneOfTheseSubStringsCS(p2, pCaseSensitive)
		case :OneOfThese
			return This.ContainsOneOfTheseSubStringsCS(p2, pCaseSensitive)

		case :NoneOfTheseSubStrings
			return This.ContainsNoneOfTheseSubStringsCS(p2, pCaseSensitive)
		case :NoneOfThese
			return This.ContainsNoneOfTheseSubStringsCS(p2, pCaseSensitive)
		off
	ok

	#=== POSITION BASED OPERATIONS ===

	if ( isString(p1) or
	     ( isList(p1) and oP1.IsSubStringNamedParam() and isString(p1[2]) ) ) and
	   isList(p2)

		if isList(p1)
			cString = p1[2]
		else
			cString = p1
		ok

		if oP2.IsOneOfTheseNamedParams([ :At, :AtPosition ]) and isNumber(p2[2])
			return This.ContainsAt(p2[2], cString)
		ok

		if oP2.IsOneOfTheseNamedParams([ :At, :AtPositions ]) and
		   isList(p2[2]) and Q(p2[2]).IsListOfNumbers()

			return This.ContainsAtPositions(p2[2], cString)
		ok

		if oP2.IsBeforeNamedParam() and Q(p2[2]).IsStringOrNumber()
			return This.ContainsBefore(cString, p2[2])
		ok

		if oP2.IsAfterNamedParam() and Q(p2[2]).IsStringOrNumber()
			return This.ContainsAfter(cString, p2[2])
		ok

		if oP2.IsBeforePositionNamedParam() and isNumber(p2[2])
			return This.ContainsBefore(cString, :Position = p2[2])
		ok

		if oP2.IsAfterPositionNamedParam() and isNumber(p2[2])
			return This.ContainsAfter(cString, :Position = p2[2])
		ok

		if oP2.IsInSectionNamedParam()
			return This.ContainsInSection(cString, p2[2])
		ok

		if oP2.IsInSectionsNamedParam()
			return This.ContainsInSections(cString, p2[2])
		ok
	ok

	StzRaise("Unsupported syntax")
