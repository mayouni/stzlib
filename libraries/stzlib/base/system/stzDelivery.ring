#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZDELIVERY               #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The REASONING behind stzBuilder. You        #
#                  describe the SOLUTION you want to deploy    #
#                  -- its parts, their targets, the Softanza   #
#                  capabilities each uses -- the planner       #
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
# and the delivery planner reasons with it, bridging what the target cannot host (M5). The
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
#   oDelivery = new stzDelivery("restolean")
#   oDelivery.AddBackend(:api, :LinuxServer).AddSuperApp(:phone, :Android).AddFirmware(:node, :ESP32)
#   oDelivery.NeedsIn(:phone, [ :Unicode, :PivotTable, :ConstraintSolver, :Collection, :Neural ])
#   ? oDelivery.Plan().Show()

  #=============#
 #  FUNCTIONS  #
#=============#

func StzDeliveryQ(pcName)
	return new stzDelivery(pcName)

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

# The delivery planner's KNOWLEDGE: each capability's differential value, as data (not a
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
			[ "unicode",          "Unicode",          0, "compute",   "light",  "strong", "strong", "weak",     6 ],
			[ "datetime",         "DateTime",         0, "compute",   "light",  "strong", "strong", "weak",     4 ],
			[ "json",             "Json",             0, "ergonomic", "light",  "strong", "strong", "weak",     2 ],
			[ "http",             "Http",             0, "ergonomic", "light",  "strong", "strong", "absent",   3 ],
			[ "regex",            "Regex",            1,  "ergonomic", "medium", "strong", "strong", "absent",  20 ],
			[ "pattern",          "Pattern",          1,  "compute",   "light",  "absent", "strong", "weak",     5 ],
			[ "pivottable",       "PivotTable",       1,  "compute",   "medium", "weak",   "strong", "absent",  12 ],
			[ "constraintsolver", "ConstraintSolver", 1,  "compute",   "medium", "absent", "strong", "absent",  15 ],
			[ "graph",            "Graph",            1,  "compute",   "medium", "weak",   "strong", "absent",  10 ],
			[ "bignumber",        "BigNumber",        0, "compute",   "light",  "strong", "strong", "weak",     3 ],
			[ "gpio",             "GPIO",             1,  "compute",   "light",  "absent", "weak",   "strong",   1 ],
			[ "collection",       "Collection",       1,  "ergonomic", "light",  "weak",   "strong", "weak",     0 ],
			[ "neural",           "Neural",           0, "compute",   "heavy",  "weak",   "strong", "absent",  900 ]
		]

	def Records()
		return @aCaps

	def Has(pcName)
		return StzFindFirst(StzLower("" + pcName), This._Keys()) > 0

	def _Keys()
		_out_ = []
		_nLen_ = len(@aCaps)
		for i = 1 to _nLen_
			_out_ + @aCaps[i][1]
		next
		return _out_

	# unknown capability -> assume Softanza-differential compute, platform-weak.
	def Record(pcName)
		_c_ = StzLower("" + pcName)
		_nLen_ = len(@aCaps)
		for i = 1 to _nLen_
			if @aCaps[i][1] = _c_
				return @aCaps[i]
			ok
		next
		return [ _c_, "" + pcName, 1, "compute", "medium", "weak", "strong", "absent", 8 ]

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

	# (capability, target class) -> [ vector, reason ]. The whole reasoning, legibly.
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


  #====================#
 #  DELIVERY PLANNER  #
#====================#

