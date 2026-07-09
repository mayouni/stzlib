
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
			_cCode_ = '@aList = ' + pcListInString
			eval(_cCode_)
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

			_cCode_ = "_oResult_ = new " + pcType + "(This.List())"
			eval(_cCode_)
			return _oResult_

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
		_aResult_ = []

		_aoStzStr_ = StzListOfStringsQ(This.Items()).ToListOfStzStrings()

		_nAoStzStr2Len_ = len(_aoStzStr_)
		for _iLoopAoStzStr2_ = 1 to _nAoStzStr2Len_
			_oStzStr_ = _aoStzStr_[_iLoopAoStzStr2_]
			if _oStzStr_.IsBoundedBy('"') or
			   _oStzStr_.IsBoundedBy("'") or
			   _oStzStr_.IsBoundedBy([ ':', "" ])
				_aResult_ + [

					_oStzStr_.RemoveTheseBoundsQ('"', '"').
						RemoveTheseBoundsQ("'", "'").Content(),

					:IsValue,
					:IsString
				]

			but _oStzStr_.IsNumberInString()
				_aResult_ + [
					_oStzStr_.Content(),
					:IsValue,
					:IsNumber
				]

			else
				# The item is a variable name
				_cVarName_ = _oStzStr_.RemoveTheseBoundsQ('"', '"').
						RemoveTheseBoundsQ("'", "'").
						Content()

				_cCode_ = '_cType_ = StzLower(type(' + _cVarName_ + '))'
				eval(_cCode_)

				_aResult_ + [
					_oStzStr_.Content(),
					:IsVarName,
					:Is + cType
				]
			ok

		next

		return _aResult_

	def Values()
		_aResult_ = []

		_aItems_ = This.ItemsXT()
		_nItems1Len_ = len(_aItems_)
		for _iLoopItems1_ = 1 to _nItems1Len_
			_aItem_ = _aItems_[_iLoopItems1_]
			if _aItem_[2] = :IsValue
				_aResult_ + _aItem_[1]
			ok
		next

		return _aResult_

	def VarNames()

		_aResult_ = []

		_aoStzStr_ = StzListOfStringsQ(This.Items()).ToListOfStzStrings()

		_nAoStzStr1Len_ = len(_aoStzStr_)
		for _iLoopAoStzStr1_ = 1 to _nAoStzStr1Len_
			_oStzStr_ = _aoStzStr_[_iLoopAoStzStr1_]
			if NOT ( _oStzStr_.IsBoundedBy('"') or
			   _oStzStr_.IsBoundedBy("'") or
			   _oStzStr_.IsBoundedBy([ ':', "" ]) or
			   _oStzStr_.IsNumberInString() )
	
				# The item is a variable name
				_cVarName_ = _oStzStr_.RemoveTheseBoundsQ('"', '"').
						RemoveTheseBoundsQ("'", "'").
						Content()

				_cCode_ = '_cType_ = StzLower(type(' + _cVarName_ + '))'
				eval(_cCode_)

				_aResult_ + _oStzStr_.Content()
			
			ok

		next

		return _aResult_

		def Variables()
			return This.VarNames()


	def Types()
		_acResult_ = []
		_aThisVarNames1_ = This.VarNames()
		_nThisVarNames1Len_ = len(_aThisVarNames1_)
		for _iLoopThisVarNames1_ = 1 to _nThisVarNames1Len_
			_cVarName_ = _aThisVarNames1_[_iLoopThisVarNames1_]
			_cCode_ = '_cType_ = ring_type('+ _cVarName_ +')'
			eval(_cCode_)
			_acResult_ + _cType_
		next

		return _acResult_

	def VariablesAndTheirTypes()
		_aResult_ = []

		_aVarNames_ = This.VarNames()
		_aTypes_ = This.Types()

		for i = 1 to stlen(_aVarNames_)
			_aResult_ + [ _aVarNames_[i], _aTypes_[i] ]
		next i

		return _aResult_

		def VarNamesAndTheirTypes()
			return This.VariablesAndTheirTypes()

	def ContainsValues()

	def ContainsVariables()

	def ContainsOnlyValues()

	def ContainsValuesAndVariables()

		
