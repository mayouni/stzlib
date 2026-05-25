#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZINTERACTION              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Interaction session class backed by the     #
#                  Softanza Engine (stz_interact module).       #
#                  Prompt-response turns with session tracking. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

# Mode constants
$STZ_INTERACT_QA      = 0
$STZ_INTERACT_DIALOG  = 1
$STZ_INTERACT_COMMAND = 2

func StzInteractionQ(cName, nMode)
	return new stzInteraction(cName, nMode)

func IsStzInteraction(pObj)
	if isObject(pObj) and classname(pObj) = "stzinteraction"
		return 1
	else
		return 0
	ok

	func @IsStzInteraction(pObj)
		return IsStzInteraction(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzInteraction

	@nHandle = -1
	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(cName, nMode)

		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Can't create stzInteraction! cName must be a non-empty string.")
			ok
			if NOT isNumber(nMode)
				StzRaise("Incorrect param! nMode must be 0 (QA), 1 (Dialog), or 2 (Command).")
			ok
		ok

		@cName = cName
		@nHandle = StzEngineInteractCreate(cName, nMode)

		if @nHandle < 0
			StzRaise("Can't create stzInteraction! Engine returned error.")
		ok

	  #-------------------------------#
	 #     TURNS                     #
	#-------------------------------#

	def AddTurn(cPrompt, cResponse)
		if CheckingParams()
			if NOT isString(cPrompt) or NOT isString(cResponse)
				StzRaise("Incorrect params! cPrompt and cResponse must be strings.")
			ok
		ok

		nResult = StzEngineInteractAddTurn(@nHandle, cPrompt, cResponse)
		if nResult < 0
			StzRaise("Can't add turn! Turn slots full.")
		ok

		def AddTurnQ(cPrompt, cResponse)
			This.AddTurn(cPrompt, cResponse)
			return This

	def TurnCount()
		return StzEngineInteractTurnCount(@nHandle)

		def NumberOfTurns()
			return This.TurnCount()

	def PromptAt(nIndex)
		return StzEngineInteractPrompt(@nHandle, nIndex)

	def ResponseAt(nIndex)
		return StzEngineInteractResponse(@nHandle, nIndex)

	def LastPrompt()
		return StzEngineInteractLastPrompt(@nHandle)

	  #-------------------------------#
	 #     INFO                      #
	#-------------------------------#

	def Name()
		return @cName

	def Handle()
		return @nHandle

	def SessionCount()
		return StzEngineInteractSessionCount()

	def CurrentMode()
		return StzEngineInteractMode(@nHandle)

		def InteractionMode()
			return This.CurrentMode()

	  #-------------------------------#
	 #     CLEANUP                   #
	#-------------------------------#

	def Destroy()
		if @nHandle >= 0
			StzEngineInteractDestroy(@nHandle)
			@nHandle = -1
		ok
