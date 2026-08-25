#=============================================================#
#  stzBpmnDiagram - BPMN drawing for workflows and state       #
#                   machines, straight to SVG                  #
#=============================================================#
#
# WHAT THIS IS
#
# The first renderer in Softanza that produces a picture WITHOUT the
# graphviz executable. stzDiagram ships four converters -- stzDiagramToDot,
# ToMermaid, ToJSON, ToStzDiag -- and none of them draws: View() shells out
# to `dot`. This class lays a process out itself and writes the SVG, so a
# workflow can be drawn anywhere Ring runs.
#
# It also closes a gap stzDiagramColor has carried for a while: that file
# defines COLOURS for :Timer, :Compensation, :Gateway, :Subprocess and
# :Error, and stzDiagram's _GetNodeShape has no case for any of them -- all
# five fall through to `box`. The BPMN vocabulary below supplies the shapes
# those colours were waiting for.
#
# WHY A PURPOSE-BUILT LAYOUT
#
# A general graph layouter treats every edge as an equal vote on placement,
# because for an arbitrary digraph every edge IS an equal vote. A business
# process is not arbitrary: it has a path it takes when things go as
# intended and paths it takes when they do not, and the first must read as
# one straight line while the others hang off it. Given that one distinction
# -- which stzWorkflow now declares, see SetExceptionEvents() -- the layout
# is simple and the drawing is calm.
#
# THE LAW
#
# This class implements a written, versioned specification:
#
#     D:\GitHub\ringflex\docs\bpmn-layout-law.md   (version 1.0.0)
#
# It is one of two conforming implementations; the other is RingFlex's
# src/bpmn.ring, which draws .wflow files with no stzlib present. Neither is
# the reference -- the document is. LayoutDigest() below emits the law's
# section 8 digest, and the two implementations are held to producing the
# same digest for the same process. That is the same shape ZQL uses for its
# three runtimes: one spec, several implementations, shared fixtures.
#
# USAGE
#
#     oWf = new stzWorkflow("order")
#     oWf.SetExceptionEvents(["timeout", "reject"])
#     oWf.AddStep_("receive")  oWf.AddStep_("check")  ...
#     oWf.ConnectSteps("receive", "check")
#
#     oB = new stzBpmnDiagram(oWf)
#     oB.SetTheme(:neutral)                  # :neutral | :access | :print
#     oB.MarkEnding("done", :terminal, :success)
#     oB.MarkVerdict("check", :danger, "deadlock: nothing leaves this step")
#     oB.WriteSvg("order.svg")
#     ? oB.LayoutDigest()                    # conformance
#
#=============================================================#

func StzBpmnDiagramQ(poWorkflow)
	return new stzBpmnDiagram(poWorkflow)

