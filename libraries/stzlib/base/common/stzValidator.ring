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

class stzValidator

	@aRuleHandles = []

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Validator is stateless at Ring level -- engine manages global rules

	  #-------------------------------#
	 #     ADDING RULES              #
	#-------------------------------#

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

		nHandle = StzEngineValAddRule(cName, nKind, nThreshold, cMessage)
		if nHandle < 0
			StzRaise("Can't add rule! Engine rule slots full.")
		ok

		@aRuleHandles + nHandle
		return nHandle

	def AddMinValueRule(cName, nMin, cMessage)
		return This.AddRule(cName, $STZ_RULE_MIN_VALUE, nMin, cMessage)

	def AddMaxValueRule(cName, nMax, cMessage)
		return This.AddRule(cName, $STZ_RULE_MAX_VALUE, nMax, cMessage)

	def AddMinLengthRule(cName, nMin, cMessage)
		return This.AddRule(cName, $STZ_RULE_MIN_LENGTH, nMin, cMessage)

	def AddMaxLengthRule(cName, nMax, cMessage)
		return This.AddRule(cName, $STZ_RULE_MAX_LENGTH, nMax, cMessage)

	def AddRequiredRule(cName, cMessage)
		return This.AddRule(cName, $STZ_RULE_REQUIRED, 0, cMessage)

	  #-------------------------------#
	 #     CHECKING VALUES           #
	#-------------------------------#

	def CheckInt(cRuleName, nValue)
		nResult = StzEngineValCheckInt(cRuleName, nValue)
		if nResult < 0
			StzRaise("Rule '" + cRuleName + "' not found!")
		ok
		return nResult

	def CheckLength(cRuleName, nLength)
		nResult = StzEngineValCheckLen(cRuleName, nLength)
		if nResult < 0
			StzRaise("Rule '" + cRuleName + "' not found!")
		ok
		return nResult

		def CheckLen(cRuleName, nLength)
			return This.CheckLength(cRuleName, nLength)

	def CheckStringLength(cRuleName, cString)
		return This.CheckLength(cRuleName, StzLen(cString))

	  #-------------------------------#
	 #     VIOLATIONS                #
	#-------------------------------#

	def AddViolation(nRuleIndex)
		return StzEngineValAddViolation(nRuleIndex)

	def NumberOfViolations()
		return StzEngineValViolationCount()

		def ViolationCount()
			return This.NumberOfViolations()

	def IsValid()
		if StzEngineValValid() = 1
			return 1
		else
			return 0
		ok

	def ClearViolations()
		StzEngineValClearViolations()

	  #-------------------------------#
	 #     RULE INFO                 #
	#-------------------------------#

	def RuleMessage(nIndex)
		return StzEngineValMessage(nIndex)

	def NumberOfRules()
		return StzEngineValRuleCount()

		def RuleCount()
			return This.NumberOfRules()

	  #-------------------------------#
	 #     CLEANUP                   #
	#-------------------------------#

	def Clear()
		StzEngineValClear()
		@aRuleHandles = []
