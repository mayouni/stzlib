#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZDEPLOYMENT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Deployment as a first-class story: from     #
#                  DEFINITION (the brain's plan) and EMULATION #
#                  (Deploy(:Emulated)) to STORAGE and LAUNCH   #
#                  of the solution on real target sites.       #
#                                                              #
#                  A stzDeploymentSite is a config-described   #
#                  DESTINATION -- a "target repo" -- reached   #
#                  and controlled through its access CONFIG    #
#                  (connection + storage + protocol/control).  #
#                  The config is the LINK that makes the site  #
#                  accessible from the programming environment.#
#                                                              #
#                  A stzDeployment sends each part of the      #
#                  solution to its site, stores it, launches   #
#                  it, and reports back -- all GOVERNED: only  #
#                  an effectful actor commits (an LLM actor    #
#                  may rehearse but touches nothing).          #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#--------------------------------------------------------------#
#
#   oServer = StzDeploymentSiteQ("prod-api").Kind(:Server) ;
#             .Endpoint("deploy@api.restolean.app:/srv/api").Via(:ssh) ;
#             .AuthRef("env/DEPLOY_KEY").StoreAt("/d/tmp/site_api")
#   oDep = new stzDeployment(oBrain).AsActor(HumanActor("ops"))
#   oDep.To(:api, oServer)
#   ? oDep.Explain()
#   oDep.Store()  oDep.Launch()  ? @@( oDep.Status() )

  #=============#
 #  FUNCTIONS  #
#=============#

func StzDeploymentSiteQ(pcName)
	return new stzDeploymentSite(pcName)

func StzDeploymentQ(poBrain)
	return new stzDeployment(poBrain)

# a site KIND -> its default access protocol (a thin classifier, not a primitive)
func _StzSiteDefaultProtocol(pcKind)
	_k_ = StzLower(ring_trim("" + pcKind))
	if _k_ = "localrepo" or _k_ = "local"
		return "file"
	but _k_ = "server"
		return "ssh"
	but _k_ = "gitrepo" or _k_ = "git"
		return "git"
	but _k_ = "registry"
		return "https"
	but _k_ = "device"
		return "serial"
	but _k_ = "objectstore"
		return "https"
	ok
	return "file"

func _StzSiteOr(pcVal, pcDefault)
	if isString(pcVal) and pcVal != ""
		return pcVal
	ok
	return pcDefault


  #====================#
 #  DEPLOYMENT SITE    #
#====================#

