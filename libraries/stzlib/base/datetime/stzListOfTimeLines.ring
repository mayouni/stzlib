
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

class stzListOfTimeLines from stzObject
	@aLanes = []       # List of lane names: ["Team A", "Team B", ...]
	@aTimeLines = []   # Corresponding list of stzTimeLine objects

	@cGlobalStart = NULL
	@cGlobalEnd = NULL

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

	@bShowDates = TRUE
	@bShowLabels = TRUE
	@cHighlight = NULL  # Can highlight across lanes

	# Multi-lane layout
	@nLabelWidth = 15  # For lane labels on the left
	@acVizCanvas = []  # Global canvas for all lanes

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

	def GlobalStart()
		return @cGlobalStart

		def GlobalStartQ()
			if @cGlobalStart != NULL
				return new stzDateTime(@cGlobalStart)
			ok
			return NULL

	def GlobalEnd()
		return @cGlobalEnd

		def GlobalEndQ()
			if @cGlobalEnd != NULL
				return new stzDateTime(@cGlobalEnd)
			ok
			return NULL

	def SetGlobalStart(p)
		@cGlobalStart = This._normalizeDateTime(p)
		This._updateAllLanesBounds()

		def SetGlobalStartQ(p)
			This.SetGlobalStart(p)
			return This

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

	def Duration()
		return This.GlobalStartQ().DurationTo(@cGlobalEnd, :InSeconds)

		def DurationQ()
			if This.Duration() != NULL
				return new stzDuration(This.Duration())
			ok
			return NULL

	// Lane Management

	def Lanes()
		return @aLanes

	def NumberOfLanes()
		return len(@aLanes)

	def Lane(pcLane)
		_nIndex_ = StzFindFirst(@aLanes, StzUpper(pcLane))
		if _nIndex_ > 0
			return @aTimeLines[_nIndex_]
		else
			StzRaise("No lane found with name: " + pcLane)
		ok

		def LaneQ(pcLane)
			return This.Lane(pcLane)  // Already a stzTimeLine object

	def HasLane(pcLane)
		return StzFindFirst(@aLanes, StzUpper(pcLane)) > 0

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

	def RemoveLane(pcLane)
		_nIndex_ = StzFindFirst(@aLanes, StzUpper(pcLane))
		if _nIndex_ > 0
			del(@aLanes, _nIndex_)
			del(@aTimeLines, _nIndex_)
		ok

		def RemoveLaneQ(pcLane)
			This.RemoveLane(pcLane)
			return This

	// Adding to Specific Lanes (Delegates to stzTimeLine methods)

	def AddPointToLane(pcLane, pcLabel, pDateTime)
		# Was `oLaneTL = This.Lane(pcLane); oLaneTL.AddPoint(...)` --
		# Ring returns a COPY of the stzTimeLine object from list
		# indexing, so the mutation never persisted back into
		# @aTimeLines. Index directly so the in-place AddPoint
		# writes to the stored timeline.
		_nIndex_ = StzFindFirst(@aLanes, StzUpper(pcLane))
		if _nIndex_ = 0
			StzRaise("No lane found with name: " + pcLane)
		ok
		@aTimeLines[_nIndex_].AddPoint(pcLabel, pDateTime)

		def AddPointToLaneQ(pcLane, pcLabel, pDateTime)
			This.AddPointToLane(pcLane, pcLabel, pDateTime)
			return This

		def AddMomentToLane(pcLane, pcLabel, pDateTime)
			This.AddPointToLane(pcLane, pcLabel, pDateTime)

	def AddPointsToLane(pcLane, paPoints)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddPoints(paPoints)

	def AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddSpan(pcLabel, pStart, pEnd)

		def AddSpanToLaneQ(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
			return This

		def AddPeriodToLane(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)

	def AddSpansToLane(pcLane, paSpans)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddSpans(paSpans)

	// Blocking in Lanes

	def AddBlockedSpanToLane(pcLane, pcLabel, pStart, pEnd)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddBlockedSpan(pcLabel, pStart, pEnd)

	def AddBlockedPointToLane(pcLane, pDateTime)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.AddBlockedPoint(pDateTime)

	def BlockSpanInLane(pcLane, pcLabel)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.BlockSpan(pcLabel)

	def BlockPointInLane(pcLane, pcLabel)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.BlockPoint(pcLabel)

	def IsBlockedInLane(pcLane, p)
		_oLaneTL_ = This.Lane(pcLane)
		return _oLaneTL_.IsBlocked(p)

	// Querying Across Lanes

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

	def HasOverlapsInLane(pcLane)
		_oLaneTL_ = This.Lane(pcLane)
		return _oLaneTL_.HasOverlaps()

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

	def UncoveredPeriodsPerLane()
		_aResult_ = []
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			_aUncovered_ = @aTimeLines[i].UncoveredPeriods()
			_aResult_ + [ :Lane = @aLanes[i], :Uncovered = _aUncovered_ ]
		next
		return _aResult_

	// Visualization (Multi-Lane)

	def Show()
		This._buildVizCanvas()
		return This._vizCanvasToString()

	def ShowShort()
		This._buildVizCanvas(:Short)
		return This._vizCanvasToString()

	def ShowXT(paOptions)
		// paOptions could include :TableType = :Statistical or :Descriptive
		This._buildVizCanvas(:Extended, paOptions)
		return This._vizCanvasToString() + nl + This._buildTable(paOptions)

	def ShowUncovered()
		This._buildVizCanvas(:Uncovered)
		return This._vizCanvasToString()

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
	def RemovePointFromLane(pcLane, pcLabelOrDateTime)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.RemovePoint(pcLabelOrDateTime)

	def RenameLabelInLane(pcLane, pcLabel, pcNewLabel)
		_oLaneTL_ = This.Lane(pcLane)
		_oLaneTL_.RenameLabel(pcLabel, pcNewLabel)

	// Add more as needed, following the pattern

	// ToTimeLine(pcMergeStrategy)
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

	def Clear()
		_nLen_ = len(@aTimeLines)
		for i = 1 to _nLen_
			@aTimeLines[i].Clear()
		next

	def Copy()
		return new stzTimeLines(This.Content())  // Assuming Content() returns init-compatible hash
