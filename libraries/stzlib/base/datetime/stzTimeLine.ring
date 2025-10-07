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

func IsStzDateTime(p)
	if isObject(p) and classname(p) = "stzdatetime"
		return 1
	else
		return 0
	ok

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
	@cUncoveredChar = "/"
	@bShowDates = TRUE
	@bShowLabels = TRUE
	@cHighlight = NULL

	# Layout
	@nLabelHeight = 1
	@nAxisRow = 0
	@nDateRow = 0
	@acVizCanvas = []

	def init(pStart, pEnd)

		if CheckParams()
			if isList(pStart) and StzListQ(pStart).IsStartOrFromNamedParam()
				pStart = pStart[2]
			ok
			if isList(pEnd) and StzListQ(pEnd).IsEndOrToNamedParam()
				pEnd = pEnd[2]
			ok
		ok

		if isString(pStart)
			pStart = trim(pStart)
			if This._IsDateOnly(pStart)
				pStart += " 00:00:00"

			but This._IsTimeOnly(pStart)
				StzRaise("Invalid input in pStart! Time specified without a date.")
			ok
		ok

		if isString(pEnd)
			pEnd = trim(pEnd)
			if This._IsDateOnly(pEnd)
				pStart += " 00:00:00"

			but This._IsTimeOnly(pEnd)
				StzRaise("Invalid input in pEnd! Time specified without a date.")
			ok
		ok

		@cStart = StzDateTimeQ(pStart).ToString()
		@cEnd = StzDateTimeQ(pEnd).ToString()

	def Content()
		aResult = [
			:Start = @cStart,
			:End = @cEnd,

			:Points = @aPoints,
			:Spans = @aSpans
		]

		return aResult

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

		def EndDate()
			return This.End_()

		def EndDateQ()
			return This.EndQ()

		def Endd()
			return This.End_()

	def SetStart(p)
		@cStart = This._normalizeDateTime(p)
	
		def SetStartQ(p)
			This.SetStart(p)
			return This
	
	def SetEnd(p)
		@cEnd = This._normalizeDateTime(p)
	
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
		cPoint = This._normalizeDateTime(pDateTime)
	
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

	# Find the occurences of a given moment (by lable)
	# on the timeline (returns its relative datetimes)
	def FindPoint(pcPoint)
		acResult = []
		nLen = len(@aPoints)

		for i = 1 to nLen
			if lower(@aPoints[i][1]) = lower(pcPoint)
				acResult + @aPoints[i][2]
			ok
		next

		return acResult

		def FindMoment(pcPoint)
			return This.FindPoint(pcPoint)

	# Returns the positions along with the datetimes
	def FindPointXT(pcPoint)
		aResult = []
		nLen = len(@aPoints)

		for i = 1 to nLen
			if lower(@aPoints[i][1]) = lower(pcPoint)
				aResult + [ ""+i, @aPoints[i][2] ]
			ok
		next

		return aResult

		def FindMomentXT(pcPoint)
			return This.FindPointXT(pcPoint)

	#--

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
		# Return unique names only
		acResult = []
		acSeen = []
		nLen = len(@aPoints)

		for i = 1 to nLen
			cName = @aPoints[i][1]
			if ring_find(acSeen, cName) = 0
				acResult + cName
				acSeen + cName
			ok
		next
	
		return acResult

	def PointNamesXT()
		# Return names with occurrence counts: [["EVENT1", 3], ["EVENT2", 1]]
		aResult = []
		aCounts = []
	
		nLen = len(@aPoints)
		for i = 1 to nLen
			cName = @aPoints[i][1]
			nPos = 0
	
			# Find if name already counted
			for j = 1 to len(aCounts)
				if aCounts[j][1] = cName
					nPos = j
					exit
				ok
			next
	
			if nPos = 0
				aCounts + [cName, 1]
			else
				aCounts[nPos][2]++
			ok
		next
	
		return aCounts

	def SpanNames()
		# Return unique names only
		acResult = []
		acSeen = []
		nLen = len(@aSpans)
		for i = 1 to nLen
			cName = @aSpans[i][1]
			if find(acSeen, cName) = 0
				acResult + cName
				acSeen + cName
			ok
		next
		return acResult

		def PeriodNames()
	        return This.SpanNames()

	def SpanNamesXT()
		# Return names with occurrence counts: [["PHASE1", 2], ["PHASE2", 1]]
		aResult = []
		aCounts = []
	
		nLen = len(@aSpans)
		for i = 1 to nLen
			cName = @aSpans[i][1]
			nPos = 0
	
			# Find if name already counted
			for j = 1 to len(aCounts)
				if aCounts[j][1] = cName
					nPos = j
					exit
				ok
			next
	
			if nPos = 0
				aCounts + [cName, 1]
			else
				aCounts[nPos][2]++
			ok
		next
	
		return aCounts
    
	    def PeriodNamesXT()
	        return This.SpanNamesXT()

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

		def AddPeriods(paSpans)
			This.AddSpans(paSpans)

	def AddSpan(cName, pStart, pEnd)
		cStart = This._normalizeDateTime(pStart)
		cEnd = This._normalizeDateTime(pEnd)
	
		# Validate span: start must be strictly before end
		oStart = new stzDateTime(cStart)
		oEnd = new stzDateTime(cEnd)
		if oStart >= oEnd
			raise("Error: Span '" + cName + "' has invalid dates. Start time (" + 
				cStart + ") must be before end time (" + cEnd + ")")
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


	# Find the occurences of a given Period (by lable)
	# on the timeline (returns its relative datetimes)
	def FindSpan(pcSpan)
		acResult = []
		nLen = len(@aSpans)

		for i = 1 to nLen
			if lower(@aSpans[i][1]) = lower(pcSpan)
				acResult + [ @aSpans[i][2], @aSpans[i][3] ]
			ok
		next

		return acResult

		def FindPeriod(pcSpan)
			return This.FindSpan(pcSpan)

	# Returns the positions along with the datetimes
	def FindSpanXT(pcSpan)
		aResult = []
		nLen = len(@aSpans)

		for i = 1 to nLen
			if lower(@aSpans[i][1]) = lower(pcSpan)
				aResult + [ ""+i, [ @aSpans[i][2], @aSpans[i][3] ] ]
			ok
		next

		return aResult

		def FindPeriodXT(pcSpan)
			return This.FindSpanXT(pcSpan)

	
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
			cDateTime = StzDateTimeQ(pDateTime).ToString()
		ok
	
		# Detect search mode
		bDateOnly = This._isDateOnly(cDateTime)
		bTimeOnly = This._isTimeOnly(cDateTime)

		aResult = []
	
		if bDateOnly
			# Match all times on this date
			oDate = new stzDate(cDateTime)
			nLen = len(@aPoints)
			for i = 1 to nLen
				if left(@aPoints[i][2], 10) = cDateTime
					aResult + [@aPoints[i][1], :Point]
				ok
			next
	
			nLen = len(@aSpans)
			for i = 1 to nLen
				oSpanStart = new stzDate(left(@aSpans[i][2], 10))
				oSpanEnd = new stzDate(left(@aSpans[i][3], 10))
				if oDate >= oSpanStart and oDate <= oSpanEnd
					aResult + [@aSpans[i][1], :Span]
				ok
			next
	
		but bTimeOnly
			# Match this time on all dates
			cTime = cDateTime
			nLen = len(@aPoints)
			for i = 1 to nLen
				if right(@aPoints[i][2], 8) = cTime
					aResult + [@aPoints[i][1], :Point]
				ok
			next
	
			nLen = len(@aSpans)
			for i = 1 to nLen
				oTime = new stzTime(cTime)
				oStart = new stzTime(@aSpans[i][2])
				oEnd = new stzTime(@aSpans[i][3])
	
				# Check if time falls within span's time range

				oSpanStartTime = new stzTime(right(@aSpans[i][2], 8))
				oSpanEndTime = new stzTime(right(@aSpans[i][3], 8))
	
				if oTime >= oSpanStartTime or oTime <= oSpanEndTime
					aResult + [@aSpans[i][1], :Span]
				ok
			next
	        
		else
			# Exact datetime match
			oDateTime = new stzDateTime(cDateTime)
	
			nLen = len(@aPoints)
			for i = 1 to nLen
				if StzDateTimeQ(@aPoints[i][2]).IsEqualTo(oDateTime)
					aResult + [@aPoints[i][1], :Point]
				ok
			next
	
			nLen = len(@aSpans)
			for i = 1 to nLen
				oStart = new stzDateTime(@aSpans[i][2])
				oEnd = new stzDateTime(@aSpans[i][3])
				if oDateTime >= oStart and oDateTime <= oEnd
					aResult + [@aSpans[i][1], :Span]
				ok
			next
		ok
	
		return aResult

	def WhatsAtXT(pDateTime, pMode)
		# Explicit mode control: :DateOnly, :TimeOnly, or :Exact
		cDateTime = NULL
		if isString(pDateTime)
			cDateTime = pDateTime
		else
			cDateTime = StzDateTimeQ(pDateTime).ToString()
		ok
	
		cMode = :Exact
		if isList(pMode) and len(pMode) = 2
			cMode = pMode[2]
		ok
	
		aResult = []
	
		switch cMode
		on :DateOnly
			cDate = left(cDateTime, 10)
			nLen = len(@aPoints)
			for i = 1 to nLen
				if left(@aPoints[i][2], 10) = cDate
					aResult + [@aPoints[i][1], :Point]
				ok
			next
	
			nLen = len(@aSpans)
			for i = 1 to nLen
				cSpanStart = left(@aSpans[i][2], 10)
				cSpanEnd = left(@aSpans[i][3], 10)
				if cDate >= cSpanStart and cDate <= cSpanEnd
					aResult + [@aSpans[i][1], :Span]
				ok
			next
	
		on :TimeOnly
			cTime = right(cDateTime, 8)
			nLen = len(@aPoints)
			for i = 1 to nLen
				if right(@aPoints[i][2], 8) = cTime
					aResult + [@aPoints[i][1], :Point]
				ok
			next
	        
			nLen = len(@aSpans)
			for i = 1 to nLen
				cSpanStartTime = right(@aSpans[i][2], 8)
				cSpanEndTime = right(@aSpans[i][3], 8)
				if cTime >= cSpanStartTime or cTime <= cSpanEndTime
					aResult + [@aSpans[i][1], :Span]
				ok
			next
	
		other
			return This.WhatsAt(cDateTime)
		off
	
		return aResult

		#< @FunctionAlternativeForms

		def HappeningAt(pDateTime)
			return This.WhatsAt(pDateTime)
			
		def WhatHappenedAt(pDateTime)
			return This.WhatsAt(pDateTime)

		def PointsAt(pDateTime)
			return This.WhatsAt(pDateTime)

		def MomentsAt(pDateTime)
			return This.WhatsAt(pDateTime)
		#>

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
			cStart = StzDateTimeQ(pStart).ToString()
		ok
		if isString(pEnd)
			cEnd = pEnd
		else
			cEnd = StzDateTimeQ(pEnd).ToString()
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
			cStart = StzDateTimeQ(pStart).ToString()
		ok
		if isString(pEnd)
			cEnd = pEnd
		else
			cEnd = StzDateTimeQ(pEnd).ToString()
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
			cDateTime = StzDateTimeQ(pDateTime).ToString()
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
	

	# Main Display Methods

	def ShowXT(paOptions)
		? This.ToStringXT(paOptions)

	def Show()
		? This.ToString()
		
	def ToString()
		return This.ToStringXT([])
		
	def ToStringXT(paParams)
		nRequestedWidth = @nVizWidth
		bShowTable = TRUE
		cTableType = :Normal
	
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
	
					on :ShowTable
						bShowTable = paParams[i][2]
	
					on :TableType
						cTableType = paParams[i][2]
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
		if oLayout = ""
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
	
		if not bShowTable
			return cViz
		ok
	
		# Add table based on type
		cTable = ""
		if cTableType = :Statistical
			cTable = StzTableQ(_buildStatisticalTable()).ToString()
		else
			cTable = _buildTimepointsTable(aTimepoints)
		ok
	
		return cViz + nl + nl + cTable
	
	def Stats()
		return _buildStatisticalTable()
	
	def ShowShort()
		? This.ToStringShort()
	
	def ToStringShort()
		if not This.HasBoundaries()
			return "Timeline has no boundaries set"
		ok
	
		# Collect timepoints
		aTimepoints = _collectAllTimepoints()
	
		# Calculate layout
		oLayout = _calculateVizLayout()
		if oLayout = NULL
			return "Cannot display timeline"
		ok
	
		# Initialize canvas
		_initVizCanvas(@nVizWidth, oLayout[:total_height])
	
		# Draw visual elements
		_drawAxis(oLayout)
		_drawSpans(oLayout, aTimepoints)
		_drawPoints(oLayout, aTimepoints)
		_drawLabels(oLayout, aTimepoints)
		_drawNumbers(oLayout, aTimepoints)
	
		# Return only canvas (no table)
		return _vizCanvasToString()



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


	# Hihlighting the uncovered spans in the timeline

	def ShowUncovered()
	    ? This.ToStringUncovered()
	