class stzDelivery from stzObject

	@cName = ""
	@aParts = []       # [ name, kind, targetname, [caps] ]  -- plain data (survives copy)
	@oCat = ""
	@aBindings = []    # [ partName, siteObject ] -- WHERE each part deploys (production)
	@oActor = ""     # the executing actor -- governs whether Deploy(:Production) commits
	@aReqs = []        # [ partName, resourceSpec ] -- what each part NEEDS from its host
	@aBundles = []     # [ partName, emulatorOrDir ] -- emulator bundle to ship in production
	@oApp = ""       # the solution's app MODEL (stzAppTopology) -- what each part DOES
	@oLog = ""       # a structured stzLog of the delivery's high-level phases
	@oReg = ""       # the EXTERNAL-DEPENDENCY surface (stzServiceRegistry)
	@aSvcNeeds = []    # [ partName, [serviceNames] ] -- which part needs which service

	def init(pcName)
		@cName = "" + pcName
		@oCat = new stzCapabilityCatalog()
		@oLog = new stzLog("delivery")
		@oLog.SetLevel(:trace)

	def Name()
		return @cName

	# the structured log of the delivery's phases (Deploy). Queryable + renderable:
	# oDelivery.Log().AsJson(), oDelivery.Log().EntriesOfLevel(:error).
	def Log()
		return @oLog

	# attach the solution's application model -- named datasets + per-part roles.
	# The emulator renders each part FROM it (its real menu / computed dashboard),
	# instead of a shared placeholder.
	def SetAppTopology(poApp)
		This.SetAppTopologyQ(poApp)

	def SetAppTopologyQ(poApp)
		@oApp = poApp
		return This

	def AppTopology()
		return @oApp

	def HasAppTopology()
		return isObject(@oApp)

	def UseCatalog(poCat)
		@oCat = poCat
		return This

	def AddPart(pcKind, pcName, pcTarget)
		@aParts + [ StzLower("" + pcName), StzLower("" + pcKind), StzLower("" + pcTarget), [] ]
		return This

		def AddApp(pcName, pcTarget)
			return This.AddPart("app", pcName, pcTarget)
		def AddSuperApp(pcName, pcTarget)
			return This.AddPart("superapp", pcName, pcTarget)
		def AddBackend(pcName, pcTarget)
			return This.AddPart("backend", pcName, pcTarget)
		def AddServer(pcName, pcTarget)
			return This.AddPart("server", pcName, pcTarget)
		def AddFirmware(pcName, pcTarget)
			return This.AddPart("firmware", pcName, pcTarget)

	def _PartIndex(pcName)
		_c_ = StzLower("" + pcName)
		_nLen_ = len(@aParts)
		for i = 1 to _nLen_
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
			_nLen_ = len(paCaps)
			for k = 1 to _nLen_
				_caps_ + StzLower("" + paCaps[k])
			next
		ok
		@aParts[_i_][4] = _caps_
		return This

	  #-- the EXTERNAL-DEPENDENCY surface (service-virtualization phase 7) ---

	# Attach the solution's stzServiceRegistry, so the delivery plan can rehearse
	# every external dependency -- its current binding and the production
	# credential it will need -- BEFORE anything runs, and so Deploy(:Production)
	# can REFUSE a surface that still resolves to a fake.
	#
	# ONE CAVEAT, and it is Ring's, not this method's: an attribute store COPIES
	# (probed -- bind a service on your own handle afterwards and this delivery
	# will not see it). So either finish configuring the registry BEFORE attaching
	# it, or make later changes THROUGH the accessor, which reaches the stored
	# object: oDelivery.ServicesQ().BindLiveQ(:payments, oImpl, "stripe_key").
	def UseServices(poReg)
		This.UseServicesQ(poReg)

	def UseServicesQ(poReg)
		@oReg = poReg
		return This

	def ServicesQ()
		return @oReg

	def HasServices()
		return isObject(@oReg)

	# Which external services a part's code actually calls. The parallel of
	# NeedsIn (Softanza capabilities); this is the OUTSIDE world.
	def NeedsServiceIn(pcPart, paServices)
		return This.NeedsServiceInQ(pcPart, paServices)

	def NeedsServiceInQ(pcPart, paServices)
		if This._PartIndex(pcPart) = 0
			return This
		ok
		_p_ = StzLower("" + pcPart)
		_svcs_ = []
		if isList(paServices)
			_n_ = len(paServices)
			for _k_ = 1 to _n_
				_svcs_ + StzLower("" + paServices[_k_])
			next
		but isString(paServices)
			_svcs_ + StzLower("" + paServices)
		ok
		_n_ = len(@aSvcNeeds)
		for _i_ = 1 to _n_
			if @aSvcNeeds[_i_][1] = _p_
				@aSvcNeeds[_i_][2] = _svcs_
				return This
			ok
		next
		@aSvcNeeds + [ _p_, _svcs_ ]
		return This

	def ServiceNeedsIn(pcPart)
		_p_ = StzLower("" + pcPart)
		_n_ = len(@aSvcNeeds)
		for _i_ = 1 to _n_
			if @aSvcNeeds[_i_][1] = _p_
				return @aSvcNeeds[_i_][2]
			ok
		next
		return []

	def ServiceNeeds()
		return @aSvcNeeds

	# The rehearsed surface, one record per service:
	# [ :service, :posture, :secret, :bound, :parts ]
	# This is the answer to "what does shipping this actually require of me?",
	# available before a single byte is built.
	def ExternalDependencies()
		_aOut_ = []
		if NOT This.HasServices()
			return _aOut_
		ok
		_aNames_ = @oReg.DeclaredServices()
		_aB_ = @oReg.BoundServices()
		_nb_ = len(_aB_)
		for _i_ = 1 to _nb_
			if StzFindFirst(_aB_[_i_], _aNames_) = 0
				_aNames_ + _aB_[_i_]
			ok
		next
		_n_ = len(_aNames_)
		for _i_ = 1 to _n_
			_s_ = "" + _aNames_[_i_]
			_aOut_ + [ :service = _s_,
			           :posture = "" + @oReg.PostureOf(_s_),
			           :secret = "" + @oReg.SecretNameOf(_s_),
			           :bound = @oReg.Has(_s_),
			           :parts = This._PartsNeeding(_s_) ]
		next
		return _aOut_

	def NumberOfExternalDependencies()
		return len( This.ExternalDependencies() )

	# The credentials a production deploy will require -- names only, never values.
	def ProductionCredentials()
		_aOut_ = []
		_a_ = This.ExternalDependencies()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if _a_[_i_][:secret] != ""
				_aOut_ + _a_[_i_][:secret]
			ok
		next
		return _aOut_

	# REHEARSE THE GATE. The registry only reports sandbox-in-production once its
	# phase IS production, so a pre-flight check asks the question in that frame
	# and then puts the phase back -- you learn what shipping would say without
	# declaring that you are shipping. (The plane's own habit: rehearse, then
	# commit.)
	def ServiceFindingsForProduction()
		if NOT This.HasServices()
			return []
		ok
		_cWas_ = "" + @oReg.Phase()
		@oReg.SetPhaseQ(:production)
		_aF_ = @oReg.Findings()
		@oReg.SetPhaseQ(_cWas_)
		return _aF_

	def ServicesAreProductionReady()
		_aF_ = This.ServiceFindingsForProduction()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = :error
				return 0
			ok
		next
		return 1

	def WhyServicesNotReady()
		_aF_ = This.ServiceFindingsForProduction()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if _aF_[_i_][:severity] = :error
				return _aF_[_i_][:invariant] + ": " + _aF_[_i_][:message]
			ok
		next
		return ""

	def _PartsNeeding(pcService)
		_s_ = StzLower("" + pcService)
		_aOut_ = []
		_n_ = len(@aSvcNeeds)
		for _i_ = 1 to _n_
			if StzFindFirst(_s_, @aSvcNeeds[_i_][2]) > 0
				_aOut_ + @aSvcNeeds[_i_][1]
			ok
		next
		return _aOut_

	# Project parts AND services into one graph, so a rule can ask the question
	# neither side can answer alone: does a part that is BOUND TO A SITE (i.e.
	# destined for production) depend on a service that is still a fake?
	# See stzServiceRuleSet.
	def AsRuleGraph()
		_oG_ = new stzGraph("delivery-rules")
		if This.HasServices()
			_oG_ = @oReg.AsRuleGraph()
		ok
		_n_ = len(@aParts)
		for _i_ = 1 to _n_
			_id_ = "part:" + @aParts[_i_][1]
			if NOT _oG_.NodeExists(_id_)
				_oG_.AddNode(_id_)
			ok
			_oG_.SetNodeProperty(_id_, "kind", "part")
			_oG_.SetNodeProperty(_id_, "part", @aParts[_i_][1])
			_oG_.SetNodeProperty(_id_, "partkind", @aParts[_i_][2])
			_oG_.SetNodeProperty(_id_, "target", @aParts[_i_][3])
			# a part with a SITE binding is destined for a real host
			_dest_ = "unbound"
			if This._BindingIndex(@aParts[_i_][1]) > 0
				_dest_ = "production"
			ok
			_oG_.SetNodeProperty(_id_, "destination", _dest_)
			_aS_ = This.ServiceNeedsIn(@aParts[_i_][1])
			_m_ = len(_aS_)
			for _k_ = 1 to _m_
				_sid_ = "service:" + _aS_[_k_]
				if NOT _oG_.NodeExists(_sid_)
					_oG_.AddNode(_sid_)
					_oG_.SetNodeProperty(_sid_, "kind", "service")
					_oG_.SetNodeProperty(_sid_, "service", _aS_[_k_])
					_oG_.SetNodeProperty(_sid_, "posture", "undeclared")
				ok
				if NOT _oG_.EdgeExists(_id_, _sid_)
					_oG_.AddEdgeXTT(_id_, _sid_, "depends-on", [ :type = "service" ])
				ok
			next
		next
		return _oG_

	def _BindingIndex(pcPart)
		_p_ = StzLower("" + pcPart)
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			if StzLower("" + @aBindings[_i_][1]) = _p_
				return _i_
			ok
		next
		return 0

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
		_nLen_ = len(_aMap_)
		for i = 1 to _nLen_
			if StzFindFirst(_aMap_[i][1], pcSrc) > 0 and StzFindFirst(_aMap_[i][2], _found_) = 0
				_found_ + _aMap_[i][2]
			ok
		next
		return _found_

	# WHERE each part deploys in production: bind a target site to the part it hosts.
	# Site-first, part-second -- demystified: "deploy to <site>, the <part>".
	# (Deploy(:Emulated) needs no sites -- it runs in the browser; production does.)
	def DeployTo(poSite, pcPart)
		@aBindings + [ StzLower("" + pcPart), poSite ]
		return This

	# the executing actor -- governs whether Deploy(:Production) COMMITS or only
	# rehearses (only an effectful actor may cross the governed bridge to reality).
	def SetActor(poActor)
		@oActor = poActor
		return This

	def Bindings()
		return @aBindings

	def DeploymentActor()
		return @oActor

	# what a part NEEDS from its host: memory / compute / storage (a stzResourceSpec).
	# Parallels NeedsIn (capabilities); here it is the physical footprint the target
	# must provide -- the CI/IaC "resources.requests" idea.
	def RequiresIn(pcPart, poSpec)
		@aReqs + [ StzLower("" + pcPart), poSpec ]
		return This

	def RequirementFor(pcPart)
		_c_ = StzLower("" + pcPart)
		_nLen_ = len(@aReqs)
		for i = 1 to _nLen_
			if @aReqs[i][1] = _c_
				return @aReqs[i][2]
			ok
		next
		return ""

	def Requirements()
		return @aReqs

	# ship an emulator's bundle DIRECTORY as a part's production artifact. The bundle
	# you built and debugged with Deploy(:Emulated) becomes what Deploy(:Production)
	# ships -- the same tree, one directive. pBundle is a stzEmulator or a dir path.
	def ShipBundle(pcPart, pBundle)
		@aBundles + [ StzLower("" + pcPart), pBundle, "bundle" ]
		return This

	# ship only pcPart's SLICE of the bundle -- its app (index.html) + engine subset
	# (stz_<part>.wasm) + the bridge (stz.js), not the whole mission-control. A
	# frontend deploys only what it needs to run.
	def ShipSlice(pcPart, pBundle)
		@aBundles + [ StzLower("" + pcPart), pBundle, "slice" ]
		return This

	def Bundles()
		return @aBundles

	# REHEARSE the placement & scope plan -- no bytes built. This is Build()'s
	# thinking made visible (VSF rehearse->plan->commit).
	def Plan()
		_oPlan_ = new stzBuildPlan(@cName)
		_nLen_ = len(@aParts)
		for i = 1 to _nLen_
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
		# the OUTSIDE world, rehearsed alongside the capabilities (phase 7)
		_oPlan_.SetExternalDependenciesQ( This.ExternalDependencies() )
		return _oPlan_

	# Deploy() covers BOTH phases (Scope-Oriented: the deploy scope is the frame).
	#   :Emulated   -> the programming phase: generate the web-based mission-control
	#                  emulator (via stzEmulator) where the whole solution runs and
	#                  is debugged visually, part by part.
	#   :Production  -> the same parts cross the governed bridge to real target SITES.
	#                  Deploy(:Production) DRIVES a stzDeployment: it binds each part to
	#                  its site (from DeployTo) and, IF the actor may commit (effectful),
	#                  STORES + LAUNCHES it -- otherwise it returns the deployment as a
	#                  rehearsal. Emulation rehearses in the browser; production commits.
	def Deploy(pMode)
		_m_ = StzLower("" + pMode)
		if _m_ = "emulated" or _m_ = ":emulated"
			@oLog.Record(:info, "deploy(:emulated) -- building the mission-control bundle", [ [ :parts, len(@aParts) ] ])
			_oEmu_ = new stzEmulator(This)
			_oEmu_.Build()
			@oLog.Record(:info, "emulator bundle built", [])
			return _oEmu_
		but _m_ = "production" or _m_ = ":production"
			return This._DeployProduction()
		ok
		return This.Plan()

	# assemble the stzDeployment from the delivery planner's bindings + actor, and perform it
	# when governance permits (commit); else return it un-committed (a rehearsal).
	def _DeployProduction()
		@oLog.Record(:info, "deploy(:production) started", [ [ :actor, This._ActorName() ], [ :bindings, len(@aBindings) ] ])
		_oDep_ = new stzDeployment(This)
		# THE SERVICE GATE (phase 7). Crossing into production is exactly the
		# moment the external surface must be real, so ask here rather than
		# trusting anyone to have remembered. An unsound surface is refused even
		# when the actor is fully entitled: this is not an authority question.
		_bSvcOk_ = 1
		if This.HasServices()
			@oReg.SetPhaseQ(:production)
			_aSvcF_ = @oReg.Findings()
			if NOT @oReg.IsSound()
				_bSvcOk_ = 0
				@oLog.Record(:error, "REFUSED -- the external surface is not production-ready",
				             [ [ :findings, len(_aSvcF_) ] ])
				_n_ = len(_aSvcF_)
				for _i_ = 1 to _n_
					if _aSvcF_[_i_][:severity] = :error
						@oLog.Record(:error, "" + _aSvcF_[_i_][:invariant] + " @ " +
						             _aSvcF_[_i_][:where], [ [ :why, _aSvcF_[_i_][:message] ] ])
						# Incident I2: one event per UNSOUND SERVICE, not one
						# per refused deploy -- the incident's Subjects() then
						# names which services were still fake, which is the
						# question a post-mortem asks. Recorded here, at the
						# refusal, and NOT inside MayGoLive: that one is a
						# preflight anyone may ask speculatively, and a
						# predicate that writes evidence would fill the ledger
						# with questions instead of events.
						StzNoteRefusal("service.production_fake_refused",
							This._ActorName(),
							"service:" + _aSvcF_[_i_][:where],
							"" + _aSvcF_[_i_][:invariant] + ": " + _aSvcF_[_i_][:message])
					ok
				next
			else
				@oLog.Record(:info, "external surface is production-ready",
				             [ [ :services, @oReg.NumberOfBound() ] ])
			ok
		ok
		if @oActor != ""
			_oDep_.SetActor(@oActor)
		ok
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_oDep_.SetTarget(@aBindings[_i_][1], @aBindings[_i_][2])
		next
		_nb_ = len(@aBundles)
		for _i_ = 1 to _nb_
			if @aBundles[_i_][3] = "slice"
				_oDep_.AttachSlice(@aBundles[_i_][1], @aBundles[_i_][2])   # only the part's slice
			else
				_oDep_.AttachBundle(@aBundles[_i_][1], @aBundles[_i_][2])  # the whole bundle
			ok
		next
		if NOT _bSvcOk_
			@oLog.Record(:warn, "returning a rehearsal -- flip the sandboxes to real bindings first", [])
			return _oDep_
		ok
		if _oDep_.MayCommit()
			@oLog.Record(:info, "governance permits commit -- executing the plan", [])
			_oDep_.Run()   # execute the ordered plan (store -> launch -> verify), transactional
			@oLog.Record(:info, "production deploy committed", [])
		else
			@oLog.Record(:warn, "no effectful actor -- returning a rehearsal (nothing committed)", [])
		ok
		return _oDep_

	def _ActorName()
		if isObject(@oActor)
			return @oActor.Name()
		ok
		return "(none)"


  #==============#
 #  BUILD PLAN  #
