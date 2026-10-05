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

# Holds a stretch of time with labelled points and labelled spans on it, and answers what is at a date, what overlaps, where the gaps are, and draws it in text.
#
# A timeline runs from a start to an end, both dates or dates with a time, and everything on it is
# kept as text such as "2024-02-14 10:00:00". A point is a single labelled moment; a span is a
# labelled stretch with a start and an end. Both must lie inside the timeline, and neither may touch
# the blocked points and blocked spans that reserve parts of it. Labels may repeat. Point labels are
# stored in capitals and are matched in any case, but a span label keeps the case it was given, and
# FindSpan, HasSpan, RemoveSpan and RenameSpanLabel compare in capitals, so a span added as "Alpha"
# cannot be found through them while Span, SpanStart, SpanEnd and SpanDuration, which compare
# exactly, can. Many alternative spellings exist (moment, instant, period). Durations are whole
# seconds. ToString draws the timeline with box characters and a table of dates. Known defects, each
# carried as a warning: HasMoment and its spellings recurse until the stack overflows; WhatsAt for a
# time of day matches nearly every span; Gaps and UncoveredPeriods are wrong when one span contains
# others, and UncoveredPeriods answers nothing for a timeline without spans; Distance works only for
# point labels.
#
#   receiver   o1 = new stzTimeLine("2024-01-01", "2024-12-31"); o1.AddPoint("launch", "2024-02-14
#              10:00:00"); o1.AddSpan("ALPHA", "2024-03-01", "2024-04-30")
#   example    ? @@( o1.FindPoint("launch") )
#              #--> [ "2024-02-14 10:00:00" ]
#   see        stzDateTime, stzDuration, stzCalendar, stzListOfTimeLines
class stzTimeLine from stzObject
	@cStart = ""
	@cEnd = ""
	@aPoints = []      # [[name, string_datetime], ...]
	@aSpans = []       # [[name, string_datetime, string_datetime], ...]

	# Display properties
	@nVizWidth = 52
	@nVizMinWidth = 30
	@nVizMinHeight = 3
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

	@bShowDates = 1
	@bShowLabels = 1
	@cHighlight = ""

	# Layout
	@nLabelHeight = 1
	@nAxisRow = 0
	@nDateRow = 0
	@acVizCanvas = []

	@aBlockedSpans = []    # [[name, string_datetime_start, string_datetime_end], ...]
	@aBlockedPoints = []

	# Builds a timeline between a start and an end, each a date or a date and time, empty of points and spans; a bad date raises an error.
	#
	#   pStart     The start of the timeline, as text such as "2024-01-01" or "2024-01-01 08:30:00",
	#              or as :Start = text
	#   pEnd       The end of the timeline, as text, or as :End = text
	#   returns    nothing; the timeline is built
	#   note       an end before the start is accepted without complaint and gives a negative
	#              Duration
	#   see        Start, End_, SetStart
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


	# Returns the whole timeline as a hash list of its start, end, points and spans.
	#
	#   returns    a hash list [ :start, :end, :points, :spans ]
	#   see        Points, Spans, Summary
	def Content()
		_aResult_ = [
			:Start = @cStart,
			:End = @cEnd,

			:Points = @aPoints,
			:Spans = @aSpans
		]

		return _aResult_

	# Returns where the timeline begins, as text in the form "YYYY-MM-DD HH:MM:SS".
	#
	#   returns    text
	#   see        End_, SetStart, Duration
	#@ aka  Boundary Management
	def Start()
		return @cStart
		
		def StartQ()
			if @cStart != ""
				return new stzDateTime(@cStart)
			ok
			return ""

		def StartDate()
			return This.Start()
			
			def StartDateQ()
				return This.StartQ()

	# Returns where the timeline finishes, as text in the form "YYYY-MM-DD HH:MM:SS".
	#
	#   returns    text
	#   note       the trailing underscore avoids the host language's end keyword
	#   see        Start, SetEnd, Duration
	def End_()
		return @cEnd
		
		# Returns the end of the timeline as a stzDateTime object, so date methods can be chained.
		#
		#   returns    a stzDateTime
		#   see        End_, Start
		def EndQ()
			if @cEnd != ""
				return new stzDateTime(@cEnd)
			ok
			return ""

		def EndDate()
			return This.End_()

		def EndDateQ()
			return This.EndQ()

		def Endd()
			return This.End_()

	# Moves the start of the timeline; a bad date raises an error and leaves the old start.
	#
	#   p          The new start, as text such as "2024-01-01" or "2024-01-01 08:30:00"
	#   returns    nothing; the timeline changes
	#   note       a date alone becomes midnight; SetStartQ answers the timeline for chaining
	#   warning    the points and spans already added are not checked against the new start, so some
	#              may end up outside the timeline
	#   see        Start, SetEnd
	def SetStart(p)
		@cStart = This._normalizeDateTime(p)
	
		def SetStartQ(p)
			This.SetStart(p)
			return This
	
	# Moves the end of the timeline; a bad date raises an error and leaves the old end.
	#
	#   p          The new end, as text such as "2024-12-31" or "2024-12-31 18:00:00"
	#   returns    nothing; the timeline changes
	#   note       a date alone becomes midnight, unlike the constructor, which gives 23:59:59;
	#              SetEndQ answers the timeline for chaining
	#   warning    the points and spans already added are not checked against the new end, so some
	#              may end up outside the timeline
	#   see        End_, SetStart
	def SetEnd(p)
		@cEnd = This._normalizeDateTime(p)
	
		def SetEndQ(p)
			This.SetEnd(p)
			return This
				
	# Returns the length of the timeline, from its start to its end, as a whole number of seconds.
	#
	#   returns    a number of seconds; negative when the end is before the start
	#   note       31622399 for the year 2024; DurationQ answers a stzDuration
	#   see        Start, End_, Summary
	def Duration()
		return This.StartQ().DurationTo(@cEnd, :InSeconds)

		def DurationQ()
			if This.Duration() != ""
				return new stzDuration(This.Duration())
			ok
			return ""

	# Adds a labelled point at a date and time inside the timeline; the label is stored in capitals and the same label may be added again.
	#
	#   pcLabel     The label of the point, as text, stored in capitals
	#   pDateTime   The date and time of the point, as text
	#   returns     nothing; the timeline changes
	#   note        raises an error when the label is not text, the date is invalid or has no date
	#               part, the point lies outside the timeline (bounds included), or it falls on a
	#               blocked point or span
	#   see         AddPoints, FindPoint, RemovePoint
	#@ aka  Point Management (single moments in time)
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
		
		# Adds a labelled point at a date and time; another spelling of the point-adding call.
		#
		#   pcLabel     The label of the point, as text, stored in capitals
		#   pDateTime   The date and time of the point, as text
		#   returns     nothing; the timeline changes
		#   see         AddPoint
		def AddTimePoint(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
			
			def AddTimePointQ(pcLabel, pDateTime)
				return This.AddPointQ(pcLabel, pDateTime)
	
		# Adds a labelled point at a date and time; another spelling of the point-adding call.
		#
		#   pcLabel     The label of the point, as text, stored in capitals
		#   pDateTime   The date and time of the point, as text
		#   returns     nothing; the timeline changes
		#   see         AddPoint
		def AddMoment(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
	
			def AddMomentQ(pcLabel, pDateTime)
				return This.AddPointQ(pcLabel, pDateTime)

		# Adds a labelled point at a date and time; another spelling of the point-adding call.
		#
		#   pcLabel     The label of the point, as text, stored in capitals
		#   pDateTime   The date and time of the point, as text
		#   returns     nothing; the timeline changes
		#   see         AddPoint
		def AddInstant(pcLabel, pDateTime)
			This.AddPoint(pcLabel, pDateTime)
	
			def AddInstantQ(pcLabel, pDateTime)
				return This.AddPointQ(pcLabel, pDateTime)

	# Adds several points in one call, each given as [ label, date and time ]; the first to raise stops the call, keeping earlier ones.
	#
	#   paPoints   The points to add, each a list [ label, date and time ]
	#   returns    nothing; the timeline changes
	#   see        AddPoint, AddSpans
	def AddPoints(paPoints)
		_nLen_ = len(paPoints)
		for i = 1 to _nLen_
			This.AddPoint(paPoints[i][1], paPoints[i][2])
		next

		# Adds several labelled points in one call; another spelling of the multi-point call.
		#
		#   paPoints   The points to add, each a list [ label, date and time ]
		#   returns    nothing; the timeline changes
		#   see        AddPoints
		def AddMoments(paPoints)
			This.AddPoints(paPoints)

		# Adds several labelled points in one call; another spelling of the multi-point call.
		#
		#   paPoints   The points to add, each a list [ label, date and time ]
		#   returns    nothing; the timeline changes
		#   see        AddPoints
		def AddInstants(paPoints)
			This.AddPoints(paPoints)

	# Returns the date and time of every point carrying a label; the label is matched in capitals, so any case works.
	#
	#   pcLabel    The label to look for, as text
	#   returns    a list of text, one per point, in the order added; [ ] when none
	#   see        Point, HasPoint, PointNames
	#@ aka  Find the occurences of a given moment (by label) on the timeline (returns its relative datetimes)
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

	# Returns every point as [ label, date and time ], in the order added, with the label in capitals.
	#
	#   returns    a list of [ label, date and time ] pairs
	#   note       PointsQ answers the date and time as stzDateTime objects
	#   see        Spans, SortedPoints, PointNames
	#@ aka  --
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

	# Returns the labels of the points, each label once, in the order first added.
	#
	#   returns    a list of text
	#   see        Points, SpanNames, CountPoints
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

	# Returns the labels of the spans, each label once, in the order first added, with the case it was given.
	#
	#   returns    a list of text
	#   see        Spans, PointNames, CountSpans
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

	# Returns the date and time of the first event with a label, in any case; given a date or a time instead, it returns what is there.
	#
	#   pcLabelOrDateTime   A point label, as text, or a date, or a time such as "10:30:00"
	#   returns             text; for a date or time argument a list of [ label, "point" or "span" ]
	#                       pairs; raises an error when no label matches
	#   note                PointQ answers a stzDateTime object
	#   see                 FindPoint, WhatsAt, HasPoint
	#@ aka  Getting a point datetime
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

	# TRUE if at least one point carries the label, matched in any case.
	#
	#   pcLabelOrDateTime   The point label to look for, as text
	#   returns             TRUE or FALSE
	#   note                a date and time given instead of a label answers FALSE
	#   see                 FindPoint, HasSpan
	#@ aka  Checking if a point exists
	def HasPoint(pcLabelOrDateTime)
		if len(This.FindPoint(pcLabelOrDateTime)) > 0
			return 1
		else
			return 0
		ok
		
		# Raises a stack overflow today instead of telling whether a point carries the label.
		#
		#   pcLabelOrDateTime   The point label to look for, as text
		#   returns             nothing today; the call never returns an answer
		#   note                HasPoint is the working call
		#   warning             known defect: the method calls itself, so it recurses until the
		#                       interpreter stops; its spelling siblings HasInstant, ContainsMoment
		#                       and ContainsInstant call it and fail the same way
		#   see                 HasPoint
		def HasMoment(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

		def HasInstant(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

		#--

		def ContainsMoment(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

		def ContainsInstant(pcLabelOrDateTime)
			return This.HasMoment(pcLabelOrDateTime)

	# Removes the first point carrying a label, matched in any case; the other points with that label stay.
	#
	#   pcLabelOrDateTime   The label of the point to remove, as text
	#   returns             nothing; the timeline changes
	#   note                to remove every point of a label call it once per point
	#   warning             a date and time given instead of a label removes nothing, and a missing
	#                       label raises nothing
	#   see                 AddPoint, FindPoint
	#TODO // Add Removing all the items with a given label
	#@ aka  Removing points
	def RemovePoint(pcLabelOrDateTime)
		_aPos_ = This.FindPointXT(pcLabelOrDateTime)
		if len(_aPos_) > 0
			del(@aPoints, _aPos_[1][2])
		ok

		def RemovePointQ(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)
			return This
		
		# Removes the first point carrying a label; another spelling of the point-removing call.
		#
		#   pcLabelOrDateTime   The label of the point to remove, as text
		#   returns             nothing; the timeline changes
		#   see                 RemovePoint
		def RemoveMoment(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)

			def RemoveMomentQ(pcLabelOrDateTime)
				return This.RemovePointQ(pcLabelOrDateTime)

		# Removes the first point carrying a label; another spelling of the point-removing call, with a typo in its name.
		#
		#   pcLabelOrDateTime   The label of the point to remove, as text
		#   returns             nothing; the timeline changes
		#   note                the name reads RemoveMInstant, not RemoveInstant; the Q form is
		#                       spelled RemoveInstantQ
		#   see                 RemovePoint
		#@ aka  --
		def RemoveMInstant(pcLabelOrDateTime)
			This.RemovePoint(pcLabelOrDateTime)

			def RemoveInstantQ(pcLabelOrDateTime)
				return This.RemovePointQ(pcLabelOrDateTime)

	# Gives a new name to every point and every span carrying a label.
	#
	#   pcLabel      The label to change, as text
	#   pcNewLabel   The new label, as text
	#   returns      nothing; the timeline changes
	#   note         the new label is stored in capitals
	#   warning      a span stored with a lowercase letter in its label is not found, because the
	#                label is compared in capitals
	#   see          RenamePointLabel, RenameSpanLabel
	#@ aka  Renaming labels
	def RenameLabel(pcLabel, pcNewLabel)
		This.RenamePointLabel(pcLabel, pcNewLabel)
		This.RenameSpanLabel(pcLabel, pcNewLabel)

	# Gives a new name to every point carrying a label, matched in any case; the new label is stored in capitals.
	#
	#   pcLabel      The label to change, as text
	#   pcNewLabel   The new label, as text
	#   returns      nothing; the timeline changes
	#   note         a label that matches nothing changes nothing and raises nothing
	#   see          RenameLabel, RenameSpanLabel
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
	
		# Gives a new name to every point carrying a label; another spelling of the point-renaming call.
		#
		#   pcLabel      The label to change, as text
		#   pcNewLabel   The new label, as text
		#   returns      nothing; the timeline changes
		#   see          RenamePointLabel
		def RenameMomentLabel(pcLabel, pcNewLabel)
			This.RenamePointLabel(pcLabel, pcNewLabel)

		# Gives a new name to every point carrying a label; another spelling of the point-renaming call.
		#
		#   pcLabel      The label to change, as text
		#   pcNewLabel   The new label, as text
		#   returns      nothing; the timeline changes
		#   see          RenamePointLabel
		def RenameInstantLabel(pcLabel, pcNewLabel)
			This.RenamePointLabel(pcLabel, pcNewLabel)


	# Gives a new name to every span carrying a label, found only if it was added in capitals; the new label is stored in capitals.
	#
	#   pcLabel      The label to change, as text
	#   pcNewLabel   The new label, as text
	#   returns      nothing; the timeline changes
	#   note         a label that matches nothing changes nothing and raises nothing
	#   warning      a span whose label has a lowercase letter, such as one added as "Alpha", is
	#                never found, because the old label is turned to capitals before the comparison
	#                and spans keep the case they were given
	#   see          RenameLabel, RenamePointLabel
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

	# Returns how many points the timeline holds, counting a repeated label each time.
	#
	#   returns    a number
	#   see        CountSpans, PointNames
	#@ aka  How many points
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

	# Adds several spans in one call, each given as [ label, start, end ]; the first to raise stops the call, keeping earlier ones.
	#
	#   paSpans    The spans to add, each a list [ label, start, end ]
	#   returns    nothing; the timeline changes
	#   see        AddSpan, AddPoints
	#@ aka  Span Management (time periods with start and end)
	def AddSpans(paSpans)
		_nLen_ = len(paSpans)
		for i = 1 to _nLen_
			This.AddSpan(paSpans[i][1], paSpans[i][2], paSpans[i][3])
		next

		# Adds several labelled spans in one call; another spelling of the multi-span call.
		#
		#   paSpans    The spans to add, each a list [ label, start, end ]
		#   returns    nothing; the timeline changes
		#   see        AddSpans
		def AddPeriods(paSpans)
			This.AddSpans(paSpans)

	# Adds a labelled span between two dates inside the timeline; the label keeps the case it is given and the same label may be added again.
	#
	#   pcLabel    The label of the span, as text, stored as given
	#   pStart     The start of the span, as text
	#   pEnd       The end of the span, as text
	#   returns    nothing; the timeline changes
	#   note       unlike points, a span label is not turned to capitals, which matters to FindSpan,
	#              HasSpan and RemoveSpan
	#   warning    raises an error when the label is not text, the end is not after the start, the
	#              span leaves the timeline, or it overlaps a blocked span or point
	#   see        AddSpans, Span, RemoveSpan
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
		
		# Adds a labelled span between two dates; another spelling of the span-adding call.
		#
		#   pcLabel    The label of the span, as text, stored as given
		#   pStart     The start of the span, as text
		#   pEnd       The end of the span, as text
		#   returns    nothing; the timeline changes
		#   see        AddSpan
		def AddPeriod(pcLabel, pStart, pEnd)
			This.AddSpan(pcLabel, pStart, pEnd)
	
			def AddPeriodQ(pcLabel, pStart, pEnd)
				return This.AddSpanQ(pcLabel, pStart, pEnd)
	

	# Returns the start and end of every span carrying a label, found only if the span's label was added in capitals.
	#
	#   pcLabel    The label to look for, as text
	#   returns    a list of [ start, end ] pairs; [ ] when none
	#   note       works for spans added with a capital-letter label, in any case of the query
	#   warning    a span stored with a lowercase letter, such as "Alpha", is never found, because
	#              the label is turned to capitals before the comparison but spans keep the case
	#              they were given
	#   see        Span, HasSpan, SpanNames
	#@ aka  Find the occurences of a given Period (by label) on the timeline (returns its relative datetimes)
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

	
	# Returns every span as [ label, start, end ], in the order added.
	#
	#   returns    a list of [ label, start, end ] lists
	#   note       SpansQ answers the dates as stzDateTime objects
	#   see        Points, SortedSpans, SpanNames
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
			
	# Returns the start and end of the first period with exactly this label, case included; raises an error when there is none.
	#
	#   pcLabel    The label of the span, as text, in exactly the case it was added with
	#   returns    a list [ start, end ]
	#   note       unlike FindSpan, no case folding is done, so Span("Alpha") finds a span added as
	#              "Alpha" and Span("ALPHA") does not
	#   see        FindSpan, SpanStart, SpanEnd
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

	# Returns the start of the first span with exactly this label; raises an error when there is none.
	#
	#   pcLabel    The label of the span, as text, in exactly the case it was added with
	#   returns    text, the start of the span
	#   note       SpanStartQ answers a stzDateTime
	#   see        Span, SpanEnd
	def SpanStart(pcLabel)
		return This.Span(pcLabel)[1]

		def SpanStartQ(pcLabel)
			return StzDateTimeQ(This.SpanStart(pcLabel))

	# Returns the end of the first span with exactly this label; raises an error when there is none.
	#
	#   pcLabel    The label of the span, as text, in exactly the case it was added with
	#   returns    text, the end of the span
	#   note       SpanEndQ answers a stzDateTime
	#   see        Span, SpanStart
	def SpanEnd(pcLabel)
		return This.Span(pcLabel)[2]

		def SpanEndQ(pcLabel)
			return StzDateTimeQ(This.SpanEnd(pcLabel))

	# Returns the length of the first span with exactly this label, in seconds; raises an error when there is none.
	#
	#   pcLabel    The label of the span, as text, in exactly the case it was added with
	#   returns    a number of seconds
	#   note       SpanDurationQ answers a stzDuration
	#   see        Span, Duration
	def SpanDuration(pcLabel)
		return This.SpanStartQ(pcLabel).DurationTo(This.SpanEnd(pcLabel), :InSeconds)

		def SpanDurationQ(pcLabel)
			return new stzDuration(This.SpanDuration(pcLabel))

	# TRUE if a span carries the label; only a span whose label was added in capitals is found, and the query may be in any case.
	#
	#   pcLabel    The span label to look for, as text
	#   returns    TRUE or FALSE
	#   note       for spans added in capitals the query may be in any case
	#   warning    a span stored as "Alpha" is reported absent, because the query is turned to
	#              capitals and the stored label is not
	#   see        FindSpan, HasPoint
	def HasSpan(pcLabel)
		return len( This.FindSpan(pcLabel) ) > 0
		
	# Removes the first span carrying a label, found only if its label was added in capitals; other spans with that label stay.
	#
	#   pcLabel    The label of the span to remove, as text
	#   returns    nothing; the timeline changes
	#   note       a label that matches nothing raises nothing
	#   warning    a span stored with a lowercase letter, such as "alpha2", is not removed, because
	#              the label is turned to capitals before the comparison and spans keep the case
	#              they were given
	#   see        AddSpan, FindSpan
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
		
	# Returns how many spans the timeline holds, counting a repeated label each time.
	#
	#   returns    a number
	#   see        CountPoints, SpanNames
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

	# Returns the points and the spans found at a date and time, at a date, or at a time of day, as [ label, "point" or "span" ] pairs.
	#
	#   pDateTime   A date and time for an exact match, a date alone for any time of that day, or a
	#               time such as "10:30:00" for any day
	#   returns     a list of [ label, "point" or "span" ] pairs; [ ] when nothing is there
	#   note        a date and time matches a point to the second and a span from its start to its
	#               end, bounds included
	#   warning     for a time of day the spans test is "at or after the start time, or at or before
	#               the end time", which holds for nearly every span: 12:00:00 and 23:30:00 both
	#               match a span running 09:00 to 17:00
	#   see         PointsBetween, SpansOverlapping, Point
	#@ aka  Temporal Queries
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
	# Returns the labels of the points lying between two dates, bounds included, in the order added.
	#
	#   pStart     The start of the range, as text
	#   pEnd       The end of the range, as text, or :And = text
	#   returns    a list of text; [ ] when none
	#   note       a date alone is midnight, so a range from one date to the same date holds no
	#              point later in the day; empty text raises an error
	#   see        SpansBetween, WhatsAt
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


	# Returns the labels of the spans that touch a range of two dates, wholly inside it or only overlapping it, in the order added.
	#
	#   pStart     The start of the range, as text
	#   pEnd       The end of the range, as text
	#   returns    a list of text; [ ] when none
	#   note       a span ending exactly at the start of the range, or starting exactly at its end,
	#              is included
	#   see        PointsBetween, SpansOverlapping
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

	# Returns the labels of the spans that contain a date and time, bounds included.
	#
	#   pDateTime   The date and time to test, as text
	#   returns     a list of text; [ ] when none
	#   see         SpansBetween, WhatsAt, HasOverlaps
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


	# TRUE if any two spans overlap by more than a single instant; spans that only touch do not count.
	#
	#   returns    TRUE or FALSE
	#   see        OverlappingSpans, Gaps
	#@ aka  Overlap Detection
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
					return 1
				ok
			next
		next

		return 0
		
	# Returns each overlapping pair of spans with the length of the overlap, in seconds.
	#
	#   returns    a list of [ first label, second label, seconds ] lists; [ ] when none
	#   see        HasOverlaps, Gaps
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
					_oOverlapStart_ = ""
					_oOverlapEnd_ = ""
					
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

	# Returns the empty stretches between one span and the next, taken in start order.
	#
	#   returns    a list of hash lists [ :after, :before, :duration ], the duration in seconds; [ ]
	#              when there is none
	#   note       for spans that do not nest the answer is right; the timeline's own start and end
	#              are ignored here
	#   warning    a span that contains later ones is not taken into account: with one long span and
	#              two short spans inside it, the stretch between the shorts is reported although
	#              the long span covers it
	#   see        UncoveredPeriods, OverlappingSpans
	#@ aka  Gap Analysis
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
		
	# Returns the stretches of the timeline that no span covers, including before the first span and after the last.
	#
	#   returns    a list of hash lists [ :start, :end, :duration ], the duration in seconds; [ ]
	#              when there is no span
	#   note       for spans that do not nest the answer is right
	#   warning    a timeline with no span at all answers [ ], although all of it is uncovered; a
	#              span that contains later ones is not taken into account, so the stretch between
	#              the shorts is reported although the long span covers it
	#   see        Gaps, ToStringUncovered
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

		# Returns the time from one point to another in seconds, negative when the second comes first; both are given by label.
		#
		#   _cLabel1_   The label of the first point, as text, or :From = text
		#   _cLabel2_   The label of the second point, as text, or :To = text
		#   returns     a number of seconds
		#   note        a label that appears twice stands for its first point
		#   warning     raises an error for a span label; two date-and-time strings give 0 and a
		#               label with a date gives a meaningless number, because a date is looked up by
		#               what is at it, not read as a date
		#   see         DurationXT, Duration
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
	# Returns the spans as [ label, start, end ], in order of start.
	#
	#   returns    a list of [ label, start, end ] lists
	#   see        Spans, SortedPoints
		#>
	#@ aka  Utility Methods
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
		
	# Returns the points as [ label, date and time ], in chronological order.
	#
	#   returns    a list of [ label, date and time ] pairs
	#   see        Points, SortedSpans
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

	# Returns a report as [ key, value ] pairs: boundaries, duration, counts, then the sorted points and spans with durations in words.
	#
	#   returns    a list of [ key, value ] pairs
	#   see        Stats, Content
	#@ aka  Output Methods
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
		
	# Removes every point and every span, keeping the boundaries and the blocked points and spans.
	#
	#   returns    nothing; the timeline changes
	#   see        Copy, RemovePoint, RemoveSpan
	def Clear()
		@aPoints = []
		@aSpans = []
		
	# Returns an independent timeline with the same boundaries, points and spans; blocked points and spans are not copied.
	#
	#   returns    a stzTimeLine
	#   see        Clear, Content
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
	
	# Sets the width of the drawn timeline in characters, never below 30.
	#
	#   n          The width, in characters
	#   returns    nothing; the setting changes
	#   see        VizWidth, SetVizHeight, ToString
	#@ aka  Configuration
	def SetVizWidth(n)
		@nVizWidth = max([@nVizMinWidth, n])
		
	# Sets the number of text rows given to the drawn timeline, never below 3; the layout may use more.
	#
	#   n          The number of rows
	#   returns    nothing; the setting changes
	#   see        VizHeight, SetVizWidth
	def SetVizHeight(n)
		# max() AGAINST ITSELF was a ratchet: the height could only ever go UP,
		# so SetVizHeight(20) then SetVizHeight(5) left 20 and the smaller value
		# was swallowed without a word. Its sibling SetVizWidth floors against a
		# MINIMUM, which is what was meant here too -- 3 rows, the floor this
		# class already applies when a height arrives through ToStringXT.
		@nVizHeight = max([@nVizMinHeight, n])
		
	# Returns the width of the drawn timeline in characters; 52 until changed.
	#
	#   returns    a number
	#   see        SetVizWidth, VizHeight
	def VizWidth()
		return @nVizWidth
		
	# Returns the number of rows set for the drawn timeline; 5 until changed.
	#
	#   returns    a number
	#   see        SetVizHeight, VizWidth
	def VizHeight()
		return @nVizHeight
	

	# Main Display Methods

	def ShowXT(paOptions)
		? This.ToStringXT(paOptions)

	# Prints the drawn timeline and its table of points and span boundaries.
	#
	#   returns    nothing; the text is printed
	#   see        ToString, ShowShort
	def Show()
		? This.ToString()
		
	# Returns the timeline drawn in text, an axis with its points and spans numbered, followed by a table of every date with its label.
	#
	#   returns    text
	#   note       the drawing uses box characters, so it needs a console that shows UTF-8
	#   see        Show, ToStringShort, Stats
	def ToString()
		return This.ToStringXT([])
		
	def ToStringXT(paParams)
		_nRequestedWidth_ = @nVizWidth
		_bShowTable_ = 1
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
	
	# Returns a small table of figures about the timeline: counts, duration, coverage, longest span, gaps and overlaps.
	#
	#   returns    a list of rows [ metric, value ], the first row being the header
	#   see        Summary, Gaps
	def Stats()
		return _buildStatisticalTable()
	
	# Prints the drawn timeline without its table.
	#
	#   returns    nothing; the text is printed
	#   see        ToStringShort, Show
	def ShowShort()
		? This.ToStringShort()
	
	# Returns the drawn timeline in text without the table of dates.
	#
	#   returns    text
	#   see        ShowShort, ToString
	def ToStringShort()
	
	    # Collect timepoints
	    _aTimepoints_ = _collectAllTimepoints()
	
	    # Calculate layout
	    _oLayout_ = _calculateVizLayout()
	    if _oLayout_ = ""
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


	# Returns the drawn timeline with the points of a label marked by a solid block instead of a dot.
	#
	#   _cLabel_   The point label to highlight, in capitals as stored
	#   returns    text
	#   note       the label is compared as stored, so a lowercase label marks nothing
	#   see        VizFindSpans, ToString
	#@ aka  Highlight Visualization Methods
	def VizFindMoments(_cLabel_)
		@cHighlight = _cLabel_
		_cResult_ = This.ToString()
		@cHighlight = ""
		return _cResult_
		
		def VizFindMoment(_cLabel_)
			return This.VizFindMoments(_cLabel_)
			
		def VizFindPoint(_cLabel_)
			return This.VizFindMoments(_cLabel_)
			
		def VizFindPoints(_cLabel_)
			return This.VizFindMoments(_cLabel_)
			
	# Returns the drawn timeline with the start and end of a span marked by a solid block.
	#
	#   _cLabel_   The span label to highlight, exactly as the span was added
	#   returns    text
	#   note       the label is compared as stored, so a span added as "Alpha" is found by "Alpha"
	#              only
	#   see        VizFindMoments, ToString
	def VizFindSpans(_cLabel_)
		@cHighlight = _cLabel_
		_cResult_ = This.ToString()
		@cHighlight = ""
		return _cResult_
		
		def VizFindSpan(_cLabel_)
			return This.VizFindSpans(_cLabel_)
			
		def VizFindPeriod(_cLabel_)
			return This.VizFindSpans(_cLabel_)
			
		def VizFindPeriods(_cLabel_)
			return This.VizFindSpans(_cLabel_)


	# Prints the drawn timeline with the stretches that no span covers filled in with slashes.
	#
	#   returns    nothing; the text is printed
	#   see        ToStringUncovered, UncoveredPeriods
	#@ aka  Hihlighting the uncovered spans in the timeline
	def ShowUncovered()
	    ? This.ToStringUncovered()
	
	# Returns the drawn timeline with the uncovered stretches marked by slashes, or a sentence saying it is fully covered.
	#
	#   returns    text
	#   note       the sentence is "Timeline is fully covered by spans"
	#   warning    an empty timeline, with no span, answers that it is fully covered although
	#              nothing covers it
	#   see        ShowUncovered, UncoveredPeriods
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
	    if _oLayout_ = ""
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

	# Marks a date and time as blocked, so that no point or span can be added over it; a date outside the timeline raises an error.
	#
	#   pDateTime   The date and time to block, as text
	#   returns     nothing; the timeline changes
	#   note        a point already blocked is ignored without complaint; points and spans added
	#               before are not checked
	#   see         AddBlockedPoints, IsPointBlocked, AddBlockedSpan
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
	
	# Marks several dates and times as blocked, one after the other; the first one that raises stops the call.
	#
	#   paDateTimes   The dates and times to block, each as text
	#   returns       nothing; the timeline changes
	#   see           AddBlockedPoint
	def AddBlockedPoints(paDateTimes)
		_nLen_ = len(paDateTimes)
		for i = 1 to _nLen_
			This.AddBlockedPoint(paDateTimes[i])
		next

	# Lifts the block on a date and time; one that was not blocked changes nothing.
	#
	#   pDateTime   The date and time to unblock, as text
	#   returns     nothing; the timeline changes
	#   see         AddBlockedPoint, BlockedPoints
	def RemoveBlockedPoint(pDateTime)
		_cPoint_ = This._normalizeDateTime(pDateTime)
		_nPos_ = StzFindFirst(_cPoint_, @aBlockedPoints)
		if _nPos_ > 0
			del(@aBlockedPoints, _nPos_)
		ok

		def RemoveBlockedPointQ(pDateTime)
			This.RemoveBlockedPoint(pDateTime)
			return This

	# Returns the blocked dates and times, as text, in the order they were blocked.
	#
	#   returns    a list of text
	#   note       BlockedPointsQ answers stzDateTime objects
	#   see        AddBlockedPoint, BlockedSpans
	def BlockedPoints()
		return @aBlockedPoints

	def BlockedPointsQ()
		_aResult_ = []
		_nLen_ = len(@aBlockedPoints)
		for i = 1 to _nLen_
			_aResult_ + new stzDateTime(@aBlockedPoints[i])
		next
		return _aResult_

	# TRUE if a date and time was blocked as a point; spans that block it do not count, and the match is exact to the second.
	#
	#   pDateTime   The date and time to test, as text
	#   returns     TRUE or FALSE
	#   see         IsBlocked, AddBlockedPoint
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
				return 1
			ok
		next
	
		return 0

	# TRUE if a date and time is a blocked point or inside a blocked span, edges included; a list of two dates tests that stretch.
	#
	#   pDateTime   A date and time as text, or a list [ start, end ]
	#   returns     TRUE or FALSE
	#   see         IsPointBlocked, IsSectionBlocked
	def IsBlocked(pDateTime)
		if isList(pDateTime) and len(pDateTime) = 2
			return This.IsSectionBlocked(pDateTime[1], pDateTime[2])
		ok
	
		# Check both blocked points and blocked spans
		if This.IsPointBlocked(pDateTime)
			return 1
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
				return 1
			ok
		next
	
		return 0

	# TRUE if the stretch between two dates overlaps a blocked span or holds a blocked point; merely touching a blocked span does not count.
	#
	#   pStart     The start of the stretch, as text
	#   pEnd       The end of the stretch, as text
	#   returns    TRUE or FALSE
	#   see        IsBlocked, AddBlockedSpan
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
				return 1
			ok
		next
	
		# Also check blocked points within range
		_nLen_ = len(@aBlockedPoints)
		for i = 1 to _nLen_
			_oPoint_ = new stzDateTime(@aBlockedPoints[i])
			if _oPoint_ >= _oStart_ and _oPoint_ <= _oEnd_
				return 1
			ok
		next
	
		return 0
	
		def IsBlockedSection(pStart, pEnd)
			return This.IsSectionBlocked(pStart, pEnd)
	
	# Marks a stretch of the timeline as blocked, so that no point or span can be added over it; the label is stored in capitals.
	#
	#   pcLabel    The label of the blocked span, as text, stored in capitals
	#   pStart     The start of the blocked span, as text
	#   pEnd       The end of the blocked span, as text
	#   returns    nothing; the timeline changes
	#   note       points and spans added before are not checked against it
	#   warning    raises an error when the label is not text, the end is not after the start or the
	#              stretch leaves the timeline
	#   see        RemoveBlockedSpan, BlockedSpans, IsBlocked
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
	
	# Lifts the block of the first blocked span with a label, matched in any case; a missing label changes nothing.
	#
	#   pcLabel    The label of the blocked span, as text
	#   returns    nothing; the timeline changes
	#   see        AddBlockedSpan, BlockedSpans
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
	
	# Returns the blocked spans as [ label, start, end ], the label in capitals, in the order they were added.
	#
	#   returns    a list of [ label, start, end ] lists
	#   see        AddBlockedSpan, BlockedPoints
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
		_aTimepoints_ + ["", @cStart, "", "Timeline start", "boundary"]
		
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
		_aTimepoints_ + ["", @cEnd, "", "Timeline end", "boundary"]
	
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
				return 0
			ok
		next
		
		# Don't place if overlaps with blocked points
		_nLen_ = len(@aBlockedPoints)
		for i = 1 to _nLen_
			_nBlockPos_ = _timeToPosition(@aBlockedPoints[i])
			if _nBlockPos_ >= _nLabelStart_ and _nBlockPos_ <= _nLabelEnd_
				return 0
			ok
		next
		
		return 1

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
			
			_bCollides_ = 0
			_nLenJ_ = len(_aPlaced_)
	
			for j = 1 to _nLenJ_
				_nPlacedStart_ = _aPlaced_[j][1]
				_nPlacedEnd_ = _aPlaced_[j][2]
				
				if not (_nLabelEnd_ < _nPlacedStart_ or _nLabelStart_ > _nPlacedEnd_)
					_bCollides_ = 1
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
			if _aTimepoints_[i][1] != ""
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
			if _nIndex_ = ""
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
	
	            _bHighlighted_ = 0
	            if @cHighlight != "" and _aTimepoints_[i][3] = @cHighlight
	                _bHighlighted_ = 1
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
	        
	        _bHighlighted_ = (@cHighlight != "" and @cHighlight = _cLabel_)
	        
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
			
			_bFree_ = 1
			for _nPos_ = _nStartPos_ to _nEndPos_
				if find(_aRowUsed_[nOffset], _nPos_) > 0
					_bFree_ = 0
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
			if _nIndex_ != ""
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
