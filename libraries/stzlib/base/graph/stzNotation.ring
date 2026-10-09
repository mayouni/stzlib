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

# Declares a diagram domain as data: its node kinds and glyphs, its colours, its well-formedness rules and its layout grammar.
#
# A notation is a profile over the one diagram foundation, not a second renderer. It declares a
# vocabulary of kinds with a glyph, a fill and a scale each (AddKind, AddKindXT, AddKindXTT), closes
# it when unknown kinds must be findings (Close), adds rules by the name of a check (Forbid for
# SelfLink, SecondParent and Cycle, ForbidFor for Inbound and Outbound on one kind), and amends the
# grammar: direction, routing, arrowheads, one ink, layout mode, where names are written. Check
# sweeps a diagram against the rules in the house rule shape [ :rule, :subject, :where, :severity,
# :message ]; MayLink answers the same rules for one link, so an editor can refuse it at the
# gesture. StzRegisterNotation puts a profile in the registry, StzNotation(name) fetches it, and a
# diagram takes one with SetNotation. A name that is not registered gives the default profile, not
# an error. SetNameInside, SetNameOutside, SetPeerChildren and SetBranchSide return nothing, so a
# chain stops at them. A picture of a diagram under a notation needs a font passed to ToPNGXT;
# without one no label is drawn. Picture: a start, two states and an end drawn under a closed
# machine profile with LeftRight showed a small green start dot, two blue rounded boxes named Idle
# and Running, a small red end dot, and arrows left to right; the return arrow from Running to Idle
# had no arrowhead in the box glyphs (notation_machine.png).
#
#   receiver   o1 = new stzNotation("machine"); o1.AddKindXT("state", "rounded", "Info.Solid");
#              o1.AddKind("start", "circle"); o1.AddKind("end", "circle"); o1.ForbidFor("end",
#              :Outbound, "nothing leaves the end")
#   example    ? @@( o1.Kinds() )
#              #--> [ "state", "start", "end" ]
#              ? o1.GlyphOf("state")
#              #--> rounded
#              ? @@( o1.SinkKinds() )
#              #--> [ "end" ]
#   see        stzDiagram, stzRuleReport, StzRegisterNotation, StzNotation
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
	@cBranchSide = ""
	@aNameInside = []
	@aNameOutside = []    # kinds whose inside is spoken for -- a place's tokens
	@bPeerChildren = 0    # a parent's children are peers: none continues it
	@aCompartmentKeys = []
	@bOneInk = 0
	@cLayoutMode = ""     # "" = layered; :Ring for a domain with no flow
	@cRankPolicy = ""     # "" = :Latest -- sinks line up at the last rank
	@cSpine = ""          # "" = no principal path; the layout decides rows
	@bEdgesDirected = 1   # a wire has no direction; a transition has
	@cRegionFill = ""     # the tinted container a discovered region wears
	@aKindScale = []      # [ kind, fraction-of-a-cell ] -- a mark is not a cell

	# Builds an empty notation profile with a name, open to any kind and with no rule and no grammar of its own.
	#
	#   pcName     the notation's name
	#   returns    nothing; the object is built
	#   see        Name_, AddKind, StzRegisterNotation
	def init(pcName)
		@cName = StzLower(ring_trim("" + pcName))

	# Returns the notation's name, trimmed and in lower case.
	#
	#   returns    a text
	#   note       the registry looks a notation up by this name
	#   see        init, StzNotation
	def Name_()
		return @cName

	# Declares a kind of node and the glyph that draws it, replacing the glyph when the kind is already declared.
	#
	#   pcKind     the node kind, as the type property of a node
	#   pcGlyph    the shape name the renderer draws, such as circle, rounded, box, diamond or
	#              ellipse
	#   returns    the notation itself, so calls chain
	#   note       AddKindXT takes a third argument, a colour role such as Info.Solid, and
	#              AddKindXTT a fourth, the fraction of a cell the glyph is drawn at
	#   warning    re-declaring a kind with AddKind clears the fill it had; AddKindXT sets the fill
	#              with the glyph and AddKindXTT adds a scale
	#   see        AddKindXT, AddKindXTT, GlyphOf, Close
	#@ aka  -- VOCABULARY -------------------------------------------------------
	def AddKind(pcKind, pcGlyph)
		return This.AddKindXT(pcKind, pcGlyph, "")

	# ...AND ITS COLOUR, which is part of the glyph rather than a
	# decoration: a domain that says "a state is a rounded box" is not
	# finished until it says what colour a state IS. Named in the house
	# ROLE vocabulary (Info.Solid, Danger.Solid) so a profile inherits
	# the whole colour system -- ramps, contrast pairs, the eight
	# semantic roles -- instead of carrying hex codes of its own.
	# ...AND ITS SIZE, as a fraction of the picture's cell. A PSEUDOSTATE
	# IS A MARK, NOT A CELL: an initial or final state holds no
	# information, has no name to carry and is not somewhere the machine
	# waits -- it is punctuation. Drawn at cell size it reads as another
	# state, and it dominated pictures where the real states were small.
	# Every reference notation draws it as a dot a fifth the size.
	def AddKindXTT(pcKind, pcGlyph, pcFill, pnScale)
		This.AddKindXT(pcKind, pcGlyph, pcFill)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKindScale)
		for _i_ = 1 to _n_
			if @aKindScale[_i_][1] = _k_
				@aKindScale[_i_][2] = pnScale
				return This
			ok
		next
		@aKindScale + [ _k_, pnScale ]
		return This

	# Returns the fraction of a cell a kind is drawn at, 1 for a kind drawn as a full cell.
	#
	#   pcKind     the node kind to ask about, in any case
	#   returns    a number, such as 0.2 for a dot-sized mark, or 1
	#   note       an initial or final state is declared small with AddKindXTT, because it is a mark
	#              and not a cell
	#   see        AddKind, FillOf
	#@ aka  The fraction of a cell this kind is drawn at, 1 when it is a cell.
	def ScaleOf(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKindScale)
		for _i_ = 1 to _n_
			if @aKindScale[_i_][1] = _k_  return @aKindScale[_i_][2]  ok
		next
		return 1

	def AddKindXT(pcKind, pcGlyph, pcFill)
		_k_ = StzLower(ring_trim("" + pcKind))
		_g_ = StzLower(ring_trim("" + pcGlyph))
		_f_ = ring_trim("" + pcFill)
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_
				@aKinds[_i_][2] = _g_
				@aKinds[_i_][3] = _f_
				return This
			ok
		next
		@aKinds + [ _k_, _g_, _f_ ]
		return This

		def AddKindXTQ(pcKind, pcGlyph, pcFill)
			return This.AddKindXT(pcKind, pcGlyph, pcFill)

	# Returns the colour role declared for a kind, or an empty text when the profile declares none.
	#
	#   pcKind     the node kind to ask about, in any case
	#   returns    a text such as Info.Solid, or an empty text
	#   note       an empty text leaves the renderer's own colour in force, and a node that names
	#              its own colour outranks the profile
	#   see        AddKind, GlyphOf
	#@ aka  The fill this profile declares for a kind, or "" -- which leaves the renderer's own default in force. A node that names its own colour always outranks the profile: the author is closer.
	def FillOf(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_ and len(@aKinds[_i_]) >= 3
				return @aKinds[_i_][3]
			ok
		next
		return ""

	# Declares the colour role a region is painted in, the tinted container drawn around the members of a region.
	#
	#   pcFill     a colour role such as Info.Subtle
	#   returns    the notation itself, so calls chain
	#   see        RegionFill, FillOf
	#@ aka  The colour a REGION is painted -- the tinted container step of the role its members carry. Declared with SetRegionFill, and left "" by a profile that draws no regions.
	def SetRegionFill(pcFill)
		@cRegionFill = "" + pcFill
		return This

	# Returns the colour role the notation paints a region in.
	#
	#   returns    a text; empty when none was set
	#   see        SetRegionFill
	def RegionFill()
		return @cRegionFill

		def AddKindQ(pcKind, pcGlyph)
			return This.AddKind(pcKind, pcGlyph)

	# Returns the declared node types, in lower case, in the order they were declared.
	#
	#   returns    a list of text; empty for a notation with none declared
	#   see        AddKind, KnowsKind, IsClosed
	def Kinds()
		_a_ = []
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_  _a_ + @aKinds[_i_][1]  next
		return _a_

	# Closes the vocabulary, so a node of an undeclared kind becomes a finding of Check instead of being drawn without comment.
	#
	#   returns    the notation itself, so calls chain
	#   note       a node with no type at all is not a finding; an open notation, the default, lets
	#              any kind through
	#   see        IsClosed, Check, KnowsKind
	def Close()
		# a CLOSED vocabulary: a kind this profile did not declare is a
		# finding, not a box. Open is the default because the default
		# profile is the generic diagram, whose whole point is openness.
		@bClosed = 1
		return This

	# TRUE if the vocabulary was closed, so only the declared kinds are accepted.
	#
	#   returns    1 when closed, 0 when open
	#   see        Close
	def IsClosed()
		return @bClosed

	# TRUE if a kind was declared, in any case.
	#
	#   pcKind     the node kind to ask about
	#   returns    TRUE or FALSE
	#   note       a kind the glyph table knows is still not declared here, so an open notation
	#              answers FALSE
	#   see        Kinds, GlyphOf
	def KnowsKind(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_  return TRUE  ok
		next
		return FALSE

	# Returns the shape that draws a kind: the declared glyph, else the shared shape table for an open notation, else an empty text.
	#
	#   pcKind     the node kind to ask about, in any case
	#   returns    a text such as rounded; empty for an undeclared kind in a closed notation
	#   note       in an open notation start answers ellipse, state answers circle and decision
	#              answers diamond, from the shared table
	#   see        AddKind, KnowsKind
	#@ aka  The kind's glyph: the geometric shape the renderer draws. The DEFAULT profile answers through the SAME shared table both faces already read (StzNodeShapeForType), so expressing the diagram as a profile moves no pixel -- DN0's whole claim. A declared kind outranks the table; an unknown kind in an OPEN profile falls back to it; in a CLOSED one it answers "", and the renderer's existing fallback (a b
	def GlyphOf(pcKind)
		_k_ = StzLower(ring_trim("" + pcKind))
		_n_ = len(@aKinds)
		for _i_ = 1 to _n_
			if @aKinds[_i_][1] = _k_  return @aKinds[_i_][2]  ok
		next
		if @bClosed  return ""  ok
		return StzNodeShapeForType(_k_)

	# Adds a well-formedness rule by the name of a check the notation knows, with the message to report when it is broken.
	#
	#   pcWhat      the check: SelfLink, SecondParent or Cycle
	#   pcMessage   the text reported as the finding and given as the reason for a refused link
	#   returns     the notation itself, so calls chain
	#   note        SelfLink forbids an edge from a node to itself, SecondParent a node with two
	#               incoming edges and Cycle an edge that closes a loop
	#   warning     a name that is not one of the three checks is stored and never used, with no
	#               error; the first rule of a name answers when it is repeated
	#   see         Rules, ForbidFor, Check, MayLink
	#@ aka  -- RULES ------------------------------------------------------------
	def Forbid(pcWhat, pcMessage)
		@aRules + [ StzLower(ring_trim("" + pcWhat)), "" + pcMessage ]
		return This

		def ForbidQ(pcWhat, pcMessage)
			return This.Forbid(pcWhat, pcMessage)

	# Returns the well-formedness checks added so far, each with the message to report.
	#
	#   returns    a list of [ check, message ] pairs, the check in lower case; empty when none was
	#              added
	#   see        Forbid, Check
	def Rules()
		return @aRules

	def _Forbids(pcWhat)
		_w_ = StzLower("" + pcWhat)
		_n_ = len(@aRules)
		for _i_ = 1 to _n_
			if @aRules[_i_][1] = _w_  return @aRules[_i_][2]  ok
		next
		return ""

	# Adds a rule that belongs to one kind: nothing may enter a kind, or nothing may leave it.
	#
	#   pcKind      the node kind the rule is about
	#   pcWhat      Inbound to forbid edges into the kind, or Outbound to forbid edges out of it
	#   pcMessage   the text reported when the rule is broken
	#   returns     the notation itself, so calls chain
	#   note        an initial state forbids Inbound and a final state forbids Outbound
	#   see         Forbid, SourceKinds, SinkKinds, Check
	#@ aka  A rule a KIND carries -- DN2. :Inbound forbidden for an initial pseudostate means nothing may transition INTO it; :Outbound for a final state means nothing leaves. The kind is the subject because that is how the domain speaks: "a final state has no exits" is a statement about final states, not about any edge.
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
		_aNd7_ = poDiag.Nodes()
		_nNd7_ = len(_aNd7_)
		for _iNd7_ = 1 to _nNd7_
			_nd_ = _aNd7_[_iNd7_]
			if StzLower("" + _nd_[:id]) != _id_  loop  ok
			if HasKey(_nd_, "properties") and isList(_nd_["properties"])
				if HasKey(_nd_["properties"], "type")
					return StzLower("" + _nd_["properties"]["type"])
				ok
			ok
			return ""
		next
		return ""

	# TRUE if an edge from one node to another is allowed by the rules, so an editor can refuse the link before it is made.
	#
	#   poDiag     the diagram the link would join, or an empty text to test the self-link rule
	#              alone
	#   pcFrom     the id of the source node
	#   pcTo       the id of the target node
	#   returns    TRUE or FALSE
	#   note       on a chain ceo, vp, mgr with SecondParent and Cycle forbidden, ceo to mgr and mgr
	#              to ceo are refused and mgr to a new node is allowed
	#   warning    with no diagram object only SelfLink is tested; SecondParent, Cycle and the kind
	#              rules need the diagram, and every one of them counts the edges the diagram
	#              already holds
	#   see        Check, Forbid, ForbidFor
	#@ aka  May an edge from -> to exist under this profile? Consulted by the editor's Link and Rewire commands, so an illegal link is refused at the gesture -- the domain's rules become the editor's refusals with no editor code knowing any domain.
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
				_aE6_ = poDiag.Edges()
				_nE6_ = len(_aE6_)
				for _iE6_ = 1 to _nE6_
					_e_ = _aE6_[_iE6_]
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

	# Sweeps a diagram against the notation and returns one row per finding, in the house rule shape.
	#
	#   poDiagram   the diagram to check
	#   returns     a list of rows [ :rule, :subject, :where, :severity, :message ]; empty when
	#               nothing is wrong or when the argument is not an object
	#   note        a node with two incoming edges is one finding, and each edge that closes a loop
	#               is one finding
	#   warning     the rule names are notation-unknown-kind (a warning), notation-self-link,
	#               notation-second-parent, notation-cycle, notation-inbound and notation-outbound
	#               (errors); where holds the notation's name
	#   see         MayLink, Forbid, Close
	#@ aka  The model swept against the profile, answered in the house rule shape -- one row per finding, ready for stzRuleReport.Ingest().
	def Check(poDiagram)
		_aOut_ = []
		if NOT isObject(poDiagram)  return _aOut_  ok

		if @bClosed
			_aNd5_ = poDiagram.Nodes()
			_nNd5_ = len(_aNd5_)
			for _iNd5_ = 1 to _nNd5_
				_nd_ = _aNd5_[_iNd5_]
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
			_aE4_ = poDiagram.Edges()
			_nE4_ = len(_aE4_)
			for _iE4_ = 1 to _nE4_
				_e_ = _aE4_[_iE4_]
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
			_aE3_ = poDiagram.Edges()
			_nE3_ = len(_aE3_)
			for _iE3_ = 1 to _nE3_
				_e_ = _aE3_[_iE3_]
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
			_aE2_ = poDiagram.Edges()
			_nE2_ = len(_aE2_)
			for _iE2_ = 1 to _nE2_
				_e_ = _aE2_[_iE2_]
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
			_aE1_ = poDiagram.Edges()
			_nE1_ = len(_aE1_)
			for _iE1_ = 1 to _nE1_
				_e_ = _aE1_[_iE1_]
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

	# Declares the direction the domain is read in, which a diagram takes over when this notation is set on it.
	#
	#   pcDir      a layout direction of the diagram: TopDown, BottomUp, LeftRight or RightLeft
	#   returns    the notation itself, so calls chain
	#   note       with LeftRight a state machine is drawn from left to right
	#   warning    the text is stored as given
	#   see        RankDir, SetSplines
	#@ aka  -- GRAMMAR ----------------------------------------------------------
	def SetRankDir(pcDir)
		@cRankDir = "" + pcDir
		return This

	# Returns the direction the notation declares.
	#
	#   returns    a text; empty when the notation amends nothing
	#   see        SetRankDir
	def RankDir()
		return @cRankDir

	# Declares the way edges are routed, which a diagram takes over when this notation is set on it.
	#
	#   pcSpl      an edge routing name such as ortho
	#   returns    the notation itself, so calls chain
	#   warning    the text is stored as given
	#   see        Splines, SetRankDir
	def SetSplines(pcSpl)
		@cSplines = "" + pcSpl
		return This

	# Returns the edge routing the notation declares.
	#
	#   returns    a text; empty when the notation amends nothing
	#   see        SetSplines
	def Splines()
		return @cSplines

	# Declares whether an edge carries a direction, so whether it is drawn with an arrowhead.
	#
	#   pbYes      1 for edges with an arrowhead, the default
	#   returns    the notation itself, so calls chain
	#   note       a diagram of two boxes and one edge draws one polygon more with 1 than with 0,
	#              the arrowhead
	#   see        EdgesDirected, SetOneInk
	#@ aka  THE STRONGEST GRAMMAR AMENDMENT A DOMAIN CAN MAKE: which layout it is read in at all. Layered is right where the graph has a direction; a domain whose objects are PEERS -- a state machine's states, a network's nodes -- declares :Ring and is drawn in a space rather than in ranks. Graphviz makes the same split by shipping dot and circo as different programs; here it is one word in the profile. WHEN 
	def SetEdgesDirected(pbYes)
		@bEdgesDirected = pbYes
		return This

	# Returns whether edges are drawn with a direction.
	#
	#   returns    1 for directed, the default, or 0
	#   see        SetEdgesDirected
	def EdgesDirected()
		return @bEdgesDirected

	# Declares whether the layout straightens the main path: HappyPath forces it, None forbids it, and empty lets the layout decide.
	#
	#   pcKind     the mode, HappyPath, None or an empty text
	#   returns    the notation itself, so calls chain
	#   note       the parameter is named for a kind but the layout reads it as a mode; the setter
	#              and getter were run, the layout's use of the mode was read in the code and not
	#              drawn
	#   see        Spine, SetBranchSide
	def SetSpine(pcKind)
		@cSpine = StzLower("" + pcKind)
		return This

	# Returns the principal-path setting, in lower case.
	#
	#   returns    a text; empty when none was set
	#   see        SetSpine
	def Spine()
		return @cSpine

	# Declares when a node takes its rank: latest lines the endings up at the last rank, earliest places a node as soon as its sources allow.
	#
	#   pcPolicy   latest or earliest
	#   returns    the notation itself, so calls chain
	#   warning    an empty text means latest
	#   see        RankPolicy, SetLayoutMode
	def SetRankPolicy(pcPolicy)
		@cRankPolicy = StzLower("" + pcPolicy)
		return This

	# Returns the rank policy, in lower case.
	#
	#   returns    a text; empty when none was set, which the diagram reads as latest
	#   see        SetRankPolicy
	def RankPolicy()
		return @cRankPolicy

	# Declares that the outline of a node and the edges are one drawing, so both use the node ink and no lighter edge colour.
	#
	#   pbYes      1 for one ink, 0 for the usual lighter edges
	#   returns    the notation itself, so calls chain
	#   note       meant for a schematic, where a wire and a part are one conductor
	#   see        OneInk, SetEdgesDirected
	#@ aka  ONE INK FOR THE OUTLINE AND THE WIRE.
	def SetOneInk(pbYes)
		@bOneInk = pbYes
		return This

	# Returns whether outlines and edges share one ink.
	#
	#   returns    1 for one ink, or 0, the default
	#   see        SetOneInk
	def OneInk()
		return @bOneInk

	# Declares that a kind writes its name inside its glyph, even a glyph that would normally hold none, such as a diamond.
	#
	#   pcKind     the node kind, in any case
	#   returns    nothing; it cannot be chained
	#   note       a decision drawn as a diamond holds its question
	#   warning    unlike the other setters it returns nothing, so a call chained after it fails
	#   see        WritesNameInside, SetNameOutside
	#@ aka  WHICH SIDE OF THE SPINE AN ALTERNATIVE STANDS ON.
	def SetNameInside(pcKind)
		_niK_ = StzLower("" + pcKind)
		_nNi_ = len(@aNameInside)
		for _iNi_ = 1 to _nNi_
			if @aNameInside[_iNi_] = _niK_  return  ok
		next
		@aNameInside + _niK_

	# Declares a property of a node as a compartment, a ruled section of the box that stacks under the name, in the order added.
	#
	#   pcKey      the property name, kept in lower case
	#   returns    the notation itself, so calls chain
	#   note       a class box in UML has attributes and operations
	#   see        CompartmentKeys
	#@ aka  THE PROPERTIES THIS NOTATION READS AS COMPARTMENTS, in the order they stack under the name.
	def AddCompartmentKey(pcKey)
		if @aCompartmentKeys = NULL  @aCompartmentKeys = []  ok
		@aCompartmentKeys + StzLower("" + pcKey)
		return This

	# Returns the compartment properties the notation declares, in the order added.
	#
	#   returns    a list of text; empty when none was added, in which case the renderer keeps its
	#              own UML pair
	#   see        AddCompartmentKey
	def CompartmentKeys()
		if @aCompartmentKeys = NULL  return []  ok
		return @aCompartmentKeys

	# TRUE if the kind was declared to write its name inside its glyph.
	#
	#   pcKind     the node kind, in any case
	#   returns    1 or 0
	#   see        SetNameInside, WritesNameOutside
	def WritesNameInside(pcKind)
		_niK_ = StzLower("" + pcKind)
		_nNi_ = len(@aNameInside)
		for _iNi_ = 1 to _nNi_
			if @aNameInside[_iNi_] = _niK_  return 1  ok
		next
		return 0

	# Declares that a kind keeps its inside for something else, so its name is written outside the glyph.
	#
	#   pcKind     the node kind, in any case
	#   returns    nothing; it cannot be chained
	#   note       a Petri place holds its tokens, and its name written over them is not readable
	#   warning    unlike the other setters it returns nothing
	#   see        WritesNameOutside, SetNameInside
	#@ aka  THE OPPOSITE DECLARATION: a kind whose inside is spoken for. The renderer writes a name inside any glyph big enough to hold it, which is right until the glyph holds something else -- a Petri place holds its tokens, and "Key" written over one dot read as "K.y". Declared per kind, so a notation says it once.
	def SetNameOutside(pcKind)
		_noK_ = StzLower("" + pcKind)
		_nNo_ = len(@aNameOutside)
		for _iNo_ = 1 to _nNo_
			if @aNameOutside[_iNo_] = _noK_  return  ok
		next
		@aNameOutside + _noK_

	# Declares that the children of a parent are peers, so none of them is the line onward and the parent stands at their middle.
	#
	#   returns    nothing; it cannot be chained
	#   note       a fault tree gate has inputs, not a continuation
	#   warning    unlike the other setters it returns nothing, so a call chained after it fails
	#   see        PeerChildren, SetBranchSide
	#@ aka  A PARENT'S CHILDREN ARE PEERS. The layout gives a parent's column to the child that carries the longest continuation -- right for a flow, where the graph itself says "this way onward". A fault tree's gate has inputs, not a continuation: none of them is the line onward, so the gate stands at their middle whatever hangs beneath each. Declared by the notation, read by the layout.
	def SetPeerChildren()
		@bPeerChildren = 1

	# Returns whether the children of a parent are peers.
	#
	#   returns    1 when declared, or 0, the default
	#   see        SetPeerChildren
	def PeerChildren()
		return @bPeerChildren

	# TRUE if the kind was declared to write its name outside its glyph.
	#
	#   pcKind     the node kind, in any case
	#   returns    1 or 0
	#   see        SetNameOutside, WritesNameInside
	def WritesNameOutside(pcKind)
		_noK_ = StzLower("" + pcKind)
		_nNo_ = len(@aNameOutside)
		for _iNo_ = 1 to _nNo_
			if @aNameOutside[_iNo_] = _noK_  return 1  ok
		next
		return 0

	# Declares on which side of the main path an alternative stands, kept in lower case.
	#
	#   pcSide     a side such as right, kept in lower case
	#   returns    nothing; it cannot be chained
	#   note       DRAKON puts every branch to the right of the main line
	#   warning    unlike the other setters it returns nothing
	#   see        BranchSide, SetSpine
	def SetBranchSide(pcSide)
		@cBranchSide = StzLower("" + pcSide)

	# Returns the side alternatives stand on.
	#
	#   returns    a text, both when none was declared
	#   see        SetBranchSide
	def BranchSide()
		if @cBranchSide = ""  return "both"  ok
		return @cBranchSide

	# Declares the layout the domain is read in, in place of ranks: ring for peers on a circle, and the other modes the diagram knows.
	#
	#   pcMode     a layout mode name such as ring, circular, modes, sequence, mesh or silhouette
	#   returns    the notation itself, so calls chain
	#   note       a state machine of peer states can be read in a ring
	#   warning    the text is stored as given, so a leading colon in it is kept and is not
	#              understood by the diagram
	#   see        LayoutMode, SetRankDir
	def SetLayoutMode(pcMode)
		@cLayoutMode = "" + pcMode
		return This

	# Returns the layout mode the notation declares.
	#
	#   returns    a text; empty for a layered layout
	#   see        SetLayoutMode
	def LayoutMode()
		return @cLayoutMode

	# Returns the kinds nothing may enter, taken from the Inbound rules of ForbidFor.
	#
	#   returns    a list of text, in lower case
	#   see        SinkKinds, ForbidFor
	#@ aka  The kinds this profile declares as SOURCES (nothing may enter) and SINKS (nothing may leave) -- derived from the kind rules rather than declared twice, so the placement that reads them can never disagree with the refusals that enforce them.
	def SourceKinds()
		_a_ = []
		_n_ = len(@aKindRules)
		for _i_ = 1 to _n_
			if @aKindRules[_i_][2] = "inbound"  _a_ + @aKindRules[_i_][1]  ok
		next
		return _a_

	# Returns the kinds nothing may leave, taken from the Outbound rules of ForbidFor.
	#
	#   returns    a list of text, in lower case
	#   see        SourceKinds, ForbidFor
	def SinkKinds()
		_a_ = []
		_n_ = len(@aKindRules)
		for _i_ = 1 to _n_
			if @aKindRules[_i_][2] = "outbound"  _a_ + @aKindRules[_i_][1]  ok
		next
		return _a_
