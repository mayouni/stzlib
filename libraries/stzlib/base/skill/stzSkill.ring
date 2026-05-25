#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSKILL                   #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Skill tracking class backed by the          #
#                  Softanza Engine (stz_skill module).          #
#                  Named skills with scoring and prerequisites. #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzSkillQ()
	return new stzSkill()

func IsStzSkill(pObj)
	if isObject(pObj) and classname(pObj) = "stzskill"
		return 1
	else
		return 0
	ok

	func @IsStzSkill(pObj)
		return IsStzSkill(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzSkill

	  #--------------#
	 #     INIT     #
	#--------------#

	def init()
		# Engine manages global skill store

	  #-------------------------------#
	 #     REGISTRATION              #
	#-------------------------------#

	def Register(cName, cCategory, nMaxLevel)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isString(cCategory)
				StzRaise("Incorrect param! cCategory must be a string.")
			ok
			if NOT isNumber(nMaxLevel) or nMaxLevel < 1
				StzRaise("Incorrect param! nMaxLevel must be a positive number.")
			ok
		ok

		nResult = StzEngineSkillRegister(cName, cCategory, nMaxLevel)
		if nResult < 0
			StzRaise("Can't register skill! Skill slots full.")
		ok

		def RegisterQ(cName, cCategory, nMaxLevel)
			This.Register(cName, cCategory, nMaxLevel)
			return This

	def Unregister(cName)
		nResult = StzEngineSkillUnregister(cName)
		if nResult < 0
			StzRaise("Skill '" + cName + "' not found!")
		ok

	  #-------------------------------#
	 #     TRACKING                  #
	#-------------------------------#

	def RecordAttempt(cName, bSuccess)
		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Incorrect param! cName must be a non-empty string.")
			ok
			if NOT isNumber(bSuccess)
				StzRaise("Incorrect param! bSuccess must be 0 or 1.")
			ok
		ok

		nResult = StzEngineSkillRecordAttempt(cName, bSuccess)
		if nResult < 0
			StzRaise("Skill '" + cName + "' not found!")
		ok

		def RecordAttemptQ(cName, bSuccess)
			This.RecordAttempt(cName, bSuccess)
			return This

	def Level(cName)
		return StzEngineSkillLevel(cName)

		def SkillLevel(cName)
			return This.Level(cName)

	def Score(cName)
		return StzEngineSkillScore(cName)

		def SkillScore(cName)
			return This.Score(cName)

	def Attempts(cName)
		return StzEngineSkillAttempts(cName)

		def TotalAttempts(cName)
			return This.Attempts(cName)

	def Successes(cName)
		return StzEngineSkillSuccesses(cName)

		def TotalSuccesses(cName)
			return This.Successes(cName)

	  #-------------------------------#
	 #     PREREQUISITES             #
	#-------------------------------#

	def AddPrerequisite(cSkill, cPrereq)
		if CheckingParams()
			if NOT isString(cSkill) or NOT isString(cPrereq)
				StzRaise("Incorrect params! cSkill and cPrereq must be strings.")
			ok
		ok

		nResult = StzEngineSkillAddPrereq(cSkill, cPrereq)
		if nResult < 0
			StzRaise("Can't add prerequisite! Skill not found or prereq slots full.")
		ok

		def AddPrerequisiteQ(cSkill, cPrereq)
			This.AddPrerequisite(cSkill, cPrereq)
			return This

	def PrerequisitesMet(cSkill)
		nResult = StzEngineSkillPrereqsMet(cSkill)
		if nResult = 1
			return 1
		else
			return 0
		ok

		def ArePrerequisitesMet(cSkill)
			return This.PrerequisitesMet(cSkill)

	  #-------------------------------#
	 #     COUNTING AND CLEANUP      #
	#-------------------------------#

	def Count()
		return StzEngineSkillCount()

		def NumberOfSkills()
			return This.Count()

	def CountByCategory(cCategory)
		return StzEngineSkillCountByCategory(cCategory)

	def Clear()
		StzEngineSkillClear()
