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

? ""
? "-- Scene 8: the deployment is a PLAN of ordered steps (store -> launch -> verify) --"
oS1 = new stzDeploymentSite("s-api")
oS1.Kind(:LocalRepo).StoreAt(cBase + "/s_api")
oDepP = new stzDeployment(oBrain)
oDepP.To(:api, oS1)
aSteps = oDepP.Steps()
chk("a simple deployment is a chain: store -> launch -> verify",
	len(aSteps) = 3 and aSteps[1][2] = "store" and aSteps[2][2] = "launch" and aSteps[3][2] = "verify")

? ""
? "-- Scene 9: complex plans ORDER by dependency (a frontend after its backend) --"
oSb = new stzDeploymentSite("s-back")
oSb.Kind(:LocalRepo).StoreAt(cBase + "/s_back")
oSf = new stzDeploymentSite("s-front")
oSf.Kind(:LocalRepo).StoreAt(cBase + "/s_front")
oDepX = new stzDeployment(oBrain)
oDepX.To(:api, oSb)
oDepX.To(:phone, oSf)
oDepX.After(:phone, :api)
aX = oDepX.Steps()
nVer = 0
nSto = 0
nAX = len(aX)
for i = 1 to nAX
	if aX[i][1] = "verify:api" nVer = i ok
	if aX[i][1] = "store:phone" nSto = i ok
next
chk("the frontend's store waits for the backend's verify", nVer > 0 and nSto > nVer)

? ""
? "-- Scene 10: a failing step ROLLS BACK the completed ones (transactional) --"
oGood = new stzDeploymentSite("ok-site")
oGood.Kind(:LocalRepo).StoreAt(cBase + "/ok")
oBad = new stzDeploymentSite("bad-site")
oBad.Kind(:Server)
oDepR = new stzDeployment(oBrain)
oDepR.AsActor(HumanActor("ops"))
oDepR.To(:phone, oGood)
oDepR.To(:api, oBad)
oDepR.After(:api, :phone)
aRun = oDepR.Run()
chk("the run does NOT commit -- a step (the unreachable remote store) failed", aRun[1] = 0)
chk("...the phone that already deployed is ROLLED BACK (transactional)", oGood.Status() = "rolledback")

? ""
? "-- Scene 11: LIVE backend -- :GitRepo runs REAL git through the managed child --"
cGitBare = cBase + "/bare.git"
cGitWork = cBase + "/gitwork"
oGb = SpawnProcess("git init --bare -q " + cGitBare)
oGb.ReadOutputAll()  oGb.ReadErrorAll()  oGb.Wait()  oGb.Close()
oGit = new stzDeploymentSite("git-remote")
oGit.Kind(:GitRepo).Endpoint(cGitBare).StoreAt(cGitWork)
chk("the git remote is reachable (real git ls-remote)", oGit.Reachable())
chk("Store() pushes for REAL (git commit + push, via SpawnProcess)", oGit.Store([ [ "deploy.json", "part=api" ] ]))
chk("...Status() reads the deployed ref back -> launched", oGit.Status() = "launched")
oShow = SpawnProcess("git --git-dir=" + cGitBare + " show main:deploy.json")
cGitShow = oShow.ReadOutputAll()  oShow.ReadErrorAll()  oShow.Wait()  oShow.Close()
chk("...the artifact TRULY landed in the git repo", StzFindFirst("part=api", cGitShow) > 0)

? ""
? "-- Scene 12: the other backends generate correct commands (run where tool + target exist) --"
oSrv = new stzDeploymentSite("prod-srv")
oSrv.Kind(:Server).Endpoint("deploy@host:/srv/app").LaunchWith("systemctl restart app")
chk("a :Server stores over scp and launches over ssh",
	StzFindFirst("scp -r", oSrv.TransferCommand()) > 0 and StzFindFirst("ssh deploy@host", oSrv.LaunchCommandLine()) > 0 and StzFindFirst("systemctl restart app", oSrv.LaunchCommandLine()) > 0)
oVm = new stzDeploymentSite("vm")
oVm.Provider(:proxmox)
chk("a scriptable host provisions from the resource spec (proxmox qm)",
	StzFindFirst("qm create --name vm --memory 2048 --cores 2", oVm.ProvisionCommandFor(StzResourcesQ().Memory(2048).Compute(2).Storage(20))) > 0)
