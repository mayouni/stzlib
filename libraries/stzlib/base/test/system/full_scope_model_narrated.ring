# Full scope model (Phase 3b) STRESS -- the architect's common ground.
#
# The claim (SOFTANZA_SYSTEM_FOUNDATION.md section 2): model the SOLUTION first
# (a platform + its apps, each deploying to a system), then write feature code in
# a NAMED scope -- App(:x).System() -- that resolves to that app's deployment
# profile. The scope DOWN-CONSTRAINS (refuses, on the dev box, an operation the
# target forbids) and UP-ENABLES (rehearses an operation the target needs but the
# dev host cannot perform). Its facts are the target's -- an ESP32 scope says
# 'espidf' on a Windows box.
#
# Builds entirely on the Phase 1b capability envelope; no engine work.
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cCwd0 = WorkingDirectory()
cScratch = cCwd0 + "/_plat_scratch"
StzEngineDirCreatePath(cScratch)

? "-- Scene 1: model the solution -- a platform PROFILE and its constituents --"
oSol = new stzPlatformProfile("my-iot-product")
oSol.DevelopedOn(:Windows)
oSol.WithServer(:backend, :LinuxServer)
oSol.WithSuperApp(:superapp, :Android)
oSol.WithApp(:firmware, :ESP32)
chk("the solution has three constituents", oSol.NumberOfParts() = 3)
chk("...named backend / superapp / firmware", oSol.HasApp(:backend) and oSol.HasApp(:superapp) and oSol.HasApp(:firmware))
chk("...of the declared kinds (server / superapp / app)",
	oSol.App(:backend).Kind() = "server" and oSol.App(:superapp).Kind() = "superapp" and oSol.App(:firmware).Kind() = "app")
chk("the firmware deploys to an ESP32 (espidf)", oSol.App(:firmware).DeploymentOSName() = "espidf")
chk("the superapp deploys to android", oSol.App(:superapp).DeploymentOSName() = "android")

? ""
? "-- Scene 2: the solution model is structurally validated --"
chk("a fully-modelled solution is sound", oSol.IsSound())
oBad = new stzPlatformProfile("bad")
chk("...one with no dev system and no apps is NOT", NOT oBad.IsSound())
chk("...and it says why", len(oBad.Validate()) >= 1)
oBad2 = new stzPlatformProfile("bad2")
oBad2.DevelopedOn(:Windows)
oBad2.AddApp(new stzAppProfile("orphan"))
chk("an app with no deployment target is flagged", NOT oBad2.IsSound())

? ""
? "-- Scene 3: the three scopes are named and distinct --"
oDev = oSol.DevelopmentSystem()
chk("DevelopmentSystem() is the declared dev system", oDev.OSName() = "windows" and oDev.IsDevelopment())
oCur = oSol.CurrentSystem()
chk("CurrentSystem() is the live runtime", oCur.IsRuntime())
oFwScope = oSol.App(:firmware).System()
chk("App(:firmware).System() is the ESP32 deployment scope", oFwScope.OSName() = "espidf")

? ""
? "-- Scene 4: NO live leak -- the scope carries the TARGET's facts --"
oMobScope = oSol.App(:superapp).System()
chk("on this Windows box, the firmware scope still says espidf", oFwScope.OSName() = "espidf" and oFwScope.OSName() != oDev.OSName())
chk("...and the mobile scope says android", oMobScope.OSName() = "android")

? ""
? "-- Scene 5: DOWN-CONSTRAIN -- the scope refuses what the target forbids --"
oFw1 = oSol.App(:firmware).System()
bR1 = FALSE
try
	oFw1.Spawn("worker")
catch
	bR1 = TRUE
done
chk("Spawn is refused in the firmware scope (an MCU has no processes)", bR1)
oMob1 = oSol.App(:superapp).System()
bR2 = FALSE
try
	oMob1.Spawn("worker")
catch
	bR2 = TRUE
done
chk("Spawn is refused in the mobile scope too (Android's sandbox)", bR2)
chk("the firmware scope reports that it forbids 'process'", oFw1.Forbids("process"))

? ""
? "-- Scene 6: UP-ENABLE -- the scope rehearses what the host lacks --"
oFw2 = oSol.App(:firmware).System()
chk("ReadPin is ALLOWED and rehearsed (gpio is on the ESP32)", oFw2.ReadPin(4) = "rehearsed")
chk("...because the dev host has no gpio", oFw2.WouldRehearse("gpio"))
chk("...the rehearsed op is captured for the deploy-time lowering", len(oFw2.RehearsedOperations()) = 1)

