#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZVALIDATOR                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Data validation class backed by the         #
#                  Softanza Engine (stz_validator module).      #
#                  Define rules, check values, track violations.#
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

# Rule kinds (matching engine RuleKind enum)
$STZ_RULE_REQUIRED   = 0
$STZ_RULE_MIN_VALUE  = 1
$STZ_RULE_MAX_VALUE  = 2
$STZ_RULE_MIN_LENGTH = 3
$STZ_RULE_MAX_LENGTH = 4
$STZ_RULE_PATTERN    = 5
$STZ_RULE_CUSTOM     = 6

func StzValidatorQ()
	return new stzValidator()

func IsStzValidator(pObj)
	if isObject(pObj) and classname(pObj) = "stzvalidator"
		return 1
	else
		return 0
	ok

	func @IsStzValidator(pObj)
		return IsStzValidator(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

# Holds named validation rules in the engine, tests values against them, and collects the violations.
#
# Add rules with AddMinValueRule, AddMaxLengthRule and their kin; each returns the index of the
# rule. CheckInt, CheckLength and CheckStringLength answer 1 or 0 for a named rule, but do not
# record anything: when a check fails, call AddViolation with the rule's index, then read IsValid
# and RuleMessage. The rules live in the engine and are shared by every stzValidator of the process,
# so call Clear first. The required-value rule never rejects anything today.
#
#   receiver   o1 = new stzValidator() o1.Clear() o1.AddMinValueRule("age_min", 18, "too young")
#              o1.AddMaxLengthRule("name_max", 5, "name too long")
#   example    ? o1.CheckInt("age_min", 20)
#              #--> 1
#              ? o1.CheckInt("age_min", 10)
#              #--> 0
#              o1.AddViolation(0)
#              ? o1.IsValid()
#              #--> 0
#              ? o1.RuleMessage(0)
#              #--> too young
#              ? o1.CheckStringLength("name_max", "Alexandria")
#              #--> 0
#              o1.Clear()
#   see        stzRuleReport, stzConstraint
class stzValidator from stzObject

	@aRuleHandles = []

	  #--------------#
	 #     INIT     #
	#--------------#

	# Opens the engine's validation store, one list of named rules and one list of violations that every stzValidator object shares.
	#
	#   returns    nothing; the object is built
	#   warning    the rules and violations are global to the process, so call Clear first for a
	#              clean slate
	#   see        Clear
	def init()
		# Validator is stateless at Ring level -- engine manages global rules

	  #-------------------------------#
	 #     ADDING RULES              #
	#-------------------------------#

	# Adds a named rule of a given kind with a threshold and a message, and returns its index.
	#
	#   cName        the rule's name, a non-empty text, used by the Check calls
	#   nKind        the kind of rule, 0 required, 1 min value, 2 max value, 3 min length, 4 max
	#                length, 5 pattern, 6 custom
	#   nThreshold   the limit the rule compares against
	#   cMessage     the text reported when the rule is violated
	#   returns      the index of the new rule, a number counted from 0
	#   note         rule names are case-sensitive
	#   warning      a bad name, kind, threshold or message raises an error; a second rule with an
	#                existing name is stored, but the Check calls keep using the first
	#   see          AddMinValueRule, CheckInt, RuleMessage
	def AddRule(cName, nKind, nThreshold, cMessage)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isNumber(nKind)
				StzRaise("Incorrect param! nKind must be a number (0-6).")
			ok
			if NOT isNumber(nThreshold)
				StzRaise("Incorrect param! nThreshold must be a number.")
			ok
			if NOT isString(cMessage)
				StzRaise("Incorrect param! cMessage must be a string.")
			ok
		ok

		_nHandle_ = StzEngineValAddRule(cName, nKind, nThreshold, cMessage)
		if _nHandle_ < 0
			StzRaise("Can't add rule! Engine rule slots full.")
		ok

		@aRuleHandles + _nHandle_
		return _nHandle_

	# Adds a rule that a number must be at least nMin, and returns its index.
	#
	#   cName      the rule's name, a non-empty text
	#   nMin       the smallest number allowed
	#   cMessage   the text reported when the rule is violated
	#   returns    the index of the new rule, a number
	#   see        AddMaxValueRule, CheckInt
	def AddMinValueRule(cName, nMin, cMessage)
		return This.AddRule(cName, $STZ_RULE_MIN_VALUE, nMin, cMessage)

	# Adds a rule that a number must be at most nMax, and returns its index.
	#
	#   cName      the rule's name, a non-empty text
	#   nMax       the largest number allowed
	#   cMessage   the text reported when the rule is violated
	#   returns    the index of the new rule, a number
	#   see        AddMinValueRule, CheckInt
	def AddMaxValueRule(cName, nMax, cMessage)
		return This.AddRule(cName, $STZ_RULE_MAX_VALUE, nMax, cMessage)

	# Adds a rule that a length must be at least nMin, and returns its index.
	#
	#   cName      the rule's name, a non-empty text
	#   nMin       the shortest length allowed
	#   cMessage   the text reported when the rule is violated
	#   returns    the index of the new rule, a number
	#   see        AddMaxLengthRule, CheckLength
	def AddMinLengthRule(cName, nMin, cMessage)
		return This.AddRule(cName, $STZ_RULE_MIN_LENGTH, nMin, cMessage)

	# Adds a rule that a length must be at most nMax, and returns its index.
	#
	#   cName      the rule's name, a non-empty text
	#   nMax       the longest length allowed
	#   cMessage   the text reported when the rule is violated
	#   returns    the index of the new rule, a number
	#   see        AddMinLengthRule, CheckLength
	def AddMaxLengthRule(cName, nMax, cMessage)
		return This.AddRule(cName, $STZ_RULE_MAX_LENGTH, nMax, cMessage)

	# Adds a required-value rule, with the threshold 0, and returns its index.
	#
	#   cName      the rule's name, a non-empty text
	#   cMessage   the text reported when the rule is violated
	#   returns    the index of the new rule, a number
	#   warning    the rule answers 1 (passes) for a length of 0, for a length of 4 and for the
	#              numbers 0 and 7, so it never rejects an empty value today (checked with
	#              CheckLength, CheckInt and CheckStringLength)
	#   see        AddRule, CheckLength
	def AddRequiredRule(cName, cMessage)
		return This.AddRule(cName, $STZ_RULE_REQUIRED, 0, cMessage)

	  #-------------------------------#
	 #     CHECKING VALUES           #
	#-------------------------------#

	# Tests a number against a named rule and answers 1 if it passes, 0 if it does not.
	#
	#   cRuleName   the name of the rule to test against
	#   nValue      the number to test
	#   returns     1 or 0
	#   note        a rule of another kind than the value check answers 1
	#   warning     an unknown rule name raises an error; a failed test is not recorded: call
	#               AddViolation to record it
	#   see         CheckLength, AddViolation
	def CheckInt(cRuleName, nValue)
		_nResult_ = StzEngineValCheckInt(cRuleName, nValue)
		if _nResult_ < 0
			StzRaise("Rule '" + cRuleName + "' not found!")
		ok
		return _nResult_

	# Tests a length against a named rule and answers 1 if it passes, 0 if it does not.
	#
	#   cRuleName   the name of the rule to test against
	#   nLength     the length to test
	#   returns     1 or 0
	#   note        a rule of another kind than the length check answers 1
	#   warning     an unknown rule name raises an error; a failed test is not recorded: call
	#               AddViolation to record it
	#   see         CheckInt, CheckStringLength
	def CheckLength(cRuleName, nLength)
		_nResult_ = StzEngineValCheckLen(cRuleName, nLength)
		if _nResult_ < 0
			StzRaise("Rule '" + cRuleName + "' not found!")
		ok
		return _nResult_

		def CheckLen(cRuleName, nLength)
			return This.CheckLength(cRuleName, nLength)

	# Tests the length of a text, counted in characters, against a named rule.
	#
	#   cRuleName   the name of the rule to test against
	#   cString     the text whose length is tested
	#   returns     1 or 0
	#   warning     counts characters, not bytes: 'Zoé' has length 3
	#   see         CheckLength
	def CheckStringLength(cRuleName, cString)
		return This.CheckLength(cRuleName, StzLen(cString))

	  #-------------------------------#
	 #     VIOLATIONS                #
	#-------------------------------#

	# Records that a rule was violated, by its index, so IsValid turns FALSE.
	#
	#   nRuleIndex   the index of the rule that was violated, as AddRule returned it
	#   returns      1 if recorded, 0 if the index names no rule
	#   see          NumberOfViolations, IsValid, RuleMessage
	def AddViolation(nRuleIndex)
		return StzEngineValAddViolation(nRuleIndex)

	# Returns how many violations were recorded.
	#
	#   returns    a number
	#   see        AddViolation, ClearViolations
	def NumberOfViolations()
		return StzEngineValViolationCount()

		def ViolationCount()
			return This.NumberOfViolations()

	# TRUE if no violation is recorded.
	#
	#   returns    1 or 0
	#   see        AddViolation, ClearViolations
	def IsValid()
		if StzEngineValValid() = 1
			return 1
		else
			return 0
		ok

	# Forgets the recorded violations and keeps the rules.
	#
	#   returns    nothing
	#   see        AddViolation, Clear
	def ClearViolations()
		StzEngineValClearViolations()

	  #-------------------------------#
	 #     RULE INFO                 #
	#-------------------------------#

	# Returns the message of the rule at an index, counted from 0 in the order the rules were added.
	#
	#   nIndex     the index of the rule
	#   returns    a text; empty when no rule has that index
	#   see        AddRule, AddViolation
	def RuleMessage(nIndex)
		return StzEngineValMessage(nIndex)

	# Returns how many rules are stored.
	#
	#   returns    a number
	#   see        AddRule, Clear
	def NumberOfRules()
		return StzEngineValRuleCount()

		def RuleCount()
			return This.NumberOfRules()

	  #-------------------------------#
	 #     CLEANUP                   #
	#-------------------------------#

	# Removes every rule and every violation, for all objects that share the store.
	#
	#   returns    nothing
	#   see        ClearViolations, NumberOfRules
	def Clear()
		StzEngineValClear()
		@aRuleHandles = []
