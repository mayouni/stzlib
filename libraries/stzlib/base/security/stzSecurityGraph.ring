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

# Holds the security surface as a graph of actors, tools, capabilities, secrets, stores and sites, so that escalation is a path query.
#
# A flag check sees one object at a time and misses a sandboxed actor that reaches an effect through
# a tool or a delegation, because that is a path. This graph makes the paths explicit: Uses, Grants,
# Holds, Delegates, References and StoredIn add labelled edges, and ReachesEffectful,
# PathToEffectful and AuditEscalations ask whether, and how, a sandboxed node gets to the effectful
# capability. AttachSecret refuses a live secret for a sandboxed actor, BlastRadius lists who can
# reach a secret, and CutCapability removes an actor's routes to a capability. Node ids are lower-
# cased. The postures that gates decide on are also recorded out of reach of GraphQ, and Tampering
# reports any that were edited around the doors.
#
#   receiver   o1 = new stzSecurityGraph("resto"); o1.AddActor("llm", "sandboxed");
#              o1.AddTool("shell") o1.Uses("llm", "shell"); o1.Grants("shell", "effectful")
#   example    ? o1.ReachesEffectful("llm")
#              #--> 1
#              ? @@(o1.PathToEffectful("llm"))
#              #--> [ "llm", "shell", "effectful" ]
#              ? o1.IsSound()
#              #--> 0
#   see        stzSecurityPosture, stzGraph, stzIncident
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

	# Builds an empty security graph with a name, ready for actors, tools, secrets and the edges between them.
	#
	#   pcName     the graph name
	#   returns    nothing; the object is built
	#   see        AddActor, GraphQ
	def init(pcName)
		@cName = "" + pcName
		@oG = new stzGraph("secgraph-" + pcName)

	# Returns the underlying stzGraph, to draw or query directly.
	#
	#   returns    the stzGraph object that holds the nodes and edges
	#   warning    the graph can be edited through it around the governed doors; Tampering reports a
	#              changed posture
	#   see        Tampering, Name
	def GraphQ()
		return @oG

	# Returns the name the graph was built with.
	#
	#   returns    a text
	#   see        GraphQ
	def Name()
		return @cName

	# Declares an actor node with a trust posture, and records the posture where gates read it.
	#
	#   pcId        the actor name, lower-cased and trimmed to make the node id
	#   pcPosture   the posture, trusted, external or sandboxed
	#   returns     the graph itself, so calls chain
	#   note        declaring the same id again replaces its posture; the posture record is kept out
	#               of reach of GraphQ
	#   see         AddTool, Uses, MayAttach, Tampering
	#@ aka  -- nodes -----------------------------------------------------------
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

	# Returns the actors whose posture in the graph no longer equals the one AddActor recorded.
	#
	#   returns    a list of [ actor, recorded, found ] rows; found is (removed) for a deleted node
	#   note       [ ] when nothing was edited around the governed doors
	#   see        Violations, GraphQ
	#@ aka  actors whose graph posture no longer matches the one AddActor recorded [ [ actor, recorded, found ], ... ]
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

	# Declares a tool node, something an actor can use and that can grant a capability.
	#
	#   pcId       the tool name, lower-cased and trimmed to make the node id
	#   returns    the graph itself, so calls chain
	#   see        Uses, Grants
	def AddTool(pcId)
		This._Node(pcId, "tool")
		return This

	# Declares a secret node, by descriptor and never by value.
	#
	#   pcId       the secret name, lower-cased and trimmed to make the node id
	#   returns    the graph itself, so calls chain
	#   see        StoredIn, References, BlastRadius
	def AddSecret(pcId)
		This._Node(pcId, "secret")
		return This

	# Declares a store node, a place where secrets live.
	#
	#   pcId       the store name, lower-cased and trimmed to make the node id
	#   returns    the graph itself, so calls chain
	#   see        StoredIn
	def AddStore(pcId)
		This._Node(pcId, "store")
		return This

	# Declares a site node, an application surface that can reference secrets.
	#
	#   pcId       the site name, lower-cased and trimmed to make the node id
	#   returns    the graph itself, so calls chain
	#   see        References
	def AddSite(pcId)
		This._Node(pcId, "site")
		return This

	# Declares a capability node, such as effectful, ahead of its first use.
	#
	#   pcId       the capability name, lower-cased and trimmed to make the node id
	#   returns    the graph itself, so calls chain
	#   note       Holds and Grants create the node themselves when it is missing
	#   see        Holds, Grants
	#@ aka  capabilities are auto-created by Holds/Grants, but may be declared too
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

	# Adds the edge by which an actor directly holds a capability.
	#
	#   pcActor        the declared actor
	#   pcCapability   the capability, created if missing
	#   returns        the graph itself, so calls chain
	#   note           an existing edge between the same two nodes is kept, so no second edge is
	#                  added
	#   warning        raises an error when the actor was not declared first
	#   see            Uses, ReachesCapability
	#@ aka  -- edges (the meaning is the label) --------------------------------
	def Holds(pcActor, pcCapability)
		This._Edge(This._Require(pcActor), This._Cap(pcCapability), "holds")
		return This

	# Adds the edge by which an actor uses a tool.
	#
	#   pcActor    the declared actor
	#   pcTool     the declared tool
	#   returns    the graph itself, so calls chain
	#   warning    raises an error when either node was not declared first
	#   see        Grants, Delegates
	#@ aka  an actor uses a tool
	def Uses(pcActor, pcTool)
		This._Edge(This._Require(pcActor), This._Require(pcTool), "uses")
		return This

	# Adds the edge by which a tool confers a capability on whoever uses it.
	#
	#   pcTool         the declared tool
	#   pcCapability   the capability, created if missing
	#   returns        the graph itself, so calls chain
	#   warning        raises an error when the tool was not declared first
	#   see            Uses, ReachesCapability
	#@ aka  a tool grants (confers) a capability
	def Grants(pcTool, pcCapability)
		This._Edge(This._Require(pcTool), This._Cap(pcCapability), "grants")
		return This

	# Adds the edge by which one actor may act as another, so trust passes along it.
	#
	#   pcFrom     the declared actor that delegates
	#   pcTo       the declared actor that it may act as
	#   returns    the graph itself, so calls chain
	#   warning    raises an error when either node was not declared first
	#   see        Uses, ReachesCapability
	#@ aka  an actor may act as another (delegation -- transitive trust)
	def Delegates(pcFrom, pcTo)
		This._Edge(This._Require(pcFrom), This._Require(pcTo), "delegates")
		return This

	# Adds the edge by which a site refers to a secret.
	#
	#   pcSite     the declared site
	#   pcSecret   the declared secret
	#   returns    the graph itself, so calls chain
	#   warning    raises an error when either node was not declared first
	#   see        StoredIn, BlastRadius
	#@ aka  a site references a secret
	def References(pcSite, pcSecret)
		This._Edge(This._Require(pcSite), This._Require(pcSecret), "references")
		return This

	# Adds the edge by which a secret lives in a store.
	#
	#   pcSecret   the declared secret
	#   pcStore    the declared store
	#   returns    the graph itself, so calls chain
	#   warning    raises an error when either node was not declared first
	#   see        References, BlastRadius
	#@ aka  a secret lives in a store
	def StoredIn(pcSecret, pcStore)
		This._Edge(This._Require(pcSecret), This._Require(pcStore), "stored_in")
		return This

	# TRUE if attaching a secret to that actor keeps the surface sound: the actor exists and was not declared sandboxed.
	#
	#   pcActor    the actor name
	#   pcSecret   the secret name, which is not looked at
	#   returns    TRUE or FALSE; FALSE for an actor that is not in the graph
	#   note       it reads the recorded posture, so editing the graph through GraphQ does not
	#              change the answer
	#   see        AttachSecret, AddActor
	#@ aka  -- the CONSTRAINT: no live secret to a sandboxed actor -------------
	def MayAttach(pcActor, pcSecret)
		_cA_ = StzLower(ring_trim("" + pcActor))
		if NOT @oG.NodeExists(_cA_)
			return 0
		ok
		return This._SealedPosture(_cA_) != "sandboxed"

	# Adds the edge by which a live secret is attached to an actor, refusing it for a sandboxed actor.
	#
	#   pcActor    the declared actor
	#   pcSecret   the declared secret
	#   returns    the graph itself, so calls chain
	#   note       the escalation never enters the graph through this door
	#   warning    raises an error for a sandboxed actor, and the refusal is noted to the security
	#              ledger as posture.refused; also raises when either node was not declared
	#   see        MayAttach, BlastRadius, Tampering
	#@ aka  Attach a secret to an actor -- the governed door. REFUSED for a sandboxed actor at construction (audit -> gate), so the escalation can never enter the graph through the sanctioned API.
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

	# TRUE if the actor can reach the effectful capability by any path: held, through a tool, or through a delegation.
	#
	#   pcActor    the actor name
	#   returns    TRUE or FALSE; FALSE for an actor that is not in the graph
	#   note       a flag check on the actor alone cannot see a path through a tool
	#   see        ReachesCapability, PathToEffectful, AuditEscalations
	#@ aka  -- queries ---------------------------------------------------------
	def ReachesEffectful(pcActor)
		return This.ReachesCapability(pcActor, "effectful")

	# TRUE if the actor can reach the named capability by any path.
	#
	#   pcActor        the actor name
	#   pcCapability   the capability name
	#   returns        TRUE or FALSE; FALSE when the actor or the capability is not in the graph
	#   see            ReachesEffectful, PathToCapability
	def ReachesCapability(pcActor, pcCapability)
		_cA_ = StzLower(ring_trim("" + pcActor))
		_cCap_ = StzLower(ring_trim("" + pcCapability))
		if NOT @oG.NodeExists(_cA_) or NOT @oG.NodeExists(_cCap_)
			return 0
		ok
		return @oG.PathExists(_cA_, _cCap_)

	# Returns the route by which the actor reaches a capability, shortest first, not just whether one exists.
	#
	#   pcActor        the actor name
	#   pcCapability   the capability name
	#   returns        a list of node names from the actor to the capability; [ ] when there is no
	#                  route or a node is unknown
	#   see            PathToEffectful, ReachesCapability, CutCapability
	#@ aka  THE PATH ITSELF, not merely whether one exists (incident I5): an investigation must be able to say HOW an actor could reach a capability -- "billing-agent -> deploy-tool -> effectful" -- and an empty list means no path.
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

	# Returns the route by which the actor reaches the effectful capability.
	#
	#   pcActor    the actor name
	#   returns    a list of node names from the actor to effectful; [ ] when there is none
	#   see        PathToCapability, AuditEscalations
	def PathToEffectful(pcActor)
		return This.PathToCapability(pcActor, "effectful")

	# Removes every path by which the actor reaches a capability, by deleting the actor own first-hop edges that lead there.
	#
	#   pcActor        the actor name
	#   pcCapability   the capability name
	#   returns        a list of [ from, label, to ] rows, the edges removed; [ ] when there was
	#                  nothing to cut
	#   note           other actors keep their own routes; a cut is noted to the ledger as
	#                  capability.revoked
	#   see            PathToCapability, ReachesCapability
	#@ aka  -- containment: cut a capability away (R10) -------------------------
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

	# Returns every node that can reach the secret, which tells what a leak of it exposes.
	#
	#   pcSecret   the secret name
	#   returns    a list of node names, the secret itself excluded; [ ] for an unknown secret
	#   note       use it to plan a rotation
	#   see        AttachSecret, References, StoredIn
	#@ aka  Every node that can REACH this secret (reverse reachability) -- the blast radius: which sites and actors a leaked secret exposes. Rotation planning.
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
	# Returns every sandboxed actor that can reach the effectful capability with its route, and records each one in the ledger.
	#
	#   returns    a list of [ actor, [ path ] ] rows
	#   note       a deliberate audit, unlike the query methods, each finding is noted as
	#              graph.escalation_path_found
	#   see        NumberOfEscalations, PathToEffectful, Violations
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

	# Returns how many sandboxed actors can reach the effectful capability.
	#
	#   returns    a number
	#   note       it runs the audit, so each finding is noted to the ledger
	#   see        AuditEscalations
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

	# Returns the rule findings of the security surface, plus one for each posture changed around the gate.
	#
	#   returns    a list of rows [ :rule, :subject, :where, :severity, :message ]; [ ] when sound
	#   see        IsSound, Tampering, AuditEscalations
	#@ aka  -- proof + internals -----------------------------------------------
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

	# TRUE if the graph breaks no security rule and no posture was changed around the gate.
	#
	#   returns    TRUE or FALSE
	#   see        Violations, Tampering
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