def ToStringUncovered()
    if not This.HasBoundaries()
        return "Timeline has no boundaries set"
    ok
    
    # Get uncovered periods
    aUncovered = This.UncoveredPeriods()
    if len(aUncovered) = 0
        return "Timeline is fully covered by spans"
    ok
    
    # Collect timepoints (without boundaries)
    aTimepoints = _collectAllTimepoints()
    
    # Add uncovered regions
    nLen = len(aUncovered)
    for i = 1 to nLen
        aTimepoints + [0, aUncovered[i][:Start], "", "Uncovered region", "uncovered_start"]
        aTimepoints + [0, aUncovered[i][:End], "", "Uncovered region", "uncovered_end"]
    next
    
    # Sort by date
    aTimepoints = This._sortTimepointsByDate(aTimepoints)
    
    # Reassign sequential indices
    nLen = len(aTimepoints)
    for i = 1 to nLen
        aTimepoints[i][1] = i
    next
    
    # Calculate layout
    oLayout = _calculateVizLayout()
    if oLayout = NULL
        return "Cannot display timeline"
    ok
    
    # Initialize canvas
    _initVizCanvas(@nVizWidth, oLayout[:total_height])
    
    # Draw visual elements
    _drawAxis(oLayout)
    _drawSpans(oLayout, aTimepoints)
    _drawUncoveredRegions(oLayout, aUncovered)  # Draw uncovered BEFORE points
    _drawPoints(oLayout, aTimepoints)  # Points will overwrite uncovered chars
    _drawLabels(oLayout, aTimepoints)
    _drawNumbers(oLayout, aTimepoints)
    
    # Build output
    cViz = _vizCanvasToString()
    cTable = _buildTimepointsTable(aTimepoints)
    
    return cViz + nl + nl + cTable	

	PRIVATE

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

		# Calculate needed span rows dynamically
		nSpanRows = 0
		if len(@aSpans) > 0
			# Auto-calculate required height
			nRequiredHeight = This._calculateRequiredVizHeight()
			@nVizHeight = max([@nVizHeight, nRequiredHeight])
			nSpanRows = @nVizHeight - 3  # Reserve 3 rows for labels, axis, numbers
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

		return aTimepoints
	
	def _sortTimepointsByDate(aItems)	
		return @SortOn(aItems, 2)

	def _sortTimepointsByOrder(aItems)
		return @SortOn(aItems, 1)

	# Drawing Methods
	
