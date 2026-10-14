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

# Matches regular-expression triggers in a text, runs a piece of code on each match and keeps a log of what changed.
#
# Register triggers (a name and a regular expression), attach code to them that works on the match
# held in @value, then Process a text. Matches, Triggers, Positions and Results describe the last
# run, trigger by trigger, and State is a log of the matches whose computed value differs, with
# timestamp, order, pattern, position, dependson and affects. Build one with StzRxuter(), rxuter()
# or StzRxu(). Positions count characters and the Hebrew class [א-ת] and emoji patterns work. Found
# today: GetDependencyChain overflows the stack once the log holds an entry; Positions gives the
# first occurrence for every copy of a repeated match; only the first code attached to a trigger
# runs; and a code that raises is silently ignored.
#
#   receiver   o1 = StzRxuter()
#   example    o1.AddTrigger([ "num", "[0-9]+" ])
#              o1.AddCode("num", "@value = @value * 2")
#              o1.Process("abc 12 de 5")
#              ? @@( o1.Matches() )
#              #--> [ "12", "5" ]
#              ? @@( o1.Results() )
#              #--> [ 24, 10 ]
#              ? @@( o1.Positions() )
#              #--> [ 5, 11 ]
#              o2 = StzRxuter()
#              o2.AddTrigger([ "he", "[א-ת]+" ])
#              o2.Process("שלום 12 עולם")
#              ? @@( o2.Positions() )
#              #--> [ 1, 9 ]
#   see        stzRegex, stzListexuter, stzString
class stzRegexuter from stzObject

	# Core data structures
	@aTriggers = []		# Pairs of [cTriggerName, cRegexPattern]
	@aCodesPerTrigger = []	# Pairs of [cTriggerName, cCodeToExecute]
	
	# State management

	@aState = []			# List of state entries as hashlists
	@aActiveComputations = []	# Track currently active computations
	
	# Results tracking

	@aLastTriggers = []
	@aLastMatches = []
	@aLastPositions = []
	@aLastResults = []
	@aLastTextualOrder = []

	# Performance tracking

	@nProcessStartTime = 0
	@nLastProcessDuration = 0

	# Builds an empty reactive text computer with no trigger and no code.
	#
	#   returns    nothing; the object is built
	#   note       build one with StzRxuter(), rxuter() or StzRxu()
	#   see        AddTrigger, Process
	def init()
		# Do nothing

	#------------------#
	# Trigger Methods  #
	#------------------#

	# Registers a trigger: a name paired with a regular expression, or the name of a library pattern.
	#
	#   aTrigger   a pair [ name, regular expression ]
	#   returns    nothing; the trigger is added
	#   note       [ "num", "[0-9]+" ] makes a trigger called num that matches digit runs
	#   warning    a trigger name already registered, compared with case, raises an error
	#   see        AddCode, Process
	def AddTrigger(aTrigger)
		if isString(aTrigger)
			if TriggerNameExists(aTrigger)
				StzRaise("Can't proceed! Trigger name already exists: " + aTrigger)
			ok
			@aTriggers + [ aTrigger, pat(aTrigger) ]
			return
		ok

		if NOT (isList(aTrigger) and len(aTrigger) = 2 and 
		        isString(aTrigger[1]) and isString(aTrigger[2]))
			StzRaise("Incorrect param! aTrigger must be a pair of strings [name, pattern]")
		ok

		if TriggerNameExists(aTrigger[1])
			StzRaise("Can't proceed! Trigger name already exists: " + aTrigger[1])
		ok

		@aTriggers + aTrigger

		# Registers a trigger: a name paired with a regular expression.
		#
		#   aTrigger   a pair [ name, regular expression ], or the name of a library pattern
		#   returns    nothing; the trigger is added
		#   note       the same call as AddTrigger
		#   warning    same limits as AddTrigger
		#   see        AddTrigger
		def Trigger(aTrigger)
			This.AddTrigger(aTrigger)

	# TRUE if a trigger of that name is registered.
	#
	#   cName      the trigger name
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       the name is compared with case: NUM is not found when num is registered
	#   see        AddTrigger
	def TriggerNameExists(cName)
		_nTriggers2Len_ = len(@aTriggers)
		for _iLoopTriggers2_ = 1 to _nTriggers2Len_
			trigger = @aTriggers[_iLoopTriggers2_]
			if trigger[1] = cName
				return 1
			ok
		next
		return 0

	#---------------#
	# Code Methods  #
	#---------------#

	# Attaches a piece of Ring code to a trigger, to compute a new value from each match held in @value.
	#
	#   _cTriggerName_   the name of a registered trigger, or a pair [ :when, name ]
	#   _cCode_          the code as text, or a pair [ :do, code ], which must mention @value and
	#                    may be wrapped in braces
	#   returns          nothing; the code is stored
	#   note             AddComputation and @C are the same call; @value = @value * 2 doubles each
	#                    number matched
	#   warning          only the FIRST code attached to a trigger runs; a second AddCode for the
	#                    same trigger is stored and never used; an unknown trigger, a code without
	#                    @value and a code that is not text raise an error; a code that raises when
	#                    it runs leaves the match unchanged and silent
	#   see              AddTrigger, Process
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
			_cCode_ = StzMid(_cCode_, 2, StzLen(_cCode_)-2)
		ok

		@aCodesPerTrigger + [_cTriggerName_, _cCode_]

		# Attaches a piece of Ring code to a trigger, to compute a new value from each match held in @value.
		#
		#   _cTriggerName_   the name of a registered trigger
		#   _cCode_          the code as text, which must mention @value
		#   returns          nothing; the code is stored
		#   note             the same call as AddCode
		#   warning          same limits as AddCode
		#   see              AddCode
		def AddComputation(_cTriggerName_, _cCode_)
			This.AddCode(_cTriggerName_, _cCode_)

		# Attaches a piece of Ring code to a trigger, to compute a new value from each match held in @value.
		#
		#   _cTriggerName_   the name of a registered trigger
		#   _cCode_          the code as text, which must mention @value
		#   returns          nothing; the code is stored
		#   note             the same call as AddCode
		#   warning          same limits as AddCode
		#   see              AddCode
		def @C(_cTriggerName_, _cCode_)
			This.AddCode(_cTriggerName_, _cCode_)

	#------------------#
	# Process Methods  #
	#------------------#

	# Matches every trigger against a text, runs the attached code on each match and records what changed.
	#
	#   cText      the text to analyse
	#   returns    nothing; read the outcome with Matches, Results, Positions and State
	#   note       Compute is the same call; abc 12 de 5 with the triggers num and word gives the
	#              matches 12, 5, abc, de
	#   warning    the matches come trigger by trigger, not in text order; a blank text clears the
	#              state log but not the last matches; the log keeps growing across calls until
	#              ResetState; the position of a match repeated in the text is always that of its
	#              first occurrence
	#   see        Matches, Results, State
	def Process(cText)
		if NOT isString(cText)
			StzRaise("Invalid input! Expected text to analyze.")
		ok

		if trim(cText) = ""
			ResetState()
			return
		ok

		# Reset tracking for this process run
		@aLastMatches = []
		@aLastResults = []
		@aLastTriggers = []
		@aLastPositions = []  # NEW: Reset positions
		@aActiveComputations = []

		_nTriggers1Len_ = len(@aTriggers)
		for _iLoopTriggers1_ = 1 to _nTriggers1Len_
			trigger = @aTriggers[_iLoopTriggers1_]
			_cTriggerName_ = trigger[1]
			_cPattern_ = trigger[2]
			
			# Use AllMatches() instead of regex_getmatches()
			_oRegex_ = new stzRegex(_cPattern_)
			_oStzStr_ = new stzString(cText)

			_aMatches_ = AllMatches(cText, _cPattern_)
			
			if len(_aMatches_) > 0
				@aActiveComputations + _cTriggerName_

				_nMatchesLen_ = len(_aMatches_)
				for i = 1 to _nMatchesLen_
					_match_ = _aMatches_[i]
					# Get position using MatchAt()
					_nPos_ = _oStzStr_.FindFirst(_match_)

					@aLastMatches + _match_
					@aLastTriggers + _cTriggerName_
					@aLastPositions + _nPos_  # NEW: Store position

					# Execute computation and track result
					_computedValue_ = executeComputation(_match_, _cTriggerName_)
					@aLastResults + _computedValue_

					# Record state change if value was modified
					if _computedValue_ != _match_
						AddStateEntry(_cTriggerName_, _cPattern_, _match_, 
						            _computedValue_, _nPos_)
					ok
				next

				del(@aActiveComputations, len(@aActiveComputations))
			ok
		next


		# Matches every trigger against a text, runs the attached code on each match and records what changed.
		#
		#   cText      the text to analyse
		#   returns    nothing; read the outcome with Matches and Results
		#   note       the same call as Process
		#   warning    same limits as Process
		#   see        Process
		def Compute(cText)
			This.Process(cText)

	#-----------------#
	# State Methods   #
	#-----------------#

	# Empties the log of state entries and the list of active computations.
	#
	#   returns    nothing
	#   warning    it does not clear Matches, Triggers, Positions or Results of the last run
	#   see        State, Process
	def ResetState()
		@aState = []
		@aActiveComputations = []

	# Appends one entry to the state log, recording that a match was turned into a computed value.
	#
	#   _cTriggerName_    the trigger that matched
	#   _cPattern_        its pattern
	#   cMatchedValue     the text matched
	#   _computedValue_   the value the code produced
	#   nPosition         the 1-based position of the match
	#   returns           nothing; the log grows by one
	#   note              Process calls it for every match whose computed value differs from the
	#                     match; the entry keeps timestamp, computationorder, triggername, pattern,
	#                     matchedvalue, computedvalue, position, dependson and affects
	#   see               State, StateByComputationOrder
	def AddStateEntry(_cTriggerName_, _cPattern_, cMatchedValue, _computedValue_, nPosition)
		# Create state entry hashlist
		_entry_ = [
			:timeStamp = date() + " " + time(),
			:computationOrder = len(@aState) + 1,

			:triggerName = _cTriggerName_,
			:pattern = _cPattern_,
			:matchedValue = cMatchedValue,
			:computedValue = _computedValue_,
			:position = nPosition,

			:dependsOn = @aActiveComputations,
			:affects = getAffectedTriggers(_cTriggerName_)
		]

		@aState + _entry_

	# Returns the names of the triggers whose log entries depend on a given trigger.
	#
	#   _cTriggerName_   the trigger whose dependants are wanted
	#   returns          a list of trigger names, repeats removed
	#   note             num after a run that changed numbers gives [ "num" ]; an unknown name gives
	#                    [ ]
	#   warning          because an entry always depends on its own trigger, the answer for a
	#                    trigger that has logged an entry is that trigger itself
	#   see              GetDependencyChain, State
	def getAffectedTriggers(_cTriggerName_)
		_aAffected_ = []
		
		# Look through state history for triggers affected by this one
		_nState2Len_ = len(@aState)
		for _iLoopState2_ = 1 to _nState2Len_
			_entry_ = @aState[_iLoopState2_]
			if find(_entry_[:dependsOn], _cTriggerName_) > 0
				_aAffected_ + _entry_[:triggerName] 
			ok
		next

		return unique(_aAffected_)

	# Returns the state log sorted by the position of the match in the text, ascending.
	#
	#   returns    a list of entries, each a list of [ key, value ] pairs
	#   note       the log is not changed; entries at the same position keep their order
	#   see        StateByComputationOrder, State
	def StateByPosition()

		# State entries sorted by matched position (ascending)

		_aSorted_ = []
		_nLen_ = len(@aState)

		for _i_ = 1 to _nLen_
			_aSorted_ + @aState[_i_]
		next

		for _i_ = 2 to _nLen_
			_e_ = _aSorted_[_i_]
			_j_ = _i_ - 1

			while _j_ >= 1
				if _aSorted_[_j_][:position] > _e_[:position]
					_aSorted_[_j_ + 1] = _aSorted_[_j_]
					_j_ -= 1
				else
					exit
				ok
			end

			_aSorted_[_j_ + 1] = _e_
		next

		return _aSorted_

	# Returns a copy of the state log in the order the computations ran.
	#
	#   returns    a list of entries, each a list of [ key, value ] pairs
	#   see        StateByPosition, State
	def StateByComputationOrder()

		# Entries are recorded in computation order; return a copy

		_aSorted_ = []
		_nLen_ = len(@aState)

		for _i_ = 1 to _nLen_
			_aSorted_ + @aState[_i_]
		next

		return _aSorted_

	# Raises a stack overflow today instead of returning the triggers a trigger depends on.
	#
	#   _cTriggerName_   the trigger whose chain is wanted
	#   returns          nothing; the call raises R4 Stack Overflow
	#   note             an unknown trigger or an empty log gives [ ]
	#   warning          every log entry lists its own trigger in dependson, so the method calls
	#                    itself on that same trigger without end; confirmed with the trigger num and
	#                    the trigger d
	#   see              getAffectedTriggers
	def GetDependencyChain(_cTriggerName_)
		_aChain_ = []
		
		_nState1Len_ = len(@aState)
		for _iLoopState1_ = 1 to _nState1Len_
			_entry_ = @aState[_iLoopState1_]
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

	# Returns the state log: one entry per match whose computed value differs from the match.
	#
	#   returns    a list of entries, each a list of [ key, value ] pairs; [ ] after ResetState
	#   note       a match left unchanged by its code is not logged
	#   see        StateByPosition, ResetState
	def State()
		return @aState

	# Returns the trigger name of each match of the last run.
	#
	#   returns    a list of texts, parallel to Matches
	#   note       num, num, word, word for abc 12 de 5
	#   see        Matches, Results
	def Triggers()
		return @aLastTriggers

	# Returns the text of each match of the last run, trigger by trigger.
	#
	#   returns    a list of texts
	#   note       abc 12 de 5 gives 12, 5, abc, de
	#   see        Results, Positions
	def Matches() 
		return @aLastMatches

	# Returns the 1-based position of each match of the last run, counted in characters.
	#
	#   returns    a list of numbers, parallel to Matches
	#   note       works across scripts: in the text שלום 12 مرحبا 😀😀 עולם the Hebrew words are at 1
	#              and 18, the Arabic one at 9 and the emoji run at 15
	#   warning    the position is that of the FIRST occurrence of the matched text, so a text
	#              matched three times reports the same position three times (7 in a 7 b 7 c 7 gives
	#              3, 3, 3)
	#   see        Matches
	def Positions()
		return @aLastPositions

	# Returns the value computed for each match of the last run.
	#
	#   returns    a list of values, parallel to Matches
	#   note       a number result stays a number: @value * 2 on 12 gives 24; with no code the
	#              result is the match itself
	#   see        Matches, MatchesAndTheirResults
	def Results()
		return @aLastResults

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

		# Returns each match paired with the value computed for it.
		#
		#   returns    a list of [ match, result ] pairs
		#   note       MatchesXT, MatchedValuesXT and MatchesAndResults are the same call;
		#              ResultsXT, ResultsAndMatches and ResultsAndTheirMatches give the pairs the
		#              other way round
		#   see        Results, Matches
		def MatchesAndTheirResults()
			return This.MatchesXT()

	#------------------#
	# Private Methods  #
	#------------------#

	private

	# Runs the code attached to a trigger on one matched text and returns the value produced.
	#
	#   cMatchedValue    the matched text
	#   _cTriggerName_   the trigger whose code is run
	#   returns          the value of @value after the code; the match itself when the trigger has
	#                    no code or the code raises
	#   note             it is called by Process for every match
	#   warning          private: calling it from outside raises R26
	#   see              Process, AddCode
	def executeComputation(cMatchedValue, _cTriggerName_)
		if NOT (isString(cMatchedValue) and isString(_cTriggerName_))
			return cMatchedValue
		ok

		# Find computation code for this trigger
		_cCode_ = ""
		_nCodesPerTrigger1Len_ = len(@aCodesPerTrigger)
		for _iLoopCodesPerTrigger1_ = 1 to _nCodesPerTrigger1Len_
			pair = @aCodesPerTrigger[_iLoopCodesPerTrigger1_]
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
