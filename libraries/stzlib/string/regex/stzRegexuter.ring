# File: stzregexuter.ring
# Description: Reactive Regex Computer System for Softanza Library

func rxuter()
	return new stzRegexuter

	func rxu()
		return new stzRegexuter

class stzRegexuter

	# Core data structures
	aTriggers = []		# Pairs of [cTriggerName, cRegexPattern]
	aCodesPerTrigger = []	# Pairs of [cTriggerName, cCodeToExecute]
	
	# State management

	aState = []			# List of state entries as hashlists
	aActiveComputations = []	# Track currently active computations
	
	# Results tracking

	aLastTriggers = []
	aLastMatches = []
	aLastPositions = []
	aLastResults = []
	aLastTextualOrder = []

	# Performance tracking

	nProcessStartTime = 0
	nLastProcessDuration = 0

	def init()
		# Do nothing

	#------------------#
	# Trigger Methods  #
	#------------------#

	def AddTrigger(aTrigger)
		if isString(aTrigger)
			if TriggerNameExists(aTrigger)
				StzRaise("Can't proceed! Trigger name already exists: " + aTrigger)
			ok
			aTriggers + [ aTrigger, pat(aTrigger) ]
			return
		ok

		if NOT (isList(aTrigger) and len(aTrigger) = 2 and 
		        isString(aTrigger[1]) and isString(aTrigger[2]))
			StzRaise("Incorrect param! aTrigger must be a pair of strings [name, pattern]")
		ok

		if TriggerNameExists(aTrigger[1])
			StzRaise("Can't proceed! Trigger name already exists: " + aTrigger[1])
		ok

		aTriggers + aTrigger

		def Trigger(aTrigger)
			This.AddTrigger(aTrigger)

	def TriggerNameExists(cName)
		for trigger in aTriggers
			if trigger[1] = cName
				return TRUE
			ok
		next
		return FALSE

	#---------------#
	# Code Methods  #
	#---------------#

	def AddCode(cTriggerName, cCode)
		if isList(cTriggerName) and StzListQ(cTriggerName).IsWhenOrIfOrForNamedParam()
			cTriggerName = cTriggerName[2]
		ok

		if isList(cCode) and StzListQ(cCode).IsDoNamedParam()
			cCode = cCode[2]
		ok

		if NOT TriggerNameExists(cTriggerName)
			StzRaise("Can't proceed! Trigger does not exist: " + cTriggerName)
		ok

		if NOT isString(cCode)
			StzRaise("Invalid code type! Expected string.")
		ok

		# Verify code contains @value
		if NOT StringContains(cCode, "@value")
			StzRaise("Invalid computation! Code must contain @value keyword.")
		ok

		# Clean code
		cCode = trim(cCode)
		if left(cCode, 1) = "{" and right(cCode, 1) = "}"
			cCode = substr(cCode, 2, len(cCode)-2)
		ok

		aCodesPerTrigger + [cTriggerName, cCode]

		def AddComputation(cTriggerName, cCode)
			This.AddCode(cTriggerName, cCode)

		def @C(cTriggerName, cCode)
			This.AddCode(cTriggerName, cCode)

	#------------------#
	# Process Methods  #
	#------------------#

	def Process(cText)
		if NOT isString(cText)
			StzRaise("Invalid input! Expected text to analyze.")
		ok

		if trim(cText) = ""
			ResetState()
			return
		ok

		# Reset tracking for this process run
		aLastMatches = []
		aLastResults = []
		aLastTriggers = []
		aLastPositions = []  # NEW: Reset positions
		aActiveComputations = []

		for trigger in aTriggers
			cTriggerName = trigger[1]
			cPattern = trigger[2]
			
			# Use AllMatches() instead of regex_getmatches()
			oRegex = new stzRegex(cPattern)
			oStzStr = new stzString(cText)

			aMatches = AllMatches(cText, cPattern)
			
			if len(aMatches) > 0
				aActiveComputations + cTriggerName

				for i = 1 to len(aMatches)
					match = aMatches[i]
					# Get position using MatchAt()
					nPos = oStzStr.FindFirst(match)

					aLastMatches + match
					aLastTriggers + cTriggerName
					aLastPositions + nPos  # NEW: Store position

					# Execute computation and track result
					computedValue = executeComputation(match, cTriggerName)
					aLastResults + computedValue

					# Record state change if value was modified
					if computedValue != match
						AddStateEntry(cTriggerName, cPattern, match, 
						            computedValue, nPos)
					ok
				next

				del(aActiveComputations, len(aActiveComputations))
			ok
		next


		def Compute(cText)
			This.Process(cTex)

	#-----------------#
	# State Methods   #
	#-----------------#

	def ResetState()
		aState = []
		aActiveComputations = []

	def AddStateEntry(cTriggerName, cPattern, cMatchedValue, computedValue, nPosition)
		# Create state entry hashlist
		entry = [
			:timeStamp = date() + " " + time(),
			:computationOrder = len(aState) + 1,

			:triggerName = cTriggerName,
			:pattern = cPattern,
			:matchedValue = cMatchedValue,
			:computedValue = computedValue,
			:position = nPosition,

			:dependsOn = aActiveComputations,
			:affects = getAffectedTriggers(cTriggerName)
		]

		aState + entry

	def getAffectedTriggers(cTriggerName)
		aAffected = []
		
		# Look through state history for triggers affected by this one
		for entry in aState
			if find(entry[:dependsOn], cTriggerName) > 0
				aAffected + entry[:triggerName] 
			ok
		next

		return unique(aAffected)

	def StateByPosition()

		# Return state entries sorted by position
		#TODO

	def StateByComputationOrder() 
		# Return state entries sorted by computation order
		# TODO

	def GetDependencyChain(cTriggerName)
		aChain = []
		
		for entry in aState
			if entry[:triggerName] = cTriggerName
				aChain + entry[:dependsOn]
				
				for depTrigger in entry[:dependsOn]
					aChain + This.GetDependencyChain(depTrigger)
				next
			ok
		next

		return unique(aChain)

	#------------------#
	# Result Methods   #
	#------------------#

	def State()
		return aState

	def Triggers()
		return aLastTriggers

	def Matches() 
		return aLastMatches

	def Positions()
		return aLastPositions

	def Results()
		return aLastResults

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

	#------------------#
	# Private Methods  #
	#------------------#

	private

	def executeComputation(cMatchedValue, cTriggerName)
		if NOT (isString(cMatchedValue) and isString(cTriggerName))
			return cMatchedValue
		ok

		# Find computation code for this trigger
		cCode = ""
		for pair in aCodesPerTrigger
			if pair[1] = cTriggerName
				cCode = pair[2]
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
