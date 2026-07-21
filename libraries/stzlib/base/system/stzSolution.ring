#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSOLUTION               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The DEPLOYABLE APEX + the building BRAIN.   #
#                  A stzSolution is what a programmer wants    #
#                  to deploy -- from one offline mobile app    #
#                  to a whole constellation (backend +         #
#                  frontends, many apps at many locations).    #
#                  Before a single byte is built, the brain    #
#                  REHEARSES a placement & scope plan: for     #
#                  each capability a part needs, on its        #
#                  target, it decides the delivery vector and  #
#                  says WHY -- and derives the minimal edge    #
#                  engine subset to ship. Build() then         #
#                  compiles exactly that; Deploy() commits.    #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# The DIFFERENTIAL-VALUE test (the load-bearing idea): the edge ships only what is
# critical to the app AND (unique to Softanza OR weak/absent on the target). A
# browser is strong at Unicode/dates/JSON -> use the platform's own; it is weak or
# lacking at Softanza's DSLs, solver, table/pivot, graph -> those go to the scoped
# edge engine (stz.wasm) or a Softanza-shaped stz.js construct. We never blindly
# ship a desktop-sized engine to an edge that cannot host it.
#
# Four delivery vectors:
#   native  -> the target platform does it well; ship nothing (JS's Unicode).
#   engine  -> Softanza-differential compute -> scoped into stz.wasm (edge) / firmware.
#   stzjs   -> ergonomic Softanza construct, written in the target language (stz.js).
#   server  -> too heavy for the edge -> runs on the backend.
#
# This is Scope-Oriented Programming applied to build/deploy, and it composes what
# already exists: the lowering bridge (meshes one op to a target) generalized to a
# whole solution; the VSF rehearse->plan->commit discipline (Plan() is the legible
# rehearsal); and the stzCodeGraph as the substrate for inferring a part's needs.
#
#   oSol = new stzSolution("restolean")
#   oSol.WithBackend(:api, :LinuxServer).WithSuperApp(:phone, :Android)
#   oSol.NeedsIn(:phone, [ :unicode, :table_pivot, :constraint_solver, :collection_dsl, :neural ])
#   ? oSol.Plan().Narration()

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSolutionQ(pcName)
	return new stzSolution(pcName)

func StzCapabilityCatalogQ()
	return new stzCapabilityCatalog()

