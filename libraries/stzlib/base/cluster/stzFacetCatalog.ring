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

# Registers the facets a cluster knows: logical competences such as graph or nlp, with their capabilities and the modules that realize them.
#
# A facet is a competence a cluster routes along, not a physical module. A fresh catalog holds the
# 18 standard facets; Define and DefinePolyglot add or override one and Drop removes one. The
# catalog belongs to its instance, so two clusters in one process can have different facets.
# MappingKindOf says whether a facet is grounded in one module, composed from several, external
# (served by a tool such as python) or purely logical.
#
#   receiver   o1 = new stzFacetCatalog()
#   example    ? o1.NumberOf()
#              #--> 18
#              ? @@( o1.CapabilitiesOf("graph") )
#              #--> [ "paths", "centrality", "planner", "rules", "orgchart" ]
#              ? o1.MappingKindOf("vision")
#              #--> external
#              ? o1.MappingKindOf("knowledge")
#              #--> composed
#              o1.Define("audio", [ "transcribe" ], [])
#              ? o1.MappingKindOf("audio")
#              #--> logical
#   see        stzComputePipeline, stzClusterSupervisor, stzRequestClassifier
class stzFacetCatalog from stzObject

	@aFacets = []      # [ [ name, [caps], [modules], tool ], ... ]

	# Builds a catalog seeded with the 18 standard Softanza facets, such as text, graph, nlp and vision.
	#
	#   returns    nothing; the object is built
	#   see        Names, Define
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

	# Adds an engine-native facet, or replaces the one of that name, with its capabilities and the modules that realize it.
	#
	#   pcName      the facet's name, stored in lower case
	#   paCaps      the capabilities the facet offers, as a list of names
	#   paModules   the base modules that realize it, as a list of texts, empty for a purely logical
	#               facet
	#   returns     the catalog itself, so calls chain
	#   warning     the catalog belongs to its own instance: a facet defined here is unknown to
	#               every other catalog
	#   see         DefinePolyglot, Drop, MappingKindOf
	#@ aka  -- customization (per-instance) ---------------------------------------
	def Define(pcName, paCaps, paModules)
		This._Put(StzLower("" + pcName), paCaps, paModules, "")
		return This

	# Adds a facet served by an external tool run off-process, or replaces the one of that name.
	#
	#   pcName     the facet's name, stored in lower case
	#   paCaps     the capabilities the facet offers, as a list of names
	#   pcTool     the external tool, such as python
	#   returns    the catalog itself, so calls chain
	#   warning    a polyglot facet has no module
	#   see        Define, IsPolyglot, ToolOf
	#@ aka  Add or override a POLYGLOT facet (served by an external tool off- process; no engine module).
	def DefinePolyglot(pcName, paCaps, pcTool)
		This._Put(StzLower("" + pcName), paCaps, [], "" + pcTool)
		return This

	# Removes a facet by name; an unknown name changes nothing.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    the catalog itself, so calls chain
	#   see        Define, Has
	def Drop(pcName)
		_c_ = StzLower("" + pcName)
		for _i_ = len(@aFacets) to 1 step -1
			if StzLower("" + @aFacets[_i_][1]) = _c_
				del(@aFacets, _i_)
			ok
		next
		return This

	# TRUE if the catalog knows a facet of that name.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        Names, Define
	#@ aka  -- queries ------------------------------------------------------------
	def Has(pcName)
		return This._IndexOf(pcName) > 0

	# Returns the names of all facets, in the order they were defined.
	#
	#   returns    a list of texts
	#   see        NumberOf, Has
	def Names()
		_a_ = []
		_n_ = len(@aFacets)
		for _i_ = 1 to _n_
			_a_ + @aFacets[_i_][1]
		next
		return _a_

	# Returns how many facets the catalog holds.
	#
	#   returns    a number
	#   see        Names
	def NumberOf()
		return len(@aFacets)

	# Returns the capabilities a facet offers; an empty list for an unknown facet.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    a list of texts
	#   see        ModulesOf, Define
	def CapabilitiesOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return []  ok
		return @aFacets[_i_][2]

	# Returns the base modules that realize a facet; an empty list for an unknown, external or purely logical facet.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    a list of texts
	#   see        MappingKindOf, CapabilitiesOf
	#@ aka  The base/ modules realizing a facet ([] = external/logical).
	def ModulesOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return []  ok
		return @aFacets[_i_][3]

	# Returns the external tool that serves a facet; an empty text for an engine-native or unknown facet.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    a text
	#   see        IsPolyglot, DefinePolyglot
	def ToolOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aFacets[_i_][4]

	# TRUE if the facet is served by an external tool off-process.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        ToolOf, DefinePolyglot
	def IsPolyglot(pcName)
		return This.ToolOf(pcName) != ""

	# Returns how a facet maps onto code: :external, :logical, :grounded for one module or :composed for two or more.
	#
	#   pcName     the facet's name, matched without regard to case
	#   returns    a text among external, logical, grounded and composed
	#   note       in the standard catalog only vision is external, and text is composed from three
	#              modules
	#   warning    an unknown name answers logical, as a facet with no module does; test Has first
	#              when the difference matters
	#   see        ModulesOf, IsPolyglot
	#@ aka  How the facet maps to code: :grounded (1 module) / :composed (2+) / :external (polyglot, 0) / :logical (0, not polyglot).
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
