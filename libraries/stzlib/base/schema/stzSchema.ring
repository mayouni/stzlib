#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZSCHEMA                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Schema definition class backed by the       #
#                  Softanza Engine (stz_schema module).         #
#                  Named fields with type and required flag.    #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  #=============#
 #  FUNCTIONS  #
#=============#

func StzSchemaQ(cName)
	return new stzSchema(cName)

func IsStzSchema(pObj)
	if isObject(pObj) and classname(pObj) = "stzschema"
		return 1
	else
		return 0
	ok

	func @IsStzSchema(pObj)
		return IsStzSchema(pObj)


  /////////////////
 ///   CLASS   ///
/////////////////

class stzSchema

	@nHandle = -1
	@cName = ""

	  #--------------#
	 #     INIT     #
	#--------------#

	def init(cName)

		if CheckingParams()
			if NOT isString(cName) or cName = ""
				StzRaise("Can't create stzSchema! cName must be a non-empty string.")
			ok
		ok

		@cName = cName
		@nHandle = StzEngineSchemaCreate(cName)

		if @nHandle < 0
			StzRaise("Can't create stzSchema! Engine returned error.")
		ok

	  #-------------------------------#
	 #     FIELDS                    #
	#-------------------------------#

	def AddField(cFieldName, cType, bRequired)
		if CheckingParams()
			if NOT isString(cFieldName) or cFieldName = ""
				StzRaise("Incorrect param! cFieldName must be a non-empty string.")
			ok
			if NOT isString(cType)
				StzRaise("Incorrect param! cType must be a string.")
			ok
			if NOT isNumber(bRequired)
				StzRaise("Incorrect param! bRequired must be 0 or 1.")
			ok
		ok

		nResult = StzEngineSchemaAddField(@nHandle, cFieldName, cType, bRequired)
		if nResult < 0
			StzRaise("Can't add field! Field slots full.")
		ok

		def AddFieldQ(cFieldName, cType, bRequired)
			This.AddField(cFieldName, cType, bRequired)
			return This

	def FieldCount()
		return StzEngineSchemaFieldCount(@nHandle)

		def NumberOfFields()
			return This.FieldCount()

	def FieldName(nIndex)
		return StzEngineSchemaFieldName(@nHandle, nIndex)

	def FieldType(nIndex)
		return StzEngineSchemaFieldType(@nHandle, nIndex)

	def FieldRequired(nIndex)
		nResult = StzEngineSchemaFieldRequired(@nHandle, nIndex)
		if nResult = 1
			return 1
		else
			return 0
		ok

		def IsFieldRequired(nIndex)
			return This.FieldRequired(nIndex)

	  #-------------------------------#
	 #     INFO                      #
	#-------------------------------#

	def Name()
		return @cName

	def Handle()
		return @nHandle

	  #-------------------------------#
	 #     CLEANUP                   #
	#-------------------------------#

	def Destroy()
		if @nHandle >= 0
			StzEngineSchemaDestroy(@nHandle)
			@nHandle = -1
		ok
