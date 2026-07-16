func StzKnowledgeGraphQ(pcId)
	return new stzKnowledgeGraph(pcId)

	func StzKnowGraphQ(pcId)
		return new stzKnowledgeGraph(pcId)

func IsStzKnowledgeGraph(pObj)
	if isObject(pObj) and classname(pObj) = "stzknowledgegraph"
		return TRUE
	ok
	return FALSE

	func IsAStzKnowledgeGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

	func IsStzKnowGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

	func IsAStzKnowGraph(pObj)
		return IsStzKnowledgeGraph(pObj)

class stzKnowGraph from stzKnowledgeGraph
class stzKnowledgeGraph from stzGraph

	@aNamespaces = []
	@aOntology = []
	@bStrictMode = 0        # G8 seed: opt-in knowledge hygiene
	@aFactMeta = []         # provenance per fact: [ :fact, :meta ]
	@aContradictions = []   # named, NEVER silently resolved

	def init(pcId)
		super.init(pcId)
		super.SetGraphType("semantic")

		@aNamespaces = []
		@aOntology = []

	def IsKnowledgeGraph()
		return TRUE

		def IsAKnowledgeGraph()
			return TRUE

	#--------------------#
	#  TRIPLE INTERFACE  #
	#--------------------#

	def AddFact(pcSubject, pcPredicate, pcObject)
		# STRICT MODE (G8): once enabled, naked facts are refused --
		# every fact must carry provenance through AddFactXT. Enable
		# strict AFTER loading/ontology-definition (those use AddFact).
		if @bStrictMode
			stzraise("Strict mode: every fact needs provenance -- use AddFactXT(s, p, o, [ :source = ..., :confidence = ... ]).")
		ok
		This._AddFactRaw(pcSubject, pcPredicate, pcObject)

		def AddTriple(pcSubject, pcPredicate, pcObject)
			This.AddFact(pcSubject, pcPredicate, pcObject)

	#-- domain-modeling verbs (INSTANCE-scoped, chainable) --------------------
	# Build a domain knowledgebase with NO globals:
	#   oKB = new stzKnowledgeGraph("restaurant")
	#   oKB.Know("margherita", "dish").
	#       KnowRelation("margherita", "contains", "tomato-sauce").
	#       ConstrainRelation("pairs-with", :Symmetric)
	# The natural-world globals (StzKnow/StzKnowRelation) are a SEPARATE
	# feature -- the default shared world behind WhatIs/AreRelated. A scoped
	# domain (a DLM's brain, an app's world) owns its own graph instance.

	def Know(pcName, pcType)
		This.AddFact(pcName, "is-a", pcType)
		return This

		def KnowEntity(pcName, pcType)
			return This.Know(pcName, pcType)

	def KnowRelation(pcSubject, pcPredicate, pcObject)
		This.AddFact(pcSubject, pcPredicate, pcObject)
		return This

		def KnowFact(pcSubject, pcPredicate, pcObject)
			return This.KnowRelation(pcSubject, pcPredicate, pcObject)

	# Record a relation LAW on THIS graph's ontology (:Symmetric, :Unique,
	# :Transitive). Prove() reads it for transitive closure; forging a DLM
	# reads it as the domain's laws.
	def ConstrainRelation(pcRel, pcLaw)
		_cR_ = StzLower(ring_trim("" + pcRel))
		_cL_ = StzLower(ring_trim("" + pcLaw))
		if _cR_ = "" or _cL_ = ""
			return This
		ok
		if NOT This.RelationHasLaw(_cR_, _cL_)
			This.DefineProperty(_cR_, [ _cL_ ])
		ok
		return This

		def Constrain(pcRel, pcLaw)
			return This.ConstrainRelation(pcRel, pcLaw)

	def _AddFactRaw(pcSubject, pcPredicate, pcObject)
		# Facts are SET-LIKE: re-asserting a known fact is a quiet no-op
		# (R1, 2026-07-14 -- reloading a .stzknow over a live graph used
		# to die on "Edge already exists"). A DIFFERENT predicate between
		# the same pair still raises: stzGraph stores ONE edge per node
		# pair (known limitation, revisit with multi-edge support).
		_cS_ = StzLower("" + pcSubject)
		_cP_ = StzLower("" + pcPredicate)
		_cO_ = StzLower("" + pcObject)
		# (EdgeExists raises on missing nodes -- only probe when both live)
		if This.NodeExists(_cS_) and This.NodeExists(_cO_)
			if This.EdgeExists(_cS_, _cO_)
				_aEdge_ = This.Edge(_cS_, _cO_)
				if _aEdge_[:label] = _cP_
					return
				ok
				stzraise("Can't add fact: '" + _cS_ + "' and '" + _cO_ + "' already carry the edge '" + _aEdge_[:label] + "' (stzGraph stores one edge per node pair).")
			ok
		ok

		if NOT This.NodeExists(pcSubject)
			This.AddNodeXTT(pcSubject, pcSubject, [:type = "entity"])
		ok

		# Bug fix: previously the object label was @@(pcObject) which
		# wraps strings with literal quote chars ("Animals" -> '"Animals"').
		# Use the raw string so the label round-trips clean.
		if NOT This.NodeExists(pcObject)
			This.AddNodeXTT(pcObject, pcObject, [:type = "entity"])
		ok

		This.AddEdgeXTT(pcSubject, pcObject, pcPredicate, [:type = "fact"])

	# Provenance-carrying add (G8). In STRICT mode :source + :confidence
	# are MANDATORY, and a fact contradicting a :Unique law is REFUSED
	# and RECORDED as a named contradiction -- never silently resolved.
	def AddFactXT(pcSubject, pcPredicate, pcObject, paMeta)
		if @bStrictMode
			if NOT ( isList(paMeta) and HasKey(paMeta, :source) and
			         HasKey(paMeta, :confidence) )
				stzraise("Strict mode: every fact needs provenance -- AddFactXT(s, p, o, [ :source = ..., :confidence = ... ]).")
			ok
			if This.RelationHasLaw(pcPredicate, "unique")
				_cS_ = StzLower("" + pcSubject)
				_cP_ = StzLower("" + pcPredicate)
				_cO_ = StzLower("" + pcObject)
				_aEdges_ = This.Edges()
				_nLen_ = len(_aEdges_)
				for _i_ = 1 to _nLen_
					if _aEdges_[_i_][:from] = _cS_ and
					   _aEdges_[_i_][:label] = _cP_ and
					   _aEdges_[_i_][:to] != _cO_
						@aContradictions + [
							:subject = _cS_,
							:relation = _cP_,
							:existing = _aEdges_[_i_][:to],
							:attempted = _cO_,
							:source = paMeta[:source]
						]
						return 0
					ok
				next
			ok
		ok
		This._AddFactRaw(pcSubject, pcPredicate, pcObject)
		@aFactMeta + [
			:fact = [ StzLower("" + pcSubject), StzLower("" + pcPredicate),
			          StzLower("" + pcObject) ],
			:meta = paMeta
		]
		return 1

	def SetStrictMode(bOnOff)
		@bStrictMode = bOnOff

		def EnableStrictMode()
			@bStrictMode = 1

		def DisableStrictMode()
			@bStrictMode = 0

	def IsStrict()
		return @bStrictMode

	def Contradictions()
		return @aContradictions

	def FactMeta()
		return @aFactMeta

	def RemoveFact(pcSubject, pcPredicate, pcObject)
		This.RemoveThisEdge(pcSubject, pcObject)

		def RemoveTriple(pcSubject, pcPredicate, pcObject)
			This.RemoveFact(pcSubject, pcPredicate, pcObject)

	def Facts()
		_aFacts_ = []
		_aEdges_ = This.Edges()

		# Node :id is stored lowercased (stzGraph normalises for
		# case-insensitive lookup) but :label preserves the original
		# casing passed in by AddFact. We return labels so callers
		# get the same strings they put in.
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			_aEdge_ = _aEdges_[_i_]
			_cFromLabel_ = This.Node(_aEdge_[:from])[:label]
			_cToLabel_   = This.Node(_aEdge_[:to])[:label]
			_aFacts_ + [_cFromLabel_, _aEdge_[:label], _cToLabel_]
		end

		return _aFacts_

		def Triples()
			return This.Facts()

	#-------------------#
	#  QUERY INTERFACE  #
	#-------------------#

	def Query(paPattern)
		# Pattern: ["?x", :IsA, "Animals"] or ["Dogs", :Eats, "?what"]
		# stzGraph stores edge :from / :to / :label all lowercased
		# for case-insensitive matching; bound terms here have to
		# be lowercased before comparing so the user-facing pattern
		# (which uses the original casing) still matches.

		_cSubject_ = paPattern[1]
		_cPredicate_ = paPattern[2]
		_cObject_ = paPattern[3]

		_acResults_ = []
		_aEdges_ = This.Edges()
		_nLen_ = len(_aEdges_)

		_bSubjVar_ = (isString(_cSubject_) and StzLeft(_cSubject_, 1) = "?")
		_bObjVar_ = (isString(_cObject_) and StzLeft(_cObject_, 1) = "?")

		# Lowercase any bound terms once, up front. StzLower is codepoint-aware
		# (byte lower() doesn't fold multibyte case, so a 'Café' fact wouldn't
		# match a 'CAFÉ' query).
		_cSubjLow_ = ""
		if isString(_cSubject_) and NOT _bSubjVar_
			_cSubjLow_ = StzLower(_cSubject_)
		ok
		_cObjLow_ = ""
		if isString(_cObject_) and NOT _bObjVar_
			_cObjLow_ = StzLower(_cObject_)
		ok
		_cPredLow_ = _cPredicate_
		if isString(_cPredicate_)
			_cPredLow_ = StzLower(_cPredicate_)
		ok

		if _bSubjVar_ and _bObjVar_
			# Both variables: return all subject-object pairs for predicate.
			# Convert IDs back to original-case node labels.
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:label] = _cPredLow_
					_cFromLab_ = This.Node(_aEdges_[_i_][:from])[:label]
					_cToLab_   = This.Node(_aEdges_[_i_][:to])[:label]
					_acResults_ + [ _cFromLab_, _cToLab_ ]
				ok
			next

		but _bSubjVar_
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:to] = _cObjLow_ and _aEdges_[_i_][:label] = _cPredLow_
					_cFromLab_ = This.Node(_aEdges_[_i_][:from])[:label]
					if StzFindFirst(_acResults_, _cFromLab_) = 0
						_acResults_ + _cFromLab_
					ok
				ok
			next

		but _bObjVar_
			for _i_ = 1 to _nLen_
				if _aEdges_[_i_][:from] = _cSubjLow_ and _aEdges_[_i_][:label] = _cPredLow_
					_cToLab_ = This.Node(_aEdges_[_i_][:to])[:label]
					if StzFindFirst(_acResults_, _cToLab_) = 0
						_acResults_ + _cToLab_
					ok
				ok
			next
			
		else
			# Both bound - check existence
			if This.EdgeExists(_cSubject_, _cObject_)
				_aEdge_ = This.Edge(_cSubject_, _cObject_)
				if _aEdge_[:label] = _cPredicate_
					return TRUE
				ok
			ok
			return FALSE
		ok
		
		return _acResults_

	def QueryPath(paaPatterns)
		# Multi-hop: [["?x", :IsA, "Animals"], ["?x", :Eats, "?food"]]
		
		if len(paaPatterns) = 0
			return []
		ok
		
		# Execute first pattern
		_aResults_ = This.Query(paaPatterns[1])
		
		# For multi-pattern queries, would need variable binding logic
		# Basic implementation returns first pattern results
		
		return _aResults_

	#-------------------#
	#  ENTITY ANALYSIS  #
	#-------------------#

	def Predicates(pcEntity)
		# Edge :from / :label are stored lowercased; lowercase the
		# query term once so case-insensitive lookups still match.
		_cPenE_ = StzLower(pcEntity)
		_acPredicates_ = []
		_aEdges_ = This.Edges()

		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = _cPenE_
				if StzFindFirst(_acPredicates_, _aEdges_[_i_][:label]) = 0
					_acPredicates_ + _aEdges_[_i_][:label]
				ok
			ok
		next

		return _acPredicates_

		def PredicatesOf(pcEntity)
			return This.Predicates(pcEntity)

	def Relations(pcEntity)
		_cRelE_ = StzLower(pcEntity)
		_aRelations_ = []
		_aEdges_ = This.Edges()

		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = _cRelE_
				# Recover the to-node's original-case label.
				_cToLab_ = This.Node(_aEdges_[_i_][:to])[:label]
				_aRelations_ + [_aEdges_[_i_][:label], _cToLab_]
			ok
		next

		return _aRelations_

		def RelationsOf(pcEntity)
			return This.Relations(pcEntity)

	def SimilarTo(pcEntity)
		_aMyPredicates_ = This.Predicates(pcEntity)
		_cSimE_ = StzLower(pcEntity)
		_acSimilar_ = []
		_aNodes_ = This.Nodes()

		_nNodeLen_ = len(_aNodes_)
		for _i_ = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[_i_][:id]

			if _cNodeId_ != _cSimE_
				_aTheirPredicates_ = This.Predicates(_cNodeId_)
				_nOverlap_ = 0

				_nMyLen_ = len(_aMyPredicates_)
				for _j_ = 1 to _nMyLen_
					if StzFindFirst(_aTheirPredicates_, _aMyPredicates_[_j_]) > 0
						_nOverlap_++
					ok
				next

				if _nOverlap_ > 0
					# Use the node's original-case label.
					_cNodeLab_ = _aNodes_[_i_][:label]
					_acSimilar_ + [_cNodeLab_, _nOverlap_]
				ok
			ok
		next

		return _acSimilar_

		def SimilarEntities(pcEntity)
			return This.SimilarTo(pcEntity)

	#--------------------#
	#  ONTOLOGY SUPPORT  #
	#--------------------#

	def DefineClass(pcClass, pcSuperClass)
		This.AddFact(pcClass, :SubClassOf, pcSuperClass)

	def DefineProperty(pcProperty, paConstraints)
		@aOntology + [
			:property = pcProperty,
			:constraints = paConstraints
		]

	def Ontology()
		return @aOntology

	def ValidateOntology()
		# Basic validation - checks if defined properties are used consistently
		return TRUE

	# Does the ontology declare this LAW for this relation?
	# (Laws land here through DefineProperty(rel, [ law ]) -- the R1
	# home of :unique / :symmetric / :transitive.)
	def RelationHasLaw(pcRel, pcLaw)
		_cR_ = StzLower("" + pcRel)
		_cL_ = StzLower("" + pcLaw)
		_nLen_ = len(@aOntology)
		for _i_ = 1 to _nLen_
			if StzLower("" + @aOntology[_i_][:property]) = _cR_
				_aCons_ = @aOntology[_i_][:constraints]
				_nC_ = len(_aCons_)
				for _j_ = 1 to _nC_
					if StzLower("" + _aCons_[_j_]) = _cL_
						return TRUE
					ok
				next
			ok
		next
		return FALSE

	#-----------------------------------------------#
	#  PROOF (G4 seed: structured derivation trace)  #
	#-----------------------------------------------#

	# Prove([ subject, relation, object ]) -> a STRUCTURED, replayable
	# proof: [ :verdict, :goal, :steps, :narration, :certainty ].
	# Each step: [ :kind ("fact"|"law"|"chain-link"), :fact, :narration ].
	# Deterministic over recorded facts + declared laws, so certainty
	# is 1 WHATEVER the verdict (a certain no is still certain, LAW 3).
	def Prove(paPattern)
		_cS_ = StzLower("" + paPattern[1])
		_cP_ = StzLower("" + paPattern[2])
		_cO_ = StzLower("" + paPattern[3])
		_aSteps_ = []

		# 1. a direct recorded fact proves the goal in one step
		_aEdges_ = This.Edges()
		_nLen_ = len(_aEdges_)
		for _i_ = 1 to _nLen_
			if _aEdges_[_i_][:from] = _cS_ and _aEdges_[_i_][:label] = _cP_ and
			   _aEdges_[_i_][:to] = _cO_
				_aSteps_ + [ :kind = "fact", :fact = [ _cS_, _cP_, _cO_ ],
					:narration = "recorded fact: '" + _cS_ + "' " + _cP_ +
					" '" + _cO_ + "'" ]
				return [ :verdict = TRUE, :goal = [ _cS_, _cP_, _cO_ ],
					:steps = _aSteps_, :narration = "proved: direct fact",
					:certainty = 1 ]
			ok
		next

		# 2. a lawful TRANSITIVE chain proves it link by link
		if This.RelationHasLaw(_cP_, "transitive")
			_acChain_ = This._ProveChainNodes(_cP_, _cS_, _cO_)
			_nC_ = len(_acChain_)
			if _nC_ > 1
				_aSteps_ + [ :kind = "law", :fact = [ _cP_, "is", "transitive" ],
					:narration = "law: '" + _cP_ + "' is :Transitive" ]
				for _i_ = 1 to _nC_ - 1
					_aSteps_ + [ :kind = "chain-link",
						:fact = [ _acChain_[_i_], _cP_, _acChain_[_i_ + 1] ],
						:narration = "recorded fact: '" + _acChain_[_i_] + "' " +
						_cP_ + " '" + _acChain_[_i_ + 1] + "'" ]
				next
				return [ :verdict = TRUE, :goal = [ _cS_, _cP_, _cO_ ],
					:steps = _aSteps_,
					:narration = "proved: " + JoinXT(_acChain_, " " + _cP_ + " "),
					:certainty = 1 ]
			ok
		ok

		return [ :verdict = FALSE, :goal = [ _cS_, _cP_, _cO_ ], :steps = [],
			:narration = "not derivable: no recorded fact or lawful chain gives '" +
			_cS_ + "' " + _cP_ + " '" + _cO_ + "'",
			:certainty = 1 ]

	# BFS over pcRel-labeled edges from pcFrom toward pcTo (depth-capped);
	# the node chain [ from, ..., to ] or [] when no path exists.
	def _ProveChainNodes(pcRel, pcFrom, pcTo)
		_aFront_ = []
		_aSeed_ = [ pcFrom ]
		_aFront_ + _aSeed_
		_acSeen_ = [ pcFrom ]
		_nDepth_ = 0
		_aEdges_ = This.Edges()
		_nE_ = len(_aEdges_)
		while len(_aFront_) > 0 and _nDepth_ < 16
			_nDepth_++
			_aNext_ = []
			_nF_ = len(_aFront_)
			for _f_ = 1 to _nF_
				_aPath_ = _aFront_[_f_]
				_cNode_ = _aPath_[len(_aPath_)]
				for _i_ = 1 to _nE_
					if _aEdges_[_i_][:from] = _cNode_ and _aEdges_[_i_][:label] = pcRel
						_cTo_ = _aEdges_[_i_][:to]
						_aNew_ = _aPath_
						_aNew_ + _cTo_
						if _cTo_ = pcTo
							return _aNew_
						ok
						if ring_find(_acSeen_, _cTo_) = 0
							_acSeen_ + _cTo_
							_aNext_ + _aNew_
						ok
					ok
				next
			next
			_aFront_ = _aNext_
		end
		return []

	#---------------------------#
	#  KNOWLEDGE GRAPH EXPLAIN  #
	#---------------------------#

	def Explain()
		_aExplanation_ = [
			:type = "Knowledge Graph",
			:structure = "",
			:facts = [],
			:entities = [],
			:predicates = [],
			:ontology = [],
			:patterns = [],
			:insights = []
		]
		
		# Structure overview
		_nNodes_ = This.NodeCount()
		_nEdges_ = This.EdgeCount()
		_nFacts_ = len(This.Facts())
		_aExplanation_[:structure] = 'Knowledge graph "' + @cId + '" contains ' + 
		                           _nNodes_ + " entities and " + _nFacts_ + " facts."
		
		# Facts analysis
		_aFacts_ = This.Facts()
		if len(_aFacts_) > 0
			_nSample_ = min([5, len(_aFacts_)])
			for i = 1 to _nSample_
				_aFact_ = _aFacts_[i]
				_aExplanation_[:facts] + (_aFact_[1] + " " + _aFact_[2] + " " + _aFact_[3])
			end
			if len(_aFacts_) > 5
				_aExplanation_[:facts] + ("... and " + (len(_aFacts_) - 5) + " more facts")
			ok
		else
			_aExplanation_[:facts] + "No facts defined yet"
		ok
		
		# Entity analysis
		_aNodes_ = This.Nodes()
		_acEntities_ = []
		_nNodeLen_ = len(_aNodes_)
		for i = 1 to _nNodeLen_
			if HasKey(_aNodes_[i]["properties"], "type")
				if _aNodes_[i]["properties"]["type"] = "entity"
					_acEntities_ + _aNodes_[i]["id"]
				ok
			ok
		end
		
		if len(_acEntities_) > 0
			_nSample_ = min([10, len(_acEntities_)])
			_cEntityList_ = ""
			for i = 1 to _nSample_
				_cEntityList_ += _acEntities_[i]
				if i < _nSample_ _cEntityList_ += ", " ok
			end
			_aExplanation_[:entities] + ("Entities: " + _cEntityList_)
			if len(_acEntities_) > 10
				_aExplanation_[:entities] + ("... and " + (len(_acEntities_) - 10) + " more")
			ok
		ok
		
		# Predicate analysis
		_acAllPredicates_ = []
		_aEdges_ = This.Edges()
		_nEdgeLen_ = len(_aEdges_)
		for i = 1 to _nEdgeLen_
			_cPred_ = _aEdges_[i][:label]
			if _cPred_ != "" and StzFindFirst(_acAllPredicates_, _cPred_) = 0
				_acAllPredicates_ + _cPred_
			ok
		end
		
		if len(_acAllPredicates_) > 0
			_aExplanation_[:predicates] + ("Predicates used: " + JoinXT(_acAllPredicates_, ", "))
		ok
		
		# Ontology status
		if len(@aOntology) > 0
			_aExplanation_[:ontology] + ("Ontology defined with " + len(@aOntology) + " constraints")
			_nOntLen_ = len(@aOntology)
			for i = 1 to _nOntLen_
				if HasKey(@aOntology[i], :property)
					_aExplanation_[:ontology] + ("Property: " + @aOntology[i][:property])
				ok
			end
		else
			_aExplanation_[:ontology] + "No formal ontology defined"
		ok
		
		# Pattern detection
		_nMaxConnections_ = 0
		_cMostConnected_ = ""
		for i = 1 to _nNodeLen_
			_cNodeId_ = _aNodes_[i]["id"]
			_nConnections_ = len(This.Predicates(_cNodeId_))
			if _nConnections_ > _nMaxConnections_
				_nMaxConnections_ = _nConnections_
				_cMostConnected_ = _cNodeId_
			ok
		end
		
		if _cMostConnected_ != ""
			_aExplanation_[:patterns] + ("Most connected entity: " + _cMostConnected_ + 
			                           " (" + _nMaxConnections_ + " relationships)")
		ok
		
		# Density
		_nDensity_ = This.NodeDensity()
		if _nDensity_ < 25
			_aExplanation_[:patterns] + ("Graph is sparse (" + _nDensity_ + "% density)")
		but _nDensity_ > 75
			_aExplanation_[:patterns] + ("Graph is highly connected (" + _nDensity_ + "% density)")
		else
			_aExplanation_[:patterns] + ("Moderate connectivity (" + _nDensity_ + "% density)")
		ok
		
		# Insights
		if This.CyclicDependencies()
			_aExplanation_[:insights] + "Contains circular relationships (cycles detected)"
		else
			_aExplanation_[:insights] + "Acyclic structure (no circular dependencies)"
		ok
		
		# Inferred knowledge
		if This.ApplyInference() > 0
			_aExplanation_[:insights] + "Inference rules generated new knowledge"
		ok
		
		if len(_acAllPredicates_) < 3
			_aExplanation_[:insights] + "Limited relationship types - consider enriching the ontology"
		ok
		
		if _nDensity_ < 10 and _nNodes_ > 5
			_aExplanation_[:insights] + "Many isolated entities - may need more connections"
		ok
		
		return _aExplanation_

	#----------------------------------#
	#  MANAGING *.zknw file format     #
	#  (legacy .stzknow still READS)  #
	#----------------------------------#

	def ImportKnow(pSource)
	    if isString(pSource)
	        if StzRight(pSource, 5) = ".zknw" or StzRight(pSource, 8) = ".stzknow"
	            _oParser_ = new stzKnowParser()
	            _oLoaded_ = _oParser_.ParseFile(pSource)
	        else
	            _oParser_ = new stzKnowParser()
	            _oLoaded_ = _oParser_.Parse(pSource)
	        ok
	        This._MergeKnowledgeBase(_oLoaded_)
	    ok
	
	    def LoadKnow(pSource)
		return This.ImportKnow(pSource)

	def ExportToKnow()
	    _cKnow_ = 'knowledge "' + @cId + '"' + NL + NL
	    _cKnow_ += "facts" + NL
	    _aFacts_ = This.Facts()
	    _nFacts2Len_ = len(_aFacts_)
	    for _iLoopFacts2_ = 1 to _nFacts2Len_
	    	_aFact_ = _aFacts_[_iLoopFacts2_]
	        _cKnow_ += "    " + _aFact_[1] + " | " + _aFact_[2] + " | " + _aFact_[3] + NL
	    end
	    # the LAWS travel with the knowledge (R1: ontology section --
	    # "relation | law" lines; the parser re-arms them on load)
	    if len(@aOntology) > 0
	        _cKnow_ += NL + "ontology" + NL
	        _nOnt1Len_ = len(@aOntology)
	        for _iLoopOnt1_ = 1 to _nOnt1Len_
	            _aCons_ = @aOntology[_iLoopOnt1_][:constraints]
	            _nCons1Len_ = len(_aCons_)
	            for _jLoopCons1_ = 1 to _nCons1Len_
	                _cKnow_ += "    " + @aOntology[_iLoopOnt1_][:property] +
	                           " | " + _aCons_[_jLoopCons1_] + NL
	            next
	        next
	    ok
	    return _cKnow_
	
	def WriteToKnowFile(pcFilename)
	    if StzRight(pcFilename, 5) != ".zknw"
	        pcFilename += ".zknw"
	    ok
	    write(pcFilename, This.ExportToKnow())
	
	    def WriteKnowFile(pcFileName)
		This.WriteToKnowFile(pcFilename)

	def _MergeKnowledgeBase(oOther)
	    _aFacts_ = oOther.Facts()
	    _nFacts1Len_ = len(_aFacts_)
	    for _iLoopFacts1_ = 1 to _nFacts1Len_
	    	_aFact_ = _aFacts_[_iLoopFacts1_]
	        This.AddFact(_aFact_[1], _aFact_[2], _aFact_[3])
	    end
	    # the ontology (laws) merges too -- deduped per (property, law)
	    _aOnt_ = oOther.Ontology()
	    _nOnt2Len_ = len(_aOnt_)
	    for _iLoopOnt2_ = 1 to _nOnt2Len_
	        _aCons_ = _aOnt_[_iLoopOnt2_][:constraints]
	        _nCons2Len_ = len(_aCons_)
	        for _jLoopCons2_ = 1 to _nCons2Len_
	            if NOT This.RelationHasLaw("" + _aOnt_[_iLoopOnt2_][:property], "" + _aCons_[_jLoopCons2_])
	                This.DefineProperty(_aOnt_[_iLoopOnt2_][:property], [ _aCons_[_jLoopCons2_] ])
	            ok
	        next
	    next

