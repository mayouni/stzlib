#================================================================#
#  STZSECURITYGRAPH -- the security surface, made an explicit graph #
#================================================================#

/*--- Why the security surface must be a graph (graph-rules plan, phase 5)

stzSecurityPosture checks FLAGS ON SINGLE OBJECTS: is THIS actor both sandboxed
and effectful; does THIS site hold an inline key. It is structurally blind to a
sandboxed actor that reaches an effect THROUGH a tool, a delegation, or a site --
because that is a PATH, and a flag check sees one node at a time.

The security surface is, in truth, a graph: actors -> capabilities, actors ->
tools, tools -> capabilities, actors -> actors (delegation), sites -> secrets,
secrets -> stores. Make that graph explicit and the escalation question becomes
the right one: can any sandboxed node REACH the effectful capability by ANY path?
That is a reachability query -- a class of finding stzSecurityPosture cannot
produce.

	oSG = new stzSecurityGraph("restolean")
	oSG.AddActor("llm", "sandboxed")        # holds NO effectful directly
	oSG.AddTool("shell")
	oSG.Uses("llm", "shell")                # ...but uses a tool
	oSG.Grants("shell", "effectful")        # ...that grants effectful
	? oSG.ReachesEffectful("llm")           #--> TRUE  (a flag check misses this)

It also carries the CONSTRAINT: AttachSecret() refuses attaching a live secret
to a sandboxed actor at construction (audit -> gate), and the blast radius of a
secret becomes a graph query (who can reach it -- rotation planning).

Colored like stzAgentGraph: nodes carry :kind and, for actors, :posture. Edges
carry their meaning as labels. Capability nodes are auto-created (a capability is
just a named lattice element); actors/tools/secrets/stores/sites are declared.
*/

func StzSecurityGraphQ(pcName)
	return new stzSecurityGraph(pcName)

