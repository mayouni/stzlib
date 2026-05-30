
func StzListInStringQ(pcString)
	return new stzListInString(pcString)

func StringIsListInString(pcString)
	return StzStringQ(pcString).IsListInString()

class stzListInString from stzString
	@cListInString
	@aList

	@aVarNames
	@aValues

	def init(pcListInString)
		if NOT StringIsListInString(pcListInString)
			StzRaise("Syntax error! The list is not correct.")
		else
			@cListInString = pcListInString
			cCode = '@aList = ' + pcListInString
			eval(cCode)
		ok

	
	def ListInString()
		return @cListInString

	def List()
		return @aList

		def ListQ()
			return new stzList(This.List())

		def ListQRT(pcType)
			# Was referencing undefined `pcReturnType` (param is pcType).
			# Named-param unwrap also operated on the wrong variable.
			# Both crash with R24.
			if isList(pcType) and IsOneOfTheseNamedParamsList(pcType, [ :ReturnedAs, :ReturnAs ])
				pcType = pcType[2]
			ok

			cCode = "oResult = new " + pcType + "(This.List())"
			eval(cCode)
			return oResult

	def Content()
		return This.List()

		def Value()
			return Content()

	def Copy()
		# init expects the ORIGINAL string-form of the list, not the
		# parsed Ring list. Was passing This.Content() (= List(), the
		# parsed list) which made the ctor's IsListInString string-check
		# crash inside stzStringQ on a non-string. Pass back the
		# preserved source string instead.
		return new stzListInString( This.ListInString() )

	def ToStzList()
		return new stzList( This.List() )

	def Items()
		return StzStringQ(This.ListInString()).RemoveAllQ([ "[", "]" ]).RemoveSpacesQ().SplitQ(",").Content()
		
	def ItemsXT()
		aResult = []

		aoStzStr = StzListOfStringsQ(This.Items()).ToListOfStzStrings()

		for oStzStr in aoStzStr
			
			if oStzStr.IsBoundedBy('"') or
			   oStzStr.IsBoundedBy("'") or
			   oStzStr.IsBoundedBy([ ':', "" ])
				aResult + [

					oStzStr.RemoveTheseBoundsQ('"', '"').
						RemoveTheseBoundsQ("'", "'").Content(),

					:IsValue,
					:IsString
				]

			but oStzStr.IsNumberInString()
				aResult + [
					oStzStr.Content(),
					:IsValue,
					:IsNumber
				]

			else
				# The item is a variable name
				cVarName = oStzStr.RemoveTheseBoundsQ('"', '"').
						RemoveTheseBoundsQ("'", "'").
						Content()

				cCode = 'cType = StzLower(type(' + cVarName + '))'
				eval(cCode)

				aResult + [
					oStzStr.Content(),
					:IsVarName,
					:Is + cType
				]
			ok

		next

		return aResult

	def Values()
		aResult = []

		aItems = This.ItemsXT()
		for aItem in aItems
			if aItem[2] = :IsValue
				aResult + aItem[1]
			ok
		next

		return aResult

	def VarNames()

		aResult = []

		aoStzStr = StzListOfStringsQ(This.Items()).ToListOfStzStrings()

		for oStzStr in aoStzStr
			
			if NOT ( oStzStr.IsBoundedBy('"') or
			   oStzStr.IsBoundedBy("'") or
			   oStzStr.IsBoundedBy([ ':', "" ]) or
			   oStzStr.IsNumberInString() )
	
				# The item is a variable name
				cVarName = oStzStr.RemoveTheseBoundsQ('"', '"').
						RemoveTheseBoundsQ("'", "'").
						Content()

				cCode = 'cType = StzLower(type(' + cVarName + '))'
				eval(cCode)

				aResult + oStzStr.Content()
			
			ok

		next

		return aResult

		def Variables()
			return This.VarNames()


	def Types()
		acResult = []
		for cVarName in This.VarNames()
			cCode = 'cType = ring_type('+ cVarName +')'
			eval(cCode)
			acResult + cType
		next

		return acResult

	def VariablesAndTheirTypes()
		aResult = []

		aVarNames = This.VarNames()
		aTypes = This.Types()

		for i = 1 to stlen(aVarNames)
			aResult + [ aVarNames[i], aTypes[i] ]
		next i

		return aResult

		def VarNamesAndTheirTypes()
			return This.VariablesAndTheirTypes()

	def ContainsValues()

	def ContainsVariables()

	def ContainsOnlyValues()

	def ContainsValuesAndVariables()

		
