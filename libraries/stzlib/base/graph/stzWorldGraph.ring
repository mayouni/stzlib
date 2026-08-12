#---------------------------------------------------------------------------#
#  STZWORLDGRAPH -- the declared world, loaded as a graph.                   #
#---------------------------------------------------------------------------#
#
#     oW = StzWorldGraphQ("build/world.json")
#
#     ? oW.IsLawful()                  # did every reference resolve?
#     ? oW.NamesOfKind(:entity)        # [ "deposit", "member" ]
#     ? oW.ReferencesFrom("flow:accept_deposit")
#     oG = oW.Graph()                  # an ordinary stzGraph from here on
#
# THIS IS C1 -- the World Contract (contracts/world-contract.md, v1.0). One
# derived, language-neutral symbol artifact per project: two flat tables, the
# symbols each court declares and the references between them.
#
# WHAT THIS CLASS IS CAREFUL ABOUT:
#
#   - It READS. It never emits world.json -- emitting is each court's job, in
#     each court's repository -- and it never queries: stzGraphQuery already
#     does that, over the graph this hands back.
#
#   - It COLLECTS refusals instead of raising on the first one. A build wants
#     the whole list; IsLawful() is the gate. Every diagnostic is one C2
#     envelope (the Diagnostic Contract, StzZui, v1.0) with language "world".
#
#   - It REFUSES a case-collision. stzGraph normalises node ids to lower case,
#     so two symbols of one kind differing only by case would silently
#     overwrite each other. Diagnosed here, because here is the only place it
#     can still be seen.
#
#   - It GROUPS references. stzGraph is a simple graph -- one edge per node
#     pair, deliberately -- and a world hits that immediately: two fields of
#     one entity sharing a type is two has_type refs between the same pair.
#     So refs are grouped by (from, to) into ONE edge carrying every row in
#     its :refs property. world.json is the truth; the graph is an index over
#     it, and an index answers reachability, which is a property of the pair.

$acWorldSymbolKinds = [
	"entity", "field", "type", "actor", "norm",
	"flow", "screen", "process", "element", "state"
]

$acWorldRefKinds = [
	"declares", "has_type", "enforces", "routes_to", "performed_by",
	"calls", "shows", "binds", "references"
]

$cWorldContractVersion = "1.0"

func StzWorldGraphQ(pSource)
	return new stzWorldGraph(pSource)

	func StzWorldQ(pSource)
		return new stzWorldGraph(pSource)

func StzWorldSymbolKinds()
	return $acWorldSymbolKinds

func StzWorldRefKinds()
	return $acWorldRefKinds

func IsStzWorldGraph(pObj)
	if isObject(pObj) and classname(pObj) = "stzworldgraph"
		return 1
	ok
	return 0

