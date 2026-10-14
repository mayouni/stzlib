
func StzListInStringQ(pcString)
	return new stzListInString(pcString)

func StringIsListInString(pcString)
	return StzStringQ(pcString).IsListInString()

# Holds a list written as text, such as '[ "a", 2 ]', evaluates it, and gives the real list back.
#
# Build one with new stzListInString(cText) or StzListInStringQ(cText); StringIsListInString(cText)
# tells whether a text qualifies. It is a stzString, so the source text answers every string method,
# and the evaluated list is available as List, Content, Value and ToStzList. The text is evaluated
# as Ring code, which lets names stand for global variables. The analysis methods (Items, Values,
# VarNames, Types, VariablesAndTheirTypes) are broken today and the four Contains... methods are
# empty; see their warnings.
#
#   receiver   o1 = new stzListInString('[ "a", 2, "שלום", 5 ]')
#   example    ? @@( o1.List() )
#              #--> [ "a", 2, "שלום", 5 ]
#              ? o1.ListInString()
#              #--> [ "a", 2, "שלום", 5 ]
#              ? @@( o1.ToStzList().Content() )
#              #--> [ "a", 2, "שלום", 5 ]
#   see        stzString, stzList
class stzListInString from stzString
	@cListInString
	@aList

	@aVarNames
	@aValues

	# Builds the object from a text that spells a Ring list, such as '[ "a", 2, "שלום" ]', and evaluates it into a real list.
	#
	#   pcListInString   the text that spells the list, in square brackets
	#   returns          nothing; the object is built
	#   note             a stzListInString is a stzString too, so every string method works on the
	#                    source text
	#   warning          a text that is not a list raises "Syntax error! The list is not correct.";
	#                    the text is evaluated as Ring code, so names in it are read as global
	#                    variables
	#   see              List, ListInString
	def init(pcListInString)
		if NOT StringIsListInString(pcListInString)
			StzRaise("Syntax error! The list is not correct.")
		else
			@cListInString = pcListInString
			_cCode_ = '@aList = ' + pcListInString
			eval(_cCode_)
		ok

	
	# Returns the source text that spells the list, exactly as it was given.
	#
	#   returns    a text
	#   see        List
	def ListInString()
		return @cListInString

	# Returns the list that the source text spells, as a real list.
	#
	#   returns    a list
	#   see        ListInString, Content, ToStzList
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

		# Returns the list that the source text spells, the same answer as List and Content.
		#
		#   returns    a list
		#   see        List
		def Value()
			return Content()

	# Returns a new stzListInString built from the same source text.
	#
	#   returns    a new stzListInString
	#   see        ToStzList
	def Copy()
		# init expects the ORIGINAL string-form of the list, not the
		# parsed Ring list. Was passing This.Content() (= List(), the
		# parsed list) which made the ctor's IsListInString string-check
		# crash inside stzStringQ on a non-string. Pass back the
		# preserved source string instead.
		return new stzListInString( This.ListInString() )

	# Returns the evaluated list wrapped in a stzList, ready for the list methods.
	#
	#   returns    a stzList
	#   see        List
	def ToStzList()
		return new stzList( This.List() )

	# Returns the source text cut at its commas into pieces of text, spaces dropped, brackets still attached to the ends.
	#
	#   returns    a list of texts
	#   note       this is what makes ItemsXT, Values, VarNames, Types and VariablesAndTheirTypes
	#              fail
	#   warning    The brackets stay on the first and last pieces today, and a comma or space inside
	#              a quoted text splits or shrinks it: '[1,2,3]' answers [ "[1", "2", "3]" ] and '[
	#              "a b", "c,d" ]' answers [ '["ab"', '"c', 'd"]' ]
	#   see        ItemsXT
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

	# Returns the items of the source text that are written as values rather than as variable names.
	#
	#   returns    nothing today: it raises an error
	#   note       the first step, ItemsXT, breaks on the bracketed first piece that Items gives
	#   warning    Raises error R42 (Error in eval()) on a list of several items and R20 on a list
	#              of one item or none, today instead of the list of values; it fails on every list
	#              tried
	#   see        VarNames, ItemsXT
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

	# Returns the items of the source text that are variable names rather than quoted texts, numbers or :names.
	#
	#   returns    nothing today: it raises an error
	#   note       Variables is the same method under another name
	#   warning    Raises error R42 (Error in eval()) on a list of several items and R20 on a list
	#              of one item or none, today instead of the list of names; it fails on every list
	#              tried, because Items leaves a bracket on the first piece
	#   see        Values, Types
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


	# Returns the Ring type of each variable named in the source text, in order.
	#
	#   returns    nothing today: it raises an error
	#   warning    Raises error R42 or R20 today instead of the list of types, through VarNames,
	#              which fails on every list tried
	#   see        VarNames, VariablesAndTheirTypes
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

	# Returns each variable named in the source text paired with its Ring type.
	#
	#   returns    nothing today: it raises an error
	#   warning    Raises error R42 or R20 today instead of a list of [ name, type ] pairs, through
	#              VarNames, which fails on every list tried
	#   see        VarNames, Types
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

	# Does nothing yet: the body is empty and the answer is an empty text.
	#
	#   returns    an empty text, never TRUE or FALSE
	#   warning    Not implemented: it answers "" whatever the list holds, so a test on it is always
	#              false
	#   see        ContainsVariables
	def ContainsValues()

	# Does nothing yet: the body is empty and the answer is an empty text.
	#
	#   returns    an empty text, never TRUE or FALSE
	#   warning    Not implemented: it answers "" whatever the list holds, so a test on it is always
	#              false
	#   see        ContainsValues
	def ContainsVariables()

	# Does nothing yet: the body is empty and the answer is an empty text.
	#
	#   returns    an empty text, never TRUE or FALSE
	#   warning    Not implemented: it answers "" whatever the list holds, so a test on it is always
	#              false
	#   see        ContainsValues
	def ContainsOnlyValues()

	# Does nothing yet: the body is empty and the answer is an empty text.
	#
	#   returns    an empty text, never TRUE or FALSE
	#   warning    Not implemented: it answers "" whatever the list holds, so a test on it is always
	#              false
	#   see        ContainsVariables
	def ContainsValuesAndVariables()

		