class stzKnowParser from stzObject
    def init()
        # stateless parser; shields stzObject's 1-arg init so
        # `new stzKnowParser()` works (R1 fix, 2026-07-14 -- the
        # ImportKnow path was dead with R19 before this)

    def ParseFile(pcFilename)
        _cContent_ = read(pcFilename)
        return This.Parse(_cContent_)
    
    def Parse(pcContent)
        _oKG_ = NULL
        _acLines_ = split(pcContent, NL)
        _cSection_ = ""
        
        _nAcLines1Len_ = len(_acLines_)
        for _iLoopAcLines1_ = 1 to _nAcLines1Len_
        	_cLine_ = _acLines_[_iLoopAcLines1_]
            _cLine_ = trim(_cLine_)
            if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
                loop
            ok
            
            if StzFindFirst(_cLine_, "knowledge ")
                _cId_ = This._ExtractQuoted(_cLine_)
                _oKG_ = new stzKnowledgeGraph(_cId_)
            
            but _cLine_ = "namespaces"
                _cSection_ = "namespaces"
            but _cLine_ = "ontology"
                _cSection_ = "ontology"
            but _cLine_ = "facts"
                _cSection_ = "facts"
            but _cLine_ = "rules"
                _cSection_ = "rules"
            
            but _cSection_ = "facts" and StzFindFirst(_cLine_, "|")
                _aParts_ = split(_cLine_, "|")
                if len(_aParts_) = 3
                    _oKG_.AddFact(trim(_aParts_[1]), trim(_aParts_[2]), trim(_aParts_[3]))
                ok

            but _cSection_ = "ontology" and StzFindFirst(_cLine_, "|")
                _aParts_ = split(_cLine_, "|")
                if len(_aParts_) = 2
                    _oKG_.DefineProperty(trim(_aParts_[1]), [ trim(_aParts_[2]) ])
                ok
            ok
        end
        
        return _oKG_
    
    def _ExtractQuoted(_cLine_)
        _nStart_ = StzFindFirst(_cLine_, '"')
        if _nStart_ = 0 return "" ok
        _nEnd_ = StzMid(_cLine_, _nStart_ + 1, StzLen(_cLine_) - _nStart_)
        _nEnd_ = StzFindFirst(_nEnd_, '"')
        return StzMid(_cLine_, _nStart_ + 1, _nEnd_ - 1)
