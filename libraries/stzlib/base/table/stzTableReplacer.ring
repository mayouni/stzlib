#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLEREPLACER            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table replacer subclass -- replacing cell   #
#                  values, columns, rows, and sub-values.      #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableReplacer from stzTable

	  #==========================================================================#
	 #  REPLACING A GIVEN CELL, DEFINED BY ITS POSITION, BY THE PROVIDED VALUE  #
	#==========================================================================#

	def ReplaceCell(pCol, pnRow, pNewCellValue)
		if CheckingParams()
			if isList(pNewCellValue) and IsOneOfTheseNamedParamsList(pNewCellValue,[ :By, :With, :Using ])
				pNewCellValue = pNewCellValue[2]
			ok
			if NOT isNumber(pnRow)
				StzRaise("Incorrect param type! pnRow must be a number.")
			ok
		ok

		aContent = @aContent
		cCol = This.ColToName(pCol)
		aContent[cCol][pnRow] = pNewCellValue

		This.UpdateWith(aContent)

		#< @FunctionAlternativeForms

		def ReplaceCellByPosition(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		def ReplaceByPositionCell(pCol, pnRow, pNewCellValue)
			This.ReplaceCell(pCol, pnRow, pNewCellValue)

		#>

	  #---------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY THE PROVIDED VALUE  #
	#---------------------------------------------------------------------------#

	def ReplaceCells(paCellsPos, paNewCellValue)

		if ChekParams() #NOTE this is a misspelled form (c in Check is lacking)
			        # But Softanza forgives it (PERMISSIVENESS prinicle of the FLEXIBILITY goal)

			if isList(paNewCellValue) and IsOneOfTheseNamedParamsList(paNewCellValue,[ :By, :With, :Using ])
				paNewCellValue = paNewCellValue[2]
			ok

		ok

		_nCellsPosLen_ = ring_len(paCellsPos)
		for i = 1 to _nCellsPosLen_
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewCellValue)
		next

		#< @FunctionAlternatives

		def ReplaceTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		#TODO // Add the fellowing semantics to all simular functions in the library

		def ReplaceEachOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		def ReplaceEveryOne(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCell(paCellsPos, paNewCellValue)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceManyByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceManyByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceEachOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceEachOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceEachCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceEachCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEachCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceEveryOneByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceEveryOneByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceEveryCellByPosition(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceEveryCellByPositions(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCellsByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryOneOfTheseCellsByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfTheseByPosition(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceEveryCellOfTheseByPositions(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#--

		def ReplaceByPositionCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsMany(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceByPositionEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachOne(paCellsPos, paNewCellValue)
			This.ReplaceEachOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachCell(paCellsPos, paNewCellValue)
			This.ReplaceEachCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEachCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)


		def ReplaceByPositionEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryOne(paCellsPos, paNewCellValue)
			This.ReplaceEveryOne(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryCell(paCellsPos, paNewCellValue)
			This.ReplaceEveryCell(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryOneOfTheseCells(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		def ReplaceByPositionsEveryCellOfThese(paCellsPos, paNewCellValue)
			This.ReplaceCells(paCellsPos, paNewCellValue)

		#>

	  #-----------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES  #
	#-----------------------------------------------------------------------------#

	def ReplaceCellsByMany(paCellsPos, paNewValues)

		if CheckingParams()

			if isList(paNewValues) and
			   IsOneOfTheseNamedParamsList(paNewValues,[ :By, :With, :Using ])
				paNewValues = paNewValues[2]
			ok

			if NOT @BothAreLists(paCellsPos, paNewValues)
				StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
			ok

		ok

		nLenCells  = ring_len(paCellsPos)
		nLenValues = ring_len(paNewValues)
		nMin = @Min([ nLenCells, nLenValues ])

		for i = 1 to nMin
			This.ReplaceCell(paCellsPos[i][1], paCellsPos[i][2], paNewValues[i])
		next

		#< @FunctionAlternativeForms

		def ReplaceTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceEachOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceEveryOneByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByMany(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceManyByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		def ReplaceEachOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		def ReplaceEveryOneByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#--

		def ReplaceByPositionCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsManyByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)


		def ReplaceByPositionEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOneByMany(paCellsPos, paNewValues)
			This.ReplaceEachOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellByMany(paCellsPos, paNewValues)
			This.ReplaceEachCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)


		def ReplaceByPositionEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneByMany(paCellsPos, paNewValues)
			This.ReplaceEveryOneByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellByMany(paCellsPos, paNewValues)
			This.ReplaceEveryCellByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneOfTheseCellsByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellOfTheseByMany(paCellsPos, paNewValues)
			This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#>

	  #---------------------------------------------------------------------------------------#
	 #  REPLACING MANY CELLS, DEFINED BY THEIR POSITIONS, BY MANY PROVIDED VALUES, EXTENDED  #
	#---------------------------------------------------------------------------------------#

	def ReplaceCellsByManyXT(paCellsPos, paNewValues)

		if CheckingParams()

			if isList(paNewValues) and
			   IsOneOfTheseNamedParamsList(paNewValues,[ :By, :With, :Using ])
				paNewValues = paNewValues[2]
			ok

			if NOT @BothAreLists(paCellsPos, paNewValues)
				StzRaise("Incorrect param types! paCellsPos and paNewValues must be both lists.")
			ok

		ok

		nLenPos = ring_len(paCellsPos)
		nLenNew = ring_len(paNewValues)

		if nLenNew < nLenPos
			paNewValues = Q(paNewValues).ExtendXTQ(:To = nLenPos, :ByRepeatingItems).Content()

		but nLenNew > nLenPos
			This.ExtendTo( QRT(paCellsPos, :stzListOfPairs).Max() )
		ok

		This.ReplaceCellsByMany(paCellsPos, paNewValues)

		#< @FunctionAlternatives

		def ReplaceTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceEachOneByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceEveryOneByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByManyXT(paCellsPos, paNewValues)
			if isList(paCellsPos) and IsOneOfTheseNamedParamsList(paCellsPos,[ :Of, :OfThese, :OfTheseCells ])
				paCellsPos = paCellsPos[2]
			ok

			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#== Adding ...ByPosition(s) to all alternatives

		def ReplaceCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceManyByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOneByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachOfTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEachCellOfTheseByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryOneOfTheseCellsByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceEveryCellOfTheseByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#--

		def ReplaceByPositionCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsManyByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplacePositionsEachOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellByPositionsByManyXT(paCellsPos, paNewValues)
			This.ReplaceEachCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEachCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCells(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryOneByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellByManyXT(paCellsPos, paNewValues)
			This.ReplaceEveryCellByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryOneOfTheseCellsByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		def ReplaceByPositionsEveryCellOfTheseByManyXT(paCellsPos, paNewValues)
			This.ReplaceCellsByManyXT(paCellsPos, paNewValues)

		#>

	  #-----------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF A CELL (VALUE) BY THE PROVIDED VALUE  #
	#=================================================================#

	def ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)
		aPos = This.FindCellCS(pCellValue, pCaseSensitive)
		This.ReplaceCellsByPositions(aPos, pNewCellValue)

		#< @FunctionAlternativeForms

		def ReplaceOccurrencesOfCellByValueCS(pCellValue, pNewCell, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceByValueOccurrencesOfCellByCS(pCellValue, pNewCell, pCaseSensitive)
			This.ReplaceCellByValueCS(pCellValue, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIIVTY

	def ReplaceCellByValue(pCellValue, pNewCellValue)
		This.ReplaceCellByValueCS(pCellValue, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceOccurrencesOfCellByValue(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		#--

		def ReplaceByValueCell(pCellValue, pNewCellValue)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		def ReplaceByValueOccurrencesOfCellBy(pCellValue, pNewCell)
			This.ReplaceCellByValue(pCellValue, pNewCellValue)

		#>

	  #--------------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY THE PROVIDED VALUE  #
	#--------------------------------------------------------------------------------#

	def ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */
		stzraise("Function not yet implemented!")

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValue(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueCS(paCellsValues, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValue(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		#--

		def ReplaceByValueManyCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		def ReplaceByValueCells(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValue(paCellsValues, pNewCellValue)

		#>

	  #--------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY MANYS VALUES  #
	#--------------------------------------------------------------------------#

	def ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */
		stzraise("Function not yet implemented!")

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCS(paCellsValues, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		def ReplaceByValueManyCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		def ReplaceByValueCellsByMany(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByMany(paCellsValues, pNewCellValue)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING OCCURRENCES OF MANY CELLS, DEFINED BY VALUE, BY MANYS VALUES -- XT FORM  #
	#-------------------------------------------------------------------------------------#

	def ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive) #TODO
		/* ... */
		stzraise("Function not yet implemented!")

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceByValueManyCellsByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		def ReplaceByValueCellsByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)
			This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)
		This.ReplaceManyCellsByValueByManyCSXT(paCellsValues, pNewCellValue, 1)

		#< @FunctionAlternativeForms

		def ReplaceCellsByValueByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		def ReplaceByValueManyCellsByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		def ReplaceByValueCellsByManyXT(paCellsValues, pNewCellValue)
			This.ReplaceManyCellsByValueByManyXT(paCellsValues, pNewCellValue)

		#>

	  #=============================================================#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A LIST OF ROWS  #
	#=============================================================#

	def ReplaceCol(pCol, paCol)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthCol(nCol, paCol)

		def ReplaceColumn(pCol, paCol)
			This.ReplaceCol(pCol, paCol)

	def ReplaceNthCol(n, paCol)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if IsList(paCol) and Q(paCol).IsByOrWithOrUsingNamedParam()
				paCol = paCol[2]
			ok

			if isList(paCol) and Q(paCol).IsByColOrByColNumberNamedParam()
				paCol = paCol[2]
			ok

			if NOT ( isList(paCol) or isString(paCol) or isNumber(paCol) )
				StzRaise("Incorrect param type! paCol must be a list or a string or number.")
			ok
		ok

		if isString(paCol)
			This.ReplaceColName(n, paCol)
			return
		ok

		if isNumber(paCol)
			paCol = This.Col(paCol)
		ok

		nRows = This.NumberOfRows()
		nLen = ring_len(paCol)

		if nLen > nRows
			nLen = nRows
		ok

		aCol = []
		aContent = @aContent

		for i = 1 to nRows
			if i <= nLen
				aCol + paCol[i]
			else
				aCol + aContent[n][2][i]
			ok
		next

		aContent[n][2] = aCol
		This.UpdateWith(aContent)

		#< @FunctionAlternativeForms

		def ReplaceNthColumn(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColN(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColumnN(n, paCol)
			This.ReplaceNthCol(n, paCol)

		#--

		def ReplaceColAt(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColAtPosition(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColumnAt(n, paCol)
			This.ReplaceNthCol(n, paCol)

		def ReplaceColumnAtPosition(n, paCol)
			This.ReplaceNthCol(n, paCol)

		#>

	  #-------------------------------------------------------------------------#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A LIST OF ROWS -- EXTENDED  #
	#-------------------------------------------------------------------------#
	# ~> XT : If paCol has fewer items than required, it will be
	# supplemented with its items starting from the first one.

	def ReplaceColXT(pCol, paCol)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthColXT(nCol, paCol)

		def ReplaceColumnXT(pCol, paCol)
			This.ReplaceColXT(pCol, paCol)

	def ReplaceNthColXT(n, paCol)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if IsList(paCol) and Q(paCol).IsByOrWithOrUsingNamedParam()
				paCol = paCol[2]
			ok

			if NOT isList(paCol)
				StzRaise("Incorrect param type! paCol must be a list.")
			ok
		ok

		nRows = This.NumberOfRows()
		nLen = ring_len(paCol)

		if nLen > nRows
			nLen = nRows
		ok

		aCol = []
		j = 0

		for i = 1 to nRows
			if i <= nLen
				aCol + paCol[i]
			else
				j++
				if j > nLen
					j = 1
				ok
				aCol + paCol[j]
			ok
		next

		aContent = @aContent
		aContent[n][2] = aCol
		This.UpdateWith(aContent)

		#< @FunctionAlternativeForms

		def ReplaceNthColumnXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColNXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColumnNXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		#--

		def ReplaceColAtXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColAtPositionXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColumnAtXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		def ReplaceColumnAtPositionXT(n, paCol)
			This.ReplaceNthColXT(n, paCol)

		#>

	  #----------------------------------------------------------------------------------------#
	 #  REPLACING COLUMNS AT GIVEN POSITIONS BY A GIVEN COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#----------------------------------------------------------------------------------------#

	def ReplaceColsAt(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = ring_len(anPosU)

		for i = 1 to nLen
			This.ReplaceColAt(anPosU[i], paCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceColsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplacesNthCols(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplaceColumnsAt(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplaceColumnsAtPositions(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		def ReplacesNthColumns(panPos, paCol)
			This.ReplaceColsAt(panPos, paCol)

		#>

	  #----------------------------------------------------------------------------------------------------#
	 #  REPLACING COLUMNS AT GIVEN POSITIONS BY A GIVEN COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#----------------------------------------------------------------------------------------------------#

	def ReplaceColsAtXT(panPos, paCol)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = ring_len(anPosU)

		for i = 1 to nLen
			This.ReplaceColAtXT(anPosU[i], paCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceColsAtPositionsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplacesNthColsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplaceColumnsAtXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplaceColumnsAtPositionsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		def ReplacesNthColumnsXT(panPos, paCol)
			This.ReplaceColsAtXT(panPos, paCol)

		#>

	  #-------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#-------------------------------------------------------------------------------------#

	def ReplaceTheseCols(paCols, paNewCol)
		if IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		anPos = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositions(anPos, paNewCol)

		def ReplaceTheseColumns(paCols, paNewCol)
			This.ReplaceTheseCols(paCols, paNewCol)


	  #-------------------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#-------------------------------------------------------------------------------------------------#

	def ReplaceTheseColsXT(paCols, paNewCol)
		if IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
			paNewCol = paNewCol[2]
		ok

		anPos = This.ColsToColNumbers(paCols)
		This.ReplaceColsAtPositionsXT(anPos, paNewCol)

		def ReplaceTheseColumnsXT(paCols, paNewCol)
			This.ReplaceTheseColsXT(paCols, paNewCol)

	  #===============================================================================#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A COLUMN NAME AND A LIST OF ROWS  #
	#===============================================================================#

	def ReplaceColNameAndData(pCol, pcColName, paColData)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthColName(nCol, pcColName)
		This.ReplaceNthCol(nCol, paColData)

		#< @FunctionAlternativeForm

		def ReplaceColumnNamedAndData(pCol, pcColName, paColData)
			This.ReplaceColNameAndData(pCol, pcColName, paColData)

		#>

	def ReplaceNthColNamedAndData(n, pcColName, paColData)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok

			if isList(pcColName) and Q(pcColName).IsWithOrByOrUsingNamedParam()
				pcColName = pcColName[2]
			ok

			if isList(paColData) and Q(paColData).IsAndNamedParam()
				pacolData = paColData[2]
			ok

			if NOT isString(pcColName)
				StzRaise("Incorrect param type! pcColName must be a string.")
			ok

			if NOT isList(paColData)
				StzRaise("Incorrect param type! paColData must be a list.")
			ok
		ok

		nMin = @Min([ ring_len(paColData), This.NumberOfRows() ])
		aTemp = []
		for i = 1 to nMin
			aTemp + paColData[i]
		next

		aContent = @aContent
		aContent[n][1] = pcColName
		aContent[n][2] = aTemp

		This.UpdateWith(aContent)


		#< @FunctionAlternativeForms

		def ReplaceNthColumnNamedAndData(n, pcColName, paColData)
			This.ReplaceNthColNamedAndData(n, pcColName, paColData)

		def ReplaceColNNamedAndData(n, pcColName, paColData)
			This.ReplaceNthColNamedAndData(n, pcColName, paColData)

		def ReplaceColumnNNamedAndData(n, pcColName, paColData)
			This.ReplaceNthColNamedAndData(n, pcColName, paColData)

		#>

	  #-------------------------------------------------------------------------------------------#
	 #  REPLACING A COLUMN BY AN OTHER PROVIDED AS A COLUMN NAME AND A LIST OF ROWS -- EXTENDED  #
	#-------------------------------------------------------------------------------------------#
	# ~> XT : If paColData has fewer items than required, it will be
	# supplemented with its items starting from the first one.

	def ReplaceColNameAndDataXT(pCol, pcColName, paColData)
		nCol = This.ColToColNumber(pCol)
		This.ReplaceNthColName(nCol, pcColName)
		This.ReplaceNthColXT(nCol, paColData)

		#< @FunctionAlternativeForm

		def ReplaceColumnNamedAndDataXT(pCol, pcColName, paColData)
			This.ReplaceColNameAndDataXT(pCol, pcColName, paColData)

		#>

	def ReplaceNthColNamedAndDataXT(n, pcColName, paColData)
		This.ReplaceNthColName(n, pcColName)
		This.ReplaceNthColXT(n, paColData)

		#< @FunctionAlternativeForms

		def ReplaceNthColumnNamedAndDataXT(n, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(n, pcColName, paColData)

		def ReplaceColNNamedAndDataXT(n, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(n, pcColName, paColData)

		def ReplaceColumnNNamedAndDataXT(n, pcColName, paColData)
			This.ReplaceNthColNamedAndDataXT(n, pcColName, paColData)

		#>

	  #==================================================================#
	 #  REPLACING ALL THE CELLS OF A COLUMN BY THE SAME PROVIDED VALUE  #
	#==================================================================#

	def ReplaceCellsInCol(pCol, pCell)
		if CheckingParams()
			if isList(pCell) and Q(pCell).IsWithOrByOrUsingNamedParam()
				pCell = pCell[2]
			ok
		ok

		nCol = This.ColToColNumber(pCol)
		nRows = This.NumberOfRows()
		aContent = @aContent

		for i = 1 to nRows
			aContent[nCol][2][i] = pCell
		next

		This.UpdateWith(aContent)


		def ReplaceCellsInColumn(pCol, pCell)
			This.ReplaceCellsInCol(pCol, pCell)

	  #------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS)  #
	#------------------------------------------------------------------------------------------------#
	#TODO // check for performance

	def ReplaceAllCols(paNewCol)
		if CheckingParams()

			if isList(paNewCol) and
			   IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
				paNewCol = paNewCol[2]
			ok

			if NOT isList(paNewCol)
				StzRaise("Incorrect param type! paNewCol must be a list.")
			ok
		ok

		nLen = This.NumberOfCols()

		for i = 1 to nLen
			This.ReplaceCol(i, paNewCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceAllColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		def ReplaceCols(paNewCols)
			This.ReplaceAllCols(paNewCols)

		def ReplaceColumns(paNewCol)
			This.ReplaceAllCols(paNewCol)

		#>

	  #------------------------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH A GIVEN NEW COLUMN (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#------------------------------------------------------------------------------------------------------------#
	#TODO // check for performance

	def ReplaceAllColsXT(paNewCol)
		if CheckingParams()

			if isList(paNewCol) and
			   IsOneOfTheseNamedParamsList(paNewCol,[ :With, :By, :Using ])
				paNewCol = paNewCol[2]
			ok

			if NOT isList(paNewCol)
				StzRaise("Incorrect param type! paNewCol must be a list.")
			ok
		ok

		nLen = This.NumberOfCols()

		for i = 1 to nLen
			This.ReplaceColXT(i, paNewCol)
		next

		#< @FunctionAlternativeForms

		def ReplaceAllColumnsXT(paNewCol)
			This.ReplaceAllColsXT(paNewCol)

		def ReplaceColsXT(paNewCols)
			This.ReplaceAllColsXT(paNewCols)

		def ReplaceColumnsXT(paNewCol)
			This.ReplaceAllColsXT(paNewCol)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  REPLACING ALL THE COLUMNS IN THE TABLE WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#----------------------------------------------------------------------------------------------#

	def ReplaceAllColsByMany(paCols, paNewCols)
		/* ... */

		StzRaise("Unsupported feature in this release!")

		def ReplaceAllColumsByMany(paCols, paNewCols)
			This.ReplaceAllColsByMany(paCols, paNewCols)

	#TODO : Add ReplaceAllColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #-----------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN COLUMNS WITH THE GIVEN COLUMNS (PROVIDED AS LISTS OF CELLS)  #
	#-----------------------------------------------------------------------------------#

	def ReplaceTheseColsByMany(paCols, paNewCols)
		if IsOneOfTheseNamedParamsList(paNewCols,[ :With, :By, :Using ])
			paNewCols = paNewCols[2]
		ok

		/* ... */

		StzRaise("Unsupported feature in this release!")

		#< @FunctionAlternativeForms

		def ReplaceTheseColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		def ReplaceColsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		def ReplaceColumnsByMany(paCols, paNewCols)
			This.ReplaceTheseColsByMany(paCols, paNewCols)

		#>

	#TODO // Add ReplaceTheseColsByManyXT()
	#--> When the new provided cols are all used --> restart from the first one

	  #===================================================================#
	 #  REPLACING THE CELLS OF THE GIVEN ROW BY THE PRIVIDED CELL VALUE  #
	#===================================================================#

	def ReplaceCellsInRow(pnRow, pCell)
		aNewRow = []
		nLen = This.NumberOfCols()

		for i = 1 to nLen
			aNewRow + pCell
		next

		This.ReplaceRow(pnRow, aNewRow)

	  #-----------------------------------------------------------------------------------------#
	 #  REPLACING A ROW (DEFINED BY ITS NUMBER) BY AN OTHER ONE (PROVIDED AS A LIST OF CELLS)  #
	#-----------------------------------------------------------------------------------------#

	def ReplaceRow(pnRow, paNewRow)
		if CheckingParams()
			if isList(pnRow) and
			   ( Q(pnRow).IsAtNamedParam() or
			     Q(pnRow).IsAtPositionNamedParam() )
				pnRow = pnRow[2]
			ok

			if isList(paNewRow) and
			   ( IsOneOfTheseNamedParamsList(paNewRow,[ :By, :With, :Using ]) or
			     Q(paNewRow).IsByRowNamedParam() or
			     Q(paNewRow).IsWithRowNamedParam() )

				paNewRow = paNewRow[2]
			ok
		ok

		aRowCells = This.RowAsPositions(pnRow)
		This.ReplaceCellsByMany(aRowCells, paNewRow)

		#< @FunctionAlternativeForm

		def ReplaceNthRow(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowN(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowAt(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		def ReplaceRowAtPosition(pnRow, paNewRow)
			This.ReplaceRow(pnRow, paNewRow)

		#>

	#-- EXTENDED FORM

	def ReplaceRowXT(pnRow, paNewRow)
		nNew  = ring_len(paNewRow)
		nRows = This.NumberOfRows()

		n = 0

		if nNew < nRows
			for i = nNew + 1 to nRows
				n++
				if n > nNew
					n = 1
				ok

				paNewRow + paNewRow[n]
			next

		but nNew > nRows
			for i = nNew to nRows + 1 step -1
				ring_remove(paNewRow, i)
			next
		ok

		This.ReplaceRow(pnRow, paNewRow)

		#< @FunctionAlternativeForm

		def ReplaceNthRowXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowNXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowAtXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		def ReplaceRowAtPositionXT(pnRow, paNewRow)
			This.ReplaceRowXT(pnRow, paNewRow)

		#>

	  #--------------------------------------------------------------------------------#
	 #  REPLACING ALL ROWS IN THE TABLE BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS)  #
	#--------------------------------------------------------------------------------#

	def ReplaceAllRows(paNewRow)
		if CheckingParams()
			if isList(paNewRow) and
			   IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
				paNewRow = paNewRow[2]
			ok

			if NOT isList(paNewRow)
				StzRaise("Incorrect param type! paNewRow must be a list.")
			ok
		ok

		nLenCols = @Min([ ring_len(paNewRow), ring_len(@aContent) ])
		nLenRows = This.NumberOfRows()
		aContent = @aContent

		for i = 1 to nLenCols
			for j = 1 to nLenRows
				aContent[i][2][j] = paNewRow[i]
			next
		next

		This.UpdateWith(aContent)

		#< @FunctionAlternativeForms

		def ReplaceRows(paNewRow)
			This.ReplaceAllRows(paNewRow)

		def ReplaceRowsWith(paNewRow)
			This.ReplaceAllRows(paNewRow)

		def ReplaceRowsBy(paNewRow)
			This.ReplaceAllRows(paNewRow)

		#>

	  #--------------------------------------------------------------------------------------------#
	 #  REPLACING ALL ROWS IN THE TABLE BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#--------------------------------------------------------------------------------------------#

	def ReplaceAllRowsXT(paNewRow)
		nRows = This.NumberOfRows()

		for i = 1 to nRows
			This.ReplaceRowXT(i, paNewRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		def ReplaceRowsWithXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		def ReplaceRowsByXT(paNewRow)
			This.ReplaceAllRowsXT(paNewRow)

		#>

	  #----------------------------------------------------------------------------------#
	 #  REPLACING ROWS AT GIVEN POSITIONS BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS)  #
	#----------------------------------------------------------------------------------#

	def ReplaceRowsAt(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = ring_len(anPosU)

		for i = 1 to nLen
			This.ReplaceRowAt(anPosU[i], paRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplacesNthRows(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplaceRowumnsAt(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplaceRowumnsAtPositions(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		def ReplacesNthRowumns(panPos, paRow)
			This.ReplaceRowsAt(panPos, paRow)

		#>

	  #----------------------------------------------------------------------------------------------#
	 #  REPLACING ROWS AT GIVEN POSITIONS BY A GIVEN ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#----------------------------------------------------------------------------------------------#

	def ReplaceRowsAtXT(panPos, paRow)
		if NOT ( isList(panPos) and @IsListOfNumbers(panPos) )
			StzRaise("Incorrect param type! panPos must be a list of numbers.")
		ok

		anPosU = U(panPos)
		nLen = ring_len(anPosU)

		for i = 1 to nLen
			This.ReplaceRowAtXT(anPosU[i], paRow)
		next

		#< @FunctionAlternativeForms

		def ReplaceRowsAtPositionsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplacesNthRowsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplaceRowumnsAtXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplaceRowumnsAtPositionsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		def ReplacesNthRowumnsXT(panPos, paRow)
			This.ReplaceRowsAtXT(panPos, paRow)

		#>

	  #-------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN ROWS WITH A GIVEN NEW ROW (PROVIDED AS A LIST OF CELLS)  #
	#-------------------------------------------------------------------------------#

	def ReplaceTheseRows(panRowsNumbers, paNewRow)
		if IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositions(panRowsNumbers, paNewRow)

		def ReplaceTheseRowumns(panRowsNumbers, paNewRow)
			This.ReplaceTheseRows(panRowsNumbers, paNewRow)

	  #-------------------------------------------------------------------------------------------#
	 #  REPLACING THE GIVEN ROWS WITH A GIVEN NEW ROW (PROVIDED AS A LIST OF CELLS) -- EXTENDED  #
	#-------------------------------------------------------------------------------------------#

	def ReplaceTheseRowsXT(panRowsNumbers, paNewRow)
		if IsOneOfTheseNamedParamsList(paNewRow,[ :With, :By, :Using ])
			paNewRow = paNewRow[2]
		ok

		This.ReplaceRowsAtPositionsXT(panRowsNumbers, paNewRow)

		def ReplaceTheseRowumnsXT(panRowsNumbers, paNewRow)
			This.ReplaceTheseRowsXT(panRowsNumbers, paNewRow)

	  #===============================================================#
	 #  REPLACING THE CELLS IN THE GIVEN ROWS BY THE PTOVIDED VALUE  #
	#===============================================================#

	def ReplaceCellsInTheseRows(paRows, pCell)
		if IsOneOfTheseNamedParamsList(paNewrows,[ :With, :By, :Using ])
			paNewrows = paNewrows[2]
		ok

		aCells = This.CellsInTheseRowsAsPositions(paRows)
		This.ReplaceCells(aCells, pCell)


		def ReplaceTheseRowsWith(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)

		def ReplaceTheseRowsBy(paRows, pCell)
			This.ReplaceTheseRows(paRows, pCell)


	  #===================================================#
	 #  REPLACING ALL OCCURRENCE OF A CELL IN THE TABLE  #
	#===================================================#

	def ReplaceAllCS(pCellValue, pNewCellValue, pCaseSensitive)
		aCellsPos = This.FindAllCS(pCellValue, pCaseSensitive)
		This.ReplaceCells(aCellsPos, pNewCellValue)

		#< @FunctionAlternatives

		def ReplaceAllOccurrencesOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEachOccurrenceOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEveryOccurrenceOfCellCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		#--

		def ReplaceAllOccurrencesCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEachOccurrenceCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		def ReplaceEveryOccurrenceCS(pCellValue, pNewCellValue, pCaseSensitive)
			This.ReplaceCellCS(pCellValue, pNewCellValue, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def ReplaceAll(pCellValue, pNewCellValue)
		This.ReplaceAllCS(pCellValue, pNewCellValue, 1)

		#< @FunctionAlternatives

		def ReplaceAllOccurrencesOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEachOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEveryOccurrenceOfCell(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#--

		def ReplaceAllOccurrences(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEachOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		def ReplaceEveryOccurrence(pCellValue, pNewCellValue)
			This.ReplaceCell(pCellValue, pNewCellValue)

		#>

	  #---------------------------------------------------#
	 #  REPLACING NTH OCCURRENCE OF A CELL IN THE TABLE  #
	#---------------------------------------------------#

	def ReplaceNthCS(n, pValue, pNewCellValue, pCaseSensitive)
		aCellPos = This.FindNthCS(n, pValue, pCaseSensitive)
		This.ReplaceCell(aCellPos, pNewCellValue)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceNth(n, pValue, pNewCellValue)
		This.ReplaceNthCS(n, pValue, pNewCellValue, 1)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceFirstCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(1, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceFirst(pValue, pNewCellValue)
		This.ReplaceFirstCS(pValue, pNewCellValue, 1)

	  #-----------------------------------------------------#
	 #  REPLACING FIRST OCCURRENCE OF A CELL IN THE TABLE  #
	#-----------------------------------------------------#

	def ReplaceLastCS(pValue, pNewCellValue, pCaseSensitive)
		This.ReplaceNthCS(:Last, pValue, pNewCellValue, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def ReplaceLast(pValue, pNewCellValue)
		This.ReplaceLastCS(pValue, pNewCellValue, 1)

	  #====================================#
	 #  REPLACING SUBVALUES INSIDE CELLS  #
	#====================================#

	def ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInCell(pnCol, pnRow, pSubValue, pNewSubValue)
		This.ReplaceInCellCS(pnCol, pnRow, pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInCells(paCellsPos, pSubValue, pNewSubValue)
		This.ReplaceInCellsCS(paCellsPos, pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInCellsByMany(paCellsPos, pSubValues, pNewSubValue)
		This.ReplaceInCellsByManyCS(paCellsPos, pSubValues, pNewSubValue, 1)

	# Add ReplaceInCellsByManyXT() : if all repalaced restart at the 1st one

	#--

	def ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInSection(paCellPos1, paCellPos2,  pSubValue, pNewSubValue)
		This.ReplaceInSectionCS(paCellPos1, paCellPos2,  pSubValue, pNewSubValue, 1)

	#--

	def ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, pCaseSensitive) // TODO
		/* ... */
		stzraise("Function not yet implemented!")

	def ReplaceInSectionByMany(paCellPos1, paCellPos2,  pSubValues, pNewSubValue)
		This.ReplaceInSectionByManyCS(paCellPos1, paCellPos2,  pSubValues, pNewSubValue, ;CaseSensitive = 1)

	# Add ReplaceInSectionByManyXT() : if all replaced restart at the 1st one

	#--

	def ReplaceInSectionsCS(aSections, pSubValue, pCaseSensitive)
		/* ... */
		stzraise("Function not yet implemented!")

	ReplaceInSections(aSections, pSubValue)
		This.ReplaceInSectionsCS(aSections, pSubValue, 1)

	#--

	def ReplaceInSectionsByManyCS(aSections, paSubValues, pCaseSensitive)
		/* ... */
		stzraise("Function not yet implemented!")

	ReplaceInSectionsByMany(aSections, paSubValues)
		This.ReplaceInSectionsByManyCS(aSections, paSubValues, 1)

	#-- Add ReplaceInSectionsByManyXT() : if all replaced restrat at 1st one