class stzSecurityGraph from stzObject

	@cName = ""
	@oG = ""
	# THE SEALED RECORD (threat-model R1, 2026-09-29). GraphQ() hands out the
	# raw graph, so any property on it can be set around the governed doors.
	# The properties a GATE decides on are therefore ALSO recorded here, by the
	# governed doors only, out of GraphQ()'s reach: the gates read THIS record,
	# and Tampering() reports every node whose graph property no longer matches
	# it. A raw edit can still change the picture; it can no longer change a
	# decision, and it can no longer go unseen.
	@aSealed = []	# [ actorId, posture ]

	def init(pcName)
		@cName = "" + pcName
		@oG = new stzGraph("secgraph-" + pcName)

	def GraphQ()
		return @oG

	def Name()
		return @cName

	  #-- nodes -----------------------------------------------------------

	# posture: trusted | external | sandboxed
	def AddActor(pcId, pcPosture)
		_cId_ = This._Node(pcId, "actor")
		_cP_ = StzLower(ring_trim("" + pcPosture))
		@oG.SetNodeProperty(_cId_, "posture", _cP_)
		_i_ = This._SealIndex(_cId_)
		if _i_ > 0
			@aSealed[_i_][2] = _cP_
		else
			@aSealed + [ _cId_, _cP_ ]
		ok
		return This

	def _SealIndex(pcId)
		_n_ = len(@aSealed)
		for _i_ = 1 to _n_
			if @aSealed[_i_][1] = pcId  return _i_  ok
		next
		return 0

	# the posture AddActor recorded -- what every gate reads ("" if none)
	def _SealedPosture(pcId)
		_i_ = This._SealIndex(pcId)
		if _i_ = 0  return ""  ok
		return @aSealed[_i_][2]

	# actors whose graph posture no longer matches the one AddActor recorded
	# [ [ actor, recorded, found ], ... ]
	def Tampering()
		_aOut_ = []
		_n_ = len(@aSealed)
		for _i_ = 1 to _n_
			_cId_ = @aSealed[_i_][1]
			_cFound_ = "(removed)"
			if @oG.NodeExists(_cId_)
				_cFound_ = StzLower("" + @oG.NodeProperty(_cId_, "posture"))
			ok
			if _cFound_ != @aSealed[_i_][2]
				_aOut_ + [ _cId_, @aSealed[_i_][2], _cFound_ ]
			ok
		next
		return _aOut_

	def AddTool(pcId)
		This._Node(pcId, "tool")
		return This

	def AddSecret(pcId)
		This._Node(pcId, "secret")
		return This

	def AddStore(pcId)
		This._Node(pcId, "store")
		return This

	def AddSite(pcId)
		This._Node(pcId, "site")
		return This

	# capabilities are auto-created by Holds/Grants, but may be declared too
	def AddCapability(pcId)
		This._Node(pcId, "capability")
		return This

	def _Node(pcId, pcKind)
		_cId_ = StzLower(ring_trim("" + pcId))
		if NOT @oG.NodeExists(_cId_)
			@oG.AddNode(_cId_)
		ok
		@oG.SetNodeProperty(_cId_, "kind", pcKind)
		return _cId_

	  #-- edges (the meaning is the label) --------------------------------

	# an actor directly holds a capability
	def Holds(pcActor, pcCapability)
		This._Edge(This._Require(pcActor), This._Cap(pcCapability), "holds")
		return This

	# an actor uses a tool
	def Uses(pcActor, pcTool)
		This._Edge(This._Require(pcActor), This._Require(pcTool), "uses")
		return This

	# a tool grants (confers) a capability
	def Grants(pcTool, pcCapability)
		This._Edge(This._Require(pcTool), This._Cap(pcCapability), "grants")
		return This

	# an actor may act as another (delegation -- transitive trust)
	def Delegates(pcFrom, pcTo)
		This._Edge(This._Require(pcFrom), This._Require(pcTo), "delegates")
		return This

	# a site references a secret
	def References(pcSite, pcSecret)
		This._Edge(This._Require(pcSite), This._Require(pcSecret), "references")
		return This

	# a secret lives in a store
	def StoredIn(pcSecret, pcStore)
		This._Edge(This._Require(pcSecret), This._Require(pcStore), "stored_in")
		return This

	  #-- the CONSTRAINT: no live secret to a sandboxed actor -------------

	# TRUE when attaching pcSecret to pcActor keeps the surface sound (a
	# sandboxed actor must not hold a live secret it could exfiltrate).
	def MayAttach(pcActor, pcSecret)
		_cA_ = StzLower(ring_trim("" + pcActor))
		if NOT @oG.NodeExists(_cA_)
			return 0
		ok
		return This._SealedPosture(_cA_) != "sandboxed"

	# Attach a secret to an actor -- the governed door. REFUSED for a sandboxed
	# actor at construction (audit -> gate), so the escalation can never enter
	# the graph through the sanctioned API.
	def AttachSecret(pcActor, pcSecret)
		_cA_ = This._Require(pcActor)
		_cS_ = This._Require(pcSecret)
		if This._SealedPosture(_cA_) = "sandboxed"
			# Incident I2: the raise stops the escalation; the ledger keeps
			# the attempt. Which secret a sandboxed actor was pointed at is
			# exactly what a post-mortem wants, and a caller's try/catch
			# would otherwise erase it.
			StzNoteRefusal("posture.refused", _cA_, "secret:" + _cS_,
				"a sandboxed actor must not hold a live secret")
			stzraise("REFUSED: attaching secret '" + _cS_ + "' to SANDBOXED actor '" + _cA_ +
			         "' -- a sandboxed actor must not hold a live secret (enforced at construction).")
		ok
		This._Edge(_cA_, _cS_, "attaches")
		return This

	  #-- queries ---------------------------------------------------------

	# Can this actor reach the 'effectful' capability by ANY path (directly, or
	# through a tool, or through delegation)? The multi-hop escalation question.
	def ReachesEffectful(pcActor)
		return This.ReachesCapability(pcActor, "effectful")

	def ReachesCapability(pcActor, pcCapability)
		_cA_ = StzLower(ring_trim("" + pcActor))
		_cCap_ = StzLower(ring_trim("" + pcCapability))
		if NOT @oG.NodeExists(_cA_) or NOT @oG.NodeExists(_cCap_)
			return 0
		ok
		return @oG.PathExists(_cA_, _cCap_)

	# THE PATH ITSELF, not merely whether one exists (incident I5): an
	# investigation must be able to say HOW an actor could reach a
	# capability -- "billing-agent -> deploy-tool -> effectful" -- and
	# an empty list means no path.
	def PathToCapability(pcActor, pcCapability)
		_cA_ = StzLower(ring_trim("" + pcActor))
		_cCap_ = StzLower(ring_trim("" + pcCapability))
		if NOT @oG.NodeExists(_cA_) or NOT @oG.NodeExists(_cCap_)
			return []
		ok
		if NOT @oG.PathExists(_cA_, _cCap_)
			return []
		ok
		return @oG.ShortestPath(_cA_, _cCap_)

	def PathToEffectful(pcActor)
		return This.PathToCapability(pcActor, "effectful")

	  #-- containment: cut a capability away (R10) -------------------------
	#
	# Remove EVERY path by which pcActor reaches pcCapability, by cutting the
	# actor's OWN first-hop edges that lead there: a capability it holds
	# directly, a tool it uses that grants it, an actor it delegates to that
	# reaches it. Other actors are untouched -- a colleague using the same
	# tool keeps it. Returns the edges removed, as [ from, label, to ].
	def CutCapability(pcActor, pcCapability)
		_cA_ = StzLower(ring_trim("" + pcActor))
		_cCap_ = StzLower(ring_trim("" + pcCapability))
		_aCut_ = []
		if NOT (@oG.NodeExists(_cA_) and @oG.NodeExists(_cCap_))
			return _aCut_
		ok
		_aE_ = @oG.Edges()
		_n_ = len(_aE_)
		for _i_ = 1 to _n_
			if _aE_[_i_][:from] = _cA_
				_cTo_ = _aE_[_i_][:to]
				if _cTo_ = _cCap_ or @oG.PathExists(_cTo_, _cCap_)
					_aCut_ + [ _cA_, "" + _aE_[_i_][:label], _cTo_ ]
				ok
			ok
		next
		_nC_ = len(_aCut_)
		for _i_ = 1 to _nC_
			@oG.RemoveThisEdge(_aCut_[_i_][1], _aCut_[_i_][3])
		next
		if _nC_ > 0
			StzNoteGrant("capability.revoked", _cA_, "capability:" + _cCap_)
		ok
		return _aCut_

	# Every node that can REACH this secret (reverse reachability) -- the blast
	# radius: which sites and actors a leaked secret exposes. Rotation planning.
	def BlastRadius(pcSecret)
		_cS_ = StzLower(ring_trim("" + pcSecret))
		_aOut_ = []
		if NOT @oG.NodeExists(_cS_)
			return _aOut_
		ok
		_aIds_ = @oG.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			if _aIds_[_i_] != _cS_ and @oG.PathExists(_aIds_[_i_], _cS_)
				_aOut_ + _aIds_[_i_]
			ok
		next
		return _aOut_

	  #-- the escalation audit (incident I2) --------------------------------

	/*
		Every sandboxed actor that can nevertheless REACH an effectful
		capability, with the path that gets it there:

			[ [ actor, [ hop, hop, ... ] ], ... ]

		...and each one recorded as a graph.escalation_path_found event.

		WHY THIS IS A VERB AND NOT A SIDE EFFECT OF ReachesEffectful().
		The query methods are questions -- an investigation asks them
		dozens of times while reconstructing an incident, and a question
		that writes evidence would fill the chain with the investigator's
		own curiosity. This is the DELIBERATE act: audit the surface, and
		remember what the audit found. Run it after a topology change, on
		a schedule, or from the CI gate next to Violations().

		The path is the whole point. "billing-agent can reach effectful"
		names a risk; "billing-agent -> deploy-tool -> effectful" names the
		edge to cut.
	*/
	def AuditEscalations()
		_aOut_ = []
		_aIds_ = @oG.NodesIds()
		_n_ = len(_aIds_)
		for _i_ = 1 to _n_
			_cId_ = _aIds_[_i_]
			if This._SealedPosture(_cId_) != "sandboxed"
				loop
			ok
			_aPath_ = This.PathToEffectful(_cId_)
			if len(_aPath_) = 0
				loop
			ok
			_aOut_ + [ _cId_, _aPath_ ]
			StzNoteRefusal("graph.escalation_path_found", _cId_,
				"capability:effectful",
				"a sandboxed actor reaches effectful via " + This._PathWords(_aPath_))
		next
		return _aOut_

	def NumberOfEscalations()
		return len( This.AuditEscalations() )

	def _PathWords(paPath)
		_n_ = len(paPath)
		if _n_ = 0
			return "(no path)"
		ok
		_c_ = "" + paPath[1]
		for _i_ = 2 to _n_
			_c_ += " -> " + paPath[_i_]
		next
		return _c_

	  #-- proof + internals -----------------------------------------------

	def Violations()
		_aF_ = StzSecurityRuleSetQ().Check(@oG)
		_aT_ = This.Tampering()
		_n_ = len(_aT_)
		for _i_ = 1 to _n_
			_aF_ + [ :rule = "governed-property-tampered", :subject = _aT_[_i_][1],
				:where = _aT_[_i_][1], :severity = :error,
				:message = "actor '" + _aT_[_i_][1] + "': posture is '" + _aT_[_i_][3] +
					"' but AddActor recorded '" + _aT_[_i_][2] + "' -- set around the gate" ]
		next
		return _aF_

	def IsSound()
		return StzSecurityRuleSetQ().IsSound(@oG) and len(This.Tampering()) = 0

	# The uniform graph-owned verb (so an stzRuleReport can Collect this graph
	# like any other): the security graph checks ITSELF.
	def CheckRules()
		return This.Violations()

	def RulesAreSound()
		return This.IsSound()

	def _Cap(pcCapability)
		return This._Node(pcCapability, "capability")

	def _Require(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		if NOT @oG.NodeExists(_cId_)
			stzraise("stzSecurityGraph: no node '" + pcId + "' -- declare it (AddActor/AddTool/AddSecret/...) first.")
		ok
		return _cId_

	def _Edge(pcFrom, pcTo, pcLabel)
		if NOT @oG.EdgeExists(pcFrom, pcTo)
			@oG.AddEdgeXTT(pcFrom, pcTo, pcLabel, [ :type = "security" ])
		ok