oAws = new stzDeploymentSite("vm-aws")
oAws.Provider(:aws)
chk("...and maps memory to an AWS instance type", StzFindFirst("t3.small", oAws.ProvisionCommandFor(StzResourcesQ().Memory(2048).Compute(2).Storage(20))) > 0)

? ""
? "-- Scene 13: ship a REAL artifact -- a compiled stz.wasm, byte-for-byte to the target --"
? "(building a real engine subset -- a few seconds)"
cArt = cBase + "/stz_api.wasm"
StzBuildEngineWasmSubset([ "solver" ], cArt)
nWasmSize = StzEngineFileSize(cArt)
chk("a REAL stz.wasm artifact was built (a KB-scale binary, not a ~150B manifest)", nWasmSize > 1000)
cW = read(cArt)
chk("...it is a real wasm binary (magic bytes 0asm)", len(cW) > 4 and ascii(cW[2]) = 97 and ascii(cW[3]) = 115 and ascii(cW[4]) = 109)

cArtBare = cBase + "/art.git"
oAb = SpawnProcess("git init --bare -q " + cArtBare)
oAb.ReadOutputAll()  oAb.ReadErrorAll()  oAb.Wait()  oAb.Close()
oArtSite = new stzDeploymentSite("cdn")
oArtSite.Kind(:GitRepo).Endpoint(cArtBare).StoreAt(cBase + "/artwork")
oDepA = new stzDeployment(oBrain)
oDepA.AsActor(HumanActor("ops"))
oDepA.To(:api, oArtSite)
oDepA.Artifact(:api, "stz_api.wasm", cArt)
aRunA = oDepA.Run()
chk("the deployment ships it through the git backend (Run commits)", aRunA[1] = 1)
oCat = SpawnProcess("git --git-dir=" + cArtBare + " cat-file -s main:stz_api.wasm")
cCat = ring_trim(oCat.ReadOutputAll())
oCat.ReadErrorAll()  oCat.Wait()  oCat.Close()
chk("...the EXACT binary landed in the target (git blob size == built " + nWasmSize + " B)", cCat = "" + nWasmSize)

? ""
? "-- Scene 14: attach a whole BUNDLE DIRECTORY -- the tree ships in one call --"
cBundle = cBase + "/webbundle"
StzEngineDirCreatePath(cBundle + "/assets")
write(cBundle + "/index.html", "<h1>restolean</h1>")
write(cBundle + "/assets/app.js", "console.log('hi')")
write(cBundle + "/.deployrc", "env=prod")
write(cBundle + "/stz.wasm", char(0) + "asm" + char(1) + char(0) + char(0) + char(0) + "ENGINE")
nBinSize = StzEngineFileSize(cBundle + "/stz.wasm")

cWbBare = cBase + "/wb.git"
oWb = SpawnProcess("git init --bare -q " + cWbBare)
oWb.ReadOutputAll()  oWb.ReadErrorAll()  oWb.Wait()  oWb.Close()
oWbSite = new stzDeploymentSite("cdn2")
oWbSite.Kind(:GitRepo).Endpoint(cWbBare).StoreAt(cBase + "/wbwork")
oDepW = new stzDeployment(oBrain)
oDepW.AsActor(HumanActor("ops"))
oDepW.To(:phone, oWbSite)
oDepW.Artifact(:phone, "site", cBundle)
aRunW = oDepW.Run()
chk("a whole bundle DIRECTORY ships in one attach (Run commits)", aRunW[1] = 1)
oLs = SpawnProcess("git --git-dir=" + cWbBare + " ls-tree -r --name-only main")
cLs = oLs.ReadOutputAll()  oLs.ReadErrorAll()  oLs.Wait()  oLs.Close()
chk("...every file landed with its path (index.html + nested assets/app.js)",
	StzFindFirst("site/index.html", cLs) > 0 and StzFindFirst("site/assets/app.js", cLs) > 0)
chk("...dotfiles included (.deployrc)", StzFindFirst("site/.deployrc", cLs) > 0)
oBz = SpawnProcess("git --git-dir=" + cWbBare + " cat-file -s main:site/stz.wasm")
cBz = ring_trim(oBz.ReadOutputAll())
oBz.ReadErrorAll()  oBz.Wait()  oBz.Close()
chk("...and the nested BINARY is byte-intact (blob size == " + nBinSize + ")", cBz = "" + nBinSize)

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
