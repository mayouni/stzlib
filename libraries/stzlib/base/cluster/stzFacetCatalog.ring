# base/cluster/stzFacetCatalog.ring
# -----------------------------------------------------------------------------
# R8 (the SCALE plane) -- stzFacetCatalog: the COMPETENCE REGISTRY.
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7, the facet naming law.)
#
# A facet is a LOGICAL competence a cluster specializes and routes along
# (NOT a physical module -- see the naming law). The catalog is the set
# of facets a given deployment knows. It is deliberately an OBJECT, not a
# global table: a catalog belongs to the stzWorkerPool / stzAppCluster
# INSTANCE that owns it, so TWO clusters deployed in one process are
# INDEPENDENT and each may define its own facets (a custom :audio, a
# subset, different budgets). A fresh catalog is seeded with the standard
# Softanza facets; Define/DefinePolyglot/Drop customize it per instance.
#
#   oCat = new stzFacetCatalog()          # seeded with the standard facets
#   oCat.CapabilitiesOf(:graph)           # [ :paths, :centrality, ... ]
#   oCat.ModulesOf(:knowledge)            # [ "natural", "graph" ] (provenance)
#   oCat.MappingKindOf(:vision)           # :external (polyglot, no module)
#   oCat.Define(:audio, [ :transcribe ], [ ])         # a custom logical facet
#   oCat.DefinePolyglot(:pdf, [ :extract ], "python") # a custom external facet
#
# Facet record: [ name, [ capabilities ], [ realizing modules ], tool ]
# where tool = "" is engine-native and tool != "" is a polyglot facet
# (run off-process via the reactor's async spawn).
# -----------------------------------------------------------------------------

func StzFacetCatalogQ()
	return new stzFacetCatalog()

class stzFacetCatalog from stzObject

	@aFacets = []      # [ [ name, [caps], [modules], tool ], ... ]

	def init()
		This._SeedStandard()

	#-- the standard Softanza facets (the resident engine's competences) ---
	# A FACET IS NOT A MODULE: the 3rd column records the OPTIONAL, MANY-TO-
	# MANY facet->module provenance (never forced 1:1). Grounded (:data 1:1),
	# composed (:math/:knowledge 1:n), external (:vision polyglot, 1:0),
	# logical (a competence with no module). The nlp/ folder was DELETED by
	# ruling, yet :nlp is a real competence realized by natural + neural.
	def _SeedStandard()
		@aFacets = [
			[ :text,      [ :transform, :find, :match, :case, :split, :unicode ], [ "string", "char", "text" ], "" ],
			[ :list,      [ :sort, :filter, :map, :reduce, :setops, :dedup ], [ "list" ], "" ],
			[ :table,     [ :query, :aggregate, :join, :pivot, :wrangle ], [ "table", "datawrangler" ], "" ],
			[ :number,    [ :arith, :convert, :format, :sequence ], [ "number" ], "" ],
			[ :math,      [ :matrix, :optimize, :stats, :solve, :ggml ], [ "matrix", "stats", "number" ], "" ],
			[ :graph,     [ :paths, :centrality, :planner, :rules, :orgchart ], [ "graph" ], "" ],
			[ :knowledge, [ :facts, :derive, :prove, :query, :ontology ], [ "natural", "graph" ], "" ],
			[ :nlp,       [ :sentiment, :entities, :classify, :summarize, :translate, :pos, :lemmatize ], [ "natural", "neural" ], "" ],
			[ :neural,    [ :embed, :generate, :zeroshot, :rerank, :dlm ], [ "neural" ], "" ],
			[ :learning,  [ :train, :knn, :bayes, :tfidf, :kmeans, :apriori ], [ "learning" ], "" ],
			[ :search,    [ :index, :similarity, :rank, :semantic ], [ "neural", "graph", "data" ], "" ],
			[ :datetime,  [ :date, :duration, :calendar, :timezone ], [ "datetime", "date", "calendar", "duration" ], "" ],
			[ :reactive,  [ :stream, :watch, :timer, :debounce ], [ "reactive" ], "" ],
			[ :agentic,   [ :perceive, :plan, :act, :govern ], [ "agentic" ], "" ],
			[ :refine,    [ :propose, :cascade, :revert ], [ "refine" ], "" ],
			[ :code,      [ :codegraph, :impact, :polyglotgraph ], [ "meta", "reflect" ], "" ],
			[ :data,      [ :crud, :persist, :sqlite ], [ "data" ], "" ],
			[ :vision,    [ :ocr, :image ], [], "python" ]    # the ONLY standard polyglot facet
		]

	#-- customization (per-instance) ---------------------------------------

	# Add or override an engine-native facet (caps + optional provenance).
	def Define(pcName, paCaps, paModules)
		This._Put(StzLower("" + pcName), paCaps, paModules, "")
		return This

	# Add or override a POLYGLOT facet (served by an external tool off-
	# process; no engine module).
	def DefinePolyglot(pcName, paCaps, pcTool)
		This._Put(StzLower("" + pcName), paCaps, [], "" + pcTool)
		return This

	def Drop(pcName)
		_c_ = StzLower("" + pcName)
		for _i_ = len(@aFacets) to 1 step -1
			if StzLower("" + @aFacets[_i_][1]) = _c_
				del(@aFacets, _i_)
			ok
		next
		return This

	#-- queries ------------------------------------------------------------

	def Has(pcName)
		return This._IndexOf(pcName) > 0

	def Names()
		_a_ = []
		_n_ = len(@aFacets)
		for _i_ = 1 to _n_
			_a_ + @aFacets[_i_][1]
		next
		return _a_

	def NumberOf()
		return len(@aFacets)

	def CapabilitiesOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return []  ok
		return @aFacets[_i_][2]

	# The base/ modules realizing a facet ([] = external/logical).
	def ModulesOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return []  ok
		return @aFacets[_i_][3]

	def ToolOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aFacets[_i_][4]

	def IsPolyglot(pcName)
		return This.ToolOf(pcName) != ""

	# How the facet maps to code: :grounded (1 module) / :composed (2+) /
	# :external (polyglot, 0) / :logical (0, not polyglot).
	def MappingKindOf(pcName)
		if This.IsPolyglot(pcName)
			return :external
		ok
		_n_ = len(This.ModulesOf(pcName))
		if _n_ = 0
			return :logical
		but _n_ = 1
			return :grounded
		ok
		return :composed

	#-- internals ----------------------------------------------------------

	def _IndexOf(pcName)
		_c_ = StzLower("" + pcName)
		_n_ = len(@aFacets)
		for _i_ = 1 to _n_
			if StzLower("" + @aFacets[_i_][1]) = _c_  return _i_  ok
		next
		return 0

	def _Put(pcName, paCaps, paModules, pcTool)
		_aC_ = paCaps
		if NOT isList(_aC_)  _aC_ = [ _aC_ ]  ok
		_aM_ = paModules
		if NOT isList(_aM_)  _aM_ = [ _aM_ ]  ok
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			@aFacets[_i_] = [ pcName, _aC_, _aM_, "" + pcTool ]
		else
			@aFacets + [ pcName, _aC_, _aM_, "" + pcTool ]
		ok
