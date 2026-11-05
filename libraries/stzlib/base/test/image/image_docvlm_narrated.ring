# A PAGE AS STRUCTURE -- IM7 (2 of 2), narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM7: Granite-Docling-258M on the house's own engine as :doc-vlm. Its picture tower
# is SmolVLM's (idefics3: SigLIP 512, pixel shuffle 4, 64 rows a view), so engine/src/vlm.zig carries it; what is new
# is the PAGE: Idefics3's tiling (the page resized to 2048 on its long side, cut into 512 x 512 tiles, one more view
# of the whole page), the decoder's entry that reads several pictures between texts (neural_gen.startWithSegments),
# the model's own tags (DocTags, stzDocTags.ring) read into the blocks the native PDF reader returns, the judging of
# both by the house's one document scorer, and the COMBINATION of the two readers (StzDocBlocksCombine).
#
#   Scene 1  DocTags -> blocks, and the combination: the parser and the rule, on text written for them (no model)
#   Scene 2  the scorer: StzDocBlocksScores against base/test/document/_doc_score.py, the independent scorer, on the
#            stored predictions of golden v1 (2 readers, 31 pages) and v2 (3 readers, 27 pages) (no model)
#   Scene 3  parity with Hugging Face's own Idefics3 code loaded with the same weights (_rig/granite_docling_reference.py):
#            the page's pixels, the prompt's tokens, the views' rows, the next-token logits, the words token by token
#   Scene 4  DocBlocks() on pages: the model's tags, the table as a grid, against the native reader on the same page;
#            and the loop stop, on the page of golden v1 that used to run to the cap
#   Scene 5  :doc-vlm judged on golden v2 (FRESH: no model had read a page when the combination's rule was written):
#            the native reader on a scan, Granite-Docling, and the two combined; v1's tie is read from the record
#
# THE TIME, because a gate says what it costs: scenes 1 and 2 are seconds; scene 3 is about 40 s a page (the views are
# made twice: once for the rows, once for the logits); scene 4 about 40 s a page, 60 s for the loop page and 5 s for the
# floor; scene 5 runs the FLOOR live on the 27 scans (3 min) and reads the stored predictions of the model (about 40
# minutes for the 27 pages: _rig/doc_vlm_run.ring makes them, results/doc_vlm_v2/ keeps them, and scene 5 says so).
#
# NEEDS what the tree does not carry: models/vision/granite_docling_258m*.gguf, the rendered pages
# (_rig/doc_vlm_render.py), the reference fixtures. When absent, a scene says which and is SKIPPED BY NAME.
# THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"
load "_court_rule.ring"
load "_golden/doc_vlm_v1.ring"
load "_golden/doc_vlm_v2.ring"
load "_rig/doc_vlm_tsv.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPages1 = $cSrc + "doc_vlm_v1/"
$cPages2 = $cSrc + "doc_vlm_v2/"
$cPar = $cSrc + "parity/granite/"
$cRes1 = "results/doc_vlm_v1/"
$cRes2 = "results/doc_vlm_v2/"

pr()
nl = char(10)
aSkipped = []
bModel = StzVisionHasModel($cStzVisionDocDecoder) and StzVisionHasModel($cStzVisionDocProjector)
bPages = fexists($cPages1 + "v2_e01.png") and fexists($cPages2 + "v2_e02.png")
aKeys = [ "v2_e01", "v4_g01", "v5_h03" ]
bPar = fexists($cPar + "v2_e01_ref.txt")

#=====================================================================#
? "-- Scene 1: DocTags -> blocks, and the combination --"
#=====================================================================#
# written for the parser, not captured: a heading and a title, a paragraph with a "<" in it and a line break, a list
# item, code, furniture, a picture whose words are not text, an empty block, and a table with every kind of cell

L = "<loc_1><loc_2><loc_3><loc_4>"
cDoc = "<doctag><title>" + L + "Annual Report</title>" +
	"<section_header_level_2>" + L + "Results</section_header_level_2>" +
	"<text>" + L + "Revenue grew   by 4 < 5 percent." + nl + "It held.</text>" +
	"<unordered_list><list_item>" + L + "first point</list_item></unordered_list>" +
	"<code>" + L + "x = 1</code><page_header>" + L + "ACME</page_header>" +
	"<picture>" + L + "<other>stray words</picture><text>" + L + "</text>" +
	"<footnote>" + L + "Note: <checkbox_selected> done</footnote></doctag>"
