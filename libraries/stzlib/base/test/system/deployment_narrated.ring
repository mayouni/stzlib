# stzDeployment -- deployment as a first-class story: from DEFINITION (the brain's
# plan) and EMULATION (Deploy(:Emulated)) to STORAGE and LAUNCH of the solution on
# real target sites.
#
# A stzDeploymentSite is a config-described DESTINATION (a "target repo"): its
# CONFIG captures every required connection / storage / protocol / control detail,
# so the site is reachable and controllable right from the programming environment.
# A stzDeployment binds each part to a site and stores/launches/reports -- GOVERNED:
# only an effectful actor commits; an LLM actor may rehearse but touches nothing.
#
# LocalRepo sites store/launch for real here (stand-ins for the real repos); the
# remote-backend transfer is a later slice -- the config model does not change.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cBase = WorkingDirectory() + "/_deploy_scratch"
StzDirDeleteAll(cBase)   # fresh start (recursive -- no leftovers pollute the absence-checks)
StzEngineDirCreatePath(cBase)

# DEFINITION -- the same restolean solution the brain plans and the emulator runs
oBrain = new stzBuilderBrain("restolean")
oBrain.WithSuperApp(:phone, :Android)
oBrain.WithBackend(:api, :LinuxServer)
oBrain.WithFirmware(:node, :ESP32)
oBrain.NeedsIn(:phone, [ :Unicode, :PivotTable, :ConstraintSolver, :Collection, :Neural ])
oBrain.NeedsIn(:api,   [ :PivotTable, :Neural ])
oBrain.NeedsIn(:node,  [ :GPIO, :Pattern ])

? "-- Scene 1: a target SITE is described by a CONFIG -- the LINK to the site --"
oRemote = new stzDeploymentSite("prod-api")
oRemote.Kind(:Server)
oRemote.Endpoint("deploy@api.restolean.app:/srv/restolean")
oRemote.Via(:ssh)
oRemote.AuthRef("env/DEPLOY_KEY")
oRemote.StoreAt("/srv/restolean/api")
oRemote.LaunchWith("systemctl restart restolean-api")
? oRemote.ConfigText()
chk("the config captures the connection (endpoint / protocol / auth)",
	oRemote.Protocol() = "ssh" and StzFindFirst("api.restolean.app", oRemote.ConfigJson()) > 0 and StzFindFirst("DEPLOY_KEY", oRemote.ConfigJson()) > 0)
chk("...and the storage + control (where it lands, how it launches)",
	StzFindFirst("/srv/restolean/api", oRemote.ConfigJson()) > 0 and StzFindFirst("systemctl restart", oRemote.ConfigJson()) > 0)
oRemote.SaveConfigTo(cBase + "/prod-api.site.json")
chk("...the config persists as a shareable link file (the site becomes reachable from the env)",
	StzEngineFileExists(cBase + "/prod-api.site.json") = 1)

? ""
? "-- Scene 2: bind each part of the solution to its site, and rehearse --"
oSitePhone = new stzDeploymentSite("app-store")
oSitePhone.Kind(:LocalRepo).StoreAt(cBase + "/site_phone")
oSiteApi = new stzDeploymentSite("prod-api")
oSiteApi.Kind(:LocalRepo).StoreAt(cBase + "/site_api")
oSiteNode = new stzDeploymentSite("fleet-node")
oSiteNode.Kind(:LocalRepo).StoreAt(cBase + "/site_node")

oDep = new stzDeployment(oBrain)
oDep.AsActor(LLMActor("assistant"))
oDep.To(:phone, oSitePhone)
oDep.To(:api, oSiteApi)
oDep.To(:node, oSiteNode)

cEx = oDep.Explain()
? cEx
chk("the deployment plan binds every part to a site",
	StzFindFirst("app-store", cEx) > 0 and StzFindFirst("prod-api", cEx) > 0 and StzFindFirst("fleet-node", cEx) > 0)

