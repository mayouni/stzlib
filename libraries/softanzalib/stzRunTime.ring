
func StzRuntimeQ(pacVarNames)
	return new stzRuntime(pacVarNames)

func ring_packages()
	return packages()

func ring_globals()
	return globals()

func ring_locals()
	return locals()

func ring_objects()
	return objects()

func IsClassName(cStr)
	if CheckParams()
		if NOT isSting(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	bResult = find( ClassesNames(), cStr)
	return bResult

	func @IsClassName(pcStr)
		return IsClassName

	func IsAClassName(pcStr)
		return IsClassName

func IsPackageName(cStr)
	if CheckParams()
		if NOT isSting(cStr)
			StzRaise("Incorrect param type! cStr must be a string.")
		ok
	ok

	bResult = find( packages(), lower(cStr))
	return bResult


func Vars()
	return globals()

class stzRunTime

	@acVarNames = []
	@aVarValues = []

	def init(pacVarsNames)
		if CheckParams()
			if NOT ( isList(pacVarsNames) and @IsListOfStrings(pacVarsNames) )
				StzRaise("Incorrect param type! pacVarsNames must be a list of strings.")
			ok
		ok

		nLen = len(pacVarsNames)

		for i = 1 to nLen

			# Skipping system vars of the form n_sys_var_1296658

			# TODO: Risky implementation, should ask Mahmoud if there
			# other system variable forms. Keep an eye on any changes
			# in future low level Ring

			# TODO: It's better to ask Mahmoud for a fucntion that
			# returns only the vars used by the user program (and not
			# system vars or any other libraries vars)

			if substr(pacVarsNames[i], 1, 10) = "n_sys_var_" and
			   isNumber( 0+ substr(pacVarsNames[i], 11, len(pcVarNames[i]) - 10) )

				loop

			ok

			@acVarNames + pacVarsNames[i]
			val = 0
			@aVarValues + val

		next

	def Content()
		aResult = Association([ @acVarsNames, @aVarsValues ])

	def NamedVars()
		return @NamedVars()

	def NumberOfVariables()
		nResult = len(@acVarsNames)
		return nResult

		def NumberOfVars()
			return This.NumberOfVariables()

		def HowManyVariables()
			return This.NumberOfVariables()

		def HowManyVars()
			return This.NumberOfVariables()

		def CountVariables()
			return This.NumberOfVariables()

		def CountVars()
			return This.NumberOfVariables()

	def VariablesNames()
		return @acVarsNames

		def VarsNames()
			return This.VariablesNames()

		def Variables()
			return This.VariablesNames()

		def Vars()
			return This.VariablesNames()


	def VariablesValues()
		return @aVarsValues

		def VarsValues()
			return This.VariablesValues()

		def VarsVals()
			return This.VariablesValues()

	def VariablesNamesAndValues()
		return This.Content()

		#< @FunctionAlternativeForms

		def VarsNamesAndValues()
			return This.VariablesNamesAndValues()

		def VarsNamesAndVals()
			return This.VariablesNamesAndValues()

		def VariablesAndTheirValues()
			return This.VariablesNamesAndValues()

		def VarsAndTheirValues()
			return This.VariablesNamesAndValues()

		def VariablesAndTheirVals()
			return This.VariablesNamesAndValues()

		def VarsAndTheirVals()
			return This.VariablesNamesAndValues()

		def VariablesXT()
			return This.VariablesNamesAndValues()

		def VariablesNamesXT()
			return This.VariablesNamesAndValues()

		def VarsXT()
			return This.VariablesNamesAndValues()

		def VarsNamesXT()
			return This.VariablesNamesAndValues()

		#>




	def Locals()
		return ring_locals()

		def LocalVars()
			return This.Locals()

		def LocalVariables()
			return This.Locals()

	def Globals()
		return ring_gloabls()

		def GlobalVars()
			return This.Globals()

		def GlobalVariables()
			return This.Globals()

	def NumbersVariables()
		aVars = This.Vars()
		nLen = len(aVars)

		anResult = []

		for i = 1 to nLen
			eval( 'bOk = isNumber(aVars[i])' )
			if bOk
				acResult + aVars[i]
			ok
		next

		return anResult

		def NumbersVars()
			return NumbersVariables()

		def Numbers
	def Strings()
		aVars = This.Vars()
		nLen = len(aVars)

		acResult = []

		for i = 1 to nLen
			if isString(aVars[i])
				acResult + aVars[i]
			ok
		next

		return anResult

	def Lists()
		aVars = This.Vars()
		nLen = len(aVars)

		anResult = []

		for i = 1 to nLen
			if isNumber(aVars[i])
				anResult + aVars[i]
			ok
		next

		return anResult

	def Objects()

	def Chars()

	def Booleans()

	def Trues()

	def Falses()

	def BinaryNumbers()

	def DecimalNumbers()

	def OctalNumbers()

	def HexNumbers()

	def Pairs()

	def Sets()

	def HashLists()

	def Grids()

	def Tables()

	def Trees()

	def StzObjects()

	def StzNamedObjects()

	def StzChars()

	def StzStrings()

	def StzNumbers()

	def StzDecimalNumbers()

	def StzBinaryNumbers()

	def StzOctalNumbers()

	def StzHexNumbers()

	def StzLists()

	def StzPairs()

	def StzSets()

	def StzHashLists()

	def StzGrids()

	def StzTables()

	def StzTrees()

	def QObjects()

	def QStringObjects()

	def QStringListsObejcts()

	def QLocaleObjects()