def _drawAxis(oLayout)
    nRow = oLayout[:axis_row]
    nCanvasWidth = len(@acVizCanvas[1])
    
    # Draw main axis line
    for i = 2 to nCanvasWidth - 2
        _setVizChar(nRow, i, @cAxisChar)
    next
    
    # Draw start marker as vertical bar
    _setVizChar(nRow, 1, @cTickChar)
    
    # Add spacing before arrow
    _setVizChar(nRow, nCanvasWidth - 1, @cAxisChar)
    
    # Draw end arrow
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
	
		# Add highlighting for spans on axis
		if @cHighlight != NULL
			nLen = len(@aSpans)
			for i = 1 to nLen
				if @aSpans[i][1] = @cHighlight
					nStartPos = _timeToPosition(@aSpans[i][2])
					nEndPos = _timeToPosition(@aSpans[i][3])
	
					# Highlight axis between start and end
					for j = nStartPos to nEndPos
						_setVizChar(nAxisRow, j, @cHighlightChar)
					next
				ok
			next
		ok


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
		cBarChar = @cSpanChar  # Always use normal char for bar

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
	
	def _calculateRequiredVizHeight()
	    # Calculate maximum span overlap depth
	    if len(@aSpans) = 0
	        return 3  # Minimum height for axis, labels, numbers
	    ok
	    
	    # Sort spans by start time
	    aSorted = This.SortedSpans()
	    nLen = len(aSorted)
	    
	    # Track concurrent spans at each point
	    nMaxOverlap = 0
	    
	    for i = 1 to nLen
	        nConcurrent = 1
	        oStart1 = new stzDateTime(aSorted[i][2])
	        oEnd1 = new stzDateTime(aSorted[i][3])
	        
	        for j = 1 to nLen
	            if i != j
	                oStart2 = new stzDateTime(aSorted[j][2])
	                oEnd2 = new stzDateTime(aSorted[j][3])
	                
	                # Check if spans overlap
	                if oStart1 < oEnd2 and oStart2 < oEnd1
	                    nConcurrent++
	                ok
	            ok
	        next
	        
	        if nConcurrent > nMaxOverlap
	            nMaxOverlap = nConcurrent
	        ok
	    next
	    
	    # Return max overlap + 3 (for labels, axis, numbers rows)
	    return nMaxOverlap + 3


	def _buildStatisticalTable()
	    aStats = []
	    
	    # Total counts
	    aStats + ["Total Points", This.CountPoints()]
	    aStats + ["Total Spans", This.CountSpans()]
	    
	    # Timeline duration
	    if This.HasBoundaries()
	        oDuration = This.DurationQ()
	        if oDuration != ""
	            aStats + ["Timeline Duration", oDuration.ToHuman()]
	        ok
	    ok
	    
	    # Coverage calculation
	    if This.HasBoundaries() and len(@aSpans) > 0
	        nTotalDuration = This.Duration()
	        nCoveredDuration = 0
	        
	        # Sum all span durations (simplified - doesn't handle overlaps)
	        nLen = len(@aSpans)
	        for i = 1 to nLen
	            nCoveredDuration += This.SpanDuration(@aSpans[i][1])
	        next
	        
	        nCoveragePercent = (nCoveredDuration * 100.0) / nTotalDuration
	        aStats + ["Coverage", "" + floor(nCoveragePercent) + "%"]
	    ok
	    
	    # Longest span
	    if len(@aSpans) > 0
	        nMaxDuration = 0
	        cLongestSpan = ""
	        
	        nLen = len(@aSpans)
	        for i = 1 to nLen
	            nDuration = This.SpanDuration(@aSpans[i][1])
	            if nDuration > nMaxDuration
	                nMaxDuration = nDuration
	                cLongestSpan = @aSpans[i][1]
	            ok
	        next
	        
	        oDuration = new stzDuration(nMaxDuration)
	        aStats + ["Longest Span", cLongestSpan + " (" + oDuration.ToHuman() + ")"]
	    ok
	    
	    # Gaps count
	    aGaps = This.Gaps()
	    aStats + ["Gaps Between Spans", len(aGaps)]
	    
	    # Overlaps
	    aOverlaps = This.OverlappingSpans()
	    aStats + ["Overlapping Spans", len(aOverlaps)]
	    
	    # Build table
	    aTableData = [[:METRIC, :VALUE]]

	    nLen = len(aStats)
	    for i = 1 to nLen
	        aTableData + [ aStats[i][1], aStats[i][2] ]
	    next
	    
	    return aTableData	