? ""
? "-- Scene 7: NATIVE -- host and target both have the capability --"
oBack = oSol.App(:backend).System()
chk("WriteFile runs natively in the backend scope", oBack.WriteFile("/var/data.txt", "x") = "native")
chk("...and so does Spawn (a Linux server has processes)", oBack.Spawn("worker") = "native")
chk("...both recorded as native", len(oBack.NativeOperations()) = 2)

? ""
? "-- Scene 8: the SAME operation, different verdicts per scope --"
# Spawn: native on the Linux backend, refused on ESP32 and Android. The scope,
# not the op, decides.
oB2 = oSol.App(:backend).System()
oF3 = oSol.App(:firmware).System()
bFw = FALSE
try
	oF3.Spawn("x")
catch
	bFw = TRUE
done
chk("Spawn is native in backend but refused in firmware", oB2.Spawn("x") = "native" and bFw)

? ""
? "-- Scene 9: the check runs against the TARGET, on the dev box --"
# We are really on Windows, which CAN spawn -- yet the firmware scope refuses,
# because the scope is the ESP32, not the host. Host can, scope forbids.
chk("the live dev host CAN spawn a process", DevelopmentSystem().Can("process"))
oF4 = oSol.App(:firmware).System()
chk("...but the firmware scope forbids it anyway (down-constrain)", oF4.Forbids("process"))

? ""
? "-- Scene 10: feature code reads naturally in a scope BLOCK --"
oS = oSol.App(:firmware).System()
oS { ReadPin(1)  WritePin(2, 1) }
chk("the block's two gpio ops were checked", oS.NumberOfChecked() = 2)
chk("...both up-enabled (rehearsed) for the target", len(oS.RehearsedOperations()) = 2)

? ""
? "-- Scene 11: the .stzplatform format round-trips --"
cText = oSol.ToStzPlatform()
chk("the serialized text names the solution", StzFindFirst("my-iot-product", cText) > 0)
oBackP = StzPlatformProfileQ()
oBackP.FromString(cText)
chk("the app count survives", oBackP.NumberOfApps() = 3)
chk("...and the firmware target", oBackP.App(:firmware).DeploymentOSName() = "espidf")
cPath = cScratch + "/solution.stzplatform"
oSol.Save(cPath)
oFileP = StzPlatformProfileQ()
oFileP.LoadFrom(cPath)
chk("Save + LoadFrom round-trips the file", oFileP.App(:superapp).DeploymentOSName() = "android")
killreal(cPath)

? ""
? "-- Scene 12: ONE model -- the scope's profile also gates actors (Phase 1b/4) --"
oFwProfile = oSol.App(:firmware).System().System()
chk("the scope's target is a full system profile", oFwProfile.Can("gpio"))
chk("...whose capabilities gate an actor too: an LLM gets nothing", len(oFwProfile.CapabilitiesForActorKinds([ "inference" ])) = 0)
chk("...a human/PI gets the effectful/sensing/compute ones", len(oFwProfile.CapabilitiesForActorKinds([ "effectful", "sensing", "compute" ])) > 0)

? ""
? "-- Scene 13: a stzPlatform OWNS the profile; Build() THEN Deploy() --"
# We do not deploy a profile -- a PLATFORM (which owns the profile) is built,
# then deployed. Two separate, ordered operations.
# each part declares its LANGUAGE + source, so Build() compiles it by language.
# Set BEFORE SetProfile: a platform OWNS a snapshot of its profile.
oSol.App(:backend).SetLanguage(:Ring).AddSource("backend.ring")
oSol.App(:firmware).SetLanguage(:C).AddSource("firmware.c")
# (the superapp declares none -- Build() records it as such)
oPlatform = StzPlatformQ("my-iot-product")
oPlatform.SetProfile(oSol)
chk("the platform owns the deployment profile", oPlatform.HasProfile())
chk("...seeing all three constituents", oPlatform.NumberOfParts() = 3)
chk("it is neither built nor deployed yet", oPlatform.IsBuilt() = 0 and oPlatform.IsDeployed() = 0)
bDeployEarly = FALSE
try
	oPlatform.Deploy()
catch
	bDeployEarly = TRUE
