# R1 -- THE KNOWLEDGE INTEGRATION (the north star's first proof)
#
# ONE default stzKnowledgeGraph stands BEHIND the natural-language sugar:
#   StzKnow("paris", "city")            -> world entity + KG fact (is-a)
#   StzKnowRelation("paris", "capital-of", "france")  -> world edge + KG fact
#   StzConstrainRelation("married-to", :Symmetric)    -> legacy law + KG law
#                                          (ontology record + stzGraphRule)
#   ? WhatIs("paris") / ? AreRelated(...)  -- unchanged surfaces
#   StzSaveKnowledgeBase("world")          -> world.stzknow  (the format)
#   StzLoadKnowledgeBase("world.stzknow")  -> KG + world re-hydrated
#   StzProve([ "piston", "part-of", "car" ]) -> STRUCTURED proof trace
#
# DESIGN: DUAL-WRITE. The legacy globals ($aStzRelations & friends) keep
# every existing behavior byte-identical; the default KG grows alongside
# as the persistable, provable, rule-governed BRAIN. The new capabilities
# (Prove, .stzknow save/load, stzGraphRule derivations) read the KG.
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 6, step R1.)

$oStzDefaultKG = NULL

func DefaultKnowledgeGraph()
	_StzDKGEnsure()
	return $oStzDefaultKG

	func DefaultKG()
		return DefaultKnowledgeGraph()

	func @DefaultKnowledgeGraph()
		return DefaultKnowledgeGraph()

func _StzDKGEnsure()
	if $oStzDefaultKG = NULL
		$oStzDefaultKG = new stzKnowledgeGraph("world")
	ok

# Add a fact to the default KG unless the very same (s, p, o) edge is
# already there (AddFact itself never dedupes edges).
# NOTE: graph node ids are SPACE-FREE by stzGraph's contract, while the
# world happily knows multi-word names ("new york", NER output). The KG
# door maps spaces to underscores -- deterministic, round-trip-stable.
func _StzDKGAddFactOnce(pcS, pcP, pcO)
	_StzDKGEnsure()
	_cS_ = StzReplace(StzLower("" + pcS), " ", "_")
	_cP_ = StzReplace(StzLower("" + pcP), " ", "_")
	_cO_ = StzReplace(StzLower("" + pcO), " ", "_")
	_aEdges_ = $oStzDefaultKG.Edges()
	_nLen_ = len(_aEdges_)
	for _i_ = 1 to _nLen_
		if _aEdges_[_i_][:from] = _cS_ and _aEdges_[_i_][:label] = _cP_ and
		   _aEdges_[_i_][:to] = _cO_
			return 0
		ok
	next
	$oStzDefaultKG.AddFact(_cS_, _cP_, _cO_)
	return 1

# Register a relation LAW on the default KG: the ontology records it
# (DefineProperty) and, where the law derives facts, a per-relation
# stzGraphRule Derivation is armed (:Symmetric). :Unique guards through
# a Constraint rule; :Transitive is a query-time closure (AreRelated and
# Prove walk it -- deliberately NOT materialized).
func StzKGConstrainRelation(pcRel, pcLaw)
	_StzDKGEnsure()
	_cR_ = StzLower(trim("" + pcRel))
	_cL_ = StzLower(trim("" + pcLaw))
	if _cR_ = "" or _cL_ = ""
		return 0
	ok
	if NOT $oStzDefaultKG.RelationHasLaw(_cR_, _cL_)
		$oStzDefaultKG.DefineProperty(_cR_, [ _cL_ ])
	ok
	if _cL_ = "symmetric"
		RegisterRule(:world, "sym_" + _cR_, [
			:type = :Derivation,
			:function = StzKGDerivationSymmetricFor(),
			:params = [ :relation = _cR_ ],
			:message = "symmetric closure of '" + _cR_ + "'",
			:severity = :info
		])
		$oStzDefaultKG.UseRulesFrom(:world)
	but _cL_ = "unique"
		RegisterRule(:world, "unq_" + _cR_, [
			:type = :Constraint,
			:function = StzKGConstraintUniqueFor(),
			:params = [ :relation = _cR_ ],
			:message = "'" + _cR_ + "' is :Unique -- one edge per subject",
			:severity = :error
		])
		$oStzDefaultKG.UseRulesFrom(:world)
	ok
	return 1

# Per-relation SYMMETRIC derivation: every a-R-b without its b-R-a
# derives the reverse edge (only for THIS relation's label).
func StzKGDerivationSymmetricFor()
	return func(oGraph, paRuleParams) {
		_cRel_ = paRuleParams[:relation]
		_aNewEdges_ = []
		_aEdges_ = oGraph.Edges()
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			_aE_ = _aEdges_[_i_]
			if _aE_[:label] = _cRel_
				_bHasReverse_ = 0
				for _j_ = 1 to _nLen_
					if _aEdges_[_j_][:from] = _aE_[:to] and
					   _aEdges_[_j_][:label] = _cRel_ and
					   _aEdges_[_j_][:to] = _aE_[:from]
						_bHasReverse_ = 1
						exit
					ok
				next
				if _bHasReverse_ = 0
					_aNewEdges_ + [ _aE_[:to], _aE_[:from], _cRel_, [ :derived = TRUE ] ]
				ok
			ok
		next
		return _aNewEdges_
	}

