# File: stzregexuter.ring
# Description: Reactive Regex Computer System for Softanza Library

func StzRxuter()
	return new stzRegexuter

	func rxuter()
		return StzRxuter()

	func StzRxu()
		return StzRxuter()

	func rxu()
		return StzRxuter()

class stzRegexuter from stzObject

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
		_nTriggers2Len_ = len(aTriggers)
		for _iLoopTriggers2_ = 1 to _nTriggers2Len_
			trigger = aTriggers[_iLoopTriggers2_]
			if trigger[1] = cName
				return TRUE
			ok
		next
		return FALSE

	#---------------#
	# Code Methods  #
	#---------------#

	def AddCode(_cTriggerName_, _cCode_)
		if isList(_cTriggerName_) and IsWhenOrIfOrForNamedParamList(_cTriggerName_)
			_cTriggerName_ = _cTriggerName_[2]
		ok

		if isList(_cCode_) and IsDoNamedParamList(_cCode_)
			_cCode_ = _cCode_[2]
		ok

		if NOT TriggerNameExists(_cTriggerName_)
			StzRaise("Can't proceed! Trigger does not exist: " + _cTriggerName_)
		ok

		if NOT isString(_cCode_)
			StzRaise("Invalid code type! Expected string.")
		ok

		# Verify code contains @value
		if NOT StringContains(_cCode_, "@value")
			StzRaise("Invalid computation! Code must contain @value keyword.")
		ok

		# Clean code
		_cCode_ = trim(_cCode_)
		if StzLeft(_cCode_, 1) = "{" and StzRight(_cCode_, 1) = "}"
			_cCode_ = StzMid(_cCode_, 2, len(_cCode_)-2)
		ok

		aCodesPerTrigger + [_cTriggerName_, _cCode_]

		def AddComputation(_cTriggerName_, _cCode_)
			This.AddCode(_cTriggerName_, _cCode_)

		def @C(_cTriggerName_, _cCode_)
			This.AddCode(_cTriggerName_, _cCode_)

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

		_nTriggers1Len_ = len(aTriggers)
		for _iLoopTriggers1_ = 1 to _nTriggers1Len_
			trigger = aTriggers[_iLoopTriggers1_]
			_cTriggerName_ = trigger[1]
			_cPattern_ = trigger[2]
			
			# Use AllMatches() instead of regex_getmatches()
			_oRegex_ = new stzRegex(_cPattern_)
			_oStzStr_ = new stzString(cText)

			_aMatches_ = AllMatches(cText, _cPattern_)
			
			if len(_aMatches_) > 0
				aActiveComputations + _cTriggerName_

				_nMatchesLen_ = len(_aMatches_)
				for i = 1 to _nMatchesLen_
					_match_ = _aMatches_[i]
					# Get position using MatchAt()
					_nPos_ = _oStzStr_.FindFirst(_match_)

					aLastMatches + _match_
					aLastTriggers + _cTriggerName_
					aLastPositions + _nPos_  # NEW: Store position

					# Execute computation and track result
					_computedValue_ = executeComputation(_match_, _cTriggerName_)
					aLastResults + _computedValue_

					# Record state change if value was modified
					if _computedValue_ != _match_
						AddStateEntry(_cTriggerName_, _cPattern_, _match_, 
						            _computedValue_, _nPos_)
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

	def AddStateEntry(_cTriggerName_, _cPattern_, cMatchedValue, _computedValue_, nPosition)
		# Create state entry hashlist
		_entry_ = [
			:timeStamp = date() + " " + time(),
			:computationOrder = len(aState) + 1,

			:triggerName = _cTriggerName_,
			:pattern = _cPattern_,
			:matchedValue = cMatchedValue,
			:computedValue = _computedValue_,
			:position = nPosition,

			:dependsOn = aActiveComputations,
			:affects = getAffectedTriggers(_cTriggerName_)
		]

		aState + _entry_

	def getAffectedTriggers(_cTriggerName_)
		_aAffected_ = []
		
		# Look through state history for triggers affected by this one
		_nState2Len_ = len(aState)
		for _iLoopState2_ = 1 to _nState2Len_
			_entry_ = aState[_iLoopState2_]
			if find(_entry_[:dependsOn], _cTriggerName_) > 0
				_aAffected_ + _entry_[:triggerName] 
			ok
		next

		return unique(_aAffected_)

	def StateByPosition()

		# Return state entries sorted by position
		#TODO

	def StateByComputationOrder() 
		# Return state entries sorted by computation order
		# TODO

	def GetDependencyChain(_cTriggerName_)
		_aChain_ = []
		
		_nState1Len_ = len(aState)
		for _iLoopState1_ = 1 to _nState1Len_
			_entry_ = aState[_iLoopState1_]
			if _entry_[:triggerName] = _cTriggerName_
				_aChain_ + _entry_[:dependsOn]
				
				_aEntrydependsOn1_ = _entry_[:dependsOn]
				_nEntrydependsOn1Len_ = len(_aEntrydependsOn1_)
				for _iLoopEntrydependsOn1_ = 1 to _nEntrydependsOn1Len_
					_depTrigger_ = _aEntrydependsOn1_[_iLoopEntrydependsOn1_]
					_aChain_ + This.GetDependencyChain(_depTrigger_)
				next
			ok
		next

		return unique(_aChain_)

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

	def executeComputation(cMatchedValue, _cTriggerName_)
		if NOT (isString(cMatchedValue) and isString(_cTriggerName_))
			return cMatchedValue
		ok

		# Find computation code for this trigger
		_cCode_ = ""
		_nCodesPerTrigger1Len_ = len(aCodesPerTrigger)
		for _iLoopCodesPerTrigger1_ = 1 to _nCodesPerTrigger1Len_
			pair = aCodesPerTrigger[_iLoopCodesPerTrigger1_]
			if pair[1] = _cTriggerName_
				_cCode_ = pair[2]
				exit
			ok
		next

		if trim(_cCode_) = ""
			return cMatchedValue
		ok

		try
			@value = cMatchedValue
			eval(_cCode_)
			return @value
		catch
			return cMatchedValue
		done
