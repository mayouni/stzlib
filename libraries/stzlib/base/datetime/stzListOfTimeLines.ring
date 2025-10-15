
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
				@aLanes = p[:Lanes]
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

			if HasKey(p, :end)
				@cGlobalEnd = This._normalizeDateTime(p[:End])

			but HasKey(p, :to)
				@cGlobalEnd = This._normalizeDateTime(p[:to])

			else
				StzRaise("Missing required param! :End must be provided.")
			ok
		else
			StzRaise("Incorrect init params! Provide a hashlist with :Lanes, :Start, and :End.")
		ok

		// Initialize each lane as a stzTimeLine with global bounds
		nLen = len(@aLanes)
? @@([ @cGlobalStart, @cGlobalEnd ])
		for i = 1 to nLen
			oLaneTL = new stzTimeLine(@cGlobalStart, @cGlobalEnd)
			@aTimeLines + oLaneTL
		next

	def Content()
		aResult = [
			:Start = @cGlobalStart,
			:End = @cGlobalEnd,
			:Lanes = @aLanes,
			:TimeLines = []
		]

		nLen = len(@aTimeLines)
		for i = 1 to nLen
			aResult[:TimeLines] + [
				:Lane = @aLanes[i],
				:Content = @aTimeLines[i].Content()
			]
		next

		return aResult

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
		nLen = len(@aTimeLines)
		for i = 1 to nLen
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
		nIndex = ring_find(@aLanes, upper(pcLane))
		if nIndex > 0
			return @aTimeLines[nIndex]
		else
			StzRaise("No lane found with name: " + pcLane)
		ok

		def LaneQ(pcLane)
			return This.Lane(pcLane)  // Already a stzTimeLine object

	def HasLane(pcLane)
		return ring_find(@aLanes, upper(pcLane)) > 0

	def AddLane(pcLane)
		if This.HasLane(pcLane)
			StzRaise("Lane already exists: " + pcLane)
		ok
		@aLanes + upper(pcLane)
		oNewTL = new stzTimeLine(@cGlobalStart, @cGlobalEnd)
		@aTimeLines + oNewTL

		def AddLaneQ(pcLane)
			This.AddLane(pcLane)
			return This

	def RemoveLane(pcLane)
		nIndex = ring_find(@aLanes, upper(pcLane))
		if nIndex > 0
			del(@aLanes, nIndex)
			del(@aTimeLines, nIndex)
		ok

		def RemoveLaneQ(pcLane)
			This.RemoveLane(pcLane)
			return This

	// Adding to Specific Lanes (Delegates to stzTimeLine methods)

	def AddPointToLane(pcLane, pcLabel, pDateTime)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.AddPoint(pcLabel, pDateTime)

		def AddPointToLaneQ(pcLane, pcLabel, pDateTime)
			This.AddPointToLane(pcLane, pcLabel, pDateTime)
			return This

		def AddMomentToLane(pcLane, pcLabel, pDateTime)
			This.AddPointToLane(pcLane, pcLabel, pDateTime)

	def AddPointsToLane(pcLane, paPoints)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.AddPoints(paPoints)

	def AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.AddSpan(pcLabel, pStart, pEnd)

		def AddSpanToLaneQ(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)
			return This

		def AddPeriodToLane(pcLane, pcLabel, pStart, pEnd)
			This.AddSpanToLane(pcLane, pcLabel, pStart, pEnd)

	def AddSpansToLane(pcLane, paSpans)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.AddSpans(paSpans)

	// Blocking in Lanes

	def AddBlockedSpanToLane(pcLane, pcLabel, pStart, pEnd)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.AddBlockedSpan(pcLabel, pStart, pEnd)

	def AddBlockedPointToLane(pcLane, pDateTime)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.AddBlockedPoint(pDateTime)

	def BlockSpanInLane(pcLane, pcLabel)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.BlockSpan(pcLabel)

	def BlockPointInLane(pcLane, pcLabel)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.BlockPoint(pcLabel)

	def IsBlockedInLane(pcLane, p)
		oLaneTL = This.Lane(pcLane)
		return oLaneTL.IsBlocked(p)

	// Querying Across Lanes

	def WhatsAt(pDateTime)
		cDateTime = This._normalizeDateTime(pDateTime)
		aResult = []

		nLen = len(@aTimeLines)
		for i = 1 to nLen
			aLaneEvents = @aTimeLines[i].WhatsAt(cDateTime)
			if len(aLaneEvents) > 0
				aResult + [ :Lane = @aLanes[i], :Events = aLaneEvents ]
			ok
		next

		return aResult

	def HasOverlapsInLane(pcLane)
		oLaneTL = This.Lane(pcLane)
		return oLaneTL.HasOverlaps()

	def CrossLaneOverlaps()
		// Detect overlaps between events in different lanes at the same time
		aResult = []
		nLen = len(@aTimeLines)

		for i = 1 to nLen - 1
			aSpansI = @aTimeLines[i].Spans()
			for j = i + 1 to nLen
				aSpansJ = @aTimeLines[j].Spans()
				// Check for overlapping spans between lane i and j
				for s1 in aSpansI
					oStart1 = new stzDateTime(s1[2])
					oEnd1 = new stzDateTime(s1[3])
					for s2 in aSpansJ
						oStart2 = new stzDateTime(s2[2])
						oEnd2 = new stzDateTime(s2[3])
						if oStart1 < oEnd2 and oStart2 < oEnd1
							nOverlapDur = min([oEnd1.Seconds(), oEnd2.Seconds()]) - max([oStart1.Seconds(), oStart2.Seconds()])
							aResult + [ [@aLanes[i], @aLanes[j]], s1[1], s2[1], nOverlapDur ]
						ok
					next
				next
			next
		next

		return aResult

	def UncoveredPeriodsPerLane()
		aResult = []
		nLen = len(@aTimeLines)
		for i = 1 to nLen
			aUncovered = @aTimeLines[i].UncoveredPeriods()
			aResult + [ :Lane = @aLanes[i], :Uncovered = aUncovered ]
		next
		return aResult

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
		@cHighlight = upper(pcLabel)
		return This.Show()

		def VizFindQ(pcLabel)
			This.VizFind(pcLabel)
			return This

	def _buildVizCanvas(pcMode, paOptions)
		// Clear canvas
		@acVizCanvas = []

		// Calculate global layout
		oGlobalLayout = This._calculateGlobalLayout()

		// For each lane, build its timepoints and draw
		nLenLanes = len(@aLanes)
		nCurrentRow = 1  // Start row for first lane

		for i = 1 to nLenLanes
			// Add lane label on the left
			This._addLaneLabelToCanvas(nCurrentRow, @aLanes[i])

			// Get lane's timepoints
			aTimepoints = @aTimeLines[i]._buildSortedTimepoints()

			// Draw axis for this lane
			This._drawAxisForLane(nCurrentRow + @nVizLaneHeight / 2, oGlobalLayout)  // Middle of lane height

			// Draw points, spans, etc., offset to lane's section
			This._drawForLane(i, nCurrentRow, aTimepoints, pcMode)

			nCurrentRow += @nVizLaneHeight + 1  // +1 for separator
		next

	def _addLaneLabelToCanvas(nRow, pcLane)
		// Pad label to @nLabelWidth and add to canvas rows
		cPaddedLabel = pcLane + Q(" " * (@nLabelWidth - len(pcLane)))
		// Assume canvas rows are built vertically; integrate into @acVizCanvas

	def _calculateGlobalLayout()
		// Similar to stzTimeLine's _calculateRequiredVizHeight but global
		nMaxHeight = 0
		nLen = len(@aTimeLines)
		for i = 1 to nLen
			nLaneHeight = @aTimeLines[i]._calculateRequiredVizHeight()
			if nLaneHeight > nMaxHeight
				nMaxHeight = nLaneHeight
			ok
		next
		@nVizLaneHeight = nMaxHeight

		return [ :width = @nVizWidth, :lane_height = @nVizLaneHeight ]

	def _drawAxisForLane(nRow, oLayout)
		// Adapted from stzTimeLine's _drawAxis, but at specific row

	def _drawForLane(nLaneIndex, nStartRow, aTimepoints, pcMode)
		oLaneTL = @aTimeLines[nLaneIndex]
		oLayout = [ :axis_row = nStartRow + 2 ]  // Example offset

		// Delegate drawing to adapted stzTimeLine methods, but offset rows
		oLaneTL._drawSpans(oLayout, aTimepoints)
		oLaneTL._drawPoints(oLayout, aTimepoints)
		if pcMode = :Uncovered
			aUncovered = oLaneTL.UncoveredPeriods()
			oLaneTL._drawUncoveredRegions(oLayout, aUncovered)
		ok
		// etc. for blocks, highlights

	def _vizCanvasToString()
		// Similar to stzTimeLine's _vizCanvasToString

	def _buildTable(paOptions)
		// Aggregate stats across lanes, similar to _buildStatisticalTable
		// E.g., Total Points Per Lane, Cross-Lane Overlaps, etc.

	// Normalization (Delegated from stzTimeLine)

	def _normalizeDateTime(pDateTime)
		// Copy from stzTimeLine's _normalizeDateTime

		def _isDateOnly(cDateTime)
			// Copy from stzTimeLine

		def _isTimeOnly(cDateTime)
			// Copy from stzTimeLine

	// Other Delegated Methods (with lane param)

	// For example:
	def RemovePointFromLane(pcLane, pcLabelOrDateTime)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.RemovePoint(pcLabelOrDateTime)

	def RenameLabelInLane(pcLane, pcLabel, pcNewLabel)
		oLaneTL = This.Lane(pcLane)
		oLaneTL.RenameLabel(pcLabel, pcNewLabel)

	// Add more as needed, following the pattern

	// ToTimeLine(pcMergeStrategy)
	def ToTimeLine(pcStrategy)
		if pcStrategy = ""
			pcStrategy = :MergeAll
		ok

		// Merge all lanes into a single stzTimeLine
		// Strategy: :MergeAll (combine points/spans with lane prefixes), :SelectLane = "Name", etc.
		oMerged = new stzTimeLine(@cGlobalStart, @cGlobalEnd)
		nLen = len(@aTimeLines)
		for i = 1 to nLen
			aPoints = @aTimeLines[i].Points()
			for p in aPoints
				oMerged.AddPoint(@aLanes[i] + "-" + p[1], p[2])
			next
			aSpans = @aTimeLines[i].Spans()
			for s in aSpans
				oMerged.AddSpan(@aLanes[i] + "-" + s[1], s[2], s[3])
			next
		next
		return oMerged

	def Clear()
		nLen = len(@aTimeLines)
		for i = 1 to nLen
			@aTimeLines[i].Clear()
		next

	def Copy()
		return new stzTimeLines(This.Content())  // Assuming Content() returns init-compatible hash