# Per-relation UNIQUE constraint: a subject may bear at most ONE edge of
# this relation (to one object).
func StzKGConstraintUniqueFor()
	return func(oGraph, paRuleParams, paOperationParams) {
		_cRel_ = paRuleParams[:relation]
		if HasKey(paOperationParams, :from) and HasKey(paOperationParams, :label)
			if paOperationParams[:label] = _cRel_
				_aEdges_ = oGraph.Edges()
				_nLen_ = len(_aEdges_)
				for _i_ = 1 to _nLen_
					if _aEdges_[_i_][:from] = paOperationParams[:from] and
					   _aEdges_[_i_][:label] = _cRel_ and
					   _aEdges_[_i_][:to] != paOperationParams[:to]
						return [ TRUE, "'" + paOperationParams[:from] +
							"' already bears '" + _cRel_ + "' (to '" +
							_aEdges_[_i_][:to] + "'; the relation is :Unique)" ]
					ok
				next
			ok
		ok
		return [ FALSE, "" ]
	}

# Fire the armed derivation rules on the default KG and make every
# DERIVED fact visible to the natural world too (WhatIs / RelationsOf /
# AreRelated read $aStzRelations) -- knowledge grows, no code changes.
func StzApplyKnowledgeDerivations()
	_StzDKGEnsure()
	_aRes_ = $oStzDefaultKG.ApplyDerivationRulesXT()
	_aAdded_ = _aRes_[:edgesAdded]
	_nLen_ = len(_aAdded_)
	for _i_ = 1 to _nLen_
		_StzAddRelationTriple(
			StzLower("" + _aAdded_[_i_][1]),
			_aAdded_[_i_][3],
			StzLower("" + _aAdded_[_i_][2])
		)
	next
	return _nLen_

# --- the .stzknow doors ------------------------------------------------

func StzSaveKnowledgeBase(pcFile)
	_StzDKGEnsure()
	$oStzDefaultKG.WriteToKnowFile(pcFile)
	return 1

func StzLoadKnowledgeBase(pcFile)
	_StzDKGEnsure()
	$oStzDefaultKG.ImportKnow(pcFile)
	# re-hydrate the natural world so WhatIs/AreRelated speak the domain
	_aFacts_ = $oStzDefaultKG.Facts()
	_nLen_ = len(_aFacts_)
	_nAbsorbed_ = 0
	for _i_ = 1 to _nLen_
		_cS_ = StzLower("" + _aFacts_[_i_][1])
		_cP_ = StzLower("" + _aFacts_[_i_][2])
		_cO_ = StzLower("" + _aFacts_[_i_][3])
		if _cP_ = "is-a" or _cP_ = "isa" or _cP_ = "is_a"
			StzKnow(_cS_, _cO_)
		else
			_StzAddRelationTriple(_cS_, _cP_, _cO_)
		ok
		_nAbsorbed_++
	next
	# re-arm the LAWS the file carried (ontology section): legacy rules
	# AND the KG-side stzGraphRule wiring, in one gesture
	_aOnt_ = $oStzDefaultKG.Ontology()
	_nOnt_ = len(_aOnt_)
	for _i_ = 1 to _nOnt_
		_aCons_ = _aOnt_[_i_][:constraints]
		_nC_ = len(_aCons_)
		for _j_ = 1 to _nC_
			StzConstrainRelation("" + _aOnt_[_i_][:property], "" + _aCons_[_j_])
		next
	next
	return _nAbsorbed_

# --- the proof door -----------------------------------------------------

# StzProve([ subject, relation, object ]) -> the default KG's structured
# proof trace (see stzKnowledgeGraph.Prove). Deterministic -> CERTAIN.
func StzProve(paTriple)
	_StzDKGEnsure()
	_aProof_ = $oStzDefaultKG.Prove(paTriple)
	$nStzLastCertainty = 1
	$cStzLastWhyB = _aProof_[:narration]
	return _aProof_

# Rebuild the default KG from the world when relations are forgotten
# (called by ForgetRelations -- keeps the two stores in step).
func _StzDKGRebuildFromWorld()
	$oStzDefaultKG = new stzKnowledgeGraph("world")
	_aAll_ = $oWorldEntities.Entities()
	_nAll_ = len(_aAll_)
	for _i_ = 1 to _nAll_
		_StzDKGAddFactOnce(_aAll_[_i_][:name], "is-a", _aAll_[_i_][:type])
	next
