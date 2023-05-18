load "stzlib.ring"

/*----------

pron()

? @@("n")	#--> "n"
? @@('n')	#--> "n"
? @@("'n'")	#--> "'n'"
? @@('"n"')	#--> '"n"'

proff()
#--> Executed in 0.02 second(s)

/*----------

pron()

o1 = new stzList([ "a", "ab", "abnA", "abAb" ])

? o1.Contains("n")
#--> FALSE

? o1.FindFirst("n")
#--> FALSE

proff()
# Executed in 0.02 second(s)

/*----------

pron()
o1 = new stzList([ "a", "ab", 1:3, "abA", "abAb", 1:3 ])

? o1.ContainsCS("ab", TRUE)
#--> TRUE

? o1.FindFirstCS("AB", FALSE)
#--> 2

? o1.FindLastCS("ABA", FALSE)
#--> 4

? o1.FindFirst(1:3)
#--> 3

? o1.FindLast(1:3)
#--> 6

proff()
# Executed in 0.09 second(s)

/*----------

pron()

o1 = new stzString("abAb")

? o1.NumberOfSubStrings()
#--> 10
# Executed in 0.02 second(s)

? @@S( o1.SubStrings() )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb", "A", "Ab", "b" ]
# Executed in 0.04 second(s)

? o1.NumberOfSubStringsCS(FALSE)
#--> 7
# Executed in 0.12 second(s)

? @@S( o1.SubStringsCS(FALSE) )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb" ]
# Executed in 0.12 second(s)

proff()
#--> Executed in 0.27 second(s)

/*----------

pron()

o1 = new stzString("hello")
? o1.NumberOfSubStrings()
#--> 15

? @@S( o1.SubStrings() )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "l", "lo",
#	"o"
# ]

proff()
# Executed in 0.06 second(s)

/*----------

pron()

o1 = new stzString("hello")
? o1.NumberOfSubStringsCS(FALSE)
#--> 14

? @@S( o1.SubStringsCS(FALSE) )
#--> [
#	"h", "he", "hel", "hell", "hello",
#	"e", "el", "ell", "ello",
#	"l", "ll", "llo", "lo",
#	"o"
# ]

proff()
# Executed in 0.54 second(s)

/*----------

pron()

o1 = new stzString("*4*34")
? o1.NumberOfSubStrings()
#--> 15

? @@S( o1.SubStrings() )
#--> [
#	"*", "*4", "*4*", "*4*3", "*4*34",
#	"4", "4*", "4*3", "4*34", "*",
#	"*3", "*34", "3", "34", "4"
# ]

proff()
# Executed in 0.05 second(s)

/*=============

pron()

o1 = new stzList([ "*", "4", "*", "3", "4" ])
//o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.05 second(s)

#
/*----------

pron()

o1 = new stzList([
	"*", "*4", "*4*", "*4*3", "*4*34",
	"4", "4*", "4*3", "4*34", "*", "*3",
	"*34", "3", "34", "4"
])

? o1.NumberOfDuplicates()
#--> 2

? o1.FindDuplicates()
#--> [10, 15]

? o1.Duplicates()
#--> ["*", 4]

? o1.DuplicatesZ()
#--> [ "*" = 10, "4" = 15 ]

proff()
# Executed in 0.25 second(s)

/*-----------

pron()

o1 = new stzString("*4*34")

? o1.NumberOfDuplicates()
#--> 2

? o1.Duplicates()
#--> [ "*", "4" ]

proff()
# Executed in 0.28 second(s)

/*----------

pron()
? "Please wait..."
o1 = new stzString("ring php ringoria")
? o1.NumberOfDuplicates()
#--> 12

? o1.Duplicates()
#--> [
#	"p", " ", "r", "ri", "rin",
#	"ring", "i", "in", "ing",
#	"n", "ng", "g", "r", "ri","i"
# ]

proff()
# Executed in 3.33 second(s)

/*----------
*/
pron()

o1 = new stzString("RINGORIALAND")
? o1.ContainsDuplicates()
#--> TRUE

? o1.NumberOfDuplicates()
#--> 5

? @@S( o1.Duplicates() )
#--> [ "R", "RI", "I", "A", "N" ]

? @@S( o1.DuplicatesZ() )

proff()
# Executed in 1.66 second(s)