aB = StzDocTagsBlocks(cDoc)
chk("nine content tags give seven blocks (the empty text and the picture's words give none)", len(aB) = 7)
chk("a title is a heading of level 1, a section_header_level_2 a heading of level 2",
	aB[1][:kind] = "heading" and aB[1][:level] = 1 and aB[1][:text] = "Annual Report" and
	aB[2][:kind] = "heading" and aB[2][:level] = 2 and aB[2][:text] = "Results")
chk("a paragraph keeps its '<' (not a tag), collapses its spaces and its line break",
	aB[3][:kind] = "paragraph" and aB[3][:text] = "Revenue grew by 4 < 5 percent. It held.")
chk("a list item, a code block and a page header keep their kinds",
	aB[4][:kind] = "list_item" and aB[5][:kind] = "code" and aB[5][:text] = "x = 1" and aB[6][:kind] = "page_header")
chk("a footnote is a paragraph, and a tag the reader does not know is skipped, the words going on",
	aB[7][:kind] = "paragraph" and aB[7][:text] = "Note: done")

cTab = "<otsl>" + L + "<ched>Item<ched>Qty<ched>Price<nl>" +
	"<fcel>Bolt<fcel>10<fcel>1.50<nl>" +
	"<fcel>Total<lcel><ecel><nl>" +
	"<fcel>Group<lcel><fcel>7<nl>" +
	"<ucel><lcel><fcel>8<nl>" +
	"<caption>" + L + "Table 1. Parts</caption></otsl>"
aT = StzDocTagsBlocks(cTab)
chk("a table is one block, its caption (inside the otsl) a second block after it",
	len(aT) = 2 and aT[1][:kind] = "table" and aT[2][:kind] = "caption" and aT[2][:text] = "Table 1. Parts")
aR = aT[1][:rows]
chk("five rows of three cells", len(aR) = 5 and len(aR[1]) = 3 and len(aR[5]) = 3)
chk("a header cell and a plain cell are cells with their text", aR[1][2] = "Qty" and aR[2][3] = "1.50")
chk("an lcel repeats the cell to its left, an ecel is empty", aR[3][2] = "Total" and aR[3][3] = "")
chk("a ucel repeats the cell above it", aR[5][1] = "Group" and aR[5][2] = "Group" and aR[5][3] = "8")

# the combination, on two readings of one page: the reader tore the table into paragraphs and read a heading as text
aNat = [
	[ :kind = "heading", :level = 1, :text = "Parts", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "Overview", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "Item", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "Bolt", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "Qty", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "10", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "Parts are counted by hand.", :rows = [] ],
	[ :kind = "page_footer", :level = 0, :text = "Page 1", :rows = [] ] ]
aGr = [
	[ :kind = "heading", :level = 1, :text = "Parts", :rows = [] ],
	[ :kind = "heading", :level = 2, :text = "Overview", :rows = [] ],
	[ :kind = "table", :level = 0, :text = "", :rows = [ [ "Item", "Qty" ], [ "Bolt", "10" ] ] ],
	[ :kind = "caption", :level = 0, :text = "Table 1", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "Parts are counted by hand!", :rows = [] ] ]
aC = StzDocBlocksCombine(aNat, aGr)
cKinds = ""
for i = 1 to len(aC)
	cKinds += aC[i][:kind] + " "
next
? "  combined kinds: " + cKinds
chk("the combination is the reader's blocks with the model's table at the first torn cell, its caption after it",
	cKinds = "heading heading table caption paragraph page_footer ")
chk("the reader's paragraph that is a heading of the model becomes that heading, at the model's level",
	aC[2][:text] = "Overview" and aC[2][:level] = 2)
chk("the torn cells are dropped, the table is the model's, and the text stays the reader's (the model's '!' is not taken)",
	len(aC[3][:rows]) = 2 and aC[3][:rows][2][2] = "10" and aC[5][:text] = "Parts are counted by hand." and aC[6][:text] = "Page 1")
aAlone = StzDocBlocksCombine([ [ :kind = "paragraph", :level = 0, :text = "Alone", :rows = [] ] ], aGr)
chk("a table none of whose cells the reader found is appended after the last block", aAlone[len(aAlone) - 1][:kind] = "table")
chk("with no model reading the combination is the reader's own", len(StzDocBlocksCombine(aNat, [])) = len(aNat))
sec("scene 1")

