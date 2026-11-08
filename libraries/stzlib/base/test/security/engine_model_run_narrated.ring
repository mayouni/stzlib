load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-R18b (stzlib-security, 2026-11-05), built by the intelligence plane 2026-11-08.
#
# The model doors are Ring functions, so a direct StzEngineNeural* call passed none of them and left no record.
# Now stz_neural writes its own record of every run -- kind model.run, actor stz_neural, subject the model file's
# name -- through stz_seclog's exported door, BEFORE the model's file is read. The Ring doors stay: they write
# model.call, who asked and through which faculty. So the governed path leaves one of each, and a direct call
# leaves a model.run with no model.call beside it: a run that went round the doors, visible as a number.
#
# Every scene reads the ledger, never a counter alone: a counter can count a record that was never written.

cPng = "../ocr/_data/facts/facts_s1.png"
cMini = StzModelsDir() + "/all-MiniLM-L6-v2.Q8_0.gguf"

StzCloseSecurityLedger()
StzForgetShutDoors()

Scenario("1. a direct engine call, with no ledger open and no Ring door, writes its own record")
	Then("no ledger is open before the call", StzSecurityLedgerIsOpen(), 0)
	StzEngineNeuralModelLoad(cMini)
	nDim = StzEngineNeuralEmbed("the engine records its own runs")
	Then("the model ran (MiniLM gives 384 numbers)", nDim, 384)
	Then("the engine opened the process ledger itself", StzSecurityLedgerIsOpen(), 1)
	aRun = _Kind("model.run")
	Then("one model.run record", len(aRun), 1)
	Then("...written by stz_neural", _Last("model.run")[:actor], "stz_neural")
	Then("...naming the model file, lowercase, without its folder", _Last("model.run")[:subject], "all-minilm-l6-v2.q8_0.gguf")
	Then("...and what ran on how much", _Last("model.run")[:reason], "embed: 31 bytes in")
	Then("no model.call: nothing governed was asked", len(_Kind("model.call")), 0)
EndScenario()

Scenario("2. the governed path leaves one of each: the ask and the run")
	oM = StzNeuralModelQ(cMini)
	nR0 = len(_Kind("model.run"))
	nC0 = len(_Kind("model.call"))
	aV = oM.EmbeddingOf("a governed ask")
	Then("the model answered", len(aV), 384)
	Then("one more model.call (the Ring door)", len(_Kind("model.call")), nC0 + 1)
	Then("one more model.run (the engine)", len(_Kind("model.run")), nR0 + 1)
	aC = _Kind("model.call")
	Then("...the call names the architecture", aC[len(aC)][:subject], "" + StzEngineNeuralModelArch())
	Then("...the run names the file", _Last("model.run")[:subject], "all-minilm-l6-v2.q8_0.gguf")
	Then("NUMBER -- runs that went round the doors in this process: the direct call of scene 1",
		len(_Kind("model.run")) - len(_Kind("model.call")), 1)
EndScenario()

Scenario("3. the record is written BEFORE the model file is read")
	# a file that does not exist: the run fails at its first byte, and the record is already there
	n0 = len(_Kind("model.run"))
	aOut = StzEngineNeuralVisionClassify("D:/nowhere/models/Crafted.GGUF", "abc", 1, 1, 3, 5, 1)
	Then("the run found no model", len(aOut), 0)
	Then("...and its record was written first", len(_Kind("model.run")), n0 + 1)
	Then("...naming the file it was asked to read", _Last("model.run")[:subject], "crafted.gguf")
	Then("...as a classify run", _Last("model.run")[:reason], "classify: 3 bytes in")
	StzEngineNeuralModelFree()
	n1 = len(_Kind("model.run"))
	StzEngineNeuralEmbed("no model in the slot")
	Then("a run with the slot empty is recorded too", len(_Kind("model.run")), n1 + 1)
	Then("...and says so", _Last("model.run")[:subject], "(no model loaded)")
EndScenario()

Scenario("4. the OCR models, called direct")
	if fexists(StzOcrModelDir() + "/ppocr_rec.gguf")
		n0 = len(_Kind("model.run"))
		aL = StzEngineNeuralOcrReadWith(StzOcrModelDir(), "", cPng, 2)
		Then("the recogniser read the page", len(aL) > 0, 1)
		Then("...and wrote one model.run", len(_Kind("model.run")), n0 + 1)
		Then("...naming the default recogniser", _Last("model.run")[:subject], "ppocr_rec.gguf")
	else
		? "  NOT RUN: the GGUF recogniser -- no " + StzOcrModelDir() + "/ppocr_rec.gguf on this machine"
	ok
	if isWindows() and len(StzOcrPlatformLanguages()) > 0
		n0 = len(_Kind("model.run"))
		aP = StzEngineNeuralOcrPlatformRead(cPng, StzOcrPlatformLanguages()[1], 40)
		Then("the platform's model read the page", len(aP) = 2, 1)
		Then("...and wrote one model.run", len(_Kind("model.run")), n0 + 1)
		Then("...naming windows.media.ocr", _Last("model.run")[:subject], "windows.media.ocr")
	else
		? "  NOT RUN: the platform OCR -- no Windows OCR language pack on this machine"
	ok
EndScenario()

Scenario("5. the engine's own count agrees with the ledger, and nothing was missed")
	aN = _RunRecords()
	Then("runs asked = model.run records in the ledger", aN[1], len(_Kind("model.run")))
	Then("records written = runs asked", aN[2], aN[1])
	Then("records missed: 0", aN[3], 0)
	Then("the ledger's chain is intact with both kinds in it", StzSecurityLedgerQ().Verify()[:intact], 1)
EndScenario()

Scenario("6. NEGATIVE -- what is not a run writes nothing")
	StzEngineNeuralModelLoad(cMini)
	n0 = len(_Kind("model.run"))
	StzEngineNeuralTokenize("only the tokenizer")
	StzEngineNeuralModelArch()
	StzEngineNeuralGgufInspect(cMini)
	Then("tokenizing, asking the architecture and inspecting the file write no model.run", len(_Kind("model.run")), n0)
	StzEngineNeuralModelFree()
EndScenario()

StzForgetShutDoors()
Summary()
shutdown($_zst_fail)

func _Kind(pcKind)
	if NOT StzSecurityLedgerIsOpen()  return []  ok
	return StzSecurityLedgerQ().OfKind(pcKind)

func _RunRecords()
	# an engine built before R18b has no such function: the control run reads -1 rather than stopping
	_a_ = [ -1, -1, -1 ]
	try
		_a_ = StzEngineNeuralRunRecords()
	catch
	done
	return _a_

func _Last(pcKind)
	_a_ = _Kind(pcKind)
	if len(_a_) = 0  return [ :subject = "", :reason = "", :actor = "" ]  ok
	return _a_[len(_a_)]
