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
        _acColNames_ = This.ColNames()
        _aContent_ = @aContent

        # Calculate column widths
        _aColWidths_ = []
        _nCols_ = len(_acColNames_)

        # First pass: calculate max width for each column header
        for i = 1 to _nCols_
            _nMaxWidth_ = len(_acColNames_[i])

            # Check column values

            _aColData_ = _aContent_[i][2]
			_nLenCol_ = len(_aColData_)

            for j = 1 to _nLenCol_

				if isNumber(_aColData_[j]) or isString(_aColData_[j])
                	_cellValue_ = "" + _aColData_[j]
				else
					_cellValue_ = @@(_aColData_[j])
				ok

                if stzlen(_cellValue_) > _nMaxWidth_
                    _nMaxWidth_ = stzlen(_cellValue_)
                ok

            next

            _aColWidths_ + (_nMaxWidth_ + 2)  # Add padding

        next

        # Build output string
        _cOutput_ = ""

        # Top border

        _cLine_ = @aBorder[:TopLeft]

        for i = 1 to _nCols_

            _cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])

			if i < _nCols_
				_cLine_ += @aBorder[:TeeDown]
			else
				_cLine_ += @aBorder[:TopRight]
			ok

        next

        _cOutput_ += _cLine_ + NL

        # Header row

        _cLine_ = @aBorder[:Vertical]

        for i = 1 to _nCols_
            _cLine_ += CenterText(@Capitalise(_acColNames_[i]), _aColWidths_[i]) + @aBorder[:Vertical]
        next

        _cOutput_ += _cLine_ + NL

        # Separator

        _cLine_ = @aBorder[:TeeRight]

        for i = 1 to _nCols_

            _cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])

			if i < _nCols_
				_cLine_ += @aBorder[:Cross]
			else
				_cLine_ += @aBorder[:TeeLeft]
			ok

        next

        _cOutput_ += _cLine_ + NL

        # Data rows

        _nRows_ = This.NumberOfRows()

        for r = 1 to _nRows_

            _cLine_ = @aBorder[:Vertical]

            for i = 1 to _nCols_

				_cellValue_ = ""
                _val_ = This.Content()[i][2][r]
				if isNumber(_val_) or isString(_val_)
                	_cellValue_ = "" + _val_
				else
					_cellValue_ = @@(_val_)
				ok

                # Right-align numbers, left-align strings

                if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
                    _cLine_ += " " + PadLeft(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
                else
                    _cLine_ += " " + PadRight(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
                ok

            next

            _cOutput_ += _cLine_ + NL

        next

        # Bottom border

        _cLine_ = @aBorder[:BottomLeft]

        for i = 1 to _nCols_

            _cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])

			if i < _nCols_
				_cLine_ += @aBorder[:TeeUp]
			else
				_cLine_ += @aBorder[:BottomRight]
			ok

        next

        _cOutput_ += _cLine_

        return _cOutput_

    # Internal method to display filtered table

    def _displayFilteredTable(paFilterCriteria)

        # Create a filtered copy of the table

        _oFilteredTable_ = This.FilterQ(paFilterCriteria)

        # Use the full table display method on the filtered table

        return _oFilteredTable_.Display(NULL)

	  #----------------------------------------#
	 #  DISPLAYING THE TABLE - EXTENDED FORM  #
	#----------------------------------------#

	# Master method orchestrating the submethods
	def ShowXT(pParams) #AI // Refactored to small methods using GrockAI
		# Initialize flags
		_bRowNumber_ = FALSE
		_bSubTotal_ = FALSE
		_bGrandTotal_ = FALSE

		# Process parameters and ensure boolean values
		processParameters(pParams, _bRowNumber_, _bSubTotal_, _bGrandTotal_)
		_bRowNumber_ = @if(not isNull(pParams[:RowNumber]), pParams[:RowNumber], FALSE)
		_bSubTotal_ = @if(not isNull(pParams[:SubTotal]), pParams[:SubTotal], FALSE)
		_bGrandTotal_ = @if(not isNull(pParams[:GrandTotal]), pParams[:GrandTotal], FALSE)

		# Get column names and content
		_acColNames_ = This.ColNames()
		_aContent_ = @aContent

		# Calculate column widths
		_aColWidths_ = calculateColumnWidths(_acColNames_, _aContent_, _bRowNumber_, _bGrandTotal_)

		# Adjust for row numbers if needed
		adjustForRowNumbers(_bRowNumber_, _aColWidths_, _acColNames_)

		# Build and return the output string
		_cOutput_ = buildOutput(_acColNames_, _aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_)

		? _cOutput_

	# Submethod to process parameters and set flags
	#TODO // Redesign this method the Softanza way!
	def processParameters(pParams, _bRowNumber_, _bSubTotal_, _bGrandTotal_, bCleanDesign)
		if pParams = NULL
			# Use defaults
		else
			if isList(pParams)
				if len(pParams) = 0
					# Use defaults
				else
					_nLenP_ = len(pParams)
					for i = 1 to _nLenP_
						if isList(pParams[i])
							_cParamName_ = StzLower(string(pParams[i][1]))
							if len(pParams[i]) >= 2
								if StzLower(_cParamName_) = "rownumber"
									_bRowNumber_ = pParams[i][2]
								but StzLower(_cParamName_) = "subtotal"
									_bSubTotal_ = pParams[i][2]
								but StzLower(_cParamName_) = "grandtotal"
									_bGrandTotal_ = pParams[i][2]

								ok
							ok
						but isString(pParams[i])
							_cParam_ = pParams[i]
							if @StzMid(_cParam_, 1, 9) = "rownumber"
								_bRowNumber_ = TRUE
							but @StzMid(_cParam_, 1, 8) = "subtotal"
								_bSubTotal_ = TRUE
							but @StzMid(_cParam_, 1, 10) = "grandtotal"
								_bGrandTotal_ = TRUE
							ok
						ok
					next
				ok

			but IsHashList(pParams)
				if HasKey(pParams, :RowNumber)
					_bRowNumber_ = pParams[:RowNumber]
				ok

				if HasKey(pParams, :SubTotal)
					_bSubTotal_ = pParams[:SubTotal]
				ok

				if HasKey(pParams, :GrandTotal)
					_bGrandTotal_ = pParams[:GrandTotal]
				ok
			ok
		ok

		# Ensure boolean values
		_bRowNumber_ = @if(IsBoolean(_bRowNumber_), _bRowNumber_, FALSE)
		_bSubTotal_ = @if(IsBoolean(_bSubTotal_), _bSubTotal_, FALSE)
		_bGrandTotal_ = @if(IsBoolean(_bGrandTotal_), _bGrandTotal_, FALSE)

	# Submethod to calculate column widths
	def calculateColumnWidths(_acColNames_, _aContent_, _bRowNumber_, _bGrandTotal_)
		_aColWidths_ = []
		_nCols_ = len(_acColNames_)

		for i = 1 to _nCols_
			_nMaxWidth_ = len(_acColNames_[i])
			_aColData_ = _aContent_[i][2]
			_nLenCol_ = len(_aColData_)

			for j = 1 to _nLenCol_
				if isString(_aColData_[j]) or isNumber(_aColData_[j])
					_cellValue_ = "" + _aColData_[j]
				else
					_cellValue_ = @@(_aColData_[j])
				ok
				_nLenCell_ = stzlen(_cellValue_)
				if _nLenCell_ > _nMaxWidth_
					_nMaxWidth_ = _nLenCell_
				ok
			next

			_nLenTemp_ = len("Product X Total")
			if i = 1
				if _nMaxWidth_ < _nLenTemp_
					_nMaxWidth_ = _nLenTemp_
				ok
			ok

			_nLenTemp_ = len("GRAND-TOTAL")
			if i = 1 and _bGrandTotal_
				if _nMaxWidth_ < _nLenTemp_
					_nMaxWidth_ = _nLenTemp_
				ok
			ok

			_aColWidths_ + (_nMaxWidth_ + 2)
		next

		return _aColWidths_

	# Submethod to adjust column widths and names for row numbers
	def adjustForRowNumbers(_bRowNumber_, _aColWidths_, _acColNames_)

		if _bRowNumber_
			_nRowNumWidth_ = len("" + This.NumberOfRows()) + 2
			_aColWidths_ = ring_insert(_aColWidths_, 1, _nRowNumWidth_)
			_acColNames_ = ring_insert(_acColNames_, 1, "#")
		ok

	# Submethod to build the output string
	def buildOutput(_acColNames_, _aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_)
		_cOutput_ = ""
		_nCols_ = len(_acColNames_)

		# Top border
		_cLine_ = @aBorder[:TopLeft]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:TeeDown]
			else
				_cLine_ += @aBorder[:TopRight]
			ok
		next
		_cOutput_ += _cLine_ + NL

		# Header row
		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += CenterText(@Capitalise(_acColNames_[i]), _aColWidths_[i]) + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + NL

		# Separator
		_cLine_ = @aBorder[:TeeRight]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:Cross]
			else
				_cLine_ += @aBorder[:TeeLeft]
			ok
		next
		_cOutput_ += _cLine_ + NL

		# Data rows with aggregation
		_cOutput_ += buildDataRows(_aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_, _nCols_)

		# Grand total
		if _bGrandTotal_
			_cOutput_ += buildGrandTotal(_aColWidths_, _bRowNumber_, _nCols_)
		ok

		# Bottom border
		_cLine_ = @aBorder[:BottomLeft]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:TeeUp]
			else
				_cLine_ += @aBorder[:BottomRight]
			ok
		next
		_cOutput_ += _cLine_

		return _cOutput_

	# Submethod to build data rows with subtotals
	def buildDataRows(_aContent_, _aColWidths_, _bRowNumber_, _bSubTotal_, _bGrandTotal_, _nCols_)
		_cOutput_ = ""
		_nRows_ = This.NumberOfRows()
		_nGroupCol_ = @if(_bRowNumber_, 2, 1)
		_cCurrentGroup_ = ""
		_aGroups_ = []
		_aGroupTotals_ = []
		_aGrandTotals_ = []

		for i = 1 to _nCols_
			_aGrandTotals_ + 0
		next

		# First pass: gather groups and calculate totals
		for r = 1 to _nRows_

			_cGroup_ = "" + _aContent_[_nGroupCol_][2][r]

			if NOT StzFindFirst(_aGroups_, _cGroup_) > 0
				_aGroups_ + _cGroup_
				_aGroupTotals_[_cGroup_] = []
				for i = 1 to _nCols_
					_aGroupTotals_[_cGroup_] + 0
				next
			ok

			for i = 1 to _nCols_
				if _bRowNumber_ and i = 1
					loop
				ok
				_nDataCol_ = @if(_bRowNumber_, i - 1, i)
				if _nDataCol_ > 0 and _nDataCol_ <= len(_aContent_)
					_cellValue_ = _aContent_[_nDataCol_][2][r]
					if not (isNumber(_cellValue_) or isString(_cellValue_))
						_cellValue_ = @@(_cellValue_)
					ok
					if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
						_aGroupTotals_[_cGroup_][i] += (0 + _cellValue_)
						_aGrandTotals_[i] += (0 + _cellValue_)
					ok
				ok
			next
		next

		# Second pass: display data with totals
		_cCurrentGroup_ = ""
		for r = 1 to _nRows_
			_cGroup_ = "" + _aContent_[_nGroupCol_][2][r]

			if _bSubTotal_ and _cCurrentGroup_ != "" and _cGroup_ != _cCurrentGroup_
				_cOutput_ += buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
			ok

			_cCurrentGroup_ = _cGroup_
			_cLine_ = @aBorder[:Vertical]
			for i = 1 to _nCols_
				if _bRowNumber_ and i = 1
					_cLine_ += " " + PadLeft("" + r, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				else
					_nDataCol_ = @if(_bRowNumber_, i - 1, i)
					if _nDataCol_ > 0 and _nDataCol_ <= len(_aContent_)
						_cellValue_ = _aContent_[_nDataCol_][2][r]
						if NOT (isNumber(_cellValue_) or isString(_cellValue_))
							_cellValue_ = @@(_cellValue_)
						ok
						if isNumber(_cellValue_) or (isString(_cellValue_) and _cellValue_ != "" and @IsNumberInString(_cellValue_))
							_cLine_ += " " + PadLeft(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
						else
							_cLine_ += " " + PadRight(_cellValue_, _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
						ok
					else
						_cLine_ += " " + PadRight("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
					ok
				ok
			next
			_cOutput_ += _cLine_ + NL

			if _bSubTotal_ and r = _nRows_
				_cOutput_ += buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
			ok
		next

		return _cOutput_

	# Submethod to build subtotal row
	def buildSubTotalRow(_aColWidths_, _nCols_, _bRowNumber_, _nGroupCol_, _cCurrentGroup_, _aGroupTotals_)
		_cOutput_ = ""
		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += " " + RepeatChar("-", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + NL

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			if _bRowNumber_ and i = 1
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			but i = _nGroupCol_
				_cLine_ += " " + PadLeft(" Sub-total", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			but (i = _nGroupCol_ + 1 and not _bRowNumber_) or (i = _nGroupCol_ + 1 and _bRowNumber_)
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			else
				if isNumber(_aGroupTotals_[_cCurrentGroup_][i]) and _aGroupTotals_[_cCurrentGroup_][i] != 0
					_cLine_ += " " + PadLeft("" + _aGroupTotals_[_cCurrentGroup_][i], _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				else
					_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				ok
			ok
		next
		_cOutput_ += _cLine_ + NL

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			_cLine_ += " " + RepeatChar(" ", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
		next
		_cOutput_ += _cLine_ + NL

		return _cOutput_

	# Submethod to build grand total
	def buildGrandTotal(_aColWidths_, _bRowNumber_, _nCols_)
		_cOutput_ = ""
		_cLine_ = @aBorder[:TeeRight]
		for i = 1 to _nCols_
			_cLine_ += StrFill(_aColWidths_[i], @aBorder[:Horizontal])
			if i < _nCols_
				_cLine_ += @aBorder[:Cross]
			else
				_cLine_ += @aBorder[:TeeLeft]
			ok
		next
		_cOutput_ += _cLine_ + NL

		_cLine_ = @aBorder[:Vertical]
		for i = 1 to _nCols_
			if _bRowNumber_ and i = 1
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			but i = @if(_bRowNumber_, 2, 1)
				_cLine_ += PadLeft("GRAND-TOTAL ", _aColWidths_[i]) + @aBorder[:Vertical]
			but i = @if(_bRowNumber_, 3, 2)
				_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
			else
				if isNumber(_aGrandTotals_[i]) and _aGrandTotals_[i] != 0
					_cLine_ += " " + PadLeft("" + _aGrandTotals_[i], _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				else
					_cLine_ += " " + PadLeft("", _aColWidths_[i] - 2) + " " + @aBorder[:Vertical]
				ok
			ok
		next
		_cOutput_ += _cLine_ + NL

		return _cOutput_

	#---------------------------------#
	#  TRANSPOSINT THE TABLE CONTENT  #
	#---------------------------------#


	def Transpose()

	    # Get dimensions directly from @aContent
	    _nCols_ = len(@aContent)
	    if _nCols_ = 0
	        return
	    ok
	    _nRows_ = len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = FALSE
	    @aOriginalColNames = []
	    for i = 1 to _nCols_
	        @aOriginalColNames + @aContent[i][1]
	    next

	    # Generate new column names
	    _acNewColNames_ = []
	    for i = 1 to _nRows_
	        _acNewColNames_ + ("COL" + i)
	    next

	    # Build new content directly in target format
	    _aNewContent_ = []
	    for i = 1 to _nRows_
	        _aNewRow_ = []
	        for j = 1 to _nCols_
	            _aNewRow_ + @aContent[j][2][i]
	        next
	        _aNewContent_ + [_acNewColNames_[i], _aNewRow_]
	    next

	    This.UpdateWith(_aNewContent_)

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
	    _nCols_ = len(@aContent)
	    if _nCols_ = 0
	        return
	    ok
	    _nRows_ = len(@aContent[1][2])

	    # Set internal flag to track header preservation
	    @bTransposedWithHeaders = True
	    @aOriginalColNames = []
	    for i = 1 to _nCols_
	        @aOriginalColNames + @aContent[i][1]
	    next

	    # Generate new column names (all follow COL pattern)
	    _acNewColNames_ = []
	    for i = 1 to _nRows_
	        _acNewColNames_ + ("COL" + i)
	    next

	    # Build new content
	    _aNewContent_ = []

	    # First column contains original headers
	    _aFirstColumn_ = []
	    for i = 1 to _nCols_
	        _aFirstColumn_ + @aContent[i][1]
	    next
	    _aNewContent_ + [_acNewColNames_[1], _aFirstColumn_]

	    # Remaining columns contain transposed data
	    for i = 1 to _nRows_
	        _aNewRow_ = []
	        for j = 1 to _nCols_
	            _aNewRow_ + @aContent[j][2][i]
	        next
	        _aNewContent_ + [("COL" + (i+1)), _aNewRow_]
	    next

	    This.UpdateWith(_aNewContent_)

	    # Reset calculated data
	    @anCalculatedCols = []
	    @anCalculatedRows = []

		def TransposeWithColNames()
			This.TansposeXT()

	def TransposeBack()
	    # Only works if table was transposed with headers
	    if len(@aOriginalColNames) = 0
	        raise("Cannot transpose back: no header information found")
	    ok

	    # Get data columns (skip first column which contains headers)
	    _aDataColumns_ = []
	    _nContentLen_ = len(@aContent)
	    for i = 2 to _nContentLen_
	        _aDataColumns_ + @aContent[i][2]
	    next

	    # Transpose back
	    _nOriginalCols_ = len(@aOriginalColNames)
	    _nOriginalRows_ = len(_aDataColumns_)

	    _aNewContent_ = []
	    for i = 1 to _nOriginalCols_
	        _aNewRow_ = []
	        for j = 1 to _nOriginalRows_
	            _aNewRow_ + _aDataColumns_[j][i]
	        next
	        _aNewContent_ + [@aOriginalColNames[i], _aNewRow_]
	    next

	    This.UpdateWith(_aNewContent_)

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

	def PadRight(_cText_, nWidth)
		if NOT (isNumber(_cText_) or isString(_cText_))
			_cText_ = @@(_cText_)
		ok

		# Pad text to the right
		_cStr_ = "" + _cText_
		_nPad_ = nWidth - stzlen(_cStr_)
		if _nPad_ > 0
			return _cStr_ + RepeatChar(" ", _nPad_)
		else
			return _cStr_
		ok

	def PadLeft(_cText_, nWidth)
		if NOT (isNumber(_cText_) or isString(_cText_))
			_text_ = @@(_cText_)
		ok

		# Pad text to the left
		_cStr_ = "" + _cText_
		_nPad_ = nWidth - stzlen(_cStr_)
		if _nPad_ > 0
			return RepeatChar(" ", _nPad_) + _cStr_
		else
			return _cStr_
		ok

	def CenterText(_cText_, nWidth)
		if NOT (isNumber(_cText_) or isString(_cText_))
			_cText_ = Q(_cText_).Stringified()
		ok

		# Center text within width
		_cStr_ = "" + _cText_
		_nPadTotal_ = nWidth - stzlen(_cStr_)
		if _nPadTotal_ <= 0
			return _cStr_
		ok

		_nPadLeft_ = floor(_nPadTotal_ / 2)
		_nPadRight_ = _nPadTotal_ - _nPadLeft_

		return RepeatChar(" ", _nPadLeft_) + _cStr_ + RepeatChar(" ", _nPadRight_)

	def StrFill(nCount, cChar)

		# Create string of repeated character
		_cResult_ = ""
		for i = 1 to nCount
			_cResult_ += cChar
		next
		return _cResult_

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

		_aData_ = JsonToList(pcJsonStr)
		if Not ( @IsHashList(_aData_) and @IsTable(_aData_) )
			StzRaise("Can't proceed! The Json structure does not correspond to a stzTable structure.")
		ok

		This.UpdateWith(_aData_)

	#---

	def ToHtml()
		return @Simplify(This.ToHtmlXT())

		def ToHtmlTable()
			return This.ToHtml()

	def ToHtmlXT()
	    _aContent_ = @aContent
	    if len(_aContent_) = 0
	        return '<table class="data"><thead><tr></tr></thead><tbody></tbody></table>'
	    ok

	    # Ensure all columns have exactly the same number of values
	    # This is critical for the buggy parser
	    _nLen_ = len(_aContent_)
	    _nRows_ = 0
	    for i = 1 to _nLen_
	        if len(_aContent_[i][2]) > _nRows_
	            _nRows_ = len(_aContent_[i][2])
	        ok
	    next

	    # Pad shorter columns with empty strings to match longest column
	    for i = 1 to _nLen_
	        while len(_aContent_[i][2]) < _nRows_
	            _aContent_[i][2] + ""
	        end
	    next

	    _cHtml_ = '<table class="data" id="products">' + nl
	    _cHtml_ += '<thead>' + nl
	    _cHtml_ += nl
	    _cHtml_ += '<tr>' + nl

	    # Generate header row - ensure format matches parser expectations
	    for i = 1 to _nLen_
	        _cHtml_ += '            ' + '<th scope="col">' + data[i][1] + '</th>' + nl
	    next

	    _cHtml_ += '</tr>' + nl
	    _cHtml_ += nl
	    _cHtml_ += '</thead>' + nl
	    _cHtml_ += nl
	    _cHtml_ += '<tbody>' + nl
	    _cHtml_ += nl

	    # Generate body rows - use exact format the parser expects
	    for nRowIndex = 1 to _nRows_
	        _cHtml_ += '<tr class="row">' + nl

	        # For each column, get the value at this row index
	        for nColIndex = 1 to _nLen_
	            _cValue_ = _aContent_[nColIndex][2][nRowIndex]
	            _cHtml_ += '        ' + '<td>' + _cValue_ + '</td>' + nl
	        next

	        _cHtml_ += nl
	        _cHtml_ += '</tr>' + nl
	        _cHtml_ += nl
	    next

	    _cHtml_ += '</tbody>' + nl
	    _cHtml_ += '</table>' + nl
			return _cHtml_

		def ToHtmlTableXT()
			return This.ToHtmlXT()


	def FromHtml(pcHtmlTable)

		if NOT isString(pcHtmlTable)
			StzRaise("Incorrect param type! pcHtmlTable must be a string.")
		ok

		This.UpdateWith(StzStringQ(pcHtmlTable).HtmlToTable())
