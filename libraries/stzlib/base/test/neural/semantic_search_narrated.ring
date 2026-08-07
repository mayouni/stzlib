# Semantic search -- the numeric retro's LAST open item, closed.
#
# The pipeline: BERT sentence embeddings (the engine's full forward pass on
# a runtime-loaded GGUF) -> a resident engine dataset -> exact top-k. The
# assertions that matter are the ones keyword search CANNOT pass: queries
# that share NO word with their target must still find it, because meaning
# survives the embedding where spelling does not.
#
# The model is a real file (all-MiniLM-L6-v2, ~23 MB, in models/). On a
# machine without it the guard proves the REFUSAL contract instead and
# says so -- a skipped capability is reported, never silently green.

load "../../stzBase.ring"

nPass = 0
nFail = 0
cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"

pr()

? "-- Scene 1: without a model, the index refuses loudly --"
if StzEngineNeuralModelLoaded() = 0
	oNoIdx = new stzSemanticIndex([])
	bRaised = FALSE
	try
		oNoIdx.AddText("anything")
	catch
		bRaised = TRUE
	done
	chk("AddText without a model raises, never garbage", bRaised)
else
	chk("(a model was already loaded; refusal scene not reachable)", TRUE)
ok

if NOT fexists(cModel)
	? ""
	? "MODEL FILE NOT PRESENT (" + cModel + ")"
	? "The semantic scenes need it; refusal contract verified above."
	? "=========================================="
	? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail (semantic scenes SKIPPED: no model)"
	? "=========================================="
	pf()
	bye
ok

oModel = new stzNeuralModel(cModel)
chk("the embedding model loads from GGUF", oModel.IsLoaded())

? ""
? "-- Scene 2: the index answers MEANING, not keywords --"
oIdx = new stzSemanticIndex([
	"The oven must be preheated before the dough goes in",
	"The compiler optimizes the inner loop aggressively",
	"A cold front brings heavy rain tomorrow morning",
	"Knead the flour and water until the mixture is elastic",
	"The unit tests cover every branch of the parser",
	"Sunny skies are expected for the whole weekend",
	"Whisk the eggs with sugar until the cream thickens",
	"The garbage collector pauses the virtual machine briefly"
])
chk("eight documents indexed", oIdx.Count() = 8)
chk("the embedding dimension is MiniLM's 384", oIdx.EmbeddingDim() = 384)

# No shared keywords: "bake bread" appears in NO document; the two baking
# sentences must still win. THIS is the assertion tf-idf cannot pass.
aHits = oIdx.SearchXT("How do I bake bread?", 2)
bBaking = (StzFindFirst("dough", aHits[1][1] + aHits[2][1]) > 0) and
          (StzFindFirst("flour", aHits[1][1] + aHits[2][1]) > 0)
chk("'How do I bake bread?' retrieves BOTH baking sentences", bBaking)

aHits2 = oIdx.SearchXT("Will the weather be nice?", 2)
bWeather = (StzFindFirst("rain", aHits2[1][1] + aHits2[2][1]) > 0) and
           (StzFindFirst("Sunny", aHits2[1][1] + aHits2[2][1]) > 0)
chk("'Will the weather be nice?' retrieves both weather sentences", bWeather)

aHits3 = oIdx.SearchXT("My program runs slowly", 1)
bCode = StzFindFirst("compiler", aHits3[1][1]) > 0 or StzFindFirst("garbage", aHits3[1][1]) > 0
chk("'My program runs slowly' lands on a programming sentence", bCode)

? ""
? "-- Scene 3: the scores behave like cosines --"
aAll = oIdx.SearchXT("How do I bake bread?", 8)
bOrdered = TRUE
for i = 2 to len(aAll)
	if aAll[i][2] > aAll[i-1][2] bOrdered = FALSE ok
next
chk("scores come back best-first", bOrdered)
bInRange = TRUE
for i = 1 to len(aAll)
	if aAll[i][2] < -1.000001 or aAll[i][2] > 1.000001 bInRange = FALSE ok
next
chk("every score is a cosine in [-1, 1]", bInRange)

# An indexed text queried verbatim is its own best match at ~1 -- and the
# NEGATIVE sibling: an unrelated query must NOT reach that ceiling.
aSelf = oIdx.SearchXT("The compiler optimizes the inner loop aggressively", 1)
chk("a verbatim query finds itself", StzFindFirst("compiler", aSelf[1][1]) > 0)
chk("...scoring essentially 1", aSelf[1][2] > 0.999)
chk("...while a cross-topic query scores well below it",
	aHits[1][2] < 0.95)

? ""
? "-- Scene 4: lifecycle is explicit --"
oIdx.Close()
chk("Close() empties the index", oIdx.Count() = 0)
chk("...and searching an empty index returns [] not an error",
	len(oIdx.SearchXT("anything", 3)) = 0)

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