#=====================================================================#
? "-- Scene 2: the scorer, against the independent scorer --"
#=====================================================================#
# a hand-worked page: the metrics are known before the code ran
aBl = [
	[ :kind = "heading", :level = 1, :text = "Alpha", :rows = [] ],
	[ :kind = "paragraph", :level = 0, :text = "One. Two.", :rows = [] ],
	[ :kind = "table", :level = 0, :text = "", :rows = [ [ "A", "B" ], [ "C", "D" ] ] ],
	[ :kind = "list_item", :level = 0, :text = "- item", :rows = [] ],
	[ :kind = "page_footer", :level = 0, :text = "Page 1", :rows = [] ],
	[ :kind = "code", :level = 0, :text = "x = 1", :rows = [] ] ]
aEx = [ :sentences = [ "One.", "Two.", "Nope." ], :headings = [ "Alpha", "Beta" ], :tables = [ [ [ "A", "B" ], [ "C", "X" ] ] ],
	:lists = [ "item" ], :furniture = [ "Page 1", "Alpha" ], :code = [ "x = 1" ] ]
aS = StzDocBlocksScores(aBl, aEx)
decimals(4)
chk("text 2 of 3, order 1 of 1 pair, headings 1 of 2, table cells 3 of 4",
	fabs(aS[1] - 2/3) < 0.0001 and aS[2] = 1 and aS[3] = 0.5 and aS[4] = 0.75)
chk("a list item found behind its marker, furniture kept out of the body 1 of 2, code found",
	aS[5] = 1 and aS[6] = 0.5 and aS[7] = 1)
chk("a document with no table to find has no table metric ('', a string: a score of 0 is a number)", isString(StzDocBlocksScores(aBl,
	[ :sentences = [], :headings = [], :tables = [], :lists = [], :furniture = [], :code = [] ])[4]))
chk("...and one whose table is not found scores 0, which is a number and counts in the mean", isNumber(StzDocBlocksScores([],
	[ :sentences = [ "x" ], :headings = [], :tables = [ [ [ "A" ] ] ], :lists = [], :furniture = [], :code = [] ])[4]) and
	StzDocBlocksMean([ 0, "", 1 ]) = 0.5)
decimals(6)

bStored1 = fexists($cRes1 + "doc_vlm_v1_scores.tsv") and fexists($cRes1 + "v2_e01.granite.tsv")
bStored2 = fexists($cRes2 + "doc_vlm_v2_scores.tsv") and fexists($cRes2 + "v2_e02.combined.tsv")
if bStored1
	CompareStored("v1", $cRes1, StzVisionGoldenDocV1($cPages1), [ "floor", "granite" ])
else
	aSkipped + "scene 2, golden v1 (the stored predictions in results/doc_vlm_v1/: _rig/doc_vlm_run.ring then doc_vlm_score.py)"
	? "  SKIPPED: the stored predictions of v1 are not in " + $cRes1
ok
if bStored2
	CompareStored("v2", $cRes2, StzVisionGoldenDocV2($cPages2), [ "floor", "granite", "combined" ])
else
	aSkipped + "scene 2, golden v2 (the stored predictions in results/doc_vlm_v2/)"
	? "  SKIPPED: the stored predictions of v2 are not in " + $cRes2
ok
sec("scene 2")

#=====================================================================#
? "-- Scene 3: parity with Hugging Face's Idefics3 --"
#=====================================================================#

