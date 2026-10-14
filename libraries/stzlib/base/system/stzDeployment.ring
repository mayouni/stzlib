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

# Holds an amount of resources, memory, virtual processors, disk and a GPU, either as the need of a part or as the capacity of a host.
#
# The same class plays two roles. As a requirement it says what a part needs, including a GPU that
# is required or optional. As a capacity it says what a host offers, including whether a GPU is
# present. Meets asks whether a capacity covers a requirement; Plus adds requirements, as for
# several parts on one host. Nothing is validated: set numbers.
#
#   receiver   o1 = new stzResourceSpec() o1.SetMemory(2048) o1.SetCompute(2) o1.SetStorage(20)
#   example    ? o1.Text()
#              #--> 2048MB / 2 vCPU / 20GB
#              oNeed = new stzResourceSpec()
#              oNeed.SetMemory(1024)
#              oNeed.SetCompute(1)
#              ? o1.Meets(oNeed)
#              #--> 1
#              oNeed.SetGpuRequired()
#              ? o1.Meets(oNeed)
#              #--> 0
#              o1.SetGpuPresent(1)
#              ? o1.Meets(oNeed)
#              #--> 1
#   see        stzDeployment, stzDeploymentSite
class stzResourceSpec from stzObject

	@nMem = 0    # MB
	@nCpu = 0    # vCPU
	@nDisk = 0   # GB
	# GPU, both roles (G5, SOFTANZA_GPU_PLAN.md): a REQUIREMENT declares
	# need ("" / "required" / "optional"), a CAPACITY declares presence.
	@cGpu = ""
	@bGpuPresent = 0

	# Creates an empty resource spec: no memory, no processors, no disk and no GPU need.
	#
	#   returns    nothing; the object is built
	#   see        SetMemory, IsEmpty
	def init()
		@nMem = 0

	# Sets the memory in megabytes, as a need of a part or as the capacity of a host.
	#
	#   pnMB       the memory in megabytes
	#   returns    nothing; use SetMemoryQ to chain
	#   warning    the value is not checked: a text is stored as given
	#   see        MemoryMB, Meets
	def SetMemory(pnMB)
		This.SetMemoryQ(pnMB)

	def SetMemoryQ(pnMB)
		@nMem = pnMB
		return This

	# Sets the number of virtual processors.
	#
	#   pnVCPU     the number of virtual processors
	#   returns    nothing; use SetComputeQ to chain
	#   warning    the value is not checked
	#   see        ComputeVCPU, Meets
	def SetCompute(pnVCPU)
		This.SetComputeQ(pnVCPU)

	def SetComputeQ(pnVCPU)
		@nCpu = pnVCPU
		return This

	# Sets the disk space in gigabytes.
	#
	#   pnGB       the disk space in gigabytes
	#   returns    nothing; use SetStorageQ to chain
	#   warning    the value is not checked
	#   see        StorageGB, Meets
	def SetStorage(pnGB)
		This.SetStorageQ(pnGB)

	def SetStorageQ(pnGB)
		@nDisk = pnGB
		return This

	# Declares that the part must have a GPU, so a deployment onto a host without one is refused.
	#
	#   returns    nothing; use SetGpuRequiredQ to chain
	#   warning    this is the requirement role: it says what the part needs, not what a host has
	#   see        SetGpuOptional, Meets
	#@ aka  requirement role: this part MUST have a GPU (Deploy refuses without one)
	def SetGpuRequired()
		This.SetGpuRequiredQ()

	def SetGpuRequiredQ()
		@cGpu = "required"
		return This

	# Declares that the part uses a GPU when there is one and falls back to the CPU otherwise.
	#
	#   returns    nothing; use SetGpuOptionalQ to chain
	#   warning    requirement role, replacing an earlier required or optional
	#   see        SetGpuRequired, GpuNeed
	#@ aka  requirement role: this part USES a GPU when present, falls back to CPU otherwise (Deploy proceeds and logs the degrade)
	def SetGpuOptional()
		This.SetGpuOptionalQ()

	def SetGpuOptionalQ()
		@cGpu = "optional"
		return This

	# Declares whether this host has a GPU, which is the capacity role.
	#
	#   bFlag      1 if the host has a GPU, 0 if not
	#   returns    nothing; use SetGpuPresentQ to chain
	#   warning    the flag is kept as given, so a text is not turned into 1 or 0
	#   see        HasGpu, Meets
	#@ aka  capacity role: this host HAS a GPU
	def SetGpuPresent(bFlag)
		This.SetGpuPresentQ(bFlag)

	def SetGpuPresentQ(bFlag)
		@bGpuPresent = bFlag
		return This

	# Returns the GPU need of a part: required, optional, or an empty text for none.
	#
	#   returns    a text
	#   see        SetGpuRequired, SetGpuOptional
	def GpuNeed()
		return @cGpu

	# Returns whether the host was declared to have a GPU.
	#
	#   returns    the flag as set; 0 by default
	#   see        SetGpuPresent, Meets
	def HasGpu()
		return @bGpuPresent

	# Returns the memory in megabytes; 0 by default.
	#
	#   returns    a number
	#   see        SetMemory
	def MemoryMB()
		return @nMem
	# Returns the number of virtual processors; 0 by default.
	#
	#   returns    a number
	#   see        SetCompute
	def ComputeVCPU()
		return @nCpu
	# Returns the disk space in gigabytes; 0 by default.
	#
	#   returns    a number
	#   see        SetStorage
	def StorageGB()
		return @nDisk

	# TRUE if no memory, processor, disk or GPU need is set.
	#
	#   returns    TRUE or FALSE
	#   see        Text
	def IsEmpty()
		return @nMem = 0 and @nCpu = 0 and @nDisk = 0 and @cGpu = ""

	# TRUE if this capacity covers the given requirement on every dimension.
	#
	#   poReq      the requirement to cover, another stzResourceSpec
	#   returns    TRUE or FALSE
	#   warning    a required GPU is met only when this spec was declared with a GPU present; an
	#              optional GPU never blocks
	#   see        Plus, SetGpuPresent
	#@ aka  does THIS capacity meet the given REQUIREMENT (every dimension covered)?
	def Meets(poReq)
		if poReq.GpuNeed() = "required" and NOT @bGpuPresent
			return 0
		ok
		return @nMem >= poReq.MemoryMB() and @nCpu >= poReq.ComputeVCPU() and @nDisk >= poReq.StorageGB()

	# Returns a new spec that adds the memory, processors and disk of two specs, as for several parts on one host.
	#
	#   poOther    the spec to add
	#   returns    a new stzResourceSpec
	#   warning    the merged GPU need is the stronger of the two; the GPU presence of the result is
	#              not carried over; neither original changes
	#   see        Meets
	#@ aka  aggregate: sum two requirements (many parts on one host)
	def Plus(poOther)
		_r_ = new stzResourceSpec()
		_r_.SetMemory(@nMem + poOther.MemoryMB())
		_r_.SetCompute(@nCpu + poOther.ComputeVCPU())
		_r_.SetStorage(@nDisk + poOther.StorageGB())
		# the merged gpu need is the STRONGER of the two
		if @cGpu = "required" or poOther.GpuNeed() = "required"
			_r_.SetGpuRequiredQ()
		but @cGpu = "optional" or poOther.GpuNeed() = "optional"
			_r_.SetGpuOptionalQ()
		ok
		return _r_

	# Returns the spec as one line such as 2048MB / 2 vCPU / 20GB / gpu required.
	#
	#   returns    a text
	#   warning    the line ends with +gpu when a GPU is present
	#   see        Show
	def Text()
		_c_ = "" + @nMem + "MB / " + @nCpu + " vCPU / " + @nDisk + "GB"
		if @cGpu != ""
			_c_ += " / gpu " + @cGpu
		ok
		if @bGpuPresent
			_c_ += " / +gpu"
		ok
		return _c_

	# Prints the line that Text gives.
	#
	#   returns    nothing; it prints
	#   see        Text
	def Show()
		? This.Text()


  #====================#
 #  DEPLOYMENT SITE    #
