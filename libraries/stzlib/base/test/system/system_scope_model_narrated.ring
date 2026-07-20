# Scope-model FLOOR (Phase 1b) STRESS -- the three system scopes, the capability
# envelope, the two worlds, and the system<->agent bridge.
#
# The claim under test (SOFTANZA_SYSTEM_FOUNDATION.md section 2): system code is
# written in a NAMED scope, never against an ambient "current". Three scopes:
#   DevelopmentSystem() -- the dev machine, live.
#   CurrentSystem()     -- wherever this runs now (== dev during development).
#   a declared profile  -- a deployment target the dev box is NOT; its facts are
#                          STORED, so an rtos/android profile never leaks the
#                          live machine's os.
# The keystone is the capability envelope, classified into the SAME abstract
# kinds (effectful/sensing/compute/inference) the agentic lattice uses -- so the
# two worlds (forbid/require) AND the system<->agent bridge are one lattice.
#
# Ring traps avoided: main code before the first func; no inline new X().M();
# no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: DevelopmentSystem() is the live dev machine --"
oDev = DevelopmentSystem()
chk("its role is 'development'", oDev.Role() = "development")
chk("it is a LIVE scope, not declared", oDev.IsLive() and NOT oDev.IsDeclared())
chk("the os name is real (non-empty)", len(oDev.OSName()) > 0 and oDev.OSName() != "unknown")
chk("the bit size is 32 or 64", oDev.BitSize() = 32 or oDev.BitSize() = 64)
chk("the cpu count is positive", oDev.CpuCount() > 0)
chk("the language version is Ring's", len(oDev.LanguageVersion()) > 0)
chk("a dev box has effectful capabilities", oDev.CapabilitiesQ().IsEffectful())
chk("...it can touch the filesystem", oDev.Can(:filesystem))
chk("...and it LACKS gpio (it is not a microcontroller)", oDev.Lacks(:gpio))

? ""
? "-- Scene 2: CurrentSystem() agrees with the dev machine DURING development --"
# The point of section 2.1: after deployment CurrentSystem() would resolve to
# the target; during development it resolves to -- and agrees with -- the dev
# machine. The same source, honestly answered for where it runs.
oCur = CurrentSystem()
chk("its role is 'runtime'", oCur.Role() = "runtime" and oCur.IsRuntime())
chk("its os equals the dev os (same live machine)", oCur.OSName() = oDev.OSName())
chk("its arch equals the dev arch", oCur.Architecture() = oDev.Architecture())
chk("its bit size equals the dev bit size", oCur.BitSize() = oDev.BitSize())
chk("its capability count equals the dev count",
	oCur.CapabilitiesQ().NumberOfCapabilities() = oDev.CapabilitiesQ().NumberOfCapabilities())

? ""
? "-- Scene 3: the three scopes are DISTINCT and unconfusable --"
chk("development is only development", oDev.IsDevelopment() and NOT oDev.IsRuntime() and NOT oDev.IsDeployment())
chk("runtime is only runtime", oCur.IsRuntime() and NOT oCur.IsDevelopment() and NOT oCur.IsDeployment())

? ""
? "-- Scene 4: a declared ESP32 target -- NO live leak --"
# Declared on THIS Windows box, the ESP32 profile must still answer 'rtos'. Its
# facts are stored values, never read from the running machine.
oEsp = DeclareSystem("esp32-firmware")
oEsp.SetOSName(:rtos)
oEsp.SetArchitecture(:arm)
oEsp.SetBitSize(32)
oEsp.SetEndianness(:little)
oEsp.SetCapabilityList([ :gpio, :network, :clock, :threads ])
chk("the target says 'rtos', NOT the live 'windows'", oEsp.OSName() = "rtos" and oEsp.OSName() != oDev.OSName())
chk("it is an embedded system class", oEsp.IsEmbedded())
chk("it is a deployment / declared scope", oEsp.IsDeployment() and oEsp.IsDeclared() and NOT oEsp.IsLive())
chk("it CAN drive gpio (the dev box cannot)", oEsp.Can(:gpio) and oDev.Lacks(:gpio))
chk("it LACKS process spawn (an MCU has no processes)", oEsp.Lacks(:process))
chk("it is 32-bit as declared", oEsp.Is32Bit())

? ""
? "-- Scene 5: the TWO WORLDS -- down-constrain and up-enable (section 2.4) --"
aForbids = oDev.Forbids(oEsp)   # dev has, target lacks
aRequires = oDev.Requires(oEsp) # target has, dev lacks
chk("DOWN-CONSTRAIN: process is something the dev box can do but the target forbids",
	has(aForbids, "process"))
chk("...filesystem too", has(aForbids, "filesystem"))
chk("UP-ENABLE: gpio is required by the target but the dev box lacks it", has(aRequires, "gpio"))
chk("...and gpio is the ONLY thing the dev box lacks here", len(aRequires) = 1)
aCmp = oDev.CompareTo(oEsp)
chk("CompareTo() returns both worlds in one call",
	len(aCmp) = 2 and aCmp[1][1] = "forbids" and aCmp[2][1] = "requires")

