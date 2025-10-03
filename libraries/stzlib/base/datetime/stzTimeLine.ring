/*
	stzTimeLine - Timeline Management in Softanza
	Manages sequential time data: points, spans, and temporal relationships
*/

func StzTimeLineQ(p)
	return new stzTimeLine(p)

func TimeLineQ(p)
	return new stzTimeLine(p)

func TimeLine(p)
	return new stzTimeLine(p)

class stzTimeLine from stzObject
	@oStart = NULL
	@oEnd = NULL
	@aPoints = []      # [[name, stzDateTime], ...]
	@aSpans = []       # [[name, stzDateTime, stzDateTime], ...]

	def init(p)
		if isList(p) and @IsHashList(p)
			# Initialize start/end boundaries
			if p[:Start] != NULL
				@oStart = new stzDateTime(p[:Start])
			ok
			if p[:End] != NULL
				@oEnd = new stzDateTime(p[:End])
			ok
		else
			@oStart = NULL
			@oEnd = NULL
		ok

	# Boundary Management
	
	def Start()
		if @oStart != NULL
			return @oStart
		ok
		return NULL
		
		def StartDate()
			return This.Start()
			
	def End()
		if @oEnd != NULL
			return @oEnd
		ok
		return NULL
		
		def EndDate()
			return This.End()
			
	def SetStart(p)
		@oStart = new stzDateTime(p)
		return This
		
	def SetEnd(p)
		@oEnd = new stzDateTime(p)
		return This
		
	def HasBoundaries()
		return @oStart != NULL and @oEnd != NULL
		
	def Duration()
		if This.HasBoundaries()
			return @oStart.DurationTo(@oEnd)
		ok
		return NULL

	# Point Management (single moments in time)
	
	def AddPoint(cName, pDateTime)
		oPoint = new stzDateTime(pDateTime)
		
		# Validate against boundaries
		if This.HasBoundaries()
			if oPoint < @oStart or oPoint > @oEnd
				raise("Point '" + cName + "' is outside timeline boundaries")
			ok
		ok
		
		@aPoints + [cName, oPoint]
		return This
		
		def AddTimePoint(cName, pDateTime)
			return This.AddPoint(cName, pDateTime)
			
		def AddMoment(cName, pDateTime)
			return This.AddPoint(cName, pDateTime)
	
	def Points()
		return @aPoints
		
		def TimePoints()
			return This.Points()
			
		def Moments()
			return This.Points()
			
	def PointNames()
		aNames = []
		for aPoint in @aPoints
			aNames + aPoint[1]
		next
		return aNames
		
	def Point(cName)
		for aPoint in @aPoints
			if aPoint[1] = cName
				return aPoint[2]
			ok
		next
		return NULL
		
	def HasPoint(cName)
		return This.Point(cName) != NULL
		
	def RemovePoint(cName)
		nPos = 0
		for i = 1 to len(@aPoints)
			if @aPoints[i][1] = cName
				nPos = i
				exit
			ok
		next
		if nPos > 0
			del(@aPoints, nPos)
		ok
		return This
		
	def PointsCount()
		return len(@aPoints)
		
		def NumberOfPoints()
			return This.PointsCount()

	# Span Management (time periods with start and end)
	
	def AddSpan(cName, pStart, pEnd)
		oStart = new stzDateTime(pStart)
		oEnd = new stzDateTime(pEnd)
		
		# Validate span
		if oStart >= oEnd
			raise("Span '" + cName + "' start must be before end")
		ok
		
		# Validate against boundaries
		if This.HasBoundaries()
			if oStart < @oStart or oEnd > @oEnd
				raise("Span '" + cName + "' is outside timeline boundaries")
			ok
		ok
		
		@aSpans + [cName, oStart, oEnd]
		return This
		
		def AddPeriod(cName, pStart, pEnd)
			return This.AddSpan(cName, pStart, pEnd)
			
	def Spans()
		return @aSpans
		
		def Periods()
			return This.Spans()
			
	def SpanNames()
		aNames = []
		for aSpan in @aSpans
			aNames + aSpan[1]
		next
		return aNames
		
		def PeriodNames()
			return This.SpanNames()
			
	def Span(cName)
		for aSpan in @aSpans
			if aSpan[1] = cName
				return [aSpan[2], aSpan[3]]
			ok
		next
		return NULL
		
		def Period(cName)
			return This.Span(cName)
			
	def SpanStart(cName)
		aSpan = This.Span(cName)
		if aSpan != NULL
			return aSpan[1]
		ok
		return NULL
		
	def SpanEnd(cName)
		aSpan = This.Span(cName)
		if aSpan != NULL
			return aSpan[2]
		ok
		return NULL
		
	def SpanDuration(cName)
		aSpan = This.Span(cName)
		if aSpan != NULL
			return aSpan[1].DurationTo(aSpan[2])
		ok
		return NULL
		
	def HasSpan(cName)
		return This.Span(cName) != NULL
		
	def RemoveSpan(cName)
		nPos = 0
		for i = 1 to len(@aSpans)
			if @aSpans[i][1] = cName
				nPos = i
				exit
			ok
		next
		if nPos > 0
			del(@aSpans, nPos)
		ok
		return This
		
	def SpansCount()
		return len(@aSpans)
		
		def NumberOfSpans()
			return This.SpansCount()
			
		def PeriodsCount()
			return This.SpansCount()

	# Temporal Queries
	
	def WhatsAt(pDateTime)
		oDateTime = new stzDateTime(pDateTime)
		aResult = []
		
		# Check points at exact time
		for aPoint in @aPoints
			if aPoint[2].IsEqualTo(oDateTime)
				aResult + [:Point = aPoint[1]]
			ok
		next
		
		# Check spans containing this time
		for aSpan in @aSpans
			if oDateTime >= aSpan[2] and oDateTime <= aSpan[3]
				aResult + [:Span = aSpan[1]]
			ok
		next
		
		return aResult
		
		def HappeningAt(pDateTime)
			return This.WhatsAt(pDateTime)
			
	def PointsBetween(pStart, pEnd)
		oStart = new stzDateTime(pStart)
		oEnd = new stzDateTime(pEnd)
		
		aResult = []
		for aPoint in @aPoints
			if aPoint[2] >= oStart and aPoint[2] <= oEnd
				aResult + aPoint[1]
			ok
		next
		return aResult
		
	def SpansBetween(pStart, pEnd)
		oStart = new stzDateTime(pStart)
		oEnd = new stzDateTime(pEnd)
		
		aResult = []
		for aSpan in @aSpans
			# Include spans that overlap with the range
			if aSpan[3] >= oStart and aSpan[2] <= oEnd
				aResult + aSpan[1]
			ok
		next
		return aResult
		
	def SpansOverlapping(pDateTime)
		oDateTime = new stzDateTime(pDateTime)
		
		aResult = []
		for aSpan in @aSpans
			if oDateTime >= aSpan[2] and oDateTime <= aSpan[3]
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
				oStart1 = @aSpans[i][2]
				oEnd1 = @aSpans[i][3]
				oStart2 = @aSpans[j][2]
				oEnd2 = @aSpans[j][3]
				
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
				oStart1 = @aSpans[i][2]
				oEnd1 = @aSpans[i][3]
				oStart2 = @aSpans[j][2]
				oEnd2 = @aSpans[j][3]
				
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
					
					oDuration = oOverlapStart.DurationTo(oOverlapEnd)
					
					aResult + [
						@aSpans[i][1],
						@aSpans[j][1],
						oDuration
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
		
		aGaps = []
		for i = 1 to len(aSorted) - 1
			oEnd1 = aSorted[i][3]
			oStart2 = aSorted[i + 1][2]
			
			if oEnd1 < oStart2
				oDuration = oEnd1.DurationTo(oStart2)
				aGaps + [
					:After = aSorted[i][1],
					:Before = aSorted[i + 1][1],
					:Duration = oDuration
				]
			ok
		next
		return aGaps
		
	def UncoveredPeriods()
		if not This.HasBoundaries() or len(@aSpans) = 0
			return []
		ok
		
		aSorted = This.SortedSpans()
		aUncovered = []
		
		# Check gap before first span
		if aSorted[1][2] > @oStart
			oDuration = @oStart.DurationTo(aSorted[1][2])
			aUncovered + [@oStart, aSorted[1][2], oDuration]
		ok
		
		# Check gaps between spans
		for i = 1 to len(aSorted) - 1
			oEnd1 = aSorted[i][3]
			oStart2 = aSorted[i + 1][2]
			
			if oEnd1 < oStart2
				oDuration = oEnd1.DurationTo(oStart2)
				aUncovered + [oEnd1, oStart2, oDuration]
			ok
		next
		
		# Check gap after last span
		nLast = len(aSorted)
		if aSorted[nLast][3] < @oEnd
			oDuration = aSorted[nLast][3].DurationTo(@oEnd)
			aUncovered + [aSorted[nLast][3], @oEnd, oDuration]
		ok
		
		return aUncovered

	# Distance Calculations
	
	def DistanceBetween(cName1, cName2)
		oTime1 = NULL
		oTime2 = NULL
		
		# Try to find as points
		oTime1 = This.Point(cName1)
		oTime2 = This.Point(cName2)
		
		# If not points, try span starts
		if oTime1 = NULL
			aSpan = This.Span(cName1)
			if aSpan != NULL
				oTime1 = aSpan[1]
			ok
		ok
		
		if oTime2 = NULL
			aSpan = This.Span(cName2)
			if aSpan != NULL
				oTime2 = aSpan[1]
			ok
		ok
		
		if oTime1 != NULL and oTime2 != NULL
			return oTime1.DurationTo(oTime2)
		ok
		
		return NULL
		
	def TimeBetween(cName1, cName2)
		return This.DistanceBetween(cName1, cName2)

	# Utility Methods
	
	def SortedSpans()
		# Simple bubble sort by start time
		aSorted = @aSpans
		nLen = len(aSorted)
		
		for i = 1 to nLen - 1
			for j = 1 to nLen - i
				if aSorted[j][2] > aSorted[j + 1][2]
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
				if aSorted[j][2] > aSorted[j + 1][2]
					aTemp = aSorted[j]
					aSorted[j] = aSorted[j + 1]
					aSorted[j + 1] = aTemp
				ok
			next
		next
		
		return aSorted

	# Output Methods
	
	def ToSummary()
		cResult = "Timeline"
		
		if This.HasBoundaries()
			cResult += " from " + @oStart.ToString() + 
			           " to " + @oEnd.ToString()
		ok
		
		cResult += NL
		cResult += "Points: " + This.PointsCount() + NL
		cResult += "Spans: " + This.SpansCount() + NL
		
		if len(@aPoints) > 0
			cResult += NL + "Time Points:" + NL
			aSorted = This.SortedPoints()
			for aPoint in aSorted
				cResult += "  - " + aPoint[1] + 
				           " at " + aPoint[2].ToString() + NL
			next
		ok
		
		if len(@aSpans) > 0
			cResult += NL + "Time Spans:" + NL
			aSorted = This.SortedSpans()
			for aSpan in aSorted
				oDuration = aSpan[2].DurationTo(aSpan[3])
				cResult += "  - " + aSpan[1] + 
				           " from " + aSpan[2].ToString() + 
				           " to " + aSpan[3].ToString() +
				           " (" + oDuration.ToHuman() + ")" + NL
			next
		ok
		
		return cResult
		
	def Clear()
		@aPoints = []
		@aSpans = []
		return This
		
	def Copy()
		oNew = new stzTimeLine([
			:Start = @oStart,
			:End = @oEnd
		])
		
		for aPoint in @aPoints
			oNew.AddPoint(aPoint[1], aPoint[2])
		next
		
		for aSpan in @aSpans
			oNew.AddSpan(aSpan[1], aSpan[2], aSpan[3])
		next
		
		return oNew
		
		def Clone()
			return This.Copy()
