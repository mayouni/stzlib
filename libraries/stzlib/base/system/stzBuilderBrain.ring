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
# differently per target -- :PivotTable is stz.wasm on a browser, FIRMWARE on an
# MCU, the native engine on a server. Name the target scope (each part's target)
# and the brain reasons with it, bridging what the target cannot host (M5). The
# DIFFERENTIAL-VALUE test decides: the edge carries only what is critical AND
# (Softanza-unique OR weak/absent on the target). A browser is strong at Unicode
# -> use its own; it lacks Softanza's solver/pivot/pattern -> those go on-device.
#
# Capabilities are named in the Softanza style -- :PivotTable, :ConstraintSolver
# (each maps to a module or a granular class of one). Ring lowercases the symbol
# to its key ("pivottable"); the catalog carries the readable name for display.
#
# Four delivery vectors, inclusive across targets:
#   native    -> the target-platform does it well; ship nothing (a browser's Unicode).
#   engine    -> Softanza-differential compute, in the target's on-device form:
#                stz.wasm (browser/mobile), FIRMWARE (mcu), the native engine (server).
#   construct -> ergonomic Softanza construct in the target language (stz.js on the web).
#   server    -> too heavy for the edge -> the backend.
#
#   oBrain = new stzBuilderBrain("restolean")
#   oBrain.WithBackend(:api, :LinuxServer).WithSuperApp(:phone, :Android).WithFirmware(:node, :ESP32)
#   oBrain.NeedsIn(:phone, [ :Unicode, :PivotTable, :ConstraintSolver, :Collection, :Neural ])
#   ? oBrain.Plan().Explain()

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
# [ key, display, unique, nature, weight, js, native, embedded, kb ]: key = the
# Softanza-named symbol lowercased (:PivotTable -> "pivottable"), display = the
# readable name; support strong/weak/absent; nature compute/ergonomic; weight
# light/medium/heavy. Each maps to a module or a granular class.
class stzCapabilityCatalog from stzObject

	@aCaps = []

	def init()
		This._SeedDefaults()

	def _SeedDefaults()
		@aCaps = [
			[ "unicode",          "Unicode",          FALSE, "compute",   "light",  "strong", "strong", "weak",     6 ],
			[ "datetime",         "DateTime",         FALSE, "compute",   "light",  "strong", "strong", "weak",     4 ],
			[ "json",             "Json",             FALSE, "ergonomic", "light",  "strong", "strong", "weak",     2 ],
			[ "http",             "Http",             FALSE, "ergonomic", "light",  "strong", "strong", "absent",   3 ],
			[ "regex",            "Regex",            TRUE,  "compute",   "medium", "weak",   "strong", "absent",  20 ],
			[ "pattern",          "Pattern",          TRUE,  "compute",   "light",  "absent", "strong", "weak",     5 ],
			[ "pivottable",       "PivotTable",       TRUE,  "compute",   "medium", "weak",   "strong", "absent",  12 ],
			[ "constraintsolver", "ConstraintSolver", TRUE,  "compute",   "medium", "absent", "strong", "absent",  15 ],
			[ "graph",            "Graph",            TRUE,  "compute",   "medium", "weak",   "strong", "absent",  10 ],
			[ "bignumber",        "BigNumber",        FALSE, "compute",   "light",  "weak",   "strong", "weak",     3 ],
			[ "gpio",             "GPIO",             TRUE,  "compute",   "light",  "absent", "weak",   "strong",   1 ],
			[ "collection",       "Collection",       TRUE,  "ergonomic", "light",  "weak",   "strong", "weak",     0 ],
			[ "neural",           "Neural",           FALSE, "compute",   "heavy",  "weak",   "strong", "absent",  900 ]
		]

	def Records()
		return @aCaps

	def Has(pcName)
		return StzFindFirst(StzLower("" + pcName), This._Keys()) > 0

	def _Keys()
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
		return [ _c_, "" + pcName, TRUE, "compute", "medium", "weak", "strong", "absent", 8 ]

	def DisplayOf(pcName)
		return This.Record(pcName)[2]

	def SizeOf(pcName)
		return This.Record(pcName)[9]

	def _SupportFor(paRec, pcClass)
		if pcClass = "server"
			return paRec[7]    # native
		but pcClass = "mcu"
			return paRec[8]    # embedded
		ok
		return paRec[6]        # js (browser / mobile)

	# (capability, target class) -> [ vector, reason ]. The whole brain, legibly.
	# Inclusive across targets: a server hosts the native engine; the heavy is
	# offloaded; a strong non-unique capability defers to the target-platform;
	# ergonomics on a language-runtime target become a construct, else fold into
	# the engine. The reason keeps the capability's readable name.
	def VectorFor(pcCap, pcClass)
		_r_ = This.Record(pcCap)
		_disp_ = _r_[2]
		_bUnique_ = _r_[3]
		_cNature_ = _r_[4]
		_cWeight_ = _r_[5]
		_cSupp_ = This._SupportFor(_r_, pcClass)

		if pcClass = "server"
			return [ "engine", _disp_ + ": the server hosts the native engine" ]
		ok
		if _cWeight_ = "heavy"
			return [ "server", _disp_ + ": heavy -> runs on the backend, not the edge" ]
		ok
		if _cSupp_ = "strong" and NOT _bUnique_
			return [ "native", _disp_ + ": the target-platform is strong at it -> use its own" ]
		ok
		if _cNature_ = "ergonomic" and (pcClass = "browser" or pcClass = "mobile")
			return [ "construct", _disp_ + ": ergonomic -> a Softanza construct in the target language" ]
		ok
		return [ "engine", _disp_ + ": Softanza-differential, " + pcClass + " " + _cSupp_ + " -> the on-device engine" ]


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

	# declare the Softanza capabilities a part's code uses (:PivotTable, :Unicode,
	# ...). Stored as lowercased keys (the canonical form).
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

	# a first inference: scan the app source for capability markers -> keys.
	# Upgradeable to the stzCodeGraph call-edge analysis (lexical starting point).
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
			[ "Pivot",      "pivottable" ],
			[ "GroupBy",    "pivottable" ],
			[ "Solve",      "constraintsolver" ],
			[ "Constraint", "constraintsolver" ],
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
				_key_ = _caps_[k]
				_v_ = @oCat.VectorFor(_key_, _class_)
				_decisions_ + [ _key_, @oCat.DisplayOf(_key_), _v_[1], _v_[2], @oCat.SizeOf(_key_) ]
			next
			_oPlan_.AddPart(_name_, _kind_, _tname_, _class_, _decisions_)
		next
		return _oPlan_

	# Deploy() covers BOTH phases (Scope-Oriented: the deploy scope is the frame).
	#   :Emulated   -> the programming phase: generate the web-based mission-control
	#                  emulator (via stzEmulator) where the whole solution runs and
	#                  is debugged visually, part by part.
	#   :Production  -> the same parts cross the governed bridge to real targets; the
	#                  plan IS the production spec the lowering/platform path executes.
	def Deploy(pMode)
		_m_ = StzLower("" + pMode)
		if _m_ = "emulated" or _m_ = ":emulated"
			_oEmu_ = new stzEmulator(This)
			_oEmu_.Build()
			return _oEmu_
		ok
		return This.Plan()


  #==============#
 #  BUILD PLAN  #