#==============#

# The rehearsed placement & scope plan -- the delivery planner's readable output. Per part:
# every capability, its delivery vector, and the reason; plus the derived on-device
# engine subset. Plain-data backed; Explain() is the legible signature (named
# Explain, not Narration, to avoid confusion with stzNarration).
class stzBuildPlan from stzObject

	@cName = ""
	@aParts = []   # [ name, kind, tname, class, [ [key, display, vector, reason, kb], ... ] ]
	@aExtDeps = [] # [ [ :service, :posture, :secret, :bound, :parts ], ... ] (phase 7)

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	def AddPart(pcName, pcKind, pcTName, pcClass, paDecisions)
		@aParts + [ pcName, pcKind, pcTName, pcClass, paDecisions ]
		return This

	  #-- the external surface, rehearsed with the capabilities (phase 7) ----

	def SetExternalDependencies(paDeps)
		This.SetExternalDependenciesQ(paDeps)

	def SetExternalDependenciesQ(paDeps)
		@aExtDeps = paDeps
		return This

	def ExternalDependencies()
		return @aExtDeps

	def NumberOfExternalDependencies()
		return len(@aExtDeps)

	# the credential NAMES a production deploy will require -- never values
	def ProductionCredentials()
		_aOut_ = []
		_n_ = len(@aExtDeps)
		for _i_ = 1 to _n_
			if ("" + @aExtDeps[_i_][:secret]) != ""
				_aOut_ + @aExtDeps[_i_][:secret]
			ok
		next
		return _aOut_

	# the dependencies that are still fakes -- i.e. what stands between this plan
	# and a production deploy
	def SandboxedDependencies()
		_aOut_ = []
		_n_ = len(@aExtDeps)
		for _i_ = 1 to _n_
			if ("" + @aExtDeps[_i_][:posture]) = "sandbox"
				_aOut_ + @aExtDeps[_i_][:service]
			ok
		next
		return _aOut_

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
		_nLen_ = len(@aParts)
		for i = 1 to _nLen_
			if @aParts[i][1] = _c_
				return i
			ok
		next
		return 0

	def _KeysByVector(paDecisions, pcVector)
		_out_ = []
		_nLen_ = len(paDecisions)
		for i = 1 to _nLen_
			if paDecisions[i][3] = pcVector
				_out_ + paDecisions[i][1]
			ok
		next
		return _out_

	def _DisplaysByVector(paDecisions, pcVector)
		_out_ = []
		_nLen_ = len(paDecisions)
		for i = 1 to _nLen_
			if paDecisions[i][3] = pcVector
				_out_ + paDecisions[i][2]
			ok
		next
		return _out_

	def _EngineKb(paDecisions)
		_kb_ = 0
		_nLen_ = len(paDecisions)
		for i = 1 to _nLen_
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
		_nLen_ = len(_decs_)
		for k = 1 to _nLen_
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

		# THE OUTSIDE WORLD (phase 7): the same rehearsal, for dependencies you do
		# not own. Read before building, not after deploying.
		_nd_ = len(@aExtDeps)
		if _nd_ > 0
			_c_ += nl + "  External dependencies (" + _nd_ + "):" + nl
			for _i_ = 1 to _nd_
				_d_ = @aExtDeps[_i_]
				_c_ += "     " + StzPadRight("" + _d_[:service], 14) +
				       StzPadRight("" + _d_[:posture], 10)
				if ("" + _d_[:secret]) != ""
					_c_ += "needs secret '" + _d_[:secret] + "'"
				but NOT _d_[:bound]
					_c_ += "NOT BOUND"
				but ("" + _d_[:posture]) = "sandbox"
					_c_ += "a FAKE -- must be flipped before production"
				else
					_c_ += "no credential required"
				ok
				if len(_d_[:parts]) > 0
					_c_ += "   <- " + @@(_d_[:parts])
				ok
				_c_ += nl
			next
			_aSb_ = This.SandboxedDependencies()
			_aCr_ = This.ProductionCredentials()
			if len(_aSb_) > 0
				_c_ += "     => " + len(_aSb_) + " still a fake: " + @@(_aSb_) +
				       " -- Deploy(:Production) will REFUSE until these are real." + nl
			else
				_c_ += "     => nothing fake remains." + nl
			ok
			if len(_aCr_) > 0
				_c_ += "     => production will require these credentials: " + @@(_aCr_) + nl
			ok
		ok

		_c_ += "  Build() will compile exactly this scope; Deploy() will commit it." + nl
		return StzSplit(_c_, nl)   # a list of lines -- caller formats; Show() prints

	def Show()
		_aLines_ = This.Explain()
		_n_ = len(_aLines_)
		for _i_ = 1 to _n_
			? _aLines_[_i_]
		next