if bModel and bPages and bPar
	cProj = StzVisionModelPath($cStzVisionDocProjector)
	cDec = StzVisionModelPath($cStzVisionDocDecoder)
	StzExpectModelDigest(cDec, $cStzVisionDocDecoderSha256)
	chk("the decoder loads with the digest recorded in models/MODELS.md", StzEngineNeuralModelLoad(cDec) = 1)
	$cStzVisionVlmSlot = cDec
	for k = 1 to len(aKeys)
		cK = aKeys[k]
		aRef = StzSplit(read($cPar + cK + "_ref.txt"), nl)
		aGrid = StzSplit(StzReplace(aRef[1], "grid ", ""), " ")
		o = StzImageQ($cPages1 + cK + ".png")
		aG2 = StzEngineNeuralVlmGrid(o.Width(), o.Height(), $nStzVisionDocLongest, $nStzVisionDocTile)
		cPx = StzEngineNeuralVlmPageViews(cProj, o.Pixels(), o.Width(), o.Height(), o.Channels(), $nStzVisionDocLongest)
		aPx = StzEngineNeuralF32Compare(cPx, read($cPar + cK + "_px.f32"))
		aT3 = _StzVisionDocTexts(aG2[1], aG2[2], $cStzVisionDocRequest)
		cIds = PromptIds(aT3)
		cJoined = StzJoinWith(aT3, char(31))
		cRows = StzEngineNeuralVlmPage(cProj, o.Pixels(), o.Width(), o.Height(), o.Channels(), $nStzVisionDocLongest, cJoined, -2, 4)
		aRw = StzEngineNeuralF32Compare(cRows, read($cPar + cK + "_feat.f32"))
		StzEngineNeuralVlmPage(cProj, o.Pixels(), o.Width(), o.Height(), o.Channels(), $nStzVisionDocLongest, cJoined, -1, 4)
		aTop = StzEngineNeuralVlmTop(5)
		aRT = StzSplit(StzReplace(aRef[3], "top ", ""), " ")
		# the DECISION must agree: the two likeliest tokens in HF's order; of the five, four the same tokens (ranks 3 to 5
		# are near-ties, 21.04 / 21.03 / 20.78 on the first page, which Q8 against fp32 may swap), their logits within
		# 2.0 token by token. The bar is 2.0 and not the 0.5 of SmolVLM's guard because these logits run to 35: the
		# measured differences are 0.3 to 1.3, about 3% of the largest logit, from Q8 products through 30 layers
		nSameTop = 0
		nD = 0
		for q = 1 to 5
			aKV = StzSplit(aRT[q], ":")
			for w = 1 to 5
				if aTop[w][1] = 0 + aKV[1]
					nSameTop++
					if fabs(aTop[w][2] - (0 + aKV[2])) > nD nD = fabs(aTop[w][2] - (0 + aKV[2])) ok
				ok
			next
		next
		nFirst = 0
		if aTop[1][1] = 0 + StzSplit(aRT[1], ":")[1] and aTop[2][1] = 0 + StzSplit(aRT[2], ":")[1] nFirst = 1 ok
		aGen = StzSplit(StzReplace(aRef[4], "gen ", ""), " ")
		nAgree = 0
		nGn = len(aGen)
		for q = 1 to nGn
			if StzEngineNeuralVlmTop(1)[1][1] = 0 + aGen[q] nAgree++ ok
			StzEngineNeuralVlmFeed(0 + aGen[q])
		next
		? "  " + cK + ": " + aG2[1] + " x " + aG2[2] + " tiles + the page, pixels cosine " + aPx[1] + " (largest difference " + aPx[2] +
			"), rows cosine " + aRw[1] + ", top-5 tokens " + nSameTop + "/5 within " + nD + ", teacher-forced " + nAgree + "/" + nGn
		chk(cK + ": the tiling is the processor's (" + aGrid[1] + " x " + aGrid[2] + " tiles and the whole page)",
			aG2[1] = 0 + aGrid[1] and aG2[2] = 0 + aGrid[2])
		chk(cK + ": the page's pixels are the processor's (cosine >= 0.9999: the same PIL Lanczos resizes)", aPx[1] >= 0.9999)
		chk(cK + ": the prompt's " + len(StzSplit(cIds, " ")) + " tokens are the independent tokenizer's", cIds = StzReplace(aRef[2], "ids ", ""))
		chk(cK + ": the views' rows agree with HF's (cosine >= 0.9995: Q8 products)", aRw[1] >= 0.9995)
		chk(cK + ": the two likeliest next tokens are HF's in HF's order; four of the five are the same tokens, logits within 2.0",
			nFirst = 1 and nSameTop >= 4 and nD < 2.0)
		chk(cK + ": fed HF's own words, the engine's next token is HF's at least " + (nGn - 3) + " times in " + nGn, nAgree >= nGn - 3)
		o.Release()
	next
else
	aSkipped + "scene 3 (models/vision/granite_docling_258m*.gguf, the rendered pages and the HF fixtures: _rig/doc_vlm_render.py, _rig/granite_docling_reference.py)"
	? "  SKIPPED: the Granite-Docling models, the rendered pages or the reference fixtures are not installed"
ok
sec("scene 3")

#=====================================================================#
? "-- Scene 4: DocBlocks() on pages, and the loop stop --"
#=====================================================================#

