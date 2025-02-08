# File: stzregexuter.ring
# Description: Reactive Regex Computer System for Softanza Library

func rxuter()
	return new stzRegexuter

	func rxu()
		return new stzRegexuter

class stzRegexuter

	aTriggers = []		# Pairs of [cTriggerName, cRegexOatterns]
	aCodesPerTrigger = []	# Pairs of [cTriggerName, cCodeToExecute]
	aState = []		# [ [ cTriggerName, [ originalValue, computedValue ] ], ... ]

	aLastResults = []	# List of last computed values after Prcess() is used
	aLastMatches = []	# Idem for matches

	  #------------------------------#
	 #  INITILAIZING THE REGEXUTER  #
	#------------------------------#

	def init()
		# Empty init

	  #-------------------------#
	 #  ADDING REGEX TRIGGERS  #
	#-------------------------#

	def AddTrigger(aTrigger)

		if isString(aTrigger)
			if TriggerNameExists(aTrigger)
				StzRaise("Can't proceed! The trigger name you specified already exists.")
			ok

			aTriggers + [ aTrigger, pat(aTrigger) ]
			return
		ok

		if NOT ( isList(aTrigger) and len(aTrigger) = 2 and
		   isString(aTrigger[1]) and isString(aTrigger[2]) )
			StzRaise("Incorrect param! aTrigger must be a pair of strings.")
		ok

		if TriggerNameExists(aTrigger[1])
			StzRaise("Can't proceed! The trigger name you specified already exists.")
		ok

		# Store trigger with its name
		aTriggers + aTrigger

		#< @FunctionAlternativeForms

		def Trigger(aTrigger)
			This.AddTrigger(aTrigger)
	
			def @T(aTrigger)
				This.AddTrigger(aTrigger)

		#>

	
	def TriggerNameExists(cName)
		nLen = len(aTriggers)
		bResult = FALSE

		for i = 1 to nLen
			if aTriggers[i][1] = cName
				bResult = FALSE
				exit
			ok
		next

		return bResult

		def TriggerExists(cName)
			return This.TriggerNameExists(cName)

	  #---------------------------------------#
	 #  ADDING CODES TO COMPUTE PER TRIGGER  #
	#---------------------------------------#

	def AddCode(cTriggerName, cCode)
		if isList(cTriggerName) and StzListQ(cTriggerName).IsWhenOrIfOrForNamedParam()
			cTriggerName = cTriggerName[2]
		ok

		if isList(cCode) and StzListQ(cCode).IsDoNamedParam()
			cCode = cCode[2]
		ok

		# Validate code contains @value

		oStzStr = new stzString(cCode)
		if NOT oStzStr.ContainsCS("@value", :CaseSensitive = FALSE)
			StzRaise("Invalid computation! cCode Must contain @value keyword.")
		ok

		# Clean code string

		cCode = oStzStr.TrimQ().TheseBoundsRemoved("{", "}")

		# Store the code (for future use)

		aCodesPerTrigger + [cTriggerName, cCode]

		#< @FunctionAlternativeForms

		def AddComputation(cTriggerName, cCode)
			This.AddCode(cTriggerName, cCode)

		def @c(cTriggerName, cCode)
			This.AddCode(cTriggerName, cCode)

		def AddScript(cTriggerName, cCode)
			This.AddCode(cTriggerName, cCode)

		#>

	  #-----------------------------------------------------------#
	 #  EXECUTING THE TRiGGERED COMPUTATIONS FOR A GIVEN STRING  #
	#-----------------------------------------------------------#

	def Process(cText)

		if NOT isString(cText)
			StzRaise("Invalid input! Expected text to analyze.")
		ok

		if trim(cText) = ""
			return [ :matches = [], :results = [] ]
		ok
		
		# Check each registered trigger against the input

		nLenTriggers = len(aTriggers)

		for i = 1 to nLenTriggers

			cTriggerName = aTriggers[i][1]
			cPattern = aTriggers[i][2]
			
			# Find matches for this trigger

			aMatches = AllMatches(cText, cPattern)
			
			# If trigger fired (has matches), add all matches,
			# while Computing results for each match

			nLenMatches = len(aMatches)

			if nLenMatches > 0

				for j = 1 to nLenMatches

					# Add the match

					aLastMatches + aMatches[j]

					# Execute the computation of that match
 
					compResult = executeComputation(aMatches[j], cTriggerName)
					aLastResults + compResult
					
					# Track state changes

					if compResult != aMatches[j]
						aState + [lower(cTriggerName), [aMatches[j], compResult]]
					ok

				next
			ok
		next

		#< @FunctionAlternativeForm

		def Compute(cText)
			This.Process(cText)

		#>

	def Results()
		return aLastResults

		def Result()
			return This.Result()

	def Matches()
		return aLastMatches

		def MatchedValues()
			return This.Matches()

	def ResultsXT()
		return Association([ This.Results(), This.Matches() ])

		def ResultXT()
			return This.ResultsXT()

		def ResultsAndMatches()
			return This.ResultsXT()

		def ResultsAndTheirMatches()
			return This.ResultsXT()

	def MatchesXT()
		return Association([ This.Matches(), This.Results() ])

		def MatchedValuesXT()
			return This.MatchesXT()

		def MatchesAndResults()
			return This.MatchesXT()

		def MatchesAndTheirResults()
			return This.MatchesXT()

	  #-----------------------------------------------------#
	 #  GETTING THE CONTENT OF THE STATE OF THE REGEXUTER  #
	#-----------------------------------------------------#

	def State()
		return aState

	private

	def executeComputation(cMatchedValue, cTriggerName)

		if NOT (isString(cMatchedValue) and isString(cTriggerName))
			StzRaise("Invalid types! Expected string values.")
		ok

		cPattern = ""
		cComputation = ""
		
		# Find computation for this trigger

		nLen = len(aCodesPerTrigger)

		for i = 1 to nLen
			if aCodesPerTrigger[i][1] = cTriggerName
				cCode = aCodesPerTrigger[i][2]
				exit
			ok
		next

		if trim(cCode) = ""
			return cMatchedValue
		ok
		
		try
			@value = cMatchedValue
			eval(cCode)
			return @value
		catch
			return cMatchedValue
		done
