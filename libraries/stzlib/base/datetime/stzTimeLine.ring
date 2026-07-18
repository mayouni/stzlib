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

func IsStzTimeLine(p)
	if isObject(p) and classname(p) = "stztimeline"
		return 1
	else
		return 0
	ok

	def @IsStzTimeLine(p)
		return IsStzTimeLine(p)

class stzTimeLine from stzObject
	@cStart = NULL
	@cEnd = NULL
	@aPoints = []      # [[name, string_datetime], ...]
	@aSpans = []       # [[name, string_datetime, string_datetime], ...]

	# Display properties
	@nVizWidth = 52
	@nVizMinWidth = 30
	@nVizHeight = 5 # Will adjust autumatically to the required hight

	@cAxisChar = char(226) + char(148) + char(128)
	@cPointChar = char(226) + char(151) + char(143)
	@cMultiPointChar = char(226) + char(151) + char(137)
	@cBoundaryEndChar = char(226) + char(151) + char(139)
	@cSpanChar = "="
	@cSpanStartChar = char(226) + char(149) + char(158)
	@cSpanEndChar = char(226) + char(149) + char(161)
	@cBoundaryStartChar = "|"
	@cHighlightChar = char(226) + char(150) + char(136)
	@cArrowChar = char(226) + char(150) + char(186)
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
			if isList(pStart) and IsStartOrFromNamedParamList(pStart)
				pStart = pStart[2]
			ok
			if isList(pEnd) and IsEndOrToNamedParamList(pEnd)
				pEnd = pEnd[2]
			ok
		ok

		if isString(pStart)
			pStart = This._normalizeDateTime(pStart)

		ok

		if isString(pEnd)
			if StzFindFirst(" ", pEnd) = 0
				pEnd += " 23:59:59"
			ok
			pEnd = This._normalizeDateTime(pEnd)
		ok

		@cStart = StzDateTimeQ(pStart).ToString()
		@cEnd = StzDateTimeQ(pEnd).ToString()


	def Content()
		_aResult_ = [
			:Start = @cStart,
			:End = @cEnd,

			:Points = @aPoints,
			:Spans = @aSpans
		]

		return _aResult_

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
	
		pcLabel = StzUpper(pcLabel)
		_cPoint_ = This._normalizeDateTime(pDateTime)
	
		_oPoint_ = new stzDateTime(_cPoint_)
		_oStart_ = This.StartQ()
		_oEnd_ = This.EndQ()
	
		if _oPoint_ < _oStart_ or _oPoint_ > _oEnd_
			raise("Point '" + pcLabel + "' is outside timeline boundaries")
		ok
	
		if This.IsBlocked(_cPoint_)
			raise("Point '" + pcLabel + "' falls within a blocked span or blocked point")
		ok
	
		@aPoints + [pcLabel, _cPoint_]
	
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

		def AddInstant(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
	
			def AddInstantQ(pcLabel, pDateTime)
				return This.AddPointQ(pcLabel, pDateTime)

	def AddPoints(paPoints)
		_nLen_ = len(paPoints)
		for i = 1 to _nLen_
			This.AddPoint(paPoints[i][1], paPoints[i][2])
		next

		def AddMoments(paPoints)
			This.AddPoints(paPoints)

		def AddInstants(paPoints)
			This.AddPoints(paPoints)

	# Find the occurences of a given moment (by label)
	# on the timeline (returns its relative datetimes)
	def FindPoint(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		pcLabel = StzUpper(pcLabel)

		#--

		_acResult_ = []
		_nLen_ = len(@aPoints)

		for i = 1 to _nLen_
			if @aPoints[i][1] = pcLabel
				_acResult_ + @aPoints[i][2]
			ok
		next

		return _acResult_

		def FindMoment(pcLabel)
			return This.FindPoint(pcLabel)

		def FindInstant(pcLabel)
			return This.FindPoint(pcLabel)

	# Returns the datetime along with the position
	def FindPointXT(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		pcLabel = StzUpper(pcLabel)

		#--

		_aResult_ = []
		_nLen_ = len(@aPoints)

		for i = 1 to _nLen_
			if @aPoints[i][1] = pcLabel
				_aResult_ + [ @aPoints[i][2], i ]
			ok
		next

		return _aResult_

		def FindMomentXT(pcLabel)
			return This.FindPointXT(pcLabel)

		def FindInstantXT(pcLabel)
			return THis.FindPointXT(pcLabel)

	#--

	def Points()
		return @aPoints
		
		def PointsQ()
			_aResult_ = []
			_nLen_ = len(@aPoints)
			for i = 1 to _nLen_
				_aResult_ + [@aPoints[i][1], new stzDateTime(@aPoints[i][2])]
			next
			return _aResult_

		def TimePoints()
			return This.Points()

			def TimePointsQ()
				return This.PointsQ()
			
		def Moments()
			return This.Points()

			def MomentsQ()
				return This.PointsQ()

		def Instants()
			return This.Points()

			def InstantsQ()
				return This.PointsQ()

	def PointNames()
		# Return unique names only
		_acResult_ = []
		_acSeen_ = []
		_nLen_ = len(@aPoints)

		for i = 1 to _nLen_
			_cLabel_ = @aPoints[i][1]
			if StzFindFirst(_cLabel_, _acSeen_) = 0
				_acResult_ + _cLabel_
				_acSeen_ + _cLabel_
			ok
		next
	
		return _acResult_

		def MomentNames()
			return This.PointNames()

		def InstantNodes()
			return This.PointNames()

	def PointNamesXT()
		# Return names with occurrence counts: [["EVENT1", 3], ["EVENT2", 1]]
		_aResult_ = []
		_aCounts_ = []
	
		_nLen_ = len(@aPoints)
		for i = 1 to _nLen_
			_cLabel_ = @aPoints[i][1]
			_nPos_ = 0
	
			# Find if name already counted
			_nCountsLen_2 = len(_aCounts_)
			for j = 1 to _nCountsLen_2
				if _aCounts_[j][1] = _cLabel_
					_nPos_ = j
					exit
				ok
			next
	
			if _nPos_ = 0
				_aCounts_ + [_cLabel_, 1]
			else
				_aCounts_[_nPos_][2]++
			ok
		next
	
		return _aCounts_

		def InstantNamesXT()
			return This.PointNamesXT()

	def SpanNames()
		# Return unique names only
		_acResult_ = []
		_acSeen_ = []
		_nLen_ = len(@aSpans)

		for i = 1 to _nLen_
			_cLabel_ = @aSpans[i][1]
			if StzFindFirst(_cLabel_, _acSeen_) = 0
				_acResult_ + _cLabel_
				_acSeen_ + _cLabel_
			ok
		next

		return _acResult_

		def PeriodNames()
	       		return This.SpanNames()

	def SpanNamesXT()
		# Return names with occurrence counts: [["PHASE1", 2], ["PHASE2", 1]]
		_aResult_ = []
		_aCounts_ = []
	
		_nLen_ = len(@aSpans)
		for i = 1 to _nLen_
			_cLabel_ = @aSpans[i][1]
			_nPos_ = 0
	
			# Find if name already counted
			_nCountsLen_ = len(_aCounts_)
			for j = 1 to _nCountsLen_
				if _aCounts_[j][1] = _cLabel_
					_nPos_ = j
					exit
				ok
			next
	
			if _nPos_ = 0
				_aCounts_ + [_cLabel_, 1]
			else
				_aCounts_[_nPos_][2]++
			ok
		next
	
		return _aCounts_
    
	    def PeriodNamesXT()
	        return This.SpanNamesXT()

	# Getting a point datetime

	def Point(pcLabelOrDateTime)

		if NOT isString(pcLabelOrDateTime)
			StzRaise("Incorrect param type! pcLabelOrDateTime must be a string.")
		ok

		if StzIsDateTime(pcLabelOrDateTime) or
		   This._IsDateOnly(pcLabelOrDateTime) or
		   This._IsTimeOnly(pcLabelOrDateTime)

			return This.WhatsAt(pcLabelOrDateTime)
		ok

		#--

		_cLabel_ = StzUpper(pcLabelOrDateTime)

		_nLen_ = len(@aPoints)
		for i = 1 to _nLen_
			if @aPoints[i][1] = _cLabel_
				return @aPoints[i][2] # A datetime string
			ok
		next
		
		StzRaise("No timepoint found with the label (" + _cLabel_ + ")!")

		def PointQ(pcLabelOrDateTime)
			return StzDateTimeQ( This.Point(pcLabelOrDateTime) )

		def Moment(pcLabelOrDateTime)
			return This.Point(pcLabelOrDateTime)

			def MomentQ(pcLabelOrDateTime)
				return This.PointQ(pcLabelOrDateTime)

		def Instant(pcLabelOrDateTime)
			return This.Point(pcLabelOrDateTime)

			def InstantQ(pcLabelOrDateTime)
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

		def HasInstant(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

		#--

		def ContainsMoment(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

		def ContainsInstant(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

	# Removing points
	#TODO // Add Removing all the items with a given label

	def RemovePoint(pcLabelOrDateTime)
		_aPos_ = This.FindPointXT(pcLabelOrDateTime)
		if len(_aPos_) > 0
			del(@aPoints, _aPos_[1][2])
		ok

		def RemovePointQ(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)
			return This
		
		def RemoveMoment(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)

			def RemoveMomentQ(pcLabelOrDateTime)
				return This.RemovePointQ(pcLabelOrDateTime)

		#--
		
		def RemoveMInstant(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)

			def RemoveInstantQ(pcLabelOrDateTime)
				return This.RemovePointQ(pcLabelOrDateTime)

	# Renaming labels

	def RenameLabel(pcLabel, pcNewLabel)
		This.RenamePointLabel(pcLabel, pcNewLabel)
		This.RenameSpanLabel(pcLabel, pcNewLabel)

	def RenamePointLabel(pcLabel, pcNewLabel)
	
		if CheckParams()
			if isList(pcNewLabel) and IsWithOrByOrUsingNamedParamList(pcNewLabel)
				pcNewLabel = pcNewLabel[2]
			ok
		ok

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
		if NOT isString(pcNewLabel)
			StzRaise("Incorrect param type! pcNewLabel must be a string.")
		ok
	
		pcLabel = StzUpper(pcLabel)
		pcNewLabel = StzUpper(pcNewLabel)
	
		_nLen_ = len(@aPoints)
	
		for i = 1 to _nLen_
			if @aPoints[i][1] = pcLabel
				@aPoints[i][1] = pcNewLabel
			ok
		next
	
		def RenameMomentLabel(pcLabel, pcNewLabel)
			This.RenamePointLabel(pcLabel, pcNewLabel)

		def RenameInstantLabel(pcLabel, pcNewLabel)
			This.RenamePointLabel(pcLabel, pcNewLabel)


	def RenameSpanLabel(pcLabel, pcNewLabel)
	
		if CheckParams()
			if isList(pcNewLabel) and IsWithOrByOrUsingNamedParamList(pcNewLabel)
				pcNewLabel = pcNewLabel[2]
			ok
		ok

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
		if NOT isString(pcNewLabel)
			StzRaise("Incorrect param type! pcNewLabel must be a string.")
		ok
	
		pcLabel = StzUpper(pcLabel)
		pcNewLabel = StzUpper(pcNewLabel)
	
		_nLen_ = len(@aSpans)
	
		for i = 1 to _nLen_
			if @aSpans[i][1] = pcLabel
				@aSpans[i][1] = pcNewLabel
			ok
		next

	# How many points

	def CountPoints()
		return len(@aPoints)
		
		def NumberOfPoints()
			return This.CountPoints()

		def HowManyPoints()
			return This.CountPoints()

		#--

		def CountMoments()
			return This.CountPoints()

		def NumberOfMoments()
			return This.CountPoints()

		def HowManyMoments()
			return This.CountPoints()

		#--

		def CountOInstants()
			return This.CountPoints()

		def NumberOfInstants()
			return This.CountPoints()

		def HowManyInstants()
			return This.CountPoints()

	# Span Management (time periods with start and end)

	def AddSpans(paSpans)
		_nLen_ = len(paSpans)
		for i = 1 to _nLen_
			This.AddSpan(paSpans[i][1], paSpans[i][2], paSpans[i][3])
		next

		def AddPeriods(paSpans)
			This.AddSpans(paSpans)

	def AddSpan(pcLabel, pStart, pEnd)
	
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
	
		_cStart_ = This._normalizeDateTime(pStart)
		_cEnd_ = This._normalizeDateTime(pEnd)
	
		# Validate span: start must be strictly before end
		_oStart_ = new stzDateTime(_cStart_)
		_oEnd_ = new stzDateTime(_cEnd_)
		if _oStart_ >= _oEnd_
			raise("Error: Span '" + pcLabel + "' has invalid dates. Start time (" + 
				_cStart_ + ") must be before end time (" + _cEnd_ + ")")
		ok
	
		_oTLStart_ = This.StartQ()
		_oTLEnd_ = This.EndQ()
	
		if _oStart_ < _oTLStart_ or _oEnd_ > _oTLEnd_
			raise("Span '" + pcLabel + "' is outside timeline boundaries")
		ok
	
		if This.IsSectionBlocked(_cStart_, _cEnd_)
			raise("Span '" + pcLabel + "' overlaps with a blocked span")
		ok
	
		@aSpans + [pcLabel, _cStart_, _cEnd_]
	
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

		_acResult_ = []
		_nLen_ = len(@aSpans)

		pcLabel = StzUpper(pcLabel)
	
		for i = 1 to _nLen_
			if @aSpans[i][1] = pcLabel
				_acResult_ + [ @aSpans[i][2], @aSpans[i][3] ]
			ok
		next
	
		return _acResult_


		def FindPeriod(pcSpan)
			return This.FindSpan(pcSpan)

	# Returns the datetimes along with their positions
	def FindSpanXT(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		_aResult_ = []
		_nLen_ = len(@aSpans)

		pcLabel = StzUpper(pcLabel)

		for i = 1 to _nLen_
			if @aSpans[i][1] = pcLabel
				_aResult_ + [ [ @aSpans[i][2], @aSpans[i][3] ], i ]
			ok
		next

		return _aResult_

		def FindPeriodXT(pcSpan)
			return This.FindSpanXT(pcSpan)

	
	def Spans()
		return @aSpans

		def SpansQ()
			_aResult_ = []
			_nLen_ = len(@aSpans)
			for i = 1 to _nLen_
				_aResult_ + [
					@aSpans[i][1],
					new stzDateTime(@aSpans[i][2]),
					new stzDateTime(@aSpans[i][3])
				]
			next
			return _aResult_
		
		def Periods()
			return This.Spans()

		def PeriodsQ()
			return This.SpansQ()
			
	def Span(pcLabel)

		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		_nLen_ = len(@aSpans)
		for i = 1 to _nLen_
			if @aSpans[i][1] = pcLabel
				return [@aSpans[i][2], @aSpans[i][3]]
			ok
		next

		StzRaise("No span found with the lable ('" + pcLabel + "')!")
		
		def Period(_cLabel_)
			return This.Span(_cLabel_)

	def SpanStart(pcLabel)
		return This.Span(pcLabel)[1]

		def SpanStartQ(pcLabel)
			return StzDateTimeQ(This.SpanStart(pcLabel))

	def SpanEnd(pcLabel)
		return This.Span(pcLabel)[2]

		def SpanEndQ(pcLabel)
			return StzDateTimeQ(This.SpanEnd(pcLabel))

	def SpanDuration(pcLabel)
		return This.SpanStartQ(pcLabel).DurationTo(This.SpanEnd(pcLabel), :InSeconds)

		def SpanDurationQ(pcLabel)
			return new stzDuration(This.SpanDuration(pcLabel))

	def HasSpan(pcLabel)
		return len( This.FindSpan(pcLabel) ) > 0
		
	def RemoveSpan(pcLabel)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		pcLabel = StzUpper(pcLabel)

		_nPos_ = 0
		_nLen_ = len(@aSpans)

		for i = 1 to _nLen_
			if @aSpans[i][1] = pcLabel
				_nPos_ = i
				exit
			ok
		next

		if _nPos_ > 0
			del(@aSpans, _nPos_)
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
			_cDateTime_ = pDateTime
		else
			_cDateTime_ = StzDateTimeQ(pDateTime).ToString()
		ok

		if _cDateTime_ = ""
			StzRaise("Incorrect param value! pDateTime must not be empty.")
		ok

		# Detect search mode
		_bDateOnly_ = This._isDateOnly(_cDateTime_)
		_bTimeOnly_ = This._isTimeOnly(_cDateTime_)

		_aResult_ = []
	
		if _bDateOnly_
			# Match all times on this date
			_oDate_ = new stzDate(_cDateTime_)
			_nLen_ = len(@aPoints)
			for i = 1 to _nLen_
				if StzLeft(@aPoints[i][2], 10) = _cDateTime_
					_aResult_ + [@aPoints[i][1], :Point]
				ok
			next
	
			_nLen_ = len(@aSpans)
			for i = 1 to _nLen_
				_oSpanStart_ = new stzDate(StzLeft(@aSpans[i][2], 10))
				_oSpanEnd_ = new stzDate(StzLeft(@aSpans[i][3], 10))
				if _oDate_ >= _oSpanStart_ and _oDate_ <= _oSpanEnd_
					_aResult_ + [@aSpans[i][1], :Span]
				ok
			next
	
		but _bTimeOnly_
			# Match this time on all dates
			_cTime_ = _cDateTime_
			_nLen_ = len(@aPoints)
			for i = 1 to _nLen_
				if StzRight(@aPoints[i][2], 8) = _cTime_
					_aResult_ + [@aPoints[i][1], :Point]
				ok
			next

	
			_nLen_ = len(@aSpans)
			for i = 1 to _nLen_
				_oTime_ = new stzTime(_cTime_)
				_oStart_ = new stzDateTime(@aSpans[i][2])
				_oEnd_ = new stzDateTime(@aSpans[i][3])
	
				# Check if time falls within span's time range

				_oSpanStartTime_ = new stzTime(StzRight(@aSpans[i][2], 8))
				_oSpanEndTime_ = new stzTime(StzRight(@aSpans[i][3], 8))
	
				if _oTime_ >= _oSpanStartTime_ or _oTime_ <= _oSpanEndTime_
					_aResult_ + [@aSpans[i][1], :Span]
				ok
			next
	        
		else
			# Exact datetime match
			_oDateTime_ = new stzDateTime(_cDateTime_)
	
			_nLen_ = len(@aPoints)
			for i = 1 to _nLen_
				if StzDateTimeQ(@aPoints[i][2]).IsEqualTo(_oDateTime_)
					_aResult_ + [@aPoints[i][1], :Point]
				ok
			next
	
			_nLen_ = len(@aSpans)
			for i = 1 to _nLen_
				_oStart_ = new stzDateTime(@aSpans[i][2])
				_oEnd_ = new stzDateTime(@aSpans[i][3])
				if _oDateTime_ >= _oStart_ and _oDateTime_ <= _oEnd_
					_aResult_ + [@aSpans[i][1], :Span]
				ok
			next
		ok
	
		return _aResult_

	def WhatsAtXT(pDateTime, pMode)
		# Explicit mode control: :DateOnly, :TimeOnly, or :Exact

		if isString(pDateTime)
			_cDateTime_ = pDateTime
		else
			_cDateTime_ = StzDateTimeQ(pDateTime).ToString()
		ok
	
		if _cDateTime_ = ""
			StzRaise("Incorrect param value! pDateTime must not be empty.")
		ok

		_cMode_ = :Exact
		if isList(pMode) and len(pMode) = 2
			_cMode_ = pMode[2]
		ok
	
		_aResult_ = []
	
		switch _cMode_
		on :DateOnly
			_cDate_ = StzLeft(_cDateTime_, 10)
			_nLen_ = len(@aPoints)
			for i = 1 to _nLen_
				if StzLeft(@aPoints[i][2], 10) = _cDate_
					_aResult_ + [@aPoints[i][1], :Point]
				ok
			next
	
			_nLen_ = len(@aSpans)
			for i = 1 to _nLen_
				_cSpanStart_ = StzLeft(@aSpans[i][2], 10)
				_cSpanEnd_ = StzLeft(@aSpans[i][3], 10)
				if _cDate_ >= _cSpanStart_ and _cDate_ <= _cSpanEnd_
					_aResult_ + [@aSpans[i][1], :Span]
				ok
			next
	
		on :TimeOnly
			_cTime_ = StzRight(_cDateTime_, 8)
			_nLen_ = len(@aPoints)
			for i = 1 to _nLen_
				if StzRight(@aPoints[i][2], 8) = _cTime_
					_aResult_ + [@aPoints[i][1], :Point]
				ok
			next
	        
			_nLen_ = len(@aSpans)
			for i = 1 to _nLen_
				_cSpanStartTime_ = StzRight(@aSpans[i][2], 8)
				_cSpanEndTime_ = StzRight(@aSpans[i][3], 8)
				if _cTime_ >= _cSpanStartTime_ or _cTime_ <= _cSpanEndTime_
					_aResult_ + [@aSpans[i][1], :Span]
				ok
			next
	
		other
			return This.WhatsAt(_cDateTime_)
		off
	
		return _aResult_

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
			if isList(pEnd) and IsAndNamedParamList(pEnd)
				pEnd = pEnd[2]
			ok
		ok

		if isString(pStart)
			_cStart_ = pStart
		else
			_cStart_ = StzDateTimeQ(pStart).ToString()
		ok

		if isString(pEnd)
			_cEnd_ = pEnd
		else
			_cEnd_ = StzDateTimeQ(pEnd).ToString()
		ok

		if _cStart_ = "" or _cEnd_ = ''
			StzRaise("Incorrect params values! pStart and pEnd must not be empty.")
		ok

		_oStart_ = new stzDateTime(_cStart_)
		_oEnd_ = new stzDateTime(_cEnd_)
		
		_aResult_ = []
		_nLen_ = len(@aPoints)

		for i = 1 to _nLen_
			_oPoint_ = new stzDateTime(@aPoints[i][2])
			if _oPoint_ >= _oStart_ and _oPoint_ <= _oEnd_
				_aResult_ + @aPoints[i][1]
			ok
		next

		return _aResult_
		

		def MomentsBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		def WhatsBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		def HappeningBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		def WhatHappenedBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)

		#--

		def InstantsBetween(pStart, pEnd)
			return This.PointsBetween(pStart, pEnd)


	def SpansBetween(pStart, pEnd)

		if isString(pStart)
			_cStart_ = pStart
		else
			_cStart_ = StzDateTimeQ(pStart).ToString()
		ok

		if isString(pEnd)
			_cEnd_ = pEnd
		else
			_cEnd_ = StzDateTimeQ(pEnd).ToString()
		ok

		if _cStart_ = "" or _cEnd_ = ''
			StzRaise("Incorrect params values! pStart and pEnd must not be empty.")
		ok

		_oStart_ = new stzDateTime(_cStart_)
		_oEnd_ = new stzDateTime(_cEnd_)
		
		_aResult_ = []
		_nLen_ = len(@aSpans)

		for i = 1 to _nLen_
			_oSpanStart_ = new stzDateTime(@aSpans[i][2])
			_oSpanEnd_ = new stzDateTime(@aSpans[i][3])
			# Include spans that overlap with the range
			if _oSpanEnd_ >= _oStart_ and _oSpanStart_ <= _oEnd_
				_aResult_ + @aSpans[i][1]
			ok
		next

		return _aResult_

		def PeriodsBetween(pStart, pEnd)
			return This.SpansBetween(pStart, pEnd)

	def SpansOverlapping(pDateTime)

		if isString(pDateTime)
			_cDateTime_ = pDateTime
		else
			_cDateTime_ = StzDateTimeQ(pDateTime).ToString()
		ok

		if _cDateTime_ = ""
			StzRaise("Incorrect param value! pDateTime must not be empty.")
		ok

		_oDateTime_ = new stzDateTime(_cDateTime_)
		
		_aResult_ = []
		_nLen_ = len(@aSpans)

		for i = 1 to _nLen_
			_oStart_ = new stzDateTime(@aSpans[i][2])
			_oEnd_ = new stzDateTime(@aSpans[i][3])

			if _oDateTime_ >= _oStart_ and _oDateTime_ <= _oEnd_
				_aResult_ + @aSpans[i][1]
			ok
		next

		return _aResult_
		

		def SpansContaining(pDateTime)
			return This.SpansOverlapping(pDateTime)

		def PeriodsOverlapping(pDateTime)
			return THis.SpansOverlapping(pDateTime)

		def PeriodsContaining(pDateTime)
			return This.SpansOverlapping(pDateTime)


	# Overlap Detection
	
	def HasOverlaps()

		_nLen_ = len(@aSpans)

		for i = 1 to _nLen_ - 1
			for j = i + 1 to _nLen_
				_oStart1_ = new stzDateTime(@aSpans[i][2])
				_oEnd1_ = new stzDateTime(@aSpans[i][3])
				_oStart2_ = new stzDateTime(@aSpans[j][2])
				_oEnd2_ = new stzDateTime(@aSpans[j][3])
				
				# Check if spans overlap
				if _oStart1_ < _oEnd2_ and _oStart2_ < _oEnd1_
					return TRUE
				ok
			next
		next

		return FALSE
		
	def OverlappingSpans()

		_aResult_ = []
		_nLen_ = len(@aSpans)
		
		for i = 1 to _nLen_ - 1
			for j = i + 1 to _nLen_
				_oStart1_ = new stzDateTime(@aSpans[i][2])
				_oEnd1_ = new stzDateTime(@aSpans[i][3])
				_oStart2_ = new stzDateTime(@aSpans[j][2])
				_oEnd2_ = new stzDateTime(@aSpans[j][3])
				
				# Check if spans overlap
				if _oStart1_ < _oEnd2_ and _oStart2_ < _oEnd1_
					# Calculate overlap duration
					_oOverlapStart_ = NULL
					_oOverlapEnd_ = NULL
					
					if _oStart1_ >= _oStart2_
						_oOverlapStart_ = _oStart1_
					else
						_oOverlapStart_ = _oStart2_
					ok
					
					if _oEnd1_ <= _oEnd2_
						_oOverlapEnd_ = _oEnd1_
					else
						_oOverlapEnd_ = _oEnd2_
					ok
					
					_nDuration_ = _oOverlapStart_.DurationTo(_oOverlapEnd_, :InSeconds)
					
					_aResult_ + [
						@aSpans[i][1],
						@aSpans[j][1],
						_nDuration_
					]
				ok
			next
		next
		return _aResult_

		def OverlappingPeriods()
			return THis.OverlappingSpans()

	# Gap Analysis
	
	def Gaps()
		if len(@aSpans) = 0
			return []
		ok
		
		# Sort spans by start time
		_aSorted_ = This.SortedSpans()
		_nLen_ = len(_aSorted_)
	
		_aGaps_ = []
		for i = 1 to _nLen_ - 1
			_oEnd1_ = new stzDateTime(_aSorted_[i][3])
			_oStart2_ = new stzDateTime(_aSorted_[i + 1][2])
			
			if _oEnd1_ < _oStart2_
				_nDuration_ = _oEnd1_.DurationTo(_oStart2_, :InSeconds)
				_aGaps_ + [
					:After = _aSorted_[i][1],
					:Before = _aSorted_[i + 1][1],
					:Duration = _nDuration_
				]
			ok
		next
	
		return _aGaps_
		
	def UncoveredPeriods()
		if len(@aSpans) = 0
			return []
		ok
		
		_aSorted_ = This.SortedSpans()
		_nLen_ = len(_aSorted_)
		_aUncovered_ = []
		
		_oStart_ = This.StartQ()
		_oEnd_ = This.EndQ()
		
		# Check gap before first span
		_oFirstStart_ = new stzDateTime(_aSorted_[1][2])
		if _oFirstStart_ > _oStart_
			_nDuration_ = _oStart_.DurationTo(_oFirstStart_, :InSeconds)
			_aUncovered_ + [
				:Start = @cStart,
				:End = _aSorted_[1][2],
				:Duration = _nDuration_
			]
		ok
		
		# Check gaps between spans
		for i = 1 to _nLen_ - 1
			_oEnd1_ = new stzDateTime(_aSorted_[i][3])
			_oStart2_ = new stzDateTime(_aSorted_[i + 1][2])
			
			if _oEnd1_ < _oStart2_
				_nDuration_ = _oEnd1_.DurationTo(_oStart2_, :InSeconds)
				_aUncovered_ + [
					:Start = _aSorted_[i][3],
					:End = _aSorted_[i + 1][2],
					:Duration = _nDuration_
				]
			ok
		next
		
		# Check gap after last span
		_oLastEnd_ = new stzDateTime(_aSorted_[_nLen_][3])
		if _oLastEnd_ < _oEnd_
			_nDuration_ = _oLastEnd_.DurationTo(_oEnd_, :InSeconds)
			_aUncovered_ + [
				:Start = _aSorted_[_nLen_][3],
				:End = @cEnd,
				:Duration = _nDuration_
			]
		ok
		
		return _aUncovered_

		def UncoveredSpans()
			return This.UncoveredPeriods()

	# Duration Calculations
	
	def DurationXT(_cLabel1_, _cLabel2_)
		if CheckParams()
			if isList(_cLabel1_) and IsFromOrBetweenNamedParamList(_cLabel1_)
				_cLabel1_ = _cLabel1_[2]
			ok

			if isList(_cLabel2_) and IsToOrAndNamedParamList(_cLabel2_)
				_cLabel2_ = _cLabel2_[2]
			ok
		ok
		
		return This.PointQ(_cLabel1_).DurationTo(This.Point(_cLabel2_), :InSeconds)

		#< @FunctionFluentForm

		def DurationXTQ(_cLabel1_, _cLabel2_)
			return new stzDuration( This.DurationXT(_cLabel1_, _cLabel2_) )

		#>

		#< @FunctionAlternativeForms

		def Interval(_cLabel1_, _cLabel2_)
			return This.DurationXT(_cLabel1_, _cLabel2_)

			def IntervalQ(_cLabel1_, _cLabel2_)
				return This.DurationXTQ(_cLabel1_, _cLabel2_)
	
		def DurationBetween(_cLabel1_, _cLabel2_)
			return This.DurationXT(_cLabel1_, _cLabel2_)
		
			def DurationBetweenQ(_cLabel1_, _cLabel2_)
				return This.DurationXTQ(_cLabel1_, _cLabel2_)
	
		def TimeBetween(_cLabel1_, _cLabel2_)
			return This.DurationXT(_cLabel1_, _cLabel2_)

			def TimeBetweenQ(_cLabel1_, _cLabel2_)
				return This.DurationXTQ(_cLabel1_, _cLabel2_)

		def Distance(_cLabel1_, _cLabel2_)
			# Accept either positional (start, end) or named-param
			# (:From = "start", :To = "end") forms.
			if isList(_cLabel1_) and len(_cLabel1_) = 2 and isString(_cLabel1_[1]) and lower(_cLabel1_[1]) = "from"
				_cLabel1_ = _cLabel1_[2]
			ok
			if isList(_cLabel2_) and len(_cLabel2_) = 2 and isString(_cLabel2_[1]) and lower(_cLabel2_[1]) = "to"
				_cLabel2_ = _cLabel2_[2]
			ok
			return This.DurationXT(_cLabel1_, _cLabel2_)

			def DistanceQ(_cLabel1_, _cLabel2_)
				return This.DurationXTQ(_cLabel1_, _cLabel2_)

		def IntervalBetween(_cLabel1_, _cLabel2_)
			return This.DurationXT(_cLabel1_, _cLabel2_)
	
			def IntervalBetweenQ(_cLabel1_, _cLabel2_)
				return This.DurationXTQ(_cLabel1_, _cLabel2_)
		#>

	# Utility Methods
	
	def SortedSpans()
		# Simple bubble sort by start time
		_aSorted_ = @aSpans
		_nLen_ = len(_aSorted_)
		
		for i = 1 to _nLen_ - 1
			for j = 1 to _nLen_ - i
				_oTime1_ = new stzDateTime(_aSorted_[j][2])
				_oTime2_ = new stzDateTime(_aSorted_[j + 1][2])
				if _oTime1_ > _oTime2_
					_aTemp_ = _aSorted_[j]
					_aSorted_[j] = _aSorted_[j + 1]
					_aSorted_[j + 1] = _aTemp_
				ok
			next
		next
		
		return _aSorted_

		def SortedPeriods()
			return This.SortedSpans()
		
	def SortedPoints()
		# Simple bubble sort by time
		_aSorted_ = @aPoints
		_nLen_ = len(_aSorted_)
		
		for i = 1 to _nLen_ - 1
			for j = 1 to _nLen_ - i
				_oTime1_ = new stzDateTime(_aSorted_[j][2])
				_oTime2_ = new stzDateTime(_aSorted_[j + 1][2])
				if _oTime1_ > _oTime2_
					_aTemp_ = _aSorted_[j]
					_aSorted_[j] = _aSorted_[j + 1]
					_aSorted_[j + 1] = _aTemp_
				ok
			next
		next
		
		return _aSorted_

		def SortedMoments()
			return This.SortedPoints()

		def SortedInstants()
			return This.SortedPoints()

	# Output Methods
	
	def Summary()

		_aResult_ = []
		
		# Add boundaries
		_aResult_ + [ "start", @cStart ] + 
			[ "end", @cEnd ] +
			[ "totalduration", This.DurationQ().ToHuman() ]
		
		# Add counts
		_aResult_ + [ "countpoints", This.CountPoints() ] +
			[ "countspans", This.CountSpans() ]
		
		# Add sorted points
		if len(@aPoints) > 0
			_aPoints_ = []
			_aSorted_ = This.SortedPoints()
			_nLen_ = len(_aSorted_)
			for i = 1 to _nLen_
				_aPoints_ + [ "name", _aSorted_[i][1] ] +
					[ "datetime", _aSorted_[i][2] ]
			next
			_aResult_ + [ "points", _aPoints_ ]
		ok
		
		# Add sorted spans with durations
		if len(@aSpans) > 0

			_aSpans_ = []
			_aSorted_ = This.SortedSpans()
			_nLen_ = len(_aSorted_)

			for i = 1 to _nLen_
				_oStart_ = new stzDateTime(_aSorted_[i][2])
				_oDuration_ = StzDurationQ(_oStart_.DurationTo(_aSorted_[i][3], :InSeconds))
				_aSpans_ + [ "name", _aSorted_[i][1] ] +
					[ "start", _aSorted_[i][2] ] +
					[ "end", _aSorted_[i][3] ] +
					[ "duration", _oDuration_.ToHuman() ]
			next

			_aResult_ + [ "spans", _aSpans_ ]
		ok
		
		return _aResult_
		
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
		_nRequestedWidth_ = @nVizWidth
		_bShowTable_ = TRUE
		_cTableType_ = :Normal
	
		# Process parameters
		if isList(paParams)
			_nLen_ = len(paParams)
	
			for i = 1 to _nLen_
				if isList(paParams[i]) and len(paParams[i]) = 2
					switch paParams[i][1]
					on :Width
						_nRequestedWidth_ = max([30, paParams[i][2]])
	
					on :Height
						@nVizHeight = max([3, paParams[i][2]])
	
					on :Highlight
						@cHighlight = paParams[i][2]
	
					on :ShowTable
						_bShowTable_ = paParams[i][2]
	
					on :TableType
						_cTableType_ = paParams[i][2]
					off
				ok
			next
		ok
	
		# Collect all timepoints
		_aTimepoints_ = _collectAllTimepoints()

		# Calculate layout
		_oLayout_ = _calculateVizLayout()
		if _oLayout_ = ""
			return "Cannot display timeline"
		ok
	
		# Initialize canvas
		_initVizCanvas(_nRequestedWidth_, _oLayout_[:total_height])
	
		# Draw visual elements
		_drawAxis(_oLayout_)
		_drawBlockedSpans(_oLayout_, _aTimepoints_)
		_drawBlockedPoints(_oLayout_, _aTimepoints_)
		_drawSpans(_oLayout_, _aTimepoints_)
		_drawPoints(_oLayout_, _aTimepoints_)
		_drawLabels(_oLayout_, _aTimepoints_)
		_drawNumbers(_oLayout_, _aTimepoints_)
	
		# Build output
		_cViz_ = _vizCanvasToString()
	
		if not _bShowTable_
			return _cViz_
		ok
	
		# Add table based on type
		_cTable_ = ""
		if _cTableType_ = :Statistical
			_cTable_ = StzTableQ(_buildStatisticalTable()).ToString()
		else
			_cTable_ = _buildTimepointsTable(_aTimepoints_)
		ok
	
		# Workaround: replacing eventual --(*) with -(*)-
		#TODO // Resolve it logically at construction

		_cViz_ = StzReplace(_cViz_, char(226) + char(148) + char(128) + char(226) + char(148) + char(128) + char(226) + char(151) + char(139) + char(226) + char(151) + char(143) + char(226) + char(150) + char(186), char(226) + char(148) + char(128) + char(226) + char(148) + char(128) + char(226) + char(148) + char(128) + char(226) + char(151) + char(143) + char(226) + char(151) + char(139) + char(226) + char(148) + char(128) + char(226) + char(150) + char(186))

		return _cViz_ + nl + nl + _cTable_
	
	def Stats()
		return _buildStatisticalTable()
	
	def ShowShort()
		? This.ToStringShort()
	
	def ToStringShort()
	
	    # Collect timepoints
	    _aTimepoints_ = _collectAllTimepoints()
	
	    # Calculate layout
	    _oLayout_ = _calculateVizLayout()
	    if _oLayout_ = NULL
	        return "Cannot display timeline"
	    ok
	
	    # Initialize canvas
	    _initVizCanvas(@nVizWidth, _oLayout_[:total_height])
	
	    # Draw visual elements
	    _drawAxis(_oLayout_)
	    _drawSpans(_oLayout_, _aTimepoints_)
	    _drawPoints(_oLayout_, _aTimepoints_)
	    _drawLabels(_oLayout_, _aTimepoints_)
	    _drawNumbers(_oLayout_, _aTimepoints_)
	
	    # Return only canvas (no table)
	    return _vizCanvasToString()


	# Highlight Visualization Methods
	
	def VizFindMoments(_cLabel_)
		@cHighlight = _cLabel_
		_cResult_ = This.ToString()
		@cHighlight = NULL
		return _cResult_
		
		def VizFindMoment(_cLabel_)
			return This.VizFindMoments(_cLabel_)
			
		def VizFindPoint(_cLabel_)
			return This.VizFindMoments(_cLabel_)
			
		def VizFindPoints(_cLabel_)
			return This.VizFindMoments(_cLabel_)
			
	def VizFindSpans(_cLabel_)
		@cHighlight = _cLabel_
		_cResult_ = This.ToString()
		@cHighlight = NULL
		return _cResult_
		
		def VizFindSpan(_cLabel_)
			return This.VizFindSpans(_cLabel_)
			
		def VizFindPeriod(_cLabel_)
			return This.VizFindSpans(_cLabel_)
			
		def VizFindPeriods(_cLabel_)
			return This.VizFindSpans(_cLabel_)


	# Hihlighting the uncovered spans in the timeline

	def ShowUncovered()
	    ? This.ToStringUncovered()
	
	def ToStringUncovered()
	    
	    # Get uncovered periods
	    _aUncovered_ = This.UncoveredPeriods()
	    if len(_aUncovered_) = 0
	        return "Timeline is fully covered by spans"
	    ok
	    
	    # Collect timepoints - same logic as Show()
	    _aTimepoints_ = _collectAllTimepoints()
	    
	    # Calculate layout
	    _oLayout_ = _calculateVizLayout()
	    if _oLayout_ = NULL
	        return "Cannot display timeline"
	    ok
	    
	    # Initialize canvas
	    _initVizCanvas(@nVizWidth, _oLayout_[:total_height])
	    
	    # Draw visual elements
	    _drawAxis(_oLayout_)
	    _drawBlockedSpans(_oLayout_, _aTimepoints_)
	    _drawBlockedPoints(_oLayout_, _aTimepoints_)
	    _drawSpans(_oLayout_, _aTimepoints_)
	    _drawUncoveredRegions(_oLayout_, _aUncovered_)
	    _drawPoints(_oLayout_, _aTimepoints_)
	    _drawNumbers(_oLayout_, _aTimepoints_)
	    
	    # Build output
	    _cViz_ = _vizCanvasToString()
	    _cTable_ = _buildTimepointsTable(_aTimepoints_)
	    
	    return _cViz_ + nl + nl + _cTable_

	#-------------------------------------#
	#  MANAGING BLOCKED POINTS AND SPANS  #
	#-------------------------------------#

	def AddBlockedPoint(pDateTime)
		_cPoint_ = This._normalizeDateTime(pDateTime)
		_oPoint_ = new stzDateTime(_cPoint_)
		_oStart_ = This.StartQ()
		_oEnd_ = This.EndQ()

		if _oPoint_ < _oStart_ or _oPoint_ > _oEnd_
			raise("Blocked point is outside timeline boundaries")
		ok

		if StzFindFirst(_cPoint_, @aBlockedPoints) = 0
			@aBlockedPoints + _cPoint_
		ok
	
		def AddBlockedPointQ(pDateTime)
			This.AddBlockedPoint(pDateTime)
			return This
	
	def AddBlockedPoints(paDateTimes)
		_nLen_ = len(paDateTimes)
		for i = 1 to _nLen_
			This.AddBlockedPoint(paDateTimes[i])
		next

	def RemoveBlockedPoint(pDateTime)
		_cPoint_ = This._normalizeDateTime(pDateTime)
		_nPos_ = StzFindFirst(_cPoint_, @aBlockedPoints)
		if _nPos_ > 0
			del(@aBlockedPoints, _nPos_)
		ok

		def RemoveBlockedPointQ(pDateTime)
			This.RemoveBlockedPoint(pDateTime)
			return This

	def BlockedPoints()
		return @aBlockedPoints

	def BlockedPointsQ()
		_aResult_ = []
		_nLen_ = len(@aBlockedPoints)
		for i = 1 to _nLen_
			_aResult_ + new stzDateTime(@aBlockedPoints[i])
		next
		return _aResult_

	def IsPointBlocked(pDateTime)
		if isString(pDateTime)
			_cDateTime_ = pDateTime
		else
			_cDateTime_ = StzDateTimeQ(pDateTime).ToString()
		ok
	
		_oDateTime_ = new stzDateTime(_cDateTime_)
		_nLen_ = len(@aBlockedPoints)
	
		for i = 1 to _nLen_
			_oBlocked_ = new stzDateTime(@aBlockedPoints[i])
			if _oDateTime_.IsEqualTo(_oBlocked_)
				return TRUE
			ok
		next
	
		return FALSE

	def IsBlocked(pDateTime)
		if isList(pDateTime) and len(pDateTime) = 2
			return This.IsSectionBlocked(pDateTime[1], pDateTime[2])
		ok
	
		# Check both blocked points and blocked spans
		if This.IsPointBlocked(pDateTime)
			return TRUE
		ok
	
		if isString(pDateTime)
			_cDateTime_ = pDateTime
		else
			_cDateTime_ = StzDateTimeQ(pDateTime).ToString()
		ok
	
		_oDateTime_ = new stzDateTime(_cDateTime_)
		_nLen_ = len(@aBlockedSpans)
	
		for i = 1 to _nLen_
			_oStart_ = new stzDateTime(@aBlockedSpans[i][2])
			_oEnd_ = new stzDateTime(@aBlockedSpans[i][3])
			if _oDateTime_ >= _oStart_ and _oDateTime_ <= _oEnd_
				return TRUE
			ok
		next
	
		return FALSE

	def IsSectionBlocked(pStart, pEnd)
		if isString(pStart)
			_cStart_ = pStart
		else
			_cStart_ = StzDateTimeQ(pStart).ToString()
		ok
	
		if isString(pEnd)
			_cEnd_ = pEnd
		else
			_cEnd_ = StzDateTimeQ(pEnd).ToString()
		ok
	
		_oStart_ = new stzDateTime(_cStart_)
		_oEnd_ = new stzDateTime(_cEnd_)
		_nLen_ = len(@aBlockedSpans)
	
		for i = 1 to _nLen_
			_oBlockStart_ = new stzDateTime(@aBlockedSpans[i][2])
			_oBlockEnd_ = new stzDateTime(@aBlockedSpans[i][3])
			if _oStart_ < _oBlockEnd_ and _oEnd_ > _oBlockStart_
				return TRUE
			ok
		next
	
		# Also check blocked points within range
		_nLen_ = len(@aBlockedPoints)
		for i = 1 to _nLen_
			_oPoint_ = new stzDateTime(@aBlockedPoints[i])
			if _oPoint_ >= _oStart_ and _oPoint_ <= _oEnd_
				return TRUE
			ok
		next
	
		return FALSE
	
		def IsBlockedSection(pStart, pEnd)
			return This.IsSectionBlocked(pStart, pEnd)
	
	#---
	
	def AddBlockedSpan(pcLabel, pStart, pEnd)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
	
		_cStart_ = This._normalizeDateTime(pStart)
		_cEnd_ = This._normalizeDateTime(pEnd)
	
		_oStart_ = new stzDateTime(_cStart_)
		_oEnd_ = new stzDateTime(_cEnd_)
		if _oStart_ >= _oEnd_
			raise("Error: Blocked span '" + pcLabel + "' has invalid dates.")
		ok
	
		_oTLStart_ = This.StartQ()
		_oTLEnd_ = This.EndQ()
	
		if _oStart_ < _oTLStart_ or _oEnd_ > _oTLEnd_
			raise("Blocked span '" + pcLabel + "' is outside timeline boundaries")
		ok
	
		@aBlockedSpans + [StzUpper(pcLabel), _cStart_, _cEnd_]
	
		def AddBlockedSpanQ(pcLabel, pStart, pEnd)
			This.AddBlockedSpan(pcLabel, pStart, pEnd)
			return This
	
	def RemoveBlockedSpan(pcLabel)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok
	
		pcLabel = StzUpper(pcLabel)
		_nPos_ = 0
		_nLen_ = len(@aBlockedSpans)
	
		for i = 1 to _nLen_
			if @aBlockedSpans[i][1] = pcLabel
				_nPos_ = i
				exit
			ok
		next
	
		if _nPos_ > 0
			del(@aBlockedSpans, _nPos_)
		ok
	
		def RemoveBlockedSpanQ(pcLabel)
			This.RemoveBlockedSpan(pcLabel)
			return This
	
	def BlockedSpans()
		return @aBlockedSpans
	
		def BlockedSpansQ()
			_aResult_ = []
			_nLen_ = len(@aBlockedSpans)
			for i = 1 to _nLen_
				_aResult_ + [
					@aBlockedSpans[i][1],
					new stzDateTime(@aBlockedSpans[i][2]),
					new stzDateTime(@aBlockedSpans[i][3])
				]
			next
			return _aResult_


	#-----------#
	PRIVATE
	#-----------#
	# Canvas Operations
	
	def _initVizCanvas(nWidth, nHeight)
		@acVizCanvas = []
		for i = 1 to nHeight
			_aRow_ = []
			for j = 1 to nWidth
				_aRow_ + " "
			next
			@acVizCanvas + _aRow_
		next
		
	def _setVizChar(_nRow_, nCol, _cChar_)
		if _nRow_ >= 1 and _nRow_ <= len(@acVizCanvas) and
		   nCol >= 1 and nCol <= len(@acVizCanvas[1])
			@acVizCanvas[_nRow_][nCol] = _cChar_
		ok
	
	def _setVizString(_nRow_, nCol, cStr)
		_nLen_ = StzLen(cStr)
		for i = 1 to _nLen_
			_setVizChar(_nRow_, nCol + i - 1, cStr[i])
		next
	
	# Layout Calculation
	
	def _calculateVizLayout()
		
		_nTotalRows_ = 0
	
		# Calculate needed span rows dynamically
		_nSpanRows_ = 0
		if len(@aSpans) > 0
			# Auto-calculate required height
			_nRequiredHeight_ = This._calculateRequiredVizHeight()
			@nVizHeight = max([@nVizHeight, _nRequiredHeight_])
			_nSpanRows_ = @nVizHeight - 3  # Reserve 3 rows for labels, axis, numbers
		ok
		
		# Spans area (only if needed)
		_nSpansStart_ = 0
		if _nSpanRows_ > 0
			_nSpansStart_ = _nTotalRows_ + 1
			_nTotalRows_ += _nSpanRows_
		ok
		
		# Point labels row (above axis, separate from spans)
		_nPointLabelsRow_ = 0
		if len(@aPoints) > 0
			_nPointLabelsRow_ = _nTotalRows_ + 1
			_nTotalRows_ += 1
		ok
		
		# Axis row
		_nAxisRow_ = _nTotalRows_ + 1
		_nTotalRows_ += 1
		
		# Numbers row (only if there are points or spans)
		_nNumbersRow_ = 0
		if len(@aPoints) > 0 or len(@aSpans) > 0
			_nNumbersRow_ = _nTotalRows_ + 1
			_nTotalRows_ += 1
		ok
		
		return [
			:total_height = _nTotalRows_,
			:labels_row = _nPointLabelsRow_,
			:spans_start = _nSpansStart_,
			:span_rows = _nSpanRows_,
			:axis_row = _nAxisRow_,
			:numbers_row = _nNumbersRow_
		]
		
		# Position Mapping & Timepoint Collection
		
		def _timeToPosition(_cDateTime_)
			
			_oStart_ = This.StartQ()
			_oEnd_ = This.EndQ()
			_oTime_ = new stzDateTime(_cDateTime_)
			
			_nTotalDuration_ = _oStart_.DurationTo(@cEnd, :InSeconds)
			if _nTotalDuration_ = 0
				return 1
			ok
			
			_nTimeDuration_ = _oStart_.DurationTo(_cDateTime_, :InSeconds)
			
			_nCanvasWidth_ = len(@acVizCanvas[1])
			_nPosition_ = ceil((_nTimeDuration_ * (_nCanvasWidth_ - 2)) / _nTotalDuration_) + 1
			
			return max([1, min([_nPosition_, _nCanvasWidth_])])
		
	def _collectAllTimepoints()
		# Returns: [[index, datetime, label, description, type], ...]
		_aTimepoints_ = []
		
		# Add start boundary (NO INDEX)
		_aTimepoints_ + [NULL, @cStart, "", "Timeline start", "boundary"]
		
		# Collect all points and span boundaries
		_aSorted_ = []
		
		# Add points
		_nLen_ = len(@aPoints)
		for i = 1 to _nLen_
			_aSorted_ + ["point", @aPoints[i][1], @aPoints[i][2], @aPoints[i][1]]
		next
	
		# Add span starts and ends
		_nLen_ = len(@aSpans)
		for i = 1 to _nLen_
			_aSorted_ + ["span_start", @aSpans[i][1], @aSpans[i][2], @aSpans[i][1]]
			_aSorted_ + ["span_end", @aSpans[i][1], @aSpans[i][3], @aSpans[i][1]]
		next
		
		# Sort by datetime
		_aSorted_ = This._sortTimepointsByDate(_aSorted_)
		
		# Add to timepoints with indices (starting from 1)
		_nIndex_ = 1
		_nLen_ = len(_aSorted_)
		for i = 1 to _nLen_
			_cType_ = _aSorted_[i][1]
			_cLabel_ = _aSorted_[i][2]
			_cDateTime_ = _aSorted_[i][3]
			_cOrigName_ = _aSorted_[i][4]
			
			_cDesc_ = ""
			switch _cType_
			on "point"
				_cDesc_ = _cOrigName_ + " event"
			on "span_start"
				_cDesc_ = "Start of " + _cOrigName_
			on "span_end"
				_cDesc_ = "End of " + _cOrigName_
			off
			
			_aTimepoints_ + [_nIndex_, _cDateTime_, _cLabel_, _cDesc_, _cType_]
			_nIndex_++
		next
		
		# Add end boundary (NO INDEX)
		_aTimepoints_ + [NULL, @cEnd, "", "Timeline end", "boundary"]
	
		return _aTimepoints_
		
	def _sortTimepointsByDate(aItems)
		# Manual bubble sort by datetime (index 3 in the array)
		_nLen_ = len(aItems)
		
		for i = 1 to _nLen_ - 1
			for j = 1 to _nLen_ - i
				_oDateTime1_ = new stzDateTime(aItems[j][3])
				_oDateTime2_ = new stzDateTime(aItems[j + 1][3])
				
				if _oDateTime1_ > _oDateTime2_
					_aTemp_ = aItems[j]
					aItems[j] = aItems[j + 1]
					aItems[j + 1] = _aTemp_
				ok
			next
		next
		
		return aItems
	
		# Drawing Methods
		
	def _drawAxis(_oLayout_)
	    _nRow_ = _oLayout_[:axis_row]
	    _nCanvasWidth_ = len(@acVizCanvas[1])
	    
	    # Draw start boundary
	    _setVizChar(_nRow_, 1, @cBoundaryStartChar)
	    
	    # Draw main axis line
	    for i = 2 to _nCanvasWidth_ - 3
	        _setVizChar(_nRow_, i, @cAxisChar)
	    next
	    
	    # Draw end boundary and arrow
	    _setVizChar(_nRow_, _nCanvasWidth_ - 2, @cBoundaryEndChar)
	    _setVizChar(_nRow_, _nCanvasWidth_ - 1, @cAxisChar)
	    _setVizChar(_nRow_, _nCanvasWidth_, @cArrowChar)
	
	def _canPlaceLabel(_nPos_, _cLabel_, _aTimepoints_)
		_nLabelLen_ = StzLen(_cLabel_)
		_nLabelStart_ = max([1, _nPos_ - floor(_nLabelLen_ / 2)])
		_nLabelEnd_ = _nLabelStart_ + _nLabelLen_ - 1
		
		# Don't place if overlaps with blocked regions
		_nLen_ = len(@aBlockedSpans)
		for i = 1 to _nLen_
			_nBlockStart_ = _timeToPosition(@aBlockedSpans[i][2])
			_nBlockEnd_ = _timeToPosition(@aBlockedSpans[i][3])
			if not (_nLabelEnd_ < _nBlockStart_ or _nLabelStart_ > _nBlockEnd_)
				return FALSE
			ok
		next
		
		# Don't place if overlaps with blocked points
		_nLen_ = len(@aBlockedPoints)
		for i = 1 to _nLen_
			_nBlockPos_ = _timeToPosition(@aBlockedPoints[i])
			if _nBlockPos_ >= _nLabelStart_ and _nBlockPos_ <= _nLabelEnd_
				return FALSE
			ok
		next
		
		return TRUE

	def _drawLabels(_oLayout_, _aTimepoints_)
		_nRow_ = _oLayout_[:labels_row]
		
		if _nRow_ = 0
			return
		ok
		
		_aLabelsToPlace_ = []
		_nLen_ = len(_aTimepoints_)
	
		for i = 1 to _nLen_
			_cType_ = _aTimepoints_[i][5]
			_cLabel_ = _aTimepoints_[i][3]
			
			if (_cType_ = "span_start" or _cType_ = "span_end") and _cLabel_ != ""
				_cDateTime_ = _aTimepoints_[i][2]
				_nPos_ = _timeToPosition(_cDateTime_)
				
				# Only add if label can be placed safely
				if This._canPlaceLabel(_nPos_, _cLabel_, _aTimepoints_)
					_aLabelsToPlace_ + [_nPos_, _cLabel_]
				ok
			ok
		next
		
		_aPlaced_ = []
		_nLen_ = len(_aLabelsToPlace_)
	
		for i = 1 to _nLen_
			_nPos_ = _aLabelsToPlace_[i][1]
			_cLabel_ = _aLabelsToPlace_[i][2]
			_nLabelLen_ = StzLen(_cLabel_)

			_nLabelStart_ = max([1, _nPos_ - floor(_nLabelLen_ / 2)])
			_nLabelEnd_ = _nLabelStart_ + _nLabelLen_ - 1
			
			_bCollides_ = FALSE
			_nLenJ_ = len(_aPlaced_)
	
			for j = 1 to _nLenJ_
				_nPlacedStart_ = _aPlaced_[j][1]
				_nPlacedEnd_ = _aPlaced_[j][2]
				
				if not (_nLabelEnd_ < _nPlacedStart_ or _nLabelStart_ > _nPlacedEnd_)
					_bCollides_ = TRUE
					exit
				ok
			next
			
			if not _bCollides_
				_setVizString(_nRow_, _nLabelStart_, _cLabel_)
				_aPlaced_ + [_nLabelStart_, _nLabelEnd_]
			ok
		next
	
	def _drawNumbers(_oLayout_, _aTimepoints_)
		_nRow_ = _oLayout_[:numbers_row]
		
		# Skip if no numbers row allocated
		if _nRow_ = 0
			return
		ok
		
		# Count non-boundary timepoints
		_nCount_ = 0
		_nLen_ = len(_aTimepoints_)
		for i = 1 to _nLen_
			if _aTimepoints_[i][1] != NULL
				_nCount_++
			ok
		next
		
		# Only draw numbers if there are actual points/spans (not just boundaries)
		if _nCount_ = 0
			return
		ok
		
		# Group indices by position
		_aPositionGroups_ = []  # [[position, [index1, index2, ...]], ...]
		
		for i = 1 to _nLen_
			_nIndex_ = _aTimepoints_[i][1]
			
			# Skip boundaries (NULL index)
			if _nIndex_ = NULL
				loop
			ok
			
			_cDateTime_ = _aTimepoints_[i][2]
			_nPos_ = _timeToPosition(_cDateTime_)
			
			# Find if this position already has indices
			_nGroupPos_ = 0
			_nLenGroups_ = len(_aPositionGroups_)
			for j = 1 to _nLenGroups_
				if _aPositionGroups_[j][1] = _nPos_
					_nGroupPos_ = j
					exit
				ok
			next
			
			if _nGroupPos_ = 0
				# New position
				_aPositionGroups_ + [_nPos_, [_nIndex_]]
			else
				# Add to existing position
				_aPositionGroups_[_nGroupPos_][2] + _nIndex_
			ok
		next
		
		# Calculate how many extra rows we need for stacked numbers
		_nMaxIndices_ = 0
		_nLenGroups_ = len(_aPositionGroups_)
		for i = 1 to _nLenGroups_
			_nIndicesCount_ = len(_aPositionGroups_[i][2])
			if _nIndicesCount_ > _nMaxIndices_
				_nMaxIndices_ = _nIndicesCount_
			ok
		next
		
		# Calculate rows needed (2 numbers per row)
		_nRowsNeeded_ = ceil(_nMaxIndices_ / 2.0)
		
		# Ensure canvas has enough rows
		_nCanvasHeight_ = len(@acVizCanvas)
		_nRowsToAdd_ = (_nRow_ + _nRowsNeeded_ - 1) - _nCanvasHeight_
		if _nRowsToAdd_ > 0
			_nCanvasWidth_ = len(@acVizCanvas[1])
			for i = 1 to _nRowsToAdd_
				_aNewRow_ = []
				for j = 1 to _nCanvasWidth_
					_aNewRow_ + " "
				next
				@acVizCanvas + _aNewRow_
			next
		ok
		
		# Draw grouped numbers (2 per line, stacked vertically)
		for i = 1 to _nLenGroups_
			_nPos_ = _aPositionGroups_[i][1]
			_aIndices_ = _aPositionGroups_[i][2]
			
			_nLenIndices_ = len(_aIndices_)
			
			if _nLenIndices_ = 1
				# Single number - draw on first row
				_cNum_ = "" + _aIndices_[1]
				_nNumLen_ = StzLen(_cNum_)
				_nStartCol_ = max([1, _nPos_ - floor(_nNumLen_ / 2)])
				_setVizString(_nRow_, _nStartCol_, _cNum_)

			else
				# Multiple indices - stack 2 per row
				_nCurrentRow_ = _nRow_

				for j = 1 to _nLenIndices_ step 2
					# Build number string for this row (up to 2 numbers)
					_cNum_ = "" + _aIndices_[j]
					if j + 1 <= _nLenIndices_
						_cNum_ += "-" + _aIndices_[j + 1]
					ok

					_nNumLen_ = StzLen(_cNum_)
					_nStartCol_ = max([1, _nPos_ - floor(_nNumLen_ / 2)])
					_setVizString(_nCurrentRow_, _nStartCol_, _cNum_)
					
					_nCurrentRow_++
				next
			ok
		next

	def _drawPoints(_oLayout_, _aTimepoints_)
	    _nAxisRow_ = _oLayout_[:axis_row]
	    _nLen_ = len(_aTimepoints_)
	
	    # First, count ALL events at each position
	    _aPositionCounts_ = []  # [[position, count], ...]
	    
	    for i = 1 to _nLen_
	        _cType_ = _aTimepoints_[i][5]
	        
	        # Skip boundaries, but count everything else
	        if _cType_ = "boundary"
	            loop
	        ok
	        
	        if _cType_ = "point" or _cType_ = "span_start" or _cType_ = "span_end"
	            _cDateTime_ = _aTimepoints_[i][2]
	            _nPos_ = _timeToPosition(_cDateTime_)
	            
	            # Find if position already counted
	            _nFoundAt_ = 0
	            _nLenCounts_ = len(_aPositionCounts_)
	            for j = 1 to _nLenCounts_
	                if _aPositionCounts_[j][1] = _nPos_
	                    _nFoundAt_ = j
	                    exit
	                ok
	            next
	            
	            if _nFoundAt_ = 0
	                _aPositionCounts_ + [_nPos_, 1]
	            else
	                _aPositionCounts_[_nFoundAt_][2]++
	            ok
	        ok
	    next
	
	    # Now draw all timepoint types with appropriate symbol
	    for i = 1 to _nLen_
	        _cType_ = _aTimepoints_[i][5]
	
	        # Skip boundaries - they're already drawn by _drawAxis
	        if _cType_ = "boundary"
	            loop
	        ok
	
	        if _cType_ = "point" or _cType_ = "span_start" or _cType_ = "span_end"
	            _cDateTime_ = _aTimepoints_[i][2]
	            _nPos_ = _timeToPosition(_cDateTime_)
	
	            # Find count at this position
	            _nCount_ = 1
	            _nLenCounts_ = len(_aPositionCounts_)
	            for j = 1 to _nLenCounts_
	                if _aPositionCounts_[j][1] = _nPos_
	                    _nCount_ = _aPositionCounts_[j][2]
	                    exit
	                ok
	            next
	
	            _bHighlighted_ = FALSE
	            if @cHighlight != NULL and _aTimepoints_[i][3] = @cHighlight
	                _bHighlighted_ = TRUE
	            ok
	
	            # Use (o) if multiple events at same position, otherwise (*)
	            _cChar_ = ""
	            if _bHighlighted_
	                _cChar_ = @cHighlightChar
	            else
	                if _nCount_ = 1
	                    _cChar_ = @cPointChar # Single event ((*))
	
	                but _nCount_ > 1
	                    _cChar_ = @cMultiPointChar  # Multiple events at this position ((o))
	                ok
	            ok
	
	            _setVizChar(_nAxisRow_, _nPos_, _cChar_)
	        ok
	    next

	def _drawSpans(_oLayout_, _aTimepoints_)
	    _nAxisRow_ = _oLayout_[:axis_row]
	    
	    # Group span starts and ends
	    _aSpanRanges_ = []
	    _nLen_ = len(@aSpans)
	
	    for i = 1 to _nLen_
	        _cLabel_ = @aSpans[i][1]
	        _cStart_ = @aSpans[i][2]
	        _cEnd_ = @aSpans[i][3]
	        
	        _nStartPos_ = _timeToPosition(_cStart_)
	        _nEndPos_ = _timeToPosition(_cEnd_)
	        
	        _bHighlighted_ = (@cHighlight != NULL and @cHighlight = _cLabel_)
	        
	        _aSpanRanges_ + [_cLabel_, _nStartPos_, _nEndPos_, _bHighlighted_]
	    next
	    
	    # Draw spans with vertical offset
	    _aRowUsed_ = []
	    for i = 1 to @nVizHeight
	        _aRowUsed_ + []
	    next
	
	    _nLen_ = len(_aSpanRanges_)
	    for i = 1 to _nLen_
	        _cLabel_ = _aSpanRanges_[i][1]
	        _nStartPos_ = _aSpanRanges_[i][2]
	        _nEndPos_ = _aSpanRanges_[i][3]
	        _bHighlighted_ = _aSpanRanges_[i][4]
	        
	        _nRow_ = _findAvailableRow(_oLayout_, _nStartPos_, _nEndPos_, _aRowUsed_)
	        _drawSpanBar(_nRow_, _nStartPos_, _nEndPos_, _cLabel_, _bHighlighted_)
	    next	

	def _findAvailableRow(_oLayout_, _nStartPos_, _nEndPos_, _aRowUsed_)
		_nAxisRow_ = _oLayout_[:axis_row]
		_nSpanRows_ = _oLayout_[:span_rows]
		
		for nOffset = 1 to _nSpanRows_
			_nRow_ = _nAxisRow_ - nOffset
			
			_bFree_ = TRUE
			for _nPos_ = _nStartPos_ to _nEndPos_
				if find(_aRowUsed_[nOffset], _nPos_) > 0
					_bFree_ = FALSE
					exit
				ok
			next
			
			if _bFree_
				for _nPos_ = _nStartPos_ to _nEndPos_
					_aRowUsed_[nOffset] + _nPos_
				next
				return _nRow_
			ok
		next
		
		return _nAxisRow_ - 1


	def _drawSpanBar(_nRow_, _nStartPos_, _nEndPos_, _cLabel_, _bHighlighted_)
		_cBarChar_ = @cSpanChar

		_setVizChar(_nRow_, _nStartPos_, @cSpanStartChar)

		# Draw label in the middle of span
		_nSpanWidth_ = _nEndPos_ - _nStartPos_ + 1
		_nLabelLen_ = StzLen(_cLabel_)

		if _nLabelLen_ <= _nSpanWidth_ - 2
			_nLabelStart_ = _nStartPos_ + floor((_nSpanWidth_ - _nLabelLen_) / 2)
	
			# Draw bar before label
			for i = _nStartPos_ + 1 to _nLabelStart_ - 1
				_setVizChar(_nRow_, i, _cBarChar_)
			next
	
			# Draw label
			_setVizString(_nRow_, _nLabelStart_, _cLabel_)
	
			# Draw bar after label
			for i = _nLabelStart_ + _nLabelLen_ to _nEndPos_ - 1
				_setVizChar(_nRow_, i, _cBarChar_)
			next
		else
			# Label doesn't fit, just draw bar
			for i = _nStartPos_ + 1 to _nEndPos_ - 1
				_setVizChar(_nRow_, i, _cBarChar_)
			next
		ok
	
		if _nEndPos_ > _nStartPos_
			_setVizChar(_nRow_, _nEndPos_, @cSpanEndChar)
		ok
		
		# Canvas to String
		
		def _vizCanvasToString()
			_cResult_ = ""
			_nRows_ = len(@acVizCanvas)
			
			for i = 1 to _nRows_
				_cLine_ = ""
				_nLen_ = len(@acVizCanvas[i])
				for j = 1 to _nLen_
					_cLine_ += @acVizCanvas[i][j]
				next
				
				if i < _nRows_
					_cResult_ += _cLine_ + nl
				else
					_cResult_ += _cLine_
				ok
			next
			
			return _cResult_

	def _buildTimepointsTable(_aTimepoints_)
		_aTableData_ = [
			[:NO, :TIMEPOINT, :LABEL, :DESCRIPTION]
		]
	
		_nLen_ = len(_aTimepoints_)
		for i = 1 to _nLen_
			_nIndex_ = _aTimepoints_[i][1]
			_cDateTime_ = _aTimepoints_[i][2]
			_cLabel_ = _aTimepoints_[i][3]
			_cDesc_ = _aTimepoints_[i][4]
			
			# Use empty string for NULL (boundaries)
			_cIndexStr_ = ""
			if _nIndex_ != NULL
				_cIndexStr_ = "" + _nIndex_
			ok
			
			_aTableData_ + [_cIndexStr_, _cDateTime_, _cLabel_, _cDesc_]
		next
		
		_oTable_ = new stzTable(_aTableData_)
		return _oTable_.ToString()

	def _calculateRequiredVizHeight()
	    # Calculate maximum span overlap depth
	    if len(@aSpans) = 0
	        return 3  # Minimum height for axis, labels, numbers
	    ok
	    
	    # Sort spans by start time
	    _aSorted_ = This.SortedSpans()
	    _nLen_ = len(_aSorted_)
	    
	    # Track concurrent spans at each point
	    _nMaxOverlap_ = 0
	    
	    for i = 1 to _nLen_
	        _nConcurrent_ = 1
	        _oStart1_ = new stzDateTime(_aSorted_[i][2])
	        _oEnd1_ = new stzDateTime(_aSorted_[i][3])
	        
	        for j = 1 to _nLen_
	            if i != j
	                _oStart2_ = new stzDateTime(_aSorted_[j][2])
	                _oEnd2_ = new stzDateTime(_aSorted_[j][3])
	                
	                # Check if spans overlap
	                if _oStart1_ < _oEnd2_ and _oStart2_ < _oEnd1_
	                    _nConcurrent_++
	                ok
	            ok
	        next
	        
	        if _nConcurrent_ > _nMaxOverlap_
	            _nMaxOverlap_ = _nConcurrent_
	        ok
	    next
	    
	    # Return max overlap + 3 (for labels, axis, numbers rows)
	    return _nMaxOverlap_ + 3


	def _buildStatisticalTable()
	    _aStats_ = []
	    
	    # Total counts
	    _aStats_ + ["Total Points", This.CountPoints()]
	    _aStats_ + ["Total Spans", This.CountSpans()]
	    
	    # Timeline duration
	     _oDuration_ = This.DurationQ()
	     _aStats_ + ["Timeline Duration", _oDuration_.ToHuman()]
	    
	    # Coverage calculation
	    _nLenSpans_ = len(@aSpans)

	    if _nLenSpans_ > 0
	        _nTotalDuration_ = This.Duration()
	        _nCoveredDuration_ = 0
	        
	        # Sum all span durations (simplified - doesn't handle overlaps)
	        _nLen_ = _nLenSpans_
	        for i = 1 to _nLen_
	            _nCoveredDuration_ += This.SpanDuration(@aSpans[i][1])
	        next
	        
	        _nCoveragePercent_ = (_nCoveredDuration_ * 100.0) / _nTotalDuration_
	        _aStats_ + ["Coverage", "" + floor(_nCoveragePercent_) + "%"]
	    ok
	    
	    # Longest span
	    if _nLenSpans_ > 0
	        _nMaxDuration_ = 0
	        _cLongestSpan_ = ""
	        
	        _nLen_ = _nLenSpans_
	        for i = 1 to _nLen_
	            _nDuration_ = This.SpanDuration(@aSpans[i][1])
	            if _nDuration_ > _nMaxDuration_
	                _nMaxDuration_ = _nDuration_
	                _cLongestSpan_ = @aSpans[i][1]
	            ok
	        next
	        
	        _oDuration_ = new stzDuration(_nMaxDuration_)
	        _aStats_ + ["Longest Span", _cLongestSpan_ + " (" + _oDuration_.ToHuman() + ")"]
	    ok
	    
	    # Gaps count
	    _aGaps_ = This.Gaps()
	    _aStats_ + ["Gaps Between Spans", len(_aGaps_)]
	    
	    # Overlaps
	    _aOverlaps_ = This.OverlappingSpans()
	    _aStats_ + ["Overlapping Spans", len(_aOverlaps_)]
	    
	    # Build table
	    _aTableData_ = [[:METRIC, :VALUE]]

	    _nLen_ = len(_aStats_)
	    for i = 1 to _nLen_
	        _aTableData_ + [ _aStats_[i][1], _aStats_[i][2] ]
	    next
	    
	    return _aTableData_	


	def _drawUncoveredRegions(_oLayout_, _aUncovered_)
	    _nAxisRow_ = _oLayout_[:axis_row]
	    _nLen_ = len(_aUncovered_)
	    _nCanvasWidth_ = len(@acVizCanvas[1])
	    
	    # Collect span boundary positions to avoid
	    _aSpanPositions_ = []
	    _nLenSpans_ = len(@aSpans)
	    for i = 1 to _nLenSpans_
	        _aSpanPositions_ + _timeToPosition(@aSpans[i][2])
	        _aSpanPositions_ + _timeToPosition(@aSpans[i][3])
	    next
	    
	    for i = 1 to _nLen_
	        _cStart_ = _aUncovered_[i][:Start]
	        _cEnd_ = _aUncovered_[i][:End]
	        
	        _nStartPos_ = _timeToPosition(_cStart_)
	        _nEndPos_ = _timeToPosition(_cEnd_)
	        
	        # Draw / pattern, skip span boundaries AND timeline boundaries
	        for j = _nStartPos_ to _nEndPos_
	            # Skip position 1 (start boundary) and last 3 positions (end boundary + arrow)
	            if j != 1 and j < _nCanvasWidth_ - 2 and find(_aSpanPositions_, j) = 0
	                _setVizChar(_nAxisRow_, j, @cUncoveredChar)
	            ok
	        next
	    next

	def _drawBlockedSpans(_oLayout_, _aTimepoints_)
		_nAxisRow_ = _oLayout_[:axis_row]
		_nLen_ = len(@aBlockedSpans)
		
		for i = 1 to _nLen_
			_cStart_ = @aBlockedSpans[i][2]
			_cEnd_ = @aBlockedSpans[i][3]
			
			_nStartPos_ = _timeToPosition(_cStart_)
			_nEndPos_ = _timeToPosition(_cEnd_)
			
			for j = _nStartPos_ to _nEndPos_
				_setVizChar(_nAxisRow_, j, @cBlockChar)
			next
		next
	
	def _drawBlockedPoints(_oLayout_, _aTimepoints_)
		_nAxisRow_ = _oLayout_[:axis_row]
		_nLen_ = len(@aBlockedPoints)
		
		for i = 1 to _nLen_
			_nPos_ = _timeToPosition(@aBlockedPoints[i])
			_setVizChar(_nAxisRow_, _nPos_, @cBlockChar)
		next
	
	def _isDateOnly(_cDateTime_)
		# Check if format is YYYY-MM-DD (no time component)
		if StzLen(_cDateTime_) = 10 and StzMid(_cDateTime_, 5, 1) = "-" and StzMid(_cDateTime_, 8, 1) = "-"
			return 1
		else
			return 0
		ok
	
		def _isOnlyDate(_cDateTime_)
			return This._isDateOnly(_cDateTime_)

	def _isTimeOnly(_cDateTime_)
		# Check if format is HH:MM:SS (no date component)
		if StzLen(_cDateTime_) = 8 and StzMid(_cDateTime_, 3, 1) = ":" and StzMid(_cDateTime_, 6, 1) = ":"
			return 1
		else
			return 0
		ok

		def _isOnlyTime(_cDateTime_)
			return This._isTimeOnly(_cDateTime_)

	def _normalizeDateTime(pDateTime)
	    # Convert date-only input to full datetime by appending 00:00:00
	    _cDateTime_ = ""
	    
	    if isString(pDateTime)
	        _cDateTime_ = trim(pDateTime)
		if _cDateTime_ = ""
			StzRaise("Invalid format! Empty strings are not allowed for datevalue!")
		ok

	    else
	        _cDateTime_ = new stzDateTime(pDateTime).ToString()
	    ok
	    
	    # Check if date-only format (YYYY-MM-DD)
	    if This._isTimeOnly(_cDateTime_)
		StzRaise("Invalid format! Time specified without a date")

	    but This._isDateOnly(_cDateTime_)
	        _cDateTime_ += " 00:00:00"
	    ok
	    
	    # Ensure the string contains a valid datetime

	    try
		new stzDateTime(_cDateTime_)
	    catch
		StzRaise("Invalid datetime format (" + _cDateTime_ + ")!")
	    done

	    return _cDateTime_
