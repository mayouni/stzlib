#====================================================================#
#  STZSERVICERULE / STZSERVICERULESET -- service rules over a graph      #
#====================================================================#

/*--- Phase 7: the constraint rules, and a deliberately SMALL rule set.

The registry already checks its own five invariants, and its findings carry the
shared report's shape, so bringing the external surface into the ONE CI gate needs
no rules at all:

    oReport = new stzRuleReport("ci")
    oReport.IngestLegacy(oReg.Findings(), "services")     # that is the whole join

So this file does NOT restate those five as graph rules. Restating a rule is how
two copies of it drift apart, and the registry's version is the one the deploy
door actually consults.

What a GRAPH adds is the question none of the flag checks can ask, because it
spans two models that do not know about each other:

  **which PART of my solution depends on a fake?**

The registry knows services and postures but has never heard of parts. stzDelivery
knows parts and sites but does not judge postures. Join them --
`stzDelivery.AsRuleGraph()` emits `part:` nodes with a `destination`, `service:`
nodes with a `posture`, and a `depends-on` edge between them -- and the answer
falls out of one hop:

  production-part-uses-sandbox (ERROR) -- a part bound to a real SITE depends on a
    service that is still a double. Names the PART, so you learn which piece of the
    solution cannot ship, not merely which service is fake.
  production-part-uses-ephemeral (ERROR) -- the same part depends on a store that
    is real until the next restart (the in-memory case).
  part-uses-undeclared-service (WARN) -- a part declares a need the registry has
    never heard of, so nothing will resolve it at run time. The registry cannot
    see this: the dependency exists only in the delivery model.

AND THE TIMING IS THE POINT. The registry reports sandbox-in-production only once
its phase IS production -- correct for it, useless for planning. These rules read a
part's DESTINATION instead, so they fire while the phase is still :development:
"if I shipped this part today, would it be fake?" That is the rehearsal the plane
is built around, one step earlier than the gate.

stzServiceRule IS-A stzGraphRule; the set IS-A stzGraphRuleSet -- so these findings
land in the same stzRuleReport as the code, agent, security, workflow and orgchart
domains.
*/

func StzServiceRuleQ(pcName)
	return new stzServiceRule(pcName)

func StzServiceRuleSetQ()
	return new stzServiceRuleSet()

# Run the set over a delivery (or any graph carrying part/service nodes) and
# return unified findings.
#
# NOTE the two temporaries. Written inline as
# `_oSet_.Check( poDelivery.AsRuleGraph() )` this raises R3 "Calling Function
# without definition: _iswellformedid" from deep inside stzGraph.SetNodeProperty --
# building a graph while that graph is being evaluated as another method's ARGUMENT
# breaks bare-name resolution in the nested frame. AsRuleGraph() called on its own
# line is fine. Same family as the known `new X(...).Method()` R13 trap: in Ring,
# give a nested method call its own statement.
func StzCheckServiceDelivery(poDelivery)
	_oG_ = poDelivery.AsRuleGraph()
	_oSet_ = new stzServiceRuleSet()
	return _oSet_.Check(_oG_)


# Walk part -> service edges and report the parts whose service carries a given
# property value. Shared by all three rules, so the traversal exists once.
#
# Rules 1 and 2 additionally require the part to be destined for production;
# rule 3 applies whatever the destination, which is why the flag is derived from
# the property being asked about rather than passed in.
# THE THREE POPULATIONS THIS DOMAIN REASONS ABOUT, named once so the
# rules can declare them instead of each re-deriving them -- and so that
# "every part" and "every production part" are two names a reader can
# tell apart rather than one boolean computed from a value string.
func _StzServiceAllParts(poGraph)
	_r_ = []
	_a_ = poGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		if StzLower("" + poGraph.NodeProperty(_a_[_i_], "kind")) != "part"
			loop
		ok
		_r_ + ("part:" + StzLower("" + _a_[_i_]))
	next
	return _r_

func _StzServiceProductionParts(poGraph)
	_r_ = []
	_a_ = poGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		if StzLower("" + poGraph.NodeProperty(_a_[_i_], "kind")) != "part"
			loop
		ok
		if StzLower("" + poGraph.NodeProperty(_a_[_i_], "destination")) !=
		   "production"  loop  ok
		_r_ + ("part:" + StzLower("" + _a_[_i_]))
	next
	return _r_

func _StzServiceNonProductionParts(poGraph)
	_r_ = []
	_a_ = poGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		if StzLower("" + poGraph.NodeProperty(_a_[_i_], "kind")) != "part"
			loop
		ok
		if StzLower("" + poGraph.NodeProperty(_a_[_i_], "destination")) =
		   "production"  loop  ok
		_r_ + ("part:" + StzLower("" + _a_[_i_]))
	next
	return _r_

