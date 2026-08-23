#-------------------------------------------------------------------------#
#  stzNotation -- A DIAGRAM DOMAIN AS A DECLARATION (DN0)                  #
#-------------------------------------------------------------------------#
#
# The DN ruling (SOFTANZA_GRAPH_PLANE_PLAN.md): a domain -- BPMN, state
# machines, org charts, UML, electric -- is a NOTATION PROFILE over the
# one foundation, never a second renderer. stzBpmnDiagram is the negative
# proof: built beside the guarded path, it arrived broken in exactly the
# way duplicated machinery breaks.
#
# A profile declares four things, and every one lands on machinery that
# already exists:
#
#   VOCABULARY   node kinds -> glyphs. Open by default (any kind, the
#                shared type table answers); a domain CLOSES it, and a
#                closed vocabulary makes an unknown kind a finding.
#   RULES        well-formedness, reported in the house rule shape
#                [ :rule, :subject, :where, :severity, :message ] so
#                stzRuleReport gates diagrams like everything else.
#                The editor inherits them free: a link a rule forbids
#                is refused AT THE GESTURE.
#   GRAMMAR      amendments to the visual contract -- a rank direction
#                the domain reads in, a spline discipline. Deltas only;
#                "" means the diagram's own setting stands.
#   GLYPHS       for DN0, a glyph is the geometric shape name the
#                renderer already draws. Ports and compartments join at
#                DN4/DN5, on the pick machinery.
#
# DN0 ships the DEFAULT profile and the seam: the default's answers ARE
# today's behaviour, proven byte-identical on four rendered scenes. A
# profile that changed any pixel of the default picture would mean the
# abstraction is wrong -- that is DN0's kill criterion, and the guard
# holds it as a live assertion, not a memory.
#
# RULES ARE DATA, NOT CODE. A rule row names a PRIMITIVE this file knows
# how to check -- the same shape as the code-rule engine, where the rule
# names the check and the engine owns the checking. DN0 carries the two
# primitives its own guard needs; domains grow the set as they arrive,
# each primitive earning its place with a real domain's real refusal:
#
#   [ :Forbid = :SelfLink,     :Message = "..." ]
#   [ :Forbid = :UnknownKind,  :Message = "..." ]   (implied by closing)
#-------------------------------------------------------------------------#

$aStzNotations = []

