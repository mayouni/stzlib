# Narrative
# ---------
# THE RELEASE AND THE FETCH (MP3b of SOFTANZA_MODEL_PLACEMENT.md, 2026-11-05). Softanza publishes the model files it CONVERTED, so a
# developer on any machine gets the measured bytes without a conversion toolchain. Four things make that safe, and this guard checks each:
#   1. a graph model is parsed only once its sha256 is the recorded one (SHA256SUMS beside it, generated from the catalogue);
#   2. the publish gate: only converted files, under a permissive licence, with the licence's text, are published;
#   3. the stager writes exactly the catalogued bytes, a model card, the licence, a notice, SHA256SUMS, a manifest -- and an upload script
#      the AUTHOR runs with their own account (this guard uploads nothing);
#   4. the fetch streams to disk and keeps a file only with the catalogue's sha256 and size; anything else leaves nothing at the path.
# Every network exchange here is with the engine's own loopback server: offline and deterministic.
#
#   cd libraries/stzlib/base/test/faculty ; rnxc release_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

cRes = StzReplace(WorkingDirectory(), "\", "/") + "/results"
nPort = StzEngineTestServerStart(0)      # the engine's loopback server, once for the process
cBase = "http://127.0.0.1:" + nPort
if NOT StzDirExists(cRes) StzDirCreatePath(cRes) ok

Scenario("SHA256SUMS beside the models is the catalogue's, line for line")
	aD = StzModelSumsDirs()
	Then("the catalogue names the vision and ocr directories", @@(aD), @@([ "vision", "ocr" ]))
	aWrong = []
	for i = 1 to len(aD)
		cF = StzModelsDir() + "/" + aD[i] + "/SHA256SUMS"
		if NOT fexists(cF)
			aWrong + (cF + " is missing")
		but StzReplace(read(cF), char(13), "") != StzModelSumsText(aD[i])
			aWrong + (cF + " differs from StzModelSumsText('" + aD[i] + "')")
		ok
	next
	Then("each SHA256SUMS is exactly what the catalogue generates: " + @@(aWrong), len(aWrong), 0)
	Then("...one line per catalogued file under the directory", len(str2list(StzModelSumsText("ocr"))), 5)
EndScenario()

Scenario("A graph model is parsed only once its sha256 is the recorded one")
	cDir = cRes + "/digest_probe"
	if NOT StzDirExists(cDir) StzDirCreatePath(cDir) ok
	cM = cDir + "/ppocr_cls.gguf"
	StzEngineFileCopy(StzModelsDir() + "/ocr/ppocr_cls.gguf", cM)
	if fexists(cDir + "/SHA256SUMS") StzEngineFileDelete(cDir + "/SHA256SUMS") ok
	Then("the shipped model loads: its line is in models/ocr/SHA256SUMS", len(StzEngineNeuralOcrGraphInfo(StzModelsDir() + "/ocr/ppocr_cls.gguf")) > 0, TRUE)
	Then("the SAME bytes with no recorded digest beside them are refused before parsing", len(StzEngineNeuralOcrGraphInfo(cM)), 0)
	Then("...and the refusal says why", StzFindFirst("no recorded sha256", StzEngineNeuralOcrGraphError()) > 0, TRUE)
	write(cDir + "/SHA256SUMS", copy("0", 64) + "  ppocr_cls.gguf" + char(10))
	Then("a recorded digest the bytes do not have is refused", len(StzEngineNeuralOcrGraphInfo(cM)) = 0 and StzFindFirst("not the recorded file", StzEngineNeuralOcrGraphError()) > 0, TRUE)
	write(cDir + "/SHA256SUMS", StzModelSumsText("ocr"))
	aI = StzEngineNeuralOcrGraphInfo(cM)
	Then("with the catalogue's line, the copy loads, and is the orientation classifier it claims to be", len(aI) > 0 and aI[1] = "cls", TRUE)
EndScenario()

Scenario("The publish gate: converted files with a permissive licence and its text, nothing else")
	aF = StzModelCatalog()[:files]
	nPass = 0
	nDownload = 0
	nDerive = 0
	aOther = []
	for i = 1 to len(aF)
		g = StzModelPublishGate(aF[i][:path])
		if g[1] = 1
			nPass++
		but aF[i][:how] = "download" and StzFindFirst("never republishes", g[2]) > 0
			nDownload++
		but aF[i][:how] = "derive" and StzFindFirst("remade, not published", g[2]) > 0
			nDerive++
		else
			aOther + g[2]
		ok
	next
	? "   gate: " + nPass + " publishable, " + nDownload + " linked to their upstream, " + nDerive + " derived"
	Then("every converted file passes: 17", nPass, 17)
	Then("every downloaded file is linked, never republished: 9 (the 9th is the optional pack's Bolt GGUF, MP2)", nDownload, 9)
	Then("the derived file (the refused shift patch) is not published", nDerive, 1)
	Then("no file is refused for any other reason: " + @@(aOther), len(aOther), 0)
	nInRepos = 0
	aR = StzModelRepos()
	for i = 1 to len(aR)  nInRepos += len(aR[i][:paths])  next
	Then("the repository rows hold exactly the 17, in 9 repositories", nInRepos = 17 and len(aR) = 9, TRUE)

	cCat = cRes + "/release_demo.zcat"
	write(cCat, read(StzModelCatalogFile()) + char(10) +
		"file|vision/__nc__.gguf|10|" + copy("ab", 32) + "|CC-BY-NC-4.0|convert|https://example.org/nc.onnx|10||python engine/tools/onnx_to_gguf.py nc.onnx vision/__nc__.gguf" + char(10) +
		"file|vision/__nolicencetext__.gguf|10|" + copy("cd", 32) + "|MIT|convert|https://example.org/x.onnx|10||python engine/tools/onnx_to_gguf.py x.onnx vision/__nolicencetext__.gguf" + char(10) +
		"repo|softanza/__demo__|vision/__nolicencetext__.gguf|licences/__absent__.txt|https://example.org|demo" + char(10))
	$cStzCatalogPath = cCat
	StzModelCatalogReload()
	Then("a non-commercial licence is refused, naming the permissive list", StzFindFirst("not on the permissive list", StzModelPublishGate("vision/__nc__.gguf")[2]) > 0, TRUE)
	Then("a licence whose TEXT is not here is refused: a release carries the text, not the name", StzFindFirst("not its name", StzModelPublishGate("vision/__nolicencetext__.gguf")[2]) > 0, TRUE)
	$cStzCatalogPath = ""
	StzModelCatalogReload()
EndScenario()

Scenario("Staging a release: the catalogued bytes, a card, the licence, a notice, sums, a manifest, and the author's upload script")
	cOut = cRes + "/release_stage"
	aS = StzModelReleaseStage("v0-guard", cOut, [ "softanza/ppocr-stzgraph" ])
	Then("one repository asked, one staged", len(aS) = 1 and aS[1][:staged] = 1, TRUE)
	? "   " + aS[1][:repo] + ": " + aS[1][:reason]
	cD = aS[1][:dir]
	aWant = [ "README.md", "LICENSE", "NOTICE", "SHA256SUMS", "softanza.zcat", "ppocr_det.gguf", "ppocr_rec.gguf", "ppocr_cls.gguf", "ppocr_rec_arabic.gguf", "ppocr_rec_cyrillic.gguf" ]
	aMissing = []
	for i = 1 to len(aWant)  if NOT fexists(cD + "/" + aWant[i]) aMissing + aWant[i] ok  next
	Then("the folder holds the five models and the five documents: " + @@(aMissing), len(aMissing), 0)
	nBad = 0
	for i = 6 to len(aWant)
		if lower(StzModelDigest(cD + "/" + aWant[i])) != lower(StzModelCatalogEntry("ocr/" + aWant[i])[:sha256]) nBad++ ok
	next
	Then("every staged model is the catalogued bytes (sha256 of the copy)", nBad, 0)
	Then("its SHA256SUMS is the catalogue's lines for these files", StzReplace(read(cD + "/SHA256SUMS"), char(13), ""), StzModelSumsText("ocr"))
	Then("a staged model loads in the engine on its own folder's SHA256SUMS", len(StzEngineNeuralOcrGraphInfo(cD + "/ppocr_det.gguf")) > 0, TRUE)
	Then("LICENSE is the licence's full text", StzFindFirst("Version 2.0, January 2004", read(cD + "/LICENSE")) > 0 and len(read(cD + "/LICENSE")) > 9000, TRUE)
	cCard = read(cD + "/README.md")
	cHead = "---" + char(10) + "license: apache-2.0" + char(10) + "library_name: softanza" + char(10)
	Then("the card opens with the hub's metadata: licence, library, tags", left(cCard, len(cHead)), cHead)
	Then("...says these are not llama.cpp models", StzFindFirst("not llama.cpp models", cCard) > 0, TRUE)
	Then("...gives each file's sha256 and steps", StzFindFirst(StzModelCatalogEntry("ocr/ppocr_rec_arabic.gguf")[:sha256], cCard) > 0 and StzFindFirst("--kind=rec", cCard) > 0, TRUE)
	Then("...says what Softanza measured, with the court's word", StzFindFirst("faculty `:ocr`, implementation `ppocr`", cCard) > 0 and StzFindFirst("items;", cCard) > 0, TRUE)
	Then("...and the limits of that measurement", StzFindFirst("do not say what it will do on your data", cCard) > 0, TRUE)
	Then("the notice names the upstream and the change", StzFindFirst("modelscope.cn/models/RapidAI/RapidOCR", read(cD + "/NOTICE")) > 0 and StzFindFirst("Nothing was trained", read(cD + "/NOTICE")) > 0, TRUE)
	$cStzCatalogPath = cD + "/softanza.zcat"
	StzModelCatalogReload()
	aM = StzModelCatalog()
	Then("the manifest is a catalogue Softanza reads: 5 files, their requires rows, 1 repository, 1 staged release",
	     len(aM[:files]) = 5 and len(aM[:requires]) >= 3 and len(aM[:repos]) = 1 and aM[:releases][1][:state] = "staged", TRUE)
	$cStzCatalogPath = ""
	StzModelCatalogReload()
	cUp = read(cOut + "/upload.ps1")
	Then("upload.ps1 creates, uploads and tags this repository, as the author", StzFindFirst("Run @('repos', 'create', 'softanza/ppocr-stzgraph', '--exist-ok')", cUp) > 0 and
	     StzFindFirst("Run @('upload', 'softanza/ppocr-stzgraph', '" + cD + "', '.'", cUp) > 0 and StzFindFirst("Run @('repos', 'tag', 'create', 'softanza/ppocr-stzgraph', 'v0-guard'", cUp) > 0, TRUE)
	Then("...and nothing else", StzFindFirst("yolox", cUp), 0)

	cCat = cRes + "/release_wrongbytes.zcat"
	write(cCat, StzReplace(read(StzModelCatalogFile()), StzModelCatalogEntry("ocr/ppocr_cls.gguf")[:sha256], copy("0", 64)))
	$cStzCatalogPath = cCat
	StzModelCatalogReload()
	aS2 = StzModelReleaseStage("v0-guard", cRes + "/release_refused", [ "softanza/ppocr-stzgraph" ])
	Then("a repository whose file is not the catalogued bytes is NOT staged, and says so", aS2[1][:staged] = 0 and StzFindFirst("only the catalogued bytes", aS2[1][:reason]) > 0, TRUE)
	Then("...and its upload script uploads nothing", StzFindFirst("Run @('upload'", read(cRes + "/release_refused/upload.ps1")), 0)
	$cStzCatalogPath = ""
	StzModelCatalogReload()
EndScenario()

Scenario("The download: streamed to disk, kept only with the recorded sha256 and size")
	N = 5000000
	cRef = cRes + "/fetch_ref.bin"
	write(cRef, copy("x", N))
	cSha = lower(StzModelDigest(cRef))
	cOut = cRes + "/fetch_out.bin"
	if fexists(cOut) StzEngineFileDelete(cOut) ok
	Then("five megabytes -- past the 4 MB body buffer of a plain GET -- arrive and are kept", StzEngineHttpDownloadVerified(cBase + "/big/" + N, cOut, cSha, N, ""), 1)
	Then("...they are the bytes: the kept file has the recorded sha256", lower(StzModelDigest(cOut)) = cSha and StzEngineHttpDownloadSha256() = cSha, TRUE)
	Then("...and no partial file is left beside it", fexists(cOut + ".part"), FALSE)
	StzEngineFileDelete(cOut)
	Then("a body whose sha256 is not the recorded one is REFUSED", StzEngineHttpDownloadVerified(cBase + "/big/" + N, cOut, copy("0", 64), N, ""), -3)
	Then("...and nothing is left at the path, not even the partial", fexists(cOut) = 0 and fexists(cOut + ".part") = 0, TRUE)
	Then("...and the reason names the digest it had", StzFindFirst(cSha, StzEngineHttpLastError()) > 0, TRUE)
	Then("a body longer than the recorded size is cut off and refused", StzEngineHttpDownloadVerified(cBase + "/big/" + N, cOut, cSha, N - 1, ""), -4)
	Then("...nothing left", fexists(cOut) = 0 and fexists(cOut + ".part") = 0, TRUE)
	Then("an HTTP error is refused", StzEngineHttpDownloadVerified(cBase + "/status/404", cOut, cSha, 0, ""), -2)
	Then("no recorded sha256 is a refusal before any byte moves", StzEngineHttpDownloadVerified(cBase + "/big/10", cOut, "", 0, ""), -6)
	write(cRef, "redirected")
	Then("a redirect (a hub answers with one to its CDN) is followed to the file", StzEngineHttpDownloadVerified(cBase + "/redirect/3", cOut, StzModelDigest(cRef), 10, ""), 1)
	StzEngineFileDelete(cOut)
	StzEngineFileDelete(cRef)
EndScenario()

Scenario("The fetch of a catalogued file, and where a published release is read from")
	N = 1000000
	cRef = cRes + "/fetch_ref.bin"
	write(cRef, copy("x", N))
	cSha = lower(StzModelDigest(cRef))
	StzEngineFileDelete(cRef)
	cCat = cRes + "/release_fetch.zcat"
	write(cCat, read(StzModelCatalogFile()) + char(10) +
		"file|vision/__fetch__.bin|" + N + "|" + cSha + "|MIT|download|" + cBase + "/big/" + N + "|" + N + "|" + cSha + "|download, save as vision/__fetch__.bin" + char(10))
	$cStzCatalogPath = cCat
	StzModelCatalogReload()
	cDir = cRes + "/fetch_models"
	if fexists(cDir + "/vision/__fetch__.bin") StzEngineFileDelete(cDir + "/vision/__fetch__.bin") ok
	a = StzModelFetchFileTo("vision/__fetch__.bin", cDir)
	? "   " + a[:reason]
	Then("a downloaded file is fetched from its upstream and kept", a[:ok] = 1 and lower(StzModelDigest(cDir + "/vision/__fetch__.bin")) = cSha, TRUE)
	Then("asked again, it is already here and intact: nothing moves", StzFindFirst("already here", StzModelFetchFileTo("vision/__fetch__.bin", cDir)[:reason]) > 0, TRUE)
	a = StzModelFetchFileTo("ocr/ppocr_det.gguf", cDir)
	Then("a converted file no release has published is not fetched: the answer is its steps", a[:ok] = 0 and StzFindFirst("make it with its steps", a[:reason]) > 0, TRUE)
	Then("...so its fetch source is empty", StzModelFetchSource("ocr/ppocr_det.gguf"), "")
	StzModelReleaseMark("softanza/ppocr-stzgraph", "v1", "staged", "")
	Then("a STAGED release is not a source either", StzModelFetchSource("ocr/ppocr_det.gguf"), "")
	StzModelReleaseMark("softanza/ppocr-stzgraph", "v1", "published", "0123abcd")
	Then("a PUBLISHED release is: the hub revision the upload made, never a moving branch",
	     StzModelFetchSource("ocr/ppocr_det.gguf"), "https://huggingface.co/softanza/ppocr-stzgraph/resolve/0123abcd/ppocr_det.gguf")
	bRaised = 0
	try StzModelReleaseMark("softanza/ppocr-stzgraph", "v2", "published", "") catch bRaised = 1 done
	Then("a release marked published without its revision is refused", bRaised, 1)
	Then("the mark went to the catalogue being read, not to the shipped one", StzFindFirst("0123abcd", read(cCat)) > 0 and StzFindFirst("0123abcd", read(StzModelsDir() + "/catalog.zcat")) = 0, TRUE)
	$cStzCatalogPath = ""
	StzModelCatalogReload()
	Then("with the shipped catalogue, no release is published yet: every converted file's source is empty", StzModelFetchSource("ocr/ppocr_det.gguf"), "")
EndScenario()

Summary()
shutdown($_zst_fail)
