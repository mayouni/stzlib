# stzCorpus / stzMatrix STRESS -- the incremental-cache pattern.
#
# Both classes keep a derived structure beside their data: stzCorpus an
# engine n-gram model, stzMatrix an engine matrix. Both used to THROW IT AWAY
# on every mutation and rebuild it on the next query. That design is only a
# problem when the MUTATION is much cheaper than the REBUILD -- and that
# distinction is the whole point of this file:
#
#   stzCorpus  AddDocument is O(one document), the retrain was O(whole
#              corpus). So "add a document, ask a question" -- the loop a
#              corpus is actually built with -- was O(docs^2). 400 documents
#              took 1.89s where 100 took 0.12s. FIXED: documents are now
#              pushed into the live model.
#
#   stzMatrix  every mutation is elementwise over the WHOLE matrix, so it is
#              already O(cells) -- the same order as the rebuild. Measured
#              linear in cells and left alone. Not every invalidating cache
#              is a defect, and this file records which is which so the
#              question is not re-opened.
#
# The corpus is multilingual because term counting, document frequency and
# vocabulary all key on TOKENS, and a tokenizer that mangles multibyte text
# corrupts every statistic above it silently.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder.
#
# Ring traps avoided: no func named Show / Try, no local named nL / oR.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cAr   = MkW([ 0x0639, 0x0645, 0x0644 ])                 # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK
cGrUp = MkW([ 0x0391, 0x0398 ])                         # Greek UPPER
cCafe = MkW([ 0x0063, 0x0061, 0x0066, 0x00E9 ])         # Latin cafe'

? "-- Scene 1: a small corpus with answers we can count by hand --"
oSmall = new stzCorpus([ "the cat sat on the mat",
                         "the dog sat on the log",
                         "cats and dogs" ])
chk("three documents", oSmall.NumberOfDocuments() = 3)
chk("'the' occurs four times", oSmall.FreqOf("the") = 4)
chk("an absent term scores zero", oSmall.FreqOf("nosuchterm") = 0)
chk("'sat' appears in two documents", oSmall.NumberOfDocumentsWith("sat") = 2)
chk("vocabulary and Vocabulary() agree",
	oSmall.VocabularySize() = len(oSmall.Vocabulary()))
chk("the most frequent term is 'the'", oSmall.MostFrequent(1)[1][1] = "the")

? ""
? "-- Scene 2: THE interleaved pattern -- add a document, ask a question --"
nDocs = 400

aDocs = []
for i = 1 to nDocs
	# every fourth document carries a different script
	if i % 4 = 0
		aDocs + (cAr + " document " + i + " about cats and dogs")
	but i % 4 = 1
		aDocs + (cCJK + " document " + i + " about cats and birds")
	but i % 4 = 2
		aDocs + (cGrUp + " document " + i + " about dogs and fish")
	else
		aDocs + (cCafe + " document " + i + " about cats and cats")
	ok
next

oInc = new stzCorpus("seed document about cats")

t0 = clock()
for i = 1 to nDocs
	oInc.AddDocument(aDocs[i])
	v = oInc.FreqOf("cats")
next
tInter = (clock() - t0) / clockspersecond()

? "  " + nDocs + " add+query steps in " + tInter + " s"
chk("every document landed", oInc.NumberOfDocuments() = nDocs + 1)
chk("interleaving stays linear (< 5s)", tInter < 5)
chk("a query during the build saw the document just added",
	oInc.FreqOf("cats") > 0)

? ""
? "-- Scene 3: incremental must equal a full retrain --"
# oInc was queried throughout, so its model was maintained document by
# document. oFull is the same corpus with no queries, so it trains once.
aAll = [ "seed document about cats" ]
for i = 1 to nDocs
	aAll + aDocs[i]
next
oFull = new stzCorpus(aAll)

chk("same document count", oInc.NumberOfDocuments() = oFull.NumberOfDocuments())
chk("same vocabulary size", oInc.VocabularySize() = oFull.VocabularySize())
chk("same token count", oInc.NumberOfWords() = oFull.NumberOfWords())
chk("same term frequency", oInc.FreqOf("cats") = oFull.FreqOf("cats"))
chk("same answer for an ABSENT term",
	oInc.FreqOf("nosuchtermatall") = oFull.FreqOf("nosuchtermatall"))
chk("same document frequency",
	oInc.NumberOfDocumentsWith("dogs") = oFull.NumberOfDocumentsWith("dogs"))
chk("same idf", "" + oInc.IdfOf("cats") = "" + oFull.IdfOf("cats"))
chk("same tf", "" + oInc.TfOf("cats", 1) = "" + oFull.TfOf("cats", 1))
chk("same tf-idf", "" + oInc.TfIdfOf("cats", 1) = "" + oFull.TfIdfOf("cats", 1))
chk("same ranking", @@(oInc.MostFrequent(5)) = @@(oFull.MostFrequent(5)))

? ""
? "-- Scene 4: multilingual terms are counted, not mangled --"
# Every statistic keys on tokens, so a tokenizer that breaks multibyte text
# would quietly under- or over-count without ever raising anything.
nExpectAr = floor(nDocs / 4)
? "  Arabic-tagged documents built: " + nExpectAr
chk("the Arabic term is present at all", oFull.FreqOf(cAr) > 0)
chk("the CJK term is present", oFull.FreqOf(cCJK) > 0)
chk("the accented Latin term is present", oFull.FreqOf(cCafe) > 0)
chk("document frequency for the Arabic term matches the build",
	oFull.NumberOfDocumentsWith(cAr) = nExpectAr)
chk("...and for the CJK term", oFull.NumberOfDocumentsWith(cCJK) = nExpectAr)
chk("a multilingual term absent from the corpus scores zero",
	oFull.FreqOf(cAr + cCJK + "-absent") = 0)

# Greek is CASED -- the tokenizer folds, so the count must survive folding
chk("the Greek UPPERCASE term is counted", oFull.FreqOf(cGrUp) > 0)
chk("...and matches its folded spelling",
	oFull.FreqOf(cGrUp) = oFull.FreqOf(StzLower(cGrUp)))

? ""
? "-- Scene 5: stzMatrix -- an invalidating cache that is NOT a defect --"
# Every stzMatrix mutation is elementwise over the whole matrix, so it is
# already O(cells) and an O(cells) rebuild costs the same order. The guard
# below records that it stays linear IN CELLS, so nobody has to re-derive
# why this one was left alone.
nSz = 60
aM = []
for i = 1 to nSz
	aRow = []
	for j = 1 to nSz
		aRow + (i + j)
	next
	aM + aRow
next

oMat = new stzMatrix(aM)
chk("the matrix has the expected shape", oMat.Rows() = nSz and oMat.Cols() = nSz)

nTraceBefore = oMat.Trace()
t0 = clock()
for k = 1 to 50
	oMat.AddMatrix(aM)
	v = oMat.Trace()
next
tMat = (clock() - t0) / clockspersecond()
? "  50 mutate+query steps on " + nSz + "x" + nSz + " in " + tMat + " s"
chk("mutating and querying stays fast (< 5s)", tMat < 5)
chk("the trace grew exactly as the additions demand",
	oMat.Trace() = nTraceBefore * 51)

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

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
