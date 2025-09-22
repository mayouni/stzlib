
#---------------------------------------#
#  SURFACE COMPOSITION-ORIENTED CHART   #
#---------------------------------------#

class stzSurfaceChart from stzSurfacePlot
class stzSquareChart from stzSurfacePlot
class stzSquarePlot from stzSurfacePlot

class stzSurfacePlot

	@bShowPercent = FALSE
	@bShowBorders = TRUE
	@bShowLabels = TRUE
	@bShowValues = FALSE

	@nMinWidth = 40
	@nMinHeight = 12
	@nMaxWidth = 120
	@nMaxHeight = 30
	
	@nWidth = 40
	@nHeight = 12
	@nMinLabelWidth = 3  # Minimum characters to show from label

	# Border characters
	@cTopLeft = "╭"
	@cTopRight = "╮"
	@cBottomLeft = "╰"
	@cBottomRight = "╯"
	@cHorizontal = "─"
	@cVertical = "│"
	@cTeeDown = "┬"
	@cTeeUp = "┴"
	@cTeeRight = "├"
	@cTeeLeft = "┤"
	@cCross = "┼"

	@aRectangles = []
	@nSum = 0
	@anValues = []
	@acLabels = []
	@acCanvas = []
	@bShowLegend = FALSE
	@aLegend = []

