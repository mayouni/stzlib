/*
	stzTimeLine - Timeline Management in Softanza
	Manages sequential time data: points, spans, and temporal relationships
	String-first design: methods accept/return strings, ...Q() returns objects
*/

func StzTimeLineQ(p)
	return new stzTimeLine(p)

func TimeLineQ(p)
	return new stzTimeLine(p)

func TimeLine(p)
	return new stzTimeLine(p)

class stzTimeLine from stzObject
	@cStart = NULL
	@cEnd = NULL
	@aPoints = []      # [[name, string_datetime], ...]
	@aSpans = []       # [[name, string_datetime, string_datetime], ...]

	# Display properties
	@nVizWidth = 52
	@nVizHeight = 5
	@cAxisChar = "─"
	@cPointChar = "●"
	@cSpanChar = "═"
	@cSpanStartChar = "╞"
	@cSpanEndChar = "╡"
	@cTickChar = "│"
	@cHighlightChar = "█"
	@cArrowChar = "──►"
	@bShowDates = TRUE
	@bShowLabels = TRUE
	@cHighlight = NULL

	# Layout
	@nLabelHeight = 1
	@nAxisRow = 0
	@nDateRow = 0
	@acVizCanvas = []

	def init(p)
		if isList(p) and @IsHashList(p)
			# Initialize start/end boundaries
			if len(p) >= 1 and p[1][1] = :Start and p[1][2] != NULL
				if isString(p[1][2])
					@cStart = p[1][2]
				else
					@cStart = new stzDateTime(p[1][2]).ToString()
				ok
			ok
			if len(p) >= 2 and p[2][1] = :End and p[2][2] != NULL
				if isString(p[2][2])
					@cEnd = p[2][2]
				else
					@cEnd = new stzDateTime(p[2][2]).ToString()
				ok
			ok
		else
			@cStart = NULL
			@cEnd = NULL
		ok

	# Boundary Management
	
	def Start()
		return @cStart
		
		def StartQ()
			if @cStart != NULL
				return new stzDateTime(@cStart)
			ok
			return NULL

		def StartDate()
			return This.Start()
			
			def StartDateQ()
				return This.StartQ()

	def End_()
		return @cEnd
		
		def EndQ()
			if @cEnd != NULL
				return new stzDateTime(@cEnd)
			ok
			return NULL

		def End_Q()
			return This.EndQ()

		def EndDate()
			return This.End_()

		def EndDateQ()
			return This.EndQ()

		def _End()
			return This.End_()

		def _EndQ()
			return This.EndQ()

		def Endd()
			return This.End_()

		def EnddQ()
			return This.EndQ()

	def SetStart(p)
		if isString(p)
			@cStart = p
		else
			@cStart = new stzDateTime(p).ToString()
		ok

		def SetStartQ(p)
			This.SetStart(p)
			return This
		
	def SetEnd(p)
		if isString(p)
			@cEnd = p
		else
			@cEnd = new stzDateTime(p).ToString()
		ok

		def SetEndQ(p)
			This.SetEnd(p)
			return This
		
	def HasBoundaries()
		return @cStart != NULL and @cEnd != NULL
		
	def Duration()
		if This.HasBoundaries()
			return This.StartQ().DurationTo(@cEnd, :InSeconds)
		ok
		return NULL

		def DurationQ()
			if This.Duration() != NULL
				return new stzDuration(This.Duration())
			ok
			return NULL

	# Point Management (single moments in time)
	
	def AddPoint(cName, pDateTime)
		cPoint = NULL
		if isString(pDateTime)
			cPoint = pDateTime
		else
			cPoint = new stzDateTime(pDateTime).ToString()
		ok
		
		# Validate against boundaries
		if This.HasBoundaries()
			oPoint = new stzDateTime(cPoint)
			oStart = This.StartQ()
			oEnd = This.EndQ()
			if oPoint < oStart or oPoint > oEnd
				raise("Point '" + cName + "' is outside timeline boundaries")
			ok
		ok
		
		@aPoints + [cName, cPoint]

		def AddPointQ(cName, pDateTime)
			This.AddPoint(cName, pDateTime)
			return This
		
		def AddTimePoint(cName, pDateTime)
			This.AddPoint(cName, pDateTime)
			
			def AddTimePointQ(cName, pDateTime)
				return This.AddPointQ(cName, pDateTime)

		def AddMoment(cName, pDateTime)
			This.AddPoint(cName, pDateTime)
	
			def AddMomentQ(cName, pDateTime)
				return This.AddPointQ(cName, pDateTime)

	def AddPoints(paPoints)
		nLen = len(paPoints)
		for i = 1 to nLen
			This.AddPoint(paPoints[i][1], paPoints[i][2])
		next

		def AddMoments(paPoints)
			This.AddPoints(paPoints)

	def Points()
		return @aPoints
		
		def PointsQ()
			aResult = []
			nLen = len(@aPoints)
			for i = 1 to nLen
				aResult + [@aPoints[i][1], new stzDateTime(@aPoints[i][2])]
			next
			return aResult

		def TimePoints()
			return This.Points()

		def TimePointsQ()
			return This.PointsQ()
			
		def Moments()
			return This.Points()

		def MomentsQ()
			return This.PointsQ()
			
	def PointNames()
		acResult = []
		nLen = len(@aPoints)
		for i = 1 to nLen
			acResult + @aPoints[i][1]
		next
		return acResult
		
	def Point(cName)
		nLen = len(@aPoints)
		for i = 1 to nLen
			if @aPoints[i][1] = cName
				return @aPoints[i][2]
			ok
		next
		return NULL

		def PointQ(cName)
			cPoint = This.Point(cName)
			if cPoint != NULL
				return new stzDateTime(cPoint)
			ok
			return NULL
		
	def HasPoint(cName)
		return This.Point(cName) != NULL
		
	def RemovePoint(cName)
		nPos = 0
		nLen = len(@aPoints)
		for i = 1 to nLen
			if @aPoints[i][1] = cName
				nPos = i
				exit
			ok
		next
		if nPos > 0
			del(@aPoints, nPos)
		ok

		def RemovePointQ(cName)
			This.RemovePoint(cName)
			return This
		
	def CountPoints()
		return len(@aPoints)
		
		def NumberOfPoints()
			return This.CountPoints()

		def HowManyPoints()
			return This.CountPoints()

	# Span Management (time periods with start and end)

	def AddSpans(paSpans)
		nLen = len(paSpans)
		for i = 1 to nLen
			This.AddSpan(paSpans[i][1], paSpans[i][2], paSpans[i][3])
		next

	def AddSpan(cName, pStart, pEnd)
		cStart = NULL
		cEnd = NULL
		
		if isString(pStart)
			cStart = pStart
		else
			cStart = new stzDateTime(pStart).ToString()
		ok
		
		if isString(pEnd)
			cEnd = pEnd
		else
			cEnd = new stzDateTime(pEnd).ToString()
		ok
		
		# Validate span
		oStart = new stzDateTime(cStart)
		oEnd = new stzDateTime(cEnd)
		if oStart >= oEnd
			raise("Span '" + cName + "' start must be before end")
		ok
		
		# Validate against boundaries
		if This.HasBoundaries()
			oTLStart = This.StartQ()
			oTLEnd = This.EndQ()
			if oStart < oTLStart or oEnd > oTLEnd
				raise("Span '" + cName + "' is outside timeline boundaries")
			ok
		ok
		
		@aSpans + [cName, cStart, cEnd]
		
		def AddSpanQ(cName, pStart, pEnd)
			This.AddSpan(cName, pStart, pEnd)
			return This
		
		def AddPeriod(cName, pStart, pEnd)
			This.AddSpan(cName, pStart, pEnd)

			def AddPeriodQ(cName, pStart, pEnd)
				return This.AddSpanQ(cName, pStart, pEnd)
			
	def Spans()
		return @aSpans

		def SpansQ()
			aResult = []
			nLen = len(@aSpans)
			for i = 1 to nLen
				aResult + [
					@aSpans[i][1],
					new stzDateTime(@aSpans[i][2]),
					new stzDateTime(@aSpans[i][3])
				]
			next
			return aResult
		
		def Periods()
			return This.Spans()

		def PeriodsQ()
			return This.SpansQ()
			
	def SpanNames()
		acResult = []
		nLen = len(@aSpans)
		for i = 1 to nLen
			acResult + @aSpans[i][1]
		next
		return acResult
		
		def PeriodNames()
			return This.SpanNames()
			
	def Span(cName)
		nLen = len(@aSpans)
		for i = 1 to nLen
			if @aSpans[i][1] = cName
				return [@aSpans[i][2], @aSpans[i][3]]
			ok
		next
		return NULL

		def SpanQ(cName)
			aSpan = This.Span(cName)
			if aSpan != NULL
				return [
					new stzDateTime(aSpan[1]),
					new stzDateTime(aSpan[2])
				]
			ok
			return NULL
		
		def Period(cName)
			return This.Span(cName)

		def PeriodQ(cName)
			return This.SpanQ(cName)

	def SpanStart(cName)
		aSpan = This.Span(cName)
		if aSpan != NULL
			return aSpan[1]
		ok
		return NULL

		def SpanStartQ(cName)
			cStart = This.SpanStart(cName)
			if cStart != NULL
				return new stzDateTime(cStart)
			ok
			return NULL
		
	def SpanEnd(cName)
		aSpan = This.Span(cName)
		if aSpan != NULL
			return aSpan[2]
		ok
		return NULL

		def SpanEndQ(cName)
			cEnd = This.SpanEnd(cName)
			if cEnd != NULL
				return new stzDateTime(cEnd)
			ok
			return NULL
		
	def SpanDuration(cName)
		aSpan = This.Span(cName)
		if aSpan != NULL
			return This.SpanStartQ(cName).DurationTo(aSpan[2], :InSeconds)
		ok
		return NULL
		
		def SpanDurationQ(cName)
			nDuration = This.SpanDuration(cName)
			if nDuration != NULL
				return new stzDuration(nDuration)
			ok
			return NULL

	def HasSpan(cName)
		return This.Span(cName) != NULL
		
	def RemoveSpan(cName)
		nPos = 0
		nLen = len(@aSpans)
		for i = 1 to nLen
			if @aSpans[i][1] = cName
				nPos = i
				exit
			ok
		next
		if nPos > 0
			del(@aSpans, nPos)
		ok
		
		def RemoveSpanQ(cName)
			This.RemoveSpan(cName)
			return This
		
	def CountSpans()
		return len(@aSpans)
		
		def NumberOfSpans()
			return This.CountSpans()
			
		def CountPeriods()
			return This.CountSpans()

		def NumberOfPeriods()
			return This.CountSpans()

		def HowManySpans()
			return This.CountSpans()

		def HowManyPeriods()
			return This.CountSpans()

	# Temporal Queries
	
	def WhatsAt(pDateTime)
		cDateTime = NULL
		if isString(pDateTime)
			cDateTime = pDateTime
		else
			cDateTime = new stzDateTime(pDateTime).ToString()
		ok
		
		oDateTime = new stzDateTime(cDateTime)
		aResult = []
		
		# Check points at exact time
		nLen = len(@aPoints)
		for i = 1 to nLen
			if StzDateTimeQ(@aPoints[i][2]).IsEqualTo(oDateTime)
				aResult + [:Point, @aPoints[i][1]]
			ok
		next
		
		# Check spans containing this time
		nLen = len(@aSpans)
		for i = 1 to nLen
			oStart = new stzDateTime(@aSpans[i][2])
			oEnd = new stzDateTime(@aSpans[i][3])
			if oDateTime >= oStart and oDateTime <= oEnd
				aResult + [:Span, @aSpans[i][1]]
			ok
		next
		
		return aResult
		
		def HappeningAt(pDateTime)
			return This.WhatsAt(pDateTime)
			
		def WhatHappenedAt(pDateTime)
			return This.WhatsAt(pDateTime)

		def PointsAt(pDateTime)
			return This.WhatsAt(pDateTime)

		def MomentsAt(pDateTime)
			return This.WhatsAt(pDateTime)

	def PointsBetween(pStart, pEnd)
		if CheckParams()
			if isList(pEnd) and StzListQ(pEnd).IsAndNamedParam()
				pEnd = pEnd[2]
			ok
		ok

		cStart = NULL
		cEnd = NULL
		if isString(pStart)
			cStart = pStart
		else
			cStart = new stzDateTime(pStart).ToString()
		ok
		if isString(pEnd)
			cEnd = pEnd
		else
			cEnd = new stzDateTime(pEnd).ToString()
		ok

		oStart = new stzDateTime(cStart)
		oEnd = new stzDateTime(cEnd)
		
		aResult = []
		nLen = len(@aPoints)
		for i = 1 to nLen
			oPoint = new stzDateTime(@aPoints[i][2])
			if oPoint >= oStart and oPoint <= oEnd
				aResult + @aPoints[i][1]
			ok
		next

		return aResult
		
		def MomentsBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		def WhatsBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		def HappeningBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		def WhatHappenedBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

	def SpansBetween(pStart, pEnd)
		cStart = NULL
		cEnd = NULL
		if isString(pStart)
			cStart = pStart
		else
			cStart = new stzDateTime(pStart).ToString()
		ok
		if isString(pEnd)
			cEnd = pEnd
		else
			cEnd = new stzDateTime(pEnd).ToString()
		ok

		oStart = new stzDateTime(cStart)
		oEnd = new stzDateTime(cEnd)
		
		aResult = []
		nLen = len(@aSpans)
		for i = 1 to nLen
			oSpanStart = new stzDateTime(@aSpans[i][2])
			oSpanEnd = new stzDateTime(@aSpans[i][3])
			# Include spans that overlap with the range
			if oSpanEnd >= oStart and oSpanStart <= oEnd
				aResult + @aSpans[i][1]
			ok
		next

		return aResult

	def SpansOverlapping(pDateTime)
		cDateTime = NULL
		if isString(pDateTime)
			cDateTime = pDateTime
		else
			cDateTime = new stzDateTime(pDateTime).ToString()
		ok

		oDateTime = new stzDateTime(cDateTime)
		
		aResult = []
		nLen = len(@aSpans)
		for i = 1 to nLen
			oStart = new stzDateTime(@aSpans[i][2])
			oEnd = new stzDateTime(@aSpans[i][3])
			if oDateTime >= oStart and oDateTime <= oEnd
				aResult + @aSpans[i][1]
			ok
		next

		return aResult
		
		def SpansContaining(pDateTime)
			return This.SpansOverlapping(pDateTime)

	# Overlap Detection
	
	def HasOverlaps()
		nLen = len(@aSpans)
		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				oStart1 = new stzDateTime(@aSpans[i][2])
				oEnd1 = new stzDateTime(@aSpans[i][3])
				oStart2 = new stzDateTime(@aSpans[j][2])
				oEnd2 = new stzDateTime(@aSpans[j][3])
				
				# Check if spans overlap
				if oStart1 < oEnd2 and oStart2 < oEnd1
					return TRUE
				ok
			next
		next
		return FALSE
		
	def OverlappingSpans()
		aResult = []
		nLen = len(@aSpans)
		
		for i = 1 to nLen - 1
			for j = i + 1 to nLen
				oStart1 = new stzDateTime(@aSpans[i][2])
				oEnd1 = new stzDateTime(@aSpans[i][3])
				oStart2 = new stzDateTime(@aSpans[j][2])
				oEnd2 = new stzDateTime(@aSpans[j][3])
				
				# Check if spans overlap
				if oStart1 < oEnd2 and oStart2 < oEnd1
					# Calculate overlap duration
					oOverlapStart = NULL
					oOverlapEnd = NULL
					
					if oStart1 >= oStart2
						oOverlapStart = oStart1
					else
						oOverlapStart = oStart2
					ok
					
					if oEnd1 <= oEnd2
						oOverlapEnd = oEnd1
					else
						oOverlapEnd = oEnd2
					ok
					
					nDuration = oOverlapStart.DurationTo(oOverlapEnd, :InSeconds)
					
					aResult + [
						@aSpans[i][1],
						@aSpans[j][1],
						nDuration
					]
				ok
			next
		next
		return aResult

	# Gap Analysis
	
	def Gaps()
		if len(@aSpans) = 0
			return []
		ok
		
		# Sort spans by start time
		aSorted = This.SortedSpans()
		nLen = len(aSorted)
	
		aGaps = []
		for i = 1 to nLen - 1
			oEnd1 = new stzDateTime(aSorted[i][3])
			oStart2 = new stzDateTime(aSorted[i + 1][2])
			
			if oEnd1 < oStart2
				nDuration = oEnd1.DurationTo(oStart2, :InSeconds)
				aGaps + [
					:After = aSorted[i][1],
					:Before = aSorted[i + 1][1],
					:Duration = nDuration
				]
			ok
		next
	
		return aGaps
		
	def UncoveredPeriods()
		if not This.HasBoundaries() or len(@aSpans) = 0
			return []
		ok
		
		aSorted = This.SortedSpans()
		nLen = len(aSorted)
		aUncovered = []
		
		oStart = This.StartQ()
		oEnd = This.EndQ()
		
		# Check gap before first span
		oFirstStart = new stzDateTime(aSorted[1][2])
		if oFirstStart > oStart
			nDuration = oStart.DurationTo(oFirstStart, :InSeconds)
			aUncovered + [
				:Start = @cStart,
				:End = aSorted[1][2],
				:Duration = nDuration
			]
		ok
		
		# Check gaps between spans
		for i = 1 to nLen - 1
			oEnd1 = new stzDateTime(aSorted[i][3])
			oStart2 = new stzDateTime(aSorted[i + 1][2])
			
			if oEnd1 < oStart2
				nDuration = oEnd1.DurationTo(oStart2, :InSeconds)
				aUncovered + [
					:Start = aSorted[i][3],
					:End = aSorted[i + 1][2],
					:Duration = nDuration
				]
			ok
		next
		
		# Check gap after last span
		oLastEnd = new stzDateTime(aSorted[nLen][3])
		if oLastEnd < oEnd
			nDuration = oLastEnd.DurationTo(oEnd, :InSeconds)
			aUncovered + [
				:Start = aSorted[nLen][3],
				:End = @cEnd,
				:Duration = nDuration
			]
		ok
		
		return aUncovered

	# Distance Calculations
	
	def Distance(cName1, cName2)
		if CheckParams()
			if isList(cName1) and StzListQ(cName1).IsFromOrBetweenNamedParam()
				cName1 = cName1[2]
			ok

			if isList(cName2) and StzListQ(cName2).IsToOrAndNamedParam()
				cName2 = cName2[2]
			ok
		ok
		
		return This.DistanceBetween(cName1, cName2)

		def DistanceQ(cName1, cName2)
			return This.DistanceBetweenQ(cName1, cName2)

		def Interval(cName1, cName2)
			return This.Distance(cName1, cName2)

		def IntervalQ(cName1, cName2)
			return This.DistanceQ(cName1, cName2)

	def DistanceBetween(cName1, cName2)
		cTime1 = NULL
		cTime2 = NULL
		
		# Try to find as points
		cTime1 = This.Point(cName1)
		cTime2 = This.Point(cName2)
		
		# If not points, try span ends for first, start for second
		if cTime1 = NULL
			aSpan = This.Span(cName1)
			if aSpan != NULL
				cTime1 = aSpan[2]  # Use end of first span
			ok
		ok
		
		if cTime2 = NULL
			aSpan = This.Span(cName2)
			if aSpan != NULL
				cTime2 = aSpan[1]  # Use start of second span
			ok
		ok
		
		if cTime1 != NULL and cTime2 != NULL
			return StzDateTimeQ(cTime1).DurationTo(cTime2, :InSeconds)
		ok
		
		return NULL
		
		def DistanceBetweenQ(cName1, cName2)
			nDuration = This.DistanceBetween(cName1, cName2)
			if nDuration != NULL
				return new stzDuration(nDuration)
			ok
			return NULL

		def TimeBetween(cName1, cName2)
			return This.DistanceBetween(cName1, cName2)
	
			def TimeBetweenQ(cName1, cName2)
				return This.DistanceBetweenQ(cName1, cName2)

		def IntervalBetween(cName1, cName2)
			return This.DistanceBetween(cName1, cName2)
	
			def IntervalBetweenQ(cName1, cName2)
				return This.DistanceBetweenQ(cName1, cName2)

	# Utility Methods
	
	def SortedSpans()
		# Simple bubble sort by start time
		aSorted = @aSpans
		nLen = len(aSorted)
		
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				oTime1 = new stzDateTime(aSorted[j][2])
				oTime2 = new stzDateTime(aSorted[j + 1][2])
				if oTime1 > oTime2
					aTemp = aSorted[j]
					aSorted[j] = aSorted[j + 1]
					aSorted[j + 1] = aTemp
				ok
			next
		next
		
		return aSorted
		
	def SortedPoints()
		# Simple bubble sort by time
		aSorted = @aPoints
		nLen = len(aSorted)
		
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				oTime1 = new stzDateTime(aSorted[j][2])
				oTime2 = new stzDateTime(aSorted[j + 1][2])
				if oTime1 > oTime2
					aTemp = aSorted[j]
					aSorted[j] = aSorted[j + 1]
					aSorted[j + 1] = aTemp
				ok
			next
		next
		
		return aSorted

	# Output Methods
	
	def Summary()

		aResult = []
		
		# Add boundaries if they exist
		if This.HasBoundaries()
			aResult + [ "start", @cStart ] + 
				[ "end", @cEnd ] +
				[ "totalduration", This.DurationQ().ToHuman() ]
		ok
		
		# Add counts
		aResult + [ "countpoints", This.CountPoints() ] +
			[ "countspans", This.CountSpans() ]
		
		# Add sorted points
		if len(@aPoints) > 0
			aPoints = []
			aSorted = This.SortedPoints()
			nLen = len(aSorted)
			for i = 1 to nLen
				aPoints + [ "name", aSorted[i][1] ] +
					[ "datetime", aSorted[i][2] ]
			next
			aResult + [ "points", aPoints ]
		ok
		
		# Add sorted spans with durations
		if len(@aSpans) > 0

			aSpans = []
			aSorted = This.SortedSpans()
			nLen = len(aSorted)

			for i = 1 to nLen
				oStart = new stzDateTime(aSorted[i][2])
				oDuration = StzDurationQ(oStart.DurationTo(aSorted[i][3], :InSeconds))
				aSpans + [ "name", aSorted[i][1] ] +
					[ "start", aSorted[i][2] ] +
					[ "end", aSorted[i][3] ] +
					[ "duration", oDuration.ToHuman() ]
			next

			aResult + [ "spans", aSpans ]
		ok
		
		return aResult
		
	def Clear()
		@aPoints = []
		@aSpans = []
		return This
		
	def Copy()
		oCopy = new stzTimeLine([
			:Start, NULL,
			:End, NULL
		])
		
		# Copy boundaries
		if This.HasBoundaries()
			oCopy.SetStart(This.Start())
			oCopy.SetEnd(This.End_())
		ok
		
		# Copy points
		nLen = len(@aPoints)
		for i = 1 to nLen
			oCopy.AddPoint(@aPoints[i][1], @aPoints[i][2])
		next
		
		# Copy spans
		nLen = len(@aSpans)
		for i = 1 to nLen
			oCopy.AddSpan(@aSpans[i][1], @aSpans[i][2], @aSpans[i][3])
		next
		
		return oCopy
		
		def Clone()
			return This.Copy()
		
	  #-----------------------------------------#
	 #  Visual Display System for stzTimeLine  #
	#-----------------------------------------#
	
	# Configuration
	
	def SetVizWidth(n)
		@nVizWidth = max([30, n])
		return This
		
	def SetVizHeight(n)
		@nVizHeight = max([3, n])
		return This
		
	def VizWidth()
		return @nVizWidth
		
	def VizHeight()
		return @nVizHeight
	
	# Canvas Operations
	
	def _initVizCanvas(nWidth, nHeight)
		@acVizCanvas = []
		for i = 1 to nHeight
			aRow = []
			for j = 1 to nWidth
				aRow + " "
			next
			@acVizCanvas + aRow
		next
		
	def _setVizChar(nRow, nCol, cChar)
		if nRow >= 1 and nRow <= len(@acVizCanvas) and
		   nCol >= 1 and nCol <= len(@acVizCanvas[1])
			@acVizCanvas[nRow][nCol] = cChar
		ok
	
	def _setVizString(nRow, nCol, cStr)
		nLen = len(cStr)
		for i = 1 to nLen
			_setVizChar(nRow, nCol + i - 1, cStr[i])
		next
	
	# Layout Calculation
	
	def _calculateVizLayout()
		if not This.HasBoundaries()
			return NULL
		ok
		
		nTotalRows = 0
		
		# Calculate needed span rows
		nSpanRows = 0
		if len(@aSpans) > 0
			nSpanRows = min([@nVizHeight, len(@aSpans)])
		ok
		
		# Spans area (only if needed)
		nSpansStart = 0
		if nSpanRows > 0
			nSpansStart = nTotalRows + 1
			nTotalRows += nSpanRows
		ok
		
		# Labels row (above axis)
		nLabelsRow = nTotalRows + 1
		nTotalRows += 1
		
		# Axis row
		nAxisRow = nTotalRows + 1
		nTotalRows += 1
		
		# Numbers row
		nNumbersRow = nTotalRows + 1
		nTotalRows += 1
		
		return [
			:total_height = nTotalRows,
			:labels_row = nLabelsRow,
			:spans_start = nSpansStart,
			:span_rows = nSpanRows,
			:axis_row = nAxisRow,
			:numbers_row = nNumbersRow
		]
	
	# Position Mapping & Timepoint Collection
	
	def _timeToPosition(cDateTime)
		if not This.HasBoundaries()
			return 0
		ok
		
		oStart = This.StartQ()
		oEnd = This.EndQ()
		oTime = new stzDateTime(cDateTime)
		
		nTotalDuration = oStart.DurationTo(@cEnd, :InSeconds)
		if nTotalDuration = 0
			return 1
		ok
		
		nTimeDuration = oStart.DurationTo(cDateTime, :InSeconds)
		
		nCanvasWidth = len(@acVizCanvas[1])
		nPosition = ceil((nTimeDuration * (nCanvasWidth - 2)) / nTotalDuration) + 1
		
		return max([1, min([nPosition, nCanvasWidth])])
	
	def _collectAllTimepoints()
		# Returns: [[index, datetime, label, description, type], ...]
		aTimepoints = []
		nIndex = 0
		
		# Add start boundary
		aTimepoints + [nIndex, @cStart, "", "Timeline start", "boundary"]
		nIndex++
		
		# Collect all points and span boundaries
		aSorted = []
		
		# Add points
		nLen = len(@aPoints)
		for i = 1 to nLen
			aSorted + ["point", @aPoints[i][1], @aPoints[i][2], @aPoints[i][1]]
		next

		# Add span starts and ends
		nLen = len(@aSpans)
		for i = 1 to nLen
			aSorted + ["span_start", @aSpans[i][1], @aSpans[i][2], @aSpans[i][1]]
			aSorted + ["span_end", @aSpans[i][1], @aSpans[i][3], @aSpans[i][1]]
		next
		
		# Sort by datetime
		aSorted = This._sortTimepointsByDate(aSorted)
		
		# Add to timepoints with indices
		nLen = len(aSorted)
		for i = 1 to nLen
			cType = aSorted[i][1]
			cLabel = aSorted[i][2]
			cDateTime = aSorted[i][3]
			cOrigName = aSorted[i][4]
			
			cDesc = ""
			switch cType
			on "point"
				cDesc = cOrigName + " event"
			on "span_start"
				cDesc = "Start of " + cOrigName
			on "span_end"
				cDesc = "End of " + cOrigName
			off
			
			aTimepoints + [nIndex, cDateTime, cLabel, cDesc, cType]
			nIndex++
		next
		
		# Add end boundary
		aTimepoints + [nIndex, @cEnd, '', "Timeline end", "boundary"]

		#TODO// The fellowing two lines are workaround, don't let them to be added at the first place
		del(aTimePoints, 1)
		del(aTimePoints, len(aTimePoints))

		return aTimepoints
	
	def _sortTimepointsByDate(aItems)
		# Simple bubble sort by datetime (3rd element)
		nLen = len(aItems)
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				oDate1 = new stzDateTime(aItems[j][3])
				oDate2 = new stzDateTime(aItems[j + 1][3])
				
				if oDate1.IsAfter(oDate2)
					temp = aItems[j]
					aItems[j] = aItems[j + 1]
					aItems[j + 1] = temp
				ok
			next
		next
		return aItems
	
	# Drawing Methods
	
	def _drawAxis(oLayout)
		nRow = oLayout[:axis_row]
		nCanvasWidth = len(@acVizCanvas[1])
		
		# Draw main axis line
		for i = 1 to nCanvasWidth - 2
			_setVizChar(nRow, i, @cAxisChar)
		next
		
		# Add spacing before arrow
		_setVizChar(nRow, nCanvasWidth - 1, @cAxisChar)
		
		# Draw start marker and end arrow
		_setVizChar(nRow, 1, @cTickChar)
		_setVizChar(nRow, nCanvasWidth, @cArrowChar)
	
	def _drawLabels(oLayout, aTimepoints)
		nRow = oLayout[:labels_row]
		
		# Collect positions and labels for points only
		aLabelsToPlace = []
		nLen = len(aTimepoints)

		for i = 1 to nLen
			cType = aTimepoints[i][5]
			cLabel = aTimepoints[i][3]
			
			if (cType = "point" or cType = "boundary") and cLabel != ""
				cDateTime = aTimepoints[i][2]
				nPos = _timeToPosition(cDateTime)
				aLabelsToPlace + [nPos, cLabel]
			ok
		next
		
		# Check for collisions and place labels
		aPlaced = []
		nLen = len(aLabelsToPlace)

		for i = 1 to nLen

			nPos = aLabelsToPlace[i][1]
			cLabel = aLabelsToPlace[i][2]
			nLabelLen = len(cLabel)
			
			# Calculate label span (centered on position)
			nLabelStart = max([1, nPos - floor(nLabelLen / 2)])
			nLabelEnd = nLabelStart + nLabelLen - 1
			
			# Check for collision with already placed labels
			bCollides = FALSE
			nLenJ = len(aPlaced)

			for j = 1 to nLenJ
				nPlacedStart = aPlaced[j][1]
				nPlacedEnd = aPlaced[j][2]
				
				# Check overlap
				if not (nLabelEnd < nPlacedStart or nLabelStart > nPlacedEnd)
					bCollides = TRUE
					exit
				ok
			next
			
			# Place label if no collision
			if not bCollides
				_setVizString(nRow, nLabelStart, cLabel)
				aPlaced + [nLabelStart, nLabelEnd]
			ok
		next
	
	def _drawNumbers(oLayout, aTimepoints)
		nRow = oLayout[:numbers_row]
		nLen = len(aTimepoints)

		for i = 1 to nLen
			nIndex = aTimepoints[i][1]
			cDateTime = aTimepoints[i][2]
			nPos = _timeToPosition(cDateTime)
			
			cNum = "" + nIndex
			nNumLen = len(cNum)
			
			# Center the number at position
			nStartCol = max([1, nPos - floor(nNumLen / 2)])
			_setVizString(nRow, nStartCol, cNum)
		next
	
	def _drawPoints(oLayout, aTimepoints)
		nAxisRow = oLayout[:axis_row]
		nLen = len(aTimepoints)

		for i = 1 to nLen
			cType = aTimepoints[i][5]
			if cType = "point" or cType = "boundary"
				cDateTime = aTimepoints[i][2]
				nPos = _timeToPosition(cDateTime)
				
				bHighlighted = FALSE
				if @cHighlight != NULL and aTimepoints[i][3] = @cHighlight
					bHighlighted = TRUE
				ok
				
				cChar = iff(bHighlighted, @cHighlightChar, @cPointChar)
				_setVizChar(nAxisRow, nPos, cChar)
			ok
		next

	def _drawSpans(oLayout, aTimepoints)
		nAxisRow = oLayout[:axis_row]
		
		# Group span starts and ends
		aSpanRanges = []
		nLen = len(@aSpans)

		for i = 1 to nLen
			cName = @aSpans[i][1]
			cStart = @aSpans[i][2]
			cEnd = @aSpans[i][3]
			
			nStartPos = _timeToPosition(cStart)
			nEndPos = _timeToPosition(cEnd)
			
			bHighlighted = (@cHighlight != NULL and @cHighlight = cName)
			
			aSpanRanges + [cName, nStartPos, nEndPos, bHighlighted]
		next
		
		# Draw spans with vertical offset
		aRowUsed = []
		for i = 1 to @nVizHeight
			aRowUsed + []
		next

		nLen = len(aSpanRanges)
		for i = 1 to nLen
			cName = aSpanRanges[i][1]
			nStartPos = aSpanRanges[i][2]
			nEndPos = aSpanRanges[i][3]
			bHighlighted = aSpanRanges[i][4]
			
			nRow = _findAvailableRow(oLayout, nStartPos, nEndPos, aRowUsed)
			_drawSpanBar(nRow, nStartPos, nEndPos, cName, bHighlighted)
			
			# Mark span boundaries on axis with dots
			_setVizChar(nAxisRow, nStartPos, @cPointChar)
			_setVizChar(nAxisRow, nEndPos, @cPointChar)
		next

	def _findAvailableRow(oLayout, nStartPos, nEndPos, aRowUsed)
		nAxisRow = oLayout[:axis_row]
		nSpanRows = oLayout[:span_rows]
		
		for nOffset = 1 to nSpanRows
			nRow = nAxisRow - nOffset
			
			bFree = TRUE
			for nPos = nStartPos to nEndPos
				if find(aRowUsed[nOffset], nPos) > 0
					bFree = FALSE
					exit
				ok
			next
			
			if bFree
				for nPos = nStartPos to nEndPos
					aRowUsed[nOffset] + nPos
				next
				return nRow
			ok
		next
		
		return nAxisRow - 1
	
	def _drawSpanBar(nRow, nStartPos, nEndPos, cLabel, bHighlighted)
		cBarChar = iff(bHighlighted, @cHighlightChar, @cSpanChar)
		
		_setVizChar(nRow, nStartPos, @cSpanStartChar)
		
		# Draw label in the middle of span
		nSpanWidth = nEndPos - nStartPos + 1
		nLabelLen = len(cLabel)
		
		if nLabelLen <= nSpanWidth - 2
			nLabelStart = nStartPos + floor((nSpanWidth - nLabelLen) / 2)
			
			# Draw bar before label
			for i = nStartPos + 1 to nLabelStart - 1
				_setVizChar(nRow, i, cBarChar)
			next
			
			# Draw label
			_setVizString(nRow, nLabelStart, cLabel)
			
			# Draw bar after label
			for i = nLabelStart + nLabelLen to nEndPos - 1
				_setVizChar(nRow, i, cBarChar)
			next
		else
			# Label doesn't fit, just draw bar
			for i = nStartPos + 1 to nEndPos - 1
				_setVizChar(nRow, i, cBarChar)
			next
		ok
		
		if nEndPos > nStartPos
			_setVizChar(nRow, nEndPos, @cSpanEndChar)
		ok
	
	# Canvas to String
	
	def _vizCanvasToString()
		cResult = ""
		nRows = len(@acVizCanvas)
		
		for i = 1 to nRows
			cLine = ""
			nLen = len(@acVizCanvas[i])
			for j = 1 to nLen
				cLine += @acVizCanvas[i][j]
			next
			
			if i < nRows
				cResult += cLine + nl
			else
				cResult += cLine
			ok
		next
		
		return cResult
	
	def _buildTimepointsTable(aTimepoints)
		# Build table data as nested array
		aTableData = [
			[:NO, :TIMEPOINT, :LABEL, :DESCRIPTION]
		]

		nLen = len(aTimepoints)
		for i = 1 to nLen
			nIndex = aTimepoints[i][1]
			cDateTime = aTimepoints[i][2]
			cLabel = aTimepoints[i][3]
			cDesc = aTimepoints[i][4]
			
			aTableData + ["" + nIndex, cDateTime, cLabel, cDesc]
		next
		
		# Create and return table string
		oTable = new stzTable(aTableData)
		return oTable.ToString()
	
	# Main Display Methods
	
	def ShowUncovered() #TODO
		raise("Not yet implemented!")

	def Show()
		? This.ToString()
		
	def ToString()
		return This.ToStringXT([])
		
	def ToStringXT(paParams)
		nRequestedWidth = @nVizWidth
		
		# Process parameters
		if isList(paParams)
			nLen = len(paParams)

			for i = 1 to nLen

				if isList(paParams[i]) and len(paParams[i]) = 2
					switch paParams[i][1]
					on :Width
						nRequestedWidth = max([30, paParams[i][2]])

					on :Height
						@nVizHeight = max([3, paParams[i][2]])

					on :Highlight
						@cHighlight = paParams[i][2]
					off
				ok
			next
		ok
		
		if not This.HasBoundaries()
			return "Timeline has no boundaries set"
		ok
		
		# Collect all timepoints
		aTimepoints = _collectAllTimepoints()
		
		# Calculate layout
		oLayout = _calculateVizLayout()
		if oLayout = NULL
			return "Cannot display timeline"
		ok
		
		# Initialize canvas
		_initVizCanvas(nRequestedWidth, oLayout[:total_height])
		
		# Draw visual elements
		_drawAxis(oLayout)
		_drawSpans(oLayout, aTimepoints)
		_drawPoints(oLayout, aTimepoints)
		_drawLabels(oLayout, aTimepoints)
		_drawNumbers(oLayout, aTimepoints)
		
		# Build output
		cViz = _vizCanvasToString()
		cTable = _buildTimepointsTable(aTimepoints)
		
		return cViz + nl + nl + cTable
	
	# Highlight Visualization Methods
	
	def VizFindMoments(cName)
		@cHighlight = cName
		cResult = This.ToString()
		@cHighlight = NULL
		return cResult
		
		def VizFindMoment(cName)
			return This.VizFindMoments(cName)
			
		def VizFindPoint(cName)
			return This.VizFindMoments(cName)
			
		def VizFindPoints(cName)
			return This.VizFindMoments(cName)
			
	def VizFindSpans(cName)
		@cHighlight = cName
		cResult = This.ToString()
		@cHighlight = NULL
		return cResult
		
		def VizFindSpan(cName)
			return This.VizFindSpans(cName)
			
		def VizFindPeriod(cName)
			return This.VizFindSpans(cName)
			
		def VizFindPeriods(cName)
			return This.VizFindSpans(cName)
