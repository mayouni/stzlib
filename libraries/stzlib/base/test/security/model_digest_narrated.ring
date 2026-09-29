load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-MODEL-DIGEST-01 -- a GGUF file is parsed only once its SHA-256
# is KNOWN.
#
# neural_model_load and stz_gguf_inspect handed any file straight to
# ggml's GGUF parser: a swapped, altered or hostile file was read as if it
# were the model the program was written for. The engine now hashes the
# file first and compares it with a RECORDED digest -- pinned in this
# process, or listed in a SHA256SUMS file beside the model. A mismatch is
# refused (-2); no recorded digest is refused too (-3). StzTrustModel is
# the explicit act that records one.
#
# The fixture is the committed tiny_bert.gguf (83 KB, synthetic), whose
# digest is recorded in base/test/neural/SHA256SUMS.

$cGood = "../neural/tiny_bert.gguf"
$cDir = "_tmp_models"
if NOT direxists($cDir)  StzEngineDirCreate($cDir)  ok
$cBytes = read($cGood)

# an ALTERED copy: one byte of the last tensor flipped, and a SHA256SUMS
# beside it naming the ORIGINAL file's digest under the copy's name
$cAltered = $cDir + "/altered.gguf"
nLast = len($cBytes)
cFlip = char(255 - ascii($cBytes[nLast]))
write($cAltered, left($cBytes, nLast - 1) + cFlip)
cGoodHex = "4b05f810bd22ac6720d32dc92283da64afc96aadcdaf8cc8cd6eb9d6046f892e"
write($cDir + "/SHA256SUMS", cGoodHex + "  altered.gguf" + char(10))

# an UNKNOWN copy: byte-identical to the good model, in a folder that
# records nothing for it
$cUnknownDir = $cDir + "/unrecorded"
if NOT direxists($cUnknownDir)  StzEngineDirCreate($cUnknownDir)  ok
$cUnknown = $cUnknownDir + "/stranger.gguf"
write($cUnknown, $cBytes)

# =====================================================================
#  REFUSALS (the first three run against the old engine too)
# =====================================================================

Scenario("a model whose digest is recorded loads (positive sibling)")
	When("tiny_bert.gguf is loaded -- SHA256SUMS beside it lists its digest")
	Then("it loads", StzEngineNeuralModelLoad($cGood), 1)
	StzEngineNeuralModelFree()
EndScenario()

Scenario("an ALTERED model is refused")
	Given("a copy with one byte changed, and a SHA256SUMS naming the original digest")
	When("it is loaded")
	# before: ggml parsed it and it loaded -- nothing looked at the bytes
	Then("it is refused", StzEngineNeuralModelLoad($cAltered), 0)
	StzEngineNeuralModelFree()
	Then("inspection is refused too (the header parser is the same attack surface)",
		StzEngineNeuralGgufInspect($cAltered) < 0, 1)
EndScenario()

Scenario("a model with NO recorded digest is refused")
	Given("a byte-identical copy in a folder with no SHA256SUMS")
	When("it is loaded")
	# before: loaded; being identical to a good model is not the point --
	# nobody SAID this file is that model
	Then("it is refused", StzEngineNeuralModelLoad($cUnknown), 0)
	StzEngineNeuralModelFree()
EndScenario()

# =====================================================================
#  THE REASONS, AND THE EXPLICIT ACT OF TRUST
# =====================================================================

Scenario("the refusal says why")
	StzEngineNeuralModelLoad($cAltered)
	Then("an altered file: digest mismatch (-2)", StzModelLoadStatus(), -2)
	StzEngineNeuralModelLoad($cUnknown)
	Then("an unrecorded file: no digest recorded (-3)", StzModelLoadStatus(), -3)
	StzEngineNeuralModelLoad($cDir + "/does_not_exist.gguf")
	Then("a missing file: unreadable (-1)", StzModelLoadStatus(), -1)
	StzEngineNeuralModelLoad($cGood)
	Then("a good file: 0", StzModelLoadStatus(), 0)
	StzEngineNeuralModelFree()
	Then("StzModelDigest reads the recorded one back", StzModelDigest($cGood), cGoodHex)
EndScenario()

Scenario("StzTrustModel records the digest, and then the model loads")
	When("the unrecorded copy is trusted")
	cHex = StzTrustModel($cUnknown)
	Then("the digest returned is the file's", cHex, cGoodHex)
	Then("a SHA256SUMS now stands beside it", fexists($cUnknownDir + "/SHA256SUMS"), 1)
	Then("it now loads", StzEngineNeuralModelLoad($cUnknown), 1)
	StzEngineNeuralModelFree()
	When("it is trusted a second time")
	StzTrustModel($cUnknown)
	Then("the manifest still holds ONE line for it",
		len(StzFindCS("stranger.gguf", read($cUnknownDir + "/SHA256SUMS"), 1)), 1)
EndScenario()

Scenario("a digest pinned in the process overrides the file beside it")
	When("a WRONG digest is pinned for the good model")
	StzExpectModelDigest($cGood, copy("0", 64))
	Then("the good model is refused as altered", StzEngineNeuralModelLoad($cGood), 0)
	Then("with status -2", StzModelLoadStatus(), -2)
	When("the right digest is pinned")
	StzExpectModelDigest($cGood, cGoodHex)
	Then("it loads again", StzEngineNeuralModelLoad($cGood), 1)
	StzEngineNeuralModelFree()
	Then("a pin that is not 64 hex characters is refused", StzExpectModelDigest($cGood, "abc"), 0)
EndScenario()

remove($cAltered)
remove($cUnknown)
remove($cDir + "/SHA256SUMS")
remove($cUnknownDir + "/SHA256SUMS")
StzEngineDirDelete($cUnknownDir)
StzEngineDirDelete($cDir)

Summary()
