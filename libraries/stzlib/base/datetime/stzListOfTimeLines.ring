
/*
	stzTimeLines - Collection of Timelines in Softanza
	Manages multiple parallel timelines (lanes) for 2D time space modeling
	Extends stzTimeLine's philosophy to multi-lane scenarios
	String-first design: methods accept/return strings, ...Q() returns objects
*/

func StzTimeLinesQ(p)
	return new stzTimeLines(p)

	func stzListOfTimeLinesQ(p)
		return new stzTimeLines(p)

func TimeLines(p)
	return new stzTimeLines(p)

class stzTimeLines from stzListOfTimeLines

# Holds several named lanes of events on one shared time axis, to ask what happens when across all of them.
#
# Build one with new stzListOfTimeLines([ :Lanes = [ ... ], :Start = ..., :End = ... ]); it is also
# reached as stzTimeLines, TimeLines(p) and StzTimeLinesQ(p). Each lane is a stzTimeLine over the
# shared bounds. Lane names are stored in upper case and every lookup ignores case, and the dates
# are read as text, a bare date meaning midnight. What works today: the lane management (AddLane,
# RemoveLane, Lanes, HasLane), AddPointToLane (and its alias AddMomentToLane), WhatsAt,
# SetGlobalStart and SetGlobalEnd, Duration, Content, ToTimeLine and Clear. Lane(name) returns a
# copy of the lane's timeline, and the methods that edit through it silently keep nothing:
# AddSpanToLane, AddSpansToLane, AddPointsToLane, AddBlockedSpanToLane, AddBlockedPointToLane,
# RenameLabelInLane and RemovePointFromLane all do nothing, so no span can be stored and the span-
# based reads (HasOverlapsInLane, CrossLaneOverlaps, UncoveredPeriodsPerLane) were not exercised
# with real data. Copy keeps the lanes and bounds but not their points. BlockSpanInLane and
# BlockPointInLane raise R14, and the whole drawing family (Show, ShowShort, ShowUncovered, VizFind)
# raises R19; each says so in its own entry. Lane names of any script (Hebrew, Arabic, emoji) work.
#
#   receiver   o1 = new stzListOfTimeLines([ :Lanes = [ "Team A", "Team B" ], :Start = "2026-01-01",
#              :End = "2026-12-31" ])
#   example    ? @@( o1.Lanes() )
#              #--> [ "TEAM A", "TEAM B" ]
#              ? o1.Duration()
#              #--> 31449600
#              o1.AddPointToLane("team a", "Kickoff", "2026-02-01")
#              ? @@( o1.WhatsAt("2026-02-01") )
#              #--> [ [ [ "lane", "TEAM A" ], [ "events", [ [ "KICKOFF", "point" ] ] ] ] ]
#              o2 = new stzListOfTimeLines([ :Lanes = [ "צוות", "فريق", "😀" ], :Start = "2026-01-01 08:00:00", :End = "2026-01-01 18:00:00" ])
#              o2.AddPointToLane("فريق", "اجتماع", "2026-01-01 09:30:00")
#              ? o2.NumberOfLanes()
#              #--> 3
#              ? o2.Duration()
#              #--> 36000
#   see        stzTimeLine, stzDateTime, stzDuration
class stzListOfTimeLines from stzObject
	@aLanes = []       # List of lane names: ["Team A", "Team B", ...]
	@aTimeLines = []   # Corresponding list of stzTimeLine objects

	@cGlobalStart = ""
	@cGlobalEnd = ""

	# Visualization properties (extended from stzTimeLine)
	@nVizWidth = 52
	@nVizMinWidth = 30
	@nVizLaneHeight = 5  # Per lane, will auto-adjust

	# Shared chars with stzTimeLine
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

	@bShowDates = 1
	@bShowLabels = 1
	@cHighlight = ""  # Can highlight across lanes

	# Multi-lane layout
	@nLabelWidth = 15  # For lane labels on the left
	@acVizCanvas = []  # Global canvas for all lanes

	# Builds a set of parallel timelines, one lane per name, all sharing a start and an end.
	#
	#   p          a hash list with :Lanes = a list of lane names, :Start = the first moment and
	#              :End = the last moment (:From and :To also work), any other value, or a missing
	#              key, raises an error
	#   returns    nothing; the object is built with every lane empty
	#   note       lane names are stored in upper case, so Team A is read back as TEAM A, and every
	#              lookup ignores case; Hebrew, Arabic and emoji names work; the class is also
	#              reached as stzTimeLines, TimeLines(p) and StzTimeLinesQ(p)
	#   warning    a start or end that is only a time, or not a date, raises an error; a date
	#              without a time becomes midnight
	#   see        AddLane, GlobalStart
	def init(p)
		if isList(p) and IsHashList(p)
			// Assume named params like :Lanes = [...], :Start = ..., :End = ...
			if HasKey(p, :Lanes)
				# Uppercase here -- Lane() and HasLane() lookup
				# with StzUpper(pcLane), but init was storing the
				# names as the user passed them. The mismatch made
				# every init-set lane unreachable.
				_aLnsTmp_ = p[:Lanes]
				@aLanes = []
				_n_aLnsTmpLen_ = len(_aLnsTmp_)
				for _iLn_ = 1 to _n_aLnsTmpLen_
					@aLanes + StzUpper(_aLnsTmp_[_iLn_])
				next
			else
				StzRaise("Missing required param! :Lanes must be provided as a list of strings.")
			ok

			if HasKey(p, :Start)
				@cGlobalStart = This._normalizeDateTime(p[:Start])

			but HasKey(p, :From)
				@cGlobalStart = This._normalizeDateTime(p[:From])

			else
				StzRaise("Missing required param! :Start must be provided.")
			ok

			# Case-normalised the keys here. Ring's HasKey is
			# actually case-insensitive, so the bug was symptomatic
			# rather than literal -- but the case inconsistency made
			# the intent ambiguous (line checked :end but read :End).
			if HasKey(p, :End)
				@cGlobalEnd = This._normalizeDateTime(p[:End])

			but HasKey(p, :To)
				@cGlobalEnd = This._normalizeDateTime(p[:To])

			else
				StzRaise("Missing required param! :End must be provided.")
			ok
		else
			StzRaise("Incorrect init params! Provide a hashlist with :Lanes, :Start, and :End.")
		ok

		// Initialize each lane as a stzTimeLine with global bounds
		# Removed stray debug print: `? @@([@cGlobalStart, @cGlobalEnd])`
		_nLen_ = len(@aLanes)
		for i = 1 to _nLen_
			_oLaneTL_ = new stzTimeLine(@cGlobalStart, @cGlobalEnd)
			@aTimeLines + _oLaneTL_
		next

	# Returns the whole set as data: the start, the end, the lane names and each lane's content.
	#
	#   returns    a hash list with the keys start, end, lanes and timelines
	#   note       each timeline entry holds the lane name and that lane's start, end, points and
	#              spans; the keys read back in lower case
	#   see        Lanes, GlobalStart
	def Content()
		_aResult_ = [
			:Start = @cGlobalStart,
			:End = @cGlobalEnd,
			:Lanes = @aLanes,
			:TimeLines = []
		]

		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			_aResult_[:TimeLines] + [
				:Lane = @aLanes[i],
				:Content = @aTimeLines[i].Content()
			]
		next

		return _aResult_

	// Global Boundaries

	# Returns the first moment shared by every lane.
	#
	#   returns    a text such as 2026-01-01 00:00:00
	#   note       GlobalStartQ returns it as a stzDateTime
	#   see        GlobalEnd, SetGlobalStart
	def GlobalStart()
		return @cGlobalStart

		def GlobalStartQ()
			if @cGlobalStart != ""
				return new stzDateTime(@cGlobalStart)
			ok
			return ""

	# Returns the last moment shared by every lane.
	#
	#   returns    a text such as 2026-12-31 00:00:00
	#   note       GlobalEndQ returns it as a stzDateTime
	#   see        GlobalStart, SetGlobalEnd
	def GlobalEnd()
		return @cGlobalEnd

		def GlobalEndQ()
			if @cGlobalEnd != ""
				return new stzDateTime(@cGlobalEnd)
			ok
			return ""

	# Moves the shared start and applies it to every lane, keeping the points already there.
	#
	#   p          the new first moment, a date or a date and time as text
	#   returns    nothing; the bounds change. SetGlobalStartQ returns the set for chaining
	#   note       a date alone becomes midnight
	#   see        SetGlobalEnd, GlobalStart
	def SetGlobalStart(p)
		@cGlobalStart = This._normalizeDateTime(p)
		This._updateAllLanesBounds()

		def SetGlobalStartQ(p)
			This.SetGlobalStart(p)
			return This

	# Moves the shared end and applies it to every lane, keeping the points already there.
	#
	#   p          the new last moment, a date or a date and time as text
	#   returns    nothing; the bounds change. SetGlobalEndQ returns the set for chaining
	#   see        SetGlobalStart, GlobalEnd
	def SetGlobalEnd(p)
		@cGlobalEnd = This._normalizeDateTime(p)
		This._updateAllLanesBounds()

		def SetGlobalEndQ(p)
			This.SetGlobalEnd(p)
			return This

	def _updateAllLanesBounds()
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			@aTimeLines[i].SetStart(@cGlobalStart)
			@aTimeLines[i].SetEnd(@cGlobalEnd)
		next

	# Returns the time from the shared start to the shared end, in seconds.
	#
	#   returns    a number of seconds
	#   note       2026-01-01 to 2026-12-31 is 31449600 seconds, 364 days; DurationQ returns it as a
	#              stzDuration
	#   see        GlobalStart, GlobalEnd
	def Duration()
		return This.GlobalStartQ().DurationTo(@cGlobalEnd, :InSeconds)

		def DurationQ()
			if This.Duration() != ""
				return new stzDuration(This.Duration())
			ok
			return ""

	// Lane Management

	# Returns the lane names, in the order they were added.
	#
	#   returns    a list of texts, in upper case
	#   see        NumberOfLanes, HasLane
	def Lanes()
		return @aLanes

	# Returns how many lanes there are.
	#
	#   returns    a number
	#   see        Lanes
	def NumberOfLanes()
		return len(@aLanes)

	# Returns the timeline of one lane, as a copy.
	#
	#   pcLane     the lane name, without regard to case
	#   returns    a stzTimeLine; an error is raised for an unknown name
	#   note       reading it with Points or Spans works; LaneQ is the same call
	#   warning    the object returned is a copy: adding to it or editing it changes nothing in the
	#              set, so use the AddPointToLane family to change a lane
	#   see        Lanes, HasLane
	def Lane(pcLane)
		_nIndex_ = StzFindFirst(StzUpper(pcLane), @aLanes)
		if _nIndex_ > 0
			return @aTimeLines[_nIndex_]
		else
			StzRaise("No lane found with name: " + pcLane)
		ok

		def LaneQ(pcLane)
			return This.Lane(pcLane)  // Already a stzTimeLine object

	# TRUE if a lane of that name exists.
	#
	#   pcLane     the lane name, without regard to case
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Lanes, AddLane
	def HasLane(pcLane)
		return StzFindFirst(StzUpper(pcLane), @aLanes) > 0

	# Adds an empty lane with the shared start and end.
	#
	#   pcLane     the new lane name, stored in upper case, a name already used raises an error
	#   returns    nothing; a lane is added. AddLaneQ returns the set for chaining
	#   see        RemoveLane, HasLane
	def AddLane(pcLane)
		if This.HasLane(pcLane)
			StzRaise("Lane already exists: " + pcLane)
		ok
		@aLanes + StzUpper(pcLane)
		_oNewTL_ = new stzTimeLine(@cGlobalStart, @cGlobalEnd)
		@aTimeLines + _oNewTL_

		def AddLaneQ(pcLane)
			This.AddLane(pcLane)
			return This

	# Removes a lane and all it holds; a name that is not there changes nothing.
	#
	#   pcLane     the lane name, without regard to case
	#   returns    nothing; the lane is gone. RemoveLaneQ returns the set for chaining
	#   see        AddLane, Lanes
	def RemoveLane(pcLane)
		_nIndex_ = StzFindFirst(StzUpper(pcLane), @aLanes)
		if _nIndex_ > 0
			del(@aLanes, _nIndex_)
			del(@aTimeLines, _nIndex_)
		ok

		def RemoveLaneQ(pcLane)
			This.RemoveLane(pcLane)
			return This

	// Adding to Specific Lanes (Delegates to stzTimeLine methods)

	# Adds a labelled point in time to a lane.
	#
	#   pcLane      the lane name
	#   pcLabel     the label of the point, stored in upper case
	#   pDateTime   when it happens, inside the shared bounds, otherwise an error is raised
	#   returns     nothing; the lane changes. AddPointToLaneQ returns the set for chaining
	#   note        AddMomentToLane is the same call; it is the one add method of this class that
	#               really keeps what it is given
	#   warning     an unknown lane raises an error
	#   see         AddMomentToLane, WhatsAt, AddPointsToLane
	def AddPointToLane(pcLane, pcLabel, pDateTime)
		# Was `oLaneTL = This.Lane(pcLane); oLaneTL.AddPoint(...)` --
		# Ring returns a COPY of the stzTimeLine object from list
		# indexing, so the mutation never persisted back into
		# @aTimeLines. Index directly so the in-place AddPoint
		# writes to the stored timeline.
		_nIndex_ = StzFindFirst(StzUpper(pcLane), @aLanes)
		if _nIndex_ = 0
			StzRaise("No lane found with name: " + pcLane)
		ok
		@aTimeLines[_nIndex_].AddPoint(pcLabel, pDateTime)

		def AddPointToLaneQ(pcLane, pcLabel, pDateTime)
			This.AddPointToLane(pcLane, pcLabel, pDateTime)
			return This

		# Adds a labelled point in time to a lane.
		#
		#   pcLane      the lane name
		#   pcLabel     the label of the point
		#   pDateTime   when it happens
		#   returns     nothing; the lane changes
		#   note        the same call as AddPointToLane
		#   see         AddPointToLane, WhatsAt
		def AddMomentToLane(pcLane, pcLabel, pDateTime)
			This.AddPointToLane(pcLane, pcLabel, pDateTime)

	# Does nothing today instead of adding several points to a lane at once.
	#
	#   pcLane     the lane name
	#   paPoints   a list of [ label, moment ] pairs
	#   returns    nothing
	#   note       add points one at a time with AddPointToLane
	#   warning    it edits the copy that Lane returns, so the lane stays empty and no error is
	#              raised: after AddPointsToLane("b", [ ["Alpha", "2026-07-01"] ]) the lane holds no
	#              point, where the same call on the copy gives it
	#   see        AddPointToLane
	def AddPointsToLane(pcLane, paPoints)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddPoints(paPoints)

	# Does nothing today instead of adding a labelled span of time to a lane.
	#
	#   pcLane     the lane name
	#   pcLabel    the label of the span
	#   pStart     when it starts
	#   pEnd       when it ends
	#   returns    nothing
	#   note       AddSpanToLaneQ and AddPeriodToLane are the same call and lose the span too
	#   warning    it edits the copy that Lane returns, so the lane stays empty and no error is
	#              raised: AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01") leaves Spans
	#              of the lane empty, though the same call on the copy returns the span
	#   see        AddPointToLane, AddSpansToLane
	def AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddSpan(pcLabel, pStart, pEnd)

		def AddSpanToLaneQ(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
			return This

		# Does nothing today instead of adding a labelled period to a lane.
		#
		#   pcLane     the lane name
		#   pcLabel    the label of the period
		#   pStart     when it starts
		#   pEnd       when it ends
		#   returns    nothing
		#   warning    it is AddSpanToLane, which edits a copy and keeps nothing
		#   see        AddSpanToLane
		def AddPeriodToLane(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)

	# Does nothing today instead of adding several spans to a lane at once.
	#
	#   pcLane     the lane name
	#   paSpans    a list of [ label, start, end ] triples
	#   returns    nothing
	#   warning    it edits the copy that Lane returns, so the lane stays empty and no error is
	#              raised
	#   see        AddSpanToLane
	def AddSpansToLane(pcLane, paSpans)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddSpans(paSpans)

	// Blocking in Lanes

	# Does nothing today instead of blocking a labelled span of a lane.
	#
	#   pcLane     the lane name
	#   pcLabel    the label of the blocked span
	#   pStart     when it starts
	#   pEnd       when it ends
	#   returns    nothing
	#   warning    it edits the copy that Lane returns: afterwards IsBlockedInLane for a moment
	#              inside the span answers FALSE
	#   see        AddBlockedPointToLane, IsBlockedInLane
	def AddBlockedSpanToLane(pcLane, pcLabel, pStart, pEnd)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddBlockedSpan(pcLabel, pStart, pEnd)

	# Does nothing today instead of blocking a moment of a lane.
	#
	#   pcLane      the lane name
	#   pDateTime   the moment to block
	#   returns     nothing
	#   warning     it edits the copy that Lane returns: afterwards IsBlockedInLane for that moment
	#               answers FALSE
	#   see         AddBlockedSpanToLane, IsBlockedInLane
	def AddBlockedPointToLane(pcLane, pDateTime)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddBlockedPoint(pDateTime)

	# Raises error R14 today instead of blocking an existing span of a lane by its label.
	#
	#   pcLane     the lane name
	#   pcLabel    the label of the span to block
	#   returns    nothing; it raises
	#   warning    it calls BlockSpan on the lane's timeline, a method stzTimeLine does not have, so
	#              every call raises R14
	#   see        AddBlockedSpanToLane
	def BlockSpanInLane(pcLane, pcLabel)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.BlockSpan(pcLabel)

	# Raises error R14 today instead of blocking an existing point of a lane by its label.
	#
	#   pcLane     the lane name
	#   pcLabel    the label of the point to block
	#   returns    nothing; it raises
	#   warning    it calls BlockPoint on the lane's timeline, a method stzTimeLine does not have,
	#              so every call raises R14
	#   see        AddBlockedPointToLane
	def BlockPointInLane(pcLane, pcLabel)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.BlockPoint(pcLabel)

	# TRUE if a moment is blocked in a lane.
	#
	#   pcLane     the lane name
	#   p          the moment to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       nothing can be blocked through this class today, so it answers FALSE for every
	#              moment (see AddBlockedPointToLane)
	#   warning    an unknown lane raises an error
	#   see        AddBlockedPointToLane, Lane
	def IsBlockedInLane(pcLane, p)
		_oLaneTL_ = This.Lane(pcLane)
		return _oLaneTL_.IsBlocked(p)

	// Querying Across Lanes

	# Returns, lane by lane, what happens at a given moment; a lane with nothing is left out.
	#
	#   pDateTime   the moment to look at, a date or a date and time as text
	#   returns     a list of [ :Lane, :Events ] pairs, each event being [ label, kind ]; empty when
	#               nothing happens
	#   note        a point shows as [ KICKOFF, point ]; spans cannot be stored through this class
	#               today, so only points are ever found
	#   see         AddPointToLane, Lane
	def WhatsAt(pDateTime)
		_cDateTime_ = This._normalizeDateTime(pDateTime)
		_aResult_ = []

		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			_aLaneEvents_ = @aTimeLines[i].WhatsAt(_cDateTime_)
			if len(_aLaneEvents_) > 0
				_aResult_ + [ :Lane = @aLanes[i], :Events = _aLaneEvents_ ]
			ok
		next

		return _aResult_

	# TRUE if two spans of a lane overlap.
	#
	#   pcLane     the lane name
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       no span can be stored in a lane today (see AddSpanToLane), so it answers FALSE
	#   warning    an unknown lane raises an error
	#   see        CrossLaneOverlaps, AddSpanToLane
	def HasOverlapsInLane(pcLane)
		_oLaneTL_ = This.Lane(pcLane)
		return _oLaneTL_.HasOverlaps()

	# Returns the overlaps between spans of different lanes: the two lanes, the two labels and the overlap in seconds.
	#
	#   returns    a list of rows [ [ lane, lane ], label, label, seconds ]; empty today
	#   note       it reads the spans of the lanes, and no span can be stored in a lane today (see
	#              AddSpanToLane), so it was not exercised with real overlaps
	#   see        HasOverlapsInLane, UncoveredPeriodsPerLane
	def CrossLaneOverlaps()
		// Detect overlaps between events in different lanes at the same time
		_aResult_ = []
		_nLen_ = len(@aTimeLines)

		for i = 1 to _nLen_ - 1
			_aSpansI_ = @aTimeLines[i].Spans()
			for j = i + 1 to _nLen_
				_aSpansJ_ = @aTimeLines[j].Spans()
				// Check for overlapping spans between lane i and j
				_nSpansI1Len_ = len(_aSpansI_)
				for _iLoopSpansI1_ = 1 to _nSpansI1Len_
					_s1_ = _aSpansI_[_iLoopSpansI1_]
					_oStart1_ = new stzDateTime(_s1_[2])
					_oEnd1_ = new stzDateTime(_s1_[3])
					_nSpansJ1Len_ = len(_aSpansJ_)
					for _iLoopSpansJ1_ = 1 to _nSpansJ1Len_
						_s2_ = _aSpansJ_[_iLoopSpansJ1_]
						_oStart2_ = new stzDateTime(_s2_[2])
						_oEnd2_ = new stzDateTime(_s2_[3])
						if _oStart1_ < _oEnd2_ and _oStart2_ < _oEnd1_
							_nOverlapDur_ = min([_oEnd1_.Seconds(), _oEnd2_.Seconds()]) - max([_oStart1_.Seconds(), _oStart2_.Seconds()])
							_aResult_ + [ [@aLanes[i], @aLanes[j]], _s1_[1], _s2_[1], _nOverlapDur_ ]
						ok
					next
				next
			next
		next

		return _aResult_

	# Returns, for each lane, the periods of the shared bounds that no span covers.
	#
	#   returns    a list of [ :Lane, :Uncovered ] pairs
	#   note       it reads spans, which cannot be stored today, so every lane answered an empty
	#              list of uncovered periods in the test
	#   see        CrossLaneOverlaps, Lane
	def UncoveredPeriodsPerLane()
		_aResult_ = []
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			_aUncovered_ = @aTimeLines[i].UncoveredPeriods()
			_aResult_ + [ :Lane = @aLanes[i], :Uncovered = _aUncovered_ ]
		next
		return _aResult_

	// Visualization (Multi-Lane)

	# Raises error R19 today instead of returning a drawing of all the lanes.
	#
	#   returns    nothing; it raises
	#   note       use WhatsAt, Lane(name).Points() or Content to read the lanes
	#   warning    it calls an internal drawing routine without the arguments it needs; the drawing
	#              routines behind it are also unfinished stubs, so no picture exists to return
	#   see        ShowShort, ShowUncovered, WhatsAt
	def Show()
		This._buildVizCanvas()
		return This._vizCanvasToString()

	# Raises error R19 today instead of returning a short drawing of all the lanes.
	#
	#   returns    nothing; it raises
	#   warning    it fails as Show does, through the same internal drawing routine
	#   see        Show
	def ShowShort()
		This._buildVizCanvas(:Short)
		return This._vizCanvasToString()

	def ShowXT(paOptions)
		// paOptions could include :TableType = :Statistical or :Descriptive
		This._buildVizCanvas(:Extended, paOptions)
		return This._vizCanvasToString() + nl + This._buildTable(paOptions)

	# Raises error R19 today instead of returning a drawing that marks the uncovered periods.
	#
	#   returns    nothing; it raises
	#   warning    it fails as Show does, through the same internal drawing routine
	#   see        Show, UncoveredPeriodsPerLane
	def ShowUncovered()
		This._buildVizCanvas(:Uncovered)
		return This._vizCanvasToString()

	# Raises error R19 today instead of drawing the lanes with one label highlighted.
	#
	#   pcLabel    the label to highlight, matched in upper case
	#   returns    nothing; it raises
	#   warning    it ends by calling Show, which fails: Show raises error R19
	#   see        Show
	def VizFind(pcLabel)
		@cHighlight = StzUpper(pcLabel)
		return This.Show()

		def VizFindQ(pcLabel)
			This.VizFind(pcLabel)
			return This

	def _buildVizCanvas(pcMode, paOptions)
		// Clear canvas
		@acVizCanvas = []

		// Calculate global layout
		_oGlobalLayout_ = This._calculateGlobalLayout()

		// For each lane, build its timepoints and draw
		_nLenLanes_ = len(@aLanes)
		_nCurrentRow_ = 1  // Start row for first lane

		for i = 1 to _nLenLanes_
			// Add lane label on the left
			This._addLaneLabelToCanvas(_nCurrentRow_, @aLanes[i])

			// Get lane's timepoints
			_aTimepoints_ = @aTimeLines[i]._buildSortedTimepoints()

			// Draw axis for this lane
			This._drawAxisForLane(_nCurrentRow_ + @nVizLaneHeight / 2, _oGlobalLayout_)  // Middle of lane height

			// Draw points, spans, etc., offset to lane's section
			This._drawForLane(i, _nCurrentRow_, _aTimepoints_, pcMode)

			_nCurrentRow_ += @nVizLaneHeight + 1  // +1 for separator
		next

	def _addLaneLabelToCanvas(nRow, pcLane)
		// Pad label to @nLabelWidth and add to canvas rows
		_cPaddedLabel_ = pcLane + Q(" " * (@nLabelWidth - len(pcLane)))
		// Assume canvas rows are built vertically; integrate into @acVizCanvas

	def _calculateGlobalLayout()
		// Similar to stzTimeLine's _calculateRequiredVizHeight but global
		_nMaxHeight_ = 0
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			_nLaneHeight_ = @aTimeLines[i]._calculateRequiredVizHeight()
			if _nLaneHeight_ > _nMaxHeight_
				_nMaxHeight_ = _nLaneHeight_
			ok
		next
		@nVizLaneHeight = _nMaxHeight_

		return [ :width = @nVizWidth, :lane_height = @nVizLaneHeight ]

	def _drawAxisForLane(nRow, _oLayout_)
		// Adapted from stzTimeLine's _drawAxis, but at specific row

	def _drawForLane(nLaneIndex, nStartRow, _aTimepoints_, pcMode)
		_oLaneTL_ = @aTimeLines[nLaneIndex]
		_oLayout_ = [ :axis_row = nStartRow + 2 ]  // Example offset

		// Delegate drawing to adapted stzTimeLine methods, but offset rows
		_oLaneTL_._drawSpans(_oLayout_, _aTimepoints_)
		_oLaneTL_._drawPoints(_oLayout_, _aTimepoints_)
		if pcMode = :Uncovered
			_aUncovered_ = _oLaneTL_.UncoveredPeriods()
			_oLaneTL_._drawUncoveredRegions(_oLayout_, _aUncovered_)
		ok
		// etc. for blocks, highlights

	def _vizCanvasToString()
		// Similar to stzTimeLine's _vizCanvasToString

	def _buildTable(paOptions)
		// Aggregate stats across lanes, similar to _buildStatisticalTable
		// E.g., Total Points Per Lane, Cross-Lane Overlaps, etc.

	// Normalization (Delegated from stzTimeLine)

	def _normalizeDateTime(pDateTime)
		# Was an empty stub ("// Copy from stzTimeLine's
		# _normalizeDateTime") -- every call returned NULL, so init's
		# @cGlobalStart and @cGlobalEnd both wound up empty and the
		# class could not construct. Ported the impl from stzTimeLine.
		_cDateTime_ = ""

		if isString(pDateTime)
			_cDateTime_ = trim(pDateTime)
			if _cDateTime_ = ""
				StzRaise("Invalid format! Empty strings are not allowed for datevalue!")
			ok
		else
			_cDateTime_ = new stzDateTime(pDateTime).ToString()
		ok

		if This._isTimeOnly(_cDateTime_)
			StzRaise("Invalid format! Time specified without a date")
		but This._isDateOnly(_cDateTime_)
			_cDateTime_ += " 00:00:00"
		ok

		try
			new stzDateTime(_cDateTime_)
		catch
			StzRaise("Invalid datetime format (" + _cDateTime_ + ")!")
		done

		return _cDateTime_

		def _isDateOnly(_cDateTime_)
			# Was an empty stub. Ported from stzTimeLine.
			if StzLen(_cDateTime_) = 10 and StzMid(_cDateTime_, 5, 1) = "-" and StzMid(_cDateTime_, 8, 1) = "-"
				return 1
			else
				return 0
			ok

		def _isTimeOnly(_cDateTime_)
			# Was an empty stub. Ported from stzTimeLine.
			if StzLen(_cDateTime_) = 8 and StzMid(_cDateTime_, 3, 1) = ":" and StzMid(_cDateTime_, 6, 1) = ":"
				return 1
			else
				return 0
			ok

	// Other Delegated Methods (with lane param)

	// For example:
	# Does nothing today instead of removing a point from a lane by label or moment.
	#
	#   pcLane              the lane name
	#   pcLabelOrDateTime   the label or the moment of the point to remove
	#   returns             nothing
	#   warning             it edits the copy that Lane returns, so the point stays in the lane and
	#                       no error is raised: removing KICKOFF2 or the moment 2026-02-01 leaves
	#                       the lane unchanged
	#   see                 AddPointToLane
	def RemovePointFromLane(pcLane, pcLabelOrDateTime)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.RemovePoint(pcLabelOrDateTime)

	# Does nothing today instead of renaming a point label in a lane.
	#
	#   pcLane       the lane name
	#   pcLabel      the label to change
	#   pcNewLabel   the new label
	#   returns      nothing
	#   warning      it edits the copy that Lane returns, so the label stays as it was and no error
	#                is raised
	#   see          AddPointToLane
	def RenameLabelInLane(pcLane, pcLabel, pcNewLabel)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.RenameLabel(pcLabel, pcNewLabel)

	// Add more as needed, following the pattern

	// ToTimeLine(pcMergeStrategy)
	# Merges every lane into one stzTimeLine over the shared bounds, prefixing each label with its lane name.
	#
	#   pcStrategy   how to merge, an empty text or :MergeAll merges everything, and no other
	#                strategy is read
	#   returns      a stzTimeLine
	#   note         a point KICKOFF of lane TEAM A becomes TEAM A-KICKOFF; the spans merge the same
	#                way
	#   see          Lane, Content
	def ToTimeLine(pcStrategy)
		if pcStrategy = ""
			pcStrategy = :MergeAll
		ok

		// Merge all lanes into a single stzTimeLine
		// Strategy: :MergeAll (combine points/spans with lane prefixes), :SelectLane = "Name", etc.
		_oMerged_ = new stzTimeLine(@cGlobalStart, @cGlobalEnd)
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			_aPoints_ = @aTimeLines[i].Points()
			_nPoints1Len_ = len(_aPoints_)
			for _iLoopPoints1_ = 1 to _nPoints1Len_
				p = _aPoints_[_iLoopPoints1_]
				_oMerged_.AddPoint(@aLanes[i] + "-" + p[1], p[2])
			next
			_aSpans_ = @aTimeLines[i].Spans()
			_nSpans1Len_ = len(_aSpans_)
			for _iLoopSpans1_ = 1 to _nSpans1Len_
				_s_ = _aSpans_[_iLoopSpans1_]
				_oMerged_.AddSpan(@aLanes[i] + "-" + _s_[1], _s_[2], _s_[3])
			next
		next
		return _oMerged_

	# Empties every lane of its points and spans, keeping the lanes and the bounds.
	#
	#   returns    nothing; the lanes are emptied
	#   see        RemoveLane, Lanes
	def Clear()
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			@aTimeLines[i].Clear()
		next

	# Returns a new set built from the same lane names and bounds, without their content.
	#
	#   returns    a stzTimeLines with the same lanes and bounds
	#   note       use Content to read everything
	#   warning    the points of the lanes are not copied: after AddPointToLane,
	#              Copy().Lane(name).Points() answers an empty list
	#   see        Content, Clear
	def Copy()
		return new stzTimeLines(This.Content())  // Assuming Content() returns init-compatible hash
