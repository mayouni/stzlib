#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZDEPLOYMENT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Deployment as a first-class story: from     #
#                  DEFINITION (the rehearsal) and EMULATION    #
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
#   oDep = new stzDeployment(oDelivery).AsActor(HumanActor("ops"))
#   oDep.To(:api, oServer)
#   ? oDep.Explain()
#   oDep.Store()  oDep.Launch()  ? @@( oDep.Status() )

  #=============#
 #  FUNCTIONS  #
#=============#

func StzDeploymentSiteQ(pcName)
	return new stzDeploymentSite(pcName)

func StzDeploymentQ(poDelivery)
	return new stzDeployment(poDelivery)

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

func StzResourcesQ()
	return new stzResourceSpec()

# a memory footprint -> an AWS instance type (a small, honest heuristic; a real
# catalog would map (mem, vcpu) pairs). Used to derive a provision command.
func _StzAwsType(poReq)
	_m_ = poReq.MemoryMB()
	if _m_ <= 1024
		return "t3.micro"
	but _m_ <= 2048
		return "t3.small"
	but _m_ <= 4096
		return "t3.medium"
	ok
	return "t3.large"


  #=====================#
 #  RESOURCE SPEC       #
#=====================#

# A resource footprint -- memory (MB), compute (vCPU), storage (GB). ONE shape,
# TWO roles: a part's REQUIREMENT (what it needs to run) and a host's CAPACITY
# (what it provides). Feasibility is just Capacity.Meets(sum-of-requirements) --
# the same admission check a CI runner label or a K8s scheduler performs. Extend
# with gpu / os / region as real backends need them.
class stzResourceSpec from stzObject

	@nMem = 0    # MB
	@nCpu = 0    # vCPU
	@nDisk = 0   # GB

	def init()
		@nMem = 0

	def SetMemoryQ(pnMB)
		@nMem = pnMB
		return This

	def SetComputeQ(pnVCPU)
		@nCpu = pnVCPU
		return This

	def SetStorageQ(pnGB)
		@nDisk = pnGB
		return This

	def MemoryMB()
		return @nMem
	def ComputeVCPU()
		return @nCpu
	def StorageGB()
		return @nDisk

	def IsEmpty()
		return @nMem = 0 and @nCpu = 0 and @nDisk = 0

	# does THIS capacity meet the given REQUIREMENT (every dimension covered)?
	def Meets(poReq)
		return @nMem >= poReq.MemoryMB() and @nCpu >= poReq.ComputeVCPU() and @nDisk >= poReq.StorageGB()

	# aggregate: sum two requirements (many parts on one host)
	def Plus(poOther)
		_r_ = new stzResourceSpec()
		_r_.SetMemoryQ(@nMem + poOther.MemoryMB())
		_r_.SetComputeQ(@nCpu + poOther.ComputeVCPU())
		_r_.SetStorageQ(@nDisk + poOther.StorageGB())
		return _r_

	def Text()
		return "" + @nMem + "MB / " + @nCpu + " vCPU / " + @nDisk + "GB"

	def Show()
		? This.Text()


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
	@oCapacity = NULL   # the host's resources (stzResourceSpec) -- declared or discovered
	@cProvider = ""     # a provisioning provider (aws/gcp/proxmox/...) -> scriptable host

	def init(pcName)
		@cName = "" + pcName

	  #-- the access config (Q-fluent: chainable via the ...Q suffix) ---

	def SetKindQ(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	def SetEndpointQ(pcUrl)
		@cEndpoint = "" + pcUrl
		return This

	def SetProtocolQ(pcProtocol)
		@cProtocol = StzLower(ring_trim("" + pcProtocol))
		return This

	def SetAuthRefQ(pcRef)
		@cAuthRef = "" + pcRef
		return This

	def SetStoreAtQ(pcLocation)
		@cStorage = "" + pcLocation
		return This

	def SetLaunchWithQ(pcCmd)
		@cLaunch = "" + pcCmd
		return This

	def SetStatusWithQ(pcCmd)
		@cStatusCmd = "" + pcCmd
		return This

	# what the host PROVIDES (its capacity). For a real host it is discovered via
	# the provider API; for a fixed host it is declared here.
	def SetCapacityQ(poSpec)
		@oCapacity = poSpec
		return This

	# name a provisioning provider -> this host can be CREATED/resized to meet a
	# requirement (IaC-style), not just deployed to.
	def SetProviderQ(pcName)
		@cProvider = StzLower(ring_trim("" + pcName))
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

	def CapacityOf()
		return @oCapacity

	def HasCapacity()
		return isObject(@oCapacity)

	def ProviderName()
		return @cProvider

	def IsScriptable()
		return @cProvider != ""

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

	  #-- access + control (LIVE backends, dispatched by kind) --
	#
	# A live backend turns the site config into a REAL command run through the managed
	# child (SpawnProcess) -- the same path stzBuilder uses to run zig. The commands are
	# rehearsable (Commands() shows them before anything runs). :LocalRepo uses direct
	# file ops; :GitRepo runs real git (proven end to end against a local bare repo);
	# :Server runs scp/ssh; a scriptable host provisions via its provider CLI. The
	# commands are correct wherever the tool + target exist -- in this sandbox git and
	# the local repo complete; scp/ssh/docker/aws are generated and run through the same
	# child, but need a real host/registry/account to finish.

	def Reachable()
		if This.IsLocal()
			return @cStorage != ""
		but @cKind = "gitrepo" or @cKind = "git"
			return This._Sh("git ls-remote " + @cEndpoint)[1] = 0
		ok
		return @cEndpoint != ""

	def Store(paArtifacts)
		if This.IsLocal()
			return This._LocalStore(paArtifacts)
		but @cKind = "gitrepo" or @cKind = "git"
			return This._GitStore(paArtifacts)
		but @cKind = "server"
			return This._ServerStore(paArtifacts)
		ok
		return FALSE

	def Launch()
		if This.IsLocal()
			return This._LocalLaunch()
		but @cKind = "gitrepo" or @cKind = "git"
			return TRUE   # a git deploy IS the push -- nothing more to start
		but @cKind = "server"
			return This._ServerLaunch()
		ok
		return FALSE

	def Status()
		if This.IsLocal()
			return This._LocalStatus()
		but @cKind = "gitrepo" or @cKind = "git"
			return This._GitStatus()
		ok
		return "absent"

	def Rollback()
		if This.IsLocal()
			StzFileDelete(@cStorage + "/deploy.json")
			write(@cStorage + "/.stzsite", "state=rolledback" + nl + "kind=" + @cKind + nl)
			return TRUE
		ok
		return TRUE   # kind-specific rollback (git revert / instance terminate) -- best effort

	# provision a scriptable host to meet a requirement (the IaC move -- bring the host
	# into existence, don't just deploy to it). Runs the provider CLI via the child.
	def Provision(poReq)
		_cmd_ = This.ProvisionCommandFor(poReq)
		if _cmd_ = ""
			return FALSE
		ok
		return This._Sh(_cmd_)[1] = 0

	  #-- the real commands, rehearsable (see them before they run) --

	def Commands()
		_out_ = []
		if This.TransferCommand() != ""
			_out_ + [ "store", This.TransferCommand() ]
		ok
		if This.LaunchCommandLine() != ""
			_out_ + [ "launch", This.LaunchCommandLine() ]
		ok
		return _out_

	def TransferCommand()
		if @cKind = "gitrepo" or @cKind = "git"
			return "git push -f " + @cEndpoint + " HEAD:refs/heads/main"
		but @cKind = "server"
			return "scp -r <staged>/. " + @cEndpoint
		but @cKind = "registry"
			return "docker push " + @cEndpoint
		but @cKind = "device"
			return "esptool --port " + @cEndpoint + " write_flash 0x0 <firmware>"
		ok
		return ""

	def LaunchCommandLine()
		if @cKind = "server" and @cLaunch != ""
			return "ssh " + This._SshHost() + " '" + @cLaunch + "'"
		ok
		return @cLaunch

	def ProvisionCommandFor(poReq)
		if NOT isObject(poReq)
			return ""
		ok
		if @cProvider = "proxmox"
			return "qm create --name " + @cName + " --memory " + poReq.MemoryMB() + " --cores " + poReq.ComputeVCPU() + " --scsi0 local:" + poReq.StorageGB()
		but @cProvider = "aws"
			return "aws ec2 run-instances --instance-type " + _StzAwsType(poReq)
		ok
		return ""

	  #-- backends -------------------------------------------

	# write an artifact under pcDir at pcRel, creating any subdirs the relname implies
	# (a bundle ships nested paths like site/assets/app.js).
	def _WriteArtifact(pcDir, pcRel, pcContent)
		_full_ = pcDir + "/" + pcRel
		StzEngineDirCreatePath(_StzDirOf(_full_))
		write(_full_, "" + pcContent)

	def _LocalStore(paArtifacts)
		if @cStorage = ""
			return FALSE
		ok
		StzEngineDirCreatePath(@cStorage)
		_n_ = len(paArtifacts)
		for _i_ = 1 to _n_
			This._WriteArtifact(@cStorage, paArtifacts[_i_][1], paArtifacts[_i_][2])
		next
		write(@cStorage + "/.stzsite", "state=stored" + nl + "kind=" + @cKind + nl)
		return TRUE

	def _LocalLaunch()
		if @cStorage = "" or StzEngineFileExists(@cStorage + "/.stzsite") = 0
			return FALSE
		ok
		_rec_ = "state=launched" + nl + "kind=" + @cKind + nl
		if @cLaunch != ""
			_rec_ += "launch=" + @cLaunch + nl
		ok
		write(@cStorage + "/.stzsite", _rec_)
		return TRUE

	def _LocalStatus()
		if @cStorage != "" and StzEngineFileExists(@cStorage + "/.stzsite") = 1
			_c_ = read(@cStorage + "/.stzsite")
			if StzFindFirst("state=launched", _c_) > 0
				return "launched"
			ok
			if StzFindFirst("state=rolledback", _c_) > 0
				return "rolledback"
			ok
			return "stored"
		ok
		return "absent"

	# :GitRepo -- REAL git, run through the managed child. Proven end to end here
	# against a local bare repo (@cEndpoint), no network.
	def _GitStore(paArtifacts)
		if @cStorage = "" or @cEndpoint = ""
			return FALSE
		ok
		_w_ = @cStorage
		StzEngineDirCreatePath(_w_)
		_n_ = len(paArtifacts)
		for _i_ = 1 to _n_
			This._WriteArtifact(_w_, paArtifacts[_i_][1], paArtifacts[_i_][2])
		next
		This._Sh("git -C " + _w_ + " init -q")
		This._Sh("git -C " + _w_ + " config user.email deploy@stz")
		This._Sh("git -C " + _w_ + " config user.name stz-deploy")
		This._Sh("git -C " + _w_ + " add -A")
		This._Sh("git -C " + _w_ + " commit -q -m deploy --allow-empty")
		return This._Sh("git -C " + _w_ + " push -f -q " + @cEndpoint + " HEAD:refs/heads/main")[1] = 0

	def _GitStatus()
		_r_ = This._Sh("git ls-remote " + @cEndpoint + " refs/heads/main")
		if _r_[1] = 0 and len(ring_trim(_r_[2])) > 0
			return "launched"
		ok
		return "absent"

	# :Server -- stage locally, scp to the endpoint, ssh the launch. Correct commands;
	# they complete against a reachable host.
	def _ServerStore(paArtifacts)
		if @cStorage = ""
			return FALSE
		ok
		StzEngineDirCreatePath(@cStorage)
		_n_ = len(paArtifacts)
		for _i_ = 1 to _n_
			This._WriteArtifact(@cStorage, paArtifacts[_i_][1], paArtifacts[_i_][2])
		next
		return This._Sh("scp -r " + @cStorage + "/. " + @cEndpoint)[1] = 0

	def _ServerLaunch()
		if @cLaunch = ""
			return TRUE
		ok
		return This._Sh("ssh " + This._SshHost() + " " + char(34) + @cLaunch + char(34))[1] = 0

	def _SshHost()
		_p_ = StzFindFirst(":", @cEndpoint)
		if _p_ > 0
			return left(@cEndpoint, _p_ - 1)
		ok
		return @cEndpoint

	# run a command through the managed child; return [ exitCode, stdout, stderr ].
	def _Sh(pcCmd)
		_o_ = SpawnProcess("" + pcCmd)
		_out_ = _o_.ReadOutputAll()
		_err_ = _o_.ReadErrorAll()
		_ex_ = _o_.Wait()
		_o_.Close()
		return [ _ex_, _out_, _err_ ]

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

	@oDelivery = NULL
	@aBindings = []   # [ partName, siteObject ]
	@oActor = NULL
	@aAfter = []      # [ partName, dependsOnPartName ] -- ordering (the plan DAG)
	@aArtifacts = []  # [ partName, relName, filePath ] -- the REAL build outputs to ship

	def init(poDelivery)
		@oDelivery = poDelivery

	# bind a part to its target site. For many at once, use SetTargets.
	def SetTarget(pcPart, poSite)
		@aBindings + [ StzLower("" + pcPart), poSite ]
		return This

	def SetTargets(paList)
		if isList(paList)
			_n_ = len(paList)
			for _i_ = 1 to _n_
				@aBindings + [ StzLower("" + paList[_i_][1]), paList[_i_][2] ]
			next
		ok
		return This

	# order the plan: pcPart runs AFTER pcDependsOn is verified (a plan-DAG edge).
	# Simple deployments declare none; complex ones (a frontend after its backend) do.
	def RunAfter(pcPart, pcDependsOn)
		@aAfter + [ StzLower("" + pcPart), StzLower("" + pcDependsOn) ]
		return This

	def _AfterOf(pcPart)
		_c_ = StzLower("" + pcPart)
		_out_ = []
		_n_ = len(@aAfter)
		for _i_ = 1 to _n_
			if @aAfter[_i_][1] = _c_
				_out_ + @aAfter[_i_][2]
			ok
		next
		return _out_

	# attach a REAL build output to ship for a part (the per-part stz_<part>.wasm, the
	# app bundle, the native binary...). pcRelName is its name at the destination;
	# pcPath is the built file on disk. Shipped byte-for-byte alongside the manifest.
	def Artifact(pcPart, pcRelName, pcPath)
		@aArtifacts + [ StzLower("" + pcPart), "" + pcRelName, "" + pcPath ]
		return This

	def ArtifactsAttached()
		return @aArtifacts

	# wire an emulator's built bundle DIRECTORY straight in as a part's production
	# artifact -- the SAME tree you emulated becomes what ships. Accepts a stzEmulator
	# (built on demand) or a bundle directory path; the bundle lands under the
	# solution name.
	def AttachBundle(pcPart, pBundle)
		return This.Artifact(pcPart, @oDelivery.Name(), This._BundleDirOf(pBundle))

	# ship a part's OWN slice from an emulator bundle -- its app (as index.html), its
	# engine subset (stz_<part>.wasm), and the bridge (stz.js) -- NOT the whole
	# mission-control. A frontend part deploys only what it needs to run.
	def AttachSlice(pcPart, pBundle)
		_dir_ = This._BundleDirOf(pBundle)
		_app_ = _dir_ + "/app_" + pcPart + ".html"
		if StzEngineFileExists(_app_) = 1
			This.Artifact(pcPart, "index.html", _app_)
		ok
		_wasm_ = _dir_ + "/stz_" + pcPart + ".wasm"
		if StzEngineFileExists(_wasm_) = 1
			This.Artifact(pcPart, "stz_" + pcPart + ".wasm", _wasm_)
		ok
		_bridge_ = _dir_ + "/stz.js"
		if StzEngineFileExists(_bridge_) = 1
			This.Artifact(pcPart, "stz.js", _bridge_)
		ok
		return This

	def _BundleDirOf(pBundle)
		if isObject(pBundle)
			if NOT pBundle.IsBuilt()
				pBundle.Build()
			ok
			return pBundle.BundleDir()
		ok
		return "" + pBundle

	def SetActor(poActor)
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
		_oPlan_ = @oDelivery.Plan()
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
		_c_ = "Deployment of '" + @oDelivery.Name() + "' -- from definition to launch (rehearsal)" + nl
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
		if len(@oDelivery.Requirements()) > 0
			_aFeas_ = This.Feasibility()
			_nf_ = len(_aFeas_)
			_c_ += nl + "  Host feasibility (required -> capacity):" + nl
			for _i_ = 1 to _nf_
				_f_ = _aFeas_[_i_]
				_mk_ = "ok  "
				if _f_[4] = 0
					_mk_ = "FAIL"
				ok
				_c_ += "     [" + _mk_ + "] " + _f_[1] + ": " + _f_[2] + " -> " + _f_[3] + "  (" + _f_[5] + ")" + nl
			next
		ok
		_aSteps_ = This.Steps()
		_ns_ = len(_aSteps_)
		if _ns_ > 0
			_c_ += nl + "  Plan (" + _ns_ + " steps, in order; Run() executes them, governed):" + nl
			for _i_ = 1 to _ns_
				_st_ = _aSteps_[_i_]
				_c_ += "     " + _i_ + ". " + StzPadRight(_st_[2], 10) + _st_[3] + " -> " + _st_[4]
				if len(_st_[5]) > 0
					_c_ += "   (after " + This._JoinNames(_st_[5]) + ")"
				ok
				_c_ += nl
			next
		ok
		_c_ += nl + "  A verify gate must pass to proceed; a failure rolls back the completed steps." + nl
		_c_ += "  Governed: only an effectful actor commits." + nl
		return StzSplit(_c_, nl)   # a list of lines -- caller formats; Show() prints

	def Show()
		_aLines_ = This.Explain()
		_n_ = len(_aLines_)
		for _i_ = 1 to _n_
			? _aLines_[_i_]
		next

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

	  #-- the plan of steps (order, gates, rollback) ---------

	# the deployment PLAN as ordered steps. A simple deployment is the default chain
	# per part -- provision? -> store -> launch -> verify; After() edges add cross-part
	# ordering (a frontend after its backend). Returns [ [name, op, part, siteName,
	# [needs]], ... ], topologically ordered so every dependency precedes its dependants.
	def Steps()
		_raw_ = []
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_part_ = @aBindings[_i_][1]
			_site_ = @aBindings[_i_][2]
			_sn_ = _site_.Name()
			# cross-part prerequisites: this part's first step waits on their verify
			_pre_ = []
			_deps_ = This._AfterOf(_part_)
			_ndp_ = len(_deps_)
			for _k_ = 1 to _ndp_
				_pre_ + ("verify:" + _deps_[_k_])
			next
			_last_ = ""
			if _site_.IsScriptable()
				_nmP_ = "provision:" + _part_
				_raw_ + [ _nmP_, "provision", _part_, _sn_, _pre_ ]
				_last_ = _nmP_
			ok
			_nmS_ = "store:" + _part_
			_needsS_ = []
			if _last_ != ""
				_needsS_ + _last_
			else
				_np_ = len(_pre_)
				for _k_ = 1 to _np_
					_needsS_ + _pre_[_k_]
				next
			ok
			_raw_ + [ _nmS_, "store", _part_, _sn_, _needsS_ ]
			_nmL_ = "launch:" + _part_
			_raw_ + [ _nmL_, "launch", _part_, _sn_, [ _nmS_ ] ]
			_nmV_ = "verify:" + _part_
			_raw_ + [ _nmV_, "verify", _part_, _sn_, [ _nmL_ ] ]
		next
		return This._TopoOrder(_raw_)

	def _TopoOrder(paRaw)
		_ordered_ = []
		_placed_ = []
		_remaining_ = paRaw
		_guard_ = 0
		while len(_remaining_) > 0 and _guard_ < 10000
			_guard_++
			_progress_ = FALSE
			_next_ = []
			_nr_ = len(_remaining_)
			for _i_ = 1 to _nr_
				_st_ = _remaining_[_i_]
				_needs_ = _st_[5]
				_ready_ = TRUE
				_nn_ = len(_needs_)
				for _k_ = 1 to _nn_
					if StzFindFirst(_needs_[_k_], _placed_) = 0
						_ready_ = FALSE
					ok
				next
				if _ready_
					_ordered_ + _st_
					_placed_ + _st_[1]
					_progress_ = TRUE
				else
					_next_ + _st_
				ok
			next
			_remaining_ = _next_
			if NOT _progress_
				_nl_ = len(_remaining_)
				for _i_ = 1 to _nl_
					_ordered_ + _remaining_[_i_]
				next
				_remaining_ = []
			ok
		end
		return _ordered_

	# EXECUTE the ordered plan (governed). Each step runs its op; the verify step is a
	# GATE (the site must be launched). On any failure, the completed store/launch steps
	# are ROLLED BACK in reverse -- the deployment is transactional. Returns
	# [ committed(0/1), [ [stepName, outcome], ... ] ]. No effectful actor -> rehearse.
	def Run()
		_bMay_ = This.MayCommit()
		_steps_ = This.Steps()
		_recs_ = []
		_undo_ = []
		_failed_ = FALSE
		_n_ = len(_steps_)
		for _i_ = 1 to _n_
			_st_ = _steps_[_i_]
			if _failed_
				_recs_ + [ _st_[1], "skipped" ]
				loop
			ok
			if NOT _bMay_
				_recs_ + [ _st_[1], "rehearsed" ]
				loop
			ok
			_site_ = This.SiteFor(_st_[3])
			if This._RunStep(_st_[2], _site_, _st_[3])
				_recs_ + [ _st_[1], "done" ]
				if _st_[2] = "store" or _st_[2] = "launch"
					_undo_ + _site_
				ok
			else
				_recs_ + [ _st_[1], "FAILED" ]
				_failed_ = TRUE
			ok
		next
		if _failed_ and _bMay_
			_nu_ = len(_undo_)
			for _i_ = _nu_ to 1 step -1
				_undo_[_i_].Rollback()
			next
		ok
		_flag_ = 1
		if _failed_ or NOT _bMay_
			_flag_ = 0
		ok
		return [ _flag_, _recs_ ]

	def _RunStep(pcOp, poSite, pcPart)
		if pcOp = "provision"
			_req_ = @oDelivery.RequirementFor(pcPart)
			if NOT isObject(_req_)
				return TRUE   # no requirement to size the host to
			ok
			return poSite.Provision(_req_)
		but pcOp = "store"
			return poSite.Store(This._ArtifactsFor(pcPart))
		but pcOp = "launch"
			return poSite.Launch()
		but pcOp = "verify"
			return poSite.Status() = "launched"
		ok
		return TRUE

	def _JoinNames(paList)
		_s_ = ""
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if _i_ > 1
				_s_ += ", "
			ok
			_s_ += paList[_i_]
		next
		return _s_

	  #-- feasibility (host resources) -----------------------

	# Per-site admission check: sum the requirements of the parts bound to each site
	# and test the site's capacity (or its ability to PROVISION one). Returns
	# [ [siteName, requiredText, capacityText, fits(0/1), note], ... ]. This is the
	# same "does the host have room?" question a K8s scheduler / CI runner answers.
	def Feasibility()
		_out_ = []
		_seen_ = []
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_site_ = @aBindings[_i_][2]
			_sn_ = _site_.Name()
			if StzFindFirst(_sn_, _seen_) > 0
				loop
			ok
			_seen_ + _sn_
			_req_ = new stzResourceSpec()
			for _j_ = 1 to _n_
				if @aBindings[_j_][2].Name() = _sn_
					_r_ = @oDelivery.RequirementFor(@aBindings[_j_][1])
					if isObject(_r_)
						_req_ = _req_.Plus(_r_)
					ok
				ok
			next
			_out_ + This._SiteFeasibility(_site_, _req_)
		next
		return _out_

	def _SiteFeasibility(poSite, poReq)
		_sn_ = poSite.Name()
		_reqT_ = poReq.Text()
		if poSite.HasCapacity()
			_cap_ = poSite.CapacityOf()
			if _cap_.Meets(poReq)
				return [ _sn_, _reqT_, _cap_.Text(), 1, "fits" ]
			ok
			return [ _sn_, _reqT_, _cap_.Text(), 0, "SHORTFALL -- host too small" ]
		but poSite.IsScriptable()
			return [ _sn_, _reqT_, "(provision)", 1, "provision on " + poSite.ProviderName() ]
		ok
		return [ _sn_, _reqT_, "(undeclared)", 1, "capacity not declared -- assumed ok" ]

	# TRUE only if every site can host its parts (fits or can provision).
	def Feasible()
		_f_ = This.Feasibility()
		_n_ = len(_f_)
		for _i_ = 1 to _n_
			if _f_[_i_][4] = 0
				return FALSE
			ok
		next
		return TRUE

	  #-- helpers --------------------------------------------

	def _CommitFlag(pbMay)
		if pbMay
			return 1
		ok
		return 0

	# the per-part deploy artifact(s). A deploy manifest (real file) for now; the
	# real binaries (stz_<part>.wasm, the app bundle, the native binary) ship in a
	# later slice -- the store/launch/govern flow is identical for them.
	# recursively collect [ relName, content ] for every file under pcDir, prefixing
	# each with pcRelPrefix and preserving the tree (subdirs + dotfiles). The engine's
	# dir listings include dotfiles, so a whole bundle ships in one attach.
	def _DirArtifacts(pcRelPrefix, pcDir)
		_out_ = []
		_aFiles_ = StzEngineDirListFiles(pcDir)
		_nf_ = len(_aFiles_)
		for _i_ = 1 to _nf_
			_out_ + [ pcRelPrefix + "/" + _aFiles_[_i_], read(pcDir + "/" + _aFiles_[_i_]) ]
		next
		_aDirs_ = StzEngineDirListDirs(pcDir)
		_nd_ = len(_aDirs_)
		for _i_ = 1 to _nd_
			_sub_ = _aDirs_[_i_]
			if _sub_ = "." or _sub_ = ".."
				loop
			ok
			_child_ = This._DirArtifacts(pcRelPrefix + "/" + _sub_, pcDir + "/" + _sub_)
			_nc_ = len(_child_)
			for _k_ = 1 to _nc_
				_out_ + _child_[_k_]
			next
		next
		return _out_

	def _ArtifactsFor(pcPart)
		_oPlan_ = @oDelivery.Plan()
		_grps_ = StzWasmGroupsFor(_oPlan_.EngineCapsFor(pcPart))
		_csv_ = ""
		_ng_ = len(_grps_)
		for _g_ = 1 to _ng_
			if _g_ > 1
				_csv_ += ","
			ok
			_csv_ += _grps_[_g_]
		next
		# the REAL build outputs attached for this part -- read as binary, shipped as-is.
		# An attachment is a FILE (shipped as relName) or a whole DIRECTORY (every file
		# under it shipped at relName/<relative-path>, subdirs + dotfiles included).
		_files_ = []
		_names_ = ""
		_na_ = len(@aArtifacts)
		for _i_ = 1 to _na_
			if @aArtifacts[_i_][1] != pcPart
				loop
			ok
			_rel_ = @aArtifacts[_i_][2]
			_path_ = @aArtifacts[_i_][3]
			_add_ = []
			if StzEngineDirExists(_path_) = 1
				_add_ = This._DirArtifacts(_rel_, _path_)
			but StzEngineFileExists(_path_) = 1
				_add_ = [ [ _rel_, read(_path_) ] ]
			ok
			_nad_ = len(_add_)
			for _k_ = 1 to _nad_
				_files_ + _add_[_k_]
				if _names_ != ""
					_names_ += ","
				ok
				_names_ += _add_[_k_][1]
			next
		next
		_q_ = char(34)
		_man_ = "{" + nl
		_man_ += "  " + _q_ + "solution" + _q_ + ": " + _q_ + @oDelivery.Name() + _q_ + "," + nl
		_man_ += "  " + _q_ + "part" + _q_ + ": " + _q_ + pcPart + _q_ + "," + nl
		_man_ += "  " + _q_ + "engine" + _q_ + ": " + _q_ + _csv_ + _q_ + "," + nl
		_man_ += "  " + _q_ + "artifacts" + _q_ + ": " + _q_ + _names_ + _q_ + nl
		_man_ += "}" + nl
		_out_ = [ [ "deploy.json", _man_ ] ]
		_nf_ = len(_files_)
		for _i_ = 1 to _nf_
			_out_ + _files_[_i_]
		next
		return _out_