if bModel and bPages
	nCalls0 = StzVisionCallsRecorded()
	o = StzImageQ($cPages1 + "v2_e01.png")
	cTags = o.DocTags()
	aS4 = StzEngineNeuralVlmStats()
	? "  v2_e01: " + aS4[3] + " tokens, the views " + floor(aS4[1]) + " ms, the words " + floor(aS4[2]) + " ms"
	chk("the tags open with <doctag> and the model ends them", left(cTags, 8) = "<doctag>" and right(ring_trim(cTags), 9) = "</doctag>")
	aBk = o.DocBlocks()
	nTab = 0
	aTab = []
	for i = 1 to len(aBk)
		if aBk[i][:kind] = "table" nTab++ aTab = aBk[i][:rows] ok
	next
	chk("the borderless table of the page is found: one table of five rows and three columns", nTab = 1 and len(aTab) = 5 and len(aTab[1]) = 3)
	chk("...its header and a body cell are the document's", aTab[1][2] = "Yield (kg/ha)" and aTab[3][1] = "Tillaberi 3" and aTab[3][3] = "79")
	chk("...and the caption stands after it as a caption", HasKind(aBk, "caption"))
	chk("the same page gets the same blocks (greedy)", @@(o.DocBlocks()) = @@(aBk))
	chk("each call went through the door: " + (StzVisionCallsRecorded() - nCalls0) + " records for 3 calls", StzVisionCallsRecorded() - nCalls0 = 3)
	o.Release()
	# the native reader on the same page as a scan: it has no table without ruling lines
	aF = _StzVisionDocFloor($cPages1 + "v2_e01.png", [])
	nFT = 0
	for i = 1 to len(aF)
		if aF[i][:kind] = "table" nFT++ ok
	next
	? "  the native reader on v2_e01 as a scan: " + len(aF) + " blocks, " + nFT + " tables"
	chk("the native reader finds no table in a table drawn without ruling lines", nFT = 0)
	# the loop stop: v20_c22 of golden v1 fell into the same line over and over, 88 times, to the old cap of 3072 tokens
	# and 275 s. The engine's own stop (an identical line 3 times in a row) ends it where it begins
	o = StzImageQ($cPages1 + "v20_c22.png")
	t0 = clock()
	cLoop = o.DocTags()
	nSecLoop = (clock() - t0) / clockspersecond()
	aS4 = StzEngineNeuralVlmStats()
	? "  v20_c22: " + aS4[3] + " tokens, " + floor(nSecLoop) + " s (it ran 3072 tokens and 275 s without the stop)"
	aLines = StzSplit(cLoop, nl)
	nLn = len(aLines)
	# the stream may end on a part of a fourth line: look for the run of three among the last six lines
	bRun = 0
	for q = 3 to nLn
		if q > nLn - 6 and aLines[q] = aLines[q - 1] and aLines[q - 1] = aLines[q - 2] bRun = 1 ok
	next
	chk("the page that looped now stops short of the cap, at an identical line three times in a row", aS4[3] < $nStzVisionDocMaxTokens and bRun = 1)
	chk("...in under half the time it took (275 s)", nSecLoop < 140)
	o.Release()
else
	aSkipped + "scene 4 (the Granite-Docling models and the rendered pages)"
	? "  SKIPPED: the Granite-Docling models or the rendered pages are not installed"
ok
sec("scene 4")

#=====================================================================#
? "-- Scene 5: :doc-vlm, judged on golden v2 (fresh) --"
#=====================================================================#
# The golden set (_rig/doc_vlm_render.py and doc_vlm_golden.py v2; the rule fixed before any model read a page): the
# second and, when there is one, the third one-page English document of each of golden_v2 ... golden_v33. A page AGREES
# when the mean of the metrics that apply to it reaches $nStzDocAgreeBar (0.9). The floor is the native PDF reader on the page
# as a scan, run here; the model's and the combination's pages are read from the predictions stored by
# _rig/doc_vlm_run.ring (the combination is derived from the two readings by StzDocBlocksCombine, here as well).