done
chk("Deploy() before Build() is REFUSED (they are separate, ordered)", bDeployEarly)
oPlatform.Build()
chk("after Build(), the platform is built", oPlatform.IsBuilt())
chk("...with a build entry per constituent", len(oPlatform.BuildReport()) = 3)
chk("Build() WIRES stzBuilder -- the firmware compiles in C, for the ESP32", oPlatform.LanguageOf(:firmware) = "c" and StzFindFirst("firmware.c", oPlatform.BuildCommandFor(:firmware)) > 0)
chk("...targeting the ESP32 triple, not the host (riscv32-freestanding)", StzFindFirst("riscv32-freestanding", oPlatform.BuildCommandFor(:firmware)) > 0)
chk("...the backend compiles in RING -- the ENGINE linked into a standalone (vm.c), never the interpreter", oPlatform.LanguageOf(:backend) = "ring" and StzFindFirst("vm.c", oPlatform.BuildCommandFor(:backend)) > 0)
chk("...for the backend's OWN target -- x86_64-linux, different from the firmware's", StzFindFirst("x86_64-linux", oPlatform.BuildCommandFor(:backend)) > 0)
chk("...a part with no declared language is recorded as such (nothing to compile)", StzFindFirst("no language", oPlatform.BuildCommandFor(:superapp)) > 0)
oPlatform.Deploy()
chk("...and NOW Deploy() succeeds", oPlatform.IsDeployed())
chk("...deploying every constituent to its target", len(oPlatform.DeployReport()) = 3)
chk("the platform LOG captured Build + Deploy -- both completed", StzFindFirst("build complete", oPlatform.Log().AsText()) > 0 and StzFindFirst("deploy complete", oPlatform.Log().AsText()) > 0)
chk("...and the earlier premature Deploy() is in the log as an ERROR (governance visible)", oPlatform.Log().CountOfLevel(:error) >= 1)
chk("...structured + queryable -- an entry per part, renderable as JSON", len(oPlatform.Log().Where(:part, "firmware")) >= 1 and StzFindFirst(char(34) + "category" + char(34) + ": " + char(34) + "platform", oPlatform.Log().AsJson()) > 0)

? ""
? "-- Scene 14: an unsound solution cannot be built --"
oBadPlat = StzPlatformQ("bad")
oBadPlat.SetProfile(new stzPlatformProfile("empty"))   # no dev system, no apps
bBuildRefused = FALSE
try
	oBadPlat.Build()
catch
	bBuildRefused = TRUE
done
chk("Build() refuses an unsound solution", bBuildRefused)

? ""
? "-- Scene 15: the deploy-time LOWERING bridge -- a rehearsal becomes firmware --"
# Author feature code per part (persisted as plain data), then Build + Deploy:
# the bridge lowers each part's UP-ENABLED rehearsals into a real target artifact.
oSol2 = new stzPlatformProfile("iot2")
oSol2.DevelopedOn(:Windows)
oSol2.WithApp(:firmware, :ESP32)
oSol2.WithServer(:backend, :LinuxServer)
chk("ReadPin authored for the ESP32 is up-enabled (rehearsed)", oSol2.ReadPinIn(:firmware, 4) = "rehearsed")
oSol2.WritePinIn(:firmware, 2, 1)
bSpawnRefused = FALSE
try
	oSol2.SpawnIn(:firmware, "worker")
catch
	bSpawnRefused = TRUE
done
chk("...authoring a forbidden op (Spawn on an MCU) is refused (down-constrain)", bSpawnRefused)
chk("WriteFile on the Linux backend is native (no lowering needed)", oSol2.WriteFileIn(:backend, "/var/x") = "native")
oPlat2 = StzPlatformQ("iot2").SetProfile(oSol2)
oPlat2.Build()
oPlat2.Deploy()
cFw = oPlat2.ArtifactFor(:firmware)
chk("the firmware artifact is generated code", StzFindFirst("void loop()", cFw) > 0)
chk("...ReadPin(4) LOWERED to digitalRead(4)", StzFindFirst("digitalRead(4)", cFw) > 0)
chk("...WritePin(2,1) LOWERED to digitalWrite(2, 1)", StzFindFirst("digitalWrite(2, 1)", cFw) > 0)
chk("the native backend op produced no firmware ops", StzFindFirst("digitalRead", oPlat2.ArtifactFor(:backend)) = 0)

? ""
? "-- Scene 16: the deploy is GOVERNED -- an LLM cannot lower to reality --"
oPlat3 = StzPlatformQ("iot2").SetProfile(oSol2)
oPlat3.Build()
bLLMDeploy = FALSE
try
	oPlat3.DeployAs(LLMActor("gen"))
catch
	bLLMDeploy = TRUE
done
chk("an LLM actor cannot perform the deploy (its effect set is empty)", bLLMDeploy)
chk("...so nothing was deployed", oPlat3.IsDeployed() = 0)
oPlat3.DeployAs(HumanActor("alice"))
chk("...but a human actor can", oPlat3.IsDeployed())

# cleanup
StzEngineDirDelete(cScratch)

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

func killreal cPath
	if StzEngineFileExists(cPath) = 1
		StzEngineFileDelete(cPath)
	ok
