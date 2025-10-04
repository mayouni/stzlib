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
			return This.StartQ().DurationTo(@cEnd)
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

	def Points()
		return @aPoints
		
		def PointsQ()
			aResult = []
			for aPoint in @aPoints
				aResult + [aPoint[1], new stzDateTime(aPoint[2])]
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
		for aPoint in @aPoints
			acResult + aPoint[1]
		next
		return acResult
		
	def Point(cName)
		for aPoint in @aPoints
			if aPoint[1] = cName
				return aPoint[2]
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
			for aSpan in @aSpans
				aResult + [
					aSpan[1],
					new stzDateTime(aSpan[2]),
					new stzDateTime(aSpan[3])
				]
			next
			return aResult
		
		def Periods()
			return This.Spans()

		def PeriodsQ()
			return This.SpansQ()
			
	def SpanNames()
		acResult = []
		for aSpan in @aSpans
			acResult + aSpan[1]
		next
		return acResult
		
		def PeriodNames()
			return This.SpanNames()
			
	def Span(cName)
		for aSpan in @aSpans
			if aSpan[1] = cName
				return [aSpan[2], aSpan[3]]
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
			return This.SpanStartQ(cName).DurationTo(aSpan[2])
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
		for aPoint in @aPoints
			if StzDateTimeQ(aPoint[2]).IsEqualTo(oDateTime)
				aResult + [:Point, aPoint[1]]
			ok
		next
		
		# Check spans containing this time
		for aSpan in @aSpans
			oStart = new stzDateTime(aSpan[2])
			oEnd = new stzDateTime(aSpan[3])
			if oDateTime >= oStart and oDateTime <= oEnd
				aResult + [:Span, aSpan[1]]
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
		for aPoint in @aPoints
			oPoint = new stzDateTime(aPoint[2])
			if oPoint >= oStart and oPoint <= oEnd
				aResult + aPoint[1]
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
		for aSpan in @aSpans
			oSpanStart = new stzDateTime(aSpan[2])
			oSpanEnd = new stzDateTime(aSpan[3])
			# Include spans that overlap with the range
			if oSpanEnd >= oStart and oSpanStart <= oEnd
				aResult + aSpan[1]
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
		for aSpan in @aSpans
			oStart = new stzDateTime(aSpan[2])
			oEnd = new stzDateTime(aSpan[3])
			if oDateTime >= oStart and oDateTime <= oEnd
				aResult + aSpan[1]
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
					
					nDuration = oOverlapStart.DurationTo(oOverlapEnd)
					
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
				nDuration = oEnd1.DurationTo(oStart2)
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
			nDuration = oStart.DurationTo(oFirstStart)
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
				nDuration = oEnd1.DurationTo(oStart2)
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
			nDuration = oLastEnd.DurationTo(oEnd)
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
			return StzDateTimeQ(cTime1).DurationTo(cTime2)
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
			aResult + [
				:Start = @cStart,
				:End = @cEnd,
				:TotalDuration = This.DurationQ().ToHuman()
			]
		ok
		
		# Add counts
		aResult + [
			:CountPoints = This.CountPoints(),
			:CountSpans = This.CountSpans()
		]
		
		# Add sorted points
		if len(@aPoints) > 0
			aPoints = []
			aSorted = This.SortedPoints()
			for aPoint in aSorted
				aPoints + [
					:Name = aPoint[1],
					:DateTime = aPoint[2]
				]
			next
			aResult + [ :Points = aPoints ]
		ok
		
		# Add sorted spans with durations
		if len(@aSpans) > 0
			aSpans = []
			aSorted = This.SortedSpans()
			for aSpan in aSorted
				oStart = new stzDateTime(aSpan[2])
				oDuration = oStart.DurationToQ(aSpan[3])
				aSpans + [
					:Name = aSpan[1],
					:Start = aSpan[2],
					:End = aSpan[3],
					:Duration = oDuration.ToHuman()
				]
			next
			aResult + [ :Spans = aSpans ]
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
		for aPoint in @aPoints
			oCopy.AddPoint(aPoint[1], aPoint[2])
		next
		
		# Copy spans
		for aSpan in @aSpans
			oCopy.AddSpan(aSpan[1], aSpan[2], aSpan[3])
		next
		
		return oCopy
		
		def Clone()
			return This.Copy()


	# Visual Display Methods
	
	def Show()
		return This.ShowXT([])
		
	def ShowXT(paParams)
		# Parameters: :Width, :Highlight, :ShowDates, :Compact
		nWidth = 80
		cHighlight = NULL
		bShowDates = TRUE
		bCompact = FALSE
		
		if isList(paParams)
			for aParam in paParams
				if isList(aParam) and len(aParam) = 2
					switch aParam[1]
					on :Width
						nWidth = aParam[2]
					on :Highlight
						cHighlight = aParam[2]
					on :ShowDates
						bShowDates = aParam[2]
					on :Compact
						bCompact = aParam[2]
					off
				ok
			next
		ok
		
		cResult = ""
		
		# Header
		if This.HasBoundaries()
			cResult += "Timeline: " + @cStart + " to " + @cEnd + NL
			if This.Duration() != NULL
				cResult += "Duration: " + This.DurationQ().ToHuman() + NL
			ok
		else
			cResult += "Timeline (unbounded)" + NL
		ok
		
		cResult += ring_copy("=", nWidth) + NL + NL
		
		# Calculate timeline range
		oStart = NULL
		oEnd = NULL
		
		if This.HasBoundaries()
			oStart = This.StartQ()
			oEnd = This.EndQ()
		else
			# Find min/max from points and spans
			aAllTimes = []
			for aPoint in @aPoints
				aAllTimes + new stzDateTime(aPoint[2])
			next
			for aSpan in @aSpans
				aAllTimes + new stzDateTime(aSpan[2])
				aAllTimes + new stzDateTime(aSpan[3])
			next
			
			if len(aAllTimes) > 0
				oStart = aAllTimes[1]
				oEnd = aAllTimes[1]
				for oTime in aAllTimes
					if oTime < oStart
						oStart = oTime
					ok
					if oTime > oEnd
						oEnd = oTime
					ok
				next
			ok
		ok
		
		if oStart = NULL or oEnd = NULL
			return cResult + "No timeline data to display" + NL
		ok
		
		nTotalDuration = oStart.DurationTo(oEnd)
		if nTotalDuration = 0
			nTotalDuration = 1  # Avoid division by zero
		ok
		
		# Build timeline visualization
		nTimelineWidth = nWidth - 20  # Reserve space for labels
		
		# Draw timeline bar
		cResult += "    |" + ring_copy("-", nTimelineWidth) + "|" + NL
		
		if bShowDates
			cResult += "    " + oStart.ToString() + ring_copy(" ", nTimelineWidth - len(oStart.ToString()) - len(oEnd.ToString())) + oEnd.ToString() + NL + NL
		ok
		
		# Display spans
		if len(@aSpans) > 0
			cResult += "Spans:" + NL
			aSorted = This.SortedSpans()
			
			for aSpan in aSorted
				cName = aSpan[1]
				oSpanStart = new stzDateTime(aSpan[2])
				oSpanEnd = new stzDateTime(aSpan[3])
				
				# Calculate position on timeline
				nStartOffset = oStart.DurationTo(oSpanStart)
				nEndOffset = oStart.DurationTo(oSpanEnd)
				
				nStartPos = floor((nStartOffset / nTotalDuration) * nTimelineWidth)
				nEndPos = floor((nEndOffset / nTotalDuration) * nTimelineWidth)
				nLength = nEndPos - nStartPos
				if nLength < 1
					nLength = 1
				ok
				
				# Highlight if requested
				cBar = "="
				if cHighlight != NULL and cName = cHighlight
					cBar = "#"
				ok
				
				cLine = "    |" + ring_copy(" ", nStartPos) + ring_copy(cBar, nLength) + ring_copy(" ", nTimelineWidth - nStartPos - nLength) + "| " + cName
				
				if not bCompact
					oDuration = oSpanStart.DurationToQ(oSpanEnd)
					cLine += " (" + oDuration.ToHuman() + ")"
				ok
				
				cResult += cLine + NL
			next
			cResult += NL
		ok
		
		# Display points
		if len(@aPoints) > 0
			cResult += "Points:" + NL
			aSorted = This.SortedPoints()
			
			for aPoint in aSorted
				cName = aPoint[1]
				oPointTime = new stzDateTime(aPoint[2])
				
				# Calculate position on timeline - FIX HERE
				nOffsetResult = oStart.DurationTo(oPointTime)
				nOffset = 0
				if isNumber(nOffsetResult)
				    nOffset = nOffsetResult
				but isList(nOffsetResult)
				    # If it's a hashlist, extract total seconds
				    nOffset = (nOffsetResult[:days] * 86400) + 
				              (nOffsetResult[:hours] * 3600) + 
				              (nOffsetResult[:minutes] * 60) + 
				              nOffsetResult[:seconds]
				ok
	
				if nOffset >= 0 and nTotalDuration > 0
					nPos = floor((nOffset / nTotalDuration) * nTimelineWidth)
					
					# Highlight if requested
					cMarker = "*"
					if cHighlight != NULL and cName = cHighlight
						cMarker = "X"
					ok
					
					cLine = "    |" + ring_copy(" ", nPos) + cMarker + ring_copy(" ", nTimelineWidth - nPos - 1) + "| " + cName
					
					if not bCompact and bShowDates
						cLine += " (" + aPoint[2] + ")"
					ok
					
					cResult += cLine + NL
				ok
			next
		ok
		
		return cResult
		
	def VizFindMoments(cName)
		return This.ShowXT([ [:Highlight, cName] ])
		
		def VizFindMoment(cName)
			return This.VizFindMoments(cName)
			
		def VizFindPoint(cName)
			return This.VizFindMoments(cName)
			
		def VizFindPoints(cName)
			return This.VizFindMoments(cName)
			
	def VizFindSpans(cName)
		return This.ShowXT([ [:Highlight, cName] ])
		
		def VizFindSpan(cName)
			return This.VizFindSpans(cName)
			
		def VizFindPeriod(cName)
			return This.VizFindSpans(cName)
			
		def VizFindPeriods(cName)
			return This.VizFindSpans(cName)