if bStored2 and bPages
	aG = StzVisionGoldenDocV2($cPages2)
	StzVisionDeclare([ [ "doc-vlm", aG ] ])
	chk("27 :doc-vlm items, every page on disk", len(StzFacultyQ("doc-vlm").Goldens()) = 27 and AllOnDisk(aG))
	chk("the faculty has three implementations (the floor, the model, the two combined)", len(StzFacultyQ("doc-vlm").Implementations()) = 3)
	StzRunGoldensFor("doc-vlm", [ "none" ], [])
	nFloor = ScoreOf("doc-vlm", "native-reader", "doc-vlm-v2")
	nOkG = 0
	nOkC = 0
	nMeanF = 0
	nMeanG = 0
	nMeanC = 0
	nDiffC = 0
	aVF = []    # the verdict of each reader on every page, in golden order: the court's evidence
	aVG = []
	aVC = []
	for i = 1 to len(aG)
		cKey = KeyOf(aG[i][1])
		aBf = BlocksFromTsv($cRes2 + cKey + ".floor.tsv")
		aBg = BlocksFromTsv($cRes2 + cKey + ".granite.tsv")
		aBc = StzDocBlocksCombine(aBf, aBg)
		if @@(aBc) != @@(BlocksFromTsv($cRes2 + cKey + ".combined.tsv")) nDiffC++ ok
		if StzGoldenAgrees("doc-blocks", aBg, aG[i][2]) nOkG++ ok
		if StzGoldenAgrees("doc-blocks", aBc, aG[i][2]) nOkC++ ok
		aVF + StzGoldenAgrees("doc-blocks", aBf, aG[i][2])
		aVG + StzGoldenAgrees("doc-blocks", aBg, aG[i][2])
		aVC + StzGoldenAgrees("doc-blocks", aBc, aG[i][2])
		nMeanF += StzDocBlocksMean(StzDocBlocksScores(aBf, aG[i][2]))
		nMeanG += StzDocBlocksMean(StzDocBlocksScores(aBg, aG[i][2]))
		nMeanC += StzDocBlocksMean(StzDocBlocksScores(aBc, aG[i][2]))
	next
	chk("the combination the library makes is the one the runner stored (" + nDiffC + " pages differ)", nDiffC = 0)
	StzRecordMeasurement("doc-vlm", "granite-docling-258m", "doc-vlm-v2", nOkG / len(aG), len(aG), 1,
		"scored by the guard with doc-blocks on the predictions stored in results/doc_vlm_v2/")
	StzRecordMeasurement("doc-vlm", "native-plus-granite", "doc-vlm-v2", nOkC / len(aG), len(aG), 1,
		"scored by the guard with doc-blocks: StzDocBlocksCombine of the stored floor and model predictions of results/doc_vlm_v2/")
	nGran = ScoreOf("doc-vlm", "granite-docling-258m", "doc-vlm-v2")
	nComb = ScoreOf("doc-vlm", "native-plus-granite", "doc-vlm-v2")
	? "    native reader on a scan " + nFloor + "   granite-docling-258m " + nGran + "   native-plus-granite " + nComb +
		"   (share of pages whose metrics' mean reaches " + $nStzDocAgreeBar + ")"
	? "    the mean of the pages' metric means: native reader " + (nMeanF / len(aG)) + "   granite " + (nMeanG / len(aG)) + "   combined " + (nMeanC / len(aG))
	chk("both models were measured on the same 27 pages (" + nGran + ", " + nComb + ")", nGran >= 0 and nComb >= 0)
	# THE COURT'S EVIDENCE (the default gate): the stored floor reading must be the live one, or the evidence is of something else
	nSumF = 0
	for i = 1 to len(aVF)  nSumF += aVF[i]  next
	chk("the floor's STORED readings agree on as many pages as its live run (" + nSumF + " of " + len(aVF) + "): the evidence is of what was measured", nSumF / len(aVF) = nFloor)
	StzRecordCourtFromVerdicts("doc-vlm", "doc-vlm-v2", [ [ "native-reader", aVF, [] ], [ "granite-docling-258m", aVG, [] ], [ "native-plus-granite", aVC, [] ] ])
	StzSaveCourt("results/court_im7b.txt")
	aCt = StzCourtVerdictOf("doc-vlm", "doc-vlm-v2", "granite-docling-258m", "native-reader")
	? "    the court: granite over the native reader " + aCt[:gains] + " gains, " + aCt[:losses] + " losses, P = " + aCt[:p] + " -> " + aCt[:verdict]
	cChosen = StzModelRegistryQ().ResolveQ("doc-vlm").Chosen()
	chk("the registry chose '" + cChosen + "' -- the rule (the court) says '" + ByTheRule("doc-vlm", "doc-vlm-v2") + "'",
		cChosen = ByTheRule("doc-vlm", "doc-vlm-v2"))
	? "    on the record, golden v1 (the first two readers): native reader " + ScoreOf("doc-vlm", "native-reader", "doc-vlm-v1") +
		", granite-docling-258m " + ScoreOf("doc-vlm", "granite-docling-258m", "doc-vlm-v1") + " -- a tie"
	chk("v1's tie is still on the record", ScoreOf("doc-vlm", "native-reader", "doc-vlm-v1") = ScoreOf("doc-vlm", "granite-docling-258m", "doc-vlm-v1") and
		ScoreOf("doc-vlm", "native-reader", "doc-vlm-v1") > 0)
	if NOT StzDirExists("results") StzDirCreatePath("results") ok
	StzSaveMeasurements("results/vision_im7b.zmdl.txt")
