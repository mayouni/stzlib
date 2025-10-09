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
	@nVizMinWidth = 30
	@nVizHeight = 5 # Will adjust autumatically to the required hight

	@cAxisChar = "─"
	@cPointChar = "●"
	@cMultiPointChar = "◉"
	@cBoundaryEndChar = "○"
	@cSpanChar = "="
	@cSpanStartChar = "╞"
	@cSpanEndChar = "╡"
	@cBoundaryStartChar = "|"
	@cHighlightChar = "█"
	@cArrowChar = "►"
	@cUncoveredChar = "/"
	@cBlockChar = "X"

	@bShowDates = TRUE
	@bShowLabels = TRUE
	@cHighlight = NULL

	# Layout
	@nLabelHeight = 1
	@nAxisRow = 0
	@nDateRow = 0
	@acVizCanvas = []

	@aBlockedSpans = []    # [[name, string_datetime_start, string_datetime_end], ...]
	@aBlockedPoints = []

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
			pStart = This._normalizeDateTime(pStart)

		ok

		if isString(pEnd)
			pEnd = This._normalizeDateTime(pEnd)
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
				
	def Duration()
		return This.StartQ().DurationTo(@cEnd, :InSeconds)

		def DurationQ()
			if This.Duration() != NULL
				return new stzDuration(This.Duration())
			ok
			return NULL

	# Point Management (single moments in time)
	
	def AddPoint(pcLabel, pDateTime)
	
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
	
		pcLabel = upper(pcLabel)
		cPoint = This._normalizeDateTime(pDateTime)
	
		oPoint = new stzDateTime(cPoint)
		oStart = This.StartQ()
		oEnd = This.EndQ()
	
		if oPoint < oStart or oPoint > oEnd
			raise("Point '" + pcLabel + "' is outside timeline boundaries")
		ok
	
		if This.IsBlocked(cPoint)
			raise("Point '" + pcLabel + "' falls within a blocked span or blocked point")
		ok
	
		@aPoints + [pcLabel, cPoint]
	
		def AddPointQ(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
			return This
		
		def AddTimePoint(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
			
			def AddTimePointQ(pcLabel, pDateTime)
				return This.AddPointQ(pcLabel, pDateTime)
	
		def AddMoment(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
	
			def AddMomentQ(pcLabel, pDateTime)
				return This.AddPointQ(pcLabel, pDateTime)

	def AddPoints(paPoints)
		nLen = len(paPoints)
		for i = 1 to nLen
			This.AddPoint(paPoints[i][1], paPoints[i][2])
		next

		def AddMoments(paPoints)
			This.AddPoints(paPoints)

	# Find the occurences of a given moment (by label)
	# on the timeline (returns its relative datetimes)
	def FindPoint(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		pcLabel = upper(pcLabel)

		#--

		acResult = []
		nLen = len(@aPoints)

		for i = 1 to nLen
			if @aPoints[i][1] = pcLabel
				acResult + @aPoints[i][2]
			ok
		next

		return acResult

		def FindMoment(pcLabel)
			return This.FindPoint(pcLabel)

	# Returns the datetime along with the position
	def FindPointXT(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		pcLabel = upper(pcLabel)

		#--

		aResult = []
		nLen = len(@aPoints)

		for i = 1 to nLen
			if @aPoints[i][1] = pcLabel
				aResult + [ @aPoints[i][2], i ]
			ok
		next

		return aResult

		def FindMomentXT(pcLabel)
			return This.FindPointXT(pcLabel)

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
			cLabel = @aPoints[i][1]
			if ring_find(acSeen, cLabel) = 0
				acResult + cLabel
				acSeen + cLabel
			ok
		next
	
		return acResult

	def PointNamesXT()
		# Return names with occurrence counts: [["EVENT1", 3], ["EVENT2", 1]]
		aResult = []
		aCounts = []
	
		nLen = len(@aPoints)
		for i = 1 to nLen
			cLabel = @aPoints[i][1]
			nPos = 0
	
			# Find if name already counted
			for j = 1 to len(aCounts)
				if aCounts[j][1] = cLabel
					nPos = j
					exit
				ok
			next
	
			if nPos = 0
				aCounts + [cLabel, 1]
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
			cLabel = @aSpans[i][1]
			if find(acSeen, cLabel) = 0
				acResult + cLabel
				acSeen + cLabel
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
			cLabel = @aSpans[i][1]
			nPos = 0
	
			# Find if name already counted
			for j = 1 to len(aCounts)
				if aCounts[j][1] = cLabel
					nPos = j
					exit
				ok
			next
	
			if nPos = 0
				aCounts + [cLabel, 1]
			else
				aCounts[nPos][2]++
			ok
		next
	
		return aCounts
    
	    def PeriodNamesXT()
	        return This.SpanNamesXT()

	# Getting a point datetime

	def Point(pcLabelOrDateTime)

		if NOT isString(pcLabelOrDateTime)
			StzRaise("Incorrect param type! pcLabelOrDateTime must be a string.")
		ok

		if IsDateTime(pcLabelOrDateTime) or
		   This._IsDateOnly(pcLabelOrDateTime) or
		   This._IsTimeOnly(pcLabelOrDateTime)

			return This.WhatsAt(pcLabelOrDateTime)
		ok

		#--

		cLabel = upper(pcLabelOrDateTime)

		nLen = len(@aPoints)
		for i = 1 to nLen
			if @aPoints[i][1] = cLabel
				return @aPoints[i][2] # A datetime string
			ok
		next
		
		StzRaise("No timepoint found with the label (" + cLabel + ")!")

		def PointQ(pcLabelOrDateTime)
			return StzDateTimeQ( This.Point(pcLabelOrDateTime) )

		def Moment(pcLabelOrDateTime)
			return This.Point(pcLabelOrDateTime)

			def MomentQ(pcLabelOrDateTime)
				return This.PointQ(pcLabelOrDateTime)

	# Checking if a point exists

	def HasPoint(pcLabelOrDateTime)
		if len(This.FindPoint(pcLabelOrDateTime)) > 0
			return 1
		else
			return 0
		ok
		
		def HasMoment(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

	# Removing points

	def RemovePoint(pcLabelOrDateTime)
		aPos = This.FindPointXT(pcLabelOrDateTime)
		if len(aPos) > 0
			del(@aPoints, anPos[1][2])
		ok

		def RemovePointQ(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)
			return This
		
		def RemoveMoment(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)

			def RemoveMomentQ(pcLabelOrDateTime)
				return This.RemovePointQ(pcLabelOrDateTime)


	# How many points

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

	def AddSpan(pcLabel, pStart, pEnd)
	
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
	
		cStart = This._normalizeDateTime(pStart)
		cEnd = This._normalizeDateTime(pEnd)
	
		# Validate span: start must be strictly before end
		oStart = new stzDateTime(cStart)
		oEnd = new stzDateTime(cEnd)
		if oStart >= oEnd
			raise("Error: Span '" + pcLabel + "' has invalid dates. Start time (" + 
				cStart + ") must be before end time (" + cEnd + ")")
		ok
	
		oTLStart = This.StartQ()
		oTLEnd = This.EndQ()
	
		if oStart < oTLStart or oEnd > oTLEnd
			raise("Span '" + pcLabel + "' is outside timeline boundaries")
		ok
	
		if This.IsRangeBlocked(cStart, cEnd)
			raise("Span '" + pcLabel + "' overlaps with a blocked span")
		ok
	
		@aSpans + [pcLabel, cStart, cEnd]
	
		def AddSpanQ(pcLabel, pStart, pEnd)
			This.AddSpan(pcLabel, pStart, pEnd)
			return This
		
		def AddPeriod(pcLabel, pStart, pEnd)
			This.AddSpan(pcLabel, pStart, pEnd)
	
			def AddPeriodQ(pcLabel, pStart, pEnd)
				return This.AddSpanQ(pcLabel, pStart, pEnd)
	

	# Find the occurences of a given Period (by label)
	# on the timeline (returns its relative datetimes)
	def FindSpan(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		acResult = []
		nLen = len(@aSpans)

		pcLabel = upper(pcLabel)
	
		for i = 1 to nLen
			if @aSpans[i][1] = pcLabel
				acResult + [ @aSpans[i][2], @aSpans[i][3] ]
			ok
		next
	
		return acResult


		def FindPeriod(pcSpan)
			return This.FindSpan(pcSpan)

	# Returns the datetimes along with their positions
	def FindSpanXT(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		acResult = []
		nLen = len(@aSpans)

		pcLabel = upper(pcLabel)

		for i = 1 to nLen
			if @aSpans[i][1] = pcSpan
				aResult + [ [ @aSpans[i][2], @aSpans[i][3] ], i ]
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
			
	def Span(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		nLen = len(@aSpans)
		for i = 1 to nLen
			if @aSpans[i][1] = pcLabel
				return [@aSpans[i][2], @aSpans[i][3]]
			ok
		next

		StzRaise("No span found with the lable ('" + pcLabel + "')!")
		
		def Period(cLabel)
			return This.Span(cLabel)

	def SpanStart(pcLabel)
		return This.Span(pcLabel)[1]

		def SpanStartQ(pcLabel)
			return new stzDateTimeQ(This.SpanStart(pcLabel))
		
	def SpanEnd(pcLabel)
		return This.Span(pcLabel)[2]

		def SpanEndQ(pcLabel)
			return new stzDateTimeQ(This.SpanEnd(pcLabel))

	def SpanDuration(pcLabel)
		return This.SpanStartQ(pcLabel).DurationTo(This.SpanEnd(pcLabel), :InSeconds)

		def SpanDurationQ(pcLabel)
			return new stzDuration(This.SpanDuration(pcLabel))

	def HasSpan(pcLabel)
		return This.FindSpan(pcLabel) > 0
		
	def RemoveSpan(pcLabel)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		pcLabel = upper(pcLabel)

		nPos = 0
		nLen = len(@aSpans)

		for i = 1 to nLen
			if @aSpans[i][1] = pcLabel
				nPos = i
				exit
			ok
		next

		if nPos > 0
			del(@aSpans, nPos)
		ok
		
		def RemoveSpanQ(pcLabel)
			This.RemoveSpan(pcLabel)
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

		if isString(pDateTime)
			cDateTime = pDateTime
		else
			cDateTime = StzDateTimeQ(pDateTime).ToString()
		ok

		if cDateTime = ""
			StzRaise("Incorrect param value! pDateTime must not be empty.")
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
				oStart = new stzDateTime(@aSpans[i][2])
				oEnd = new stzDateTime(@aSpans[i][3])
	
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

		if isString(pDateTime)
			cDateTime = pDateTime
		else
			cDateTime = StzDateTimeQ(pDateTime).ToString()
		ok
	
		if cDateTime = ""
			StzRaise("Incorrect param value! pDateTime must not be empty.")
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

		if cStart = "" or cEnd = ''
			StzRaise("Incorrect params values! pStart and pEnd must not be empty.")
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

		if cStart = "" or cEnd = ''
			StzRaise("Incorrect params values! pStart and pEnd must not be empty.")
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

		if isString(pDateTime)
			cDateTime = pDateTime
		else
			cDateTime = StzDateTimeQ(pDateTime).ToString()
		ok

		if cDateTime = ""
			StzRaise("Incorrect param value! pDateTime must not be empty.")
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
		if len(@aSpans) = 0
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

	# Duration Calculations
	
	def DurationXT(cLabel1, cLabel2)
		if CheckParams()
			if isList(cLabel1) and StzListQ(cLabel1).IsFromOrBetweenNamedParam()
				cLabel1 = cLabel1[2]
			ok

			if isList(cLabel2) and StzListQ(cLabel2).IsToOrAndNamedParam()
				cLabel2 = cLabel2[2]
			ok
		ok
		
		return This.PointQ(cLabel1).DurationTo(This.Point(cLabel2), :InSeconds)

		#< @FunctionFluentForm

		def DurationXTQ(cLabel1, cLabel2)
			return new stzDuration( This.DurationXT(cLabel1, cLabel2) )

		#>

		#< @FunctionAlternativeForms

		def Interval(cLabel1, cLabel2)
			return This.DurationXT(cLabel1, cLabel2)

			def IntervalQ(cLabel1, cLabel2)
				return This.DurationXTQ(cLabel1, cLabel2)
	
		def DurationBetween(cLabel1, cLabel2)
			return This.DurationXT(cLabel1, cLabel2)
		
			def DurationBetweenQ(cLabel1, cLabel2)
				return This.DurationXTQ(cLabel1, cLabel2)
	
		def TimeBetween(cLabel1, cLabel2)
			return This.DurationXT(cLabel1, cLabel2)
	
			def TimeBetweenQ(cLabel1, cLabel2)
				return This.DurationXTQ(cLabel1, cLabel2)

		def IntervalBetween(cLabel1, cLabel2)
			return This.This.DurationXT(cLabel1, cLabel2)
	
			def IntervalBetweenQ(cLabel1, cLabel2)
				return This.This.DurationXTQ(cLabel1, cLabel2)
		#>

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
		
		# Add boundaries
		aResult + [ "start", @cStart ] + 
			[ "end", @cEnd ] +
			[ "totalduration", This.DurationQ().ToHuman() ]
		
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
		
	def Copy()
		_oCopy_ = new stzTimeLine(
			:Start = This.Start(),
			:End = This.End_()
		)

		_oCopy_.@aPoints = This.@aPoints
		_oCopy_.@aSpans = This.@aSpans
		
		return _oCopy_
		
		def Clone()
			return This.Copy()
		
	  #-----------------------------------------#
	 #  Visual Display System for stzTimeLine  #
	#-----------------------------------------#
	
	# Configuration
	
	def SetVizWidth(n)
		@nVizWidth = max([@nVizMinWidth, n])
		
	def SetVizHeight(n)
		@nVizHeight = max([@nVizHeight, n])
		
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
		_drawBlockedSpans(oLayout, aTimepoints)
		_drawBlockedPoints(oLayout, aTimepoints)
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
	
		# Workaround: replacing eventual ──○●► with ─●○─►
		#TODO // Resolve it logically at construction

		cViz = substr(cViz, "──○●►", "───●○─►")

		return cViz + nl + nl + cTable
	
	def Stats()
		return _buildStatisticalTable()
	
	def ShowShort()
		? This.ToStringShort()
	
def ToStringShort()

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
	
	def VizFindMoments(cLabel)
		@cHighlight = cLabel
		cResult = This.ToString()
		@cHighlight = NULL
		return cResult
		
		def VizFindMoment(cLabel)
			return This.VizFindMoments(cLabel)
			
		def VizFindPoint(cLabel)
			return This.VizFindMoments(cLabel)
			
		def VizFindPoints(cLabel)
			return This.VizFindMoments(cLabel)
			
	def VizFindSpans(cLabel)
		@cHighlight = cLabel
		cResult = This.ToString()
		@cHighlight = NULL
		return cResult
		
		def VizFindSpan(cLabel)
			return This.VizFindSpans(cLabel)
			
		def VizFindPeriod(cLabel)
			return This.VizFindSpans(cLabel)
			
		def VizFindPeriods(cLabel)
			return This.VizFindSpans(cLabel)


	# Hihlighting the uncovered spans in the timeline

	def ShowUncovered()
	    ? This.ToStringUncovered()
	
	def ToStringUncovered()
	    
	    # Get uncovered periods
	    aUncovered = This.UncoveredPeriods()
	    if len(aUncovered) = 0
	        return "Timeline is fully covered by spans"
	    ok
	    
	    # Collect timepoints - same logic as Show()
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
	    _drawBlockedSpans(oLayout, aTimepoints)
	    _drawBlockedPoints(oLayout, aTimepoints)
	    _drawSpans(oLayout, aTimepoints)
	    _drawUncoveredRegions(oLayout, aUncovered)
	    _drawPoints(oLayout, aTimepoints)
	    _drawNumbers(oLayout, aTimepoints)
	    
	    # Build output
	    cViz = _vizCanvasToString()
	    cTable = _buildTimepointsTable(aTimepoints)
	    
	    return cViz + nl + nl + cTable

	#----------------------------#
	#  MANAGING BLOCKED POINTS AND SPANS  #
	#----------------------------#

def AddBlockedPoint(pDateTime)
	cPoint = This._normalizeDateTime(pDateTime)
	oPoint = new stzDateTime(cPoint)
	oStart = This.StartQ()
	oEnd = This.EndQ()

	if oPoint < oStart or oPoint > oEnd
		raise("Blocked point is outside timeline boundaries")
	ok

	if find(@aBlockedPoints, cPoint) = 0
		@aBlockedPoints + cPoint
	ok

	def AddBlockedPointQ(pDateTime)
		This.AddBlockedPoint(pDateTime)
		return This

def AddBlockedPoints(paDateTimes)
	nLen = len(paDateTimes)
	for i = 1 to nLen
		This.AddBlockedPoint(paDateTimes[i])
	next

def RemoveBlockedPoint(pDateTime)
	cPoint = This._normalizeDateTime(pDateTime)
	nPos = find(@aBlockedPoints, cPoint)
	if nPos > 0
		del(@aBlockedPoints, nPos)
	ok

	def RemoveBlockedPointQ(pDateTime)
		This.RemoveBlockedPoint(pDateTime)
		return This

def BlockedPoints()
	return @aBlockedPoints

	def BlockedPointsQ()
		aResult = []
		nLen = len(@aBlockedPoints)
		for i = 1 to nLen
			aResult + new stzDateTime(@aBlockedPoints[i])
		next
		return aResult

def IsPointBlocked(pDateTime)
	if isString(pDateTime)
		cDateTime = pDateTime
	else
		cDateTime = StzDateTimeQ(pDateTime).ToString()
	ok

	oDateTime = new stzDateTime(cDateTime)
	nLen = len(@aBlockedPoints)

	for i = 1 to nLen
		oBlocked = new stzDateTime(@aBlockedPoints[i])
		if oDateTime.IsEqualTo(oBlocked)
			return TRUE
		ok
	next

	return FALSE

def IsBlocked(pDateTime)
	if isList(pDatetime) and len(pDateTime) = 2
		return This.IsRangeBlocked(pDateTime[1], pDateTime[2])
	ok

	# Check both blocked points and blocked spans
	if This.IsPointBlocked(pDateTime)
		return TRUE
	ok

	if isString(pDateTime)
		cDateTime = pDateTime
	else
		cDateTime = StzDateTimeQ(pDateTime).ToString()
	ok

	oDateTime = new stzDateTime(cDateTime)
	nLen = len(@aBlockedSpans)

	for i = 1 to nLen
		oStart = new stzDateTime(@aBlockedSpans[i][2])
		oEnd = new stzDateTime(@aBlockedSpans[i][3])
		if oDateTime >= oStart and oDateTime <= oEnd
			return TRUE
		ok
	next

	return FALSE

def IsRangeBlocked(pStart, pEnd)
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
	nLen = len(@aBlockedSpans)

	for i = 1 to nLen
		oBlockStart = new stzDateTime(@aBlockedSpans[i][2])
		oBlockEnd = new stzDateTime(@aBlockedSpans[i][3])
		if oStart < oBlockEnd and oEnd > oBlockStart
			return TRUE
		ok
	next

	# Also check blocked points within range
	nLen = len(@aBlockedPoints)
	for i = 1 to nLen
		oPoint = new stzDateTime(@aBlockedPoints[i])
		if oPoint >= oStart and oPoint <= oEnd
			return TRUE
		ok
	next

	return FALSE

#---

def AddBlockedSpan(pcLabel, pStart, pEnd)
	if NOT isString(pcLabel)
		StzRaise("Incorrect param type! pcLabel must be a string.")
	ok

	cStart = This._normalizeDateTime(pStart)
	cEnd = This._normalizeDateTime(pEnd)

	oStart = new stzDateTime(cStart)
	oEnd = new stzDateTime(cEnd)
	if oStart >= oEnd
		raise("Error: Blocked span '" + pcLabel + "' has invalid dates.")
	ok

	oTLStart = This.StartQ()
	oTLEnd = This.EndQ()

	if oStart < oTLStart or oEnd > oTLEnd
		raise("Blocked span '" + pcLabel + "' is outside timeline boundaries")
	ok

	@aBlockedSpans + [upper(pcLabel), cStart, cEnd]

	def AddBlockedSpanQ(pcLabel, pStart, pEnd)
		This.AddBlockedSpan(pcLabel, pStart, pEnd)
		return This

def RemoveBlockedSpan(pcLabel)
	if NOT isString(pcLabel)
		StzRaise("Incorrect param type! pcLabel must be a string.")
	ok

	pcLabel = upper(pcLabel)
	nPos = 0
	nLen = len(@aBlockedSpans)

	for i = 1 to nLen
		if @aBlockedSpans[i][1] = pcLabel
			nPos = i
			exit
		ok
	next

	if nPos > 0
		del(@aBlockedSpans, nPos)
	ok

	def RemoveBlockedSpanQ(pcLabel)
		This.RemoveBlockedSpan(pcLabel)
		return This

def BlockedSpans()
	return @aBlockedSpans

	def BlockedSpansQ()
		aResult = []
		nLen = len(@aBlockedSpans)
		for i = 1 to nLen
			aResult + [
				@aBlockedSpans[i][1],
				new stzDateTime(@aBlockedSpans[i][2]),
				new stzDateTime(@aBlockedSpans[i][3])
			]
		next
		return aResult


	#-----------#
	PRIVATE
	#-----------#
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
		
		# Point labels row (above axis, separate from spans)
		nPointLabelsRow = 0
		if len(@aPoints) > 0
			nPointLabelsRow = nTotalRows + 1
			nTotalRows += 1
		ok
		
		# Axis row
		nAxisRow = nTotalRows + 1
		nTotalRows += 1
		
		# Numbers row (only if there are points or spans)
		nNumbersRow = 0
		if len(@aPoints) > 0 or len(@aSpans) > 0
			nNumbersRow = nTotalRows + 1
			nTotalRows += 1
		ok
		
		return [
			:total_height = nTotalRows,
			:labels_row = nPointLabelsRow,
			:spans_start = nSpansStart,
			:span_rows = nSpanRows,
			:axis_row = nAxisRow,
			:numbers_row = nNumbersRow
		]
		
		# Position Mapping & Timepoint Collection
		
		def _timeToPosition(cDateTime)
			
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
		
		# Add start boundary (NO INDEX)
		aTimepoints + [NULL, @cStart, "", "Timeline start", "boundary"]
		
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
		
		# Add to timepoints with indices (starting from 1)
		nIndex = 1
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
		
		# Add end boundary (NO INDEX)
		aTimepoints + [NULL, @cEnd, "", "Timeline end", "boundary"]
	
		return aTimepoints
		
	def _sortTimepointsByDate(aItems)
		# Manual bubble sort by datetime (index 3 in the array)
		nLen = len(aItems)
		
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				oDateTime1 = new stzDateTime(aItems[j][3])
				oDateTime2 = new stzDateTime(aItems[j + 1][3])
				
				if oDateTime1 > oDateTime2
					aTemp = aItems[j]
					aItems[j] = aItems[j + 1]
					aItems[j + 1] = aTemp
				ok
			next
		next
		
		return aItems
	
		# Drawing Methods
		
	def _drawAxis(oLayout)
	    nRow = oLayout[:axis_row]
	    nCanvasWidth = len(@acVizCanvas[1])
	    
	    # Draw start boundary
	    _setVizChar(nRow, 1, @cBoundaryStartChar)
	    
	    # Draw main axis line
	    for i = 2 to nCanvasWidth - 3
	        _setVizChar(nRow, i, @cAxisChar)
	    next
	    
	    # Draw end boundary and arrow
	    _setVizChar(nRow, nCanvasWidth - 2, @cBoundaryEndChar)
	    _setVizChar(nRow, nCanvasWidth - 1, @cAxisChar)
	    _setVizChar(nRow, nCanvasWidth, @cArrowChar)
	
	def _canPlaceLabel(nPos, cLabel, aTimepoints)
		nLabelLen = len(cLabel)
		nLabelStart = max([1, nPos - floor(nLabelLen / 2)])
		nLabelEnd = nLabelStart + nLabelLen - 1
		
		# Don't place if overlaps with blocked regions
		nLen = len(@aBlockedSpans)
		for i = 1 to nLen
			nBlockStart = _timeToPosition(@aBlockedSpans[i][2])
			nBlockEnd = _timeToPosition(@aBlockedSpans[i][3])
			if not (nLabelEnd < nBlockStart or nLabelStart > nBlockEnd)
				return FALSE
			ok
		next
		
		# Don't place if overlaps with blocked points
		nLen = len(@aBlockedPoints)
		for i = 1 to nLen
			nBlockPos = _timeToPosition(@aBlockedPoints[i])
			if nBlockPos >= nLabelStart and nBlockPos <= nLabelEnd
				return FALSE
			ok
		next
		
		return TRUE

	def _drawLabels(oLayout, aTimepoints)
		nRow = oLayout[:labels_row]
		
		if nRow = 0
			return
		ok
		
		aLabelsToPlace = []
		nLen = len(aTimepoints)
	
		for i = 1 to nLen
			cType = aTimepoints[i][5]
			cLabel = aTimepoints[i][3]
			
			if (cType = "span_start" or cType = "span_end") and cLabel != ""
				cDateTime = aTimepoints[i][2]
				nPos = _timeToPosition(cDateTime)
				
				# Only add if label can be placed safely
				if This._canPlaceLabel(nPos, cLabel, aTimepoints)
					aLabelsToPlace + [nPos, cLabel]
				ok
			ok
		next
		
		aPlaced = []
		nLen = len(aLabelsToPlace)
	
		for i = 1 to nLen
			nPos = aLabelsToPlace[i][1]
			cLabel = aLabelsToPlace[i][2]
			nLabelLen = len(cLabel)
			
			nLabelStart = max([1, nPos - floor(nLabelLen / 2)])
			nLabelEnd = nLabelStart + nLabelLen - 1
			
			bCollides = FALSE
			nLenJ = len(aPlaced)
	
			for j = 1 to nLenJ
				nPlacedStart = aPlaced[j][1]
				nPlacedEnd = aPlaced[j][2]
				
				if not (nLabelEnd < nPlacedStart or nLabelStart > nPlacedEnd)
					bCollides = TRUE
					exit
				ok
			next
			
			if not bCollides
				_setVizString(nRow, nLabelStart, cLabel)
				aPlaced + [nLabelStart, nLabelEnd]
			ok
		next
	
	def _drawNumbers(oLayout, aTimepoints)
		nRow = oLayout[:numbers_row]
		
		# Skip if no numbers row allocated
		if nRow = 0
			return
		ok
		
		# Count non-boundary timepoints
		nCount = 0
		nLen = len(aTimepoints)
		for i = 1 to nLen
			if aTimepoints[i][1] != NULL
				nCount++
			ok
		next
		
		# Only draw numbers if there are actual points/spans (not just boundaries)
		if nCount = 0
			return
		ok
		
		# Group indices by position
		aPositionGroups = []  # [[position, [index1, index2, ...]], ...]
		
		for i = 1 to nLen
			nIndex = aTimepoints[i][1]
			
			# Skip boundaries (NULL index)
			if nIndex = NULL
				loop
			ok
			
			cDateTime = aTimepoints[i][2]
			nPos = _timeToPosition(cDateTime)
			
			# Find if this position already has indices
			nGroupPos = 0
			nLenGroups = len(aPositionGroups)
			for j = 1 to nLenGroups
				if aPositionGroups[j][1] = nPos
					nGroupPos = j
					exit
				ok
			next
			
			if nGroupPos = 0
				# New position
				aPositionGroups + [nPos, [nIndex]]
			else
				# Add to existing position
				aPositionGroups[nGroupPos][2] + nIndex
			ok
		next
		
		# Calculate how many extra rows we need for stacked numbers
		nMaxIndices = 0
		nLenGroups = len(aPositionGroups)
		for i = 1 to nLenGroups
			nIndicesCount = len(aPositionGroups[i][2])
			if nIndicesCount > nMaxIndices
				nMaxIndices = nIndicesCount
			ok
		next
		
		# Calculate rows needed (2 numbers per row)
		nRowsNeeded = ceil(nMaxIndices / 2.0)
		
		# Ensure canvas has enough rows
		nCanvasHeight = len(@acVizCanvas)
		nRowsToAdd = (nRow + nRowsNeeded - 1) - nCanvasHeight
		if nRowsToAdd > 0
			nCanvasWidth = len(@acVizCanvas[1])
			for i = 1 to nRowsToAdd
				aNewRow = []
				for j = 1 to nCanvasWidth
					aNewRow + " "
				next
				@acVizCanvas + aNewRow
			next
		ok
		
		# Draw grouped numbers (2 per line, stacked vertically)
		for i = 1 to nLenGroups
			nPos = aPositionGroups[i][1]
			aIndices = aPositionGroups[i][2]
			
			nLenIndices = len(aIndices)
			
			if nLenIndices = 1
				# Single number - draw on first row
				cNum = "" + aIndices[1]
				nNumLen = len(cNum)
				nStartCol = max([1, nPos - floor(nNumLen / 2)])
				_setVizString(nRow, nStartCol, cNum)
				
			else
				# Multiple indices - stack 2 per row
				nCurrentRow = nRow
				
				for j = 1 to nLenIndices step 2
					# Build number string for this row (up to 2 numbers)
					cNum = "" + aIndices[j]
					if j + 1 <= nLenIndices
						cNum += "-" + aIndices[j + 1]
					ok
					
					nNumLen = len(cNum)
					nStartCol = max([1, nPos - floor(nNumLen / 2)])
					_setVizString(nCurrentRow, nStartCol, cNum)
					
					nCurrentRow++
				next
			ok
		next

	def _drawPoints(oLayout, aTimepoints)
	    nAxisRow = oLayout[:axis_row]
	    nLen = len(aTimepoints)
	
	    # First, count ALL events at each position
	    aPositionCounts = []  # [[position, count], ...]
	    
	    for i = 1 to nLen
	        cType = aTimepoints[i][5]
	        
	        # Skip boundaries, but count everything else
	        if cType = "boundary"
	            loop
	        ok
	        
	        if cType = "point" or cType = "span_start" or cType = "span_end"
	            cDateTime = aTimepoints[i][2]
	            nPos = _timeToPosition(cDateTime)
	            
	            # Find if position already counted
	            nFoundAt = 0
	            nLenCounts = len(aPositionCounts)
	            for j = 1 to nLenCounts
	                if aPositionCounts[j][1] = nPos
	                    nFoundAt = j
	                    exit
	                ok
	            next
	            
	            if nFoundAt = 0
	                aPositionCounts + [nPos, 1]
	            else
	                aPositionCounts[nFoundAt][2]++
	            ok
	        ok
	    next
	
	    # Now draw all timepoint types with appropriate symbol
	    for i = 1 to nLen
	        cType = aTimepoints[i][5]
	
	        # Skip boundaries - they're already drawn by _drawAxis
	        if cType = "boundary"
	            loop
	        ok
	
	        if cType = "point" or cType = "span_start" or cType = "span_end"
	            cDateTime = aTimepoints[i][2]
	            nPos = _timeToPosition(cDateTime)
	
	            # Find count at this position
	            nCount = 1
	            nLenCounts = len(aPositionCounts)
	            for j = 1 to nLenCounts
	                if aPositionCounts[j][1] = nPos
	                    nCount = aPositionCounts[j][2]
	                    exit
	                ok
	            next
	
	            bHighlighted = FALSE
	            if @cHighlight != NULL and aTimepoints[i][3] = @cHighlight
	                bHighlighted = TRUE
	            ok
	
	            # Use ◉ if multiple events at same position, otherwise ●
	            cChar = ""
	            if bHighlighted
	                cChar = @cHighlightChar
	            else
	                if nCount = 1
	                    cChar = @cPointChar # Single event (●)
	
	                but nCount > 1
	                    cChar = @cMultiPointChar  # Multiple events at this position (◉)
	                ok
	            ok
	
	            _setVizChar(nAxisRow, nPos, cChar)
	        ok
	    next

	def _drawSpans(oLayout, aTimepoints)
	    nAxisRow = oLayout[:axis_row]
	    
	    # Group span starts and ends
	    aSpanRanges = []
	    nLen = len(@aSpans)
	
	    for i = 1 to nLen
	        cLabel = @aSpans[i][1]
	        cStart = @aSpans[i][2]
	        cEnd = @aSpans[i][3]
	        
	        nStartPos = _timeToPosition(cStart)
	        nEndPos = _timeToPosition(cEnd)
	        
	        bHighlighted = (@cHighlight != NULL and @cHighlight = cLabel)
	        
	        aSpanRanges + [cLabel, nStartPos, nEndPos, bHighlighted]
	    next
	    
	    # Draw spans with vertical offset
	    aRowUsed = []
	    for i = 1 to @nVizHeight
	        aRowUsed + []
	    next
	
	    nLen = len(aSpanRanges)
	    for i = 1 to nLen
	        cLabel = aSpanRanges[i][1]
	        nStartPos = aSpanRanges[i][2]
	        nEndPos = aSpanRanges[i][3]
	        bHighlighted = aSpanRanges[i][4]
	        
	        nRow = _findAvailableRow(oLayout, nStartPos, nEndPos, aRowUsed)
	        _drawSpanBar(nRow, nStartPos, nEndPos, cLabel, bHighlighted)
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
		cBarChar = @cSpanChar
	
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
		aTableData = [
			[:NO, :TIMEPOINT, :LABEL, :DESCRIPTION]
		]
	
		nLen = len(aTimepoints)
		for i = 1 to nLen
			nIndex = aTimepoints[i][1]
			cDateTime = aTimepoints[i][2]
			cLabel = aTimepoints[i][3]
			cDesc = aTimepoints[i][4]
			
			# Use empty string for NULL (boundaries)
			cIndexStr = ""
			if nIndex != NULL
				cIndexStr = "" + nIndex
			ok
			
			aTableData + [cIndexStr, cDateTime, cLabel, cDesc]
		next
		
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
	     oDuration = This.DurationQ()
	     aStats + ["Timeline Duration", oDuration.ToHuman()]
	    
	    # Coverage calculation
	    nLenSpans = len(@aSpans)

	    if nLenSpans > 0
	        nTotalDuration = This.Duration()
	        nCoveredDuration = 0
	        
	        # Sum all span durations (simplified - doesn't handle overlaps)
	        nLen = nLenSpans
	        for i = 1 to nLen
	            nCoveredDuration += This.SpanDuration(@aSpans[i][1])
	        next
	        
	        nCoveragePercent = (nCoveredDuration * 100.0) / nTotalDuration
	        aStats + ["Coverage", "" + floor(nCoveragePercent) + "%"]
	    ok
	    
	    # Longest span
	    if nLenSpans > 0
	        nMaxDuration = 0
	        cLongestSpan = ""
	        
	        nLen = nLenSpans
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
	    nCanvasWidth = len(@acVizCanvas[1])
	    
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
	        
	        # Draw / pattern, skip span boundaries AND timeline boundaries
	        for j = nStartPos to nEndPos
	            # Skip position 1 (start boundary) and last 3 positions (end boundary + arrow)
	            if j != 1 and j < nCanvasWidth - 2 and find(aSpanPositions, j) = 0
	                _setVizChar(nAxisRow, j, @cUncoveredChar)
	            ok
	        next
	    next

	def _drawBlockedSpans(oLayout, aTimepoints)
		nAxisRow = oLayout[:axis_row]
		nLen = len(@aBlockedSpans)
		
		for i = 1 to nLen
			cStart = @aBlockedSpans[i][2]
			cEnd = @aBlockedSpans[i][3]
			
			nStartPos = _timeToPosition(cStart)
			nEndPos = _timeToPosition(cEnd)
			
			for j = nStartPos to nEndPos
				_setVizChar(nAxisRow, j, @cBlockChar)
			next
		next
	
	def _drawBlockedPoints(oLayout, aTimepoints)
		nAxisRow = oLayout[:axis_row]
		nLen = len(@aBlockedPoints)
		
		for i = 1 to nLen
			nPos = _timeToPosition(@aBlockedPoints[i])
			_setVizChar(nAxisRow, nPos, @cBlockChar)
		next
	
	def _isDateOnly(cDateTime)
		# Check if format is YYYY-MM-DD (no time component)
		if len(cDateTime) = 10 and substr(cDateTime, 5, 1) = "-" and substr(cDateTime, 8, 1) = "-"
			return 1
		else
			return 0
		ok
	
		def _isOnlyDate(cDateTime)
			return This._isDateOnly(cDateTime)

	def _isTimeOnly(cDateTime)
		# Check if format is HH:MM:SS (no date component)
		if len(cDateTime) = 8 and substr(cDateTime, 3, 1) = ":" and substr(cDateTime, 6, 1) = ":"
			return 1
		else
			return 0
		ok

		def _isOnlyTime(cDateTime)
			return This._isTimeOnly(cDateTime)

	def _normalizeDateTime(pDateTime)
	    # Convert date-only input to full datetime by appending 00:00:00
	    cDateTime = ""
	    
	    if isString(pDateTime)
	        cDateTime = trim(pDateTime)
		if cDateTime = ""
			StzRaise("Invalid format! Empty strings are not allowed for datevalue!")
		ok

	    else
	        cDateTime = new stzDateTime(pDateTime).ToString()
	    ok
	    
	    # Check if date-only format (YYYY-MM-DD)
	    if This._isTimeOnly(cDateTime)
		StzRaise("Invalid format! Time specified without a date")

	    but This._isDateOnly(cDateTime)
	        cDateTime += " 00:00:00"
	    ok
	    
	    # Ensure the string contains valide datetime processable by Qt

	    try
		new stzDateTime(cDateTime)
	    catch
		StzRaise("Invalid datetime format (" + cDateTime + ")!")
	    done

	    return cDateTime
