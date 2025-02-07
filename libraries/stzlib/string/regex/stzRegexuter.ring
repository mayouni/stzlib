# File: stzregexuter.ring
# Description: Reactive Regex Computer System for Softanza Library

func rxuter
	return new stzRegexuter

func rxu
	return new stzRegexuter

class stzRegexuter

	aTriggers = []		# Pairs of [name, pattern]
	aComputations = []	# Pairs of [name, computation]
	aState = []		# [[trigger_name, [original, computed]], ...]

	  #------------------------------#
	 #  INITILAIZING THE REGEXUTER  #
	#------------------------------#

	def init()
		# Empty init - triggers and computations added dynamically

	  #-------------------------#
	 #  ADDING REGEX TRIGGERS  #
	#-------------------------#

	def RegisterTrigger(aTrigger)

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

		def AddTrigger(aTrigger)
			This.RegisterTrigger(aTrigger)
	
			def Trigger(aTrigger)
				This.RegisterTrigger(aTrigger)
	
			def @t(aTrigger)
				This.RegisterTrigger(aTrigger)

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

	  #-------------------------------------#
	 #  DEFINING COMPUTATIONS PER TRIGGER  #
	#-------------------------------------#

	def AddComputationalOp(cTriggerName, cComputation)
		if isList(cTriggerName) and StzListQ(cTriggerName).IsWhenOrIfOrForNamedParam()
			cTriggerName = cTriggerName[2]
		ok

		if isList(cComputation) and StzListQ(cComputation).IsDoNamedParam()
			cComputation = cComputation[2]
		ok

		# Validate computation contains @value

		oStzStr = new stzString(cComputation)
		if NOT oStzStr.ContainsCS("@value", :CaseSensitive = FALSE)
			StzRaise("Invalid computation! Must contain @value keyword.")
		ok

		# Clean computation string

		cComputation = oStzStr.TrimQ().TheseBoundsRemoved("{", "}")

		# Store the computatio (for future use)

		aComputations + [cTriggerName, cComputation]

		#< @FunctionAlternativeForms

		def AddComputation(cTrigger, cComputation)
			This.AddComputationalOp(cTrigger, cComputation)

		def @c(cTrigger, cComputation)
			This.AddComputationalOp(cTrigger, cComputation)

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
		
		aResult = [
			:matches = [],
			:results = []
		]

		# Check each registered trigger against the input

		nLenTriggers = len(aTriggers)

		for i = 1 to nLenTriggers

			cTriggerName = aTriggers[i][1]
			cPattern = aTriggers[i][2]
			
			# Find matches for this trigger

			aMatches = AllMatches(cText, cPattern)
			
			# If trigger fired (has matches)

			nLenMatches = len(aMatches)

			if nLenMatches > 0

				# Add all matches

				aResult[:matches] + aMatches
				
				# Compute results for each match

				for j = 1 to nLenMatches

					aCompResult = executeComputation(aMatches[j], cTriggerName)
					aResult[:results] + aCompResult[1]
					
					# Track state changes

					if aCompResult[1] != aMatches[j]
						aState + [lower(cTriggerName), [aMatches[j], aCompResult[1]]]
					ok
				next
			ok
		next
		
		return aResult

		#< @FunctionAlternativeForm

		def Compute(cText)
			This.Process(cText)

		#>

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

		nLen = len(aComputations)

		for i = 1 to nLen
			if aComputations[i][1] = cTriggerName
				cComputation = aComputations[i][2]
				exit
			ok
		next

		if trim(cComputation) = ""
			return [cMatchedValue]
		ok
		
		try
			@value = cMatchedValue
			eval(cComputation)
			return [@value]
		catch
			return [cMatchedValue]
		done