else
	aSkipped + "scene 5 (the stored predictions and the rendered pages)"
	? "  SKIPPED: the stored predictions or the rendered pages are not installed"
ok
sec("scene 5")

if len(aSkipped) > 0
	? "SKIPPED BY NAME, not run: " + len(aSkipped)
	for i = 1 to len(aSkipped)
		? "  - " + aSkipped[i]
	next
ok
? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

# the independent scorer's numbers against the Ring scorer's, metric by metric, on a set's stored predictions
func CompareStored(cSet, cRes, aG, aTools)
	aPy = ReadScores(cRes + "doc_vlm_" + cSet + "_scores.tsv")
	nDiff = 0
	nCmp = 0
	nDocs = 0
	for t = 1 to len(aTools)
		for i = 1 to len(aG)
			cKey = KeyOf(aG[i][1])
			aBk = BlocksFromTsv(cRes + cKey + "." + aTools[t] + ".tsv")
			aMine = StzDocBlocksScores(aBk, aG[i][2])
			aTheirs = ScoresOf(aPy, aTools[t] + "|" + cKey)
			nDocs++
			for m = 1 to 7
				nCmp++
				# a metric is a number or "" (none): compare the TYPE first, 0 = "" being TRUE in Ring
				if isString(aMine[m]) and isString(aTheirs[m]) loop ok
				if isString(aMine[m]) or isString(aTheirs[m]) or fabs(aMine[m] - aTheirs[m]) > 0.0000001
					nDiff++
					? "    differs: " + aTools[t] + " " + cKey + " metric " + m + ": " + aMine[m] + " vs " + aTheirs[m]
				ok
			next
		next
	next
	chk("golden " + cSet + ": the Ring scorer and _doc_score.py agree on " + nCmp + " metrics of " + nDocs + " stored predictions", nDiff = 0)

# the ids the engine gives the prompt's texts, the views' 64 rows each written as 64 <image> ids (100270)
func PromptIds(aTexts)
	c = ""
	n = len(aTexts)
	for k = 1 to n
		m = StzEngineNeuralGenTokenize(aTexts[k])
		for i = 0 to m - 1
			c += " " + StzEngineNeuralGenTokenAt(i)
		next
		if k < n
			for j = 1 to 64
				c += " 100270"
			next
		ok
	next
	return ring_trim(c)

func HasKind(aB, cKind)
	for i = 1 to len(aB)
		if aB[i][:kind] = cKind return 1 ok
	next
	return 0

func KeyOf(cPath)
	a = StzSplit(cPath, "/")
	c = a[len(a)]
	return left(c, len(c) - 4)

func AllOnDisk(aG)
	n = len(aG)
	for i = 1 to n
		if NOT fexists(aG[i][1]) return 0 ok
	next
	return 1

func ScoreOf(cF, cImpl, cVer)
	a = StzMeasurementOf(cF, cImpl, cVer)
	if len(a) = 0
		return -1
	ok
	return a[:score]

func ByTheRule(cF, cVer)
	# the court's rule (the default gate since 2026-11-05), restated independently in _court_rule.ring
	return CourtRuleChoice(cF, cVer)

func ReadScores(cPath)
	aOut = []
	aL = StzSplit(read(cPath), char(10))
	for i = 1 to len(aL)
		if aL[i] = "" loop ok
		aF = StzSplit(aL[i], char(9))
		aM = []
		for m = 3 to 9
			if aF[m] = "-" aM + "" else aM + (0 + aF[m]) ok
		next
		aOut + [ aF[1] + "|" + aF[2], aM ]
	next
	return aOut

func ScoresOf(aPy, cKey)
	for i = 1 to len(aPy)
		if aPy[i][1] = cKey return aPy[i][2] ok
	next
	return []

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()
