
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
			if isList(pcReturnType) and Q(pcReturnType).IsOneOfTheseNamedParams([ :ReturnedAs, :ReturnAs ])
				pcReturnType = pcReturnType[2]
			ok

			cCode = "oResult = new " + pcType + "(This.List())"
			eval(cCode)
			return oResult

	def Content()
		return This.List()

		def Value()
			return Content()

	def Copy()
		return new stzListInString( This.Content() )

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

				cCode = 'cType = lower(type(' + cVarName + '))'
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

				cCode = 'cType = lower(type(' + cVarName + '))'
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

		
