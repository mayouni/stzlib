#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLESEARCH              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table search subclass -- finding cells,     #
#                  counting occurrences, containment checks    #
#                  across cells, rows, columns, and sections.  #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableSearch from stzTable

	/// WORKING ON TABLE /////////////////////////////////////////////////////////////////

	  #==================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==================================================================================#

	def FindAllCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.FindAll("Ali") // or o1.FindAll( :Cells = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? _o1_.FindAll( :SubValue = "A" )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1] ]
		     ]
		*/

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue,
				:CellValue, :OfCellValue, :Of ])


				return This.FindCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue,
				:Part, :OfPart, :CellPart, :OfCellPart,
				:SubPart, :OfSubPart ])

				return This.FindSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)
			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		else
			return This.FindCellCS(pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForms

		def FindCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)		

		def FindAllOccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)		

		def FindOccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)

		def OccurrencesCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)

		def PositionsCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllCS(pCellValueOrSubValue, pCaseSensitive)
		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAll(pCellValueOrSubValue)
		return This.FindAllCS(pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def Find(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)

		def FindAllOccurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)		
	
		def FindOccurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
	
		def Occurrences(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
		
		def Positions(pCellValueOrSubValue)
			return This.FindAll(pCellValueOrSubValue)
		#>

	  #--------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL IN THE TABLE  #
	#--------------------------------------------------#

	def FindCellCS(pCellValue, pCaseSensitive)
		if isString(pCellValue)
			This._EnsureEngine()
			# Engine returns a ready list of [col, row] pairs (built Zig-side).
			return StzEngineTableFindCellStringCS(@pEngine, pCellValue, pCaseSensitive)
		ok

		_aResult_ = StzListOfListsQ( This.Cols() ).FindInListsCS(pCellValue, pCaseSensitive)
		return _aResult_

		#< @FunctionAlternativeForms
			
		def OccurrencesOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		def PositionsOfCellCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

		#--

		def FindValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)
			
		def OccurrencesOfValueCS(pCellValue, pCaseSensitive)
			return This.FindCellCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindCell(pValue)
		return This.FindCellCS(pValue, 1)

		#< @FunctionAlternativeForms

		def OccurrencesOfCell(pValue)
			return This.FindCell(pValue)

		def PositionsOfCell(pValue)
			return This.FindCell(pValue)

		#--
	
		def FindValue(pCellValue)
			return This.FindCell(pCellValue)
					
		def OccurrencesOfValue(pCellValue)
			return This.FindCell(pCellValue)
	
		#>
	
	  #-----------------------------------#
	 #  FINDING MANY CELLS IN THE TABLE  #
	#-----------------------------------#

	def FindCellsCS(paValues, pCaseSensitive)
		if CheckingParams()
			if NOT isList(paValues)
				StzRaise("Incorrect param type! paValues must be a list.")
			ok
		ok

		paValues = UCS(paValues, pCaseSensitive)
		_nLen_ = len(paValues)

		_aResult_ = []

		for i = 1 to _nLen_
			_aTemp_ = This.FindCellCS(paValues[i], pCaseSensitive)
			_nLen_ = len(_aTemp_)

			for j = 1 to _nLen_
				_aResult_ + _aTemp_[j]
			next
		next

		return _aResult_

		def FindValuesCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyCellsCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

		def FindManyValuesCS(paValues, pCaseSensitive)
			return This.FindCellsCS(paValues, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindCells(paValues)
		return This.FindCellsCS(paValues, 1)

		def FindValues(paValues)
			return This.FindCells(paValues)

		def FindMany(paValues)
			return This.FindCells(paValues)

		def FindManyCells(paValues)
			return This.FindCells(paValues)

		def FindManyValues(paValues)
			return This.FindCells(paValues)

	  #-------------------------------------------#
	 #  FINDING ALL CELLS EXCEPT THOSE PROVIDED  #
	#-------------------------------------------#

	def FindCellsExceptCS(paValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindCellsExcept(paValues)
		return This.FindCellsExceptCS(paValues, 1)

	  #------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN SUBVALUE IN THE TABLE  #
	#------------------------------------------------------#

	def FindSubValueCS(pSubValue, pCaseSensitive)
		_bCheckCase_ = 0
		if @IsStringOrList(pSubValue)
			_bCheckCase_ = 1
		ok

		_aCellsXT_ = This.CellsAndTheirPositions()

		_aResult_ = []
		_nCellsXTLen_3 = len(_aCellsXT_)
		for i = 1 to _nCellsXTLen_3
			_cellValue_ = _aCellsXT_[i][1]
			_oCellValue_ = Q(_cellValue_)

			_aCellPos_  = _aCellsXT_[i][2]

			_bCellIsString_ = isString(_cellValue_)
			_bCellIsListOfStrings_ = isList(_cellValue_) and _oCellValue_.IsListOfStrings()


			if _bCheckCase_
				if _bCellIsString_ = 1 or _bCellIsListOfStrings_ = 1

					if _oCellValue_.ContainsCS(pSubValue, pCaseSensitive)
						_aResult_ + [ _aCellPos_, _oCellValue_.FindAllCS(pSubValue, pCaseSensitive) ]
					ok
				ok
			else

				if isList(_cellValue_) and _oCellValue_.Contains(pSubValue)
					_aResult_ + [ _aCellPos_, _oCellValue_.FindAll(pSubValue) ]
				ok
			ok
		next

		return _aResult_

		#< @FuntionAlternativeForm

		def PositionsOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindSubValueCS(pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubValue(pSubValue)
		return This.FindSubValueCS(pSubValue, 1)

		#< @FuntionAlternativeForm

		def PositionsOfSubValue(pSubValue)
			return This.FindSubValue(pSubValue)

		#>

	  #-------------------------------------------#
	 #  FINFING MANY SUBVALUES INSIDE THE TABLE  #
	#-------------------------------------------#

	def FindSubValuesCS(paSubValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindSubValues(paSubValues)
		return This.FindSubValuesCS(paSubValues, 1)

	  #-----------------------------------------------#
	 #  FINFING ALL SUBVALUES EXCEPT THOSE PROVIDED  #
	#-----------------------------------------------#

	def FindSubValuesExceptCS(paSubValues, pCaseSensitive) #TODO
		StzRaise("TODO!")

	#-- WITHOUT CASESENSITIVITY

	def FindSubValuesExcept(paSubValues)
		return This.FindSubValuesExceptCS(paSubValues, 1)

	  #---------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#---------------------------------------------------------------------------------------#

	def FindNthCS(_n_, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if _oParam_.IsOfOfTheseNamedParams([
				:Cell, :OfCell, :Value, :OfValue, :Of ])

				return This.FindNthValueCS(_n_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue, :Part, :OfPart,
				:CellPart, :OfCellPart ])

				return This.FindNthSubValueCS(_n_, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok

		else
			return This.FindNthValueCS(_n_, pCellValueOrSubValue, pCaseSensitive)
		ok

		#< @FunctionAlternativeForm

		def FindNthOccurrenceCS(_n_, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthCS(_n_, pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNth(_n_, pCellValueOrSubValue)
		return This.FindNthCS(_n_, pCellValueOrSubValue, 1)
	
		def FindNthOccurrence(_n_, pCellValueOrSubValue)
			return This.FindNth(_n_, pCellValueOrSubValue)	

	  #-------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#-------------------------------------------------#

	def FindNthCellCS(_n_, pCellValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(_n_)

			if StzFindFirst([ :First, :FirstOccurrence ], _n_) > 0
				_n_ = 1

			but StzFindFirst([ :Last, :LastOccurrence ], _n_) > 0
				_n_ = This.NumberOfOccurrenceCS(pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_aResult_ = []

		_aFoundCells_ = This.FindCellCS(pCellValue, pCaseSensitive)

		if _n_ > 0 and _n_ <= len(_aFoundCells_)
			_aResult_ = _aFoundCells_[_n_]
		ok	

		return _aResult_

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfCellCS(_n_, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(_n_, pCellValue, pCaseSensitive)

		def FindNthValueCS(_n_, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(_n_, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueCS(_n_, pCellValue, pCaseSensitive)
			return This.FindNthCellCS(_n_, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthCell(_n_, pValue)
		return This.FindNthCellCS(_n_, pValue, 1)

		#< @FunctionAlternativeForms
	
		def FindNthOccurrenceOfCell(_n_, pCellValue)
			return This.FindNthCell(_n_, pCellValue)
	
		def FindNthValue(_n_, pCellValue)
			return This.FindNthCell(_n_, pCellValue)
	
		def FindNthOccurrenceOfValue(_n_, pCellValue)
			return This.FindNthCell(_n_, pCellValue)
	
		#>

	  #-----------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-----------------------------------------------------#
	
	def FindNthSubValueCS(_n_, pSubValue, pCaseSensitive)
		# If no occurrence is found, an empty list [] is returned. Otherwise,
		# the nth position is returned as a pair of numbers

		if isString(_n_)
			if StzFindFirst([ :First, :FirstOccurrence ], _n_) > 0
				_n_ = 1

			but StzFindFirst([ :Last, :LastOccurrence ], _n_) > 0
				_n_ = This.CountSubValueCS(pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindSubValueCS(pSubValue, pCaseSensitive)

		_nLen_ = len(_anPos_)

		_aResult_ = []
		_m_ = 0
		for i = 1 to _nLen_
			_line_ = _anPos_[i]
			_nLine2Len_ = len(_line_[2])
			for j = 1 to _nLine2Len_
				_m_ += 1
				if _m_ = _n_
					_aResult_ = [ _line_[1], _line_[2][j] ]
					exit 2
				ok
			next
		next

		return _aResult_
			
		def FindNthOccurrenceOfSubValueCS(_n_, pSubValue, pCaseSensitive)
			return This.FindNthSubValueCS(_n_, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValue(_n_, pSubValue)
		return This.FindNthSubValueCS(_n_, pSubValue, 1)

		def FindNthOccurrenceOfSubValue(_n_, pSubValueValue)
			return This.FindNthSubValue(_n_, pSubValue)

	  #-----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#-----------------------------------------------------------------------------------------#

	def FindFirstCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue, :Of ])

				return This.FindFirstCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue, :Part, :OfPart,
				:CellPart, :OfCellPart ])

				return This.FindFirstSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindFirstCellCS(pCellValueOrSubValue, pCaseSensitive)
		
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstCS(pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirst(pCellValueOrSubValue)
		return This.FindFirstCS(pCellValueOrSubValue, 1)
	
		def FindFirstOccurrence(pCellValueOrSubValue)
			return This.FindFirst(pCellValueOrSubValue)	

	  #----------------------------------------#
	 #   FIRST CELL AND LAST CELL POSITIONS   #
	#----------------------------------------#

	def FirstCellPosition()
		return [1, 1]

	def LastCellPosition()
		return [ This.NumberOfCol(), This.NumberOfRows() ]

	  #---------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL VALUE IN THE TABLE  #
	#---------------------------------------------------------#

	def FindFirstCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(1, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstValueCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueCS(pCellValue, pCaseSensitive)
			return This.FindFirstCellCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstCell(pValue)
		return This.FindFirstCellCS(pValue, 1)

		def FindFirstOccurrenceOfCell(pCellValue)
			return This.FindFirstCell(pCellValue)
	
		def FindFirstValue(pCellValue)
			return This.FindFirstCell(pCellValue)
	
		def FindFirstOccurrenceOfValue(pCellValue)
			return This.FindFirstCell(pCellValue)
	
	  #-------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-------------------------------------------------------#

	def FindFirstSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(1, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindFirstSubValueCS(pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValue(pSubValue)
		return This.FindFirstSubValueCS(pSubValue, 1)

		def FindFirstOccurrenceOfSubValue(pSubValueValue)
			return This.FindFirstSubValue(pSubValue)

	  #----------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#----------------------------------------------------------------------------------------#

	def FindLastCS(pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:Cell, :OfCell, :Value, :OfValue, :Of ])

				return This.FindLastCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[
				:SubValue, :OfSubValue, :Part, :OfPart,
				:CellPart, :OfCellPart ])

				return This.FindLastSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindLastCellCS(pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceCS(pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastCS(pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLast(pCellValue)
		return This.FindLastCS(pCellValue, 1)
	
		def FindLastOccurrence(pCellValue)
			return This.FindLast(pCellValue)	

	  #-------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE  #
	#-------------------------------------------#

	def FindLastCellCS(pCellValue, pCaseSensitive)
		return This.FindNthCellCS(:Last, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfCellCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

		def FindLastValueCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueCS(pCellValue, pCaseSensitive)
			return This.FindLastCellCS(pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastCell(pValue)
		return This.FindLastCellCS(pValue, 1)

		def FindLastOccurrenceOfCell(pCellValue)
			return This.FindLastCell(pCellValue)
	
		def FindLastValue(pCellValue)
			return This.FindLastCell(pCellValue)
	
		def FindLastOccurrenceOfValue(pCellValue)
			return This.FindLastCell(pCellValue)
	
	  #-----------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE  #
	#-----------------------------------------#

	def FindLastSubValueCS(pSubValue, pCaseSensitive)
		return This.FindNthSubValueCS(:Last, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.FindLastSubValueCS(pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValue(pSubValue)
			return This.FindLastSubValueCS(pSubValue, 1)

			def FindLastOccurrenceOfSubValue(pSubValueValue)
				return This.FindLastSubValue(pSubValue)

	  #==========================================================================================#
	 #  GETTING NUMBER OF OCCURRENCE A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE TABLE  #
	#==========================================================================================#

	def NumberOfOccurrenceCS(pValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrence( :OfCell = "Ali" ) #--> 2
		? _o1_.NumberOfOccurrence( :OfSubValue = "A" ) #--> 3
		*/

		if isList(pValue)
			if IsOneOfTheseNamedParamsList(pValue, [ :Cell, :OfCell, :Cells, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrenceOfCellCS(pValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pValue, [ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrenceOfSubValueCS(pValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def CountCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyOccurrenceCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		def HowManyOccurrencesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrence(pValue)
		return This.NumberOfOccurrenceCS(pValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		def Count(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowMany(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowManyOccurrence(pValue)
			return This.NumberOfOccurrence(pValue)

		def HowManyOccurrences(pValue)
			return This.NumberOfOccurrence(pValue)

		#>

	  #-------------------------------------------------------#
	 #  GETTING NUMBER OF OCCURRENCE OF A CELL IN THE TABLE  #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfCellCS(pCellValue, pCaseSensitive)
		return len( This.FindCellCS(pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def CountValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#==

		def HowManyCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrenceOfCellCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrencesOfCellsCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyValuesCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueCS(pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellCS(pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCell(pCellValue)
		return This.NumberOfOccurrenceOfCellCS(pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def NumberOfOccurrencesOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#--

		def NumberOfOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def NumberOfOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def CountValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#--

		def HowManyCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrenceOfCell(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrencesOfCells(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyValues(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrenceOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		def HowManyOccurrencesOfValue(pValue)
			return This.NumberOfOccurrenceOfCell(pValue)

		#>

	  #-----------------------------------------------------------#
	 #  GETTING NUMBER OF OCCURRENCE OF A SUBVALUE IN THE TABLE  #
	#-----------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		_aPos_ = This.FindSubValueCS(pSubValue, pCaseSensitive)
		_nLen_ = len(_aPos_)

		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += len(_aPos_[i][2])
		next

		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def CountSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManySubValueCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		def HowManySubValuesCS(pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueCS(pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValue(pSubValue)
		return This.NumberOfOccurrenceOfSubValueCS(pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def CountSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#--

		def HowManyOccurrenceOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrenceOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrencesOfSubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManyOccurrencesOfSubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManySubValue(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		def HowManySubValues(pSubValue)
			return This.NumberOfOccurrenceOfSubValue(pSubValue)

		#>

	   #------------------------------------------------------------------#
	  #  GETTING NUMBER OF OCCURRENCE OF A GIVEN CELL VALUE OR SUBVALUE  #
	 #  IN THE GIVEN CELL(S) OR COL(S) OR ROW(S)                        #
	#------------------------------------------------------------------#

	def NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([

		])

		? _o1_.NumberOfOccurrenceXT( :InCol = :NAME, :OfSubValue = "Ali" )
		*/

		if NOT isList(pInCellsOrColOrRow)
			StzRaise("Incorrect param type! pInCellsOrColOrRow must be a list.")
		ok

		_nResult_ = 0

		_oTempList_ = new stzList(pInCellsOrColOrRow)
		if _oTempList_.IsInCellNamedParam()
			_coll_ = pInCellsOrColOrRow[2][1]
			_nRow_ = pInCellsOrColOrRow[2][2]
			_nResult_ = This.NumberOfOccurrenceInCellCS(_coll_, _nRow_, pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInCellsNamedParam()
			_nResult_ = This.NumberOfOccurrenceInCellsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInColNamedParam()
			_nResult_ = This.NumberOfOccurrenceInColCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInColsNamedParam()
			_nResult_ = This.NumberOfOccurrenceInColsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInRowNamedParam()
			_nResult_ = This.NumberOfOccurrenceInRowCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		but _oTempList_.IsInRowsNamedParam()
			_nResult_ = This.NumberOfOccurrenceInRowsCS(pInCellsOrColOrRow[2], pValueOrSubValue, pCaseSensitive)

		else
			StzRaise("Syntax error! pInCellsOrColOrRow must be one of these lists ( :InCells = ..., :InCol = ..., or :InRow = ...).")

		ok

		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def CountCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)
		return This.NumberOfOccurrenceCSXT(pInCellsOrColOrRow, pValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def CountXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def HowManyOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		def HowManyOccurrencesXT(pInCellsOrColOrRow, pValueOrSubValue)
			return This.NumberOfOccurrenceXT(pInCellsOrColOrRow, pValueOrSubValue)

		#>

	  #=============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A CELL  #
	#=============================================================================#

	def ContainsCS(pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Dan", "Ali", "Sam" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.Contains( :Cell = "Ali" ) #--> TRUE
		? _o1_.Contains( :SubValue = "a" ) #--> TRUE
		*/

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzlist(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :Value ])
				return This.ContainsCellCS(pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :Part, :CellPart ])
				return This.ContainsSubValueCS(pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.ContainsCellCS(pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY
	
		def Contains(pCellValueOrSubValue)
			return This.ContainsCS(pCellValueOrSubValue, 1)

	def ContainsCellCS(pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		def ContainsValueCS(pCellValue, pCaseSensitive)
			return This.ContainsCellCS(pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsCell(pCellValue)
			return This.ContainsCellCS(pCellValue, 1)

			def ContainsValue(pCellValue)
				return This.ContainsCell(pCellValue)

	  #-----------------------------------------------#
	 #  CHECKING IF THE TABBLE CONTAINS A GIVEN ROW  #
	#-----------------------------------------------#

	def ContainsRowCS(paRow, pCaseSensitive)
		_bResult_ = 0

		if isList(paRow) and len(paRow) = This.NumberOfRows()

			_bResult_ = This.RowsQ().ContainsCS(paRow, pCaseSensitive)
		ok

		return _bResult_

	#-- WITHOUT CASESENSITIVITY

	def ContainsRow(paRow)
		return This.ContainsRowCS(paRow, 1)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN ROWS  #
	#-------------------------------------------------#

	def ContainsRowsCS(paRows, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? _o1_.ContainsCols([
			[ 10, "Imed", 52  ],
			[ 30, "Karim", 48 ]
		])

		#--> TRUE
		*/

		_bResult_ = 1
		_nLen_ = len(paRows)

		for i = 1 to _nLen_
			if NOT This.ContainsRowCS(paRows[i], pCaseSensitive)
				_bResult_ = 0
				exit
			ok

		next

		return _bResult_

		def ContainsTheseRowsCS(paRows, pCaseSensitive)
			return This.ContainsRowsCS(paRows, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsRows(paRows)
		return This.ContainsRowsCS(paRows, 1)

		def ContainsTheseRows(paRows)
			return This.ContainsRows(paRows)

	  #-------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN COLUMN  #
	#-------------------------------------------------#

	def ContainsColCS(paCol, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? _o1_.ContainsCol( :NAME = [ "Imed", "Hatem", "Karim" ] )
		#--> TRUE
		*/

		_bResult_ = 0

		if isList(paCol) and len(paCol) = 2 and
		   isString(paCol[1]) and This.HasColName(paCol[1]) and
		   isList(paCol[2]) and len(paCol[2]) = This.NumberOfRows()

			_cCol_ = paCol[1]
			_bResult_ = This.ColQ(_cCol_).IsEqualToCS(paCol[2], pCaseSensitive)
		ok

		return _bResult_

		def ContainsColumnCS(paCol, pCaseSensitive)
			return This.ContainsColCS(paCol, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsCol(paCol)
		return This.ContainsColCS(paCol, 1)

		def ContainsColumn(paCol)
			return This.ContainsCol(paCol)

	  #----------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS THE GIVEN COLUMNS  #
	#----------------------------------------------------#

	def ContainsColsCS(paCols, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :ID,	:NAME,		:AGE 	],
			[ 10,	"Imed",		52   	],
			[ 20,	"Hatem", 	46	],
			[ 30,	"Karim",	48	]
		])

		? _o1_.ContainsCols([
			:NAME = [ "Imed", "Hatem", "Karim" ],
			:AGE  = [ 52, 46, 48 ]
		])

		#--> TRUE
		*/

		_bResult_ = 1
		_nLen_ = len(paCols)

		for i = 1 to _nLen_
			if NOT This.ContainsColCS(paCols[i], pCaseSensitive)
				_bResult_ = 0
				exit
			ok

		next

		return _bResult_

		def ContainsTheseColsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

		def ContainsTheseColumnsCS(paCols, pCaseSensitive)
			return This.ContainsColsCS(paCols, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ContainsCols(paCols)
		return This.ContainsColsCS(paCols, 1)

		def containsTheseCols(paCols)
			return This.ContainsCols(paCols)

		def ContainsColumns(paCols)
			return This.ContainsCols(paCol)

		def ContainsTheseColumns(paCols)
			return This.ContainsCols(paCol)

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE TABLE CONTAINS CELLS THAT INCLUDE A GIVEN SUBVALUE  #
	#----------------------------------------------------------------------#

	def ContainsSubValueCS(pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceCS(:OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#-- WITHOUT CASESENSITIVITY

	def ContainsSubValue(pSubValue)
		return This.ContainsSubValueCS(pSubValue, 1)


	/// WORKING ON SOME CELLS //////////////////////////////////////////////////

	  #=====================================================#
	 #  FINDING A GIVEN VALUE OR SUBVALUE IN A GIVEN CELL  #
	#=====================================================#

	def FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
		_bValue_ = 0
		_bSubValue_ = 1

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				_bValue_ = 1
				_bSubValue_ = 0

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				_bValue_ = 0
				_bSubValue_ = 1
			ok
		
		ok

		if _bValue_
			_bResult_ = This.CellQ(pCellCol, pCellRow).IsEqualToCS(pCellValueOrSubValue, pCaseSensitive)
			return _bResult_

		else // bSubValue

			_anResult_ = []

			_oCell_ = This.CellQ(pCellCol, pCellRow)

			if @IsStzFindable(_oCell_)
				_anResult_ = _oCell_.FindCS(pCellValueOrSubValue, pCaseSensitive)

			ok

			return _anResult_
		ok

	#-- WITHOUT CASESENSITIVITY

	def FindInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.FindInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)

	  #---------------------------------------------#
	 #  FINDING A GIVEN VALUE INSIDE A GIVEN CELL  #
	#---------------------------------------------#

	def FindValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :Value = pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCell(pCellCol, pCellRow, pValue)
		return This.FindValueInCellCS(pCellCol, pCellRow, pValue, 1)

	  #------------------------------------------------#
	 #  FINDING A GIVEN SUBVALUE INSIDE A GIVEN CELL  #
	#------------------------------------------------#

	def FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindInCellCS(pCellCol, pCellRow, :SubValue = pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, 1)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN A GIVEN NUMBER OF CELLS  #
	#================================================================================================#

	def FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
		if NOT ( isList(paCells) and Q(paCells).IsListOfPairs() )
			StzRaise("Incorrect param type! paCells must be a list of pairs.")
		ok

		_bValue_ = 0
		_bSubValue_ = 1

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])

				_bValue_ = 1
				_bSubValue_ = 0
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])

				_bValue_ = 0
				_bSubValue_ = 1
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			ok

		ok

		_nLen_ = len(paCells)
		_aResult_ = []

		if _bValue_

			for i = 1 to _nLen_
				_cellValue_ = This.Cell(paCells[i][1], paCells[i][2])
				_oCell_ = Q(_cellValue_)

				if @BothAreNumbers(_cellValue_, pCellValueOrSubValue)

					if _cellValue_ = pCellValueOrSubValue
						_aResult_ + paCells[i]
					ok

				but @BothAreStrings(_cellValue_, pCellValueOrSubValue) or
				    @BothAreLists(_cellValue_, pCellValueOrSubValue)
				
					if _oCell_.IsEqualToCS(pCellValueOrSubValue, pCaseSensitive)
						_aResult_ + paCells[i]
					ok

				but @BothAreStzObjects( _cellValue_, pCellValueOrSubValue)

					if _oCell_.IsEqualTo(pCellValueOrSubValue)
						_aResult_ + paCells[i]
					ok

				ok
			next

		else // bSubValue

			for i = 1 to _nLen_
				_aPos_ = This.FindSubValueInCellCS(paCells[i][1], paCells[i][2], pCellValueOrSubValue, pCaseSensitive)
				if len(_aPos_) > 0
					_aResult_ + [ paCells[i], _aPos_ ]
				ok
			next
		ok

		return _aResult_
				
		#< @FunctionAlternativeForms

		def FindAllOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def FindOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def OccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def PositionsInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def FindInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindAllInCells(paCells, pCellValueOrSubValue)

		return This.FindAllInCellsCS(paCells, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def FindAllOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def FindOccurrencesInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
	
		def OccurrencesInCells(pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)
		
		def PositionsInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)

		def FindInCells(paCells, pCellValueOrSubValue)
			return This.FindAllInCells(paCells, pCellValueOrSubValue)

		#>

	  #--------------------------------------------#
	 #  FINDING A VALUE IN A GIVEN LIST OF CELLS  #
	#--------------------------------------------#

	def FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		_aCellsXT_ = This.TheseCellsAndTheirPositions(paCells)

		_aResult_ = []

		_nCellsXTLen_2 = len(_aCellsXT_)
		for i = 1 to _nCellsXTLen_2

			_cellValue_ = _aCellsXT_[i][1]
			_aCellPos_  = _aCellsXT_[i][2]

			if @BothAreNumbers(_cellValue_, pCellValue)
				if _cellValue_ = pCellValue
					_aResult_ + _aCellPos_
				ok

			but @BothAreStrings(_cellValue_, pCellValue) or
			    @BothAreLists(_cellValue_, pCellValue)

				if Q(_cellValue_).IsEqualToCS(pCellValue, pCaseSensitive)
					_aResult_ + _aCellPos_
				ok

			but @BothAreStzObjects(_cellValue_, pCellValue)

				if Q(_cellValue_).IsEqualTo(pCellValue)
					_aResult_ + _aCellPos_
				ok
			ok
		next

		return _aResult_

		#< @FunctionAlternativeForms
			
		def OccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def PositionsOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindValueInCellsCS(ppaCells, _cellValue_, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCells(pValue)
		return This.FindValueInCellsCS(pValue, 1)
			
		def OccurrencesOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(paCells, pCellValue)

		def PositionsOfValueInCells(paCells, pCellValue)
			return This.FindValueInCells(ppaCells, _cellValue_)
	
	  #-----------------------------------------------#
	 #  FINDING A SUBVALUE IN A GIVEN LIST OF CELLS  #
	#-----------------------------------------------#

	def FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		_aCellsXT_ = This.TheseCellsAndTheirPositions(paCells)

		_aResult_ = []

		_nCellsXTLen_ = len(_aCellsXT_)
		for i = 1 to _nCellsXTLen_

			_cellValue_ = _aCellsXT_[i][1]
			_oCellValue_ = Q(_cellValue_)

			_aCellPos_  = _aCellsXT_[i][2]

			if @BothAreStrings(_cellValue_, pSubValue) or
			   @BothAreLists(_cellValue_, pSubValue)

				if _oCellValue_.ContainsCS(pSubValue, pCaseSensitive)
					_aResult_ + [ _aCellPos_, _oCellValue_.FindAllCS(pSubValue, pCaseSensitive) ]
				ok

			but @BothAreNumbers(_cellValue_, pSubValue) or
				( (isString(_cellValue_) and isNumber(pSubValue)) or
			     	  (isNumber(_cellValue_) and @IsNumberInString(pSubValue))
				)

				_oStzStrCellValue_ = new stzString(""+ _cellValue_)

				if _oStzStrCellValue_.Contains(''+ pSubValue)
					_aResult_ + [ _aCellPos_, _oStzStrCellValue_.FindAll(""+ pSubValue) ]
				ok
			ok

		next

		return _aResult_

		#< @FunctionAlternativeForms

		def OccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def PositionsOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCells(paCells, pSubValue)
		return This.FindSubValueInCellsCS(paCells, pSubValue, 1)

		#< @FunctionAlternativeForms

		def OccurrencesOfSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCells(paCells, pSubValue)

		def PositionsOfSubValueInCells(paCells, pSubValue)
			return This.FindSubValueInCells(paCells, pSubValue)

		#>

	  #---------------------------------------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#---------------------------------------------------------------------------------------------#

	def FindNthInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindNthValueInCellsCS(_n_, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindNthSubValueInCellsCS(_n_, paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindNthValueInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInCellsCS(_n_, paCells, pCellValueOrSubValue, pCaseSensitive)		

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCells(_n_, paCells, pCellValueOrSubValue)
		return This.FindNthInCellsCS(_n_, paCells, pCellValueOrSubValue, 1)
	
		def FindNthOccurrenceInCells(_n_, paCells, pCellValueOrSubValue)
			return This.FindNthInCells(_n_, paCells, pCellValueOrSubValue)	

	  #----------------------------------------------#
	 #  FINDING NTH VALUE IN A GIVEN LIST OF CELLS  #
	#----------------------------------------------#

	def FindNthValueInCellsCS(_n_, paCells, pCellValue, pCaseSensitive)
		# Returns the cell position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(_n_)
			if StzFindFirst([ :First, :FirstOccurrence, :FirstValue ], _n_) > 0
				_n_ = 1

			but StzFindFirst([ :Last, :LastOccurrence, :LastValue ], _n_) > 0
				_n_ = This.NumberOfOccurrenceInCellsCS(paCells, pCellValue, pCaseSensitive)
			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindValueInCellsCS( paCells, pCellValue, pCaseSensitive)

		_aResult_ = []

		if len(_anPos_) > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		def FindNthOccurrenceOfValueInCellCS(_n_, paCells, pCellValue, pCaseSensitive)
			return This.FindNthValueInCellCS(_n_, paCells, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCells(_n_, paCells, pValue)
		return This.FindNthCellCS(_n_, pValue, 1)

		def FindNthOccurrenceOfValueInCells(_n_, paCells, pCellValue)
			return This.FindNthValueInCells(_n_, paCells, pValue)
	
	  #-------------------------------------------------#
	 #  FINDING NTH SUBVALUE IN A GIVEN LIST OF CELLS  #
	#-------------------------------------------------#

	def FindNthSubValueInCellsCS(_n_, paCells, pSubValue, pCaseSensitive)
		# Returns the subvalue position as a pair of numbers
		# Returns an empty pair [] if no occurrence is found.

		if isString(_n_)
			if StzFindFirst([ :First, :FirstOccurrence, :FirstSubValue ], _n_) > 0
				_n_ = 1

			but StzFindFirst([ :Last, :LastOccurrence, :LastSubValue ], _n_) > 0
				_n_ = This.CountSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

			ok
		ok

		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		_nLen_ = len(_anPos_)

		_aResult_ = []
		_m_ = 0

		for i = 1 to _nLen_
			_line_ = _anPos_[i]
			_nLen2_ = len(_line_[2])

			for j = 1 to _nLen2_
				_m_ += 1
				if _m_ = _n_
					_aResult_ = [ _line_[1], _line_[2][j] ]
					exit 2
				ok
			next
		next

		return _aResult_
			
		def FindNthOccurrenceOfSubValueInCellsCS(_n_, paCells, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInCellsCS(_n_, paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCells(_n_, paCells, pSubValue)
		return This.FindNthSubValueInCellsCS(_n_, paCells, pSubValue, 1)

		def FindNthOccurrenceOfSubValueInCells(_n_, paCells, pSubValueValue)
			return This.FindNthSubValueInCells(_n_, paCells, pSubValue)

	  #------------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#------------------------------------------------------------------------------------------------#

	def FindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.FindFirstSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindFirstValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FFindFirstInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCells(paCells, pCellValueOrSubValue)
		return This.FindFirstInCellsCS(paCells, pCellValueOrSubValue, 1)
	
		def FindFirstOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.FindFirstInCells(paCells, pCellValueOrSubValue)	

	  #--------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN CELL IN THE PROVIDED LIST OF CELLS  #
	#--------------------------------------------------------------------------#

	def FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(1, paCells, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindFirstValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCells(paCells, pValue)
		return This.FindFirstValueInCellCS(paCells, pValue, 1)

		def FindFirstOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindFirstValueInCells(paCells, pValue)

	  #------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN THE PROVIDED LIST OF CELLS  #
	#------------------------------------------------------------------------------#

	def FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(1, paCells, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCells(paCells, pSubValue)
		return This.FindFirstSubValueInCellsCS(paCells, pSubValue, 1)

		def FindFirstOccurrenceOfSubValueInCells(paCells, pSubValueValue)
			return This.FindFirstSubValueInCells(paCells, pSubValue)

	  #-----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------------------------------------#

	def FindLastInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfPart ])
				return This.FindLastSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")
			ok
		ok

		return This.FindLastValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.FFindLastnCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)	

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCells(paCells, pCellValueOrSubValue)
		return This.FindLastInCellsCS(paCells, pCellValueOrSubValue, 1)
	
		def FindLastOccurrenceInCells(paCells, pCellValueOrSubValue)
				return This.FindLastInCells(paCells, pCellValueOrSubValue)	

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN VAULUE IN SOME GIVEN CELLS  #
	#-----------------------------------------------------------------#

	def FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(:Last, paCells, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.FindLastValueInCellsCS(paCells, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCells(paCells, pValue)
		return This.FindLastValueInCellCS(paCells, pValue, 1)

		def FindLastOccurrenceOfValueInCells(paCells, pCellValue)
			return This.FindLastValueInCells(paCells, pValue)

	  #-------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN SUBVALUE IN SOME GIVEN CELLS  #
	#-------------------------------------------------------------------#
	
	def FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(:Last, paCells, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCells(paCells, pSubValue)
		return This.FindLastSubValueInCellsCS(paCells, pSubValue, 1)

		def FindLasttOccurrenceOfSubValueInCells(paCells, pSubValueValue)
			return This.FindLastSubValueInCells(paCells, pSubValue)

	  #----------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF  CELLS  #
	#----------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellsCS(paCells, pCellValueOrSubValue, 1)
	
		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)
	
		def CountInCells(paCells, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCells(paCells, pCellValueOrSubValue)

		#>

	  #-------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF  CELLS  #
	#-------------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
		_nResult_ = len( This.FindValueInCellsCS(paCells, pCellValue, pCaseSensitive) )
		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def CountValueInCellsCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellsOfValueCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsOfValueCS(paCells, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pCellValue, 1)

		#--

		def NumberOfOccurrenceOfValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def CountValueInCells(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)
		#--

		def NumberOfOccurrencesInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		def NumberOfOccurrenceInCellsOfValue(paCells, pCellValue)
			return This.NumberOfOccurrencesOfValueInCells(paCells, pCellValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A SUBVALUE IN A GIVEN LIST OF  CELLS  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		_anPos_ = This.FindSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		_nLen_ = len(_anPos_)

		_nResult_ = 0

		for i = 1 to _nLen_
			_nResult_ += len(_anPos_[i][2])
		next

		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def CountSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellsOfSubValueCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellsOfSubValueCS(paCells, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfValueInCellsCS(paCells, pSubValue, 1)

	#--

	def NumberOfOccurrenceOfSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	def CountSubValueInCells(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	#--

	def NumberOfOccurrencesInCellsOfSubValue(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	def NumberOfOccurrenceInCellsOfSubValue(paCells, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCells(paCells, pSubValue)

	#>

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL VALUE OR SUBVALUE  #
	#----------------------------------------------------------------------#

	def CellsContainCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.CellsContainValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.CellsContainSubValueCS(paCells, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.CellsContainValueCS(paCells, pCellValueOrSubValue, pCaseSensitive)

		def ContainsInCellsCS(paCells, pCellValueOrSubValue, pCaseSensitive)
			return This.CellsContainCS(paCells, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContain(paCells, pCellValueOrSubValue)
		return This.CellsContainCS(paCells, pCellValueOrSubValue, 1)

		def ContainsInCells(paCells, pCellValueOrSubValue)
			return This.CellsContain(paCells, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	def CellsContainValueCS(paCells, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellsCS(paCells, pValue, pCaseSensitive) ) > 0
			return 1
		else
			return 0
		ok

		def ContainsValueInCellsCS(paCells, pValue, pCaseSensitive)
			return This.CellsContainValueCS(paCells, pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContainValue(paCells, pValue)
		return This.CellsContainValueCS(paCells, pValue, 1)

		def ContainsValueInCells(paCells, pValue)
			return This.CellsContainValue(paCells, pValue)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELLS CONTAIN A GIVEN CELL SUBVALUE  #
	#-------------------------------------------------------------#

	def CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)
		_aTemp_ = This.FindFirstSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
		if isList(_aTemp_) and len(_aTemp_) > 0
			return 1
		else
			return 0
		ok

		def ContainsSubValueInCellsCS(paCells, pSubValue, pCaseSensitive)
			return This.CellsContainSubValueCS(paCells, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellsContainSubValue(paCells, pSubValue)
		return This.CellsContainSubValueCS(paCells, pSubValue, 1)

		def ContainsSubValueInCells(paCells, pSubValue)
			return This.CellsContainSubValue(paCells, pSubValue)

	  #========================================================#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN A GIVEN CELL  #
	#========================================================#

	def FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
		if NOT isNumber(_n_)
			StzRaise("Incorrect param type! n must be a number.")
		ok

		_anPos_ = FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		_anResult_ = _anPos_[_n_]

		#TODO // Implement a more performant alortithm by adding FindNext...()

		return _anResult_

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindNthSubValueInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindNthOccurrenceOfSubValueInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)
		return This.FindNthInCellCS(_n_, pCellCol, pCellRow, pSubValue, 1)
	
		#< @FunctionAlternativeForm

		def FindNthOccurrenceInCell(_n_, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)

		def FindNthSubValueInCell(_n_, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)
			
		def FindNthOccurrenceOfSubValueInCell(_n_, pCellCol, pCellRow, pSubValue)
			return This.FindNthInCell(_n_, pCellCol, pCellRow, pSubValue)

		#>

	  #-----------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A GIVEN SUBVALUE IN A CELL)  #
	#-----------------------------------------------------------#

	def FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindNthInCellCS(1, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindFirstSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindFirstOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCell(pCellCol, pCellRow, pSubValue)
		return This.FindFirstInCellCS(pCellCol, pCellRow, pSubValue, 1)
	
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInCell(pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)

		def FindFirstSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)
			
		def FindFirstOccurrenceOfSubValueInCell( pCellCol, pCellRow, pSubValue)
			return This.FindFirstInCell(pCellCol, pCellRow, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN SOME GIVEN CELL  #
	#----------------------------------------------------------------------------------------------#

	def FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		return This.FindNthInCellCS(:Last, pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def FindLastSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			
		def FindLastOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCell(pCellCol, pCellRow, pSubValue)
		return This.FindLastInCellCS(pCellCol, pCellRow, pSubValue, 1)
	
		#< @FunctionAlternativeForm

		def FindLastOccurrenceInCell(pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)

		def FindLastSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)
			
		def FindLastOccurrenceOfSubValueInCell( pCellCol, pCellRow, pSubValue)
			return This.FindLastInCell(pCellCol, pCellRow, pSubValue)

		#>

	  #--------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL (OR A SUVALUE OF THE CELL) IN A GIVEN LIST OF CELL  #
	#--------------------------------------------------------------------------------------#

	def NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				return This.NumberOfOccurrencesOfValueInCellCS( pCellCol, pCellRow, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pCellValueOrSubValue[2], pCaseSensitive)

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		def CountInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)
		return NumberOfOccurrencesInCellCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)
	
		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)
	
		def CountInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.NumberOfOccurrencesInCell(pCellCol, pCellRow, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A CELL VALUE IN A GIVEN LIST OF CELL  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
		_nResult_ = len( This.FindValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive) )
		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		def CountValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellOfValueCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceInCellOfValueCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)
		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfValueInCell(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		def CountValueInCell(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)
		#--

		def NumberOfOccurrencesInCellOfValue(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		def NumberOfOccurrenceInCellOfValue(pCellCol, pCellRow, pCellValue)
			return This.NumberOfOccurrencesOfValueInCell(pCellCol, pCellRow, pCellValue)

		#>

	  #---------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A SUBVALUE IN A GIVEN LIST OF CELL  #
	#---------------------------------------------------------------#

	def NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		_nResult_ = len( This.FindSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive) )
		return _nResult_

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def CountSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesInCellOfSubValueCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS( pCellCol, pCellRow, pSubValue, pCaseSensitive)

		def NumberOfOccurrenceInCellOfSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrencesOfSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfValueInCellCS(pCellCol, pCellRow, pSubValue, 1)

	#--

	def NumberOfOccurrenceOfSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	def CountSubValueInCell(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	#--

	def NumberOfOccurrencesInCellOfSubValue(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	def NumberOfOccurrenceInCellOfSubValue(pCellCol, pCellRow, pSubValue)
		return This.NumberOfOccurrencesOfSubValueInCell(pCellCol, pCellRow, pSubValue)

	#>

	  #----------------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE OR SUBVALUE  #
	#----------------------------------------------------------------------#

	def CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
		_bValue_ = 0
		_bSubValue_ = 1

		if isList(pCellValueOrSubValue)

			_oParam_ = new stzList(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Cell, :OfCell, :Value, :OfValue, :Of ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]
				_bValue_ = 1
				_bSubValue_ = 0
				
			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :OfSubValue, :Part, :OfPart, :CellPart, :OfCellPart ])
				pCellValueOrSubValue = pCellValueOrSubValue[2]

			else
				StzRaise("Incorrect param format! pCellValueOrSubValue must take the form :Cell = ... or :SubValue = ...")

			ok
		ok

		_bResult_ = 0

		if _bValue_
			_bResult_ = This.CellContainsValueCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		else // bSubValue
			_bResult_ = This.CellContainsSubValueCS(pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

		ok

		def ContainsInCellCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)
			return This.CellContainsCS( pCellCol, pCellRow, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContains(pCellCol, pCellRow, pCellValueOrSubValue)
		return This.CellContainsCS(pCellCol, pCellRow, pCellValueOrSubValue, 1)

		def ContainsInCell(pCellCol, pCellRow, pCellValueOrSubValue)
			return This.CellContains( pCellCol, pCellRow, pCellValueOrSubValue)

	  #----------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL VALUE  #
	#----------------------------------------------------------#

	def CellContainsValueCS( pCellCol, pCellRow, pValue, pCaseSensitive)
		if len( This.FindFirstValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive) ) > 0
			return 1
		else
			return 0
		ok

		def ContainsValueInCellCS(pCellCol, pCellRow, pValue, pCaseSensitive)
			return This.CellContainValueCS(pCellCol, pCellRow, pValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContainValue(pCellCol, pCellRow, pValue)
		return This.CellContainValueCS(pCellCol, pCellRow, pValue, 1)

		def ContainsValueInCell(pCellCol, pCellRow, pValue)
			return This.CellContainValue( pCellCol, pCellRow, pValue)

	  #-------------------------------------------------------------#
	 #  CHECKING IF THE GIVEN CELL CONTAINS A GIVEN CELL SUBVALUE  #
	#-------------------------------------------------------------#

	def CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
		_nPos_ = This.FindFirstSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

		if _nPos_ > 0
			return 1
		else
			return 0
		ok

		def ContainsSubValueInCellCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)
			return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def CellContainsSubValue(pCellCol, pCellRow, pSubValue)
		return This.CellContainsSubValueCS(pCellCol, pCellRow, pSubValue, 1)

		def ContainsSubValueInCell(pCellCol, pCellRow, pSubValue)
			return This.CellContainsSubValue(pCellCol, pCellRow, pSubValue)

	/// WORKING ON ROWS //////////////////////////////////////////////////////////////////////

	  #======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#======================================================================================#

	def FindInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? _o1_.FindInRow(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? _o1_.FindInRow(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? _o1_.FindInRow( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		_aCellsPos_ = This.RowCellsAsPositions(pRow)

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.FindValueInCellsCS(_aCellsPos_, pCellValueOrSubValue, pCaseSensitive)


		#-- WITHOUT CASESENSITIVITY

		def FindInRow(pRow, pCellValueOrSubValue)
			return This.FindInRowCS(pRow, pCellValueOrSubValue, 1)

	def FindValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.RowAsPositions(pRow), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInRow(pRow, pCellValue)
			return This.FindValueInRowCS(pRow, pSubValue, 1)

	def FindSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInRow(pRow, pSubValue)
			return This.FindValueInRowCS(pRow, pSubValue, 1)

	  #=========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROW  #
	#=========================================================================================#

	def FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :N, :Nth, :Occurrence ])
			_n_ = _n_[2]
		ok

		if isList(pRow) and IsOneOfTheseNamedParamsList(pRow,[ :Row, :InRow ])
			pRow = pRow[2]
		ok

		return This.FindNthInCellsCS(_n_, This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInRowCS(_n_, pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInRow(_n_, pRow, pCellValueOrSubValue)
			return This.FindNthInRowCS(_n_, pRow, pCellValueOrSubValue, 1)
		
			def FindNthOccurrenceInRow(_n_, pRow, pCellValueOrSubValue)
				return This.FindNthInRow(_n_, pRow, pCellValueOrSubValue)

	def FindNthValueInRowCS(_n_, pRow, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(_n_, This.RowAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInRow(_n_, pRow, pCellValue)
			return This.FindNthValueInRowCS(_n_, pRow, pCellValue, 1)

			def FindNthOccurrenceOfValueInRow(_n_, pRow, pCellValue)
				return This.FindNthValueInRow(_n_, pRow, pCellValue)

	def FindNthSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.RowAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowCS(_n_, pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInRow(_n_, pRow, pSubValue)
			return This.FindNthSubValueInRowCS(_n_, pRow, pSubValue, 1)

			def FindNthOccurrenceOfSubValueInRow(_n_, pRow, pSubValue)
				return This.FindNthSubValueInRow(_n_, pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(1, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInRow(pRow, pCellValueOrSubValue)
			return This.FindFirstInRowCS(pRow, pCellValueOrSubValue, 1)
		
			def FindFirstOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindFirstInRow(pRow, pCellValueOrSubValue)

	def FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInRow(pRow, pCellValue)
			return This.FindFirstValueInRowCS(pRow, pCellValue, 1)

			def FindFirstOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindFirstValueInRow(pRow, pCellValue)

	def FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def FindFirstOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInRow(pRow, pSubValue)
			return This.FindFirstSubValueInRowCS(pRow, pSubValue, 1)

			def FindFirstOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindFirstSubValueInRow(pRow, pSubValue)

	  #-------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A ROW  #
	#-------------------------------------------------------------------------#

	def FindLastInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowCS(:Last, pRow, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastInRow(pRow, pCellValueOrSubValue)
			return This.FindLastInRowCS(pRow, pCellValueOrSubValue, 1)
		
			def FindLastOccurrenceInRow( pRow, pCellValueOrSubValue)
				return This.FindLastInRow(pRow, pCellValueOrSubValue)

	def FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)
		return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInRowCs(pRow, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowCS(pRow, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInRow(pRow, pCellValue)
			return This.FindLastValueInRowCS(pRow, pCellValue, 1)

			def FindLastOccurrenceOfValueInRow(pRow, pCellValue)
				return This.FindLastValueInRow(pRow, pCellValue)

	def FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInRowCS(pRow, pSubValue, 1)

		def FindLastOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInRow(pRow, pSubValue)
			return This.FindLastSubValueInRowCS(pRow, pSubValue, 1)

			def FindLastOccurrenceOfSubValueInRow(pRow, pSubValue)
				return This.FindLastSubValueInRow(pRow, pSubValue)

	  #---------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A ROW  #
	#---------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrenceInRow( :OfCell = "Ali" ) #--> 2
		? _o1_.CountInRow( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.RowAsPositions(pRow), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		def CountInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRowCS(pRow, pValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRow(pRow, pValue)

		def CountInRow(pRow, pValue)
			return This.NumberOfOccurrenceInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, pCaseSensitive)
		return len( This.FindCellInRowCS(pRow, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountCellInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountCellsInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountOfValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		def CountValueInRowCS(pRow, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInRow(pRow, pCellValue)
			return This.NumberOfOccurrenceOfCellInRowCS(pRow, pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def NumberOfOccurrencesOfCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountCellInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountCellsInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		#--

		def NumberOfOccurrenceOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		def CountOfValueInRowInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRowInRow(pRow, pRow, pValue)

		def CountValueInRow(pRow, pValue)
			return This.NumberOfOccurrenceOfCellInRow(pRow, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowAsPositions(pRow), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRowCS(pRow, pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		def CountOfSubValueInRow(pRow, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRow(pRow, pSubValue)

		#>

	  #============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A ROW  #
	#============================================================================#

	def ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? _o1_.ContainsInRow(2, :Value = "Abraham") #--> TRUE
		
		? _o1_.ContainsInRow(2, :SubValue = "AL") #--> FALSE
		? _o1_.ContainsInRowCS(2, :SubValue = "AL", 0) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.RowAsPositions(pRow), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowContainsCS(pRow, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInRow(pRow, pCellValueOrSubValue)
			return This.ContainsInRowCS(pRow, pCellValueOrSubValue, 1)

			def RowContains(pRow, pCellValueOrSubValue)
				return This.ContainsInRow(pRow, pCellValueOrSubValue)

	def ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def RowContainsCellCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		def ContainsValueInRowCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		def RowContainsValueCS(pRow, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowCS(pRow, pCellValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def ContainsCellInRow(pRow, pCellValue)
			return This.ContainsCellInRowCS(pRow, pCellValue, 1)

			def RowContainsCell(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)

			def ContainsValueInRow(pRow, pCellValue)
				return This.ContainsCellInRow(pRow, pCellValue)
	
	def ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowCS(pRow, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		def RowContainsSubValueCS(pRow, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInRow(pRow, pSubValue)
			return This.ContainsSubValueInRowCS(pRow, pSubValue, 1)

			def RowContainsSubValue(pRow, pSubValue)
				return This.ContainsSubValueInRow(pRow, pSubValue)

	/// WORKING ON A LIST OF ROWS /////////////////////////////////////////////////////////////

	  #=======================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#=======================================================================================#

	def FindInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME,	:JOB 	     ],

			[ "Andy", 	"Maestro",	"Programmer" ],
			[ "Ali", 	"Abraham",	"Designer"   ],
			[ "Alia",	"Ali",		"Lawer"      ]
		])

		? _o1_.FindInRows( [ 2, 3 ], :Value = "Ali" )
		#--> [ [ 1, 2], [2, 3] ]

		? _o1_.FindInRowsCS(  [ 1, 3 ], :SubValue = "a", 0 )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1, 4] ],
			[ [3, 1], [6] ],
			[ [3, 3], [2] ]
		     ]
		*/

		_aCellsPositions_ = This.RowsToCellsAsPositions(panRows)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
		
			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
				
			ok
		ok

		return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInRows(panRows, pCellValueOrSubValue)
		return This.FindInRowsCS(panRows, pCellValueOrSubValue, 1)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN ROWS  #
	#------------------------------------------------------------#

	def FindValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInRows(panRows, pCellValue)
		return This.FindValueInRowsCS(panRows, pSubValue, 1)

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.RowsAsPositions(panRows), pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInRows(panRows, pSubValue)
		return This.FindValueInRowsCS(panRows, pSubValue, 1)

	  #==========================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN ROWS  #
	#==========================================================================================#

	def FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok

		panRows = This.RowsToNames(panRows)

		return This.FindNthInCellsCS(_n_, This.RowsAsPositions(panRows), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInRows(_n_, panRows, pCellValueOrSubValue)
		return This.FindNthInRowsCS(_n_, panRows, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForm

		def FindNthOccurrenceInRows(_n_, panRows, pCellValueOrSubValue)
			return This.FindNthInRows(_n_, panRows, pCellValueOrSubValue)

		#>

	  #------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN ROWS  #
	#------------------------------------------------------#

	def FindNthValueInRowsCS(_n_, panRows, pCellValue, pCaseSensitive)

		if isList(panRows) and
		   IsOneOfTheseNamedParamsList(panRows,[ :Rows, :InRows, :OfRows ])

			panRows = panRows[2]
		ok

		return This.FindNthInCellsCS(_n_, This.RowsAsPositions(panRows), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfValueInRowsCs(_n_, panRows, pCellValue, pCaseSensitive)
			return This.FindNthValueInRowsCS(_n_, panRows, pCellValue, pCaseSensitive)

		#>


	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInRows(_n_, panRows, pCellValue)
		return This.FindNthValueInRowsCS(_n_, panRows, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceOfValueInRows(_n_, panRows, pCellValue)
			return This.FindNthValueInRows(_n_, panRows, pCellValue)

		#>

	  #----------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN ROWS  #
	#----------------------------------------------------------#

	def FindNthSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)
		_anPos_ = This.FindSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		_aResult_ = []
		if _n_ > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		#< @FunctionAlternativeForm

		def FindNthOccurrenceOfSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInRowsCS(_n_, panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInRows(_n_, panRows, pSubValue)
		return This.FindNthSubValueInRowsCS(_n_, panRows, pSubValue, 1)

		#< @FuntionAlternativeForm

		def FindNthOccurrenceOfSubValueInRows(_n_, panRows, pSubValue)
			return This.FindNthSubValueInRows(_n_, panRows, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF ROWS  #
	#----------------------------------------------------------------------------------------#

	def FindFirstInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowsCS(1, panRows, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInRows(panRows, pCellValueOrSubValue)
		return This.FindFirstInRowsCS(panRows, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForm

		def FindFirstOccurrenceInRows(panRows, pCellValueOrSubValue)
			return This.FindFirstInRows(panRows, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A GIVEN LIST OF ROWS  #
	#--------------------------------------------------------------#

	def FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRowsCs(panRows, pCellValue, pCaseSensitive)
			return This.FindFirstValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInRows(panRows, pCellValue)
		return This.FindFirstValueInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfValueInRows(panRows, pCellValue)
			return This.FindFirstValueInRows(panRows, pCellValue)

		#>

	  #------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#------------------------------------------------------------------#

	def FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInRows(panRows, pSubValue)
		return This.FindFirstSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindFirstOccurrenceOfSubValueInRows(panRows, pSubValue)
			return This.FindFirstSubValueInRows(panRows, pSubValue)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF ROWS  #
	#----------------------------------------------------------------------------------------#

	def FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInRowsCS(:Last, pRow, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInRows(panRows, pCellValueOrSubValue)
		return This.FindLastInRowsCS(panRows, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForm

		def FindLastOccurrenceInRows(panRows, pCellValueOrSubValue)
			return This.FindLastInRows(panRows, pCellValueOrSubValue)

		#>

	  #-------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE IN A LIST OF ROWS  #
	#-------------------------------------------------------------#

	def FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)
		return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.FindLastValueInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInRows(panRows, pCellValue)
		return This.FindLastValueInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfValueInRows(panRows, pCellValue)
			return This.FindLastValueInRows(panRows, pCellValue)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#-----------------------------------------------------------------#

	def FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInRows(panRows, pSubValue)
		return This.FindLastSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastOccurrenceOfSubValueInRows(panRows, pSubValue)
			return This.FindLastSubValueInRows(panRows, pSubValue)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A GIVEN LIST OF ROWS  #
	#------------------------------------------------------------------------------------------#

	def NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceInCellsCS(This.RowsAsPositions(panRows), pValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)

		def CountInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
		return This.NumberOfOccurrenceInRowsCS(panRows, pValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrencesInRows(panRows, pValueOrSubValue)
			return This.NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
	
		def CountInRows(panRows, pValueOrSubValue)
			return This.NumberOfOccurrenceInRows(panRows, pValueOrSubValue)
	
		#>

	  #----------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A LIST OF ROWS  #
	#----------------------------------------------------#

	def NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		return len( This.FindCellInRowsCS(panRows, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountCellInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		def CountOfValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def CountValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCellInRows(panRows, pCellValue)
		return This.NumberOfOccurrenceOfCellInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForm

		def NumberOfOccurrencesOfCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountOfCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountCellInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def NumberOfOccurrenceOfValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountOfValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		def CountValueInRows(panRows, pCellValue)
			return This.NumberOfOccurrenceOfCellInRows(panRows, pCellValue)

		#>

	  #--------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF ROWS  #
	#--------------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.RowsAsPositions(panRows), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		def CountOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInRows(panRows, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)

		def CountOfSubValueInRows(panRows, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInRows(panRows, pSubValue)

		#>

	  #===========================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A GIVEN LIST OF ROWS  #
	#===========================================================================================#

	def ContainsInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		if isList(panRows) and
		   IsOneOfTheseNamedParamsList(panRows,[ :Rows, :InRows, :OfRows ])
			pRow = pRow[2]
		ok

		_aRowPos_ = This.RowsAsPositions(panRows)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(_aRowPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(_aRowPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.ContainsValueInCellsCS(_aRowPos_, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def RowsContainCS(panRows, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInRowsCS(panRows, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def ContainsInRows(panRows, pCellValueOrSubValue)
		return This.ContainsInRowsCS(panRows, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForm

		def RowsContain(panRows, pCellValueOrSubValue)
			return This.ContainsInRows(panRows, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------#
	 #  CHECKING IF A GIVEN LIST OF ROWS CONTAIN THE GIVEN CELL  #
	#-----------------------------------------------------------#

	def ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowsCS(panRows, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def RowsContainCellCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def ContainsValueInRowsCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		def RowsContainValueCS(panRows, pCellValue, pCaseSensitive)
			return This.ContainsCellInRowsCS(panRows, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsCellInRows(panRows, pCellValue)
		return This.ContainsCellInRowsCS(panRows, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def RowsContainCell(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)

		def ContainsValueInRows(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)

		def RowsContainValue(panRows, pCellValue)
			return This.ContainsCellInRows(panRows, pCellValue)
	
		#>

	  #-------------------------------------------------------#
	 #  CHECKING IF A LIST OF ROWS CONTAIN A GIVEN SUBVALUE  #
	#-------------------------------------------------------#
	
	def ContainsSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInRowsCS(panRows, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForm

		def RowsContainSubValueCS(panRows, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInRowsCS(panRows, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInRows(panRows, pSubValue)
		return This.ContainsSubValueInRowsCS(panRows, pSubValue, 1)

		#< @FunctionAlternativeForm
		
		def RowsContainSubValue(panRows, pSubValue)
			return This.ContainsSubValueInRows(panRows, pSubValue)
		
		#>

	/// WORKING ON COLUMNS //////////////////////////////////////////////////////////////////////

	  #=========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#=========================================================================================#

	def FindInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])

		? _o1_.FindInCol( :FIRSTNAME, :Value = "Ali" )
		#--> [ [ 1, 2], [1, 3] ]

		? _o1_.FindInCol( :FIRSTNAME, :SubValue = "a" ) #--> [ ]

		? _o1_.FindInColCS( :LASTNAME, :SubValue = "a", 0 )
		#--> [
			[ [2, 1], [2]    ],
			[ [2, 2], [1, 4, 6] ],
			[ [2, 3], [1] ]
		     ]
		*/

		pCol = This.ColToName(pCol)
		_aCellsPositions_ = This.ColAsPositions(pCol)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCol(pCol, pCellValueOrSubValue)
		return This.FindInColCS(pCol, pCellValueOrSubValue, 1)

		def FindInColumn(pCol, pCellValueOrSubValue)
			return This.FindInCol(pCol, pCellValueOrSubValue)

	  #--------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN COLUMN  #
	#--------------------------------------------------------------#

	def FindValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.ColAsPositions(pCol), pCellValue, pCaseSensitive)

		def FindValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindValueInColCS(pCol, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCol(pCol, pCellValue)
		return This.FindValueInColCS(pCol, pSubValue, 1)

		def FindValueInColumn(pCol, pCellValue)
			return This.FindValueInCol(pCol, pCellValue)

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive)

		def FindSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCol(pCol, pSubValue)
		return This.FindValueInColCS(pCol, pSubValue, 1)

		def FindSubValueInColumn(pCol, pSubValue)
			return This.FindSubValueInCol(pCol, pSubValue)

	  #============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMN  #
	#============================================================================================#

	def FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok

		pCol = This.ColToName(pCol)

		return This.FindNthInCellsCS(_n_, This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCol(_n_, pCol, pCellValueOrSubValue)
		return This.FindNthInColCS(_n_, pCol, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindNthInColumn(_n_, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(_n_, pCol, pCellValueOrSubValue)

		def FindNthOccurrenceInCol(_n_, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(_n_, pCol, pCellValueOrSubValue)

		def FindNthOccurrenceInColumn(_n_, pCol, pCellValueOrSubValue)
			return This.FindNthInCol(_n_, pCol, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN COLUMN  #
	#--------------------------------------------------------#

	def FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		if isList(pCol) and IsOneOfTheseNamedParamsList(pCol,[
					:Col, :InCol, :OfCol,
					:Column, :InColumn, :OfColumn
				    ])

			pCol = pCol[2]
		ok

		return This.FindNthInCellsCS(_n_, This.ColAsPositions(pcol), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumCS(_n_, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColCs(_n_, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnCS(_n_, pCol, pCellValue, pCaseSensitive)
			return This.FindNthValueInColCS(_n_, pCol, pCellValue, pCaseSensitive)

		#>


	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCol(_n_, pCol, pCellValue)
		return This.FindNthValueInColCS(_n_, pCol, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindNthValueInColumn(_n_, pCol, pCellValue)
			return This.FindNthValueInCol(_n_, pCol, pCellValue)

		def FindNthOccurrenceOfValueInCol(_n_, pCol, pCellValue)
			return This.FindNthValueInCol(_n_, pCol, pCellValue)

		def FindNthOccurrenceOfValueInColumn(_n_, pCol, pCellValue)
			return This.FindNthValueInCol(_n_, pCol, pCellValue)

		#>

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)
		_anPos_ = This.FindSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		_aResult_ = []
		if _n_ > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnCS(_n_, pCol, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCol(_n_, pCol, pSubValue)
		return This.FindNthSubValueInColCS(_n_, pCol, pSubValue, 1)

		#< @FuntionAlternativeForms

		def FindNthSubValueInColum(_n_, pCol, pSubValue)
			return This.FindNthSubValueInCol(_n_, pCol, pSubValue)

		def FindNthOccurrenceOfSubValueInCol(_n_, pCol, pSubValue)
			return This.FindNthSubValueInCol(_n_, pCol, pSubValue)

		def FindNthOccurrenceOfSubValueInColumn(_n_, pCol, pSubValue)
			return This.FindNthSubValueInCol(_n_, pCol, pSubValue)

		#>

	  #----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(1, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCol(pCol, pCellValueOrSubValue)
		return This.FindFirstInColCS(pCol, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindFirstInColumn( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		def FindFirstOccurrenceInCol( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		def FindFirstOccurrenceInColumn( pCol, pCellValueOrSubValue)
			return This.FindFirstInCol(pCol, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A COLUMN  #
	#--------------------------------------------------#

	def FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCol(pCol, pCellValue)
		return This.FindFirstValueInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumn(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		def FindFirstOccurrenceOfValueInCol(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		def FindFirstOccurrenceOfValueInColumn(pCol, pCellValue)
			return This.FindFirstValueInCol(pCol, pCellValue)

		#>

	  #------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A COLUMN  #
	#------------------------------------------------------#

	def FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCol(pCol, pSubValue)
		return This.FindFirstSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstSubValueInColumn(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		def FindFirstOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		def FindFirstOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.FindFirstSubValueInCol(pCol, pSubValue)

		#>

	  #----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A COLUMN  #
	#----------------------------------------------------------------------------#

	def FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCol(pCol, pCellValueOrSubValue)
		return This.FindLastInColCS(pCol, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindLastInColumn( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		def FindLastOccurrenceInCol( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		def FindLastOccurrenceInColumn( pCol, pCellValueOrSubValue)
			return This.FindLastInCol(pCol, pCellValueOrSubValue)

		#>

	  #---------------------------------#
	 #  FINDING LAST CELL IN A COLUMN  #
	#---------------------------------#

	def FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)
		return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnCs(pCol, pCellValue, pCaseSensitive)
			return This.FindLastValueInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCol(pCol, pCellValue)
		return This.FindLastValueInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindLastValueInColumn(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		def FindLastOccurrenceOfValueInCol(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		def FindLastOccurrenceOfValueInColumn(pCol, pCellValue)
			return This.FindLastValueInCol(pCol, pCellValue)

		#>

	  #-------------------------------------#
	 #  FINDING LAST SUBVALUE IN A COLUMN  #
	#-------------------------------------#

	def FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCol(pCol, pSubValue)
		return This.FindLastSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastSubValueInColumn(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		def FindLastOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		def FindLastOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.FindLastSubValueInCol(pCol, pSubValue)

		#>

	  #------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A COLUMN  #
	#------------------------------------------------------------------------------#

	def NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrenceInCol( :OfCell = "Ali" ) #--> 2
		? _o1_.CountInCol( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.ColAsPositions(pCol), pCellValueOrSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def CountInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def CountInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
		return This.NumberOfOccurrenceInColCS(pCol, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		def NumberOfOccurrencesInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def NumberOfOccurrencesInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		def CountInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def CountInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)
	
		#--

		def HowManyOccurrenceInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrencesInCol(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrenceInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		def HowManyOccurrencesInColumn(pCol, pCellValueOrSubValue)
			return This.NumberOfOccurrenceInCol(pCol, pCellValueOrSubValue)

		#>

	  #----------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A COLUMN  #
	#----------------------------------------------#

	def NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, pCaseSensitive)
		return len( This.FindCellInColCS(pCol, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountCellInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountCellsInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountCellsInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def CountValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def CountValueInColumCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#==

		def HowManyValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValuesInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyValuesInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColumnCS(pCol, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColCS(pCol, pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCellInCol(pCol, pCellValue)
		return This.NumberOfOccurrenceOfCellInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrencesOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--

		def NumberOfOccurrencesOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountOfCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountOfCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountCellInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountCellInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def CountCellsInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountCellsInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrenceOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		#--
	
		def NumberOfOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def NumberOfOccurrencesOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
		
		#--
	
		def CountOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
		
		#--
	
		def CountValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)
	
		def CountValueInColum(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#==

		def HowManyValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValuesInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyValuesInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#--

		def HowManyOccurrenceOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrenceOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrencesOfValueInCol(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		def HowManyOccurrencesOfValueInColumn(pCol, pValue)
			return This.NumberOfOccurrenceOfCellInCol(pCol, pValue)

		#>

	  #--------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN COLUMN  #
	#--------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColAsPositions(pCol), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#==

		def HowManySubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValuesInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManySubValuesInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#--
	
		def NumberOfOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		def NumberOfOccurrencesOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#--
	
		def CountOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		def CountOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)
	
		#==

		def HowManySubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValuesInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManySubValuesInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		#--

		def HowManyOccurrenceOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrenceOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrencesOfSubValueInCol(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		def HowManyOccurrencesOfSubValueInColumn(pCol, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCol(pCol, pSubValue)

		#>

	  #===============================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A COLUMN  #
	#===============================================================================#

	def ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? _o1_.ContainsInCol(2, :Value = "Abraham") #--> TRUE
		
		? _o1_.ContainsInCol(2, :SubValue = "AL") #--> FALSE
		? _o1_.ContainsInColCS(2, :SubValue = "AL", 0) #--> TRUE
		*/

		if isList(pCol) and IsOneOfTheseNamedParamsList(pCol,[
					:Col, :Column, :InCol, :InColumn, :OfCol, :OfColumn
				    ])

			pCol = pCol[2]
		ok

		if isString(pCol)

			if StzFindFirst([ :First, :FirstCol, :FirstColumn ], pCol) > 0
				pCol = 1

			but StzFindFirst([ :Last, :LastCol, :LastColumn ], pCol) > 0
				pCol = This.NumberOfCols()
		
			else
				StzRaise("Incorrect param type! pCol must be a number.")
			ok
		ok

		_aCellsPos_ = This.ColAsPositions(pCol)

		if isList(pCellValueOrSubValue)

			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(_aCellsPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok

		ok

		return This.ContainsValueInCellsCS(_aCellsPos_, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		def ColumnContainsCS(pCol, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColCS(pCol, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def ContainsInCol(pCol, pCellValueOrSubValue)
		return This.ContainsInColCS(pCol, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def ContainsInColumn(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		def ColContains(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		def ColumnContains(pCol, pCellValueOrSubValue)
			return This.ContainsInCol(pCol, pCellValueOrSubValue)

		#>

	  #----------------------------------------------------#
	 #  CHECKING IF A GIVEN COLUMN CONTAINS A GIVEN CELL  #
	#----------------------------------------------------#

	def ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsCellInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ColContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColumnContainsCellCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ContainsValueInColCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ContainsValueInColumnCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#--

		def ColContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		def ColumnContainsValueCS(pCol, pCellValue, pCaseSensitive)
			return This.ContainsCellInColCS(pCol, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsCellInCol(pCol, pCellValue)
		return This.ContainsCellInColCS(pCol, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsCellInColumn(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ColContainsCell(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ColumnContainsCell(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ContainsValueInCol(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ContainsValueInColumn(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#--
	
		def ColContainsValue(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		def ColumnContainsValue(pCol, pCellValue)
			return This.ContainsCellInCol(pCol, pCellValue)
	
		#>

	  #--------------------------------------------------#
	 #  CHECKING IF A COLUMN CONTAINS A GIVEN SUBVALUE  #
	#--------------------------------------------------#
	
	def ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColCS(pCol, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsSubValueInColumnCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def ColContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		def ColumnContainsSubValueCS(pCol, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColCS(pCol, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInCol(pCol, pSubValue)
		return This.ContainsSubValueInColCS(pCol, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumn(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		def ColContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		def ColumnContainsSubValue(pCol, pSubValue)
			return This.ContainsSubValueInCol(pCol, pSubValue)
	
		#>

	/// WORKING ON A LIST OF COLUMNS /////////////////////////////////////////////////////////////

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#==========================================================================================#

	def FindInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE

		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME,	:JOB 	     ],

			[ "Andy", 	"Maestro",	"Programmer" ],
			[ "Ali", 	"Abraham",	"Designer"   ],
			[ "Alia",	"Ali",		"Lawer"      ]
		])

		? _o1_.FindInCols( [ :FIRSTNAME, :LASTNAME ], :Value = "Ali" )
		#--> [ [ 1, 2], [2, 3] ]

		? _o1_.FindInColsCS(  [ :FIRSTNAME, :LASTNAME ], :SubValue = "a", 0 )
		#--> [
			[ [1, 1], [1] ],
			[ [1, 2], [1] ],
			[ [1, 3], [1, 4] ],
			[ [2, 2], [1, 4, 6] ],
			[ [2, 3], [1] ]
		     ]
		*/

		_bValue_ = 1
		_bSubValue_ = 0

		_aCellsPositions_ = This.ColsToCellsAsPositions(paCols)

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
		
			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue[2], pCaseSensitive)
		
			ok
		ok

		return This.FindValueInCellsCS(_aCellsPositions_, pCellValueOrSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindInCols(paCols, pCellValueOrSubValue)
		return This.FindInColsCS(paCols, pCellValueOrSubValue, 1)

		def FindInColumns(paCols, pCellValueOrSubValue)
			return This.FindInCols(paCols, pCellValueOrSubValue)

	  #---------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL VALUE IN THE GIVEN COLUMNS  #
	#---------------------------------------------------------------#

	def FindValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS(This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		def FindValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindValueInColsCS(paCols, pCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindValueInCols(paCols, pCellValue)
		return This.FindValueInColsCS(paCols, pSubValue, 1)

		def FindValueInColumns(paCols, pCellValue)
			return This.FindValueInCols(paCols, pCellValue)

	  #-------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMNS  #
	#-------------------------------------------------------------#

	def FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS(This.ColsAsPositions(paCols), pSubValue, pCaseSensitive)

		def FindSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def FindSubValueInCols(paCols, pSubValue)
		return This.FindValueInColsCS(paCols, pSubValue, 1)

		def FindSubValueInColumns(paCols, pSubValue)
			return This.FindSubValueInCols(paCols, pSubValue)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN COLUMNS  #
	#=============================================================================================#

	def FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :Nth, :N, :Occurrence ])
			_n_ = _n_[2]
		ok

		paCols = This.ColsToNames(paCols)

		return This.FindNthInCellsCS(_n_, This.ColsAsPositions(paCols), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthOccurrenceInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthInColumnsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInColumsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthInCols(_n_, paCols, pCellValueOrSubValue)
		return This.FindNthInColsCS(_n_, paCols, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindNthInColumns(_n_, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(_n_, paCols, pCellValueOrSubValue)

		def FindNthOccurrenceInCols(_n_, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(_n_, paCols, pCellValueOrSubValue)

		def FindNthOccurrenceInColumns(_n_, paCols, pCellValueOrSubValue)
			return This.FindNthInCols(_n_, paCols, pCellValueOrSubValue)

		#>

	  #---------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A CELL IN THE GIVEN COLUMNS  #
	#---------------------------------------------------------#

	def FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		if isList(paCols) and IsOneOfTheseNamedParamsList(paCols,[
					:Cols, :InCols, :OfCols,
					:Columns, :InColumns, :OfColumns
				    ])

			paCols = paCols[2]
		ok

		return This.FindNthInCellsCS(_n_, This.ColsAsPositions(paCols), pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindNthValueInColumsCS(_n_, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColsCs(_n_, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		def FindNthOccurrenceOfValueInColumnsCS(_n_, paCols, pCellValue, pCaseSensitive)
			return This.FindNthValueInColsCS(_n_, paCols, pCellValue, pCaseSensitive)

		#>


	#-- WITHOUT CASESENSITIVITY

	def FindNthValueInCols(_n_, paCols, pCellValue)
		return This.FindNthValueInColsCS(_n_, paCols, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindNthValueInColumns(_n_, paCols, pCellValue)
			return This.FindNthValueInCols(_n_, paCols, pCellValue)

		def FindNthOccurrenceOfValueInCols(_n_, paCols, pCellValue)
			return This.FindNthValueInCols(_n_, paCols, pCellValue)

		def FindNthOccurrenceOfValueInColumns(_n_, paCols, pCellValue)
			return This.FindNthValueInCols(_n_, paCols, pCellValue)

		#>

	  #------------------------------------------------------------#
	 #  FINDING NTH OCCURRENCE OF A SUBVALUE IN THE GIVEN COLUMN  #
	#------------------------------------------------------------#

	def FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)
		_anPos_ = This.FindSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		_aResult_ = []
		if _n_ > 0 and _n_ <= len(_anPos_)
			_aResult_ = _anPos_[_n_]
		ok

		return _aResult_

		#< @FunctionAlternativeForms

		def FindNthSubValueInColumsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInColumnsCS(_n_, paCols, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindNthSubValueInCols(_n_, paCols, pSubValue)
		return This.FindNthSubValueInColsCS(_n_, paCols, pSubValue, 1)

		#< @FuntionAlternativeForms

		def FindNthSubValueInColums(_n_, paCols, pSubValue)
			return This.FindNthSubValueInCols(_n_, paCols, pSubValue)

		def FindNthOccurrenceOfSubValueInCols(_n_, paCols, pSubValue)
			return This.FindNthSubValueInCols(_n_, paCols, pSubValue)

		def FindNthOccurrenceOfSubValueInColumns(_n_, paCols, pSubValue)
			return This.FindNthSubValueInCols(_n_, paCols, pSubValue)

		#>

	  #------------------------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF COLUMN  #
	#------------------------------------------------------------------------------------------#

	def FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColsCS(1, paCols, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstInCols(paCols, pCellValueOrSubValue)
		return This.FindFirstInColsCS(paCols, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindFirstInColumns(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		def FindFirstOccurrenceInCols(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		def FindFirstOccurrenceInColumns(paCols, pCellValueOrSubValue)
			return This.FindFirstInCols(paCols, pCellValueOrSubValue)

		#>

	  #-----------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A CELL IN A GIVEN LIST OF COLUMNS  #
	#-----------------------------------------------------------------#

	def FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInColumnsCs(paCols, pCellValue, pCaseSensitive)
			return This.FindFirstValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstValueInCols(paCols, pCellValue)
		return This.FindFirstValueInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstValueInColumns(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		def FindFirstOccurrenceOfValueInCols(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		def FindFirstOccurrenceOfValueInColumns(paCols, pCellValue)
			return This.FindFirstValueInCols(paCols, pCellValue)

		#>

	  #---------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#---------------------------------------------------------------------#

	def FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstSubValueInCols(paCols, pSubValue)
		return This.FindFirstSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindFirstSubValueInColumns(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		def FindFirstOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		def FindFirstOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.FindFirstSubValueInCols(paCols, pSubValue)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A GIVEN LIST OF COLUMNS  #
	#-------------------------------------------------------------------------------------------#

	def FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInColsCS(:Last, pCol, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastInCols(paCols, pCellValueOrSubValue)
		return This.FindLastInColsCS(paCols, pCellValueOrSubValue, 1)
		
		#< @FunctionAlternativeForms

		def FindLastInColumns(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		def FindLastOccurrenceInCols(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		def FindLastOccurrenceInColumns(paCols, pCellValueOrSubValue)
			return This.FindLastInCols(paCols, pCellValueOrSubValue)

		#>

	  #----------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A CELL VALUE IN A LIST OF COLUMNS  #
	#----------------------------------------------------------------#

	def FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)
		return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def FindLastValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.FindLastValueInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastValueInCols(paCols, pCellValue)
		return This.FindLastValueInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms

		def FindLastValueInColumns(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		def FindLastOccurrenceOfValueInCols(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		def FindLastOccurrenceOfValueInColumns(paCols, pCellValue)
			return This.FindLastValueInCols(paCols, pCellValue)

		#>

	  #--------------------------------------------------------------------#
	 #  FINDING LAST OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#--------------------------------------------------------------------#

	def FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms

		def FindLastSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def FindLastOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastSubValueInCols(paCols, pSubValue)
		return This.FindLastSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForm

		def FindLastSubValueInColumns(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		def FindLastOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		def FindLastOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.FindLastSubValueInCols(paCols, pSubValue)

		#>

	  #---------------------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A GIVEN LIST OF COLUMNS  #
	#---------------------------------------------------------------------------------------------#

	def NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceInCellsCS(This.ColsAsPositions(paCols), pValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def NumberOfOccurrencesInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInCoslCS(paCols, pValueOrSubValue, pCaseSensitive)

		def CountInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def CountInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrenceInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		def HowManyOccurrencesInColumnsCS(paCols, pValueOrSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
		return This.NumberOfOccurrenceInColsCS(paCols, pValueOrSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
	
		def NumberOfOccurrencesInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def NumberOfOccurrencesInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)
	
		def CountInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def CountInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		#--

		def HowManyOccurrenceInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrenceInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrencesInCols(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		def HowManyOccurrencesInColumns(paCols, pValueOrSubValue)
			return This.NumberOfOccurrenceInCols(paCols, pValueOrSubValue)

		#>

	  #-------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A CELL IN A LIST OF COLUMNS  #
	#-------------------------------------------------------#

	def NumberOfOccurrenceOfCellInColsCS(paCols, pCellValue, pCaseSensitive)
		return len( This.FindCellInColsCS(paCols, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountCellInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountCellInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountCellsInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountCellsInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrenceOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def CountValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def CountValueInColumsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#==

		def HowManyValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValuesInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyValuesInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInColumnsCS(paCols, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInColsCS(paCols, pValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfCellInCols(paCols, pCellValue)
		return This.NumberOfOccurrenceOfCellInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrencesOfCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--

		def NumberOfOccurrencesOfCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountOfCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountOfCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountCellInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountCellInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def CountCellsInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountCellsInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrenceOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrenceOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		#--
	
		def NumberOfOccurrencesOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def NumberOfOccurrencesOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
		
		#--
	
		def CountOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
		
		#--
	
		def CountValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)
	
		def CountValueInColums(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#==

		def HowManyValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValuesInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyValuesInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#--

		def HowManyOccurrenceOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrenceOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrencesOfValueInCols(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		def HowManyOccurrencesOfValueInColumns(paCols, pValue)
			return This.NumberOfOccurrenceOfCellInCols(paCols, pValue)

		#>

	  #-----------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCE OF A SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#-----------------------------------------------------------------#

	def NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.ColsAsPositions(paCols), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def NumberOfOccurrencesOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def NumberOfOccurrencesOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def CountOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def CountOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#==

		def HowManySubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValuesInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManySubValuesInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#--

		def HowManyOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
		return This.NumberOfOccurrenceOfSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def NumberOfOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		#--
	
		def NumberOfOccurrencesOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		def NumberOfOccurrencesOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
		
		#--
	
		def CountOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)
	
		def CountOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#==

		def HowManySubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValuesInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManySubValuesInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#--

		def HowManyOccurrenceOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrenceOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrencesOfSubValueInCols(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		def HowManyOccurrencesOfSubValueInColumns(paCols, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInCols(paCols, pSubValue)

		#>

	  #==============================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A GIVEN LIST OF COLUMNS  #
	#==============================================================================================#

	def ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		if isList(paCols) and IsOneOfTheseNamedParamsList(paCols,[
					:Cols, :Columns, :InCols, :InColumns, :OfCols, :OfColumns
				    ])

			pCol = pCol[2]
		ok

		_aColPos_ = This.ColsAsPositions(paCols)

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.ContainsValueInCellsCS(_aColPos_, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.ContainsSubValueInCellsCS(_aColPos_, pCellValueOrSubValue[2], pCaseSensitive)

			ok
		ok

		return This.ContainsValueInCellsCS(_aColPos_, pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def ContainsInColumnsCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def ColsContainCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		def ColumnsContainCS(paCols, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInColsCS(paCols, pCellValueOrSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY
	
	def ContainsInCols(paCols, pCellValueOrSubValue)
		return This.ContainsInColsCS(paCols, pCellValueOrSubValue, 1)

		#< @FunctionAlternativeForms

		def ContainsInColumns(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		def ColsContain(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		def ColumnsContain(paCols, pCellValueOrSubValue)
			return This.ContainsInCols(paCols, pCellValueOrSubValue)

		#>

	  #--------------------------------------------------------------#
	 #  CHECKING IF A GIVEN LIST OF COLUMNS CONTAIN THE GIVEN CELL  #
	#--------------------------------------------------------------#

	def ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColsCS(paCols, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsCellInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ColsContainCellCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ColumnsContainCellCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ContainsValueInColsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ContainsValueInColumnsCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#--

		def ColsContainValueCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		def ColumnsContainsValueCS(paCols, pCellValue, pCaseSensitive)
			return This.ContainsCellInColsCS(paCols, pCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsCellInCols(paCols, pCellValue)
		return This.ContainsCellInColsCS(paCols, pCellValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsCellInColumns(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ColsContainCell(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ColumnsContainCell(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ContainsValueInCols(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ContainsValueInColumns(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#--
	
		def ColsContainValue(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		def ColumnsContainValue(paCols, pCellValue)
			return This.ContainsCellInCols(paCols, pCellValue)
	
		#>

	  #----------------------------------------------------------#
	 #  CHECKING IF A LIST OF COLUMNS CONTAIN A GIVEN SUBVALUE  #
	#----------------------------------------------------------#
	
	def ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInColsCS(paCols, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def ContainsSubValueInColumnsCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def ColsContainSubValueCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		def ColumnsContainSubValueCS(paCols, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInColsCS(paCols, pSubValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ContainsSubValueInCols(paCols, pSubValue)
		return This.ContainsSubValueInColsCS(paCols, pSubValue, 1)

		#< @FunctionAlternativeForms
	
		def ContainsSubValueInColumns(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		def ColsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		def ColumnsContainSubValue(paCols, pSubValue)
			return This.ContainsSubValueInCols(paCols, pSubValue)
	
		#>

	/// WORKING ON SECTIONS //////////////////////////////////////////////////////////////////////
	#TODO // Working on SELECTIONS

	  #==========================================================================================#
	 #  FINDING POSITIONS OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#==========================================================================================#

	def FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],

			[ "Andy", 		"Maestro" ],
			[ "Ali", 		"Abraham" ],
			[ "Ali",		"Ali"     ]
		])

		? _o1_.FindInSection(2, :Value = "Ali")
		#--> [ [ 1, 2] ]

		? _o1_.FindInSection(3, :Value = "Ali" )
		#--> [ [1, 3], [2, 3] ]

		? _o1_.FindInSection( 2, :SubValue = "a" )
		#--> [
				[ [1, 2], [1]    ],
				[ [2, 2], [4, 6] ],
		     ]
		*/

		if isList(pCellValueOrSubValue)
			_oTemp_ = Q(pCellValueOrSubValue)

			if IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :Value, :Cell, :CellValue ])
				return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)

			but IsOneOfTheseNamedParamsList(pCellValueOrSubValue,[ :SubValue, :CellPart, :SubPart ])
				return This.FindSubValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue[2], pCaseSensitive)
			ok
		ok

		return This.FindValueInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)

	def FindValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindValueInSection(paSection1, paSection2, pCellValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, 1)

	def FindSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindValueInSectionCS(paSection1, paSection2, pSubValue, 1)

	  #=============================================================================================#
	 #  FINDING NTH POSITION OF A GIVEN CELL (OR A GIVEN SUBVALUE IN A CELL) IN THE GIVEN SECTION  #
	#=============================================================================================#

	def FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		if isList(_n_) and IsOneOfTheseNamedParamsList(_n_,[ :N, :Nth, :Occurrence ])
			_n_ = _n_[2]
		ok

		return This.FindNthInCellsCS(_n_, This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		def FindNthOccurrenceInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)
			return This.FindNthInSectionCS(_n_, paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindNthOccurrenceInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)
				return This.FindNthInSection(_n_, paSection1, paSection2, pCellValueOrSubValue)

	def FindNthValueInSectionCS(_n_, paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindNthValueInCellsCS(_n_, This.SectionAsPositions(), pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthValueInSection(_n_, paSection1, paSection2, pCellValue)
			return This.FindNthValueInSectionCS(_n_, paSection1, paSection2, pCellValue, 1)

			def FindNthOccurrenceOfValueInSection(_n_, paSection1, paSection2, pCellValue)
				return This.FindNthValueInSection(_n_, paSection1, paSection2, pCellValue)

	def FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindNthSubValueInCellsCS(_n_, This.SectionAsPositions(), pSubValue, pCaseSensitive)

		def FindNthOccurrenceOfSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindNthSubValueInSection(_n_, paSection1, paSection2, pSubValue)
			return This.FindNthSubValueInSectionCS(_n_, paSection1, paSection2, pSubValue, 1)

			def FindNthOccurrenceOfSubValueInSection(_n_, paSection1, paSection2, pSubValue)
				return This.FindNthSubValueInSection(_n_, paSection1, paSection2, pSubValue)

	  #-----------------------------------------------------------------------------#
	 #  FINDING FIRST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-----------------------------------------------------------------------------#

	def FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(1, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindFirstOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindFirstInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindFirstOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindFirstInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindFirstOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstValueInSection(paSection1, paSection2, pCellValue)
			return This.FindFirstValueInSectionCS(paSection1, paSection2, pCellValue, 1)

			def FindFirstOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindFirstValueInSection(paSection1, paSection2, pCellValue)

	def FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

		def FindFirstOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindFirstSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindFirstSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def FindFirstOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindFirstSubValueInSection(paSection1, paSection2, pSubValue)

	  #-----------------------------------------------------------------------------#
	 #  FINIDING LAST OCCURRENCE (OF A CELL OR A SUBVALUE OF A CELL) IN A SECTION  #
	#-----------------------------------------------------------------------------#

	def FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		return This.FindNthInSectionCS(:Last, paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		def FindLastOccurrenceInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.FindLastInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)
		
			def FindLastOccurrenceInSection( paSection1, paSection2, pCellValueOrSubValue)
				return This.FindLastInSection(paSection1, paSection2, pCellValueOrSubValue)

	def FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def FindLastOccurrenceOfValueInSectionCs(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastValueInSection(paSection1, paSection2, pCellValue)
			return This.FindLastValueInSectionCS(paSection1, paSection2, pCellValue, 1)

			def FindLastOccurrenceOfValueInSection(paSection1, paSection2, pCellValue)
				return This.FindLastValueInSection(paSection1, paSection2, pCellValue)

	def FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

		def FindLastOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def FindLastSubValueInSection(paSection1, paSection2, pSubValue)
			return This.FindLastSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def FindLastOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
				return This.FindLastSubValueInSection(paSection1, paSection2, pSubValue)

	  #-------------------------------------------------------------------------------#
	 #  NUMBER OF OCCURRENCES OF A VALUE (OR A SUBVALUE INSIDE A CELL) IN A SECTION  #
	#-------------------------------------------------------------------------------#

	def NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			:NAME = [ "Andy", "Ali", "Ali" ]
			:AGE  = [    35,    58,    23 ]
		])

		? _o1_.NumberOfOccurrenceInSection( :OfCell = "Ali" ) #--> 2
		? _o1_.CountInSection( :SubValue = "A" ) #--> 3
		*/

		return This.NumberOfOccurrenceInCellsCS( This.SectionAsPositions(paSection1, paSection2), pValue, pCaseSensitive)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, pValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def CountInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		return len( This.FindCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive) )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#--

		def NumberOfOccurrenceOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def CountValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#==

		def HowManyCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesOfCellsInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyValuesInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrenceOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		def HowManyOccurrencesOfValueInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pCellValue)
			return This.NumberOfOccurrenceOfCellInSectionCS(paSection1, paSection2, pCellValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def NumberOfOccurrencesOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#--

		def NumberOfOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue, pCaseSensitive)

		def NumberOfOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def CountOfValueInSectionInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSectionInSection(paSection1, paSection2, paSection1, paSection2, pValue)

		def CountValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#==

		def HowManyCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceOfCellInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesOfCellsInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyValuesInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrenceOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		def HowManyOccurrencesOfValueInSection(paSection1, paSection2, pValue)
			return This.NumberOfOccurrenceOfCellInSection(paSection1, paSection2, pValue)

		#>

	def NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		return This.NumberOfOccurrenceOfSubValueInCellsCS( This.SectionAsPositions(paSection1, paSection2), pSubValue, pCaseSensitive )

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def CountOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def HowManyOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		def HowManyOccurrencesOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

		#< @FunctionAlternativeForms

		def NumberOfOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def CountOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def HowManyOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		def HowManyOccurrencesOfSubValueInSection(paSection1, paSection2, pSubValue)
			return This.NumberOfOccurrenceOfSubValueInSection(paSection1, paSection2, pSubValue)

		#>

	  #================================================================================#
	 #  CHECKING IF THE TABLE CONTAINS A GIVEN CELL OR A GIVEN SUBVALUE IN A SECTION  #
	#================================================================================#

	def ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
		/* EXAMPLE
		_o1_ = new stzTable([
			[ :FIRSTNAME,	:LASTNAME ],
			[ "Andy", 	"Maestro" ],
			[ "Ali", 	"Abraham" ],
			[ "Ali",	"Ali"     ]
		])
		
		? _o1_.ContainsInSection(2, :Value = "Abraham") #--> TRUE
		
		? _o1_.ContainsInSection(2, :SubValue = "AL") #--> FALSE
		? _o1_.ContainsInSectionCS(2, :SubValue = "AL", 0) #--> TRUE
		*/

		return This.ContainsInCellsCS( This.SectionAsPositions(paSection1, paSection2), pCellValueOrSubValue, pCaseSensitive)

		#< @FunctionAlternativeForm

		def SectionContainsCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY
	
		def ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)
			return This.ContainsInSectionCS(paSection1, paSection2, pCellValueOrSubValue, 1)

			def SectionContains(paSection1, paSection2, pCellValueOrSubValue)
				return This.ContainsInSection(paSection1, paSection2, pCellValueOrSubValue)

	def ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfCell = pCellValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForms

		def SectionContainsCellCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def ContainsValueInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		def SectionContainsValueCS(paSection1, paSection2, pCellValue, pCaseSensitive)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, pCaseSensitive)

		#>

		#-- WITHOUT CASESENSITIVITY

		def ContainsCellInSection(paSection1, paSection2, pCellValue)
			return This.ContainsCellInSectionCS(paSection1, paSection2, pCellValue, 1)

			def SectionContainsCell(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)

			def ContainsValueInSection(paSection1, paSection2, pCellValue)
				return This.ContainsCellInSection(paSection1, paSection2, pCellValue)
	
	def ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)
		if This.NumberOfOccurrenceInSectionCS(paSection1, paSection2, :OfSubValue = pSubValue, pCaseSensitive) > 0
			return 1

		else
			return 0
		ok

		def SectionContainsSubValueCS(paSection1, paSection2, pSubValue, pCaseSensitive)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, pCaseSensitive)

		#-- WITHOUT CASESENSITIVITY

		def ContainsSubValueInSection(paSection1, paSection2, pSubValue)
			return This.ContainsSubValueInSectionCS(paSection1, paSection2, pSubValue, 1)

			def SectionContainsSubValue(paSection1, paSection2, pSubValue)
				return This.ContainsSubValueInSection(paSection1, paSection2, pSubValue)