#====================#

# Describes where a solution is deployed and how to reach and drive that place: kind, endpoint, protocol, authentication, storage, commands and capacity.
#
# A site is configuration first: set it with the Set methods (each has a Q form that returns the
# site to chain), read it back as data with Config, as lines with ConfigText or as JSON with
# ConfigJson, and see the commands it would run with Commands, TransferCommand and LaunchCommandLine
# before anything runs. Authentication is a plain reference, a stzSecret kept behind a redacted
# descriptor, or a secret held by name in a stzSecretStore and revealed through ResolveAuthVia so
# that the store audits it. Store, Launch, Status and Rollback act on the target: a local folder is
# written directly, a git site runs git, a server runs scp and ssh, and registry, device and object-
# store sites have commands listed but no store backend. A stzDeployment drives sites under a
# governed actor. The runs behind this reference only configured and read sites; nothing was stored
# to, launched on or rolled back.
#
#   receiver   o1 = new stzDeploymentSite("prod-api")
#   example    o1.SetKindQ("server").SetEndpointQ("deploy@api.example.test:/srv/api")
#              ? o1.Protocol()
#              #--> ssh
#              ? o1.TransferCommand()
#              #--> scp -r <staged>/. deploy@api.example.test:/srv/api
#              ? o1.IsLocal()
#              #--> 0
#   see        StzDeploymentSiteQ, stzDeployment, stzResourceSpec, stzSecretStore
class stzDeploymentSite from stzObject

	@cName = ""
	@cKind = "localrepo"
	@cEndpoint = ""
	@cProtocol = ""
	@cAuthRef = ""
	@cStorage = ""
	@cLaunch = ""
	@cStatusCmd = ""
	@oCapacity = ""   # the host's resources (stzResourceSpec) -- declared or discovered
	@cProvider = ""     # a provisioning provider (aws/gcp/proxmox/...) -> scriptable host
	@oAuthSecret = ""   # a stzSecret guarding the credential (else @cAuthRef is a plain ref)
	@bStoreBacked = 0 # auth is a NAME in a central store -- reveal via the store (audited)
	@cAuthStoreName = ""  # the secret's name in that store

	# Builds a site with the given name, of kind localrepo, with no endpoint, storage, auth, capacity or provider.
	#
	#   pcName     the site's name
	#   returns    nothing; the object is built
	#   see        SetKind, SetEndpoint
	def init(pcName)
		@cName = "" + pcName

	# Sets the kind of the site, which decides how it is reached: localrepo, server, gitrepo, registry, device or objectstore.
	#
	#   pcKind     the kind, trimmed and lowered
	#   returns    nothing; use SetKindQ to chain
	#   note       an unknown kind is accepted and then behaves like a site with no backend
	#   see        KindName, Protocol, Store
	#@ aka  -- the access config (Q-fluent: chainable via the ...Q suffix) ---
	def SetKind(pcKind)
		This.SetKindQ(pcKind)

	def SetKindQ(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	# Sets the address of the site, such as a user@host:path or a repository path or URL.
	#
	#   pcUrl      the address
	#   returns    nothing; use SetEndpointQ to chain
	#   see        EndpointOf, SetProtocol
	def SetEndpoint(pcUrl)
		This.SetEndpointQ(pcUrl)

	def SetEndpointQ(pcUrl)
		@cEndpoint = "" + pcUrl
		return This

	# Sets the access protocol, instead of the default of the kind.
	#
	#   pcProtocol   the protocol such as ssh, file, git, https or serial, trimmed and lowered
	#   returns      nothing; use SetProtocolQ to chain
	#   see          Protocol, SetKind
	def SetProtocol(pcProtocol)
		This.SetProtocolQ(pcProtocol)

	def SetProtocolQ(pcProtocol)
		@cProtocol = StzLower(ring_trim("" + pcProtocol))
		return This

	# Sets how the site authenticates: a plain reference text, or a stzSecret that the site then keeps behind a redacted descriptor.
	#
	#   pRef       a reference text such as env/DEPLOY_KEY, or a stzSecret
	#   returns    nothing; use SetAuthRefQ to chain
	#   note       with a secret, the key never appears in Config, ConfigText or ConfigJson, only
	#              its descriptor
	#   warning    anything else raises an error
	#   see        SetAuthFromStore, ResolveAuth, AuthReference
	#@ aka  auth is EITHER a plain reference string (e.g. "env/DEPLOY_KEY", back-compat) OR a stzSecret. When it is a secret, the site stores the OBJECT and displays only its redacted descriptor -- the key never lands in Config/ConfigJson.
	def SetAuthRef(pRef)
		This.SetAuthRefQ(pRef)

	def SetAuthRefQ(pRef)
		if isObject(pRef)
			@bStoreBacked = 0
			@cAuthStoreName = ""
			@oAuthSecret = pRef
			@cAuthRef = pRef.Descriptor()
		but isString(pRef)
			@bStoreBacked = 0
			@cAuthStoreName = ""
			@oAuthSecret = ""
			@cAuthRef = "" + pRef
		else
			StzRaise("SetAuthRefQ expects a reference string or a stzSecret.")
		ok
		return This

	# Sets the authentication to a secret held by name in a central secret store, so every reveal is audited by that store.
	#
	#   poStore    the stzSecretStore that holds the secret
	#   pcName     the secret's name in that store
	#   returns    nothing; use SetAuthFromStoreQ to chain
	#   note       the site keeps the name and the redacted descriptor, never the store or the value
	#   warning    it raises an error when poStore is not an object and when the store has no secret
	#              of that name
	#   see        ResolveAuthVia, SetAuthRef, IsStoreBacked
	#@ aka  reference the auth secret BY NAME from a central stzSecretStore. The site holds NO key and NO store object -- only the name (Ring copies objects on assignment, so a held store would be a private copy whose audit no one sees). The reveal is done through the SHARED store, passed by reference at reveal time (ResolveAuthVia), so the store's gate applies AND the store audits it. This is how a project k
	def SetAuthFromStore(poStore, pcName)
		This.SetAuthFromStoreQ(poStore, pcName)

	def SetAuthFromStoreQ(poStore, pcName)
		if NOT isObject(poStore)
			StzRaise("SetAuthFromStoreQ expects a stzSecretStore.")
		ok
		if NOT poStore.Has(pcName)
			StzRaise("SetAuthFromStoreQ: the store has no secret named '" + pcName + "'.")
		ok
		@bStoreBacked = 1
		@cAuthStoreName = "" + pcName
		@oAuthSecret = ""
		@cAuthRef = poStore.DescriptorOf(pcName)   # redacted, captured for display/config
		return This

	# Sets the staging location where artifacts are stored: the folder of a local site, or the staging folder before a copy to a server.
	#
	#   pcLocation   the folder path
	#   returns      nothing; use SetStoreAtQ to chain
	#   see          StorageLocation, Store
	def SetStoreAt(pcLocation)
		This.SetStoreAtQ(pcLocation)

	def SetStoreAtQ(pcLocation)
		@cStorage = "" + pcLocation
		return This

	# Sets the command that starts the deployed solution on the site.
	#
	#   pcCmd      the command line
	#   returns    nothing; use SetLaunchWithQ to chain
	#   note       on a server the command is wrapped in ssh to the host
	#   see        LaunchCommandLine, Launch
	def SetLaunchWith(pcCmd)
		This.SetLaunchWithQ(pcCmd)

	def SetLaunchWithQ(pcCmd)
		@cLaunch = "" + pcCmd
		return This

	# Sets the command that reports the state of the deployed solution, kept in the config.
	#
	#   pcCmd      the command line
	#   returns    nothing; use SetStatusWithQ to chain
	#   note       Status does not run it: it is only recorded and shown
	#   see        Config, Status
	def SetStatusWith(pcCmd)
		This.SetStatusWithQ(pcCmd)

	def SetStatusWithQ(pcCmd)
		@cStatusCmd = "" + pcCmd
		return This

	# Declares what the host provides, as a resource spec, so that feasibility can be checked against what parts need.
	#
	#   poSpec     a stzResourceSpec of memory in MB, vCPU and storage in GB
	#   returns    nothing; use SetCapacityQ to chain
	#   see        CapacityOf, HasCapacity, SetProvider
	#@ aka  what the host PROVIDES (its capacity). For a real host it is discovered via the provider API; for a fixed host it is declared here.
	def SetCapacity(poSpec)
		This.SetCapacityQ(poSpec)

	def SetCapacityQ(poSpec)
		@oCapacity = poSpec
		return This

	# Declares which cloud or hypervisor, aws or proxmox, can create this host, which makes the site scriptable.
	#
	#   pcName     the provider name, trimmed and lowered
	#   returns    nothing; use SetProviderQ to chain
	#   see        ProviderName, IsScriptable, ProvisionCommandFor
	#@ aka  name a provisioning provider -> this host can be CREATED/resized to meet a requirement (IaC-style), not just deployed to.
	def SetProvider(pcName)
		This.SetProviderQ(pcName)

	def SetProviderQ(pcName)
		@cProvider = StzLower(ring_trim("" + pcName))
		return This

	# Returns the name the site was given.
	#
	#   returns    a text
	#   see        init
	#@ aka  -- reads ----------------------------------------------
	def Name()
		return @cName

	# Returns the kind of the site in lower case.
	#
	#   returns    a text, localrepo by default
	#   see        SetKind
	def KindName()
		return @cKind

	# Returns the address of the site.
	#
	#   returns    a text; empty when none was set
	#   see        SetEndpoint
	def EndpointOf()
		return @cEndpoint

	# Returns the access protocol: the one set, or the default of the kind.
	#
	#   returns    a text: file for localrepo and unknown kinds, ssh for server, git for gitrepo,
	#              https for registry and objectstore, serial for device
	#   see        SetProtocol, SetKind
	def Protocol()
		if @cProtocol != ""
			return @cProtocol
		ok
		return _StzSiteDefaultProtocol(@cKind)

	# Returns the authentication reference shown for the site.
	#
	#   returns    a text: the plain reference, or the redacted descriptor of a secret; empty when
	#              none
	#   see        SetAuthRef, ResolveAuth
	def AuthReference()
		return @cAuthRef

	# Returns the stzSecret the site holds directly.
	#
	#   returns    a stzSecret; an empty text when the site has a plain reference, a store-backed
	#              secret or nothing
	#   see        HasAuthSecret, SetAuthRef
	def AuthSecret()
		return @oAuthSecret

	# TRUE if the site holds a stzSecret directly.
	#
	#   returns    1 or 0
	#   note       a store-backed secret answers 0 here
	#   see        HasSecretAuth, AuthSecret
	def HasAuthSecret()
		return isObject(@oAuthSecret)

	# TRUE if the authentication is a secret held by name in a central store.
	#
	#   returns    1 or 0
	#   see        SetAuthFromStore, AuthStoreName
	def IsStoreBacked()
		return @bStoreBacked

	# Returns the name of the store-held secret used for authentication.
	#
	#   returns    a text; empty when the site is not store-backed
	#   see        SetAuthFromStore, IsStoreBacked
	def AuthStoreName()
		return @cAuthStoreName

	# TRUE if the authentication is a secret, held directly or by name in a store, rather than a plain reference.
	#
	#   returns    1 or 0
	#   see        HasAuthSecret, IsStoreBacked
	#@ aka  the site holds a secret (directly, or by name in a store) rather than a ref.
	def HasSecretAuth()
		return isObject(@oAuthSecret) or @bStoreBacked

	# Returns the live authentication value: the secret revealed to an actor that may see it, or the plain reference as it is.
	#
	#   poActor    the actor asking, which must be effectful and not sandboxed to reveal a secret
	#   returns    a text
	#   note       the reveal of a directly held secret is not recorded in a store's access log
	#   warning    it raises an error for a store-backed site, telling you to use ResolveAuthVia,
	#              and a language-model actor is refused when the site holds a secret
	#   see        ResolveAuthVia, SetAuthRef
	#@ aka  the LIVE auth value -- GOVERNED. For a directly-held stzSecret it reveals with the actor gate; for a plain ref string it returns it as-is. A STORE-BACKED secret cannot be revealed here -- the store must be passed by reference so its audit is real; use ResolveAuthVia(store, actor).
	def ResolveAuth(poActor)
		if @bStoreBacked
			StzRaise("Site '" + @cName + "': auth is store-backed ('" + @cAuthStoreName +
				"'). Reveal it through the store so the access is audited: " +
				"ResolveAuthVia(store, actor).")
		but isObject(@oAuthSecret)
			return @oAuthSecret.Reveal(poActor)
		ok
		return @cAuthRef

	# Returns the live authentication value through the shared secret store, so the store's gate applies and the access is logged.
	#
	#   poStore    the stzSecretStore that holds the secret
	#   poActor    the actor asking
	#   returns    a text
	#   note       for a site that is not store-backed the store is ignored and the answer is that
	#              of ResolveAuth
	#   warning    it raises an error when the site is store-backed and poStore is not an object
	#   see        ResolveAuth, SetAuthFromStore
	#@ aka  the store-aware reveal: the shared store is passed HERE (by reference), so its gate applies AND it AUDITS the access -- the project's one audit trail stays complete. For a non-store-backed site the store is ignored and this behaves like ResolveAuth(actor).
	def ResolveAuthVia(poStore, poActor)
		if @bStoreBacked
			if NOT isObject(poStore)
				StzRaise("ResolveAuthVia: a stzSecretStore is required for a store-backed site.")
			ok
			return poStore.Reveal(@cAuthStoreName, poActor)
		ok
		return This.ResolveAuth(poActor)

	# Returns the staging location.
	#
	#   returns    a text; empty when none was set
	#   see        SetStoreAt
	def StorageLocation()
		return @cStorage

	# TRUE if the site is a local folder, kind localrepo or local.
	#
	#   returns    1 or 0
	#   see        KindName, Store
	def IsLocal()
		return @cKind = "localrepo" or @cKind = "local"

	# Returns the capacity the host was declared to have.
	#
	#   returns    a stzResourceSpec; an empty text when none was declared
	#   see        SetCapacity, HasCapacity
	def CapacityOf()
		return @oCapacity

	# TRUE if a capacity was declared.
	#
	#   returns    1 or 0
	#   see        SetCapacity, CapacityOf
	def HasCapacity()
		return isObject(@oCapacity)

	# Returns the provisioning provider in lower case.
	#
	#   returns    a text; empty when none
	#   see        SetProvider
	def ProviderName()
		return @cProvider

	# TRUE if a provider is named, so that the host can be created by a command.
	#
	#   returns    1 or 0
	#   see        SetProvider, ProvisionCommandFor
	def IsScriptable()
		return @cProvider != ""

	# Returns the access configuration as a nested list of the name, kind, connection, storage, control, capacity and provider.
	#
	#   returns    a list of pairs; the connection and control entries are lists of pairs, and
	#              capacity is a text or (undeclared)
	#   note       a secret appears only as its descriptor
	#   see        ConfigText, ConfigJson
	#@ aka  the access config as inspectable DATA -- the LINK between the programming environment and this site (connection + storage + control). CAPACITY AND PROVIDER BELONG HERE. They are exactly what _SiteFeasibility() reads to decide whether a part fits a site or has to be provisioned -- and they appeared in NONE of the three renderings below. A site could be declared, printed and saved without the two fa
	def Config()
		_cap_ = "(undeclared)"
		if This.HasCapacity()
			_cap_ = @oCapacity.Text()
		ok
		return [
			[ "name",    @cName ],
			[ "kind",    @cKind ],
			[ "connection", [ [ "endpoint", @cEndpoint ], [ "protocol", This.Protocol() ], [ "auth", @cAuthRef ] ] ],
			[ "storage", @cStorage ],
			[ "control", [ [ "launch", @cLaunch ], [ "status", @cStatusCmd ] ] ],
			[ "capacity", _cap_ ],
			[ "provider", @cProvider ]
		]

	# Returns the configuration as readable lines, naming the site and its kind first.
	#
	#   returns    a text with one line per set item: connection, storage, and launch, status,
	#              capacity and provider when set
	#   see        Config, Show
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
		# status was carried by Config() and ConfigJson() and missing only here --
		# the human reading of a site disagreed with both machine readings of it
		if @cStatusCmd != ""
			_c_ += "  status:     " + @cStatusCmd + nl
		ok
		if This.HasCapacity()
			_c_ += "  capacity:   " + @oCapacity.Text() + nl
		ok
		if @cProvider != ""
			_c_ += "  provider:   " + @cProvider + nl
		ok
		return _c_

	# Returns the configuration as JSON text, with the capacity as numbers or null.
	#
	#   returns    a text
	#   note       a secret appears only as its descriptor
	#   warning    quotes and backslashes in a value are not escaped, so a launch command or path
	#              containing them gives invalid JSON
	#   see        SaveConfigTo, Config
	#@ aka  the config, serialized -- so a target site can be SAVED, versioned, shared: the persistent link the dev/emulation environment reads to reach a site.
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
		_c_ += ", " + _q_ + "status" + _q_ + ": " + _q_ + @cStatusCmd + _q_ + " }," + nl

		# capacity crosses as NUMBERS here and as text in ConfigText(): this is the
		# form a machine reads back, and "4096MB / 8 vCPU / 500GB" is a sentence.
		if This.HasCapacity()
			_c_ += "  " + _q_ + "capacity" + _q_ + ": { " + _q_ + "memoryMB" + _q_ + ": " + @oCapacity.MemoryMB()
			_c_ += ", " + _q_ + "vcpu" + _q_ + ": " + @oCapacity.ComputeVCPU()
			_c_ += ", " + _q_ + "storageGB" + _q_ + ": " + @oCapacity.StorageGB() + " }," + nl
		else
			_c_ += "  " + _q_ + "capacity" + _q_ + ": null," + nl
		ok
		_c_ += "  " + _q_ + "provider" + _q_ + ": " + _q_ + @cProvider + _q_ + nl
		_c_ += "}" + nl
		return _c_

	# Writes the JSON configuration to a file, overwriting it.
	#
	#   pcPath     the file path to write
	#   returns    the site itself, so calls chain
	#   warning    the file is overwritten if it exists
	#   see        ConfigJson
	def SaveConfigTo(pcPath)
		write("" + pcPath, This.ConfigJson())
		return This

	# TRUE if the site can be reached: a local site needs a storage location, a git site answers to git ls-remote, any other needs an endpoint.
	#
	#   returns    1 or 0
	#   warning    for a git site it starts a git process against the endpoint, and it was run only
	#              against a path that is not a repository
	#   see        Status, Store
	#@ aka  -- access + control (LIVE backends, dispatched by kind) --
	def Reachable()
		if This.IsLocal()
			return @cStorage != ""
		but @cKind = "gitrepo" or @cKind = "git"
			return This._Sh("git ls-remote " + @cEndpoint)[1] = 0
		ok
		return @cEndpoint != ""

	# Sends artifacts to the site: writes them to the local folder, or commits and pushes them for git, or stages and copies them for a server.
	#
	#   paArtifacts   a list of pairs, each a relative file name and its content
	#   returns       1 if stored, 0 if it failed or the kind has no store backend
	#   note          this was read from the code and not run against a target
	#   warning       it writes files and runs git, scp or similar, so only the refusal for a site
	#                 with no storage was run, and registry, device and objectstore sites return 0
	#                 although Commands lists a command for the first two
	#   see           Launch, Status, Commands
	def Store(paArtifacts)
		if This.IsLocal()
			return This._LocalStore(paArtifacts)
		but @cKind = "gitrepo" or @cKind = "git"
			return This._GitStore(paArtifacts)
		but @cKind = "server"
			return This._ServerStore(paArtifacts)
		ok
		return 0

	# Starts the deployed solution: marks a local site as launched, nothing more for git, and runs the launch command over ssh for a server.
	#
	#   returns    1 if launched, 0 if it could not be or the kind has no launch backend
	#   warning    it changes the target, so only the refusal for a site with nothing stored was run
	#   see        Store, Status, SetLaunchWith
	def Launch()
		if This.IsLocal()
			return This._LocalLaunch()
		but @cKind = "gitrepo" or @cKind = "git"
			return 1   # a git deploy IS the push -- nothing more to start
		but @cKind = "server"
			return This._ServerLaunch()
		ok
		return 0

	# Returns the state of the site as a word: absent, stored, launched or rolledback.
	#
	#   returns    a text; absent for a site with no record and always for server, registry, device
	#              and objectstore
	#   note       a local site reads it from its marker file, and a git site is launched when its
	#              main branch exists
	#   see        Store, Launch, Rollback
	def Status()
		if This.IsLocal()
			return This._LocalStatus()
		but @cKind = "gitrepo" or @cKind = "git"
			return This._GitStatus()
		ok
		return "absent"

	# Withdraws the deployment from a local site by removing its manifest and marking it rolledback.
	#
	#   returns    1; it also returns 1 for other kinds, where it does nothing
	#   warning    it writes into the storage folder, so it was not run on a local site, and reading
	#              the code shows that with no storage location the paths become /deploy.json and
	#              /.stzsite at the root of the drive
	#   see        Store, Status
	def Rollback()
		if This.IsLocal()
			StzFileDelete(@cStorage + "/deploy.json")
			write(@cStorage + "/.stzsite", "state=rolledback" + nl + "kind=" + @cKind + nl)
			return 1
		ok
		return 1   # kind-specific rollback (git revert / instance terminate) -- best effort

	# Runs the provider command that creates or resizes the host to meet a requirement.
	#
	#   poReq      a stzResourceSpec of what the host must provide
	#   returns    1 if the command ran and exited with 0, 0 if there is no command or it failed
	#   note       the command to be run is shown first by ProvisionCommandFor
	#   warning    it runs a provider command line and creates real resources, so only the case with
	#              no command was run
	#   see        ProvisionCommandFor, SetProvider
	#@ aka  provision a scriptable host to meet a requirement (the IaC move -- bring the host into existence, don't just deploy to it). Runs the provider CLI via the child.
	def Provision(poReq)
		_cmd_ = This.ProvisionCommandFor(poReq)
		if _cmd_ = ""
			return 0
		ok
		return This._Sh(_cmd_)[1] = 0

	# Returns the store and launch commands that would be run, without running them.
	#
	#   returns    a list of pairs, each a step name (store or launch) and its command line; empty
	#              for a local site with no launch command
	#   see        TransferCommand, LaunchCommandLine
	#@ aka  -- the real commands, rehearsable (see them before they run) --
	def Commands()
		_out_ = []
		if This.TransferCommand() != ""
			_out_ + [ "store", This.TransferCommand() ]
		ok
		if This.LaunchCommandLine() != ""
			_out_ + [ "launch", This.LaunchCommandLine() ]
		ok
		return _out_

	# Returns the command that sends artifacts to the site.
	#
	#   returns    a text: git push for gitrepo, scp for server, docker push for registry, esptool
	#              for device; empty for other kinds
	#   note       registry and device commands are generated only: Store does not run them
	#   see        Commands, Store
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

	# Returns the command that starts the solution, wrapped in ssh for a server.
	#
	#   returns    a text; empty when no launch command was set
	#   see        SetLaunchWith, Commands
	def LaunchCommandLine()
		if @cKind = "server" and @cLaunch != ""
			return "ssh " + This._SshHost() + " '" + @cLaunch + "'"
		ok
		return @cLaunch

	# Returns the provider command that would create a host of the required size, without running it.
	#
	#   poReq      a stzResourceSpec giving memory, vCPU and storage
	#   returns    a text; empty when the provider is not aws or proxmox, or poReq is not an object
	#   note       the aws command picks t3.micro up to 1024 MB, t3.small to 2048, t3.medium to 4096
	#              and t3.large above
	#   see        Provision, SetProvider
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
			return 0
		ok
		StzEngineDirCreatePath(@cStorage)
		_n_ = len(paArtifacts)
		for _i_ = 1 to _n_
			This._WriteArtifact(@cStorage, paArtifacts[_i_][1], paArtifacts[_i_][2])
		next
		write(@cStorage + "/.stzsite", "state=stored" + nl + "kind=" + @cKind + nl)
		return 1

	def _LocalLaunch()
		if @cStorage = "" or StzEngineFileExists(@cStorage + "/.stzsite") = 0
			return 0
		ok
		_rec_ = "state=launched" + nl + "kind=" + @cKind + nl
		if @cLaunch != ""
			_rec_ += "launch=" + @cLaunch + nl
		ok
		write(@cStorage + "/.stzsite", _rec_)
		return 1

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
			return 0
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
			return 0
		ok
		StzEngineDirCreatePath(@cStorage)
		_n_ = len(paArtifacts)
		for _i_ = 1 to _n_
			This._WriteArtifact(@cStorage, paArtifacts[_i_][1], paArtifacts[_i_][2])
		next
		return This._Sh("scp -r " + @cStorage + "/. " + @cEndpoint)[1] = 0

	def _ServerLaunch()
		if @cLaunch = ""
			return 1
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

	# Prints the configuration text to the console.
	#
	#   returns    nothing
	#   see        ConfigText
	def Show()
		? This.ConfigText()


  #================#
 #  DEPLOYMENT     #
#================#

# Sends each part of a delivery plan to its site, stores it, launches it and reports back, all governed by the actor's authority.
#
# Bind parts to stzDeploymentSite objects with SetTarget, order them with RunAfter, attach real
# build outputs with Artifact, and set an actor. Only an effectful actor commits: with no actor, or
# with a language-model actor, Store, Launch and Run are rehearsals that touch nothing and say so in
# their rows. Steps gives the ordered plan (provision, store, launch, verify per part), Run executes
# it with a verify gate and rolls the completed steps back in reverse on a failure, and Feasibility
# asks whether each host has room. Explain and Plan are pure reading. With an effectful actor Store,
# Launch and Run write to sites, start parts and can provision hosts: the documentation run used
# only the rehearsing path.
#
#   receiver   oD = new stzDelivery("bistro") oD.AddBackend(:api, :LinuxServer) oS = new
#              stzDeploymentSite("local-api")
#              oS.SetKindQ(:LocalRepo).SetStoreAtQ("deploy_demo/site_api") o1 = new
#              stzDeployment(oD) o1.SetTarget(:api, oS) o1.SetActor(LLMActor("assistant"))
#   example    ? o1.MayCommit()
#              #--> 0
#              ? len(o1.Steps())
#              #--> 3
#              ? @@( o1.Store() )
#              #--> [ 0, [ [ "api", "local-api", "rehearsed (not committed)" ] ] ]
#              aRun = o1.Run()
#              ? aRun[1]
#              #--> 0
#              ? o1.WasRun()
#              #--> 1
#              ? o1.WasCommitted()
#              #--> 0
#   see        stzDeploymentSite, stzDelivery, stzSystemActor, stzResourceSpec
class stzDeployment from stzObject

	@oDelivery = ""
	@aBindings = []   # [ partName, siteObject ]
	@oActor = ""
	@aAfter = []      # [ partName, dependsOnPartName ] -- ordering (the plan DAG)
	@aArtifacts = []  # [ partName, relName, filePath ] -- the REAL build outputs to ship
	@oLog = ""      # a structured stzLog of what Run() actually did
	@bRan = 0     # did Run() actually execute? (a refused deploy never runs)
	@bCommitted = 0  # ...and did it COMMIT, or only rehearse?

	# Creates a deployment of a delivery plan, with a structured trace log that records everything it does.
	#
	#   poDelivery   the stzDelivery whose parts are to be deployed
	#   returns      nothing; the object is built
	#   see          SetTarget, Run
	def init(poDelivery)
		@oDelivery = poDelivery
		@oLog = new stzLog("deployment")
		@oLog.SetLevelQ(:trace)   # a deployment records everything it does

	# Returns the structured log of the deployment, filled by Run.
	#
	#   returns    a stzLog
	#   warning    entries carry a sequence number, a time, a level, a category and fields
	#   see        Run
	#@ aka  the structured log of the deployment run -- queryable and renderable (oDep.Log().EntriesOfLevel(:error), oDep.Log().AsJson()). Populated by Run().
	def Log()
		return @oLog

	# Binds a part of the solution to the site it will be stored on and launched from.
	#
	#   pcPart     the part's name, stored in lower case
	#   poSite     the stzDeploymentSite that receives the part
	#   returns    the deployment itself, so calls chain
	#   warning    binding a part twice keeps both bindings, and SiteFor answers the first
	#   see        SetTargets, Plan
	#@ aka  bind a part to its target site. For many at once, use SetTargets.
	def SetTarget(pcPart, poSite)
		@aBindings + [ StzLower("" + pcPart), poSite ]
		return This

	# Binds many parts at once.
	#
	#   paList     a list of [ part, site ] pairs
	#   returns    the deployment itself, so calls chain
	#   warning    a value that is not a list changes nothing
	#   see        SetTarget
	def SetTargets(paList)
		if isList(paList)
			_n_ = len(paList)
			for _i_ = 1 to _n_
				@aBindings + [ StzLower("" + paList[_i_][1]), paList[_i_][2] ]
			next
		ok
		return This

	# Orders the plan: a part is stored only after another part has been verified.
	#
	#   pcPart        the part that must wait
	#   pcDependsOn   the part that must be verified first
	#   returns       the deployment itself, so calls chain
	#   warning       the edge appears in Steps as the first step of pcPart waiting on verify of
	#                 pcDependsOn
	#   see           Steps
	#@ aka  order the plan: pcPart runs AFTER pcDependsOn is verified (a plan-DAG edge). Simple deployments declare none; complex ones (a frontend after its backend) do.
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

	# Attaches a real build output to ship with a part, under a name at the destination.
	#
	#   pcPart      the part that ships it
	#   pcRelName   its name at the destination
	#   pcPath      the built file on disk
	#   returns     the deployment itself, so calls chain
	#   warning     the file is not read here: a path that does not exist is recorded as given
	#   see         ArtifactsAttached, AttachBundle
	#@ aka  attach a REAL build output to ship for a part (the per-part stz_<part>.wasm, the app bundle, the native binary...). pcRelName is its name at the destination; pcPath is the built file on disk. Shipped byte-for-byte alongside the manifest.
	def Artifact(pcPart, pcRelName, pcPath)
		@aArtifacts + [ StzLower("" + pcPart), "" + pcRelName, "" + pcPath ]
		return This

	# Returns the attached artifacts as [ part, name, path ] rows.
	#
	#   returns    a list of lists
	#   see        Artifact
	def ArtifactsAttached()
		return @aArtifacts

	# Attaches a whole emulator bundle folder as a part's production artifact, so the tree that was emulated is what ships.
	#
	#   pcPart     the part that ships it
	#   pBundle    a stzEmulator, which is built on demand, or the folder path of a built bundle
	#   returns    the deployment itself, so calls chain
	#   note       with a folder path it only records the folder; with an emulator it writes the
	#              bundle
	#   warning    the bundle is shipped under the delivery's name
	#   see        AttachSlice, Artifact
	#@ aka  wire an emulator's built bundle DIRECTORY straight in as a part's production artifact -- the SAME tree you emulated becomes what ships. Accepts a stzEmulator (built on demand) or a bundle directory path; the bundle lands under the solution name.
	def AttachBundle(pcPart, pBundle)
		return This.Artifact(pcPart, @oDelivery.Name(), This._BundleDirOf(pBundle))

	# Attaches only a part's own slice of a bundle: its app as index.html, its engine subset and the bridge, those that exist.
	#
	#   pcPart     the part whose slice is shipped
	#   pBundle    a stzEmulator or the folder path of a built bundle
	#   returns    the deployment itself, so calls chain
	#   warning    files that are missing are skipped silently: a folder with no app_<part>.html
	#              attaches nothing
	#   see        AttachBundle
	#@ aka  ship a part's OWN slice from an emulator bundle -- its app (as index.html), its engine subset (stz_<part>.wasm), and the bridge (stz.js) -- NOT the whole mission-control. A frontend part deploys only what it needs to run.
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

	# Sets the actor under whose authority the deployment acts; only an effectful actor commits.
	#
	#   poActor    a stzSystemActor, such as a human or a language-model actor
	#   returns    the deployment itself, so calls chain
	#   warning    without an actor, or with a language-model actor, every action is a rehearsal
	#              that touches nothing
	#   see        MayCommit, Run
	def SetActor(poActor)
		@oActor = poActor
		return This

	# Returns the part-to-site bindings as [ part, site ] rows.
	#
	#   returns    a list of lists
	#   see        SetTarget
	def Bindings()
		return @aBindings

	# Returns how many bindings there are.
	#
	#   returns    a number
	#   see        Bindings
	def NumberOfBindings()
		return len(@aBindings)

	# Returns the site bound to a part; an empty text when the part is unbound.
	#
	#   pcPart     the part's name, matched without regard to case
	#   returns    a stzDeploymentSite, or an empty text
	#   see        SetTarget, Plan
	def SiteFor(pcPart)
		_c_ = StzLower("" + pcPart)
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			if @aBindings[_i_][1] = _c_
				return @aBindings[_i_][2]
			ok
		next
		return ""

	# TRUE if the actor is effectful, so that Store, Launch and Run would really act.
	#
	#   returns    TRUE or FALSE
	#   warning    FALSE without an actor
	#   see        SetActor
	#@ aka  the governance gate: may this deployment cross to reality?
	def MayCommit()
		if @oActor = ""
			return 0
		ok
		return @oActor.Can("effectful")

	# Returns each part of the delivery with its binding: [ part, kind, target, site name, site kind, protocol ].
	#
	#   returns    a list of lists
	#   warning    an unbound part shows (unbound) for its site
	#   see        Steps, Explain
	#@ aka  -- the deployment plan (rehearsal) --------------------
	def Plan()
		_oPlan_ = @oDelivery.Plan()
		_aParts_ = _oPlan_.Parts()
		_out_ = []
		_n_ = len(_aParts_)
		for _i_ = 1 to _n_
			_p_ = _aParts_[_i_]
			_site_ = This.SiteFor(_p_[1])
			if _site_ = ""
				_out_ + [ _p_[1], _p_[2], _p_[3], "(unbound)", "", "" ]
			else
				_out_ + [ _p_[1], _p_[2], _p_[3], _site_.Name(), _site_.KindName(), _site_.Protocol() ]
			ok
		next
		return _out_

	# Returns the rehearsal as lines of text: the actor, each part with its site, reach and storage, the host feasibility and the ordered steps.
	#
	#   returns    a list of strings
	#   warning    pure reading: nothing runs
	#   see        Show, Plan
	def Explain()
		_c_ = "Deployment of '" + @oDelivery.Name() + "' -- from definition to launch (rehearsal)" + nl
		_c_ += "==============================================================================" + nl
		if This.MayCommit()
			_c_ += "  actor: " + @oActor.Name() + " -- MAY commit (effectful)" + nl
		but @oActor != ""
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

	# Prints the lines that Explain returns.
	#
	#   returns    nothing; it prints
	#   see        Explain
	def Show()
		_aLines_ = This.Explain()
		_n_ = len(_aLines_)
		for _i_ = 1 to _n_
			? _aLines_[_i_]
		next

	# Stores each bound part's artifact on its site when the actor may commit, else only rehearses.
	#
	#   returns    a list [ committed, rows ], each row [ part, site, outcome ] with stored, store-
	#              failed or rehearsed (not committed)
	#   warning    effectful with an effectful actor: it writes into the site's storage; it was run
	#              here only without an actor and with a language-model actor, where every row read
	#              rehearsed (not committed) and nothing was written
	#   see        Launch, Run
	#@ aka  -- perform (governed) ---------------------------------
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

	# Launches each bound part on its site when the actor may commit, else only rehearses.
	#
	#   returns    a list [ committed, rows ], each row [ part, site, outcome ] with launched,
	#              launch-failed or rehearsed (not committed)
	#   warning    effectful with an effectful actor: it starts the part on its site; it was run
	#              here only without an actor and with a language-model actor, where nothing was
	#              launched
	#   see        Store, Run
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

	# Returns the state of each bound site as [ part, site, state ] rows.
	#
	#   returns    a list of lists
	#   warning    asks each site for its state: a local site reads its folder, a git site runs git,
	#              any other kind answers absent; it was run on local sites whose folder does not
	#              exist, where every state read absent
	#   see        Run
	def Status()
		_recs_ = []
		_n_ = len(@aBindings)
		for _i_ = 1 to _n_
			_recs_ + [ @aBindings[_i_][1], @aBindings[_i_][2].Name(), @aBindings[_i_][2].Status() ]
		next
		return _recs_

	# Returns the ordered plan as [ name, op, part, site, needs ] rows: provision if scriptable, then store, launch and verify.
	#
	#   returns    a list of lists
	#   warning    the order is topological; a cycle of RunAfter edges is appended unordered instead
	#              of refused
	#   see        Run, RunAfter
	#@ aka  -- the plan of steps (order, gates, rollback) ---------
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
			_progress_ = 0
			_next_ = []
			_nr_ = len(_remaining_)
			for _i_ = 1 to _nr_
				_st_ = _remaining_[_i_]
				_needs_ = _st_[5]
				_ready_ = 1
				_nn_ = len(_needs_)
				for _k_ = 1 to _nn_
					if StzFindFirst(_needs_[_k_], _placed_) = 0
						_ready_ = 0
					ok
				next
				if _ready_
					_ordered_ + _st_
					_placed_ + _st_[1]
					_progress_ = 1
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

	# TRUE if Run was called, whether it committed or only rehearsed.
	#
	#   returns    TRUE or FALSE
	#   warning    a deployment refused upstream stays FALSE
	#   see        Run, WasCommitted
	#@ aka  EXECUTE the ordered plan (governed). Each step runs its op; the verify step is a GATE (the site must be launched). On any failure, the completed store/launch steps are ROLLED BACK in reverse -- the deployment is transactional. Returns [ committed(0/1), [ [stepName, outcome], ... ] ]. No effectful actor -> rehearse. Did Run() execute at all? A deployment REFUSED upstream -- by the service gate in s
	def WasRun()
		return @bRan

	# TRUE if Run really committed, which is not so for a rehearsal or a failed and rolled back run.
	#
	#   returns    TRUE or FALSE
	#   see        Run, WasRun
	#@ aka  Did it commit, or only rehearse? Rehearsed steps touch nothing.
	def WasCommitted()
		return @bCommitted

	# Executes the ordered plan under the actor's authority, with a verify gate and rollback on failure, and returns each step's outcome.
	#
	#   returns    a list [ committed, rows ], each row [ step, outcome ] with done, rehearsed,
	#              FAILED or skipped
	#   note       a failed step makes the later steps skipped
	#   warning    effectful with an effectful actor: it stores, launches and may provision hosts
	#              and roll back; it was run here only without an actor and with a language-model
	#              actor, where every step read rehearsed and nothing happened; a part whose
	#              requirement declares a GPU is checked before its first step, and on a local site
	#              that probes this machine's GPU, which was not exercised
	#   see        Steps, Store, Launch
	def Run()
		@bRan = 1
		_bMay_ = This.MayCommit()
		@oLog.Record(:info, "deployment run started", [ [ :actor, This._ActorName() ], [ :commit, _bMay_ ] ])
		_steps_ = This.Steps()
		_recs_ = []
		_undo_ = []
		_failed_ = 0
		_gated_ = []   # parts whose GPU admission has been checked
		_n_ = len(_steps_)
		for _i_ = 1 to _n_
			_st_ = _steps_[_i_]
			_flds_ = [ [ :step, _st_[1] ], [ :op, _st_[2] ], [ :part, _st_[3] ] ]
			if _failed_
				_recs_ + [ _st_[1], "skipped" ]
				@oLog.Record(:warn, "step skipped (an earlier step failed)", _flds_)
				loop
			ok
			# the GPU ADMISSION gate (G5): checked once per part, BEFORE its
			# first step -- an admission question, not a provisioning action,
			# so it fires whether or not the site is scriptable.
			if StzFindFirst(_st_[3], _gated_) = 0
				_gated_ + _st_[3]
				_req_ = @oDelivery.RequirementFor(_st_[3])
				if isObject(_req_) and NOT This._GpuGateOk(_req_, This.SiteFor(_st_[3]), _st_[3])
					_recs_ + [ _st_[1], "FAILED" ]
					@oLog.Record(:error, "step FAILED (the gpu admission gate refused)", _flds_)
					_failed_ = 1
					loop
				ok
			ok
			if NOT _bMay_
				_recs_ + [ _st_[1], "rehearsed" ]
				@oLog.Record(:info, "step rehearsed -- not committed (no effectful actor)", _flds_)
				loop
			ok
			_site_ = This.SiteFor(_st_[3])
			if This._RunStep(_st_[2], _site_, _st_[3])
				_recs_ + [ _st_[1], "done" ]
				@oLog.Record(:info, "step done", _flds_)
				if _st_[2] = "store" or _st_[2] = "launch"
					_undo_ + _site_
				ok
			else
				_recs_ + [ _st_[1], "FAILED" ]
				@oLog.Record(:error, "step FAILED", _flds_)
				_failed_ = 1
			ok
		next
		if _failed_ and _bMay_
			_nu_ = len(_undo_)
			for _i_ = _nu_ to 1 step -1
				@oLog.Record(:warn, "rolling back", [ [ :site, _undo_[_i_].Name() ] ])
				_undo_[_i_].Rollback()
			next
		ok
		_flag_ = 1
		if _failed_ or NOT _bMay_
			_flag_ = 0
		ok
		@bCommitted = (_flag_ = 1)
		if _failed_
			@oLog.Record(:error, "deployment run FAILED -- rolled back", [ [ :steps, _n_ ] ])
		but NOT _bMay_
			@oLog.Record(:info, "deployment rehearsed -- nothing committed", [ [ :steps, _n_ ] ])
		else
			@oLog.Record(:info, "deployment run complete", [ [ :steps, _n_ ] ])
		ok
		return [ _flag_, _recs_ ]

	def _ActorName()
		if isObject(@oActor)
			return @oActor.Name()
		ok
		return "(none)"

	def _RunStep(pcOp, poSite, pcPart)
		if pcOp = "provision"
			_req_ = @oDelivery.RequirementFor(pcPart)
			if NOT isObject(_req_)
				return 1   # no requirement to size the host to
			ok
			return poSite.Provision(_req_)
		but pcOp = "store"
			return poSite.Store(This._ArtifactsFor(pcPart))
		but pcOp = "launch"
			return poSite.Launch()
		but pcOp = "verify"
			return poSite.Status() = "launched"
		ok
		return 1

	# -- the GPU capability gate (G5, SOFTANZA_GPU_PLAN.md) -----------------
	# A part's requirement declares SetGpuRequired() or SetGpuOptional().
	#   required + no GPU at the site -> the provision step FAILS (Deploy
	#                                    refuses; the run rolls back)
	#   optional + no GPU             -> Deploy proceeds; the degrade is
	#                                    LOGGED (the part's seams fall back
	#                                    to CPU and COUNT it -- G1's law)
	# The site's GPU truth: its declared capacity if any; a LIVE PROBE of
	# this machine when the site is local; absent otherwise (a remote site
	# that never declared a GPU is honestly treated as having none).
	def _GpuGateOk(poReq, poSite, pcPart)
		_cNeed_ = poReq.GpuNeed()
		if _cNeed_ = ""
			return 1
		ok
		if This._SiteHasGpu(poSite)
			@oLog.Record(:info, "gpu present at the site", [ [ :part, pcPart ], [ :site, poSite.Name() ] ])
			return 1
		ok
		if _cNeed_ = "required"
			@oLog.Record(:error, "part REQUIRES a gpu and the site has none -- refused", [ [ :part, pcPart ], [ :site, poSite.Name() ] ])
			return 0
		ok
		@oLog.Record(:warn, "no gpu at the site -- part deploys DEGRADED (cpu fallback)", [ [ :part, pcPart ], [ :site, poSite.Name() ] ])
		return 1

	def _SiteHasGpu(poSite)
		_oCap_ = poSite.CapacityOf()
		if isObject(_oCap_) and _oCap_.HasGpu()
			return 1
		ok
		if poSite.IsLocal()
			# the local machine can answer for ITSELF -- probe the device
			if StzEngineGpuIsAvailable() = 0
				StzEngineGpuInit($cStzGpuRuntime)
			ok
			return StzEngineGpuIsAvailable() = 1
		ok
		return 0

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

	# Returns, per site, whether it can host the parts bound to it: [ site, required, capacity, fits, note ] rows.
	#
	#   returns    a list of lists, fits being 1 or 0
	#   warning    the requirements of the parts on one site are added up; a site with no declared
	#              capacity is assumed to fit, and a scriptable site is assumed to be provisioned
	#   see        Feasible, Explain
	#@ aka  -- feasibility (host resources) -----------------------
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

	# TRUE if every site can host its parts, by its capacity or by being provisioned.
	#
	#   returns    TRUE or FALSE
	#   warning    Run does not check it: a deployment with a shortfall still rehearses
	#   see        Feasibility
	#@ aka  TRUE only if every site can host its parts (fits or can provision).
	def Feasible()
		_f_ = This.Feasibility()
		_n_ = len(_f_)
		for _i_ = 1 to _n_
			if _f_[_i_][4] = 0
				return 0
			ok
		next
		return 1

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