# A config-described deployment destination (a "target repo"). It carries the
# ACCESS config -- connection (endpoint/protocol/auth), storage, control -- that
# makes it reachable and controllable from the programming environment. Distinct
# from stzSystemProfile (which says what a target CAN DO): this says how to REACH
# and DRIVE it. Backend-dispatched by kind; :LocalRepo works end to end here, and
# the config generalizes to real backends (server/git/registry/device) unchanged.
class stzDeploymentSite from stzObject

	@cName = ""
	@cKind = "localrepo"
	@cEndpoint = ""
	@cProtocol = ""
	@cAuthRef = ""
	@cStorage = ""
	@cLaunch = ""
	@cStatusCmd = ""

	def init(pcName)
		@cName = "" + pcName

	  #-- the access config (fluent) -------------------------

	def Kind(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	def Endpoint(pcUrl)
		@cEndpoint = "" + pcUrl
		return This

	def Via(pcProtocol)
		@cProtocol = StzLower(ring_trim("" + pcProtocol))
		return This

	def AuthRef(pcRef)
		@cAuthRef = "" + pcRef
		return This

	def StoreAt(pcLocation)
		@cStorage = "" + pcLocation
		return This

	def LaunchWith(pcCmd)
		@cLaunch = "" + pcCmd
		return This

	def StatusWith(pcCmd)
		@cStatusCmd = "" + pcCmd
		return This

	  #-- reads ----------------------------------------------

	def Name()
		return @cName

	def KindName()
		return @cKind

	def EndpointOf()
		return @cEndpoint

	def Protocol()
		if @cProtocol != ""
			return @cProtocol
		ok
		return _StzSiteDefaultProtocol(@cKind)

	def AuthReference()
		return @cAuthRef

	def StorageLocation()
		return @cStorage

	def IsLocal()
		return @cKind = "localrepo" or @cKind = "local"

	# the access config as inspectable DATA -- the LINK between the programming
	# environment and this site (connection + storage + control).
	def Config()
		return [
			[ "name",    @cName ],
			[ "kind",    @cKind ],
			[ "connection", [ [ "endpoint", @cEndpoint ], [ "protocol", This.Protocol() ], [ "auth", @cAuthRef ] ] ],
			[ "storage", @cStorage ],
			[ "control", [ [ "launch", @cLaunch ], [ "status", @cStatusCmd ] ] ]
		]

	def ConfigText()
		_c_ = "site '" + @cName + "' [" + @cKind + "]" + nl
		_c_ += "  connection: " + This.Protocol() + " -> " + _StzSiteOr(@cEndpoint, "(local)")
		if @cAuthRef != ""
			_c_ += "   auth: " + @cAuthRef
		ok
		_c_ += nl
		_c_ += "  storage:    " + _StzSiteOr(@cStorage, "(unset)") + nl
		if @cLaunch != ""
			_c_ += "  launch:     " + @cLaunch + nl
		ok
		return _c_

	# the config, serialized -- so a target site can be SAVED, versioned, shared:
	# the persistent link the dev/emulation environment reads to reach a site.
	def ConfigJson()
		_q_ = char(34)
		_c_ = "{" + nl
		_c_ += "  " + _q_ + "name" + _q_ + ": " + _q_ + @cName + _q_ + "," + nl
		_c_ += "  " + _q_ + "kind" + _q_ + ": " + _q_ + @cKind + _q_ + "," + nl
		_c_ += "  " + _q_ + "connection" + _q_ + ": { " + _q_ + "endpoint" + _q_ + ": " + _q_ + @cEndpoint + _q_
		_c_ += ", " + _q_ + "protocol" + _q_ + ": " + _q_ + This.Protocol() + _q_
		_c_ += ", " + _q_ + "auth" + _q_ + ": " + _q_ + @cAuthRef + _q_ + " }," + nl
		_c_ += "  " + _q_ + "storage" + _q_ + ": " + _q_ + @cStorage + _q_ + "," + nl
		_c_ += "  " + _q_ + "control" + _q_ + ": { " + _q_ + "launch" + _q_ + ": " + _q_ + @cLaunch + _q_
		_c_ += ", " + _q_ + "status" + _q_ + ": " + _q_ + @cStatusCmd + _q_ + " }" + nl
		_c_ += "}" + nl
		return _c_

	def SaveConfigTo(pcPath)
		write("" + pcPath, This.ConfigJson())
		return This

	  #-- access + control (backend-dispatched by kind) ------

	# LocalRepo works end to end. Remote kinds declare their config now; their live
	# probe/transfer is the next slice (the config model does not change).
	def Reachable()
		if This.IsLocal()
			return @cStorage != ""
		ok
		return @cEndpoint != ""

	# place each artifact ([ relname, content ]) into the site's storage.
	def Store(paArtifacts)
		if NOT This.IsLocal()
			return FALSE
		ok
		if @cStorage = ""
			return FALSE
		ok
		StzEngineDirCreatePath(@cStorage)
		_n_ = len(paArtifacts)
		for _i_ = 1 to _n_
			write(@cStorage + "/" + paArtifacts[_i_][1], "" + paArtifacts[_i_][2])
		next
		write(@cStorage + "/.stzsite", "state=stored" + nl + "kind=" + @cKind + nl)
		return TRUE

	def Launch()
		if NOT This.IsLocal()
			return FALSE
		ok
		if @cStorage = "" or StzEngineFileExists(@cStorage + "/.stzsite") = 0
			return FALSE
		ok
		_rec_ = "state=launched" + nl + "kind=" + @cKind + nl
		if @cLaunch != ""
			_rec_ += "launch=" + @cLaunch + nl
		ok
		write(@cStorage + "/.stzsite", _rec_)
		return TRUE

	def Status()
		if This.IsLocal() and @cStorage != "" and StzEngineFileExists(@cStorage + "/.stzsite") = 1
			_c_ = read(@cStorage + "/.stzsite")
			if StzFindFirst("state=launched", _c_) > 0
				return "launched"
			ok
			return "stored"
		ok
		return "absent"

	def Show()
		? This.ConfigText()


  #================#
 #  DEPLOYMENT     #
#================#

# The act of placing a solution onto sites: bind each part to a target site, then
# store / launch / report -- GOVERNED. Reality-touching ops (Store/Launch) require
# an actor that Can("effectful"); an inference-only actor (an LLM) may rehearse the
# plan but commits nothing. This is the same governance crossing the rest of the
# System Foundation uses: expression is free, admission is governed.
class stzDeployment from stzObject

	@oBrain = NULL
	@aBindings = []   # [ partName, siteObject ]
	@oActor = NULL

	def init(poBrain)
		@oBrain = poBrain

	def To(pcPart, poSite)
		@aBindings + [ StzLower("" + pcPart), poSite ]
		return This

		def Send(pcPart, poSite)
			return This.To(pcPart, poSite)

	def AsActor(poActor)
		@oActor = poActor
		return This

	def Bindings()
		return @aBindings

	def NumberOfBindings()
		return len(@aBindings)

	def SiteFor(pcPart)
		_c_ = StzLower("" + pcPart)
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			if @aBindings[_i_][1] = _c_
				return @aBindings[_i_][2]
			ok
		next
		return NULL

	# the governance gate: may this deployment cross to reality?
	def MayCommit()
		if @oActor = NULL
			return FALSE
		ok
		return @oActor.Can("effectful")

	  #-- the deployment plan (rehearsal) --------------------

	# each part -> [ part, kind, target, siteName, siteKind, protocol ]
	def Plan()
		_oPlan_ = @oBrain.Plan()
		_aParts_ = _oPlan_.Parts()
		_out_ = []
		_n_ = len(_aParts_)
		for _i_ = 1 to _n_
			_p_ = _aParts_[_i_]
			_site_ = This.SiteFor(_p_[1])
			if _site_ = NULL
				_out_ + [ _p_[1], _p_[2], _p_[3], "(unbound)", "", "" ]
			else
				_out_ + [ _p_[1], _p_[2], _p_[3], _site_.Name(), _site_.KindName(), _site_.Protocol() ]
			ok
		next
		return _out_

	def Explain()
		_c_ = "Deployment of '" + @oBrain.Name() + "' -- from definition to launch (rehearsal)" + nl
		_c_ += "==============================================================================" + nl
		if This.MayCommit()
			_c_ += "  actor: " + @oActor.Name() + " -- MAY commit (effectful)" + nl
		but @oActor != NULL
			_c_ += "  actor: " + @oActor.Name() + " -- rehearse only (not effectful)" + nl
		else
			_c_ += "  actor: (none) -- rehearse only" + nl
		ok
		_aP_ = This.Plan()
		_n_ = len(_aP_)
		for _i_ = 1 to _n_
			_r_ = _aP_[_i_]
			_c_ += nl + "  Part '" + _r_[1] + "' [" + _r_[2] + "] -> " + _r_[3] + nl
			if _r_[4] = "(unbound)"
				_c_ += "     (no site bound -- add .To(:" + _r_[1] + ", <site>))" + nl
			else
				_site_ = This.SiteFor(_r_[1])
				_c_ += "     site:   " + _r_[4] + " [" + _r_[5] + "]" + nl
				_c_ += "     reach:  " + _site_.Protocol() + " -> " + _StzSiteOr(_site_.EndpointOf(), "(local)") + nl
				_c_ += "     store:  " + _StzSiteOr(_site_.StorageLocation(), "(unset)") + nl
			ok
		next
		_c_ += nl + "  Store() places each part's artifacts on its site; Launch() starts them;" + nl
		_c_ += "  Status() reports back -- governed: only an effectful actor commits." + nl
		return _c_

	  #-- perform (governed) ---------------------------------

	# store each part's deploy artifact on its bound site.
	# returns [ committed(0/1), [ [part, site, outcome], ... ] ]
	def Store()
		_bMay_ = This.MayCommit()
		_recs_ = []
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_part_ = @aBindings[_i_][1]
			_site_ = @aBindings[_i_][2]
			if _bMay_
				if _site_.Store(This._ArtifactsFor(_part_))
					_recs_ + [ _part_, _site_.Name(), "stored" ]
				else
					_recs_ + [ _part_, _site_.Name(), "store-failed" ]
				ok
			else
				_recs_ + [ _part_, _site_.Name(), "rehearsed (not committed)" ]
			ok
		next
		return [ This._CommitFlag(_bMay_), _recs_ ]

	def Launch()
		_bMay_ = This.MayCommit()
		_recs_ = []
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_part_ = @aBindings[_i_][1]
			_site_ = @aBindings[_i_][2]
			if _bMay_
				if _site_.Launch()
					_recs_ + [ _part_, _site_.Name(), "launched" ]
				else
					_recs_ + [ _part_, _site_.Name(), "launch-failed" ]
				ok
			else
				_recs_ + [ _part_, _site_.Name(), "rehearsed (not committed)" ]
			ok
		next
		return [ This._CommitFlag(_bMay_), _recs_ ]

	def Status()
		_recs_ = []
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_recs_ + [ @aBindings[_i_][1], @aBindings[_i_][2].Name(), @aBindings[_i_][2].Status() ]
		next
		return _recs_

	  #-- helpers --------------------------------------------

	def _CommitFlag(pbMay)
		if pbMay
			return 1
		ok
		return 0

	# the per-part deploy artifact(s). A deploy manifest (real file) for now; the
	# real binaries (stz_<part>.wasm, the app bundle, the native binary) ship in a
	# later slice -- the store/launch/govern flow is identical for them.
	def _ArtifactsFor(pcPart)
		_oPlan_ = @oBrain.Plan()
		_grps_ = StzWasmGroupsFor(_oPlan_.EngineCapsFor(pcPart))
		_csv_ = ""
		_ng_ = len(_grps_)
		for _g_ = 1 to _ng_
			if _g_ > 1
				_csv_ += ","
			ok
			_csv_ += _grps_[_g_]
		next
		_q_ = char(34)
		_man_ = "{" + nl
		_man_ += "  " + _q_ + "solution" + _q_ + ": " + _q_ + @oBrain.Name() + _q_ + "," + nl
		_man_ += "  " + _q_ + "part" + _q_ + ": " + _q_ + pcPart + _q_ + "," + nl
		_man_ += "  " + _q_ + "engine" + _q_ + ": " + _q_ + _csv_ + _q_ + nl
		_man_ += "}" + nl
		return [ [ "deploy.json", _man_ ] ]