func _StzServicePartsDependingOn(poGraph, pcProp, pValue, pcMid, pcTail)
	_aOut_ = []
	_bProdOnly_ = ("" + pValue) != "undeclared"
	_aIds_ = poGraph.NodesIds()
	_n_ = len(_aIds_)
	for _i_ = 1 to _n_
		if StzLower("" + poGraph.NodeProperty(_aIds_[_i_], "kind")) != "part"
			loop
		ok
		if _bProdOnly_ and
		   StzLower("" + poGraph.NodeProperty(_aIds_[_i_], "destination")) != "production"
			loop
		ok
		_aNb_ = poGraph.Neighbors(_aIds_[_i_])
		_m_ = len(_aNb_)
		for _k_ = 1 to _m_
			_svc_ = "" + _aNb_[_k_]
			if StzLower("" + poGraph.NodeProperty(_svc_, "kind")) != "service"
				loop
			ok
			_v_ = poGraph.NodeProperty(_svc_, pcProp)
			_bHit_ = 0
			if isString(pValue)
				if StzLower("" + _v_) = StzLower("" + pValue)
					_bHit_ = 1
				ok
			else
				if _v_ = pValue
					_bHit_ = 1
				ok
			ok
			if _bHit_
				_aOut_ + [ :where = "" + poGraph.NodeProperty(_aIds_[_i_], "part"),
				           :message = "part '" + poGraph.NodeProperty(_aIds_[_i_], "part") +
				           "' " + pcMid + poGraph.NodeProperty(_svc_, "service") + pcTail ]
			ok
		next
	next
	return _aOut_


class stzServiceRule from stzGraphRule
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("services")


class stzServiceRuleSet from stzGraphRuleSet

	def init()
		super.init("service-invariants")
		This.SetDomainQ("services")
		This._LoadServiceRules()

	def _LoadServiceRules()

		# 1. THE HEADLINE: a part destined for a real site depends on a fake.
		#    One hop, but neither model can take it alone.
		_oR1_ = new stzServiceRule("production-part-uses-sandbox")
		_oR1_.SetSeverityQ("error")
		_oR1_.SetMessageQ("a part destined for production must not depend on a sandboxed service")
		# PARTS DESTINED FOR PRODUCTION. A part bound for staging may
		# depend on a double quite legitimately -- that is what a double
		# is for -- so it is outside this rule, not compliant with it.
		# The difference matters at a release gate: "no production part
		# touches a sandbox" and "nothing here is going to production"
		# are the two answers, and they were one answer.
		_oR1_.SetOrderQ(10)
		_oR1_.SetReadsQ([ "node.kind", "node.destination", "graph.edges" ])
		_oR1_.GovernsQ(func oGraph { return _StzServiceProductionParts(oGraph) })
		_oR1_.ExcludesQ(func oGraph { return _StzServiceNonProductionParts(oGraph) })
		_oR1_.UseCheckerQ(func oGraph {
			return _StzServicePartsDependingOn(oGraph, "posture", "sandbox",
			       "is destined for production but depends on '",
			       "', which is still a DOUBLE -- flip it to a real binding first")
		})
		This.AddRule(_oR1_)

		# 2. the same shape for a store that empties on restart
		_oR2_ = new stzServiceRule("production-part-uses-ephemeral")
		_oR2_.SetSeverityQ("error")
		_oR2_.SetMessageQ("a part destined for production must not depend on an ephemeral store")
		# The same population as the rule above, asking about a different
		# property of what it depends on. Sharing a subject is correct
		# here and the governance is told so.
		_oR2_.SetOrderQ(20)
		_oR2_.SetReadsQ([ "node.kind", "node.destination", "graph.edges" ])
		_oR2_.GovernsQ(func oGraph { return _StzServiceProductionParts(oGraph) })
		_oR2_.ExcludesQ(func oGraph { return _StzServiceNonProductionParts(oGraph) })
		_oR2_.UseCheckerQ(func oGraph {
			return _StzServicePartsDependingOn(oGraph, "ephemeral", 1,
			       "is destined for production but depends on '",
			       "', which is real only until the next restart")
		})
		This.AddRule(_oR2_)

		# 3. a part needs something the registry never heard of -- invisible to the
		#    registry, because the dependency exists only in the delivery model.
		_oR3_ = new stzServiceRule("part-uses-undeclared-service")
		_oR3_.SetSeverityQ("warning")
		_oR3_.SetMessageQ("a part depends on a service that is not declared in the registry")
		# EVERY PART, WHATEVER ITS DESTINATION -- and this rule is the
		# reason the scope is worth declaring at all. The shared checker
		# selects its population from a BOOLEAN derived from the value
		# being matched:
		#
		#     _bProdOnly_ = ("" + pValue) != "undeclared"
		#
		# So "which parts do I govern" is decided by "what string am I
		# looking for", and the two have nothing to do with each other.
		# It is correct today and it is correct by coincidence: a fourth
		# rule matching the value "undeclared" on some other property
		# would silently inherit the wider population, and a rule that
		# genuinely wanted every part would have to spell its value
		# "undeclared" to get one.
		#
		# Declared here, the distinction is a statement instead of a
		# side effect, and the next rule added has to say which it means.
		_oR3_.SetOrderQ(30)
		_oR3_.SetReadsQ([ "node.kind", "graph.edges" ])
		_oR3_.GovernsQ(func oGraph { return _StzServiceAllParts(oGraph) })
		_oR3_.ExcludesQ(func oGraph {
			_r_ = []
			_a_ = oGraph.NodesIds()
			for _i_ = 1 to len(_a_)
				if StzLower("" + oGraph.NodeProperty(_a_[_i_], "kind")) = "part"
					loop
				ok
				_r_ + ("node:" + StzLower("" + _a_[_i_]))
			next
			return _r_
		})
		_oR3_.UseCheckerQ(func oGraph {
			return _StzServicePartsDependingOn(oGraph, "posture", "undeclared",
			       "depends on '",
			       "', which the registry does not declare -- nothing will resolve it at run time")
		})
		This.AddRule(_oR3_)