? ""
? "-- Scene 6: the system <-> agent bridge (one lattice) --"
# An actor's authority is a set of abstract kinds. Which system capabilities may
# it exercise? Exactly those whose kind is in its set.
aLLM = [ "inference" ]                          # an LLM actor's kinds
aPI  = [ "effectful", "compute", "sensing" ]    # a full PI actor's kinds
aGuardian = [ "compute", "sensing" ]            # a guardian: no effect
chk("an LLM actor may exercise NO ESP32 capability -- the empty effect set",
	len(oEsp.CapabilitiesForActorKinds(aLLM)) = 0)
chk("a PI actor may exercise ALL of them (gpio/network/clock/threads)",
	len(oEsp.CapabilitiesForActorKinds(aPI)) = 4)
aGCaps = oEsp.CapabilitiesForActorKinds(aGuardian)
chk("a guardian may exercise clock+threads (sensing+compute) but NOT gpio (effectful)",
	len(aGCaps) = 2 and NOT has(aGCaps, "gpio"))

? ""
? "-- Scene 7: the capability envelope is a CLOSED named set (M2) --"
oCaps = new stzSystemCapabilities([ :filesystem, :clock ])
chk("Can() reports a granted capability", oCaps.Can(:filesystem))
chk("Lacks() reports an absent one", oCaps.Lacks(:gpio))
chk("filesystem is classified effectful", oCaps.KindOf(:filesystem) = "effectful")
chk("clock is classified sensing", oCaps.KindOf(:clock) = "sensing")
chk("threads is classified compute", oCaps.KindOf(:threads) = "compute")
bRaised = FALSE
try
	oCaps.Grant("teleport")
catch
	bRaised = TRUE
done
chk("granting an UNKNOWN capability is refused (closed set)", bRaised)
oCaps.Grant(:network)
chk("granting a known capability grows the set", oCaps.NumberOfCapabilities() = 3)
oCaps.Revoke(:network)
chk("revoke removes it", oCaps.Lacks(:network) and oCaps.NumberOfCapabilities() = 2)

? ""
? "-- Scene 8: the .stzsystem format round-trips (string) --"
cText = oEsp.ToStzSystem()
chk("the serialized text names the target", StzFindFirst("esp32-firmware", cText) > 0)
oBack = SystemProfileFromString(cText)
chk("os survives the round trip", oBack.OSName() = "rtos")
chk("arch survives", oBack.Architecture() = "arm")
chk("bit size survives (parsed as a number)", oBack.BitSize() = 32)
chk("name survives", oBack.Name() = "esp32-firmware")
chk("role survives as deployment", oBack.Role() = "deployment")
chk("capabilities survive -- gpio present, process absent", oBack.Can(:gpio) and oBack.Lacks(:process))
chk("the capability count matches the original", oBack.CapabilitiesQ().NumberOfCapabilities() = oEsp.CapabilitiesQ().NumberOfCapabilities())

? ""
? "-- Scene 9: a declared profile with NO capabilities line defaults by class --"
cMobileText = "name: my-android-app" + char(10) + "os: android" + char(10) + "arch: arm64" + char(10) + "bits: 64"
oMob = SystemProfileFromString(cMobileText)
chk("an android profile is the mobile class", oMob.IsMobile())
chk("...and gets sensible mobile default capabilities (network, no gpio)",
	oMob.Can(:network) and oMob.Lacks(:gpio))
chk("...and it still says android, not windows", oMob.OSName() = "android")

? ""
? "-- Scene 10: Save() to a .stzsystem file and ReadSystemProfile() back --"
cPath = "_tmp_scope_esp32.stzsystem"
oEsp.Save(cPath)
oFile = ReadSystemProfile(cPath)
chk("the file round-trips the os", oFile.OSName() = "rtos")
chk("...and the gpio capability", oFile.Can(:gpio))
chk("...and the arch", oFile.Architecture() = "arm")
remove(cPath)

? ""
? "-- Scene 11: rapid live reads stay cheap and stable --"
t0 = clock()
nOk = 0
for i = 1 to 2000
	oQ = DevelopmentSystem()
	if oQ.BitSize() = oDev.BitSize() and oQ.CpuCount() = oDev.CpuCount()
		nOk++
	ok
next
tRead = (clock() - t0) / clockspersecond()
? "  2000 DevelopmentSystem() reads in " + tRead + " s"
chk("2000 live scope reads stay fast (< 5s)", tRead < 5)
chk("...and every read agreed with the first", nOk = 2000)

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

func has aList, cItem
	nLen = len(aList)
	for i = 1 to nLen
		if aList[i] = cItem
			return TRUE
		ok
	next
	return FALSE
