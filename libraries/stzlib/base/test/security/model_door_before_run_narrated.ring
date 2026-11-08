load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-R18a, SECURITY-MODELDOOR-01, SECURITY-AMBIENT-01/02 (stzlib-security,
# 2026-11-05), closed by the intelligence plane 2026-11-08.
#
# A shut model door must refuse the RUN, not only withhold the answer: a crafted
# model file or a loader bug is reached by the run. So every refusal below is
# checked two ways -- the call raises naming the advisory, AND no model.call
# record was written, which is the record a run writes. Each refusal has a
# sibling that must still pass. And state set for one call must not survive a
# raise: a skill that fails leaves no agent name behind for the next caller.

StzCloseSecurityLedger()
StzOpenSecurityLedger(4096)
StzForgetShutDoors()
oResp = new stzExposureResponder()
cPng = "../ocr/_data/facts/facts_s1.png"

Scenario("1. the image door refuses before the model is read: no file is opened, no run, no record")
	# the face model is pointed at a file that is NOT installed: only a check made before the file is looked for can
	# name the advisory -- a door after the run would answer "not installed" (the control, 2026-11-08, on the old code)
	cKeepFace = $cStzVisionFaceModel
	$cStzVisionFaceModel = "never-installed-fixture.gguf"
	oResp.ShutModel("ADV-FACES-01", "never-installed-fixture.gguf", "a crafted face model")
	n0 = _ModelCalls()
	cMsg = ""
	try
		StzImageQ(cPng).Faces()
	catch
		cMsg = cCatchError
	done
	Then("Faces() is refused", cMsg != "", 1)
	Then("...naming the advisory, before the file is looked for", StzFindFirst("ADV-FACES-01", cMsg) > 0, 1)
	Then("...and the refusal is in the ledger with the advisory as origin", _Refused("ADV-FACES-01"), 1)
	Then("no model ran: no model.call record was written", _ModelCalls(), n0)
	oResp.Reopen("ADV-FACES-01")
	cMsg2 = ""
	try
		StzImageQ(cPng).Faces()
	catch
		cMsg2 = cCatchError
	done
	Then("SIBLING -- with the door open, the same call reaches the file and says it is not installed", StzFindFirst("not installed", cMsg2) > 0, 1)
	$cStzVisionFaceModel = cKeepFace
EndScenario()

Scenario("2. the neural load checks the model FILE's door before the reader opens it")
	oResp.ShutModel("ADV-GGUF-01", "crafted.gguf", "a crafted GGUF")
	cMsg = ""
	try
		oM = StzNeuralModelQ("D:/nowhere/models/Crafted.GGUF")
	catch
		cMsg = cCatchError
	done
	Then("the load of crafted.gguf is refused (the name is matched in lower case, without its folder)", StzFindFirst("ADV-GGUF-01", cMsg) > 0, 1)
	Then("StzModelFileName keeps the name only", StzModelFileName("D:\models\sub/Crafted.GGUF"), "crafted.gguf")
	cMsg2 = ""
	try
		oM2 = StzNeuralModelQ("D:/nowhere/models/other.gguf")
	catch
		cMsg2 = cCatchError
	done
	Then("SIBLING -- another file is not refused by the door", StzFindFirst("door to", cMsg2) = 0, 1)
	Then("...(it does not exist, so it simply does not load)", StzFindFirst("ADV-GGUF-01", cMsg2) = 0, 1)
	oResp.Reopen("ADV-GGUF-01")
EndScenario()

Scenario("3. the neural gate checks the slot's file before a run")
	cKeepFile = $cStzNeuralModelFile
	$cStzNeuralModelFile = "slot-fixture.gguf"
	oResp.ShutModel("ADV-SLOT-01", "slot-fixture.gguf", "the model in the slot")
	cMsg = ""
	try
		_StzNeuralGate()
	catch
		cMsg = cCatchError
	done
	Then("the gate refuses while the slot's file is shut", StzFindFirst("ADV-SLOT-01", cMsg) > 0, 1)
	oResp.Reopen("ADV-SLOT-01")
	cMsg2 = ""
	try
		_StzNeuralGate()
	catch
		cMsg2 = cCatchError
	done
	Then("SIBLING -- reopened, the gate passes", cMsg2, "")
	$cStzNeuralModelFile = cKeepFile
EndScenario()

Scenario("4. the OCR door: the GGUF recogniser is refused before it runs, and before its cache answers")
	oResp.ShutModel("ADV-OCR-01", "ppocr_rec.gguf", "the Latin recogniser")
	n0 = _ModelCalls()
	cMsg = ""
	try
		StzOcrModelLinesXT(cPng, "")
	catch
		cMsg = cCatchError
	done
	Then("StzOcrModelLinesXT is refused, naming the advisory", StzFindFirst("ADV-OCR-01", cMsg) > 0, 1)
	Then("no model ran", _ModelCalls(), n0)
	oResp.Reopen("ADV-OCR-01")
	if fexists(StzOcrModelDir() + "/ppocr_rec.gguf")
		$aStzOcrCache = []
		aL = StzOcrModelLinesXT(cPng, "")
		aC = StzSecurityLedgerQ().OfKind("model.call")
		Then("SIBLING -- reopened, the model reads the page", len(aL) > 0, 1)
		Then("...and its run is a model.call record, the recogniser as subject", aC[len(aC)][:subject], "ppocr_rec.gguf")
		oResp.ShutModel("ADV-OCR-02", "ppocr_rec.gguf", "shut after a read")
		cMsg3 = ""
		try
			StzOcrModelLinesXT(cPng, "")
		catch
			cMsg3 = cCatchError
		done
		Then("a page read BEFORE the shut is not answered from the cache after it", StzFindFirst("ADV-OCR-02", cMsg3) > 0, 1)
		oResp.Reopen("ADV-OCR-02")
	else
		? "  NOT RUN: the sibling read -- no " + StzOcrModelDir() + "/ppocr_rec.gguf on this machine"
	ok
EndScenario()

Scenario("5. the OCR door: the platform's model (Windows.Media.Ocr)")
	# any language pack the machine has: the door is the model's, not the language's
	cLang = ""
	if isWindows()
		acPk = StzOcrPlatformLanguages()
		if len(acPk) > 0  cLang = acPk[1]  ok
	ok
	if cLang != ""
		oResp.ShutModel("ADV-WINOCR-01", "windows.media.ocr", "the platform OCR")
		n0 = _ModelCalls()
		cMsg = ""
		try
			StzOcrPlatformLines(cPng, cLang)
		catch
			cMsg = cCatchError
		done
		Then("StzOcrPlatformLines is refused, naming the advisory", StzFindFirst("ADV-WINOCR-01", cMsg) > 0, 1)
		Then("no model ran", _ModelCalls(), n0)
		oResp.Reopen("ADV-WINOCR-01")
		$aStzOcrCache = []
		aL = StzOcrPlatformLines(cPng, cLang)
		aC = StzSecurityLedgerQ().OfKind("model.call")
		Then("SIBLING -- reopened, the platform reads the page", len(aL) > 0, 1)
		Then("...and its run is a model.call record", aC[len(aC)][:subject], "windows.media.ocr")
	else
		? "  NOT RUN: no Windows OCR language pack on this machine"
	ok
EndScenario()

Scenario("6. a skill that raises leaves no caller and no workbench behind (SECURITY-AMBIENT-01)")
	$cStzCaller = ""
	nWbBefore = $nStzActiveAgentWorkbench
	oAg = new stzPIAgent("agent-x")
	oSk = new stzAgentSkill("falls-over")
	oSk.SetWhen(func oM { return 1 })
	oSk.SetDoes(func oM { raise("the skill fell over") })
	oSk.SetVerifiedBy(func oM { return 1 })
	oAg.AddSkill(oSk)
	cMsg = ""
	try
		oAg.Cycle()
	catch
		cMsg = cCatchError
	done
	Then("the skill's error still reaches the caller of Cycle", StzFindFirst("the skill fell over", cMsg) > 0, 1)
	Then("...and $cStzCaller is empty again, not agent-x", $cStzCaller, "")
	Then("...and the ambient workbench is what it was", $nStzActiveAgentWorkbench, nWbBefore)
	n0 = _ModelCalls()
	_StzVisionDoor("classify", "fixture.gguf", "a record after the failed cycle")
	aC = StzSecurityLedgerQ().OfKind("model.call")
	Then("a later model call is filed under nobody, not under agent-x", StzFindFirst("agent-x", "" + aC[len(aC)][:origin]) = 0, 1)
	oOk = new stzPIAgent("agent-y")
	oS2 = new stzAgentSkill("stands")
	oS2.SetWhen(func oM { return 1 })
	oS2.SetDoes(func oM { return 1 })
	oS2.SetVerifiedBy(func oM { return 1 })
	oOk.AddSkill(oS2)
	Then("SIBLING -- a skill that does not raise still runs and verifies", oOk.Cycle(), 1)
	Then("...and leaves no caller behind either", $cStzCaller, "")
EndScenario()

Scenario("7. the rule that found AMBIENT-01/02 reads 0 on the five files the fix touched")
	acF = [ "../../agentic/stzPIAgent.ring", "../../faculty/stzModelsReport.ring", "../../image/stzVision.ring",
		"../../neural/stzNeuralModel.ring", "../../ocr/stzOcr.ring" ]
	nHits = 0
	for i = 1 to len(acF)
		aF = StzCheckCode(read(acF[i]))
		for j = 1 to len(aF)
			if aF[j][:rule] = :global_restored_by_hand
				nHits++
				? "  FOUND " + acF[i] + ":" + aF[j][:line]
			ok
		next
	next
	Then("no global is saved and restored by hand without a try", nHits, 0)
EndScenario()

StzForgetShutDoors()
Summary()
shutdown($_zst_fail)

func _ModelCalls()
	if NOT StzSecurityLedgerIsOpen()  return 0  ok
	return len(StzSecurityLedgerQ().OfKind("model.call"))

func _Refused(pcAdvisory)
	# the last capability.refused record, and whether it names the advisory
	_aR_ = StzSecurityLedgerQ().OfKind("capability.refused")
	if len(_aR_) = 0  return 0  ok
	return _aR_[len(_aR_)][:origin] = pcAdvisory
