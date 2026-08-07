# The GPU capability gate in the deployment plane -- G5 of the GPU plane
# (SOFTANZA_GPU_PLAN.md: "a deployment declares gpu-required / gpu-optional;
# Deploy() refuses or degrades accordingly -- the service-virtualization
# precedent").
#
# A part's stzResourceSpec now carries its GPU need (SetGpuRequired /
# SetGpuOptional); a site's capacity carries GPU presence (SetGpuPresent),
# and a LOCAL site answers for itself by PROBING the real device. The
# provision step enforces it:
#   required + gpu-less site -> the step FAILS, the deploy REFUSES
#   optional + gpu-less site -> the deploy proceeds, the degrade is LOGGED
#   (and at runtime the part's seams fall back to CPU and COUNT it)
#
# Both directions asserted, plus the spec-level mechanics (Meets, Plus,
# and the strongest-need merge).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the resource spec speaks gpu, both roles --"
oReq = new stzResourceSpec()
oReq.SetGpuRequiredQ()
oCapNo = new stzResourceSpec()
oCapYes = new stzResourceSpec()
oCapYes.SetGpuPresentQ(TRUE)
chk("a gpu-less capacity does NOT meet a gpu-required ask", NOT oCapNo.Meets(oReq))
chk("a gpu-bearing capacity DOES", oCapYes.Meets(oReq))
oOpt = new stzResourceSpec()
oOpt.SetGpuOptionalQ()
chk("optional need does not block a gpu-less capacity", oCapNo.Meets(oOpt))
oSum = oOpt.Plus(oReq)
chk("merging needs keeps the STRONGEST (optional + required = required)",
    oSum.GpuNeed() = "required")
chk("a gpu-only requirement is not 'empty'", NOT oReq.IsEmpty())
chk("the footprint text says it: " + oReq.Text(), StzFindFirst("gpu required", oReq.Text()) > 0)

? ""
? "-- Scene 2: REQUIRED + a gpu-less site: the deploy REFUSES --"
oBrain = new stzDelivery("gpuplane")
oBrain.AddBackend(:viz, :LinuxServer)
oReqViz = new stzResourceSpec()
oReqViz.SetGpuRequiredQ()
oBrain.RequiresIn(:viz, oReqViz)

# a remote site that never declared a GPU: honestly treated as having none
oSiteNoGpu = new stzDeploymentSite("cpu-farm")
oSiteNoGpu.SetKindQ(:Server)
oSiteNoGpu.SetEndpointQ("deploy@cpu-farm.example:/srv/viz")

oDep = new stzDeployment(oBrain)
oDep.SetActor(HumanActor("ops"))
oDep.SetTarget(:viz, oSiteNoGpu)
aRun = oDep.Run()
chk("the deploy did NOT commit", aRun[1] = 0)
aRecs = aRun[2]
chk("the part's FIRST step failed at the admission gate", aRecs[1][2] = "FAILED")
bSkipped = TRUE
for i = 2 to len(aRecs)
    if aRecs[i][2] != "skipped"
        bSkipped = FALSE
    ok
next
chk("every later step was skipped -- nothing shipped to a site that can't run it", bSkipped)
chk("the refusal is IN THE LOG, by name",
    StzFindFirst("REQUIRES a gpu", oDep.Log().AsJson()) > 0)
chk("and it was THE GATE, not a coincidental step failure",
    StzFindFirst("gpu admission gate refused", oDep.Log().AsJson()) > 0)

? ""
? "-- Scene 3: OPTIONAL + the same gpu-less site: deploy proceeds, DEGRADED --"
oBrain2 = new stzDelivery("gpuplane2")
oBrain2.AddBackend(:report, :LinuxServer)
oReqRep = new stzResourceSpec()
oReqRep.SetGpuOptionalQ()
oBrain2.RequiresIn(:report, oReqRep)
oDep2 = new stzDeployment(oBrain2)
oDep2.SetActor(HumanActor("ops"))
oDep2.SetTarget(:report, oSiteNoGpu)
aRun2 = oDep2.Run()
chk("the gate ADMITTED the optional part (no gate refusal in the log)",
    StzFindFirst("gpu admission gate refused", oDep2.Log().AsJson()) = 0)
chk("and the degrade is in the log, by name",
    StzFindFirst("DEGRADED", oDep2.Log().AsJson()) > 0)

? ""
? "-- Scene 4: a LOCAL site answers for itself -- the live probe --"
oBrain3 = new stzDelivery("gpuplane3")
oBrain3.AddBackend(:viz, :LinuxServer)
oReqViz3 = new stzResourceSpec()
oReqViz3.SetGpuRequiredQ()
oBrain3.RequiresIn(:viz, oReqViz3)
oSiteLocal = new stzDeploymentSite("this-machine")
oSiteLocal.SetKindQ(:LocalRepo)
oSiteLocal.SetStoreAtQ(WorkingDirectory() + "/_gate_scratch")
oDep3 = new stzDeployment(oBrain3)
oDep3.SetActor(HumanActor("ops"))
oDep3.SetTarget(:viz, oSiteLocal)
aRun3 = oDep3.Run()
if StzEngineGpuIsAvailable() = 1
    chk("this machine HAS a gpu: the probe admits the required part",
        StzFindFirst("gpu present", oDep3.Log().AsJson()) > 0)
    chk("no gate refusal",
        StzFindFirst("gpu admission gate refused", oDep3.Log().AsJson()) = 0)
else
    chk("no gpu here: the required part is refused even locally",
        StzFindFirst("gpu admission gate refused", oDep3.Log().AsJson()) > 0)
    chk("and named", StzFindFirst("REQUIRES a gpu", oDep3.Log().AsJson()) > 0)
ok
StzDirDeleteAll(WorkingDirectory() + "/_gate_scratch")

? ""
? "-- Scene 5: a DECLARED gpu on a remote satisfies required (no probe possible) --"
oSiteDecl = new stzDeploymentSite("gpu-farm")
oSiteDecl.SetKindQ(:Server)
oSiteDecl.SetEndpointQ("deploy@gpu-farm.example:/srv/viz")
oCapFarm = new stzResourceSpec()
oCapFarm.SetGpuPresentQ(TRUE)
oSiteDecl.SetCapacityQ(oCapFarm)
oBrain4 = new stzDelivery("gpuplane4")
oBrain4.AddBackend(:viz, :LinuxServer)
oReqViz4 = new stzResourceSpec()
oReqViz4.SetGpuRequiredQ()
oBrain4.RequiresIn(:viz, oReqViz4)
oDep4 = new stzDeployment(oBrain4)
oDep4.SetActor(HumanActor("ops"))
oDep4.SetTarget(:viz, oSiteDecl)
aRun4 = oDep4.Run()
chk("declared capacity carries the gate (admitted, 'gpu present' logged)",
    StzFindFirst("gpu present", oDep4.Log().AsJson()) > 0 and
    StzFindFirst("gpu admission gate refused", oDep4.Log().AsJson()) = 0)

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
