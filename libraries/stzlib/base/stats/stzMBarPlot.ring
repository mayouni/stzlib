
class stzMultiBarChart from stzMBarPlot
class stzMBarChart from stzMBarPlot

class stzMultiBarPlot from stzMBarPlot
class stzMBarPlot from stzBarPlot

	# Multi-series data properties
	@aSeriesData = []		# [ [:SeriesName = "Sales", :Values = [25,35,30,40], :Char = char(226) + char(150) + char(136)], ... ]
	@acCategories = []		# ["Q1", "Q2", "Q3", "Q4"]
	@acSeriesNames = []		# ["Sales", "Costs", "Profit"]
	@acSeriesChars = []		# [char(226) + char(150) + char(136), char(226) + char(150) + char(146), char(226) + char(150) + char(147)]
	@nSeries = 0
	@nCategories = 0

	# Multi-series display options
	@bShowLegend = True
	@cLegendLayout = :Horizontal	# :Horizontal or :Vertical
	@nSeriesSpace = 1		# Space between bars in same category
	@nCategorySpace = 2		# Space between categories

	# Default series characters
	@acDefaultSeriesChars = [char(226) + char(150) + char(136), char(226) + char(150) + char(146), char(226) + char(150) + char(147), char(226) + char(150) + char(145), char(226) + char(150) + char(140), char(226) + char(150) + char(144), char(226) + char(150) + char(128), char(226) + char(150) + char(132)]

	def init(paMultiSeriesData)
		if not isList(paMultiSeriesData)
			StzRaise("Multi-series dataset must be a list")
		ok

		_processMultiSeriesData(paMultiSeriesData)
		_calculateMultiSeriesMetrics()

	# --- Multi-Series Data Processing ---

	def _processMultiSeriesData(paData)
		if not IsHashList(paData)
			StzRaise("Multi-series data must be a hashlist")
		ok

		@aSeriesData = []
		@acCategories = []
		@acSeriesNames = []
		@nSeries = 0

		_oData_ = new stzHashList(paData)
		@acSeriesNames = _oData_.Keys()
		@nSeries = len(@acSeriesNames)

		# Process each series
		for i = 1 to @nSeries
			_cSeriesName_ = @acSeriesNames[i]
			_aSeriesValues_ = _oData_.Value(i)

			if not IsHashList(_aSeriesValues_)
				StzRaise("Each series must be a hashlist of category:value pairs")
			ok

			_oSeriesData_ = new stzHashList(_aSeriesValues_)
			_aCategories_ = _oSeriesData_.Keys()
			_aValues_ = _oSeriesData_.Values()

			# Validate all values are positive numbers
			_nValues1Len_ = len(_aValues_)
			for _iLoopValues1_ = 1 to _nValues1Len_
				_nVal_ = _aValues_[_iLoopValues1_]
				if not isNumber(_nVal_) or _nVal_ < 0
					StzRaise("All values must be positive numbers")
				ok
			next

			# Set categories from first series
			if i = 1
				@acCategories = _aCategories_
				@nCategories = len(@acCategories)
			ok

			# Assign default character
			_cChar_ = @acDefaultSeriesChars[((i-1) % len(@acDefaultSeriesChars)) + 1]

			@aSeriesData + [
				:SeriesName = _cSeriesName_,
				:Categories = _aCategories_,
				:Values = _aValues_,
				:Char = _cChar_
			]
		next

	def _calculateMultiSeriesMetrics()
		# Find global max value across all series
		@nMaxValue = 0
		@nSum = 0
		_nTotalValues_ = 0

		_nSeriesData1Len_ = len(@aSeriesData)
		for _iLoopSeriesData1_ = 1 to _nSeriesData1Len_
			_aSeriesInfo_ = @aSeriesData[_iLoopSeriesData1_]
			_aValues_ = _aSeriesInfo_[:Values]
			_nSeriesMax_ = max(_aValues_)
			_nSeriesSum_ = @sum(_aValues_)
			
			@nMaxValue = max([@nMaxValue, _nSeriesMax_])
			@nSum += _nSeriesSum_
			_nTotalValues_ += len(_aValues_)
		next

		@nAverage = iff(_nTotalValues_ > 0, @nSum / _nTotalValues_, 0)

	# --- Configuration Methods ---

	def SetSeriesChars(acChars)
		if not isList(acChars)
			return
		ok

		for i = 1 to min([len(acChars), @nSeries])
			if IsChar(acChars[i])
				@aSeriesData[i][:Char] = acChars[i]
			ok
		next

		def SetBarsChars(acChars)
			This.SetSeriesChars(acChars)


	def SetSeriesSpace(n)
		@nSeriesSpace = max([0, n])

		def SetBarInterSpace(n)
			This.SetSeriesSpace(n)

		def SetBarSpace(n)
			This.SetSeriesSpace(n)

		def SetInterBarSpace(n)
			This.SetSeriesSpace(n)

	def SetCategorySpace(n)
		@nCategorySpace = max([1, n])

		def SetCategoryInterSpace(n)
			This.SetCategorySpace(n)

	def SetLegend(bShow)
		@bShowLegend = bShow

		def AddLegend()
			@bShowLegend = True

	def SetLegendLayout(cLayout)
		if NOT StzFindFirst(cLayout, [:Horizontal, :Vertical, "horizontal", "vertical", "h", "v"])
			stzRaise("Incorrect legend layout value! Must be 'horizontal' or 'vertical'.")
		ok

		if cLayout = "horizontal" or cLayout = "h"
				@cLegendLayout = :Horizontal
		else
				@cLegendLayout = :Vertical
		ok


	def SetAverage(bShow)
		StzRaise("Unsupported feature in the current version.")

		def SetAverageLine(bShow)
			This.SetAverage(bShow)

		def AddAverage()
			This.SetAverage(TRUE)

		def AddAverageLine()
			This.SetAverage(TRUE)

	# --- Multi-Series Layout Calculation ---

	def _calculateMultiSeriesLayout()
		if @nSeries = 0 or @nCategories = 0
			return []
		ok

		# Calculate category group width
		_nBarsPerCategory_ = @nSeries
		_nCategoryGroupWidth_ = (_nBarsPerCategory_ * @nBarWidth) + ((_nBarsPerCategory_ - 1) * @nSeriesSpace)
		
		# Calculate total bars area width
		_nTotalBarsWidth_ = (@nCategories * _nCategoryGroupWidth_) + ((@nCategories - 1) * @nCategorySpace)
		
		# Calculate element widths for labels and values
		_aElementWidths_ = []
		for i = 1 to @nCategories
			_nMaxWidth_ = _nCategoryGroupWidth_
			
			# Check category label width
			if @bShowLabels and @bShowAxisLabels and i <= len(@acCategories)
				_nLabelWidth_ = min([len(@acCategories[i]), @nMaxLabelWidth])
				_nMaxWidth_ = max([_nMaxWidth_, _nLabelWidth_])
			ok
			
			# Check values width for this category
			if @bShowValues or @bShowPercent
				for j = 1 to @nSeries
					if i <= len(@aSeriesData[j][:Values])
						_nValue_ = @aSeriesData[j][:Values][i]
						
						if @bShowValues
							_nValueWidth_ = len("" + _nValue_)
							_nMaxWidth_ = max([_nMaxWidth_, _nValueWidth_])
						but @bShowPercent and @nSum > 0
							_nPercent_ = (_nValue_ * 100) / @nSum
							_nValueWidth_ = len('' + RoundN(_nPercent_, 1) + "%")
							_nMaxWidth_ = max([_nMaxWidth_, _nValueWidth_])
						ok
					ok
				next
			ok
			
			_aElementWidths_ + _nMaxWidth_
		next
		
		# Calculate total width
		_nBaseWidth_ = @sum(_aElementWidths_) + ((@nCategories - 1) * @nCategorySpace)
		_nTotalWidth_ = _nBaseWidth_ + iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding, 0) + 2
		
		# Add space for average value if shown
		if @bShowAverage
			_nAvgValueWidth_ = len("" + RoundN(@nAverage, 1))
			_nTotalWidth_ += 2 + _nAvgValueWidth_
		ok
		
		# Calculate legend dimensions
		_nLegendHeight_ = 0
		_nLegendWidth_ = 0
		if @bShowLegend
			if @cLegendLayout = :Horizontal
				_nLegendHeight_ = 1
				# Calculate total legend width: char(226) + char(150) + char(136) + char(226) + char(150) + char(136) + " SeriesName   " + char(226) + char(150) + char(146) + char(226) + char(150) + char(146) + " SeriesName   ..."
				_nLegendWidth_ = 0
				for i = 1 to @nSeries
					_nLegendWidth_ += 3 + len(@acSeriesNames[i])  # char(226) + char(150) + char(136) + char(226) + char(150) + char(136) + " SeriesName"
					if i < @nSeries
						_nLegendWidth_ += 3  # "   " spacing
					ok
				next
			else  # Vertical
				_nLegendHeight_ = @nSeries
				_nLegendWidth_ = 0
				_nAcSeriesNames1Len_ = len(@acSeriesNames)
				for _iLoopAcSeriesNames1_ = 1 to _nAcSeriesNames1Len_
					_cName_ = @acSeriesNames[_iLoopAcSeriesNames1_]
					_nLegendWidth_ = max([_nLegendWidth_, 3 + len(_cName_)])
				next
			ok
		ok
		
		# Calculate layout rows
		_nCurrentRow_ = 1
		
		# V-axis arrow row
		if @bShowVAxis
			_nCurrentRow_ = 2
		ok
		
		# Values row
		_nValuesRow_ = 0
		if @bShowValues or @bShowPercent
			_nValuesRow_ = _nCurrentRow_
			_nCurrentRow_ += 1
		ok
		
		# Bars area
		_nBarsStartRow_ = _nCurrentRow_
		_nBarsEndRow_ = _nCurrentRow_ + @nHeight - 1
		_nCurrentRow_ = _nBarsEndRow_ + 1
		
		# H-axis row
		_nHAxisRow_ = 0
		if @bShowHAxis
			_nHAxisRow_ = _nCurrentRow_
			_nCurrentRow_ += 1
		ok
		
		# Labels row
		_nLabelsRow_ = 0
		if @bShowLabels and @bShowAxisLabels
			_nLabelsRow_ = _nCurrentRow_
			_nCurrentRow_ += 1
		ok
		
		# Legend row(s)
		_nLegendStartRow_ = 0
		if @bShowLegend
			_nLegendStartRow_ = _nCurrentRow_ + 1  # Add spacing line
			_nCurrentRow_ = _nLegendStartRow_ + _nLegendHeight_
		ok
		
		# Total dimensions
		_nTotalHeight_ = _nCurrentRow_ - 1
		_nTotalWidth_ = max([_nTotalWidth_, _nLegendWidth_ + 2])
		
		# Column positions
		_nVAxisCol_ = 1
		_nBarsStart_ = iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding + 1, 1)
		
		return [
			:total_width = _nTotalWidth_,
			:total_height = _nTotalHeight_,
			:bars_start = _nBarsStart_,
			:bars_start_row = _nBarsStartRow_,
			:bars_end_row = _nBarsEndRow_,
			:h_axis_row = _nHAxisRow_,
			:values_row = _nValuesRow_,
			:labels_row = _nLabelsRow_,
			:legend_start_row = _nLegendStartRow_,
			:legend_height = _nLegendHeight_,
			:v_axis_col = _nVAxisCol_,
			:v_axis_start = iff(@bShowVAxis, 2, 1),
			:bars_height = @nHeight,
			:element_widths = _aElementWidths_,
			:category_group_width = _nCategoryGroupWidth_
		]

	# --- Multi-Series Drawing Methods ---

	def _drawMultiSeriesBars(_oLayout_)
		if @nSeries = 0 or @nCategories = 0
			return
		ok

		_nBarsStartRow_ = _oLayout_[:bars_start_row]
		_nBarsEndRow_ = _oLayout_[:bars_end_row]
		_nBarsHeight_ = _oLayout_[:bars_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		_nCategoryGroupWidth_ = _oLayout_[:category_group_width]
		
		_nCurrentH_ = _oLayout_[:bars_start]
		
		# Draw each category group
		for nCat = 1 to @nCategories
			_nElementWidth_ = _aElementWidths_[nCat]
			_nGroupStartH_ = _nCurrentH_ + floor((_nElementWidth_ - _nCategoryGroupWidth_) / 2)
			_nBarH_ = _nGroupStartH_
			
			# Draw each series bar in this category
			for nSer = 1 to @nSeries
				_aSeriesInfo_ = @aSeriesData[nSer]
				_aValues_ = _aSeriesInfo_[:Values]
				_cBarChar_ = _aSeriesInfo_[:Char]
				
				if nCat <= len(_aValues_)
					_nValue_ = _aValues_[nCat]
					
					# Calculate bar height
					_nBarHeight_ = 0
					if @nMaxValue > 0 and _nValue_ > 0
						_nBarHeight_ = max([1, ceil(_nBarsHeight_ * _nValue_ / @nMaxValue)])
					ok
					
					# Draw bar from bottom up
					for j = 1 to _nBarHeight_
						for k = 1 to @nBarWidth
							_nCol_ = _nBarH_ + k - 1
							_nRow_ = _nBarsEndRow_ - j + 1
							_setChar(_nRow_, _nCol_, _cBarChar_)
						next
					next
				ok
				
				# Move to next series position
				if nSer < @nSeries
					_nBarH_ += @nBarWidth + @nSeriesSpace
				ok
			next
			
			# Move to next category
			if nCat < @nCategories
				_nCurrentH_ += _nElementWidth_ + @nCategorySpace
			ok
		next

	def _drawMultiSeriesValues(_oLayout_)
		if not (@bShowValues or @bShowPercent) or _oLayout_[:values_row] = 0
			return
		ok

		_nBarsStartRow_ = _oLayout_[:bars_start_row]
		_nBarsHeight_ = _oLayout_[:bars_height]
		_aElementWidths_ = _oLayout_[:element_widths]
		_nCategoryGroupWidth_ = _oLayout_[:category_group_width]
		
		_nCurrentH_ = _oLayout_[:bars_start]
		
		# Draw values for each category group
		for nCat = 1 to @nCategories
			_nElementWidth_ = _aElementWidths_[nCat]
			_nGroupStartH_ = _nCurrentH_ + floor((_nElementWidth_ - _nCategoryGroupWidth_) / 2)
			_nBarH_ = _nGroupStartH_
			
			# Draw values for each series in this category
			for nSer = 1 to @nSeries
				_aSeriesInfo_ = @aSeriesData[nSer]
				_aValues_ = _aSeriesInfo_[:Values]
				
				if nCat <= len(_aValues_)
					_nValue_ = _aValues_[nCat]
					
					# Format value
					_cValue_ = ""
					if @bShowValues
						if IsInteger(_nValue_)

							_cValue_ = "" + _nValue_
						else
							_cValue_ = "" + RoundN(_nValue_, 1)
						ok

					but @bShowPercent and @nSum > 0
						_nPercent_ = RoundN((_nValue_ * 100) / @nSum, 1)
						_cValue_ = '' + _nPercent_ + "%"
						_cPercent_ = RoundN((_nValue_ * 100) / @nSum, 1)
						_cPercent_ = StzReplace(_cPercent_, ".0", "")
						_cValue_ = _cPercent_ + "%"
					ok
					
					# Calculate bar height to position value above it
					_nBarHeight_ = 0
					if @nMaxValue > 0 and _nValue_ > 0
						_nBarHeight_ = max([1, ceil(_nBarsHeight_ * _nValue_ / @nMaxValue)])
					ok
					
					# Position value above bar
					_nValueRow_ = _nBarsStartRow_ + _nBarsHeight_ - _nBarHeight_ - 1
					if _nValueRow_ < 1
						_nValueRow_ = 1
					ok
					
					# Center value over bar
					_nValueStart_ = _nBarH_ + floor((@nBarWidth - len(_cValue_)) / 2)
					
					# Draw value
					_nLen_ = len(_cValue_)
					for j = 1 to _nLen_
						if _nValueStart_ + j - 1 <= _oLayout_[:total_width]
							_setChar(_nValueRow_, _nValueStart_ + j - 1, _cValue_[j])
						ok
					next
				ok
				
				# Move to next series position
				if nSer < @nSeries
					_nBarH_ += @nBarWidth + @nSeriesSpace
				ok
			next
			
			# Move to next category
			if nCat < @nCategories
				_nCurrentH_ += _nElementWidth_ + @nCategorySpace
			ok
		next


	def _drawMultiSeriesLabels(_oLayout_)
		if not @bShowLabels or not @bShowAxisLabels or _oLayout_[:labels_row] = 0
			return
		ok

		_nLabelsRow_ = _oLayout_[:labels_row]
		_aElementWidths_ = _oLayout_[:element_widths]
		_nCurrentH_ = _oLayout_[:bars_start]
		
		# Draw category labels
		for i = 1 to @nCategories
			if i <= len(@acCategories)
				_cLabel_ = Capitalise(@acCategories[i])
				_nElementWidth_ = _aElementWidths_[i]
				
				# Truncate if needed
				if len(_cLabel_) > @nMaxLabelWidth
					_cLabel_ = Left(_cLabel_, @nMaxLabelWidth - 2) + ".."
				ok
				
				# Center label
				_nLabelStart_ = _nCurrentH_ + floor((_nElementWidth_ - len(_cLabel_)) / 2)
				
				# Draw label
				_nLen_ = len(_cLabel_)
				for j = 1 to _nLen_
					_setChar(_nLabelsRow_, _nLabelStart_ + j - 1, _cLabel_[j])
				next
			ok
			
			# Move to next position
			if i < @nCategories
				_nCurrentH_ += _aElementWidths_[i] + @nCategorySpace
			ok
		next

	def _drawLegend(_oLayout_)
		if not @bShowLegend or _oLayout_[:legend_start_row] = 0
			return
		ok

		_nStartRow_ = _oLayout_[:legend_start_row]
		

		if @cLegendLayout = :Horizontal
			# Draw horizontal legend: char(226) + char(150) + char(136) + char(226) + char(150) + char(136) + " Series1   " + char(226) + char(150) + char(146) + char(226) + char(150) + char(146) + " Series2   ..."
			_nCol_ = 1
			for i = 1 to @nSeries
				_aSeriesInfo_ = @aSeriesData[i]
				_cChar_ = _aSeriesInfo_[:Char]
				_cName_ = Capitalise(_aSeriesInfo_[:SeriesName])
				
				# Draw series character (doubled)
				_setChar(_nStartRow_, _nCol_, _cChar_)
				_setChar(_nStartRow_, _nCol_ + 1, _cChar_)
				
				# Draw space and name
				_setChar(_nStartRow_, _nCol_ + 2, " ")
				_nLen_ = len(_cName_)
				for j = 1 to _nLen_
					_setChar(_nStartRow_, _nCol_ + 2 + j, _cName_[j])
				next
				
				# Move to next series position
				if i < @nSeries
					_nCol_ += 3 + _nLen_ + 3  # chars + space + name + spacing
				ok
			next
		else
			# Draw vertical legend
			for i = 1 to @nSeries
				_aSeriesInfo_ = @aSeriesData[i]
				_cChar_ = _aSeriesInfo_[:Char]
				_cName_ = Capitalise(_aSeriesInfo_[:SeriesName])
				_nRow_ = _nStartRow_ + i - 1
				
				# Draw series character (doubled)
				_setChar(_nRow_, 1, _cChar_)
				_setChar(_nRow_, 2, _cChar_)
				
				# Draw space and name
				_setChar(_nRow_, 3, " ")
				_nLen_ = len(_cName_)
				for j = 1 to _nLen_
					_setChar(_nRow_, 3 + j, _cName_[j])
				next
			next
		ok

	# --- Override Main Methods ---

	def ToString()
		if @nSeries = 0
			return ""
		ok

		_oLayout_ = _calculateMultiSeriesLayout()
		_initCanvas(_oLayout_[:total_width], _oLayout_[:total_height])

		_drawVAxis(_oLayout_)
		_drawHAxis(_oLayout_)
		_drawMultiSeriesBars(_oLayout_)
		_drawMultiSeriesValues(_oLayout_)
		_drawMultiSeriesLabels(_oLayout_)
		_drawLegend(_oLayout_)

		return _canvasToString()

	# --- Multi-Series Accessors ---

	def SeriesNames()
		return @acSeriesNames

	def Categories()
		return @acCategories

	def SeriesData()
		return @aSeriesData

	def SeriesCount()
		return @nSeries

	def CategoryCount()
		return @nCategories
