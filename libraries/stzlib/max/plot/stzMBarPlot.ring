
class stzMultiBarPlot from stzMBarPlot
class stzMBarPlot from stzBarPlot

	# Multi-series data properties
	@aSeriesData = []		# [ [:SeriesName = "Sales", :Values = [25,35,30,40], :Char = "█"], ... ]
	@acCategories = []		# ["Q1", "Q2", "Q3", "Q4"]
	@acSeriesNames = []		# ["Sales", "Costs", "Profit"]
	@acSeriesChars = []		# ["█", "▒", "▓"]
	@nSeries = 0
	@nCategories = 0

	# Multi-series display options
	@bShowLegend = True
	@cLegendLayout = :Horizontal	# :Horizontal or :Vertical
	@nSeriesSpace = 1		# Space between bars in same category
	@nCategorySpace = 2		# Space between categories

	# Default series characters
	@acDefaultSeriesChars = ["█", "▒", "▓", "░", "▌", "▐", "▀", "▄"]

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

		oData = new stzHashList(paData)
		@acSeriesNames = oData.Keys()
		@nSeries = len(@acSeriesNames)

		# Process each series
		for i = 1 to @nSeries
			cSeriesName = @acSeriesNames[i]
			aSeriesValues = oData.Value(i)

			if not IsHashList(aSeriesValues)
				StzRaise("Each series must be a hashlist of category:value pairs")
			ok

			oSeriesData = new stzHashList(aSeriesValues)
			aCategories = oSeriesData.Keys()
			aValues = oSeriesData.Values()

			# Validate all values are positive numbers
			for nVal in aValues
				if not isNumber(nVal) or nVal < 0
					StzRaise("All values must be positive numbers")
				ok
			next

			# Set categories from first series
			if i = 1
				@acCategories = aCategories
				@nCategories = len(@acCategories)
			ok

			# Assign default character
			cChar = @acDefaultSeriesChars[((i-1) % len(@acDefaultSeriesChars)) + 1]

			@aSeriesData + [
				:SeriesName = cSeriesName,
				:Categories = aCategories,
				:Values = aValues,
				:Char = cChar
			]
		next

	def _calculateMultiSeriesMetrics()
		# Find global max value across all series
		@nMaxValue = 0
		@nSum = 0
		nTotalValues = 0

		for aSeriesInfo in @aSeriesData
			aValues = aSeriesInfo[:Values]
			nSeriesMax = max(aValues)
			nSeriesSum = @sum(aValues)
			
			@nMaxValue = max([@nMaxValue, nSeriesMax])
			@nSum += nSeriesSum
			nTotalValues += len(aValues)
		next

		@nAverage = iff(nTotalValues > 0, @nSum / nTotalValues, 0)

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
		if NOT ring_find([:Horizontal, :Vertical, "horizontal", "vertical", "h", "v"], cLayout)
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
		nBarsPerCategory = @nSeries
		nCategoryGroupWidth = (nBarsPerCategory * @nBarWidth) + ((nBarsPerCategory - 1) * @nSeriesSpace)
		
		# Calculate total bars area width
		nTotalBarsWidth = (@nCategories * nCategoryGroupWidth) + ((@nCategories - 1) * @nCategorySpace)
		
		# Calculate element widths for labels and values
		aElementWidths = []
		for i = 1 to @nCategories
			nMaxWidth = nCategoryGroupWidth
			
			# Check category label width
			if @bShowLabels and @bShowAxisLabels and i <= len(@acCategories)
				nLabelWidth = min([len(@acCategories[i]), @nMaxLabelWidth])
				nMaxWidth = max([nMaxWidth, nLabelWidth])
			ok
			
			# Check values width for this category
			if @bShowValues or @bShowPercent
				for j = 1 to @nSeries
					if i <= len(@aSeriesData[j][:Values])
						nValue = @aSeriesData[j][:Values][i]
						
						if @bShowValues
							nValueWidth = len("" + nValue)
							nMaxWidth = max([nMaxWidth, nValueWidth])
						but @bShowPercent and @nSum > 0
							nPercent = (nValue * 100) / @nSum
							nValueWidth = len('' + RoundN(nPercent, 1) + "%")
							nMaxWidth = max([nMaxWidth, nValueWidth])
						ok
					ok
				next
			ok
			
			aElementWidths + nMaxWidth
		next
		
		# Calculate total width
		nBaseWidth = @sum(aElementWidths) + ((@nCategories - 1) * @nCategorySpace)
		nTotalWidth = nBaseWidth + iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding, 0) + 2
		
		# Add space for average value if shown
		if @bShowAverage
			nAvgValueWidth = len("" + RoundN(@nAverage, 1))
			nTotalWidth += 2 + nAvgValueWidth
		ok
		
		# Calculate legend dimensions
		nLegendHeight = 0
		nLegendWidth = 0
		if @bShowLegend
			if @cLegendLayout = :Horizontal
				nLegendHeight = 1
				# Calculate total legend width: "██ SeriesName   ▒▒ SeriesName   ..."
				nLegendWidth = 0
				for i = 1 to @nSeries
					nLegendWidth += 3 + len(@acSeriesNames[i])  # "██ SeriesName"
					if i < @nSeries
						nLegendWidth += 3  # "   " spacing
					ok
				next
			else  # Vertical
				nLegendHeight = @nSeries
				nLegendWidth = 0
				for cName in @acSeriesNames
					nLegendWidth = max([nLegendWidth, 3 + len(cName)])
				next
			ok
		ok
		
		# Calculate layout rows
		nCurrentRow = 1
		
		# V-axis arrow row
		if @bShowVAxis
			nCurrentRow = 2
		ok
		
		# Values row
		nValuesRow = 0
		if @bShowValues or @bShowPercent
			nValuesRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# Bars area
		nBarsStartRow = nCurrentRow
		nBarsEndRow = nCurrentRow + @nHeight - 1
		nCurrentRow = nBarsEndRow + 1
		
		# H-axis row
		nHAxisRow = 0
		if @bShowHAxis
			nHAxisRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# Labels row
		nLabelsRow = 0
		if @bShowLabels and @bShowAxisLabels
			nLabelsRow = nCurrentRow
			nCurrentRow += 1
		ok
		
		# Legend row(s)
		nLegendStartRow = 0
		if @bShowLegend
			nLegendStartRow = nCurrentRow + 1  # Add spacing line
			nCurrentRow = nLegendStartRow + nLegendHeight
		ok
		
		# Total dimensions
		nTotalHeight = nCurrentRow - 1
		nTotalWidth = max([nTotalWidth, nLegendWidth + 2])
		
		# Column positions
		nVAxisCol = 1
		nBarsStart = iff(@bShowVAxis, @nVAxisWidth + @nAxisPadding + 1, 1)
		
		return [
			:total_width = nTotalWidth,
			:total_height = nTotalHeight,
			:bars_start = nBarsStart,
			:bars_start_row = nBarsStartRow,
			:bars_end_row = nBarsEndRow,
			:h_axis_row = nHAxisRow,
			:values_row = nValuesRow,
			:labels_row = nLabelsRow,
			:legend_start_row = nLegendStartRow,
			:legend_height = nLegendHeight,
			:v_axis_col = nVAxisCol,
			:v_axis_start = iff(@bShowVAxis, 2, 1),
			:bars_height = @nHeight,
			:element_widths = aElementWidths,
			:category_group_width = nCategoryGroupWidth
		]

	# --- Multi-Series Drawing Methods ---

	def _drawMultiSeriesBars(oLayout)
		if @nSeries = 0 or @nCategories = 0
			return
		ok

		nBarsStartRow = oLayout[:bars_start_row]
		nBarsEndRow = oLayout[:bars_end_row]
		nBarsHeight = oLayout[:bars_height]
		aElementWidths = oLayout[:element_widths]
		nCategoryGroupWidth = oLayout[:category_group_width]
		
		nCurrentH = oLayout[:bars_start]
		
		# Draw each category group
		for nCat = 1 to @nCategories
			nElementWidth = aElementWidths[nCat]
			nGroupStartH = nCurrentH + floor((nElementWidth - nCategoryGroupWidth) / 2)
			nBarH = nGroupStartH
			
			# Draw each series bar in this category
			for nSer = 1 to @nSeries
				aSeriesInfo = @aSeriesData[nSer]
				aValues = aSeriesInfo[:Values]
				cBarChar = aSeriesInfo[:Char]
				
				if nCat <= len(aValues)
					nValue = aValues[nCat]
					
					# Calculate bar height
					nBarHeight = 0
					if @nMaxValue > 0 and nValue > 0
						nBarHeight = max([1, ceil(nBarsHeight * nValue / @nMaxValue)])
					ok
					
					# Draw bar from bottom up
					for j = 1 to nBarHeight
						for k = 1 to @nBarWidth
							nCol = nBarH + k - 1
							nRow = nBarsEndRow - j + 1
							_setChar(nRow, nCol, cBarChar)
						next
					next
				ok
				
				# Move to next series position
				if nSer < @nSeries
					nBarH += @nBarWidth + @nSeriesSpace
				ok
			next
			
			# Move to next category
			if nCat < @nCategories
				nCurrentH += nElementWidth + @nCategorySpace
			ok
		next

	def _drawMultiSeriesValues(oLayout)
		if not (@bShowValues or @bShowPercent) or oLayout[:values_row] = 0
			return
		ok

		nBarsStartRow = oLayout[:bars_start_row]
		nBarsHeight = oLayout[:bars_height]
		aElementWidths = oLayout[:element_widths]
		nCategoryGroupWidth = oLayout[:category_group_width]
		
		nCurrentH = oLayout[:bars_start]
		
		# Draw values for each category group
		for nCat = 1 to @nCategories
			nElementWidth = aElementWidths[nCat]
			nGroupStartH = nCurrentH + floor((nElementWidth - nCategoryGroupWidth) / 2)
			nBarH = nGroupStartH
			
			# Draw values for each series in this category
			for nSer = 1 to @nSeries
				aSeriesInfo = @aSeriesData[nSer]
				aValues = aSeriesInfo[:Values]
				
				if nCat <= len(aValues)
					nValue = aValues[nCat]
					
					# Format value
					cValue = ""
					if @bShowValues
						if IsInteger(nValue)

							cValue = "" + nValue
						else
							cValue = "" + RoundN(nValue, 1)
						ok

					but @bShowPercent and @nSum > 0
						cPercent = RoundN((nValue * 100) / @nSum, 1)
						cPercent = ring_substr2(cPercent, ".0", "")
						cValue = cPercent + "%"
					ok
					
					# Calculate bar height to position value above it
					nBarHeight = 0
					if @nMaxValue > 0 and nValue > 0
						nBarHeight = max([1, ceil(nBarsHeight * nValue / @nMaxValue)])
					ok
					
					# Position value above bar
					nValueRow = nBarsStartRow + nBarsHeight - nBarHeight - 1
					if nValueRow < 1
						nValueRow = 1
					ok
					
					# Center value over bar
					nValueStart = nBarH + floor((@nBarWidth - len(cValue)) / 2)
					
					# Draw value
					nLen = len(cValue)
					for j = 1 to nLen
						if nValueStart + j - 1 <= oLayout[:total_width]
							_setChar(nValueRow, nValueStart + j - 1, cValue[j])
						ok
					next
				ok
				
				# Move to next series position
				if nSer < @nSeries
					nBarH += @nBarWidth + @nSeriesSpace
				ok
			next
			
			# Move to next category
			if nCat < @nCategories
				nCurrentH += nElementWidth + @nCategorySpace
			ok
		next


	def _drawMultiSeriesLabels(oLayout)
		if not @bShowLabels or not @bShowAxisLabels or oLayout[:labels_row] = 0
			return
		ok

		nLabelsRow = oLayout[:labels_row]
		aElementWidths = oLayout[:element_widths]
		nCurrentH = oLayout[:bars_start]
		
		# Draw category labels
		for i = 1 to @nCategories
			if i <= len(@acCategories)
				cLabel = Capitalise(@acCategories[i])
				nElementWidth = aElementWidths[i]
				
				# Truncate if needed
				if len(cLabel) > @nMaxLabelWidth
					cLabel = Left(cLabel, @nMaxLabelWidth - 2) + ".."
				ok
				
				# Center label
				nLabelStart = nCurrentH + floor((nElementWidth - len(cLabel)) / 2)
				
				# Draw label
				nLen = len(cLabel)
				for j = 1 to nLen
					_setChar(nLabelsRow, nLabelStart + j - 1, cLabel[j])
				next
			ok
			
			# Move to next position
			if i < @nCategories
				nCurrentH += aElementWidths[i] + @nCategorySpace
			ok
		next

	def _drawLegend(oLayout)
		if not @bShowLegend or oLayout[:legend_start_row] = 0
			return
		ok

		nStartRow = oLayout[:legend_start_row]

		if @cLegendLayout = :Horizontal
			# Draw horizontal legend: "██ Series1   ▒▒ Series2   ..."
			nCol = 1
			for i = 1 to @nSeries
				aSeriesInfo = @aSeriesData[i]
				cChar = aSeriesInfo[:Char]
				cName = Capitalise(aSeriesInfo[:SeriesName])
				
				# Draw series character (doubled)
				_setChar(nStartRow, nCol, cChar)
				_setChar(nStartRow, nCol + 1, cChar)
				
				# Draw space and name
				_setChar(nStartRow, nCol + 2, " ")
				nLen = len(cName)
				for j = 1 to nLen
					_setChar(nStartRow, nCol + 2 + j, cName[j])
				next
				
				# Move to next series position
				if i < @nSeries
					nCol += 3 + nLen + 3  # chars + space + name + spacing
				ok
			next
		else
			# Draw vertical legend
			for i = 1 to @nSeries
				aSeriesInfo = @aSeriesData[i]
				cChar = aSeriesInfo[:Char]
				cName = Capitalise(aSeriesInfo[:SeriesName])
				nRow = nStartRow + i - 1
				
				# Draw series character (doubled)
				_setChar(nRow, 1, cChar)
				_setChar(nRow, 2, cChar)
				
				# Draw space and name
				_setChar(nRow, 3, " ")
				nLen = len(cName)
				for j = 1 to nLen
					_setChar(nRow, 3 + j, cName[j])
				next
			next
		ok

	# --- Override Main Methods ---

	def ToString()
		if @nSeries = 0
			return ""
		ok

		oLayout = _calculateMultiSeriesLayout()
		_initCanvas(oLayout[:total_width], oLayout[:total_height])

		_drawVAxis(oLayout)
		_drawHAxis(oLayout)
		_drawMultiSeriesBars(oLayout)
		_drawMultiSeriesValues(oLayout)
		_drawMultiSeriesLabels(oLayout)
		_drawLegend(oLayout)

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
