#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZTABLEDISPLAY             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Table display subclass -- show, toString,   #
#                  transpose, CSV, JSON, HTML import/export.   #
#   Version      : V0.9 (2026)                                #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#


  /////////////////
 ///   CLASS   ///
/////////////////

class stzTableDisplay from stzTable

	  #-----------#
	 #  DSIPLAY  #
	#-----------#

	def ToString()
		return This._displayFullTable()

	def Show()
		? This._displayFullTable()

	def ShowFilter(paFilterCriteria)
		? _displayFilteredTable(paFilterCriteria)

    # New display method to show table contents

    def Display(paFilterCriteria)

        # If no filter criteria provided, display full table

        if paFilterCriteria = NULL
            return This._displayFullTable()

        else
            return This._displayFilteredTable(paFilterCriteria)
        ok

    # Internal method to display full table

    def _displayFullTable()
        # Get column names and content
        acColNames = This.ColNames()
        aContent = @aContent

        # Calculate column widths
        aColWidths = []
        nCols = ring_len(acColNames)

        # First pass: calculate max width for each column header
        for i = 1 to nCols
            nMaxWidth = ring_len(acColNames[i])

            # Check column values

            aColData = aContent[i][2]
			nLenCol = ring_len(aColData)

            for j = 1 to nLenCol

				if isNumber(aColData[j]) or isString(aColData[j])
                	cellValue = "" + aColData[j]
				else
					cellValue = @@(aColData[j])
				ok

                if stzlen(cellValue) > nMaxWidth
                    nMaxWidth = stzlen(cellValue)
                ok

            next

            aColWidths + (nMaxWidth + 2)  # Add padding

        next

        # Build output string
        cOutput = ""

        # Top border

        cLine = @aBorder[:TopLeft]

        for i = 1 to nCols

            cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])

			if i < nCols
				cLine += @aBorder[:TeeDown]
			else
				cLine += @aBorder[:TopRight]
			ok

        next

        cOutput += cLine + NL

        # Header row

        cLine = @aBorder[:Vertical]

        for i = 1 to nCols
            cLine += CenterText(@Capitalise(acColNames[i]), aColWidths[i]) + @aBorder[:Vertical]
        next

        cOutput += cLine + NL

        # Separator

        cLine = @aBorder[:TeeRight]

        for i = 1 to nCols

            cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])

			if i < nCols
				cLine += @aBorder[:Cross]
			else
				cLine += @aBorder[:TeeLeft]
			ok

        next

        cOutput += cLine + NL

        # Data rows

        nRows = This.NumberOfRows()

        for r = 1 to nRows

            cLine = @aBorder[:Vertical]

            for i = 1 to nCols

				cellValue = ""
                val = This.Content()[i][2][r]
				if isNumber(val) or isString(val)
                	cellValue = "" + val
				else
					cellValue = @@(val)
				ok

                # Right-align numbers, left-align strings

                if isNumber(cellValue) or (isString(cellValue) and cellValue != "" and @IsNumberInString(cellValue))
                    cLine += " " + PadLeft(cellValue, aColWidths[i] - 2) + " " + @aBorder[:Vertical]
                else
                    cLine += " " + PadRight(cellValue, aColWidths[i] - 2) + " " + @aBorder[:Vertical]
                ok

            next

            cOutput += cLine + NL

        next

        # Bottom border

        cLine = @aBorder[:BottomLeft]

        for i = 1 to nCols

            cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])

			if i < nCols
				cLine += @aBorder[:TeeUp]
			else
				cLine += @aBorder[:BottomRight]
			ok

        next

        cOutput += cLine

        return cOutput

    # Internal method to display filtered table

    def _displayFilteredTable(paFilterCriteria)

        # Create a filtered copy of the table

        oFilteredTable = This.FilterQ(paFilterCriteria)

        # Use the full table display method on the filtered table

        return oFilteredTable.Display(NULL)

	  #----------------------------------------#
	 #  DISPLAYING THE TABLE - EXTENDED FORM  #
	#----------------------------------------#

	# Master method orchestrating the submethods
	def ShowXT(pParams) #AI // Refactored to small methods using GrockAI
		# Initialize flags
		bRowNumber = FALSE
		bSubTotal = FALSE
		bGrandTotal = FALSE

		# Process parameters and ensure boolean values
		processParameters(pParams, bRowNumber, bSubTotal, bGrandTotal)
		bRowNumber = @if(not isNull(pParams[:RowNumber]), pParams[:RowNumber], FALSE)
		bSubTotal = @if(not isNull(pParams[:SubTotal]), pParams[:SubTotal], FALSE)
		bGrandTotal = @if(not isNull(pParams[:GrandTotal]), pParams[:GrandTotal], FALSE)

		# Get column names and content
		acColNames = This.ColNames()
		aContent = @aContent

		# Calculate column widths
		aColWidths = calculateColumnWidths(acColNames, aContent, bRowNumber, bGrandTotal)

		# Adjust for row numbers if needed
		adjustForRowNumbers(bRowNumber, aColWidths, acColNames)

		# Build and return the output string
		cOutput = buildOutput(acColNames, aContent, aColWidths, bRowNumber, bSubTotal, bGrandTotal)

		? cOutput

	# Submethod to process parameters and set flags
	#TODO // Redesign this method the Softanza way!
	def processParameters(pParams, bRowNumber, bSubTotal, bGrandTotal, bCleanDesign)
		if pParams = NULL
			# Use defaults
		else
			if isList(pParams)
				if ring_len(pParams) = 0
					# Use defaults
				else
					nLenP = ring_len(pParams)
					for i = 1 to nLenP
						if isList(pParams[i])
							cParamName = StzLower(string(pParams[i][1]))
							if ring_len(pParams[i]) >= 2
								if StzLower(cParamName) = "rownumber"
									bRowNumber = pParams[i][2]
								but StzLower(cParamName) = "subtotal"
									bSubTotal = pParams[i][2]
								but StzLower(cParamName) = "grandtotal"
									bGrandTotal = pParams[i][2]

								ok
							ok
						but isString(pParams[i])
							cParam = pParams[i]
							if @substr(cParam, 1, 9) = "rownumber"
								bRowNumber = TRUE
							but @substr(cParam, 1, 8) = "subtotal"
								bSubTotal = TRUE
							but @substr(cParam, 1, 10) = "grandtotal"
								bGrandTotal = TRUE
							ok
						ok
					next
				ok

			but IsHashList(pParams)
				if HasKey(pParams, :RowNumber)
					bRowNumber = pParams[:RowNumber]
				ok

				if HasKey(pParams, :SubTotal)
					bSubTotal = pParams[:SubTotal]
				ok

				if HasKey(pParams, :GrandTotal)
					bGrandTotal = pParams[:GrandTotal]
				ok
			ok
		ok

		# Ensure boolean values
		bRowNumber = @if(IsBoolean(bRowNumber), bRowNumber, FALSE)
		bSubTotal = @if(IsBoolean(bSubTotal), bSubTotal, FALSE)
		bGrandTotal = @if(IsBoolean(bGrandTotal), bGrandTotal, FALSE)

	# Submethod to calculate column widths
	def calculateColumnWidths(acColNames, aContent, bRowNumber, bGrandTotal)
		aColWidths = []
		nCols = ring_len(acColNames)

		for i = 1 to nCols
			nMaxWidth = ring_len(acColNames[i])
			aColData = aContent[i][2]
			nLenCol = ring_len(aColData)

			for j = 1 to nLenCol
				if isString(aColData[j]) or isNumber(aColData[j])
					cellValue = "" + aColData[j]
				else
					cellValue = @@(aColData[j])
				ok
				nLenCell = stzlen(cellValue)
				if nLenCell > nMaxWidth
					nMaxWidth = nLenCell
				ok
			next

			nLenTemp = ring_len("Product X Total")
			if i = 1
				if nMaxWidth < nLenTemp
					nMaxWidth = nLenTemp
				ok
			ok

			nLenTemp = ring_len("GRAND-TOTAL")
			if i = 1 and bGrandTotal
				if nMaxWidth < nLenTemp
					nMaxWidth = nLenTemp
				ok
			ok

			aColWidths + (nMaxWidth + 2)
		next

		return aColWidths

	# Submethod to adjust column widths and names for row numbers
	def adjustForRowNumbers(bRowNumber, aColWidths, acColNames)

		if bRowNumber
			nRowNumWidth = ring_len("" + This.NumberOfRows()) + 2
			aColWidths = ring_insert(aColWidths, 1, nRowNumWidth)
			acColNames = ring_insert(acColNames, 1, "#")
		ok

	# Submethod to build the output string
	def buildOutput(acColNames, aContent, aColWidths, bRowNumber, bSubTotal, bGrandTotal)
		cOutput = ""
		nCols = ring_len(acColNames)

		# Top border
		cLine = @aBorder[:TopLeft]
		for i = 1 to nCols
			cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])
			if i < nCols
				cLine += @aBorder[:TeeDown]
			else
				cLine += @aBorder[:TopRight]
			ok
		next
		cOutput += cLine + NL

		# Header row
		cLine = @aBorder[:Vertical]
		for i = 1 to nCols
			cLine += CenterText(@Capitalise(acColNames[i]), aColWidths[i]) + @aBorder[:Vertical]
		next
		cOutput += cLine + NL

		# Separator
		cLine = @aBorder[:TeeRight]
		for i = 1 to nCols
			cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])
			if i < nCols
				cLine += @aBorder[:Cross]
			else
				cLine += @aBorder[:TeeLeft]
			ok
		next
		cOutput += cLine + NL

		# Data rows with aggregation
		cOutput += buildDataRows(aContent, aColWidths, bRowNumber, bSubTotal, bGrandTotal, nCols)

		# Grand total
		if bGrandTotal
			cOutput += buildGrandTotal(aColWidths, bRowNumber, nCols)
		ok

		# Bottom border
		cLine = @aBorder[:BottomLeft]
		for i = 1 to nCols
			cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])
			if i < nCols
				cLine += @aBorder[:TeeUp]
			else
				cLine += @aBorder[:BottomRight]
			ok
		next
		cOutput += cLine

		return cOutput

	# Submethod to build data rows with subtotals
	def buildDataRows(aContent, aColWidths, bRowNumber, bSubTotal, bGrandTotal, nCols)
		cOutput = ""
		nRows = This.NumberOfRows()
		nGroupCol = @if(bRowNumber, 2, 1)
		cCurrentGroup = ""
		aGroups = []
		aGroupTotals = []
		aGrandTotals = []

		for i = 1 to nCols
			aGrandTotals + 0
		next

		# First pass: gather groups and calculate totals
		for r = 1 to nRows

			cGroup = "" + aContent[nGroupCol][2][r]

			if NOT StzFind(aGroups, cGroup) > 0
				aGroups + cGroup
				aGroupTotals[cGroup] = []
				for i = 1 to nCols
					aGroupTotals[cGroup] + 0
				next
			ok

			for i = 1 to nCols
				if bRowNumber and i = 1
					loop
				ok
				nDataCol = @if(bRowNumber, i - 1, i)
				if nDataCol > 0 and nDataCol <= ring_len(aContent)
					cellValue = aContent[nDataCol][2][r]
					if not (isNumber(cellValue) or isString(cellValue))
						cellValue = @@(cellValue)
					ok
					if isNumber(cellValue) or (isString(cellValue) and cellValue != "" and @IsNumberInString(cellValue))
						aGroupTotals[cGroup][i] += (0 + cellValue)
						aGrandTotals[i] += (0 + cellValue)
					ok
				ok
			next
		next

		# Second pass: display data with totals
		cCurrentGroup = ""
		for r = 1 to nRows
			cGroup = "" + aContent[nGroupCol][2][r]

			if bSubTotal and cCurrentGroup != "" and cGroup != cCurrentGroup
				cOutput += buildSubTotalRow(aColWidths, nCols, bRowNumber, nGroupCol, cCurrentGroup, aGroupTotals)
			ok

			cCurrentGroup = cGroup
			cLine = @aBorder[:Vertical]
			for i = 1 to nCols
				if bRowNumber and i = 1
					cLine += " " + PadLeft("" + r, aColWidths[i] - 2) + " " + @aBorder[:Vertical]
				else
					nDataCol = @if(bRowNumber, i - 1, i)
					if nDataCol > 0 and nDataCol <= ring_len(aContent)
						cellValue = aContent[nDataCol][2][r]
						if NOT (isNumber(cellValue) or isString(cellValue))
							cellValue = @@(cellValue)
						ok
						if isNumber(cellValue) or (isString(cellValue) and cellValue != "" and @IsNumberInString(cellValue))
							cLine += " " + PadLeft(cellValue, aColWidths[i] - 2) + " " + @aBorder[:Vertical]
						else
							cLine += " " + PadRight(cellValue, aColWidths[i] - 2) + " " + @aBorder[:Vertical]
						ok
					else
						cLine += " " + PadRight("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
					ok
				ok
			next
			cOutput += cLine + NL

			if bSubTotal and r = nRows
				cOutput += buildSubTotalRow(aColWidths, nCols, bRowNumber, nGroupCol, cCurrentGroup, aGroupTotals)
			ok
		next

		return cOutput

	# Submethod to build subtotal row
	def buildSubTotalRow(aColWidths, nCols, bRowNumber, nGroupCol, cCurrentGroup, aGroupTotals)
		cOutput = ""
		cLine = @aBorder[:Vertical]
		for i = 1 to nCols
			cLine += " " + RepeatChar("-", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
		next
		cOutput += cLine + NL

		cLine = @aBorder[:Vertical]
		for i = 1 to nCols
			if bRowNumber and i = 1
				cLine += " " + PadLeft("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
			but i = nGroupCol
				cLine += " " + PadLeft(" Sub-total", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
			but (i = nGroupCol + 1 and not bRowNumber) or (i = nGroupCol + 1 and bRowNumber)
				cLine += " " + PadLeft("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
			else
				if isNumber(aGroupTotals[cCurrentGroup][i]) and aGroupTotals[cCurrentGroup][i] != 0
					cLine += " " + PadLeft("" + aGroupTotals[cCurrentGroup][i], aColWidths[i] - 2) + " " + @aBorder[:Vertical]
				else
					cLine += " " + PadLeft("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
				ok
			ok
		next
		cOutput += cLine + NL

		cLine = @aBorder[:Vertical]
		for i = 1 to nCols
			cLine += " " + RepeatChar(" ", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
		next
		cOutput += cLine + NL

		return cOutput

	# Submethod to build grand total
	def buildGrandTotal(aColWidths, bRowNumber, nCols)
		cOutput = ""
		cLine = @aBorder[:TeeRight]
		for i = 1 to nCols
			cLine += StrFill(aColWidths[i], @aBorder[:Horizontal])
			if i < nCols
				cLine += @aBorder[:Cross]
			else
				cLine += @aBorder[:TeeLeft]
			ok
		next
		cOutput += cLine + NL

		cLine = @aBorder[:Vertical]
		for i = 1 to nCols
			if bRowNumber and i = 1
				cLine += " " + PadLeft("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
			but i = @if(bRowNumber, 2, 1)
				cLine += PadLeft("GRAND-TOTAL ", aColWidths[i]) + @aBorder[:Vertical]
			but i = @if(bRowNumber, 3, 2)
				cLine += " " + PadLeft("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
			else
				if isNumber(aGrandTotals[i]) and aGrandTotals[i] != 0
					cLine += " " + PadLeft("" + aGrandTotals[i], aColWidths[i] - 2) + " " + @aBorder[:Vertical]
				else
					cLine += " " + PadLeft("", aColWidths[i] - 2) + " " + @aBorder[:Vertical]
				ok
			ok
		next
		cOutput += cLine + NL

		return cOutput

	#---------------------------------#
	#  TRANSPOSINT THE TABLE CONTENT  #
	#---------------------------------#


	def Transpose()

	    # Get dimensions directly from @aContent
	    nCols = ring_len(@aContent)
	    if nCols = 0
	        return
	    ok
	    nRows = ring_len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = FALSE
	    @aOriginalColNames = []
	    for i = 1 to nCols
	        @aOriginalColNames + @aContent[i][1]
	    next

	    # Generate new column names
	    acNewColNames = []
	    for i = 1 to nRows
	        acNewColNames + ("COL" + i)
	    next

	    # Build new content directly in target format
	    aNewContent = []
	    for i = 1 to nRows
	        aNewRow = []
	        for j = 1 to nCols
	            aNewRow + @aContent[j][2][i]
	        next
	        aNewContent + [acNewColNames[i], aNewRow]
	    next

	    This.UpdateWith(aNewContent)

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []


		def TransposeQ()
			This.Transpose()
			return This


		def Turn()
			This.Transpose()

		def SwapColsAndRows()
			This.Transpose()

		def SwapRowsAndCols()
			This.Transpose()

		def SwitchColsAndRows()
			This.Transpose()

		def SwithRowsAndCols()
			This.Transpose()


	def TransposeXT() # Keeps original colnames

	    # Get dimensions and column names directly from @aContent
	    nCols = ring_len(@aContent)
	    if nCols = 0
	        return
	    ok
	    nRows = ring_len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = True
	    @aOriginalColNames = []
	    for i = 1 to nCols
	        @aOriginalColNames + @aContent[i][1]
	    next

	    # Generate new column names (all follow COL pattern)
	    acNewColNames = []
	    for i = 1 to nRows
	        acNewColNames + ("COL" + i)
	    next

	    # Build new content
	    aNewContent = []

	    # First column contains original headers
	    aFirstColumn = []
	    for i = 1 to nCols
	        aFirstColumn + @aContent[i][1]
	    next
	    aNewContent + [acNewColNames[1], aFirstColumn]

	    # Remaining columns contain transposed data
	    for i = 1 to nRows
	        aNewRow = []
	        for j = 1 to nCols
	            aNewRow + @aContent[j][2][i]
	        next
	        aNewContent + [("COL" + (i+1)), aNewRow]
	    next

	    This.UpdateWith(aNewContent)

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []

		def TransposeWithColNames()
			This.TansposeXT()

	def TransposeBack()
	    # Only works if table was transposed with headers
	    if ring_len(@aOriginalColNames) = 0
	        raise("Cannot transpose back: no header information found")
	    ok

	    # Get data columns (skip first column which contains headers)
	    aDataColumns = []
	    for i = 2 to ring_len(@aContent)
	        aDataColumns + @aContent[i][2]
	    next

	    # Transpose back
	    nOriginalCols = ring_len(@aOriginalColNames)
	    nOriginalRows = ring_len(aDataColumns)

	    aNewContent = []
	    for i = 1 to nOriginalCols
	        aNewRow = []
	        for j = 1 to nOriginalRows
	            aNewRow + aDataColumns[j][i]
	        next
	        aNewContent + [@aOriginalColNames[i], aNewRow]
	    next

	    This.UpdateWith(aNewContent)

	    # Clear transpose flags
	    @bTransposedWithHeaders = False
	    @aOriginalColNames = []

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []

	def CanTransposeBack()
	    return (@bTransposedWithHeaders and @aOriginalColNames != [])


	  #---------------------#
	 #  UTILITY FUNCTIONS  #
	#---------------------#

	def PadRight(cText, nWidth)
		if NOT (isNumber(cText) or isString(cText))
			cText = @@(cText)
		ok

		# Pad text to the right
		cStr = "" + cText
		nPad = nWidth - stzlen(cStr)
		if nPad > 0
			return cStr + RepeatChar(" ", nPad)
		else
			return cStr
		ok

	def PadLeft(cText, nWidth)
		if NOT (isNumber(cText) or isString(cText))
			text = @@(cText)
		ok

		# Pad text to the left
		cStr = "" + cText
		nPad = nWidth - stzlen(cStr)
		if nPad > 0
			return RepeatChar(" ", nPad) + cStr
		else
			return cStr
		ok

	def CenterText(cText, nWidth)
		if NOT (isNumber(cText) or isString(cText))
			cText = Q(cText).Stringified()
		ok

		# Center text within width
		cStr = "" + cText
		nPadTotal = nWidth - stzlen(cStr)
		if nPadTotal <= 0
			return cStr
		ok

		nPadLeft = floor(nPadTotal / 2)
		nPadRight = nPadTotal - nPadLeft

		return RepeatChar(" ", nPadLeft) + cStr + RepeatChar(" ", nPadRight)

	def StrFill(nCount, cChar)

		# Create string of repeated character
		cResult = ""
		for i = 1 to nCount
			cResult += cChar
		next
		return cResult

	  #======================================================================#
	 #  IMPORTING TABLE CONTENT FROM AN EXTERNAL STRING (CSV, JSON OR HTML)  #
	#========================================================================#

	def ToCSV()
		return ListToCSV(This.Content())

	def ToCSVXT(pcSep)
		return ListToCSVXT(This.Content(), pcSep)

	#---

	def FromCSV(pcCSV)
		This.UpdateWith(CSVToList(pcCSV))

		def FromCSVString(pcCSV)
			This.FromCSV(pcCSV)

	def FromCSVXT(pcCSV, pcSep)
		This.UpdateWith(CSVToListXT(pcCSV, pcSep))

		def FromCSVStringXT(pcCSV, pcSep)
			This.FromCSVXT(pcCSV, pcSep)

	#--

	def ToJSON() # Compact Json (without NL and TAB indendtaion)
		return ListToJson(This.Content())

	def ToJsonXT() # Json with NL and TAB-indentation
		return ListToJsonXT(This.Content())

	def FromJson(pcJsonStr) #TODO Test it
		if NOT isString(pcJsonStr)
			StzRaise("Incorrect param type! pcJsonStr must be a string.")
		ok

		if NOT @IsJson(pcJsonStr)
			StzRaise("Can't proceed! This string you provided is not in JSON.")
		ok

		aData = JsonToList(pcJsonStr)
		if Not ( @IsHashList(aData) and @IsTable(aData) )
			StzRaise("Can't proceed! The Json structure does not correspond to a stzTable structure.")
		ok

		This.UpdateWith(aData)

	#---

	def ToHtml()
		return @Simplify(This.ToHtmlXT())

		def ToHtmlTable()
			return This.ToHtml()

	def ToHtmlXT()
	    aContent = @aContent
	    if ring_len(aContent) = 0
	        return '<table class="data"><thead><tr></tr></thead><tbody></tbody></table>'
	    ok

	    # Ensure all columns have exactly the same number of values
	    # This is critical for the buggy parser
	    nLen = ring_len(aContent)
	    nRows = 0
	    for i = 1 to nLen
	        if ring_len(aContent[i][2]) > nRows
	            nRows = ring_len(aContent[i][2])
	        ok
	    next

	    # Pad shorter columns with empty strings to match longest column
	    for i = 1 to nLen
	        while ring_len(aContent[i][2]) < nRows
	            aContent[i][2] + ""
	        end
	    next

	    cHtml = '<table class="data" id="products">' + nl
	    cHtml += '<thead>' + nl
	    cHtml += nl
	    cHtml += '<tr>' + nl

	    # Generate header row - ensure format matches parser expectations
	    for i = 1 to nLen
	        cHtml += '            ' + '<th scope="col">' + data[i][1] + '</th>' + nl
	    next

	    cHtml += '</tr>' + nl
	    cHtml += nl
	    cHtml += '</thead>' + nl
	    cHtml += nl
	    cHtml += '<tbody>' + nl
	    cHtml += nl

	    # Generate body rows - use exact format the parser expects
	    for nRowIndex = 1 to nRows
	        cHtml += '<tr class="row">' + nl

	        # For each column, get the value at this row index
	        for nColIndex = 1 to nLen
	            cValue = aContent[nColIndex][2][nRowIndex]
	            cHtml += '        ' + '<td>' + cValue + '</td>' + nl
	        next

	        cHtml += nl
	        cHtml += '</tr>' + nl
	        cHtml += nl
	    next

	    cHtml += '</tbody>' + nl
	    cHtml += '</table>' + nl
			return cHtml

		def ToHtmlTableXT()
			return This.ToHtmlXT()


	def FromHtml(pcHtmlTable)

		if NOT isString(pcHtmlTable)
			StzRaise("Incorrect param type! pcHtmlTable must be a string.")
		ok

		This.UpdateWith(StzStringQ(pcHtmlTable).HtmlToTable())