class stzBpmnDiagram from stzObject

	@oWf = NULL

	@cTheme   = "neutral"
	@aEndings = []      # [ name, kind(:terminal|:suspension), outcome ]
	@aVerdicts = []     # [ nodeName, severity(:danger|:warning), message ]
	@aResumes = []      # [ endingName, targetStep ]

	# the placed model (law sections 3-5)
	@aCol = []  @aRow = []
	@aPlaced = []       # [ name, kind, col, row ]
	@aStubs  = []       # [ id, name, kind, outcome, col, row ]
	@aArrows = []       # [ from, label, toId, exceptional, class ]

	@nMaxCol = 1  @nMaxRow = 0  @nRet = 0
	@bLaidOut = FALSE
	@aArrCount = []     # arrivals counted per ending, for L8's suffixing

	def init(poWorkflow)
		@oWf = poWorkflow

	#-----------------#
	#  DECLARATIONS   #
	#-----------------#

	def SetTheme(pcTheme)
		@cTheme = StzLower("" + pcTheme)

		def SetThemeQ(pcTheme)
			This.SetTheme(pcTheme)
			return This

	# A step that is really an ENDING -- where work stops. stzWorkflow has no
	# terminal concept, so the caller names them.
	def MarkEnding(pcName, pcKind, pcOutcome)
		@aEndings + [pcName, StzLower("" + pcKind), StzLower("" + pcOutcome)]
		@bLaidOut = FALSE

		def MarkEndingQ(pcName, pcKind, pcOutcome)
			This.MarkEnding(pcName, pcKind, pcOutcome)
			return This

	# A suspension that re-enters the process at a step (law L10)
	def MarkResume(pcEnding, pcTargetStep)
		@aResumes + [pcEnding, pcTargetStep]
		@bLaidOut = FALSE

	# An analyzer finding, drawn on the node it names (law L17)
	def MarkVerdict(pcNode, pcSeverity, pcMessage)
		@aVerdicts + [pcNode, StzLower("" + pcSeverity), pcMessage]

		def MarkVerdictQ(pcNode, pcSeverity, pcMessage)
			This.MarkVerdict(pcNode, pcSeverity, pcMessage)
			return This

	#-----------------#
	#  THE LAYOUT     #
	#-----------------#

	def Layout()
		if @bLaidOut  return ok

		@aCol = []  @aRow = []
		@aPlaced = []  @aStubs = []  @aArrows = []
		aOcc = []

		cEntry = This.EntryStep()
		if cEntry = ""
			@bLaidOut = TRUE
			return
		ok

		# --- L3: the happy path --------------------------------------
		aHappy = [cEntry]
		cCur = cEntry
		_nGuard_ = 0
		while _nGuard_ < 500
			_nGuard_++
			if This.IsEnding(cCur)  exit ok
			cNext = ""
			aOut = This.ArrowsFrom(cCur)
			for j = 1 to len(aOut)
				if NOT aOut[j][3]
					cNext = aOut[j][2]
					exit
				ok
			next
			if cNext = ""  exit ok
			if StzFindFirst(cNext, aHappy) > 0  exit ok
			aHappy + cNext
			cCur = cNext
		end

		# --- L4: the spine takes row 0 and strictly rising columns ----
		_nHc_ = 0
		for i = 1 to len(aHappy)
			if NOT This.IsEnding(aHappy[i])
				_nHc_++
				This._SetKV(:col, aHappy[i], _nHc_)
				This._SetKV(:row, aHappy[i], 0)
				aOcc + ("" + _nHc_ + ":0")
			ok
		next

		# --- L5: everything else ranks off the spine ------------------
		aQueue = [cEntry]
		_n_ = 1
		while _n_ <= len(aQueue)
			cFrom = aQueue[_n_]
			_n_++
			aOut = This.ArrowsFrom(cFrom)
			for j = 1 to len(aOut)
				cTo = aOut[j][2]
				if This.IsEnding(cTo)  loop ok
				if aOut[j][3]          loop ok
				if This._GetKV(:col, cTo) < 0
					This._SetKV(:col, cTo, This._GetKV(:col, cFrom) + 1)
					aQueue + cTo
				ok
			next
		end
		# reachable only through an exception: iterate to a fixed point
		_nG2_ = 0
		while _nG2_ < 30
			_nG2_++
			_bMoved_ = FALSE
			aSteps = @oWf.Steps()
			for i = 1 to len(aSteps)
				cN = aSteps[i][:id]
				if This.IsEnding(cN)  loop ok
				if This._GetKV(:col, cN) >= 0  loop ok
				for k = 1 to len(aSteps)
					cS = aSteps[k][:id]
					if This._GetKV(:col, cS) < 0  loop ok
					aOut = This.ArrowsFrom(cS)
					for j = 1 to len(aOut)
						if aOut[j][2] = cN
							This._SetKV(:col, cN, This._GetKV(:col, cS) + 1)
							_bMoved_ = TRUE
							exit
						ok
					next
					if This._GetKV(:col, cN) >= 0  exit ok
				next
			next
			if NOT _bMoved_  exit ok
		end

		# --- L6: first free row below ---------------------------------
		aSteps = @oWf.Steps()
		for i = 1 to len(aSteps)
			cN = aSteps[i][:id]
			if This.IsEnding(cN)  loop ok
			if This._GetKV(:row, cN) >= 0  loop ok
			nC = This._GetKV(:col, cN)
			if nC < 0
				nC = 1
				This._SetKV(:col, cN, 1)
			ok
			nR = 1
			while StzFindFirst("" + nC + ":" + nR, aOcc) > 0
				nR++
			end
			This._SetKV(:row, cN, nR)
			aOcc + ("" + nC + ":" + nR)
		next

		for i = 1 to len(aSteps)
			cN = aSteps[i][:id]
			if This.IsEnding(cN)  loop ok
			@aPlaced + [cN, This.KindOf(cN), This._GetKV(:col, cN), This._GetKV(:row, cN)]
		next

		# --- L7/L8: endings, one marker per arrival -------------------
		aArr = []
		for i = 1 to len(aSteps)
			cFrom = aSteps[i][:id]
			if This.IsEnding(cFrom)  loop ok
			aOut = This.ArrowsFrom(cFrom)
			for j = 1 to len(aOut)
				cLbl = aOut[j][1]
				cTo  = aOut[j][2]
				bExc = aOut[j][3]

				if NOT This.IsEnding(cTo)
					nDc = This._GetKV(:col, cTo) - This._GetKV(:col, cFrom)
					cCls = "fwd"
					if nDc = 0  cCls = "lat" ok
					if nDc < 0  cCls = "ret" ok
					@aArrows + [cFrom, cLbl, cTo, bExc, cCls]
					loop
				ok

				nA = This._GetKV(:arr, cTo)
				if nA < 0  nA = 0 ok
				nA++
				This._SetKV(:arr, cTo, nA)
				cSid = This.EndingId(cTo, nA)
				nC = This._GetKV(:col, cFrom) + 1
				nR = This._GetKV(:row, cFrom)
				if bExc  nR++ ok
				while StzFindFirst("" + nC + ":" + nR, aOcc) > 0
					nR++
				end
				aOcc + ("" + nC + ":" + nR)
				@aStubs + [cSid, cTo, This.EndingKind(cTo), This.EndingOutcome(cTo), nC, nR]
				@aArrows + [cFrom, cLbl, cSid, bExc, "fwd"]
			next
		next

		# --- L10: a suspension resumes --------------------------------
		for i = 1 to len(@aResumes)
			if This._GetKV(:arr, @aResumes[i][1]) > 0
				@aArrows + [This.EndingId(@aResumes[i][1], 1), "resumes", @aResumes[i][2], TRUE, "ret"]
			ok
		next

		# --- L9: an ending nothing arrives at is still drawn -----------
		for i = 1 to len(@aEndings)
			if This._GetKV(:arr, @aEndings[i][1]) < 0
				@aStubs + [This.EndingId(@aEndings[i][1], 1), @aEndings[i][1],
				           @aEndings[i][2], @aEndings[i][3], 1, 1]
			ok
		next

		This._ComputeExtents()
		@bLaidOut = TRUE

	def _ComputeExtents()
		@nMaxCol = 1  @nMaxRow = 0  @nRet = 0
		for i = 1 to len(@aPlaced)
			if @aPlaced[i][3] > @nMaxCol  @nMaxCol = @aPlaced[i][3] ok
			if @aPlaced[i][4] > @nMaxRow  @nMaxRow = @aPlaced[i][4] ok
		next
		for i = 1 to len(@aStubs)
			if @aStubs[i][5] > @nMaxCol  @nMaxCol = @aStubs[i][5] ok
			if @aStubs[i][6] > @nMaxRow  @nMaxRow = @aStubs[i][6] ok
		next
		for i = 1 to len(@aArrows)
			if @aArrows[i][5] = "ret"  @nRet++ ok
		next

	#-----------------#
	#  MODEL ACCESS   #
	#-----------------#
	# Projects stzWorkflow onto the law's section 1 model.

	def EntryStep()
		aSteps = @oWf.Steps()
		if len(aSteps) = 0  return "" ok
		# a step nothing points at, else the first declared
		for i = 1 to len(aSteps)
			if len(@oWf.Incoming(aSteps[i][:id])) = 0
				return aSteps[i][:id]
			ok
		next
		return aSteps[1][:id]

	# [ label, to, exceptional ] for each arrow out of a step
	def ArrowsFrom(pcStep)
		aOut = []
		aT = @oWf.Transitions()
		if len(aT) > 0
			for i = 1 to len(aT)
				if aT[i][:from] = pcStep
					aOut + [aT[i][:event], aT[i][:to], aT[i][:exceptional]]
				ok
			next
			return aOut
		ok
		# a sequential workflow has edges but no transitions: every edge is
		# intended, and the edge label is the arrow's label
		aE = @oWf.Edges()
		for i = 1 to len(aE)
			if aE[i][:from] = pcStep
				cL = ""
				if HasKey(aE[i], :label)  cL = aE[i][:label] ok
				aOut + [cL, aE[i][:to], FALSE]
			ok
		next
		return aOut

	def IsEnding(pcName)
		for i = 1 to len(@aEndings)
			if @aEndings[i][1] = pcName  return TRUE ok
		next
		return FALSE

	def EndingKind(pcName)
		for i = 1 to len(@aEndings)
			if @aEndings[i][1] = pcName  return @aEndings[i][2] ok
		next
		return "terminal"

	def EndingOutcome(pcName)
		for i = 1 to len(@aEndings)
			if @aEndings[i][1] = pcName  return @aEndings[i][3] ok
		next
		return ""

	def EndingId(pcName, n)
		cBase = "terminal_" + pcName
		if This.EndingKind(pcName) = "suspension"
			cBase = "suspended_" + pcName
		ok
		if n > 1  cBase += "__" + n ok
		return cBase

	# stzWorkflow's node `type` property -> the law's NodeKind
	def KindOf(pcStep)
		cT = StzLower("" + @oWf.NodeProperty(pcStep, "type"))
		switch cT
		on "decision"    return "gateway"
		on "gateway"     return "gateway"
		on "timer"       return "timer-wait"
		on "event"       return "event-wait"
		on "compensation" return "compensate"
		on "human"       return "human"
		on "usertask"    return "human"
		off
		if @oWf.NodeProperty(pcStep, "assignedTo") != ""
			return "human"
		ok
		return "invoke"

	def VerdictFor(pcNode)
		for i = 1 to len(@aVerdicts)
			if @aVerdicts[i][1] = pcNode  return @aVerdicts[i] ok
		next
		return []

	#-----------------#
	#  CONFORMANCE    #
	#-----------------#
	# The layout digest of the law, section 8. Two implementations conform
	# when they emit the same digest for the same process.

	def LayoutDigest()
		This.Layout()
		_dg_ = "LAWVER 1.0.0" + nl
		_dg_ += "E " + This.EntryStep() + nl

		aN = []
		for i = 1 to len(@aPlaced)
			p = @aPlaced[i]
			aN + ("N " + p[1] + " " + p[2] + " " + p[3] + " " + p[4])
		next
		aN = This._Sorted(aN)
		for i = 1 to len(aN)  _dg_ += aN[i] + nl next

		aX = []
		for i = 1 to len(@aStubs)
			s = @aStubs[i]
			cK = "terminal"
			if s[3] = "suspension"  cK = "suspension" ok
			aX + ("X " + s[1] + " " + s[2] + " " + cK + " " + s[5] + " " + s[6])
		next
		aX = This._Sorted(aX)
		for i = 1 to len(aX)  _dg_ += aX[i] + nl next

		aA = []
		for i = 1 to len(@aArrows)
			e = @aArrows[i]
			cK = "spine"
			if e[4]  cK = "exception" ok
			aA + ("A " + e[1] + " " + e[2] + " " + e[3] + " " + cK + " " + e[5])
		next
		aA = This._Sorted(aA)
		for i = 1 to len(aA)  _dg_ += aA[i] + nl next

		return _dg_

	#-----------------#
	#  SVG            #
	#-----------------#

	def Svg()
		This.Layout()
		aT = This.Palette()
		nColW = 220  nRowH = 104  nX0 = 70  nY0 = 96
		nW = nX0 + (@nMaxCol + 1) * nColW + 60
		nH = nY0 + (@nMaxRow + 1) * nRowH + 40 + @nRet * 16 + 30

		_sv_ = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + nW + " " + nH + '"'
		_sv_ += ' id="workflow_' + @oWf.Id() + '" font-family="Arial, Helvetica, sans-serif">' + nl
		_sv_ += '<rect width="' + nW + '" height="' + nH + '" fill="' + aT[:background] + '"/>' + nl
		_sv_ += '<defs>' + nl
		_sv_ += This._Marker("wfArr", aT[:line]) + This._Marker("wfArrMuted", aT[:muted])
		_sv_ += '</defs>' + nl
		_sv_ += '<text x="24" y="34" font-size="15" font-weight="bold" fill="' + aT[:ink] + '">'
		_sv_ += This._Esc(@oWf.Id()) + '</text>' + nl

		# arrows under the nodes
		nRetIdx = 0
		for i = 1 to len(@aArrows)
			if @aArrows[i][5] = "ret"  nRetIdx++ ok
			_sv_ += This._ArrowSvg(@aArrows[i], aT, nColW, nRowH, nX0, nY0, nRetIdx, i)
		next

		# entry event
		nEx = nX0 + 110
		nEy = nY0 + 27
		_sv_ += '<g id="workflow_entry" class="wf-entry">' + nl
		_sv_ += '  <circle cx="' + nEx + '" cy="' + nEy + '" r="15" fill="' + aT[:ink] + '"/>' + nl
		_sv_ += '</g>' + nl

		for i = 1 to len(@aPlaced)
			_sv_ += This._NodeSvg(@aPlaced[i], aT, nColW, nRowH, nX0, nY0)
		next
		for i = 1 to len(@aStubs)
			_sv_ += This._StubSvg(@aStubs[i], aT, nColW, nRowH, nX0, nY0)
		next

		_sv_ += '</svg>' + nl
		return _sv_

	def WriteSvg(pcPath)
		write(pcPath, This.Svg())

		def SaveSvg(pcPath)
			This.WriteSvg(pcPath)

	# The colour law, section 7 of the spec. WHITE by default; the only thing
	# that colours a node is a verdict. `print` carries no colour at all,
	# which is why a verdict is always drawn in three channels.
	def Palette()
		switch @cTheme
		on "access"
			return [ :background = "#FFFEF7", :ink = "#101010", :inkon = "#FFFFFF",
			         :line = "#101010", :muted = "#6B6B6B",
			         :success = "#0B6E1F", :warning = "#7A4E00", :danger = "#A31212" ]
		on "print"
			return [ :background = "#FFFFFF", :ink = "#000000", :inkon = "#000000",
			         :line = "#000000", :muted = "#000000",
			         :success = "#000000", :warning = "#000000", :danger = "#000000" ]
		off
		return [ :background = "#FFFFFF", :ink = "#101010", :inkon = "#FFFFFF",
		         :line = "#303030", :muted = "#8A8A8A",
		         :success = "#1B7F3B", :warning = "#B35C00", :danger = "#C1121F" ]

	#-----------------#
	#  SVG INTERNALS  #
	#-----------------#

	def _Marker(pcId, pcColor)
		_mk_ = '<marker id="' + pcId + '" viewBox="0 0 10 10" refX="9" refY="5"'
		_mk_ += ' markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
		_mk_ += '<path d="M 0 0 L 10 5 L 0 10 z" fill="' + pcColor + '"/></marker>' + nl
		return _mk_

	def _Cx(nCol, nColW, nX0)   return nX0 + nCol * nColW + 110
	def _Cy(nRow, nRowH, nY0)   return nY0 + nRow * nRowH + 27

	def _NodeSvg(aP, aT, nColW, nRowH, nX0, nY0)
		cN = aP[1]  cK = aP[2]
		nCx = This._Cx(aP[3], nColW, nX0)
		nCy = This._Cy(aP[4], nRowH, nY0)

		aV = This.VerdictFor(cN)
		cFill = aT[:background]  cInk = aT[:ink]  cLine = aT[:line]
		nSw = 1  cMark = ""  cCls = "wf-step wf-" + cK
		if len(aV) > 0
			nSw = 3
			cMark = "(!) "
			if aV[2] != "danger"  cMark = "(?) " ok
			if aT[:danger] != aT[:ink]
				cFill = aT[:danger]
				if aV[2] != "danger"  cFill = aT[:warning] ok
				cInk = aT[:inkon]
				cLine = cFill
			ok
			cCls += " wf-verdict wf-" + aV[2]
		ok

		_nd_ = '<g id="step_' + cN + '" class="' + cCls + '">'
		if len(aV) > 0
			_nd_ += '<title>' + This._Esc(aV[3]) + '</title>'
		ok
		_nd_ += nl

		# WHICH GLYPH A KIND TAKES IS THE PROFILE'S ANSWER, not this
		# file's (DN3). The vocabulary was written here, privately, and
		# a second face of BPMN drawing the same process through the
		# shared renderer would have had its own copy -- which is how
		# two faces come to disagree about what a gateway looks like.
		# The profile owns the table; both faces read it.
		#
		# The COLOUR law stays here, and deliberately: L16 and L17 are
		# the domain's own written law -- white by default, colour only
		# from a verdict, and a verdict carried in three channels so it
		# survives a print theme that paints every fill white. The house
		# ramp answers a different question. The profile DECLARES the
		# law (every kind white, no role named); this face implements it.
		if StzLower("" + StzBpmnNotation().GlyphOf(cK)) = "diamond"
			_nd_ += '  <polygon points="' + nCx + ',' + (nCy-30) + ' ' + (nCx+30) + ',' + nCy
			_nd_ += ' ' + nCx + ',' + (nCy+30) + ' ' + (nCx-30) + ',' + nCy + '"'
			_nd_ += ' fill="' + cFill + '" stroke="' + cLine + '" stroke-width="' + nSw + '"/>' + nl
			_nd_ += '  <path d="M ' + (nCx-9) + ' ' + (nCy-9) + ' L ' + (nCx+9) + ' ' + (nCy+9)
			_nd_ += ' M ' + (nCx+9) + ' ' + (nCy-9) + ' L ' + (nCx-9) + ' ' + (nCy+9) + '"'
			_nd_ += ' stroke="' + cInk + '" stroke-width="2" fill="none"/>' + nl
			_nd_ += This._Halo(aT, nCx, nCy - 40, 10, cMark + cN, aT[:ink])
		else
			_nd_ += '  <rect x="' + (nCx-75) + '" y="' + (nCy-27) + '" width="150" height="54" rx="9"'
			_nd_ += ' fill="' + cFill + '" stroke="' + cLine + '" stroke-width="' + nSw + '"/>' + nl
			_nd_ += This._TaskMarker(cK, nCx-68, nCy-21, cInk)
			_nd_ += '  <text x="' + nCx + '" y="' + (nCy+4) + '" font-size="11" text-anchor="middle"'
			_nd_ += ' fill="' + cInk + '">' + This._Esc(cMark + cN) + '</text>' + nl
		ok
		_nd_ += '</g>' + nl
		return _nd_

	def _TaskMarker(pcKind, x, y, cInk)
		cS = ' stroke="' + cInk + '" stroke-width="1.2" fill="none"'
		switch pcKind
		on "human"
			_tm_ = '  <circle cx="' + (x+6) + '" cy="' + (y+4) + '" r="2.6"' + cS + '/>' + nl
			_tm_ += '  <path d="M ' + (x+1) + ' ' + (y+13) + ' C ' + (x+1) + ' ' + (y+8) + ', '
			_tm_ += '' + (x+11) + ' ' + (y+8) + ', ' + (x+11) + ' ' + (y+13) + '"' + cS + '/>' + nl
			return _tm_
		on "invoke"
			_tm_ = '  <circle cx="' + (x+6) + '" cy="' + (y+7) + '" r="3.6"' + cS + '/>' + nl
			_tm_ += '  <path d="M ' + (x+6) + ' ' + (y+1) + ' V ' + (y+3) + ' M ' + x + ' ' + (y+7)
			_tm_ += ' H ' + (x+2) + '"' + cS + '/>' + nl
			return _tm_
		on "event-wait"
			_tm_ = '  <rect x="' + x + '" y="' + (y+2) + '" width="13" height="9" rx="1"' + cS + '/>' + nl
			_tm_ += '  <path d="M ' + x + ' ' + (y+3) + ' L ' + (x+6) + ' ' + (y+8) + ' L '
			_tm_ += '' + (x+13) + ' ' + (y+3) + '"' + cS + '/>' + nl
			return _tm_
		on "timer-wait"
			_tm_ = '  <circle cx="' + (x+6) + '" cy="' + (y+7) + '" r="5.5"' + cS + '/>' + nl
			_tm_ += '  <path d="M ' + (x+6) + ' ' + (y+4) + ' V ' + (y+7) + ' H ' + (x+9) + '"' + cS + '/>' + nl
			return _tm_
		on "compensate"
			_tm_ = '  <path d="M ' + (x+12) + ' ' + (y+2) + ' L ' + (x+7) + ' ' + (y+7) + ' L '
			_tm_ += '' + (x+12) + ' ' + (y+12) + ' z M ' + (x+6) + ' ' + (y+2) + ' L ' + (x+1) + ' '
			_tm_ += '' + (y+7) + ' L ' + (x+6) + ' ' + (y+12) + ' z"' + cS + '/>' + nl
			return _tm_
		off
		return ""

	def _StubSvg(aS, aT, nColW, nRowH, nX0, nY0)
		nCx = This._Cx(aS[5], nColW, nX0) - 55
		nCy = This._Cy(aS[6], nRowH, nY0)
		cRing = aT[:line]  nSw = 3  cDash = ""
		cCls = "wf-terminal wf-target-" + aS[2]
		if aS[3] = "suspension"
			nSw = 1.5
			cDash = ' stroke-dasharray="4,3"'
			cCls = "wf-suspended wf-target-" + aS[2]
		but aS[4] = "success"
			cRing = aT[:success]
		ok

		_st_ = '<g id="' + aS[1] + '" class="' + cCls + '">' + nl
		_st_ += '  <circle cx="' + nCx + '" cy="' + nCy + '" r="15" fill="' + aT[:background]
		_st_ += '" stroke="' + cRing + '" stroke-width="' + nSw + '"' + cDash + '/>' + nl
		if aS[3] = "suspension"
			_st_ += '  <circle cx="' + nCx + '" cy="' + nCy + '" r="11" fill="none" stroke="'
			_st_ += cRing + '" stroke-width="1"' + cDash + '/>' + nl
		ok
		_st_ += This._Halo(aT, nCx, nCy + 28, 10, aS[2], aT[:ink])
		_st_ += '</g>' + nl
		return _st_

	def _ArrowSvg(aA, aT, nColW, nRowH, nX0, nY0, nRetIdx, nJog)
		aF = This._GeomOf(aA[1], nColW, nRowH, nX0, nY0)
		aTo = This._GeomOf(aA[3], nColW, nRowH, nX0, nY0)
		if len(aF) = 0 or len(aTo) = 0  return "" ok

		cColor = aT[:line]  cMk = "wfArr"  cDash = ""  nSw = "1.5"
		cCls = "wf-transition wf-spine"
		if aA[4]
			cColor = aT[:muted]  cMk = "wfArrMuted"
			cDash = ' stroke-dasharray="5,4"'  nSw = "1.2"
			cCls = "wf-transition wf-exception"
		ok

		cPath = ""  nLx = 0  nLy = 0
		if aA[5] = "ret"
			nCh = nY0 + (@nMaxRow + 1) * nRowH + 10 + nRetIdx * 16
			cPath = "M " + aF[1] + " " + aF[4] + " V " + nCh + " H " + aTo[1] + " V " + (aTo[4] + 4)
			nLx = (aF[1] + aTo[1]) / 2
			nLy = nCh - 5
		but aA[5] = "lat"
			if aF[6] < aTo[6]
				cPath = "M " + aF[1] + " " + aF[4] + " V " + (aTo[3] - 4)
				nLy = (aF[4] + aTo[3]) / 2
			else
				cPath = "M " + aF[1] + " " + aF[3] + " V " + (aTo[4] + 4)
				nLy = (aF[3] + aTo[4]) / 2
			ok
			nLx = aF[1] + 6
		else
			if aF[5] = aTo[5]
				cPath = "M " + aF[2] + " " + aF[5] + " H " + (aTo[7] - 4)
				nLx = (aF[2] + aTo[7]) / 2
				nLy = aF[5] - 7
			else
				xm = aTo[7] - 18 - (nJog % 4) * 7
				cPath = "M " + aF[2] + " " + aF[5] + " H " + xm + " V " + aTo[5]
				cPath += " H " + (aTo[7] - 4)
				nLx = xm + 8
				nLy = (aF[5] + aTo[5]) / 2
			ok
		ok

		_ar_ = '<g id="transition_' + aA[1] + "__" + aA[2] + "__" + aA[3] + '" class="' + cCls + '">' + nl
		_ar_ += '  <path d="' + cPath + '" fill="none" stroke="' + cColor + '" stroke-width="' + nSw + '"'
		_ar_ += cDash + ' marker-end="url(#' + cMk + ')"/>' + nl
		if aA[2] != ""
			cLi = aT[:ink]
			if aA[4]  cLi = aT[:muted] ok
			_ar_ += This._Halo(aT, nLx, nLy, 9, aA[2], cLi)
		ok
		_ar_ += '</g>' + nl
		return _ar_

	# [cx, right, top, bottom, cy, row, left]
	def _GeomOf(pcRef, nColW, nRowH, nX0, nY0)
		for i = 1 to len(@aPlaced)
			if @aPlaced[i][1] = pcRef
				nCx = This._Cx(@aPlaced[i][3], nColW, nX0)
				nCy = This._Cy(@aPlaced[i][4], nRowH, nY0)
				if @aPlaced[i][2] = "gateway"
					return [nCx, nCx+30, nCy-30, nCy+30, nCy, @aPlaced[i][4], nCx-30]
				ok
				return [nCx, nCx+75, nCy-27, nCy+27, nCy, @aPlaced[i][4], nCx-75]
			ok
		next
		for i = 1 to len(@aStubs)
			if @aStubs[i][1] = pcRef
				nCx = This._Cx(@aStubs[i][5], nColW, nX0) - 55
				nCy = This._Cy(@aStubs[i][6], nRowH, nY0)
				return [nCx, nCx+15, nCy-15, nCy+15, nCy, @aStubs[i][6], nCx-15]
			ok
		next
		return []

	def _Halo(aT, x, y, nSize, cText, cInk)
		_ha_ = '  <text x="' + x + '" y="' + y + '" font-size="' + nSize + '" text-anchor="middle"'
		_ha_ += ' fill="' + cInk + '" stroke="' + aT[:background] + '" stroke-width="3"'
		_ha_ += ' paint-order="stroke">' + This._Esc(cText) + '</text>' + nl
		return _ha_

	#-----------------#
	#  SMALL HELPERS  #
	#-----------------#

	def _GetKV(pcBag, pcKey)
		aB = @aCol
		if pcBag = :row  aB = @aRow ok
		if pcBag = :arr  aB = @aArrCount ok
		for i = 1 to len(aB)
			if aB[i][1] = pcKey  return aB[i][2] ok
		next
		return -1

	def _SetKV(pcBag, pcKey, nVal)
		if pcBag = :col
			for i = 1 to len(@aCol)
				if @aCol[i][1] = pcKey  @aCol[i][2] = nVal  return ok
			next
			@aCol + [pcKey, nVal]
		but pcBag = :row
			for i = 1 to len(@aRow)
				if @aRow[i][1] = pcKey  @aRow[i][2] = nVal  return ok
			next
			@aRow + [pcKey, nVal]
		but pcBag = :arr
			for i = 1 to len(@aArrCount)
				if @aArrCount[i][1] = pcKey  @aArrCount[i][2] = nVal  return ok
			next
			@aArrCount + [pcKey, nVal]
		ok

	# Ring's relational operators raise R41 on strings; ordering must be done
	# on character codes.
	def _Sorted(paL)
		for i = 1 to len(paL) - 1
			for j = 1 to len(paL) - i
				if This._Gt(paL[j], paL[j+1])
					_t_ = paL[j]  paL[j] = paL[j+1]  paL[j+1] = _t_
				ok
			next
		next
		return paL

	def _Gt(pcA, pcB)
		nA = len(pcA)  nB = len(pcB)
		n = nA
		if nB < n  n = nB ok
		for i = 1 to n
			kA = ascii(pcA[i])
			kB = ascii(pcB[i])
			if kA > kB  return TRUE ok
			if kA < kB  return FALSE ok
		next
		return nA > nB

	def _Esc(pcText)
		_es_ = ""
		for i = 1 to len(pcText)
			ch = pcText[i]
			if ch = "&"
				_es_ += "&amp;"
			but ch = "<"
				_es_ += "&lt;"
			but ch = ">"
				_es_ += "&gt;"
			but ch = '"'
				_es_ += "&quot;"
			but ch = char(10) or ch = char(13)
				_es_ += " "
			else
				_es_ += ch
			ok
		next
		return _es_