def init(paData)
	if NOT isList(paData)
		raise("Can't create the stzSquareChart object! paData must be a list.")
	ok

	if NOT (IsListOfNumbers(paData) or IsHashList(paData))
		raise("Can't create the stzSquareChart object! paData must be a list of numbers or a hashlist.")
	ok

	# In case a list of numbers is provided (the dataset
	# contains no labels ~> Added automatically as :1, :2, etc.
	if IsListOfNumbers(paData)
		aTemp = []
		nLen = len(paData)

		for i = 1 to nLen
			aTemp + [ ""+i, paData[i] ]
		next

		paData = aTemp
	ok

	# Forming the object container attributes from the hashlist
	oHash = new stzHashList(paData)
	@anValues = oHash.Values()
	@acLabels = oHash.Keys()

	if NOT IsListOfPositiveNumbers(@anValues)
		raise("Incorrect param value! You must provide only positive numbers.")
	ok

	@nSum = Sum(@anValues)	
	_calculateSquaremap()

	def Sum(anNumbers)
		nResult = 0
		for n in anNumbers
			nResult += n
		next
		return nResult

	def IsListOfNumbers(aList)
		for item in aList
			if NOT isNumber(item)
				return FALSE
			ok
		next
		return TRUE

	def IsListOfPositiveNumbers(aList)
		for item in aList
			if NOT (isNumber(item) and item > 0)
				return FALSE
			ok
		next
		return TRUE

	def IsHashList(aList)
		if len(aList) = 0
			return FALSE
		ok
		for item in aList
			if NOT (isList(item) and len(item) = 2)
				return FALSE
			ok
		next
		return TRUE

	def AddPercent()
		@bShowPercent = TRUE
		return This

		def SetPercent(bShow)
			@bShowPercent = bShow
			return This

		def IncludePercent()
			@bShowPercent = TRUE
			return This

	def AddValues()
		@bShowValues = TRUE
		return This

		def SetValues(bShow)
			@bShowValues = bShow
			return This

		def IncludeValues()
			@bShowValues = TRUE
			return This

	def WithoutBorders()
		@bShowBorders = FALSE
		return This

	def SetBorders(bShow)
		@bShowBorders = bShow
		return This

	def WithoutLabels()
		@bShowLabels = FALSE
		return This

	def SetLabels(bShow)
		@bShowLabels = bShow
		return This

	def AddLegend()
		@bShowLegend = TRUE
		return This

	def SetLegend(bShow)
		@bShowLegend = bShow
		return This

	def IncludeLegend()
		@bShowLegend = TRUE
		return This

	def SetWidth(nWidth)
		if NOT isNumber(nWidth)
			raise("Incorrect param type! nWidth must be a number.")
		ok

		@nWidth = max([@nMinWidth, nWidth])

		if @nWidth > @nMaxWidth
			@nWidth = @nMaxWidth
		ok

		_calculateSquaremap()
		return This

	def SetHeight(nHeight)
		if NOT isNumber(nHeight)
			raise("Incorrect param type! nHeight must be a number.")
		ok

		@nHeight = max([@nMinHeight, nHeight])
		
		if @nHeight > @nMaxHeight
			@nHeight = @nMaxHeight
		ok

		_calculateSquaremap()
		return This

	def SetSize(nWidth, nHeight)
		if NOT (isNumber(nWidth) and isNumber(nHeight))
			raise("Incorrect param type! nWidth and nHeight must be both numbers.")
		ok

		@nWidth = max([@nMinWidth, nWidth])
		@nHeight = max([@nMinHeight, nHeight])

		if @nWidth > @nMaxWidth
			@nWidth = @nMaxWidth
		ok
		
		if @nHeight > @nMaxHeight
			@nHeight = @nMaxHeight
		ok

		_calculateSquaremap()
		return This

		def SetDimensions(nWidth, nHeight)
			return This.SetSize(nWidth, nHeight)

	def Show()
		? This.ToString()

	def ToString()
		_autoResize()  # Auto-resize based on content needs
		_calculateSquaremap()
		_initCanvas()
		
		if @bShowBorders
			_drawBorders()
			_connectBordersToOuter()
		ok
		
		_drawContent()
		
		return _finalizeCanvas()

	def _autoResize()
		# Calculate minimum size needed for labels
		nMaxLabelLen = 0
		nLen = len(@acLabels)
		for i = 1 to nLen
			nLenLabel = len(@acLabels[i])
			if nLenLabel > nMaxLabelLen
				nMaxLabelLen = nLenLabel
			ok
		next
		
		# Calculate minimum width needed
		nMinNeededWidth = max([@nMinWidth, nMaxLabelLen + 4])  # +4 for borders and spacing
		if @nWidth < nMinNeededWidth
			@nWidth = min([nMinNeededWidth, @nMaxWidth])
		ok
		
	def _initCanvas()
		@acCanvas = []
		for i = 1 to @nHeight
			aRow = []
			for j = 1 to @nWidth
				aRow + " "
			next
			@acCanvas + aRow
		next
		
	def _finalizeCanvas()
		cResult = ""
		for i = 1 to @nHeight
			for j = 1 to @nWidth
				cResult += @acCanvas[i][j]
			next
			if i < @nHeight
				cResult += nl
			ok
		next
		return cResult

	def _calculateSquaremap()
		@aRectangles = []
		nValues = len(@anValues)
		
		if nValues = 0
			return
		ok
		
		# Sort values by size (descending) for better layout
		aSorted = []
		for i = 1 to nValues
			aSorted + [@anValues[i], @acLabels[i], i]
		next
		
		# Simple bubble sort (descending)
		nLenSorted = len(aSorted)
		for i = 1 to nLenSorted - 1
			for j = i + 1 to nLenSorted
				if aSorted[i][1] < aSorted[j][1]
					temp = aSorted[i]
					aSorted[i] = aSorted[j]
					aSorted[j] = temp
				ok
			next
		next
		
		# Calculate available area (excluding borders if shown)
		nAvailWidth = @nWidth
		nAvailHeight = @nHeight
		
		if @bShowBorders
			nAvailWidth -= 2
			nAvailHeight -= 2
		ok
		
		nTotalArea = nAvailWidth * nAvailHeight
		
		# Calculate rectangles using squarified treemap algorithm (simplified)
		_squarifyLayout(aSorted, 1, 1, nAvailWidth, nAvailHeight, nTotalArea)

	def _squarifyLayout(aSorted, nH, nV, nWidth, nHeight, nTotalArea)
		
		nLen = len(aSorted)
		if nLen = 0
			return
		ok
		
		if nLen = 1
			# Single rectangle fills the space
			nValue = aSorted[1][1]
			cLabel = aSorted[1][2]
			nIndex = aSorted[1][3]
			
			@aRectangles + [nH, nV, nWidth, nHeight, nValue, cLabel, nIndex]
			return
		ok
		
		# Improved treemap layout - better space utilization
		if nLen <= 4
			# Small number of rectangles - create a 2x2 or similar grid
			_createGridLayout(aSorted, nH, nV, nWidth, nHeight)
		else
			# Larger number - use recursive division
			_recursiveDivision(aSorted, nH, nV, nWidth, nHeight)
		ok

	def _createGridLayout(aSorted, nH, nV, nWidth, nHeight)
		nLen = len(aSorted)
		
		if nLen = 2
			# Two rectangles - divide by larger dimension
			if nWidth > nHeight
				# Split horizontally
				nValue1 = aSorted[1][1]
				nValue2 = aSorted[2][1]
				nTotal = nValue1 + nValue2
				nWidth1 = max([1, floor((nValue1 / nTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				@aRectangles + [nH, nV, nWidth1, nHeight, nValue1, aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nH + nWidth1, nV, nWidth2, nHeight, nValue2, aSorted[2][2], aSorted[2][3]]
			else
				# Split vertically
				nValue1 = aSorted[1][1]
				nValue2 = aSorted[2][1]
				nTotal = nValue1 + nValue2
				nHeight1 = max([1, floor((nValue1 / nTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				@aRectangles + [nH, nV, nWidth, nHeight1, nValue1, aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nH, nV + nHeight1, nWidth, nHeight2, nValue2, aSorted[2][2], aSorted[2][3]]
			ok
			
		but nLen = 3
			# Three rectangles - one large, two smaller
			nLargest = aSorted[1][1]
			nSecond = aSorted[2][1]
			nThird = aSorted[3][1]
			nTotal = nLargest + nSecond + nThird
			
			if nWidth > nHeight
				# Horizontal layout: largest left, two on right
				nWidth1 = max([1, floor((nLargest / nTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				# Largest rectangle on left
				@aRectangles + [nH, nV, nWidth1, nHeight, nLargest, aSorted[1][2], aSorted[1][3]]
				
				# Two smaller on right, split vertically
				nSubTotal = nSecond + nThird
				nHeight1 = max([1, floor((nSecond / nSubTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				@aRectangles + [nH + nWidth1, nV, nWidth2, nHeight1, nSecond, aSorted[2][2], aSorted[2][3]]
				@aRectangles + [nH + nWidth1, nV + nHeight1, nWidth2, nHeight2, nThird, aSorted[3][2], aSorted[3][3]]
			else
				# Vertical layout: largest top, two below
				nHeight1 = max([1, floor((nLargest / nTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				# Largest rectangle on top
				@aRectangles + [nH, nV, nWidth, nHeight1, nLargest, aSorted[1][2], aSorted[1][3]]
				
				# Two smaller below, split horizontally
				nSubTotal = nSecond + nThird
				nWidth1 = max([1, floor((nSecond / nSubTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				@aRectangles + [nH, nV + nHeight1, nWidth1, nHeight2, nSecond, aSorted[2][2], aSorted[2][3]]
				@aRectangles + [nH + nWidth1, nV + nHeight1, nWidth2, nHeight2, nThird, aSorted[3][2], aSorted[3][3]]
			ok
			
		else # nLen = 4
			# Four rectangles - 2x2 grid
			nSum1 = aSorted[1][1] + aSorted[2][1]
			nSum2 = aSorted[3][1] + aSorted[4][1]
			nTotal = nSum1 + nSum2
			
			if nWidth >= nHeight
				# Split horizontally first
				nWidth1 = max([1, floor((nSum1 / nTotal) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				# Left column
				nSubTotal1 = aSorted[1][1] + aSorted[2][1]
				nHeight1 = max([1, floor((aSorted[1][1] / nSubTotal1) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				@aRectangles + [nH, nV, nWidth1, nHeight1, aSorted[1][1], aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nH, nV + nHeight1, nWidth1, nHeight2, aSorted[2][1], aSorted[2][2], aSorted[2][3]]
				
				# Right column
				nSubTotal2 = aSorted[3][1] + aSorted[4][1]
				nHeight3 = max([1, floor((aSorted[3][1] / nSubTotal2) * nHeight)])
				nHeight4 = nHeight - nHeight3
				
				@aRectangles + [nH + nWidth1, nV, nWidth2, nHeight3, aSorted[3][1], aSorted[3][2], aSorted[3][3]]
				@aRectangles + [nH + nWidth1, nV + nHeight3, nWidth2, nHeight4, aSorted[4][1], aSorted[4][2], aSorted[4][3]]
			else
				# Split vertically first
				nHeight1 = max([1, floor((nSum1 / nTotal) * nHeight)])
				nHeight2 = nHeight - nHeight1
				
				# Top row
				nSubTotal1 = aSorted[1][1] + aSorted[2][1]
				nWidth1 = max([1, floor((aSorted[1][1] / nSubTotal1) * nWidth)])
				nWidth2 = nWidth - nWidth1
				
				@aRectangles + [nH, nV, nWidth1, nHeight1, aSorted[1][1], aSorted[1][2], aSorted[1][3]]
				@aRectangles + [nH + nWidth1, nV, nWidth2, nHeight1, aSorted[2][1], aSorted[2][2], aSorted[2][3]]
				
				# Bottom row
				nSubTotal2 = aSorted[3][1] + aSorted[4][1]
				nWidth3 = max([1, floor((aSorted[3][1] / nSubTotal2) * nWidth)])
				nWidth4 = nWidth - nWidth3
				
				@aRectangles + [nH, nV + nHeight1, nWidth3, nHeight2, aSorted[3][1], aSorted[3][2], aSorted[3][3]]
				@aRectangles + [nH + nWidth3, nV + nHeight1, nWidth4, nHeight2, aSorted[4][1], aSorted[4][2], aSorted[4][3]]
			ok
		ok

	def _recursiveDivision(aSorted, nH, nV, nWidth, nHeight)
		# For larger numbers, use simple recursive division
		nLen = len(aSorted)
		nMid = floor(nLen / 2)
		
		# Calculate sum for first half
		nSum1 = 0
		for i = 1 to nMid
			nSum1 += aSorted[i][1]
		next
		
		# Calculate sum for second half
		nSum2 = 0
		for i = nMid + 1 to nLen
			nSum2 += aSorted[i][1]
		next
		
		nTotal = nSum1 + nSum2
		
		if nWidth >= nHeight
			# Divide horizontally
			nWidth1 = max([1, floor((nSum1 / nTotal) * nWidth)])
			nWidth2 = nWidth - nWidth1
			
			# First half
			aFirst = []
			for i = 1 to nMid
				aFirst + aSorted[i]
			next
			_squarifyLayout(aFirst, nH, nV, nWidth1, nHeight, nWidth1 * nHeight)
			
			# Second half
			aSecond = []
			for i = nMid + 1 to nLen
				aSecond + aSorted[i]
			next
			_squarifyLayout(aSecond, nH + nWidth1, nV, nWidth2, nHeight, nWidth2 * nHeight)
		else
			# Divide vertically
			nHeight1 = max([1, floor((nSum1 / nTotal) * nHeight)])
			nHeight2 = nHeight - nHeight1
			
			# First half
			aFirst = []
			for i = 1 to nMid
				aFirst + aSorted[i]
			next
			_squarifyLayout(aFirst, nH, nV, nWidth, nHeight1, nWidth * nHeight1)
			
			# Second half
			aSecond = []
			for i = nMid + 1 to nLen
				aSecond + aSorted[i]
			next
			_squarifyLayout(aSecond, nH, nV + nHeight1, nWidth, nHeight2, nWidth * nHeight2)
		ok

	def _drawBorders()
		
		# Draw outer border
		# Top border
		@acCanvas[1][1] = @cTopLeft
		@acCanvas[1][@nWidth] = @cTopRight
		for i = 2 to @nWidth - 1
			@acCanvas[1][i] = @cHorizontal
		next
		
		# Bottom border
		@acCanvas[@nHeight][1] = @cBottomLeft
		@acCanvas[@nHeight][@nWidth] = @cBottomRight
		for i = 2 to @nWidth - 1
			@acCanvas[@nHeight][i] = @cHorizontal
		next
		
		# Side borders
		for i = 2 to @nHeight - 1
			@acCanvas[i][1] = @cVertical
			@acCanvas[i][@nWidth] = @cVertical
		next
		
		# Draw internal borders between rectangles
		_drawInternalBorders()

	def _connectBordersToOuter()
	    # Check each position on outer border for connections
	    
	    # Top border connections
	    for j = 2 to @nWidth - 1
	        if @acCanvas[2][j] = @cVertical  # Internal border connects from below
	            @acCanvas[1][j] = @cTeeDown
	        ok
	    next
	    
	    # Bottom border connections  
	    for j = 2 to @nWidth - 1
	        if @acCanvas[@nHeight-1][j] = @cVertical  # Internal border connects from above
	            @acCanvas[@nHeight][j] = @cTeeUp
	        ok
	    next
	    
	    # Left border connections
	    for i = 2 to @nHeight - 1
	        if @acCanvas[i][2] = @cHorizontal  # Internal border connects from right
	            @acCanvas[i][1] = @cTeeRight
	        ok
	    next
	    
	    # Right border connections
	    for i = 2 to @nHeight - 1
	        if @acCanvas[i][@nWidth-1] = @cHorizontal  # Internal border connects from left
	            @acCanvas[i][@nWidth] = @cTeeLeft
	        ok
	    next

	def _drawInternalBorders()
	    
	    nLen = len(@aRectangles)
	    
	    # First pass: draw all borders without intersections
	    for i = 1 to nLen
	        aRect = @aRectangles[i]
	        nH = aRect[1]
	        nV = aRect[2] 
	        nW = aRect[3]
	        nHt = aRect[4]
	        
	        # Adjust for outer border offset
	        if @bShowBorders
	            nH++
	            nV++
	        ok
	        
	        # Draw right border if not at edge
	        if nH + nW < @nWidth
	            for j = nV to nV + nHt - 1
	                if j >= 1 and j <= @nHeight
	                    if @acCanvas[j][nH + nW] = " "
	                        @acCanvas[j][nH + nW] = @cVertical
	                    ok
	                ok
	            next
	        ok
	        
	        # Draw bottom border if not at edge
	        if nV + nHt < @nHeight and nV + nHt > 1
	            for j = nH to nH + nW - 1
	                if j >= 1 and j <= @nWidth
	                    if @acCanvas[nV + nHt][j] = " "
	                        @acCanvas[nV + nHt][j] = @cHorizontal
	                    ok
	                ok
	            next
	        ok
	    next
	    
	    # Second pass: fix all intersections
	    _fixBorderIntersections()

	def _fixBorderIntersections()
		
		for i = 1 to @nHeight
			for j = 1 to @nWidth
				
				cCurrent = @acCanvas[i][j]
				
				# Only process positions that have border characters
				if cCurrent = @cVertical or cCurrent = @cHorizontal
				
					# Check all four directions for connections
					bUp = FALSE
					bDown = FALSE
					bLeft = FALSE
					bRight = FALSE
					
					# Check up
					if i > 1
						cUp = @acCanvas[i-1][j]
						bUp = (cUp = @cVertical or cUp = @cTeeDown or cUp = @cTeeUp or cUp = @cCross or cUp = @cTeeLeft or cUp = @cTeeRight)
					ok
					
					# Check down
					if i < @nHeight
						cDown = @acCanvas[i+1][j]
						bDown = (cDown = @cVertical or cDown = @cTeeDown or cDown = @cTeeUp or cDown = @cCross or cDown = @cTeeLeft or cDown = @cTeeRight)
					ok
					
					# Check left
					if j > 1
						cLeft = @acCanvas[i][j-1]
						bLeft = (cLeft = @cHorizontal or cLeft = @cTeeLeft or cLeft = @cTeeRight or cLeft = @cCross or cLeft = @cTeeDown or cLeft = @cTeeUp)
					ok
					
					# Check right
					if j < @nWidth
						cRight = @acCanvas[i][j+1]
						bRight = (cRight = @cHorizontal or cRight = @cTeeLeft or cRight = @cTeeRight or cRight = @cCross or cRight = @cTeeDown or cRight = @cTeeUp)
					ok
					
					# Determine proper intersection character
					nConnections = 0
					if bUp: nConnections++ ok
					if bDown: nConnections++ ok
					if bLeft: nConnections++ ok
					if bRight: nConnections++ ok
					
					# Apply appropriate intersection character
					if nConnections >= 2
						if bUp and bDown and bLeft and bRight
							@acCanvas[i][j] = @cCross
						but bUp and bDown and bRight and not bLeft
							@acCanvas[i][j] = @cTeeRight
						but bUp and bDown and bLeft and not bRight
							@acCanvas[i][j] = @cTeeLeft
						but bLeft and bRight and bDown and not bUp
							@acCanvas[i][j] = @cTeeDown
						but bLeft and bRight and bUp and not bDown
							@acCanvas[i][j] = @cTeeUp
						but bUp and bRight and not bDown and not bLeft
							@acCanvas[i][j] = @cBottomLeft
						but bUp and bLeft and not bDown and not bRight
							@acCanvas[i][j] = @cBottomRight
						but bDown and bRight and not bUp and not bLeft
							@acCanvas[i][j] = @cTopLeft
						but bDown and bLeft and not bUp and not bRight
							@acCanvas[i][j] = @cTopRight
						ok
					ok
				ok
			next
		next

	def _truncateLabel(cLabel, nMaxWidth)
		if len(cLabel) <= nMaxWidth
			return cLabel
		ok
		
		if nMaxWidth <= @nMinLabelWidth
			return left(cLabel, max([1, nMaxWidth - 1])) + "."
		ok
		
		return left(cLabel, nMaxWidth - 1) + "."

	def _drawContent()
	    
	    nLen = len(@aRectangles)
	    
	    for i = 1 to nLen
	        aRect = @aRectangles[i]
	        nH = aRect[1]
	        nV = aRect[2]
	        nW = aRect[3]
	        nHt = aRect[4]
	        nValue = aRect[5]
	        cLabel = Capitalise(aRect[6])
	        nOrigIndex = aRect[7]
	        
	        # Adjust for border offset
	        if @bShowBorders
	            nH++
	            nV++
	        ok
	        
	        # Calculate usable content area (avoiding borders)
	        nContentH = nH
	        nContentV = nV
	        nContentW = nW
	        nContentHt = nHt

	        if @bShowBorders
	            # Shrink content area to avoid internal borders
	            if nH + nW < @nWidth
	                nContentW -= 1  # Avoid right border
	            ok
	            if nV + nHt < @nHeight
	                nContentHt -= 1  # Avoid bottom border
	            ok
	        ok

	        # Only proceed if we have reasonable space
	        if nContentW < 3 or nContentHt < 1
	            loop  # Skip this rectangle - too small for meaningful content
	        ok

	        # Build content lines
	        aContentLines = []

	        # Prepare label and value content
	        cMainContent = ""
	        cSubContent = ""

	        if @bShowLabels and len(cLabel) > 0
	            cMainContent = _truncateLabel(cLabel, nContentW)
	        ok

	        # Build value/percent string
	        cValueStr = ""
	        if @bShowValues
	            cValueStr = ""+ RoundN(nValue, 1)
				cValueStr = ring_substr2(cValueStr, ".0", "")
	        ok

	        if @bShowPercent
	            cPercentStr = ""+ RoundN((nValue / @nSum) * 100, 1)
				cPercentStr = ring_substr2(cPercentStr, ".0", "")
	            cPercentStr += "%"
	            
	            if len(cValueStr) > 0
	                cSubContent = cValueStr + " (" + cPercentStr + ")"
	            else
	                cSubContent = cPercentStr
	            ok
	        but len(cValueStr) > 0
	            cSubContent = cValueStr
	        ok

	        # Ensure sub-content fits
	        if len(cSubContent) > nContentW
	            if nContentW > 3
	                cSubContent = left(cSubContent, nContentW - 1) + "."
	            else
	                cSubContent = left(cSubContent, nContentW)
	            ok
	        ok

	        # Determine layout - prioritize compact, clean display
	        bShowMain = (len(cMainContent) > 0 and len(cMainContent) <= nContentW)
	        bShowSub = (len(cSubContent) > 0 and len(cSubContent) <= nContentW)
	        
	        if bShowMain and bShowSub
	            if nContentHt >= 2
	                # Multi-line: label on top, value below
	                aContentLines + cMainContent
	                aContentLines + cSubContent
	            but nContentW >= (len(cMainContent) + len(cSubContent) + 1)
	                # Single line if they fit together
	                aContentLines + cMainContent + " " + cSubContent
	            else
	                # Prioritize more important content
	                if @bShowPercent or @bShowValues
	                    aContentLines + cSubContent  # Values/percentages more important in compact view
	                else
	                    aContentLines + cMainContent
	                ok
	            ok
	        but bShowMain
	            aContentLines + cMainContent
	        but bShowSub
	            aContentLines + cSubContent
	        ok
	        
			# Draw content lines centered in available space
			nLenLines = len(aContentLines)
	        if nLenLines > 0
	            # Vertical centering
	            nStartV = nContentV + max([0, floor((nContentHt - len(aContentLines)) / 2)])
	
	            for k = 1 to nLenLines
	                cLine = aContentLines[k]
	                nLineLen = len(cLine)
	                nCurrentV = nStartV + k - 1
	
	                # Horizontal centering
	                nCenterH = nContentH + max([0, floor((nContentW - nLineLen) / 2)])
	
	                # Draw the line
	                if nCurrentV >= nContentV and nCurrentV < nContentV + nContentHt and nCurrentV >= 1 and nCurrentV <= @nHeight
	                    for j = 1 to nLineLen
	                        nCol = nCenterH + j - 1
	                        if nCol >= nContentH and nCol < nContentH + nContentW and nCol >= 1 and nCol <= @nWidth
	                            if @acCanvas[nCurrentV][nCol] = " "
	                                @acCanvas[nCurrentV][nCol] = cLine[j]
	                            ok
	                        ok
	                    next
	                ok
	            next
	        ok
    	next