def _drawUncoveredRegions(oLayout, aUncovered)
    nAxisRow = oLayout[:axis_row]
    nLen = len(aUncovered)
    
    # Collect span boundary positions to avoid
    aSpanPositions = []
    nLenSpans = len(@aSpans)
    for i = 1 to nLenSpans
        aSpanPositions + _timeToPosition(@aSpans[i][2])
        aSpanPositions + _timeToPosition(@aSpans[i][3])
    next
    
    for i = 1 to nLen
        cStart = aUncovered[i][:Start]
        cEnd = aUncovered[i][:End]
        
        nStartPos = _timeToPosition(cStart)
        nEndPos = _timeToPosition(cEnd)
        
        # Draw / pattern, skip span boundaries
        for j = nStartPos to nEndPos
            if find(aSpanPositions, j) = 0
                _setVizChar(nAxisRow, j, "/")
            ok
        next
    next

	def _isDateOnly(cDateTime)
		# Check if format is YYYY-MM-DD (no time component)
		if len(cDateTime) = 10 and substr(cDateTime, 5, 1) = "-" and substr(cDateTime, 8, 1) = "-"
			return TRUE
		ok
		return FALSE
	
	def _isTimeOnly(cDateTime)
		# Check if format is HH:MM:SS (no date component)
		if len(cDateTime) = 8 and substr(cDateTime, 3, 1) = ":" and substr(cDateTime, 6, 1) = ":"
			return TRUE
		ok
		return FALSE

	def _normalizeDateTime(pDateTime)
	    # Convert date-only input to full datetime by appending 00:00:00
	    cDateTime = NULL
	    
	    if isString(pDateTime)
	        cDateTime = pDateTime
	    else
	        cDateTime = new stzDateTime(pDateTime).ToString()
	    ok
	    
	    # Check if date-only format (YYYY-MM-DD)
	    if This._isDateOnly(cDateTime)
	        cDateTime += " 00:00:00"
	    ok
	    
	    return cDateTime

