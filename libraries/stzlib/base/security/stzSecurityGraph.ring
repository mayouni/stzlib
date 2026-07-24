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
	@oG = NULL

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
		@oG.SetNodeProperty(_cId_, "posture", StzLower(ring_trim("" + pcPosture)))
		return This

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
			return FALSE
		ok
		return StzLower("" + @oG.NodeProperty(_cA_, "posture")) != "sandboxed"

	# Attach a secret to an actor -- the governed door. REFUSED for a sandboxed
	# actor at construction (audit -> gate), so the escalation can never enter
	# the graph through the sanctioned API.
	def AttachSecret(pcActor, pcSecret)
		_cA_ = This._Require(pcActor)
		_cS_ = This._Require(pcSecret)
		if StzLower("" + @oG.NodeProperty(_cA_, "posture")) = "sandboxed"
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
			return FALSE
		ok
		return @oG.PathExists(_cA_, _cCap_)

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

	  #-- proof + internals -----------------------------------------------

	def Violations()
		return StzSecurityRuleSetQ().Check(@oG)

	def IsSound()
		return StzSecurityRuleSetQ().IsSound(@oG)

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