# The registry. Asking for a name that is not registered answers the
# DEFAULT profile rather than an error: a diagram always has a notation,
# the way it always has a theme.
func StzNotation(pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	_n_ = len($aStzNotations)
	for _i_ = 1 to _n_
		if $aStzNotations[_i_][1] = _c_  return $aStzNotations[_i_][2]  ok
	next
	if _c_ != "default"  return StzNotation("default")  ok
	_o_ = new stzNotation("default")
	return _o_

func StzRegisterNotation(poNotation)
	if NOT isObject(poNotation)  return FALSE  ok
	_c_ = StzLower("" + poNotation.Name_())
	_n_ = len($aStzNotations)
	for _i_ = 1 to _n_
		if $aStzNotations[_i_][1] = _c_
			$aStzNotations[_i_][2] = poNotation
			return TRUE
		ok
	next
	$aStzNotations + [ _c_, poNotation ]
	return TRUE

func StzNotations()
	_a_ = [ "default" ]
	_n_ = len($aStzNotations)
	for _i_ = 1 to _n_
		if $aStzNotations[_i_][1] != "default"  _a_ + $aStzNotations[_i_][1]  ok
	next
	return _a_

class stzNotation from stzObject

	@cName = "default"
	@aKinds = []          # [ kind, glyph ] rows; authority when closed
	@bClosed = 0          # 0 = open vocabulary: unknown kinds pass through
	@aEdgeKinds = []      # named edge kinds (adornments arrive at DN4)
	@aRules = []          # [ [ cForbid, cMessage ] ] over the primitives
	@aKindRules = []      # [ [ cKind, cForbid, cMessage ] ] -- DN2: rules
	                      # scoped to a KIND (:Inbound into an initial
	                      # state, :Outbound from a final one)
	@cRankDir = ""        # "" = no amendment; the diagram's setting stands
	@cSplines = ""
	@cLayoutMode = ""     # "" = layered; :Ring for a domain with no flow

	def init(pcName)
		@cName = StzLower(ring_trim("" + pcName))

	def Name_()
		return @cName

	#-- VOCABULARY -------------------------------------------------------

	def AddKind(pcKind, pcGlyph)
		_k_ = StzLower(ring_trim("" + pcKind))
		_g_ = StzLower(ring_trim("" + pcGlyph))
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_
				@aKinds[_i_][2] = _g_
				return This
			ok
		next
		@aKinds + [ _k_, _g_ ]
		return This

		def AddKindQ(pcKind, pcGlyph)
			return This.AddKind(pcKind, pcGlyph)

	def Kinds()
		_a_ = []
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_  _a_ + @aKinds[_i_][1]  next
		return _a_

	def Close()
		# a CLOSED vocabulary: a kind this profile did not declare is a
		# finding, not a box. Open is the default because the default
		# profile is the generic diagram, whose whole point is openness.
		@bClosed = 1
		return This

	def IsClosed()
		return @bClosed

	def KnowsKind(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_  return TRUE  ok
		next
		return FALSE

	# The kind's glyph: the geometric shape the renderer draws. The
	# DEFAULT profile answers through the SAME shared table both faces
	# already read (StzNodeShapeForType), so expressing the diagram as a
	# profile moves no pixel -- DN0's whole claim. A declared kind
	# outranks the table; an unknown kind in an OPEN profile falls back
	# to it; in a CLOSED one it answers "", and the renderer's existing
	# fallback (a box) still draws while Check() reports the finding.
	def GlyphOf(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_  return @aKinds[_i_][2]  ok
		next
		if @bClosed  return ""  ok
		return StzNodeShapeForType(_k_)

	#-- RULES ------------------------------------------------------------

	def Forbid(pcWhat, pcMessage)
		@aRules + [ StzLower(ring_trim("" + pcWhat)), "" + pcMessage ]
		return This

		def ForbidQ(pcWhat, pcMessage)
			return This.Forbid(pcWhat, pcMessage)

	def Rules()
		return @aRules

	def _Forbids(pcWhat)
		_w_ = StzLower("" + pcWhat)
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			if @aRules[_i_][1] = _w_  return @aRules[_i_][2]  ok
		next
		return ""

	# A rule a KIND carries -- DN2. :Inbound forbidden for an initial
	# pseudostate means nothing may transition INTO it; :Outbound for a
	# final state means nothing leaves. The kind is the subject because
	# that is how the domain speaks: "a final state has no exits" is a
	# statement about final states, not about any edge.
	def ForbidFor(pcKind, pcWhat, pcMessage)
		@aKindRules + [ StzLower(ring_trim("" + pcKind)),
			StzLower(ring_trim("" + pcWhat)), "" + pcMessage ]
		return This

		def ForbidForQ(pcKind, pcWhat, pcMessage)
			return This.ForbidFor(pcKind, pcWhat, pcMessage)

	def _KindForbids(pcKind, pcWhat)
		_k_ = StzLower("" + pcKind)
		_w_ = StzLower("" + pcWhat)
		_n_ = len(@aKindRules)
		for _i_ = 1 to _n_
			if @aKindRules[_i_][1] = _k_ and @aKindRules[_i_][2] = _w_
				return @aKindRules[_i_][3]
			ok
		next
		return ""

	# The declared kind of a node in this diagram, from the same property
	# the glyph dispatch reads. "" when the node is untyped or absent.
	def _KindOfNode(poDiag, pcId)
		_id_ = StzLower("" + pcId)
		for _nd_ in poDiag.Nodes()
			if StzLower("" + _nd_[:id]) != _id_  loop  ok
			if HasKey(_nd_, "properties") and isList(_nd_["properties"])
				if HasKey(_nd_["properties"], "type")
					return StzLower("" + _nd_["properties"]["type"])
				ok
			ok
			return ""
		next
		return ""

	# May an edge from -> to exist under this profile? Consulted by the
	# editor's Link and Rewire commands, so an illegal link is refused at
	# the gesture -- the domain's rules become the editor's refusals with
	# no editor code knowing any domain.
	#
	# Takes the DIAGRAM because two of the primitives are about the graph
	# the link would join, not about the link alone (DN1, org charts): a
	# second parent is only a second parent given the edges that exist,
	# and a cycle is only a cycle given the paths that do.
	def MayLink(poDiag, pcFrom, pcTo)
		_f_ = StzLower("" + pcFrom)
		_t_ = StzLower("" + pcTo)
		if _f_ = _t_
			if This._Forbids(:SelfLink) != ""  return FALSE  ok
		ok
		if isObject(poDiag)
			# :SecondParent -- the target may hold at most one incoming
			# edge. The TREE grammar's editor face: in an org chart this
			# reads "one supervisor per position".
			if This._Forbids(:SecondParent) != "" and _f_ != _t_
				for _e_ in poDiag.Edges()
					if StzLower("" + _e_[:to]) = _t_  return FALSE  ok
				next
			ok
			# :Cycle -- the link may not close a loop. PathExists answers
			# 1 for from=to, which :SelfLink already owns, so the guard
			# above keeps the two rules from answering for each other.
			if This._Forbids(:Cycle) != "" and _f_ != _t_
				if poDiag.PathExists(pcTo, pcFrom)  return FALSE  ok
			ok
			# kind-scoped: into a kind that admits nothing, out of a
			# kind that releases nothing
			if len(@aKindRules) > 0
				if This._KindForbids(This._KindOfNode(poDiag, pcTo),
					:Inbound) != ""
					return FALSE
				ok
				if This._KindForbids(This._KindOfNode(poDiag, pcFrom),
					:Outbound) != ""
					return FALSE
				ok
			ok
		ok
		return TRUE

	# The model swept against the profile, answered in the house rule
	# shape -- one row per finding, ready for stzRuleReport.Ingest().
	def Check(poDiagram)
		_aOut_ = []
		if NOT isObject(poDiagram)  return _aOut_  ok

		if @bClosed
			for _nd_ in poDiagram.Nodes()
				_k_ = ""
				if HasKey(_nd_, "properties") and isList(_nd_["properties"])
					if HasKey(_nd_["properties"], "type")
						_k_ = StzLower("" + _nd_["properties"]["type"])
					ok
				ok
				if _k_ != "" and NOT This.KnowsKind(_k_)
					_aOut_ + [ :rule = "notation-unknown-kind",
						:subject = "" + _nd_[:id],
						:where = @cName,
						:severity = :warning,
						:message = "'" + _nd_[:id] + "' is a '" + _k_ +
							"', which the " + @cName + " notation does " +
							"not declare. Its kinds: " +
							This._KindsLine() ]
				ok
			next
		ok

		_cSelfMsg_ = This._Forbids(:SelfLink)
		if _cSelfMsg_ != ""
			for _e_ in poDiagram.Edges()
				if StzLower("" + _e_[:from]) = StzLower("" + _e_[:to])
					_aOut_ + [ :rule = "notation-self-link",
						:subject = "" + _e_[:from],
						:where = @cName,
						:severity = :error,
						:message = _cSelfMsg_ ]
				ok
			next
		ok

		# :SecondParent over the MODEL: every node with two or more
		# incoming edges is one finding, named once, however many edges
		# it holds -- the finding is the node's, not each edge's.
		_cPar_ = This._Forbids(:SecondParent)
		if _cPar_ != ""
			_aSeen_ = []
			for _e_ in poDiagram.Edges()
				_t_ = StzLower("" + _e_[:to])
				if _t_ = StzLower("" + _e_[:from])  loop  ok
				_nAt_ = 0
				_n_ = len(_aSeen_)
				for _i_ = 1 to _n_
					if _aSeen_[_i_][1] = _t_  _nAt_ = _i_  exit  ok
				next
				if _nAt_ = 0
					_aSeen_ + [ _t_, 1 ]
				else
					_aSeen_[_nAt_][2]++
					if _aSeen_[_nAt_][2] = 2
						_aOut_ + [ :rule = "notation-second-parent",
							:subject = _t_,
							:where = @cName,
							:severity = :error,
							:message = _cPar_ ]
					ok
				ok
			next
		ok

		# :Cycle over the MODEL: report each edge that closes a loop --
		# the edge whose removal breaks it is the actionable subject.
		_cCyc_ = This._Forbids(:Cycle)
		if _cCyc_ != ""
			for _e_ in poDiagram.Edges()
				_f_ = "" + _e_[:from]
				_t_ = "" + _e_[:to]
				if StzLower(_f_) = StzLower(_t_)  loop  ok
				if poDiagram.PathExists(_t_, _f_)
					_aOut_ + [ :rule = "notation-cycle",
						:subject = _f_ + ">" + _t_,
						:where = @cName,
						:severity = :error,
						:message = _cCyc_ ]
				ok
			next
		ok

		# kind-scoped rules over the MODEL: each offending edge is a
		# finding, because unlike :SecondParent the edge itself is the
		# thing the domain refuses
		if len(@aKindRules) > 0
			for _e_ in poDiagram.Edges()
				_cIn_ = This._KindForbids(
					This._KindOfNode(poDiagram, "" + _e_[:to]), :Inbound)
				if _cIn_ != ""
					_aOut_ + [ :rule = "notation-inbound",
						:subject = "" + _e_[:from] + ">" + _e_[:to],
						:where = @cName,
						:severity = :error,
						:message = _cIn_ ]
				ok
				_cOut_ = This._KindForbids(
					This._KindOfNode(poDiagram, "" + _e_[:from]), :Outbound)
				if _cOut_ != ""
					_aOut_ + [ :rule = "notation-outbound",
						:subject = "" + _e_[:from] + ">" + _e_[:to],
						:where = @cName,
						:severity = :error,
						:message = _cOut_ ]
				ok
			next
		ok
		return _aOut_

	def _KindsLine()
		_c_ = ""
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if _i_ > 1  _c_ += ", "  ok
			_c_ += @aKinds[_i_][1]
		next
		return _c_

	#-- GRAMMAR ----------------------------------------------------------

	def SetRankDir(pcDir)
		@cRankDir = "" + pcDir
		return This

	def RankDir()
		return @cRankDir

	def SetSplines(pcSpl)
		@cSplines = "" + pcSpl
		return This

	def Splines()
		return @cSplines

	# THE STRONGEST GRAMMAR AMENDMENT A DOMAIN CAN MAKE: which layout it
	# is read in at all. Layered is right where the graph has a
	# direction; a domain whose objects are PEERS -- a state machine's
	# states, a network's nodes -- declares :Ring and is drawn in a
	# space rather than in ranks. Graphviz makes the same split by
	# shipping dot and circo as different programs; here it is one word
	# in the profile.
	def SetLayoutMode(pcMode)
		@cLayoutMode = "" + pcMode
		return This

	def LayoutMode()
		return @cLayoutMode

	# The kinds this profile declares as SOURCES (nothing may enter) and
	# SINKS (nothing may leave) -- derived from the kind rules rather
	# than declared twice, so the placement that reads them can never
	# disagree with the refusals that enforce them.
	def SourceKinds()
		_a_ = []
		_n_ = len(@aKindRules)
		for _i_ = 1 to _n_
			if @aKindRules[_i_][2] = "inbound"  _a_ + @aKindRules[_i_][1]  ok
		next
		return _a_

	def SinkKinds()
		_a_ = []
		_n_ = len(@aKindRules)
		for _i_ = 1 to _n_
			if @aKindRules[_i_][2] = "outbound"  _a_ + @aKindRules[_i_][1]  ok
		next
		return _a_