? ""
? "-- Scene 3: GOVERNED -- an LLM actor may rehearse but commits NOTHING --"
chk("the LLM actor MAY NOT commit (not effectful)", NOT oDep.MayCommit())
aStore = oDep.Store()
chk("...Store() rehearses, does not commit (committed = 0)", aStore[1] = 0)
chk("...nothing landed on disk", StzEngineFileExists(cBase + "/site_api/deploy.json") = 0)

? ""
? "-- Scene 4: an ops actor MAY commit -- store + launch, for real --"
oDep.AsActor(HumanActor("ops"))
chk("the ops actor MAY commit (effectful)", oDep.MayCommit())
aStore2 = oDep.Store()
chk("...Store() commits (committed = 1)", aStore2[1] = 1)
chk("...each part's artifact landed on its site",
	StzEngineFileExists(cBase + "/site_phone/deploy.json") = 1 and StzEngineFileExists(cBase + "/site_api/deploy.json") = 1 and StzEngineFileExists(cBase + "/site_node/deploy.json") = 1)
chk("...the stored artifact carries the part's engine subset (phone -> aggregation + solver)",
	StzFindFirst("aggregation", read(cBase + "/site_phone/deploy.json")) > 0 and StzFindFirst("solver", read(cBase + "/site_phone/deploy.json")) > 0)

? ""
? "-- Scene 5: launch on the sites, then report status back to the editor --"
aLaunch = oDep.Launch()
chk("Launch() commits", aLaunch[1] = 1)
aStatus = oDep.Status()
chk("...every site reports 'launched'", aStatus[1][3] = "launched" and aStatus[2][3] = "launched" and aStatus[3][3] = "launched")

? ""
? "-- Scene 6: brain.Deploy(:Production) DRIVES the deployment -- one verb, two phases --"
oSiteX = new stzDeploymentSite("prod-x")
oSiteX.Kind(:LocalRepo).StoreAt(cBase + "/site_prodx")
oBrain.DeployTo(:api, oSiteX)
oDepA = oBrain.Deploy(:Production)
chk("Deploy(:Production) returns a stzDeployment bound to the site", oDepA.NumberOfBindings() = 1)
chk("...with no actor set it rehearses -- nothing committed (safe by default)", StzEngineFileExists(cBase + "/site_prodx/deploy.json") = 0)
oBrain.AsActor(HumanActor("release-bot"))
oDepB = oBrain.Deploy(:Production)
chk("...with an effectful actor it COMMITS -- the artifact lands and the site launches",
	StzEngineFileExists(cBase + "/site_prodx/deploy.json") = 1 and oDepB.Status()[1][3] = "launched")

? ""
? "-- Scene 7: host FEASIBILITY -- required resources vs the host's capacity --"
oBrain.RequiresIn(:api, StzResourcesQ().Memory(2048).Compute(2).Storage(20))
oFit = new stzDeploymentSite("prod-1")
oFit.Kind(:Server).Capacity(StzResourcesQ().Memory(4096).Compute(4).Storage(100))
oDepF = new stzDeployment(oBrain)
oDepF.To(:api, oFit)
chk("a host with enough memory/compute/storage is feasible", oDepF.Feasible())
chk("...the check reports it fits", oDepF.Feasibility()[1][4] = 1)
oSmall = new stzDeploymentSite("tiny")
oSmall.Kind(:Server).Capacity(StzResourcesQ().Memory(512).Compute(1).Storage(5))
oDepS = new stzDeployment(oBrain)
oDepS.To(:api, oSmall)
chk("an undersized host is NOT feasible (a pre-flight gate, before any commit)", NOT oDepS.Feasible())
oCloud = new stzDeploymentSite("gpu-pool")
oCloud.Kind(:Server).Provider(:aws)
oDepC = new stzDeployment(oBrain)
oDepC.To(:api, oCloud)
chk("a scriptable host is feasible -- it provisions to meet the requirement",
	oDepC.Feasible() and StzFindFirst("provision", oDepC.Feasibility()[1][5]) > 0)

StzDirDeleteAll(cBase)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
