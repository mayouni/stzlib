
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
# are read as text, a bare date meaning midnight. The lane management (AddLane, RemoveLane, Lanes,
# HasLane), the adding calls (AddPointToLane and its alias AddMomentToLane, AddPointsToLane,
# AddSpanToLane, AddPeriodToLane, AddSpansToLane, AddBlockedSpanToLane, AddBlockedPointToLane), the
# editing calls (RemovePointFromLane, RenameLabelInLane, BlockSpanInLane, BlockPointInLane) and the
# reads (WhatsAt, HasOverlapsInLane, CrossLaneOverlaps, UncoveredPeriodsPerLane, ToTimeLine,
# Content) all work on the lanes stored in the set. Lane(name) returns a copy of a lane's timeline,
# so editing that copy changes nothing in the set. Copy gives an independent set that keeps the
# lanes, the bounds, the points, the spans and the blocks. Show, ShowShort, ShowUncovered, ShowXT
# and VizFind return a text drawing of every lane under its name; they print nothing. Lane names of
# any script (Hebrew, Arabic, emoji) work.
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

	# the position of a lane in the stored list; every method that edits a lane goes through it and
	# edits @aTimeLines[position] in place, because Lane() hands out a copy
	def _laneIndex(pcLane)
		_nIndex_ = StzFindFirst(StzUpper(pcLane), @aLanes)
		if _nIndex_ = 0
			StzRaise("No lane found with name: " + pcLane)
		ok
		return _nIndex_

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
	#   note        AddMomentToLane is the same call; the other lanes are not touched
	#   warning     an unknown lane raises an error
	#   see         AddMomentToLane, WhatsAt, AddPointsToLane
	def AddPointToLane(pcLane, pcLabel, pDateTime)
		# Ring returns a COPY of a stzTimeLine read into a local, so the
		# stored timeline is edited in place through its index.
		_nIndex_ = This._laneIndex(pcLane)
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

	# Adds several labelled points to one lane at once, each given as a label and a moment.
	#
	#   pcLane     the lane name, without regard to case
	#   paPoints   a list of [ label, moment ] pairs, each moment inside the shared bounds
	#   returns    nothing; the lane changes
	#   note       the labels are stored in upper case; the other lanes are not touched
	#   warning    an unknown lane raises an error; so does a moment outside the bounds or on a blocked
	#              moment, and the pairs before it are kept
	#   see        AddPointToLane, AddSpansToLane
	def AddPointsToLane(pcLane, paPoints)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].AddPoints(paPoints)

	# Adds a labelled span of time to one lane, between a start and an end inside the shared bounds.
	#
	#   pcLane     the lane name, without regard to case
	#   pcLabel    the label of the span, kept as given (a span label is not turned to upper case)
	#   pStart     when it starts
	#   pEnd       when it ends, after the start
	#   returns    nothing; the lane changes. AddSpanToLaneQ returns the set for chaining
	#   note       AddPeriodToLane is the same call; the other lanes are not touched
	#   warning    an unknown lane raises an error; so does an end that is not after the start, a span
	#              outside the bounds, or one over a blocked stretch
	#   see        AddPointToLane, AddSpansToLane, AddBlockedSpanToLane
	def AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].AddSpan(pcLabel, pStart, pEnd)

		def AddSpanToLaneQ(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
			return This

		# Adds a labelled period of time to one lane; another spelling of the span-adding call.
		#
		#   pcLane     the lane name, without regard to case
		#   pcLabel    the label of the period, kept as given
		#   pStart     when it starts
		#   pEnd       when it ends, after the start
		#   returns    nothing; the lane changes
		#   note       it is AddSpanToLane under another name
		#   see        AddSpanToLane
		def AddPeriodToLane(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)

	# Adds several labelled spans to one lane at once, each given as a label, a start and an end.
	#
	#   pcLane     the lane name, without regard to case
	#   paSpans    a list of [ label, start, end ] triples
	#   returns    nothing; the lane changes
	#   warning    an unknown lane raises an error; so does a span that fails as AddSpanToLane does, and
	#              the triples before it are kept
	#   see        AddSpanToLane, AddPointsToLane
	def AddSpansToLane(pcLane, paSpans)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].AddSpans(paSpans)

	// Blocking in Lanes

	# Blocks a stretch of one lane, so that no point or span can be added over it afterwards.
	#
	#   pcLane     the lane name, without regard to case
	#   pcLabel    the label of the blocked stretch, stored in upper case
	#   pStart     when it starts
	#   pEnd       when it ends, after the start
	#   returns    nothing; the lane changes
	#   note       points and spans already in the lane are not checked against it
	#   warning    an unknown lane raises an error; so does an end that is not after the start or a
	#              stretch outside the bounds
	#   see        AddBlockedPointToLane, BlockSpanInLane, IsBlockedInLane
	def AddBlockedSpanToLane(pcLane, pcLabel, pStart, pEnd)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].AddBlockedSpan(pcLabel, pStart, pEnd)

	# Blocks one moment of a lane, so that no point or span can be added over it afterwards.
	#
	#   pcLane      the lane name, without regard to case
	#   pDateTime   the moment to block, inside the shared bounds
	#   returns     nothing; the lane changes
	#   warning     an unknown lane raises an error; so does a moment outside the bounds
	#   see         AddBlockedSpanToLane, BlockPointInLane, IsBlockedInLane
	def AddBlockedPointToLane(pcLane, pDateTime)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].AddBlockedPoint(pDateTime)

	# Blocks the stretch of every span of a lane that carries a given label.
	#
	#   pcLane     the lane name, without regard to case
	#   pcLabel    the label of the span or spans to block, without regard to case
	#   returns    nothing; the lane changes, the spans themselves stay
	#   note       the blocked stretch takes the label in upper case, as AddBlockedSpanToLane does
	#   warning    an unknown lane raises an error; so does a label that no span of the lane carries
	#   see        AddBlockedSpanToLane, BlockPointInLane, IsBlockedInLane
	def BlockSpanInLane(pcLane, pcLabel)
		_nIndex_ = This._laneIndex(pcLane)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		_cLabel_ = StzUpper(pcLabel)
		_aSpans_ = @aTimeLines[_nIndex_].Spans()
		_nLen_ = ring_len(_aSpans_)
		_nBlocked_ = 0
		for i = 1 to _nLen_
			if StzUpper(_aSpans_[i][1]) = _cLabel_
				@aTimeLines[_nIndex_].AddBlockedSpan(_aSpans_[i][1], _aSpans_[i][2], _aSpans_[i][3])
				_nBlocked_ += 1
			ok
		next

		if _nBlocked_ = 0
			StzRaise("No span found with label: " + pcLabel)
		ok

	# Blocks the moment of every point of a lane that carries a given label.
	#
	#   pcLane     the lane name, without regard to case
	#   pcLabel    the label of the point or points to block, without regard to case
	#   returns    nothing; the lane changes, the points themselves stay
	#   warning    an unknown lane raises an error; so does a label that no point of the lane carries
	#   see        AddBlockedPointToLane, BlockSpanInLane, IsBlockedInLane
	def BlockPointInLane(pcLane, pcLabel)
		_nIndex_ = This._laneIndex(pcLane)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		_aMoments_ = @aTimeLines[_nIndex_].FindPoint(pcLabel)
		_nLen_ = ring_len(_aMoments_)
		if _nLen_ = 0
			StzRaise("No point found with label: " + pcLabel)
		ok

		for i = 1 to _nLen_
			@aTimeLines[_nIndex_].AddBlockedPoint(_aMoments_[i])
		next

	# TRUE if a moment is blocked in a lane.
	#
	#   pcLane     the lane name, without regard to case
	#   p          the moment to test
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a moment is blocked when it is a blocked point or lies inside a blocked stretch,
	#              edges included (see AddBlockedPointToLane, AddBlockedSpanToLane)
	#   warning    an unknown lane raises an error
	#   see        AddBlockedPointToLane, BlockSpanInLane
	def IsBlockedInLane(pcLane, p)
		_nIndex_ = This._laneIndex(pcLane)
		return @aTimeLines[_nIndex_].IsBlocked(p)

	// Querying Across Lanes

	# Returns, lane by lane, what happens at a given moment; a lane with nothing is left out.
	#
	#   pDateTime   the moment to look at, a date or a date and time as text
	#   returns     a list of [ :Lane, :Events ] pairs, each event being [ label, kind ]; empty when
	#               nothing happens
	#   note        a point shows as [ KICKOFF, point ], and a span as [ Build, span ]
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
	#   note       it answers FALSE for a lane with no span, or whose spans do not overlap
	#   warning    an unknown lane raises an error
	#   see        CrossLaneOverlaps, AddSpanToLane
	def HasOverlapsInLane(pcLane)
		_nIndex_ = This._laneIndex(pcLane)
		return @aTimeLines[_nIndex_].HasOverlaps()

	# Returns the overlaps between spans of different lanes: the two lanes, the two labels and the overlap in seconds.
	#
	#   returns    a list of rows [ [ lane, lane ], label, label, seconds ]; empty when no spans of
	#              two lanes overlap
	#   note       it reads the spans stored in the lanes (see AddSpanToLane); the last figure is the
	#              length of the overlap in seconds
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
							_nOverlapDur_ = min([_oEnd1_.ToUnixTimeStamp(), _oEnd2_.ToUnixTimeStamp()]) - max([_oStart1_.ToUnixTimeStamp(), _oStart2_.ToUnixTimeStamp()])
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
	#   note       it reads the spans stored in the lanes (see AddSpanToLane)
	#   warning    a lane with no span at all answers an empty list, although all of it is uncovered;
	#              this is how the lane's timeline answers (see stzTimeLine UncoveredPeriods)
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

	# Returns a text drawing of every lane, one after the other, each under its name with its table of dates.
	#
	#   returns    a text, empty when the set has no lane
	#   note       each lane is drawn by its own timeline; nothing is printed or opened, so the text
	#              can be written to a file; the drawing uses box characters and needs a console that
	#              shows UTF-8
	#   warning    the span bars of the lane drawing are known to run a few columns off (see
	#              stzTimeLine ToString); the table of dates is right
	#   see        ShowShort, ShowUncovered, VizFind, ShowXT
	def Show()
		return This._drawLanes(:Normal, "")

	# Returns a text drawing of every lane under its name, without the tables of dates.
	#
	#   returns    a text, empty when the set has no lane
	#   note       nothing is printed
	#   see        Show
	def ShowShort()
		return This._drawLanes(:Short, "")

	# Returns a text drawing of every lane under its name, drawn with the options given.
	#
	#   paOptions   a list of [ key, value ] pairs read by the lane timelines: :Width, :Height,
	#               :Highlight, :ShowTable and :TableType (:Statistical for a table of figures)
	#   returns     a text, empty when the set has no lane
	#   note        each lane is drawn from a copy, so the options leave the stored lanes as they were;
	#               nothing is printed
	#   see         Show, ShowShort
	def ShowXT(paOptions)
		return This._drawLanes(:Extended, paOptions)

	# Returns a text drawing of every lane under its name, the uncovered periods marked with slashes.
	#
	#   returns    a text, empty when the set has no lane
	#   note       a lane that no gap leaves open is answered by the sentence that it is fully covered;
	#              nothing is printed
	#   warning    a lane with no span at all is answered by that same sentence, although nothing
	#              covers it (the timeline's own answer)
	#   see        Show, UncoveredPeriodsPerLane
	def ShowUncovered()
		return This._drawLanes(:Uncovered, "")

	# Returns a text drawing of every lane under its name, the points or spans of one label marked.
	#
	#   pcLabel    the label to highlight, without regard to case, a point or a span of any lane
	#   returns    a text; a lane with no such label is drawn as Show draws it
	#   note       a label carried by a point of a lane is marked as a point there, otherwise as a
	#              span; nothing is printed
	#   see        Show
	def VizFind(pcLabel)
		return This._drawLanes(:Highlight, pcLabel)

		def VizFindQ(pcLabel)
			This.VizFind(pcLabel)
			return This

	def _drawLanes(pcMode, pParam)
		_cResult_ = ""
		_nLen_ = ring_len(@aTimeLines)
		for i = 1 to _nLen_
			if i > 1
				_cResult_ += char(10) + char(10)
			ok
			_cResult_ += "== " + @aLanes[i] + " ==" + char(10)
			if pcMode = :Short
				_cResult_ += @aTimeLines[i].ToStringShort()
			but pcMode = :Uncovered
				_cResult_ += @aTimeLines[i].ToStringUncovered()
			but pcMode = :Extended
				# a copy on purpose: the :Highlight and :Height options stay on the timeline they are given to
				_oLaneCopy_ = @aTimeLines[i]
				_cResult_ += _oLaneCopy_.ToStringXT(pParam)
			but pcMode = :Highlight
				_cResult_ += This._drawLaneHighlighted(i, pParam)
			else
				_cResult_ += @aTimeLines[i].ToString()
			ok
		next
		return _cResult_

	def _drawLaneHighlighted(nLane, pcLabel)
		if NOT isString(pcLabel)
			StzRaise("Incorrect param type! pcLabel must be a string.")
		ok

		_cLabel_ = StzUpper(pcLabel)
		if ring_len(@aTimeLines[nLane].FindPoint(_cLabel_)) > 0
			return @aTimeLines[nLane].VizFindMoments(_cLabel_)
		ok

		# spans keep the case they were given, so the stored spelling is looked up
		_aSpans_ = @aTimeLines[nLane].Spans()
		_nLen_ = ring_len(_aSpans_)
		for i = 1 to _nLen_
			if StzUpper(_aSpans_[i][1]) = _cLabel_
				return @aTimeLines[nLane].VizFindSpans(_aSpans_[i][1])
			ok
		next

		return @aTimeLines[nLane].ToString()

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
	# Removes the first point of a lane that carries a label.
	#
	#   pcLane              the lane name, without regard to case
	#   pcLabelOrDateTime   the label of the point to remove, without regard to case
	#   returns             nothing; the lane changes
	#   note                a label that no point carries changes nothing and raises nothing; the other
	#                       lanes are not touched
	#   warning             an unknown lane raises an error; a moment given instead of a label removes
	#                       nothing, because the timeline removes by label only
	#   see                 AddPointToLane
	def RemovePointFromLane(pcLane, pcLabelOrDateTime)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].RemovePoint(pcLabelOrDateTime)

	# Gives a new name to the points of a lane that carry a label, and to its spans of that label.
	#
	#   pcLane       the lane name, without regard to case
	#   pcLabel      the label to change, without regard to case
	#   pcNewLabel   the new label, stored in upper case
	#   returns      nothing; the lane changes
	#   note         a label that nothing carries changes nothing and raises nothing; the other lanes
	#                are not touched
	#   warning      an unknown lane raises an error; a span added with a lowercase letter in its
	#                label keeps its name, because the timeline compares span labels in upper case
	#   see          AddPointToLane
	def RenameLabelInLane(pcLane, pcLabel, pcNewLabel)
		_nIndex_ = This._laneIndex(pcLane)
		@aTimeLines[_nIndex_].RenameLabel(pcLabel, pcNewLabel)

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

	# Returns an independent set built from the same lane names and bounds, with their points, spans and blocks.
	#
	#   returns    a stzTimeLines whose lanes hold what these lanes hold
	#   note       changing the copy, or the original afterwards, leaves the other as it was; use
	#              Content to read everything
	#   see        Content, Clear
	def Copy()
		_oCopy_ = new stzTimeLines(This.Content())  // Content() holds the init keys :Lanes, :Start and :End

		_nLen_ = ring_len(@aTimeLines)
		for i = 1 to _nLen_
			_cLane_ = @aLanes[i]
			_oCopy_.AddPointsToLane(_cLane_, @aTimeLines[i].Points())
			_oCopy_.AddSpansToLane(_cLane_, @aTimeLines[i].Spans())

			# blocks go in last: adding over a block is refused
			_aBlockedPoints_ = @aTimeLines[i].BlockedPoints()
			_nBlockedPoints_ = ring_len(_aBlockedPoints_)
			for j = 1 to _nBlockedPoints_
				_oCopy_.AddBlockedPointToLane(_cLane_, _aBlockedPoints_[j])
			next

			_aBlockedSpans_ = @aTimeLines[i].BlockedSpans()
			_nBlockedSpans_ = ring_len(_aBlockedSpans_)
			for j = 1 to _nBlockedSpans_
				_oCopy_.AddBlockedSpanToLane(_cLane_, _aBlockedSpans_[j][1], _aBlockedSpans_[j][2], _aBlockedSpans_[j][3])
			next
		next

		return _oCopy_