class stzWorldGraph from stzObject

	@cWorld = ""
	@cContract = ""
	@oGraph = ""
	@aSymbols = []		# [ :id, :kind, :name, :type, :file, :line, :rationale ]
	@aRefs = []		# [ :from, :to, :kind, :file, :line ]
	@aDiag = []		# C2 envelopes, in the order they were found

	# Give it a path to a world.json, or the JSON text itself.
	def init(pSource)
		@cWorld = ""
		@cContract = ""
		@aSymbols = []
		@aRefs = []
		@aDiag = []

		_cText_ = This._TextOf(pSource)
		@oGraph = new stzGraph("world")
		@oGraph.SetGraphType("semantic")

		if _cText_ = ""
			This._Refuse("EMPTY_WORLD", "error", "", 0,
				"There is nothing to read: the world artifact is empty or could not be opened.")
			return
		ok

		_aRoot_ = JsonToList(_cText_)
		if NOT isList(_aRoot_) or len(_aRoot_) = 0
			This._Refuse("MALFORMED_WORLD", "error", "", 0,
				"The world artifact is not readable as JSON.")
			return
		ok

		@cWorld = This._Str(_aRoot_, "world")
		@cContract = This._Str(_aRoot_, "contract")

		if @cContract != $cWorldContractVersion
			This._Refuse("CONTRACT_MISMATCH", "error", "", 0,
				"This world was emitted against contract '" + @cContract +
				"'; this loader implements '" + $cWorldContractVersion + "'.")
		ok

		This._ReadSymbols(_aRoot_)
		This._ReadRefs(_aRoot_)
		This._Build()

	#-- what was read -------------------------------------------------------

	def World()
		return @cWorld

	def ContractVersion()
		return @cContract

	def Graph()
		return @oGraph

	def Symbols()
		return @aSymbols

	def SymbolCount()
		return len(@aSymbols)

	def Refs()
		return @aRefs

	def RefCount()
		return len(@aRefs)

	#-- looking things up ---------------------------------------------------

	# Ids are matched case-insensitively -- the same rule the graph enforces.
	def HasSymbol(pcId)
		return This._IndexOfSymbol(pcId) > 0

	def Symbol(pcId)
		_n_ = This._IndexOfSymbol(pcId)
		if _n_ = 0
			return []
		ok
		return @aSymbols[_n_]

	# The names of every symbol of one kind -- the projection every consumer
	# of a symbol table starts from.
	def NamesOfKind(pcKind)
		_cK_ = StzLower(ring_trim("" + pcKind))
		_ac_ = []
		_n_ = len(@aSymbols)
		for _i_ = 1 to _n_
			if @aSymbols[_i_][:kind] = _cK_
				_ac_ + @aSymbols[_i_][:name]
			ok
		next
		return _ac_

	def IdsOfKind(pcKind)
		_cK_ = StzLower(ring_trim("" + pcKind))
		_ac_ = []
		_n_ = len(@aSymbols)
		for _i_ = 1 to _n_
			if @aSymbols[_i_][:kind] = _cK_
				_ac_ + @aSymbols[_i_][:id]
			ok
		next
		return _ac_

	def Kinds()
		_ac_ = []
		_n_ = len(@aSymbols)
		for _i_ = 1 to _n_
			if ring_find(_ac_, @aSymbols[_i_][:kind]) = 0
				_ac_ + @aSymbols[_i_][:kind]
			ok
		next
		return _ac_

	# The exact four arrays StzZui's zui verifier reads for its Level-3
	# checks (tools/zui, --symbols FILE). Without them it SKIPS those checks,
	# because undecidable is silence, never a pass -- so this projection is
	# what turns a world artifact into Level-3 coverage.
	def ZuiSymbolTable()
		return [
			:entities = This.NamesOfKind(:entity),
			:actors   = This.NamesOfKind(:actor),
			:state    = This.NamesOfKind(:state),
			:elements = This.NamesOfKind(:element)
		]

	#-- references ----------------------------------------------------------

	# Every reference SITE out of a symbol -- rows, not pairs, so two steps
	# enforcing one norm are two answers with two spans.
	def ReferencesFrom(pcId)
		_cI_ = StzLower(ring_trim("" + pcId))
		_a_ = []
		_n_ = len(@aRefs)
		for _i_ = 1 to _n_
			if @aRefs[_i_][:from] = _cI_
				_a_ + @aRefs[_i_]
			ok
		next
		return _a_

	def ReferencesTo(pcId)
		_cI_ = StzLower(ring_trim("" + pcId))
		_a_ = []
		_n_ = len(@aRefs)
		for _i_ = 1 to _n_
			if @aRefs[_i_][:to] = _cI_
				_a_ + @aRefs[_i_]
			ok
		next
		return _a_

	#-- the verdict ---------------------------------------------------------

	def Diagnostics()
		return @aDiag

	def ErrorCount()
		_n_ = 0
		_nLen_ = len(@aDiag)
		for _i_ = 1 to _nLen_
			if @aDiag[_i_][:severity] = "error"
				_n_++
			ok
		next
		return _n_

	def IsLawful()
		return This.ErrorCount() = 0

	#-- internals -----------------------------------------------------------

	def _TextOf(pSource)
		if NOT isString(pSource)
			return ""
		ok
		if StzLeft(ring_trim(pSource), 1) = "{"
			return pSource
		ok
		if fexists(pSource)
			return read(pSource)
		ok
		return ""

	def _Refuse(pcCode, pcSeverity, pcFile, pnLine, pcMessage)
		@aDiag + [
			:code = pcCode,
			:severity = pcSeverity,
			:message = pcMessage,
			:span = [ :file = pcFile, :line = pnLine ],
			:cites = [],
			:language = "world"
		]

	def _Str(paHash, pcKey)
		if isList(paHash) and HasKey(paHash, pcKey)
			_v_ = paHash[pcKey]
			if isString(_v_)
				return _v_
			ok
			if isNumber(_v_)
				return "" + _v_
			ok
		ok
		return ""

	def _Num(paHash, pcKey)
		if isList(paHash) and HasKey(paHash, pcKey)
			_v_ = paHash[pcKey]
			if isNumber(_v_)
				return _v_
			ok
		ok
		return 0

	def _List(paHash, pcKey)
		if isList(paHash) and HasKey(paHash, pcKey)
			_v_ = paHash[pcKey]
			if isList(_v_)
				return _v_
			ok
		ok
		return []

	# A name must survive stzGraph's node-id rule: no space, no newline.
	def _IsWellFormedName(pcName)
		if NOT isString(pcName) or pcName = ""
			return 0
		ok
		# StzFindFirst, not StzFind: StzFind answers a LIST of positions,
		# and comparing a list to 0 is an R21.
		if StzFindFirst(" ", pcName) > 0
			return 0
		ok
		if StzFindFirst(char(10), pcName) > 0
			return 0
		ok
		return 1

	def _IndexOfSymbol(pcId)
		_cI_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aSymbols)
		for _i_ = 1 to _n_
			if @aSymbols[_i_][:id] = _cI_
				return _i_
			ok
		next
		return 0

	def _ReadSymbols(paRoot)
		_aRows_ = This._List(paRoot, "symbols")
		_nLen_ = len(_aRows_)

		for _i_ = 1 to _nLen_
			_aRow_ = _aRows_[_i_]
			_aSpan_ = This._List(_aRow_, "span")
			_cFile_ = This._Str(_aSpan_, "file")
			_nLine_ = This._Num(_aSpan_, "line")

			_cKind_ = StzLower(ring_trim(This._Str(_aRow_, "kind")))
			_cName_ = ring_trim(This._Str(_aRow_, "name"))

			if ring_find($acWorldSymbolKinds, _cKind_) = 0
				This._Refuse("UNKNOWN_SYMBOL_KIND", "error", _cFile_, _nLine_,
					"'" + _cKind_ + "' is not a symbol kind. The set is closed: " +
					JoinXT($acWorldSymbolKinds, ", ") + ".")
				loop
			ok

			if NOT This._IsWellFormedName(_cName_)
				This._Refuse("MALFORMED_NAME", "error", _cFile_, _nLine_,
					"A symbol name carries a space or a newline, which no graph node id may: '" +
					_cName_ + "'.")
				loop
			ok

			if _cFile_ = ""
				This._Refuse("MISSING_SPAN", "warning", "", 0,
					"Symbol '" + _cKind_ + ":" + _cName_ +
					"' declares no file, so nothing can point at it.")
			ok

			_cId_ = StzLower(_cKind_ + ":" + _cName_)

			if This._IndexOfSymbol(_cId_) > 0
				This._Refuse("DUPLICATE_SYMBOL", "error", _cFile_, _nLine_,
					"'" + _cId_ + "' is declared twice. Names are matched without " +
					"regard to case, because the graph stores them that way.")
				loop
			ok

			@aSymbols + [
				:id = _cId_,
				:kind = _cKind_,
				:name = _cName_,
				:type = This._Str(_aRow_, "type"),
				:file = _cFile_,
				:line = _nLine_,
				:rationale = This._Str(_aRow_, "rationale")
			]
		next

	def _ReadRefs(paRoot)
		_aRows_ = This._List(paRoot, "refs")
		_nLen_ = len(_aRows_)

		for _i_ = 1 to _nLen_
			_aRow_ = _aRows_[_i_]
			_aSpan_ = This._List(_aRow_, "span")
			_cFile_ = This._Str(_aSpan_, "file")
			_nLine_ = This._Num(_aSpan_, "line")

			_cFrom_ = StzLower(ring_trim(This._Str(_aRow_, "from")))
			_cTo_   = StzLower(ring_trim(This._Str(_aRow_, "to")))
			_cKind_ = StzLower(ring_trim(This._Str(_aRow_, "kind")))

			if ring_find($acWorldRefKinds, _cKind_) = 0
				This._Refuse("UNKNOWN_REFERENCE_KIND", "error", _cFile_, _nLine_,
					"'" + _cKind_ + "' is not a reference kind. The set is closed: " +
					JoinXT($acWorldRefKinds, ", ") + ".")
				loop
			ok

			if This._IndexOfSymbol(_cFrom_) = 0
				This._Refuse("DANGLING_REFERENCE", "error", _cFile_, _nLine_,
					"'" + _cFrom_ + "' refers to something, but nothing declares '" +
					_cFrom_ + "' itself.")
				loop
			ok

			if This._IndexOfSymbol(_cTo_) = 0
				This._Refuse("DANGLING_REFERENCE", "error", _cFile_, _nLine_,
					"'" + _cFrom_ + "' " + _cKind_ + " '" + _cTo_ +
					"', which nothing declares.")
				loop
			ok

			@aRefs + [
				:from = _cFrom_,
				:to = _cTo_,
				:kind = _cKind_,
				:file = _cFile_,
				:line = _nLine_
			]
		next

	# Nodes for every lawful symbol; ONE edge per referenced pair, carrying
	# every row that produced it.
	def _Build()
		_nS_ = len(@aSymbols)
		for _i_ = 1 to _nS_
			_a_ = @aSymbols[_i_]
			@oGraph.AddNodeXTT(_a_[:id], _a_[:name], [
				:type = "symbol",
				:kind = _a_[:kind],
				:file = _a_[:file],
				:line = _a_[:line]
			])
		next

		_aPairs_ = []		# [ :from, :to, :kind, :rows ]
		_nR_ = len(@aRefs)
		for _i_ = 1 to _nR_
			_aR_ = @aRefs[_i_]
			_nAt_ = 0
			_nP_ = len(_aPairs_)
			for _j_ = 1 to _nP_
				if _aPairs_[_j_][:from] = _aR_[:from] and
				   _aPairs_[_j_][:to] = _aR_[:to]
					_nAt_ = _j_
					exit
				ok
			next

			if _nAt_ = 0
				_aPairs_ + [
					:from = _aR_[:from],
					:to = _aR_[:to],
					:kind = _aR_[:kind],
					:rows = [ _aR_ ]
				]
			else
				_aRows_ = _aPairs_[_nAt_][:rows]
				_aRows_ + _aR_
				_aPairs_[_nAt_][:rows] = _aRows_
			ok
		next

		_nP_ = len(_aPairs_)
		for _i_ = 1 to _nP_
			_aP_ = _aPairs_[_i_]
			@oGraph.AddEdgeXTT(_aP_[:from], _aP_[:to], _aP_[:kind], [
				:type = "reference",
				:refs = _aP_[:rows]
			])
		next
