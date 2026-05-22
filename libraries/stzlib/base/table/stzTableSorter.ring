#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLESORTER              #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table sorter subclass -- sorting by         #
#                  column, expression, ascending/descending.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableSorter from stzTable

	  #==================================#
	 #  SORTING THE TABLE IN ASCENDING  #
	#==================================#

	def Sort()
		This.SortOn(1)

		#< @FunctionFluentForm

		def SortQ()
			This.Sort()
			return This

		#>

		#< @FunctionAlternativeForms

		def SortUp()
			This.Sort()

			def SortUpQ()
				return This.SortQ()

		def SortInAscending()
			This.Sort()

			def SortInAscendingQ()
				return This.SortQ()

		#>

	  #-----------------------------------#
	 #  SORTING THE TABLE IN DESCENDING  #
	#-----------------------------------#

	def SortDown()
		This.SortDownOn(1)

		#< @FunctionFluentForm

		def SortDownQ()
			This.SortDown()
			return This

		#>

		#< @FunctionAlternativeForm

		def SortInDescending()
			This.SortDown()

			def SortInDescendingQ()
				return This.SortDownQ()

		#>

	def SortedDown()
		aResult = This.Copy().SortDownQ().Content()
		return aResult

		def SortedInDescending()
			return This.SortedDown()

	  #----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN ASCENDiNG  #
	#====================================================#

	#TODO
	# Check performance on large tables

	def SortOn(pCol)
		nCol = This.ColToColNumber(pCol)

		This._EnsureEngine()
		StzEngineTableSortOn(@pEngine, nCol-1, 1)
		This._SyncFromEngine()

		#< @FunctionFluentForm

		def SortOnQ(pCol)
			This.SortOn(pCol)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortUpOn(pCol)
			This.SortOn(pCol)

			def SortUpOnQ(pCol)
				return This.SortOnQ(pCol)

		def SortOnInAscending(pCol)
			This.SortOn(pCol)

			def SortOnInAscendingQ(pCol)
				return This.SortOnQ(pCol)

		def SortOnCol(pCol)
			This.SortOn(pCol)

			def SortOnColQ(pCol)
				return This.SortOnQ(pCol)

		def SortColUpOn(pCol)
			This.SortOn(pCol)

			def SortColUpOnQ(pCol)
				return This.SortOnQ(pCol)

		def SortInAscendingOnCol(pCol)
			This.SortOn(pCol)

			def SortInAscendingOnColQ(pCol)
				return This.SortOnQ(pCol)

		def SortOnColumn(pCol)
			This.SortOn(pCol)

			def SortOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		def SortUpOnColumn(pCol)
			This.SortOn(pCol)

			def SortUpOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		def SortInAscendingOnColumn(pCol)
			This.SortOn(pCol)

			def SortInAscendingOnColumnQ(pCol)
				return This.SortOnQ(pCol)

		#>

	def SortedOn(pCol)
		aResult = This.Copy().SortOnQ(pCol).Content()
		return aResult

		#< @FunctionAlternativeForms

		def SortedUpOn(pCol)
			return This.SortedOn(pCol)

		def SortedInAscendingOn(pCol)
			return This.SortedOn(pCol)

		def SortedOnCol(pCol)
			return This.SortedOn(pCol)

		def SortedUpOnCol(pCol)
			return This.SortedOn(pCol)

		def SortedInAscendingOnCol(pCol)
			return This.SortedOn(pCol)

		def SortedOnColumn(pCol)
			return This.SortedOn(pCol)

		def SortedUpOnColumn(pCol)
			return This.SortedOn(pCol)

		def SortedInAscendingOnColumn(pCol)
			return This.SortedOn(pCol)

		#>

	  #-----------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN IN DESCENDiNG  #
	#=====================================================#

	def SortDownOn(pCol)
		nCol = This.ColToColNumber(pCol)

		This._EnsureEngine()
		StzEngineTableSortOn(@pEngine, nCol-1, 0)
		This._SyncFromEngine()

		#< @FunctionFluentForm


		def SortDownOnQ(pCol)
			This.SortDownOn(pCol)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInDescendingOn(pCol)
			This.SortOnDown(pCol)

			def SortInDescendingOnQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortColDownOn(pCol)
			This.SortDownOn(pCol)

			def SortColDownOnQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortInDescendingOnCol(pCol)
			This.SortDownOn(pCol)

			def SortInDescendingOnColQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortDownOnColumn(pCol)
			This.SortDownOn(pCol)

			def SortDownOnColumnQ(pCol)
				return This.SortDownOnQ(pCol)

		def SortInDescendingOnColumn(pCol)
			This.SortDownOn(pCol)

			def SortInDescendingOnColumnQ(pCol)
				return This.SortDownOnQ(pCol)

		#>

	def SortedDownOn(pCol)
		aResult = This.Copy().SortDownOnQ().Content()
		return aResult

		#< @FunctionAlternativeForms

		def SortedInDescendingOn(pCol)
			return This.SortedDown(pcol)

		def SortedColDownOn(pCol)
			return This.SortedDown(pcol)

		def SortedInDescendingOnCol(pCol)
			return This.SortedDown(pcol)

		def SortedDownOnColumn(pCol)
			return This.SortedDown(pcol)

		def SortedInDescendingOnColumn(pCol)
			return This.SortedDown(pcol)

		#>

	  #========================================================#
	 #  SORTING THE TABLE BY A GIVEN EXPRESSION IN ASCENDING  #
	#========================================================#

	def SortBy(pcExpr)

		This.SortOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortByQ(pcExpr)
			This.SortBy(pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortUpBy(pcExpr)
			This.SortBy(pcExpr)

			def SortUpByQ(pcExpr)
				return This.SortByQ(pcExpr)

		def SortInAscendingBy(pcExpr)
			This.SortBy(pcExpr)

			def SortInAscendingByQ(pcExpr)
				return This.SortByQ(pcExpr)

		#>

	def SortedBy(pcExpr)
		aResult = This.Copy().SortByQ(pcExpr).Content()
		return aResult

		#< @FunctionAlternativeForms

		def SortedUpBy(pcExpr)
			return This.SortedBy(pcExpr)

		def SortedInAscendingBy(pcExpr)
			return This.SortedBy(pcExpr)

		#>

	  #---------------------------------------------------------#
	 #  SORTING THE TABLE BY A GIVEN EXPRESSION IN DESCENDING  #
	#---------------------------------------------------------#

	def SortDownBy(pcExpr)
		This.SortDownOnBy(1, pcExpr)

		#< @FunctionFluentForm

		def SortDownByQ(pcExpr)
			This.SortDownBy(pcExpr)
			return This

		#>

		#< @FunctionAlternativeForm

		def SortInDescendingBy(pcExpr)
			This.SortDownBy(pcExpr)

			def SortInDescendingByQ(pcExpr)
				return This.SortDownByQ(pcExpr)

		#>

	def SortedDownBy(pcExpr)
		aResult = This.Copy().SortDownByQ(pcExpr).Content()
		return aResult

		#< @FunctionAlternativeForm

		def SortedBInDescendingy(pcExpr)
			return This.SortedDownBy(pcExpr)

		#>

	  #--------------------------------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN BY A GIVEN EXPRESSION IN ASCENDiNG  #
	#==========================================================================#

	def SortOnBy(pCol, pcExpr)

		nCol = This.ColToColNumber(pCol)
		oLoL = new stzListOfLists( This.Rows() )
		pcExpr = StzReplace(StzReplace(pcExpr, "@cell", "@item"), "@CELL", "@item")

		oLoL.SortOnBy(nCol, pcExpr)

		aRowsSorted = oLoL.Content()
		nLenRows = len(aRowsSorted)

		for i = 1 to nLenRows
			This.ReplaceRow(i, aRowsSorted[i])
		next

		#< @FunctionFluentForm

		def SortOnByQ(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortOnByUp(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnByUpQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortInAscendingOnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnColByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortUpOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortUpOnColByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortInAscendingOnColBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnColByQ(pCol, pcExp)
				return This.SortOnByQ(pCol, pcExpr)

		def SortOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortOnColumnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortUpOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortUpOnColumnByQ(pCol, pcExpr)
				return This.SortOnByQ(pCol, pcExpr)

		def SortInAscendingOnColumnBy(pCol, pcExpr)
			This.SortOnBy(pCol, pcExpr)

			def SortInAscendingOnColumnByQ(pCol, pcExp)
				return This.SortOnByQ(pCol, pcExpr)

		#>

	def SortedOnBy(pCol, pcExpr)
		aResult = This.Copy().SortOnByQ(pCol, pcExpr).Content()
		return aResult

		#< @FunctionAlternativeForms

		def SortedUpOnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedInAscendingOnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedOnColBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedUpOnColBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedInAscendingOnColBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedOnColumnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedUpOnColumnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		def SortedInAscendingOnColumnBy(pCol, pcExpr)
			return This.SortedOnBy(pCol, pcExpr)

		#>

	  #---------------------------------------------------------------------------#
	 #  SORTING THE TABLE ON A GIVEN COLUMN BY A GIVEN EXPRESSION IN DESCENDiNG  #
	#===========================================================================#

	def SortDownOnBy(pCol, pcExpr)

		nCol = This.ColToColNumber(pCol)

		oLoL = new stzListOfLists( This.Rows() )
		pcExpr = StzReplace(StzReplace(pcExpr, "@cell", "@item"), "@CELL", "@item")
		oLoL.SortDownOnBy(nCol, pcExpr)

		aRowsSorted = oLol.Content()
		nLenRows = len(aRowsSorted)

		for i = 1 to nLenRows
			This.ReplaceRow(i, aRowsSorted[i])
		next

		#< @FunctionFluentForm

		def SortDownOnByQ(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)
			return This

		#>

		#< @FunctionAlternativeForms

		def SortInDescendingOnBy(pCol, pcExpr)
			This.SortDownOnBy(nCol, pcExpr)

			def SortInDescendingOnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortDownOnColBy(nCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortDownOnColByQ(nCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortInDescendingOnColBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortInDescendingOnColByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortDownOnColumnBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortedDownOnColumnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		def SortInDescendingOnColumnBy(pCol, pcExpr)
			This.SortDownOnBy(pCol, pcExpr)

			def SortInDescendingOnColumnByQ(pCol, pcExpr)
				return This.SortDownOnByQ(pCol, pcExpr)

		#>

	def SortedDownOnBy(pCol, pcExpr)
		aResult = This.Copy().SortDownOnByQ(pCol, pcExpr).Content()
		return aResult

		#< @FunctionAlternativeForms

		def SortedInDescendingOnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedDownOnColBy(nCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedInDescendingInColBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedDownOnColumnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		def SortedInDescendingOnColumnBy(pCol, pcExpr)
			return This.SortedDownOnBy(pCol, pcExpr)

		#>

	#-----------------------------------#
	#  CHECKING IF THE TABLE IS SORTED  #
	#-----------------------------------#

	def IsSorted()
		return This.IsSortedOn(1)

	def IsSortedUp()
		return This.IsSortedUpOn(1)

		def IsSortedInAscending()
			return This.IsSortedUpOn(1)

	def IsSortedDown()
		return This.IsSortedDownOn(1)

		def IsSortedInDescending()
			return This.IsSortedDownOn(1)

	def IsSortedOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortOn(pCol)

		_bResult_ = TRUE
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

		def IsSortedOnCol(pCol)
			return This.IsSortedOn(pCol)

		def IsSortedOnColumn(pCol)
			return This.IsSortedOn(pCol)

	def IsSortedUpOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortUpOn(pCol)

		_bResult_ = TRUE
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_


		def IsSortedOnUp(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedUpOnCol(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedUpOnColumn(pCol)
			return THis.IsSortedUpOn(pCol)

		#--

		def IsSortedInAscendingOn(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedInAscendingUp(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedInAscendingCol(pCol)
			return THis.IsSortedUpOn(pCol)

		def IsSortedInAscendingColumn(pCol)
			return THis.IsSortedUpOn(pCol)

	def IsSortedDownOn(pCol)
		_oCopy_ = This.Copy()
		_oCopy_.SortDownOn(pCol)

		_bResult_ = TRUE
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_


		def IsSortedDownOnCol(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedDownOnColumn(pCol)
			return THis.IsSortedDownOn(pCol)

		#--

		def IsSortedInDescendingOn(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedUpInDescending(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedInDescendingCol(pCol)
			return THis.IsSortedDownOn(pCol)

		def IsSortedInDescendingOnColumn(pCol)
			return THis.IsSortedDownOn(pCol)

	#--

	def IsSortedBy(pcExpr)
		return This.IsSotedOnBy(1, pcExpr)

	def IsSortedUpBy(pcExpr)
		return This.IsSortedUpOn(1, pcExpr)

		def IsSortedInAscendingBy(pcExpr)
			return This.IsSortedUpBy(1, pcExpr)

	def IsSortedDownBy(pcExpr)
		return This.IsSortedDownOnBy(1, pcExpr)

		def IsSortedInDescendingBy(pcExpr)
			return This.IsSortedDownOnBy(1, pcExpr)

	def IsSortedOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortOnBy(pCol, pcExpr)

		_bResult_ = TRUE
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

		def IsSortedOnColBy(pCol, pcExpr)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedOnColumnBy(pCol, pcExpr)
			return This.IsSortedOnBy(pCol, pcExpr)

		#--

		def IsSortedByOn(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedByOnCol(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

		def IsSortedByOnColumn(pcExpr, pCol)
			return This.IsSortedOnBy(pCol, pcExpr)

	def IsSortedUpOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortUpOnBy(pCol, pcExpr)

		_bResult_ = TRUE
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_

		def IsSortedUpOnColBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpOnColumnBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#--

		def IsSorteUpByOn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpByOnCol(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedUpByOnColumn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#==

		def IsSortedInAscendingOnColBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingOnColumnBy(pCol, pcExpr)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		#--

		def IsSorteInAscendingByOn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingByOnCol(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

		def IsSortedInAscendingByOnColumn(pcExpr, pCol)
			return This.IsSortedUpOnBy(pCol, pcExpr)

	def IsSortedDownOnBy(pCol, pcExpr)
		_oCopy_ = This.Copy()
		_oCopy_.SortDownOnBy(pCol, pcExpr)

		_bResult_ = TRUE
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			if NOT _oCopy_.ColQ(i).IsEqualToXT(This.Col(i))
				_bResult_ = FALSE
				exit
			ok
		next

		return _bResult_


		def IsSortedDownOnColBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownOnColumnBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#--

		def IsSortedDownByOn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownByOnCol(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedDownByOnColumn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#==

		def IsSortedInDescendingOnColBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingOnColumnBy(pCol, pcExpr)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		#--

		def IsSortedInDescendingByOn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingByOnCol(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)

		def IsSortedInDescendingByOnColumn(pcExpr, pCol)
			return This.IsSortedDownOnBy(pCol, pcExpr)