#==============#

# The rehearsed placement & scope plan -- the brain's readable output. Per part:
# every capability, its delivery vector, and the reason; plus the derived on-device
# engine subset. Plain-data backed; Explain() is the legible signature (named
# Explain, not Narration, to avoid confusion with stzNarration).
class stzBuildPlan from stzObject

	@cName = ""
	@aParts = []   # [ name, kind, tname, class, [ [key, display, vector, reason, kb], ... ] ]

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	def AddPart(pcName, pcKind, pcTName, pcClass, paDecisions)
		@aParts + [ pcName, pcKind, pcTName, pcClass, paDecisions ]
		return This

	def NumberOfParts()
		return len(@aParts)

	# the raw per-part decisions -- consumed by stzEmulator to render each part.
	def Parts()
		return @aParts

	# the on-device delivery label for a vector + class (public: the emulator reuses it)
	def LabelFor(pcVector, pcClass)
		return This._Label(pcVector, pcClass)

	def _Idx(pcName)
		_c_ = StzLower("" + pcName)
		nLen = len(@aParts)
		for i = 1 to nLen
			if @aParts[i][1] = _c_
				return i
			ok
		next
		return 0

	def _KeysByVector(paDecisions, pcVector)
		_out_ = []
		nLen = len(paDecisions)
		for i = 1 to nLen
			if paDecisions[i][3] = pcVector
				_out_ + paDecisions[i][1]
			ok
		next
		return _out_

	def _DisplaysByVector(paDecisions, pcVector)
		_out_ = []
		nLen = len(paDecisions)
		for i = 1 to nLen
			if paDecisions[i][3] = pcVector
				_out_ + paDecisions[i][2]
			ok
		next
		return _out_

	def _EngineKb(paDecisions)
		_kb_ = 0
		nLen = len(paDecisions)
		for i = 1 to nLen
			if paDecisions[i][3] = "engine"
				_kb_ += paDecisions[i][5]
			ok
		next
		return _kb_

	# the on-device delivery label per target class (inclusive). "target" (not
	# "platform") -- to avoid confusion with stzPlatform.
	def _Label(pcVector, pcClass)
		if pcVector = "native"
			return "[target]"
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

	# the delivery vector chosen for a capability in a part (data -- for checks).
	# Case-insensitive on the key: :PivotTable matches the stored "pivottable".
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
				return _decs_[k][3]
			ok
		next
		return ""

	# the capability KEYS compiled into a part's on-device engine (stz.wasm/firmware)
	def EngineCapsFor(pcPart)
		_i_ = This._Idx(pcPart)
		if _i_ = 0
			return []
		ok
		return This._KeysByVector(@aParts[_i_][5], "engine")

	def EngineKbFor(pcPart)
		_i_ = This._Idx(pcPart)
		if _i_ = 0
			return 0
		ok
		return This._EngineKb(@aParts[_i_][5])

	def Explain()
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
				_lbl_ = This._Label(_decs_[k][3], _class_)
				_c_ += "     " + StzPadRight(_decs_[k][2], 18) + " " + StzPadRight(_lbl_, 12) + _decs_[k][4] + nl
				_tot_++
				if _decs_[k][3] = "native"
					_nat_++
				but _decs_[k][3] = "engine"
					_eng_++
				but _decs_[k][3] = "construct"
					_cst_++
				but _decs_[k][3] = "server"
					_srv_++
				ok
			next
			if _bEdge_
				_engnames_ = This._DisplaysByVector(_decs_, "engine")
				if len(_engnames_) > 0
					_c_ += "     -> " + This._EngineArtifact(_class_) + " carries: " + @@(_engnames_) + "  (~" + This._EngineKb(_decs_) + " KB, " + len(_engnames_) + " of " + mLen + ")" + nl
				else
					_c_ += "     -> " + This._EngineArtifact(_class_) + ": nothing to ship (all target / construct / server)" + nl
				ok
			else
				_c_ += "     -> runs on the full native engine (server has everything)" + nl
			ok
		next
		_c_ += nl + "  Summary: " + _tot_ + " capabilities across " + nParts + " parts -> "
		_c_ += "target " + _nat_ + ", engine " + _eng_ + ", construct " + _cst_ + ", server " + _srv_ + "." + nl
		_c_ += "  Build() will compile exactly this scope; Deploy() will commit it." + nl
		return _c_

	def Show()
		? This.Explain()