# A friendly target -> its class: server / mobile / browser / mcu.
func _StzTargetClass(pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	if StzFindFirst("android", _c_) > 0 or StzFindFirst("ios", _c_) > 0 or StzFindFirst("mobile", _c_) > 0 or StzFindFirst("phone", _c_) > 0
		return "mobile"
	but StzFindFirst("browser", _c_) > 0 or StzFindFirst("web", _c_) > 0 or StzFindFirst("wasm", _c_) > 0
		return "browser"
	but StzFindFirst("esp", _c_) > 0 or StzFindFirst("rtos", _c_) > 0 or StzFindFirst("mcu", _c_) > 0 or StzFindFirst("arduino", _c_) > 0
		return "mcu"
	but StzFindFirst("server", _c_) > 0 or StzFindFirst("linux", _c_) > 0 or StzFindFirst("windows", _c_) > 0 or StzFindFirst("macos", _c_) > 0 or StzFindFirst("backend", _c_) > 0
		return "server"
	ok
	return "server"

func _StzIsEdgeClass(pcClass)
	return pcClass != "server"

func _StzVectorLabel(pcV)
	if pcV = "native"
		return "[platform]"
	but pcV = "engine"
		return "[stz.wasm]"
	but pcV = "stzjs"
		return "[stz.js]"
	but pcV = "server"
		return "[server]"
	ok
	return "[" + pcV + "]"

func _StzPad(pcS, pnN)
	_c_ = "" + pcS
	while len(_c_) < pnN
		_c_ += " "
	end
	return _c_

func _StzJoinList(paList)
	_c_ = ""
	_n_ = len(paList)
	for _i_ = 1 to _n_
		_c_ += "" + paList[_i_]
		if _i_ < _n_
			_c_ += ", "
		ok
	next
	return _c_

func _StzListHas(paList, pcX)
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if paList[_i_] = pcX
			return TRUE
		ok
	next
	return FALSE


  #=====================#
 #  CAPABILITY CATALOG  #
#=====================#

# The brain's KNOWLEDGE: each capability's differential value, as data (not a
# heuristic buried in code) so placement decisions are inspectable. A record is
# [ name, unique, nature, weight, js, native, embedded, kb ] where support is
# strong/weak/absent, nature is compute/ergonomic, weight is light/medium/heavy.
class stzCapabilityCatalog from stzObject

	@aCaps = []

	def init()
		This._SeedDefaults()

	def _SeedDefaults()
		@aCaps = [
			[ "unicode",           FALSE, "compute",   "light",    "strong", "strong", "weak",     6 ],
			[ "datetime",          FALSE, "compute",   "light",    "strong", "strong", "weak",     4 ],
			[ "json",              FALSE, "ergonomic", "light",    "strong", "strong", "weak",     2 ],
			[ "http",              FALSE, "ergonomic", "light",    "strong", "strong", "absent",   3 ],
			[ "regex",             TRUE,  "compute",   "medium",   "weak",   "strong", "absent",  20 ],
			[ "pattern",           TRUE,  "compute",   "light",    "absent", "strong", "weak",     5 ],
			[ "table_pivot",       TRUE,  "compute",   "medium",   "weak",   "strong", "absent",  12 ],
			[ "constraint_solver", TRUE,  "compute",   "medium",   "absent", "strong", "absent",  15 ],
			[ "graph",             TRUE,  "compute",   "medium",   "weak",   "strong", "absent",  10 ],
			[ "exact_numerics",    FALSE, "compute",   "light",    "weak",   "strong", "weak",     3 ],
			[ "collection_dsl",    TRUE,  "ergonomic", "light",    "weak",   "strong", "weak",     0 ],
			[ "neural",            FALSE, "compute",   "heavy",    "weak",   "strong", "absent",  900 ]
		]

	def Records()
		return @aCaps

	def Has(pcName)
		_c_ = StzLower("" + pcName)
		_n_ = len(@aCaps)
		for _i_ = 1 to _n_
			if @aCaps[_i_][1] = _c_
				return TRUE
			ok
		next
		return FALSE

	# unknown capability -> assume Softanza-differential compute, platform-weak.
	def Record(pcName)
		_c_ = StzLower("" + pcName)
		_n_ = len(@aCaps)
		for _i_ = 1 to _n_
			if @aCaps[_i_][1] = _c_
				return @aCaps[_i_]
			ok
		next
		return [ _c_, TRUE, "compute", "medium", "weak", "strong", "absent", 8 ]

	def SizeOf(pcName)
		return This.Record(pcName)[8]

	def _SupportFor(paRec, pcClass)
		if pcClass = "server"
			return paRec[6]
		but pcClass = "mcu"
			return paRec[7]
		ok
		return paRec[5]   # browser / mobile use JS support

	# (capability, target class) -> [ vector, reason ]. The whole brain, legibly.
	def VectorFor(pcCap, pcClass)
		_r_ = This.Record(pcCap)
		_cap_ = _r_[1]
		_bUnique_ = _r_[2]
		_cNature_ = _r_[3]
		_cWeight_ = _r_[4]
		_cSupp_ = This._SupportFor(_r_, pcClass)

		if pcClass = "server"
			return [ "engine", _cap_ + ": the server hosts the native engine" ]
		ok
		if _cWeight_ = "heavy"
			return [ "server", _cap_ + ": heavy -> runs on the backend, not the edge" ]
		ok
		if _cSupp_ = "strong" and NOT _bUnique_
			return [ "native", _cap_ + ": the target is strong at it -> use the platform's own" ]
		ok
		if _cNature_ = "ergonomic"
			return [ "stzjs", _cap_ + ": ergonomic -> a Softanza-shaped construct in stz.js" ]
		ok
		return [ "engine", _cap_ + ": Softanza-differential, platform " + _cSupp_ + " -> scoped into the edge engine" ]


  #=============#
 #  SOLUTION   #
#=============#

class stzSolution from stzObject

	@cName = ""
	@aParts = []       # [ name, kind, targetname, [caps] ]  -- plain data (survives copy)
	@oCat = NULL

	def init(pcName)
		@cName = "" + pcName
		@oCat = new stzCapabilityCatalog()

	def Name()
		return @cName

	def UseCatalog(poCat)
		@oCat = poCat
		return This

	def WithPart(pcKind, pcName, pcTarget)
		@aParts + [ StzLower("" + pcName), StzLower("" + pcKind), StzLower("" + pcTarget), [] ]
		return This

		def WithApp(pcName, pcTarget)
			return This.WithPart("app", pcName, pcTarget)
		def WithSuperApp(pcName, pcTarget)
			return This.WithPart("superapp", pcName, pcTarget)
		def WithBackend(pcName, pcTarget)
			return This.WithPart("backend", pcName, pcTarget)
		def WithServer(pcName, pcTarget)
			return This.WithPart("server", pcName, pcTarget)

	def _PartIndex(pcName)
		_c_ = StzLower("" + pcName)
		_n_ = len(@aParts)
		for _i_ = 1 to _n_
			if @aParts[_i_][1] = _c_
				return _i_
			ok
		next
		return 0

	def Parts()
		return @aParts

	def NumberOfParts()
		return len(@aParts)

	# declare the Softanza capabilities a part's code uses
	def NeedsIn(pcPart, paCaps)
		_i_ = This._PartIndex(pcPart)
		if _i_ = 0
			return This
		ok
		_caps_ = []
		if isList(paCaps)
			_m_ = len(paCaps)
			for _k_ = 1 to _m_
				_caps_ + StzLower("" + paCaps[_k_])
			next
		ok
		@aParts[_i_][4] = _caps_
		return This

	# a first inference: scan the app source for capability markers. Upgradeable to
	# the stzCodeGraph call-edge analysis (this is the lexical starting point).
	def InferNeedsIn(pcPart, pcSourcePath)
		_i_ = This._PartIndex(pcPart)
		if _i_ = 0
			return This
		ok
		_cSrc_ = ""
		try
			_cSrc_ = read(pcSourcePath)
		catch
			return This
		done
		@aParts[_i_][4] = This._InferCaps(_cSrc_)
		return This

	def _InferCaps(pcSrc)
		_aMap_ = [
			[ "Pivot",      "table_pivot" ],
			[ "GroupBy",    "table_pivot" ],
			[ "Solve",      "constraint_solver" ],
			[ "Constraint", "constraint_solver" ],
			[ "Regex",      "regex" ],
			[ "Pattern",    "pattern" ],
			[ "Graph",      "graph" ],
			[ "Neural",     "neural" ],
			[ "TextQ",      "unicode" ],
			[ "Uppercase",  "unicode" ],
			[ "Date",       "datetime" ],
			[ "Json",       "json" ]
		]
		_found_ = []
		_n_ = len(_aMap_)
		for _i_ = 1 to _n_
			if StzFindFirst(_aMap_[_i_][1], pcSrc) > 0
				if NOT _StzListHas(_found_, _aMap_[_i_][2])
					_found_ + _aMap_[_i_][2]
				ok
			ok
		next
		return _found_

	# REHEARSE the placement & scope plan -- no bytes built. This is Build()'s
	# thinking made visible (VSF rehearse->plan->commit).
	def Plan()
		_oPlan_ = new stzSolutionPlan(@cName)
		_n_ = len(@aParts)
		for _i_ = 1 to _n_
			_name_ = @aParts[_i_][1]
			_kind_ = @aParts[_i_][2]
			_tname_ = @aParts[_i_][3]
			_caps_ = @aParts[_i_][4]
			_class_ = _StzTargetClass(_tname_)
			_decisions_ = []
			_m_ = len(_caps_)
			for _k_ = 1 to _m_
				_v_ = @oCat.VectorFor(_caps_[_k_], _class_)
				_decisions_ + [ _caps_[_k_], _v_[1], _v_[2], @oCat.SizeOf(_caps_[_k_]) ]
			next
			_oPlan_.AddPart(_name_, _kind_, _tname_, _class_, _decisions_)
		next
		return _oPlan_


  #==================#
 #  SOLUTION PLAN   #
#==================#

# The rehearsed placement & scope plan -- the brain's readable output. Per part:
# every capability, its delivery vector, and the reason; plus the derived edge
# engine subset. Plain-data backed; Narration() is the legible signature.
class stzSolutionPlan from stzObject

	@cName = ""
	@aParts = []   # [ name, kind, tname, class, [ [cap, vector, reason, kb], ... ] ]

	def init(pcName)
		@cName = "" + pcName

	def AddPart(pcName, pcKind, pcTName, pcClass, paDecisions)
		@aParts + [ pcName, pcKind, pcTName, pcClass, paDecisions ]
		return This

	def NumberOfParts()
		return len(@aParts)

	def _Idx(pcName)
		_c_ = StzLower("" + pcName)
		_n_ = len(@aParts)
		for _i_ = 1 to _n_
			if @aParts[_i_][1] = _c_
				return _i_
			ok
		next
		return 0

	def _CapsByVector(paDecisions, pcVector)
		_out_ = []
		_n_ = len(paDecisions)
		for _i_ = 1 to _n_
			if paDecisions[_i_][2] = pcVector
				_out_ + paDecisions[_i_][1]
			ok
		next
		return _out_

	def _EngineKb(paDecisions)
		_kb_ = 0
		_n_ = len(paDecisions)
		for _i_ = 1 to _n_
			if paDecisions[_i_][2] = "engine"
				_kb_ += paDecisions[_i_][4]
			ok
		next
		return _kb_

	# the delivery vector chosen for a capability in a part (data -- for checks)
	def VectorFor(pcPart, pcCap)
		_i_ = This._Idx(pcPart)
		if _i_ = 0
			return ""
		ok
		_cc_ = StzLower("" + pcCap)
		_decs_ = @aParts[_i_][5]
		_n_ = len(_decs_)
		for _k_ = 1 to _n_
			if _decs_[_k_][1] = _cc_
				return _decs_[_k_][2]
			ok
		next
		return ""

	# the capabilities compiled into a part's edge engine (stz.wasm / firmware)
	def EngineCapsFor(pcPart)
		_i_ = This._Idx(pcPart)
		if _i_ = 0
			return []
		ok
		return This._CapsByVector(@aParts[_i_][5], "engine")

	def EngineKbFor(pcPart)
		_i_ = This._Idx(pcPart)
		if _i_ = 0
			return 0
		ok
		return This._EngineKb(@aParts[_i_][5])

	def Narration()
		_c_ = "Solution '" + @cName + "' -- placement & scope plan (rehearsal; nothing built yet)" + nl
		_c_ += "==============================================================================" + nl
		_tot_ = 0
		_nat_ = 0
		_eng_ = 0
		_js_ = 0
		_srv_ = 0
		_np_ = len(@aParts)
		for _i_ = 1 to _np_
			_p_ = @aParts[_i_]
			_c_ += nl + "  Part '" + _p_[1] + "' [" + _p_[2] + "] -> " + _p_[3] + " (" + _p_[4]
			if _StzIsEdgeClass(_p_[4])
				_c_ += " / edge"
			ok
			_c_ += ")" + nl
			_decs_ = _p_[5]
			_m_ = len(_decs_)
			_bEdge_ = _StzIsEdgeClass(_p_[4])
			for _k_ = 1 to _m_
				_lbl_ = _StzVectorLabel(_decs_[_k_][2])
				if _decs_[_k_][2] = "engine" and NOT _bEdge_
					_lbl_ = "[engine]"   # the server's native Softanza engine, not wasm
				ok
				_c_ += "     " + _StzPad(_decs_[_k_][1], 18) + " " + _StzPad(_lbl_, 12) + _decs_[_k_][3] + nl
				_tot_++
				if _decs_[_k_][2] = "native"
					_nat_++
				but _decs_[_k_][2] = "engine"
					_eng_++
				but _decs_[_k_][2] = "stzjs"
					_js_++
				but _decs_[_k_][2] = "server"
					_srv_++
				ok
			next
			if _bEdge_
				_engcaps_ = This._CapsByVector(_decs_, "engine")
				if len(_engcaps_) > 0
					_c_ += "     -> edge engine carries: " + _StzJoinList(_engcaps_) + "  (~" + This._EngineKb(_decs_) + " KB, " + len(_engcaps_) + " of " + _m_ + ")" + nl
				else
					_c_ += "     -> edge engine: nothing to ship (all native / stz.js / server)" + nl
				ok
			else
				_c_ += "     -> runs on the full native engine (server has everything)" + nl
			ok
		next
		_c_ += nl + "  Summary: " + _tot_ + " capabilities across " + _np_ + " parts -> "
		_c_ += "platform " + _nat_ + ", stz.wasm " + _eng_ + ", stz.js " + _js_ + ", server " + _srv_ + "." + nl
		_c_ += "  Build() will compile exactly this scope; Deploy() will commit it." + nl
		return _c_

	def Show()
		? This.Narration()
