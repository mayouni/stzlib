#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZBUILDERBRAIN           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The REASONING behind stzBuilder. You        #
#                  describe the SOLUTION you want to deploy    #
#                  -- its parts, their targets, the Softanza   #
#                  capabilities each uses -- and the brain     #
#                  REHEARSES a placement & scope plan BEFORE   #
#                  a byte is built: per capability, on its     #
#                  target, it picks a delivery vector and      #
#                  says WHY, and derives the minimal on-device #
#                  engine subset. stzBuilder then compiles     #
#                  exactly that plan; Deploy() commits it.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# This is Scope-Oriented Programming, third instance (after regex and system): the
# invisible governing frame is the TARGET PLATFORM. The SAME capability behaves
# differently per target -- table_pivot is stz.wasm on a browser, FIRMWARE on an
# MCU, the native engine on a server. Name the target scope (each part's target)
# and the brain reasons with it, bridging what the target cannot host (M5). The
# DIFFERENTIAL-VALUE test decides: the edge carries only what is critical AND
# (Softanza-unique OR weak/absent on the target). A browser is strong at Unicode
# -> use its own; it lacks Softanza's solver/pivot/pattern -> those go on-device.
#
# Four delivery vectors, inclusive across targets:
#   native    -> the target platform does it well; ship nothing (a browser's Unicode).
#   engine    -> Softanza-differential compute, in the target's on-device form:
#                stz.wasm (browser/mobile), FIRMWARE (mcu), the native engine (server).
#   construct -> ergonomic Softanza construct in the target language (stz.js on the web).
#   server    -> too heavy for the edge -> the backend.
#
#   oBrain = new stzBuilderBrain("restolean")
#   oBrain.WithBackend(:api, :LinuxServer).WithSuperApp(:phone, :Android).WithApp(:node, :ESP32)
#   oBrain.NeedsIn(:phone, [ :unicode, :table_pivot, :constraint_solver, :collection_dsl, :neural ])
#   ? oBrain.Plan().Narration()

  #=============#
 #  FUNCTIONS  #
#=============#

func StzBuilderBrainQ(pcName)
	return new stzBuilderBrain(pcName)

func StzCapabilityCatalogQ()
	return new stzCapabilityCatalog()

# A friendly target -> its class: server / mobile / browser / mcu. (Thin domain
# classifier, like _StzSystemProfileForTarget -- not a reinvented primitive.)
func _StzTargetClass(pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	if StzFindFirst("android", _c_) > 0 or StzFindFirst("ios", _c_) > 0 or StzFindFirst("mobile", _c_) > 0 or StzFindFirst("phone", _c_) > 0
		return "mobile"
	but StzFindFirst("browser", _c_) > 0 or StzFindFirst("web", _c_) > 0 or StzFindFirst("wasm", _c_) > 0
		return "browser"
	but StzFindFirst("esp", _c_) > 0 or StzFindFirst("rtos", _c_) > 0 or StzFindFirst("mcu", _c_) > 0 or StzFindFirst("arduino", _c_) > 0 or StzFindFirst("firmware", _c_) > 0
		return "mcu"
	but StzFindFirst("server", _c_) > 0 or StzFindFirst("linux", _c_) > 0 or StzFindFirst("windows", _c_) > 0 or StzFindFirst("macos", _c_) > 0 or StzFindFirst("backend", _c_) > 0
		return "server"
	ok
	return "server"


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
			[ "gpio",              TRUE,  "compute",   "light",    "absent", "weak",   "strong",   1 ],
			[ "collection_dsl",    TRUE,  "ergonomic", "light",    "weak",   "strong", "weak",     0 ],
			[ "neural",            FALSE, "compute",   "heavy",    "weak",   "strong", "absent",  900 ]
		]

	def Records()
		return @aCaps

	def Has(pcName)
		return StzFindFirst(StzLower("" + pcName), This._Names()) > 0

	def _Names()
		_out_ = []
		nLen = len(@aCaps)
		for i = 1 to nLen
			_out_ + @aCaps[i][1]
		next
		return _out_

	# unknown capability -> assume Softanza-differential compute, platform-weak.
	def Record(pcName)
		_c_ = StzLower("" + pcName)
		nLen = len(@aCaps)
		for i = 1 to nLen
			if @aCaps[i][1] = _c_
				return @aCaps[i]
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
	# Inclusive across targets: a server hosts the native engine; the heavy is
	# offloaded; a strong non-unique capability uses the platform; ergonomics on a
	# language-runtime target become a construct, else they fold into the engine.
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
		if _cNature_ = "ergonomic" and (pcClass = "browser" or pcClass = "mobile")
			return [ "construct", _cap_ + ": ergonomic -> a Softanza construct in the target language" ]
		ok
		return [ "engine", _cap_ + ": Softanza-differential, " + pcClass + " " + _cSupp_ + " -> the on-device engine" ]


  #=================#
 #  BUILDER BRAIN  #
#=================#