/*----------------------------------------------------------
TODO: SUBSTRING
	  #==============================================================#
	 #   SUBSTRING(S) ENCLOSED BETWEEN TWO SUBSTRINGS OR POSITIONS  # 
	#==============================================================#

	def BetweenCS(p1, p2, pCaseSensitive)

		# Checking params

		if isList(p1) and Q(p1).IsOneOfTheseNamedParams([ :SubString, :Position, :SubStrings, :Positions ])
			p1 = p1[2]
		ok

		if isList(p2) and Q(p2).IsOneOfTheseNamedParams([ :And, :AndSubString, :AndPosition ])
			p1 = p1[2]
		ok

		# Doing the job

		if BothAreNumbers(p1, p2) # In case p1 and p2 are numbers forming a section
			return This.Section(p1, p2)

		but BothAreStrings(p1, p2)
			return This.SubStringsBetweenCS(p1, p2, pCaseSensitive)

		else
			StzRaise("Incorrect param's types! p1 and p2 must be both numbers or both strings.")

		ok

		#< @FunctionFluentForms

		def BetweenCSQ(p1, p2, pCaseSensitive)
			return Q( This.BetweenCS(p1, p2, pCaseSensitive) )

		def BetweenCSQR(p1, p2, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzClassNames() )
				StzRaise("Incorrect param! pcReturnType must be a string containing a Softanza class name.")
			ok

			Between = This.BetweenCS(p1, p2, pCaseSensitive)

			if isString(Between)
				if pcReturnType = :stzString
					return new stzString(Between)
				else
					StzRaise("Can't return a stzString! Because the data is a list.")
				ok

			but isList(Between)
				switch pcReturnType
				on :stzList
					return new stzList(Between)

				on :stzListOfStrings
					return new stzListOfStrings(Between)

				other
					StzRaise("Unsupported return type!")
				off

			ok

		#>

	#-- WITHOUT CASESENSITIVITY

	def Between(p1, p2)
		return This.BetweenCS(p1, p2, :CaseSensitive = TRUE)

		#< @FunctionFluentForms

		def BetweenQ(p1, p2)
			return Q( This.Between(p1, p2) )

		def BetweenQR(p1, p2, pcReturnType)
			return This.BetweenCSQR(p1, p2, :CaseSensitive = TRUE, pcReturnType)

		#>

	  #------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- Z/EXTENDED  #
	#==================================================================#

	def BetweenZCS(p1, p2, pCaseSensitive)

		between = This.BetweenCS(p1, p2, pCaseSensitive)

		if isString(between) # In case p1 and p2 are numbers forming a section
			return [ between, This.FindCS(between, pCaseSensitive) ]
		
		else
			return This.SubStringsBetweenZCS(p1, p2, pCaseSensitive) 
		ok
		
		#< @FunctionAlternativeForm

		def BetweenCSZ(p1, p2, pCaseSensitive)
			return This.BetweenZCS(p1, p2, pCaseSensitive)

		def AnyBetweenZCS(p1, p2, pCaseSensitive)
			return This.BetweenZCS(p1, p2, pCaseSensitive)

			def AnyBetweenCSZ(p1, p2, pCaseSensitive)
				return This.BetweenZCS(p1, p2, pCaseSensitive)
	
		def BoundedByZCS(pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.BetweenZCS(pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsListOfStrings()
				return This.BetweenZCS(pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
			ok

			def BoundedByCSZ(pacBounds, pCaseSensitive)
				return This.BoundedByZCS(pacBounds, pCaseSensitive)

		def AnyBoundedByZCS(pacBounds, pCaseSensitive)
			return This.BoundedByZCS(pacBounds, pCaseSensitive)

			def AnyBoundedByCSZ(pacBounds, pCaseSensitive)
				return This.AnyBoundedByZCS(pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def BetweenZ(p1, p2)
		return This.BetweenZCS(p1, p2, :CaseSensitive = TRUE)
 
		#< @FunctionAlternativeForm

		def AnyBetweenZ(p1, p2)
			return This.BetweenZ(p1, p2)

		def BoundedByZ(pacBounds)
			return This.BoundedByZCS(pacBounds, :CaseSensitive = TRUE)

		def AnyBoundedByZ(pacBounds)
			return This.BoundedByZ(pacBounds)

		#>

	  #---------------------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO OTHER SUBSTRINGS -- ZZ/EXTENDED #
	#=========================================================#

	def SubStringsBetweenZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		aSections = This.FindAnyBetweenAsSectionsCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		acSubStr  = This.Sections(aSections)

		aResult = Association([ acSubStr, aSections ])

		return aResult

		#< @FunctionFluentForm

		def SubStringsBetweenZZCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenZZCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

		def SubStringsBetweenZZCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

			switch pcReturnType
			on :stzList
				return new stzList( This.SubStringsBetweenZZCS(pcSubStr1, pcSubStr2, pCaseSensitive) )

			on :stzListOfPairs
				return new stzListOfPairs( This.SubStringsBetweenZZCS(pcSubStr1, pcSubStr2, pCaseSensitive) )

			other
				StzRaise( "Unsupported return type!")
			off

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenZZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenZZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def subStringsBetweenZZQ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenZZCSQ(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		def SubStringsBetweenZZQR(pcSubStr1, pcSubStr2, pcReturnType)
			return This.SubStringsBetweenZZCSQR(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE, pcReturnType)

		#>

	  #---------------------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO OTHER SUBSTRINGS -- Z/EXTENDED  #
	#=========================================================#

	def SubStringsBetweenZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		aBetweenZZ = This.SubStringsBetweenZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		nLen = len(aBetweenZZ)

		aResult = []
		for i = 1 to nLen
			aResult + [ aBetweenZZ[i][1], aBetweenZZ[i][2][1] ]
		next

		return aResult

		#< @FunctionAlternativeForm

		def SubStringsBetweenCSZ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		def AnySubStringsBetweenZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		
			def AnySubStringsBetweenCSZ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.AnySubStringsBetweenZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		#>

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenZ( pcSubStr1, pcSubStr2 )
		return This.SubStringsBetweenZCS( pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		def AnySubStringsBetweenZ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenZ(pcSubStr1, pcSubStr2)
		
		#>

	  #--------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- UZZ/EXTENDED  #
	#====================================================================#

	def BetweenZZCS(p1, p2, pCaseSensitive)

		between = This.BetweenCS(p1, p2, pCaseSensitive)

		if isString(between) # Case where p1 and p2 are numbers
			return [ between, This.FindAsSectionsCS(between, pCaseSensitive) ]

		else
			return This.SubStringsBetweenZZCS(p1, p2, pCaseSensitive)
		ok
		
		#< @FunctionAlternativeForm

		def BetweenCSZZ(p1, p2, pCaseSensitive)
			return This.BetweenZZCS(p1, p2, pCaseSensitive)

		def AnyBetweenZZCS(p1, p2, pCaseSensitive)
			return This.BetweenZZCS(p1, p2, pCaseSensitive)

			def AnyBetweenCSZZ(p1, p2, pCaseSensitive)
				return This.AnyBetweenZZCS(p1, p2, pCaseSensitive)
		
		def BoundedByZZCS(pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.BetweenZZCS(pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsListOfStrings()
				return This.BetweenZZCS(pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or a pair of strings.")
			ok

			def BoundedByCSZZ(pacBounds, pCaseSensitive)
				return This.BoundedByZZCS(pacBounds, pCaseSensitive)

		def AnyBoundedByZZCS(pacBounds, pCaseSensitive)
			return This.BoundedByZZCS(pacBounds, pCaseSensitive)

			def AnyBoundedByCSZZ(pacBounds, pCaseSensitive)
				return This.AnyBoundedByZZCS(pacBounds, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def BetweenZZ(p1, p2)
		return This.BetweenZZCS(p1, p2, :CaseSensitive = TRUE)
 
		#< @FunctionAlternativeForm

		def AnyBetweenZZ(p1, p2)
			return This.BetweenZZ(p1, p2)
		
		def BoundedByZZ(pacBounds)
			return This.BoundedByZZCS(pacBounds, :CaseSensitive = TRUE)

		def AnyBoundedByZZ(pacBounds)
			return This.BoundedByZZ(pacBounds)

		#>

	  #------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO OTHER SUBSTRINGS #
	#==========================================#

	def SubStringsBetweenCS( pcSubStr1, pcSubStr2, pCaseSensitive )
		aBetweenZZ = This.SubStringsBetweenZZCS( pcSubStr1, pcSubStr2, pCaseSensitive )
		nLen = len(aBetweenZZ)

		aResult = []

		for i = 1 to nLen
			aResult + aBetweenZZ[i][1]
		next

		return aResult

		#< @FunctionFluentForm

		def SubStringsBetweenCSQ( pcSubStr1, pcSubStr2, pCaseSensitive )
			return This.SubStringsBetweenCSQR( pcSubStr1, pcSubStr2, pCaseSensitive, :stzList )

		def SubStringsBetweenCSQR( pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType )
			switch pcReturnType
			on :stzList
				return new stzList( This.SubStringsBetweenCS( pcSubStr1, pcSubStr2, pCaseSensitive ) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SubStringsBetweenCS( pcSubStr1, pcSubStr2, pCaseSensitive ) )

			other
				StzRaise("Unsupported return type!")
			off

		#>

		#< @FunctionAlternativeForms

		// See them in bottom of file

		#>
		
	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetween( pcSubStr1, pcSubStr2 )
		return This.SubStringsBetweenCS( pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionAlternativeForm

		// See them in bottom of file

		#>

	  #------------------------------------------------------------------------------#
	 #  SUBSTRING(S) ENCLOSED BETWEEN TWO SUBSTRINGS (OR POSITIONS) -- IB/EXTENDED  # 
	#==============================================================================#

	def BetweenIBCS(p1, p2, pCaseSensitive)
		if isList(p1) and Q(p1).IsOneOfTheseNamedParams([ :SubString, :Position, :SubStrings, :Positions ])
			p1 = p1[2]
		ok

		if isList(p2) and Q(p2).IsOneOfTheseNamedParams([ :And, :AndSubString, :AndPosition ])
			p1 = p1[2]
		ok

		if BothAreNumbers(p1, p2)
			return This.Section(p1, p2)

		but BothAreStrings(p1, p2)
			return this.SubStringsBetweenIBCS(p1, p2, pCaseSensitive)

		else
			StzRaise("Incorrect param's types! p1 and p2 must be both numbers or both strings.")

		ok

		#< @FunctionFluentForm

		def BetweenIBCSQ(p1, p2, pCaseSensitive)
			Between = This.BetweenIBCS(p1, p2, pCaseSensitive)

			if isString(Between)
				return new stzString(Between)

			but isList(Between)
				return new stzList(Between)
			ok

		def BetweenIBCSQR(p1, p2, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzClassName() )

				StzRaise("Incorrect param type! pcReturnType must be a string " +
					 "containing a Softanza class name.")
			ok

			Between = This.BetweenIBCS(p1, p2, pCaseSensitive)

			if isString(Between)
				return new stzString(Between)

			but isList(Between)
				switch pcReturnType
				on :stzList
					return new stzList(Between)
				on :stzListOfStrings
					return new stzListOfStrings(Between)
				other
					StzRaise("Unsupported return type!")
				off
			ok

		#>

	#-- WITHOUT CASESENSITIVITY

	def BetweenIB(p1, p2)
		return This.BetweenIBCS(p1, p2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def BetweenIBQ(p1, p2)
			return This.BetweenIBCSQ(p1, p2, :CaseSensitive = TRUE)

		def BetweenIBQR(p1, p2, pcReturnType)
			return This.BetweenIBCSQR(p1, p2, :CaseSensitive = TRUE, pcReturnType)
		#>

	  #-----------------------------------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO SUBSTRINGS (OR POSITIONS) -- IB/Z() EXTENDED  #
	#=======================================================================#

	def BetweenIBZCS(p1, p2, pCaseSensitive)
	
		acBetweenIBU = This.BetweenIBCS(p1, p2, pCaseSensitive)
		anPositions  = This.FindAnyBetweenIBCS(p1, p2, pCaseSensitive)

		aResult = Association([ acBetweenIBU,  anPositions ])
		return aResult
	
		#< @FunctionAlternativeForms
	
		def BetweenIBCSZ(p1, p2, pCaseSensitive)
			return This.BetweenIBZCS(p1, p2, pCaseSensitive)

		def AnyBetweenIBZCS(p1, p2, pCaseSensitive)
			return This.BetweenIBZCS(p1, p2, pCaseSensitive)
	
			def AnyBetweenIBCSZ(p1, p2, pCaseSensitive)
				return This.AnyBetweenIBZCS(p1, p2, pCaseSensitive)

		def BoundedByIBZCS(pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.BetweenIBZCS(pacBounds, pacBounds, pCaseSensitive)
			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.BetweenIBUZCS(pacBounds[1], pacBounds[2], pCaseSensitive)
			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

			def BoundedByIBCSZ(pacBounds, pCaseSensitive)
				return This.BoundedByIBZCS(pacBounds, pCaseSensitive)
	
		def AnyBoundedByIBZCS(pacBounds, pCaseSensitive)
			return This.BoundedByIBZCS(pacBounds, pCaseSensitive)

			def AnyBoundedByIBCSZ(pacBounds, pCaseSensitive)
				return This.AnyBoundedByIBZCS(pacBounds, pCaseSensitive)

		#>
	
	#-- WITHOUT CASESENSITIVITY
	
	def BetweenIBZ(p1, p2)
		return This.BetweenIBZCS(p1, p2, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms
	
		def AnyBetweenIBZ(p1, p2)
			return This.BetweenIBZ(p1, p2)
	
		def BoundedByIBZ(pacBounds)
			return This.BoundedByIBZCS(pacBounds, :CaseSensitive = TRUE)
	
		def AnyBoundedByIBZ(pacBounds)
			return This.BoundedByIBZ(pacBounds)
	
		#>
		
	  #------------------------------------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO SUBSTRINGS (OR POSITIONS) -- IB/ZZ() EXTENDED  #
	#========================================================================#

	def BetweenIBZZCS(p1, p2, pCaseSensitive)
	
		acBetweenIB = This.BetweenIBCS(p1, p2, pCaseSensitive)
		anSections  = This.FindAnyBetweenAsSectionsIBCS(p1, p2, pCaseSensitive)

		aResult = Association([ acBetweenIB, anSections ])
		return aResult
	
		#< @FunctionAlternativeForms
	
		def BetweenIBCSZZ(p1, p2, pCaseSensitive)
			return This.BetweenIBZZCS(p1, p2, pCaseSensitive)

		def AnyBetweenIBZZCS(p1, p2, pCaseSensitive)
			return This.BetweenIBZZCS(p1, p2, pCaseSensitive)

			def AnyBetweenIBCSZZ(p1, p2, pCaseSensitive)
				return This.AnyBetweenIBZZCS(p1, p2, pCaseSensitive)

		def BoundedByIBZZCS(pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.BetweenIBZZCS(pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.BetweenIBZZCS(pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

			def BoundedByIBCSZZ(pacBounds, pCaseSensitive)
				return This.BoundedByIBZZCS(pacBounds, pCaseSensitive)
	
		def AnyBoundedByIBZZCS(pacBounds, pCaseSensitive)
			return This.BoundedByIBZZCS(pacBounds, pCaseSensitive)
	
			def AnyBoundedByIBCSZZ(pacBounds, pCaseSensitive)
				return This.AnyBoundedByIBZZCS(pacBounds, pCaseSensitive)

		#>
	
	#-- WITHOUT CASESENSITIVITY
	
	def BetweenIBZZ(p1, p2)
		return This.BetweenIBZZCS(p1, p2, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms
	
		def AnyBetweenIBZZ(p1, p2)
			return This.BetweenIBZZ(p1, p2)
	
		def BoundedByIBZZ(pacBounds)
			return This.BoundedByIBZZCS(pacBounds, :CaseSensitive = TRUE)
	
		def AnyBoundedByIBZZ(pacBounds)
			return This.BoundedByIBZZ(pacBounds)
	
		#>

	  #----------------------------------------------------------------------#
	 #   SUBSTRINGS ENCLOSED BETWEEN TWO OTHER SUBSTRINGS  -- IB/EXTENDED   # 
	#======================================================================#
	# Bounds are considered in the results

	def SubstringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		/* EXAMPLE

		o1 = new stzString("blabla bla <<word1>> bla bla <<word2>>")
		? o1.SubstringsBetweenIB("<<", ">>")

		# --> [ "<<word1>>", "<<word2>>" ]
		*/

		aSections = This.FindAnyBetweenAsSectionsIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		acResult = This.Sections(aSections)

		return acResult

		#< @FunctionFluentForm

		def SubstringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

		def SubstringsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			switch pcReturnType
			on :stzList
				return new stzList( This.SubstringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive) )

			on :stzListOfStrings
				return new stzListOfStrings( This.SubstringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive) )

			other
				stzRaise("Unsupported return type!")
			off
			
		#>

	#-- WITHOUT CASESENSITIVITY

	def SubstringsBetweenIB(pcSubStr1, pcSubStr2)
		return This.SubstringsBetweenIBCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def SubstringsBetweenIBQ(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenIBQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

		def SubstringsBetweenIBQR(pcSubStr1, pcSubStr2, pcReturnType)
			return This.SubStringsBetweenIBCSQR(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE, pcReturnType)

		#>

	  #--------------------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO SUBSTRINGS -- IB/Z() EXTENDED  #
	#========================================================#

	def SubStringsBetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		acBetweenIB = This.SubStringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		anPositions = This.FindBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		aResult = Association([ acBetweenIB, anPositions ])
	
		return aResult
	
		#< @FunctionAlternativeForms
	
		def SubStringsBetweenIBCSZ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnySubStringBetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.BetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringBetweenIBCSZ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.AnySubStringBetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnySubStringsBetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.BetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
			def AnySubStringsBetweenIBCSZ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.BetweenIBZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		def SubStringsBoundedByIBZCS(pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.SubStringsBetweenIBZCS(pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.SubstringsBetweenIBZCS(pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok

			def SubStringsBoundedByIBCSZ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByIBZCS(pacBounds, pCaseSensitive)
	
		def AnySybStringBoundedByIBZCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByIBZCS(pacBounds, pCaseSensitive)

			def AnySybStringBoundedByIBCSZ(pacBounds, pCaseSensitive)
				return This.AnySybStringBoundedByIBZCS(pacBounds, pCaseSensitive)

		def AnySybStringsBoundedByIBZCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByIBZCS(pacBounds, pCaseSensitive)
	
			def AnySybStringsBoundedByIBCSZ(pacBounds, pCaseSensitive)
				return This.AnySybStringsBoundedByIBZCS(pacBounds, pCaseSensitive)

		#>
	
	#-- WITHOUT CASESENSITIVITY
	
	def SubStringsBetweenIBZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenIBZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms
	
		def AnySubStringBetweenIBZ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenIBZ(pcSubStr1, pcSubStr2)
	
		def AnySubStringsBetweenIBZ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenIBZ(pcSubStr1, pcSubStr2)

		def SubStringsBoundedByIBZ(pacBounds)
			return This.SubstringsBoundedByIBZCS(pacBounds, :CaseSensitive = TRUE)
	
		def AnySubStringBoundedByIBZ(pacBounds)
			return This.SubStringsBoundedByIBZ(pacBounds)

		def AnySubStringsBoundedByIBZ(pacBounds)
			return This.SubStringsBoundedByIBZ(pacBounds)
	
		#>
		
	  #---------------------------------------------------------#
	 #  SUBSTRINGS BETWEEN TWO SUBSTRINGS -- IB/ZZ() EXTENDED  #
	#=========================================================#

	def SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		acBetweenIB = This.SubStringsBetweenIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		anSections  = This.FindBetweenAsSectionsIBCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		aResult = Association( :Of = acBetweenIB, :And = anPositions )
	
		return aResult
	
		#< @FunctionAlternativeForms

		def SubStringsBetweenIBCSZZ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		def AnySubStringBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringBetweenIBCSZZ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		def AnySubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

			def AnySubStringsBetweenIBCSZZ(pcSubStr1, pcSubStr2, pCaseSensitive)
				return This.SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
	
		def SubStringsBoundedByIBZZCS(pacBounds, pCaseSensitive)
			if isString(pacBounds)
				return This.SubstringsBetweenIBZZCS(pacBounds, pacBounds, pCaseSensitive)

			but isList(pacBounds) and Q(pacBounds).IsPairOfStrings()
				return This.SubStringsBetweenIBZZCS(pacBounds[1], pacBounds[2], pCaseSensitive)

			else
				StzRaise("Incorrect param type! pacBounds must be a string or pair of strings.")
			ok
	
			def SubStringsBoundedByIBCSZZ(pacBounds, pCaseSensitive)
				return This.SubStringsBoundedByIBZZCS(pacBounds, pCaseSensitive)

		def AnySubstringBoundedByIBZZCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByIBZZCS(pacBounds, pCaseSensitive)

			def AnySubstringBoundedByIBCSZZ(pacBounds, pCaseSensitive)
				return This.AnySubstringBoundedByIBZZCS(pacBounds, pCaseSensitive)

		def AnySubstringsBoundedByIBZZCS(pacBounds, pCaseSensitive)
			return This.SubStringsBoundedByIBZZCS(pacBounds, pCaseSensitive)
	
			def AnySubstringsBoundedByIBCSZZ(pacBounds, pCaseSensitive)
				return This.AnySubstringsBoundedByIBZZCS(pacBounds, pCaseSensitive)

		#>
	
	#-- WITHOUT CASESENSITIVITY
	
	def SubstringsBetweenIBZZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenIBZZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)
	
		#< @FunctionAlternativeForms
	
		def AnySubStringBetweenIBZZ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenIBZZ(pcSubStr1, pcSubStr2)

		def AnySubStringsBetweenIBZZ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenIBZZ(pcSubStr1, pcSubStr2)

		def SubstringsBoundedByIBZZ(pacBounds)
			return This.subStringsBoundedByIBZZCS(pacBounds, :CaseSensitive = TRUE)
	
		def AnySubStringBoundedByIBZZ(pacBounds)
			return This.SubStringsBoundedByIBZZ(pacBounds)
	
		def AnySubStringsBoundedByIBZZ(pacBounds)
			return This.SubStringsBoundedByIBZZ(pacBounds)

		#>

	  #----------------------------------------------------------------------------#
	 #  UNIQUE SUBSTRING(S) ENCLOSED BETWEEN TWO OTHER SUBSTRINGS (OR POSITIONS)  # 
	#============================================================================#

	def BetweenUCS(p1, p2, pCaseSensitive)
		if isList(p1) and Q(p1).IsOneOfTheseNamedParams([ :SubString, :Position, :SubStrings, :Positions ])
			p1 = p1[2]
		ok

		if isList(p2) and Q(p2).IsOneOfTheseNamedParams([ :And, :AndSubString, :AndPosition ])
			p1 = p1[2]
		ok

		if BothAreNumbers(p1, p2)
			return This.Section(p1, p2)

		but BothAreStrings(p1, p2)
			acResult = This.BetweenCSQ(p1, p2, pCaseSensitive).DupplicatesRemoved()
			return acResult

		else
			StzRaise("Incorrect param's types! p1 and p2 must be both numbers or both strings.")

		ok

		#< @FunctionFluentForm

		def BetweenUCSQ(p1, p2, pCaseSensitive)
			Between = This.BetweenCS(p1, p2, pCaseSensitive)

			if isString(Between)
				return new stzString(Between)

			but isList(Between)
				return new stzList(Between)
			ok

		def BetweenUCSQR(p1, p2, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzClassName() )

				StzRaise("Incorrect param type! pcReturnType must be a string " +
					 "containing a Softanza class name.")
			ok

			Between = This.BetweenCS(p1, p2, pCaseSensitive)

			if isString(Between)
				return new stzString(Between)

			but isList(Between)
				switch pcReturnType
				on :stzList
					return new stzList(Between)
				on :stzListOfStrings
					return new stzListOfStrings(Between)
				other
					StzRaise("Unsupported return type!")
				off
			ok

		#>

		#< @FunctionAlternativeForm

		def AnyBetweenUCS(p1, p2, pCaseSensitive)
			return This.BetweenUCS(p1, p2, pCaseSensitive)

		def AnyBetweenUCSQ(p1, p2, pCaseSensitive)
			return This.BetweenUCSQ(p1, p2, pCaseSensitive)

		def AnyBetweenUCSQR(p1, p2, pCaseSensitive, pcReturType)
			return This.BetweenUCSQR(p1, p2, pCaseSensitive, pcReturType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def BetweenU(p1, p2)
		return This.BetweenUCS(p1, p2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def BetweenUQ(p1, p2)
			return This.BetweenUCSQ(p1, p2, :CaseSensitive = TRUE)

		def BetweenUQR(p1, p2, pcReturnType)
			return This.BetweenUCSQR(p1, p2, :CaseSensitive = TRUE, pcReturnType)
		#>

		#< @FunctionAlternativeForm

		def AnyBetweenU(p1, p2)
			return This.BetweenU(p1, p2)

		def AnyBetweenUQ(p1, p2)
			return This.BetweenUQ(p1, p2)

		def AnyBetweenUQR(p1, p2)
			return This.BetweenUQR(p1, p2)

		#>

	  #--------------------------------------------------------------------------#
	 #  UNIQUE SUBSTRINGS ENCLOSED BETWEEN TWO OTHER SUBSTRINGS (OR POSITIONS)  #
	#==========================================================================#

	def SubstringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		acResult = This.SubStringsBetweenCSQ(pcSubStr1, pcSubStr2, pCaseSensitive).
				DuplicatesRemoved()

		return acResult

		#< @FunctionFluentForm

		def SubstringsBetweenUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

		def SubstringsBetweenUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			acResult = This.SubstringsBetweenCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType).
				DuplicatesRemoved()

			return acResult

		#>

		#< @FunctionAlternativeForm

		def AnySubStringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnySubStringsBetweenUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubStringsBetweenUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnySubStringsBetweenUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturType)
			return This.SubStringsBetweenUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubstringsBetweenU(pcSubStr1, pcSubStr2)
		return This.SubstringsBetweenUCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def SubstringsBetweenUQ(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenUQR(pcSubStr1, pcSubStr2, :stzList)

		def SubstringsBetweenUQR(pcSubStr1, pcSubStr2, pcReturnType)
			return This.SubstringsBetweenICSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		#>


		#< @FunctionAlternativeForm

		def AnySubStringsBetweenU(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenU(pcSubStr1, pcSubStr2)

		def AnySubStringsBetweenUQ(pcSubStr1, pcSubStr2)
			return This.SubStringsBetweenUQ(pcSubStr1, pcSubStr2)

		def AnySubStringsBetweenUQR(pcSubStr1, pcSubStr2, pcReturType)
			return This.SubStringsBetweenUCQR(pcSubStr1, pcSubStr2, pcReturType)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  UNIQUE SUBSTRING(S) ENCLOSED BETWEEN TWO OTHER SUBSTRINGS (OR POSITIONS) -- IB/Extended  # 
	#===========================================================================================#

	def BetweenIBUCS(p1, p2, pCaseSensitive)
		if isList(p1) and Q(p1).IsOneOfTheseNamedParams([ :SubString, :Position, :SubStrings, :Positions ])
			p1 = p1[2]
		ok

		if isList(p2) and Q(p2).IsOneOfTheseNamedParams([ :And, :AndSubString, :AndPosition ])
			p1 = p1[2]
		ok

		if BothAreNumbers(p1, p2)
			return This.Section(p1, p2)

		but BothAreStrings(p1, p2)
			acResult = This.BetweenIBCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
			return acResult

		else
			StzRaise("Incorrect param's types! p1 and p2 must be both numbers or both strings.")

		ok

		#< @FunctionFluentForm

		def BetweenIBUCSQ(p1, p2, pCaseSensitive)
			Between = This.BetweenIBUCS(p1, p2, pCaseSensitive)

			if isString(Between)
				return new stzString(Between)

			but isList(Between)
				return new stzList(Between)
			ok

		def BetweenIBUCSQR(p1, p2, pCaseSensitive, pcReturnType)
			if isList(pcReturnType) and Q(pcReturnType).IsReturnedAsNamedParam()
				pcReturnType = pcReturnType[2]
			ok

			if NOT ( isString(pcReturnType) and Q(pcReturnType).IsStzClassName() )

				StzRaise("Incorrect param type! pcReturnType must be a string " +
					 "containing a Softanza class name.")
			ok

			Between = This.BetweenIBUCS(p1, p2, pCaseSensitive)

			if isString(Between)
				return new stzString(Between)

			but isList(Between)
				switch pcReturnType
				on :stzList
					return new stzList(Between)
				on :stzListOfStrings
					return new stzListOfStrings(Between)
				other
					StzRaise("Unsupported return type!")
				off
			ok

		#>

		#< @FunctionAlternativeForm

		def AnyBetweenIBUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.BetweenIBUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnyBetweenIBUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.BetweenIBUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnyBetweenIBUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			return This.BetweenIBUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def BetweenIBU(p1, p2)
		return This.BetweenIBUCS(p1, p2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def BetweenIBUQ(p1, p2)
			return This.BetweenIBUCSQ(p1, p2, :CaseSensitive = TRUE)

		def BetweenIBUQR(p1, p2, pcReturnType)
			return This.BetweenIBUCSQR(p1, p2, :CaseSensitive = TRUE, pcReturnType)
		#>

		#< @FunctionAlternativeForm

		def AnyBetweenIBU(pcSubStr1, pcSubStr2)
			return This.BetweenIBU(pcSubStr1, pcSubStr2)

		def AnyBetweenIBUQ(pcSubStr1, pcSubStr2)
			return This.BetweenIBUQ(pcSubStr1, pcSubStr2)

		def AnyBetweenIBUQR(pcSubStr1, pcSubStr2, pcReturnType)
			return This.BetweenIBUQR(pcSubStr1, pcSubStr2, pcReturnType)

		#>

	  #-----------------------------------------------------------------------------#
	 #   UNIQUE SUBSTRINGS ENCLOSED BETWEEN TWO OTHER SUBSTRINGS  -- IB/EXTENDED   # 
	#=============================================================================#

	def SubstringsBetweenIBUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		acResult = This.SubStringsBetweenIBCSQ(pcSubStr1, pcSubStr2, pCaseSensitive).
				DuplicatesRemoved()

		return acResult

		#< @FunctionFluentForm

		def SubstringsBetweenIBUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenIBUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, :stzList)

		def SubstringsBetweenIBUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			acResult = This.SubstringsBetweenIBCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType).
				DuplicatesRemoved()

			return acResult

		#>

		#< @FunctionAlternativeForm

		def AnySubstringsBetweenIBUCS(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenIBUCS(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnySubstringsBetweenIBUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)
			return This.SubstringsBetweenIBUCSQ(pcSubStr1, pcSubStr2, pCaseSensitive)

		def AnySubstringsBetweenIBUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)
			return This.SubstringsBetweenIBUCSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		#>

	#-- WITHOUT CASESENSITIVITY

	def SubstringsBetweenIBU(pcSubStr1, pcSubStr2)
		return This.SubstringsBetweenIBUCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

		#< @FunctionFluentForm

		def SubstringsBetweenIBUQ(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenIBUQR(pcSubStr1, pcSubStr2, :stzList)

		def SubstringsBetweenIBUQR(pcSubStr1, pcSubStr2, pcReturnType)
			return This.SubstringsBetweenIBUSQR(pcSubStr1, pcSubStr2, pCaseSensitive, pcReturnType)

		#>

		#< @FunctionAlternativeForm

		def AnySubstringsBetweenIBU(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenIBU(pcSubStr1, pcSubStr2)

		def AnySubstringsBetweenIBUQ(pcSubStr1, pcSubStr2)
			return This.SubstringsBetweenIBUQ(pcSubStr1, pcSubStr2)

		def AnySubstringsBetweenIBUQR(pcSubStr1, pcSubStr2, pcReturnType)
			return This.SubstringsBetweenIBUQR(pcSubStr1, pcSubStr2, pcReturnType)

		#>

	  #-------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- UZ/EXTENDED  #
	#===================================================================#
	# TODO: add FluentForms and AlternativeForms

	def BetweenUZCS(p1, p2, pCaseSensitive)
		acBetween = This.BetweenUCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			anPos = This.FindSubStringBetweenCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], anPos ]
		next i
	
		return aResult
	
	#-- WITHOUT CASESENSITIVITY

	def BetweenUZ(p1, p2, pCaseSensitive)
		return BetweenUZCS(p1, p2, :CaseSensitive = TRUE)

	  #------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- UZ/EXTENDED  #
	#============================================================#

	def SubStringsBetweenUZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.BetweenUZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenUZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenUZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- UZZ/EXTENDED  #
	#====================================================================#

	def BetweenUZZCS(p1, p2, pCaseSensitive)
		acBetween = This.BetweenUCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			aSections = This.FindBetweenAsSectionsCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], aSections ]
		next i
	
		return aResult
	
	#-- WITHOUT CASESENSITIVITY

	def BetweenUZZ(p1, p2)
		return BetweenUZZCS(p1, p2, :CaseSensitive = TRUE)

	  #-------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- UZZ/EXTENDED  #
	#=============================================================#

	def SubStringsBetweenUZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.BetweenUZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenUZZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenUZZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

	  #---------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- IBUZ/EXTENDED  #
	#=====================================================================#

	def BetweenIBUZCS(p1, p2, pCaseSensitive)
		acBetween = This.BetweenIBCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			anPos = This.FindSubStringBetweenCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], anPos ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenIBUZ(p1, p2)
		return This.BetweenIBUZCS(p1, p2, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- IBUZ/EXTENDED  #
	#==============================================================#

	def SubStringsBetweenIBUZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.BetweenIBUZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenIBUZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenIBUZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- IBUZZ/EXTENDED  #
	#======================================================================#

	def BetweenIBUZZCS(p1, p2, pCaseSensitive)
		acBetween = This.BetweenIBCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			aSections = This.FindBetweenAsSectionsCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], aSections ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenIBUZZ(p1, p2)
		return This.BetweenIBUZZCS(p1, p2, :CaseSensitive = TRUE)

	  #---------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- IBUZZ/EXTENDED  #
	#===============================================================#

	def SubStringsBetweenIBUZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.BetweenIBUZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenIBUZZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenIBUZZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SUZ/EXTENDED  #
	#====================================================================#

	def BetweenSUZCS(p1, p2, pCaseSensitive)
		acBetween = This.BetweenSCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			anPos = This.FindSubStringBetweenCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], anPos ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenSUZ(p1, p2)
		return This.BetweenSUZCS(p1, p2, :CaseSensitive = TRUE)

	  #-------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- SUZ/EXTENDED  #
	#=============================================================#

	def SubStringsBetweenSUZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.BetweenSUZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenSUZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenSUZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

	  #---------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SUZZ/EXTENDED  #
	#=====================================================================#

	def BetweenSUZZCS(p1, p2, pCaseSensitive)
		acBetween = This.BetweenSCSQ(p1, p2, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			aSections = This.FindBetweenAsSectionsCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], aSections ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenSUZZ(p1, p2)
		return This.BetweenSUZZCS(p1, p2, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- SUZZ/EXTENDED  #
	#==============================================================#

	def SubStringsBetweenSUZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)
		return This.BetweenSUZZCS(pcSubStr1, pcSubStr2, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenSUZZ(pcSubStr1, pcSubStr2)
		return This.SubStringsBetweenSUZZCS(pcSubStr1, pcSubStr2, :CaseSensitive = TRUE)

	  #---------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDUZ/EXTENDED  #
	#=====================================================================#

	def BetweenSDUZCS(p1, p2, pnStartingAt, pCaseSensitive)
		acBetween = This.BetweenSDCSQ(p1, p2, pnStartingAt, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			anPos = This.FindSubStringBetweenCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], anPos ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenSDUZ(p1, p2)
		return This.BetweenSDUZCS(p1, p2, pnStartingAt, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- SDUZ/EXTENDED  #
	#==============================================================#

	def SubStringsBetweenSDUZCS(pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		return This.BetweenSDUZCS(pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenSDUZ(pcSubStr1, pcSubStr2, pnStartingAt)
		return This.SubStringsBetweenSDUZCS(pcSubStr1, pcSubStr2, pnStartingAt, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDUZZ/EXTENDED  #
	#======================================================================#

	def BetweenSDUZZCS(p1, p2, pnStartingAt, pCaseSensitive)
		acBetween = This.BetweenSCSQ(p1, p2, pnStartingAt, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			aSections = This.FindBetweenAsSectionsCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], aSections ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenSDUZZ(p1, p2, pnStartingAt)
		return This.BetweenSDUZZCS(p1, p2, pnStartingAt, :CaseSensitive = TRUE)

	  #---------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- SDUZZ/EXTENDED  #
	#===============================================================#

	def SubStringsBetweenSDUZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)
		return This.BetweenSDUZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenSDUZZ(pcSubStr1, pcSubStr2, pnStartingAt)
		return This.SubStringsBetweenSDUZZCS(pcSubStr1, pcSubStr2, pnStartingAt, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDIBUZ/EXTENDED  #
	#=======================================================================#

	def BetweenSDIBUZCS(p1, p2, pnStartingAt, pcDirection, pCaseSensitive)
		acBetween = This.BetweenSDIBCSQ(p1, p2, pnStartingAt, pcDirection, pcCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			anPos = This.FindSubStringBetweenCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], anPos ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenSDIBUZ(p1, p2)
		return This.BetweenSDIBUZCS(p1, p2, pnStartingAt, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- SDIBUZ/EXTENDED  #
	#================================================================#

	def SubStringsBetweenSDIBUZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, pCaseSensitive)
		return This.BetweenSDIBUZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenSDIBUZ(pcSubStr1, pcSubStr2, pcDirection, pnStartingAt)
		return This.SubStringsBetweenSDIBUZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

	  #------------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDIBUZZ/EXTENDED  #
	#========================================================================#

	def BetweenSDIBUZZCS(p1, p2, pnStartingAt, pcDirection, pCaseSensitive)
		acBetween = This.BetweenSDCSQ(p1, p2, pnStartingAt, pcDirection, pCaseSensitive).DuplicatesRemoved()
		nLen = len(acBetween)
	
		aResult = []
		for i = 1 to nLen
			aSections = This.FindBetweenAsSectionsCS(acBetween[i], p1, p2, pCaseSensitive)
			aResult + [ acBetween[i], aSections ]
		next i
	
		return aResult

	#-- WITHOUT CASESENSITIVITY

	def BetweenSDIBUZZ(p1, p2, pnStartingAt, pcDirection)
		return This.BetweenSDIBUZZCS(p1, p2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO GIVEN SUBSTRINGS -- SDIBUZZ/EXTENDED  #
	#=================================================================#

	def SubStringsBetweenSDIBUZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirectionpCaseSensitive)
		return This.BetweenSDIBUZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def SubStringsBetweenSDIBUZZ(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection)
		return This.SubStringsBetweenSDIBUZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

#---------------------------

# TODO (future): Add ..CR() to update functions (CR --> Check Return)
#--> Cheks if the function has really made its jobs (returns TRUE or FALSE)

# TODO (future): Add ..XP() to explain what the function does

#---------------------------

	  #-------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SZ/EXTENDED  #
	#===================================================================#

	def BetweenSZCS(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
	
		aSections = This.FindAnyBetweenAsSectionsSCS(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		acSubStrings = This.Sections(aSections)
		anPositions = QR(aSections, :stzListOfPairs).FirstItems()
		
		aResult = Association([ acSubStrings, anPositions ])

		return aResult

		def BetweenSCSZ(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.BetweenSZCS(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def BetweenSZ(pcSubStr1, pcSubStr2, pnStartingAt)
		return This.BetweenSZCS(pcSubStr1, pcSubStr2, pnStartingAt, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SZZ/EXTENDED  #
	#====================================================================#

	def BetweenSZZCS(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

		aSections = This.FindAnyBetweenAsSectionsSCS(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
		acSubStrings = This.Sections(aSections)
		
		aResult = Association([ acSubStrings, aSections ])

		return aResult

		def BetweenSCSZZ(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)
			return This.BetweenSZZCS(pcBound1, pcBound2, pnStartingAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def BetweenSZZ(pcSubStr1, pcSubStr2, pnStartingAt)
		return This.BetweenSZZCS(pcSubStr1, pcSubStr2, pnStartingAt, :CaseSensitive = TRUE)

	  #--------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDZ/EXTENDED  #
	#====================================================================#

	def BetweenSDZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
	
		aSections = This.FindAnyBetweenAsSectionsSDCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		acSubStrings = This.Sections(aSections)
		anPositions = QR(aSections, :stzListOfPairs).FirstItems()
		
		aResult = Association([ acSubStrings, anPositions ])

		return aResult

		def BetweenSDCSZ(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.BetweenSDZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def BetweenSDZ(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection)
		return This.BetweenSDZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

	  #---------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDZZ/EXTENDED  #
	#=====================================================================#

	def BetweenSDZZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		aSections = This.FindAnyBetweenAsSectionsSDCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		acSubStrings = This.Sections(aSections)
		
		aResult = Association([ acSubStrings, aSections ])

		return aResult

		def BetweenSDCSZZ(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.BetweenSDZZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def BetweenSDZZ(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection)
		return This.BetweenSDZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

	  #----------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDIBZ/EXTENDED  #
	#======================================================================#

	def BetweenSDIBZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
	
		aSections = This.FindAnyBetweenAsSectionsSDIBCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		acSubStrings = This.Sections(aSections)
		anPositions = QR(aSections, :stzListOfPairs).FirstItems()
		
		aResult = Association([ acSubStrings, anPositions ])

		return aResult

		def BetweenSDIBCSZ(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.BetweenSDIBZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)


	#-- WITHOUT CASESENSITIVE

	def BetweenSDIBZ(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection)
		return This.BetweenSDIBZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)

	  #-----------------------------------------------------------------------#
	 #  SUBSTRING(S) BETWEEN TWO POSITIONS OR SUBSTRINGS -- SDIBZZ/EXTENDED  #
	#=======================================================================#

	def BetweenSDIBZZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

		aSections = This.FindAnyBetweenAsSectionsSDIBCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
		acSubStrings = This.Sections(aSections)
		
		aResult = Association([ acSubStrings, aSections ])

		return aResult

		def BetweenSDIBCSZZ(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)
			return This.BetweenSDIBZZCS(pcBound1, pcBound2, pnStartingAt, pcDirection, pCaseSensitive)

	#-- WITHOUT CASESENSITIVE

	def BetweenSDIBZZ(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection)
		return This.BetweenSDIBZZCS(pcSubStr1, pcSubStr2, pnStartingAt, pcDirection, :CaseSensitive = TRUE)
