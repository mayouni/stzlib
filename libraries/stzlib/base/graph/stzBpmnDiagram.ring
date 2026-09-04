#=============================================================#
#  stzBpmnDiagram - THE BPMN LAYOUT LAW, AND THE DIGEST TWO    #
#                   IMPLEMENTATIONS ARE HELD TO                #
#=============================================================#
#
# WHAT THIS IS
#
# THIS CLASS NO LONGER DRAWS, and what is left is the more valuable half.
#
# It was the first renderer in Softanza to produce a picture without the
# graphviz executable: it laid a process out itself AND wrote the SVG. The
# writer went on 2026-09-04, 276 lines of it, because the shared renderer
# now does that job under the visual contract and carries the consumer
# contract too -- an id and a set of classes per element, which is the one
# thing that used to keep this file alive.
#
# What remains is the LAW: L3 to L10 assigning a column, a row and an arrow
# class, and LayoutDigest() emitting the conformance record that this
# library and the second implementation in ringflex are both held to.
# Section 77 of the graphics guard compares the shared renderer against
# that digest, cell by cell, over five process shapes -- so this file is
# now the ORACLE rather than a rival, and deleting it outright would have
# deleted the only thing that can say whether a BPMN picture is lawful.
#
# ONE THING TO KNOW BEFORE FEEDING IT. It reads Steps(), and stzWorkflow
# carries TWO collections -- @aSteps for the process vocabulary and
# @aStates for the state-machine one. A workflow built with AddStateXTT
# leaves Steps() empty, EntryStep() answers "", and the digest comes back
# with a header and no records. That is not a failure; it is the wrong
# vocabulary, and it is why this class appeared to have no callers.
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

	@aEndings = []      # [ name, kind(:terminal|:suspension), outcome ]
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
		$n = nA
		if nB < $n  $n = nB ok
		for i = 1 to $n
			kA = ascii(pcA[i])
			kB = ascii(pcB[i])
			if kA > kB  return TRUE ok
			if kA < kB  return FALSE ok
		next
		return nA > nB