class stzBuilderBrain from stzObject

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
		def WithFirmware(pcName, pcTarget)
			return This.WithPart("firmware", pcName, pcTarget)

	def _PartIndex(pcName)
		_c_ = StzLower("" + pcName)
		nLen = len(@aParts)
		for i = 1 to nLen
			if @aParts[i][1] = _c_
				return i
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
			nLen = len(paCaps)
			for k = 1 to nLen
				_caps_ + StzLower("" + paCaps[k])
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
			[ "ReadPin",    "gpio" ],
			[ "WritePin",   "gpio" ],
			[ "TextQ",      "unicode" ],
			[ "Uppercase",  "unicode" ],
			[ "Date",       "datetime" ],
			[ "Json",       "json" ]
		]
		_found_ = []
		nLen = len(_aMap_)
		for i = 1 to nLen
			if StzFindFirst(_aMap_[i][1], pcSrc) > 0 and StzFindFirst(_aMap_[i][2], _found_) = 0
				_found_ + _aMap_[i][2]
			ok
		next
		return _found_

	# REHEARSE the placement & scope plan -- no bytes built. This is Build()'s
	# thinking made visible (VSF rehearse->plan->commit).
	def Plan()
		_oPlan_ = new stzBuildPlan(@cName)
		nLen = len(@aParts)
		for i = 1 to nLen
			_name_ = @aParts[i][1]
			_kind_ = @aParts[i][2]
			_tname_ = @aParts[i][3]
			_caps_ = @aParts[i][4]
			_class_ = _StzTargetClass(_tname_)
			_decisions_ = []
			mLen = len(_caps_)
			for k = 1 to mLen
				_v_ = @oCat.VectorFor(_caps_[k], _class_)
				_decisions_ + [ _caps_[k], _v_[1], _v_[2], @oCat.SizeOf(_caps_[k]) ]
			next
			_oPlan_.AddPart(_name_, _kind_, _tname_, _class_, _decisions_)
		next
		return _oPlan_


  #==============#
 #  BUILD PLAN  #
#==============#

# The rehearsed placement & scope plan -- the brain's readable output. Per part:
# every capability, its delivery vector, and the reason; plus the derived on-device
# engine subset. Plain-data backed; Narration() is the legible signature.
class stzBuildPlan from stzObject

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
		nLen = len(@aParts)
		for i = 1 to nLen
			if @aParts[i][1] = _c_
				return i
			ok
		next
		return 0

	def _CapsByVector(paDecisions, pcVector)
		_out_ = []
		nLen = len(paDecisions)
		for i = 1 to nLen
			if paDecisions[i][2] = pcVector
				_out_ + paDecisions[i][1]
			ok
		next
		return _out_

	def _EngineKb(paDecisions)
		_kb_ = 0
		nLen = len(paDecisions)
		for i = 1 to nLen
			if paDecisions[i][2] = "engine"
				_kb_ += paDecisions[i][4]
			ok
		next
		return _kb_

	# the on-device engine artifact label per target class (inclusive)
	def _Label(pcVector, pcClass)
		if pcVector = "native"
			return "[platform]"
		but pcVector = "construct"
			return "[stz.js]"
		but pcVector = "server"
			return "[server]"
		but pcVector = "engine"
			if pcClass = "server"
				return "[engine]"
			but pcClass = "mcu"
				return "[firmware]"
			ok
			return "[stz.wasm]"
		ok
		return "[" + pcVector + "]"

	# the engine artifact name for a class (what the "engine carries" line names)
	def _EngineArtifact(pcClass)
		if pcClass = "mcu"
			return "firmware"
		but pcClass = "server"
			return "native engine"
		ok
		return "stz.wasm"

	# the delivery vector chosen for a capability in a part (data -- for checks)
	def VectorFor(pcPart, pcCap)
		_i_ = This._Idx(pcPart)
		if _i_ = 0
			return ""
		ok
		_cc_ = StzLower("" + pcCap)
		_decs_ = @aParts[_i_][5]
		nLen = len(_decs_)
		for k = 1 to nLen
			if _decs_[k][1] = _cc_
				return _decs_[k][2]
			ok
		next
		return ""

	# the capabilities compiled into a part's on-device engine (stz.wasm / firmware)
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
		_cst_ = 0
		_srv_ = 0
		nParts = len(@aParts)
		for i = 1 to nParts
			_p_ = @aParts[i]
			_class_ = _p_[4]
			_bEdge_ = (_class_ != "server")
			_c_ += nl + "  Part '" + _p_[1] + "' [" + _p_[2] + "] -> " + _p_[3] + " (" + _class_
			if _bEdge_
				_c_ += " / edge"
			ok
			_c_ += ")" + nl
			_decs_ = _p_[5]
			mLen = len(_decs_)
			for k = 1 to mLen
				_lbl_ = This._Label(_decs_[k][2], _class_)
				_c_ += "     " + StzPadRight(_decs_[k][1], 18) + " " + StzPadRight(_lbl_, 12) + _decs_[k][3] + nl
				_tot_++
				if _decs_[k][2] = "native"
					_nat_++
				but _decs_[k][2] = "engine"
					_eng_++
				but _decs_[k][2] = "construct"
					_cst_++
				but _decs_[k][2] = "server"
					_srv_++
				ok
			next
			if _bEdge_
				_engcaps_ = This._CapsByVector(_decs_, "engine")
				if len(_engcaps_) > 0
					_c_ += "     -> " + This._EngineArtifact(_class_) + " carries: " + @@(_engcaps_) + "  (~" + This._EngineKb(_decs_) + " KB, " + len(_engcaps_) + " of " + mLen + ")" + nl
				else
					_c_ += "     -> " + This._EngineArtifact(_class_) + ": nothing to ship (all native / construct / server)" + nl
				ok
			else
				_c_ += "     -> runs on the full native engine (server has everything)" + nl
			ok
		next
		_c_ += nl + "  Summary: " + _tot_ + " capabilities across " + nParts + " parts -> "
		_c_ += "platform " + _nat_ + ", engine " + _eng_ + ", construct " + _cst_ + ", server " + _srv_ + "." + nl
		_c_ += "  Build() will compile exactly this scope; Deploy() will commit it." + nl
		return _c_

	def Show()
		? This.Narration()
