# Softanza (Ring engine) side of the NLP benchmark. Mirror of bench_python.py:
# same corpus, same workloads, best-of-5 wall time.
#
# Run gencorpus.py first, then from THIS directory:
#     ring bench_softanza.ring
# (must be run from the _bench directory so the engine DLLs resolve and the
#  corpus files are found; each measured region excludes stzBase load time.)
#
# NOTE: Windows Ring clock() has ~10-15ms resolution -- treat sub-15ms numbers
# as noise. One statement per line (multi-statement lines parse flakily).

load "../../../stzBase.ring"

cCorpus   = read("corpus.txt")
cEntities = read("entities.txt")
cDocA     = read("docA.txt")
cDocB     = read("docB.txt")
REPS = 5

# 1) word frequency top-20 (folded) via the streaming accumulator
nBest = 9999999
cTop = ""
for r = 1 to REPS
	t0 = clock()
	o = new stzWordStream()
	o.Feed(cCorpus)
	aTop = o.TopWords(20)
	o.Free()
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest
		nBest = dt
		cTop = aTop[1][1] + "=" + aTop[1][2]
	ok
next
? "wordfreq top20      : " + floor(nBest) + " ms   (top=" + cTop + ")"

# 2) cosine similarity docA vs docB (folded)
nBest = 9999999
nSim = 0
for r = 1 to REPS
	t0 = clock()
	oA = new stzString(cDocA)
	x = oA.CosineSimilarityWithCS(cDocB, 0)
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest
		nBest = dt
		nSim = x
	ok
next
? "cosine similarity   : " + floor(nBest) + " ms   (sim=" + nSim + ")"

# 3) collocations / PMI top-10 bigrams (min count 5, folded)
nBest = 9999999
cColl = ""
for r = 1 to REPS
	t0 = clock()
	oC = new stzString(cCorpus)
	aColl = oC.CollocationsCS(5, 10, 0)
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest
		nBest = dt
		if len(aColl) > 0
			cColl = aColl[1]
		ok
	ok
next
? "collocations PMI    : " + floor(nBest) + " ms   (top=" + cColl + ")"

# 4) NER extraction (emails + urls + ipv4) over the entity text
nBest = 9999999
cN = ""
for r = 1 to REPS
	t0 = clock()
	oE = new stzString(cEntities)
	ne = len(oE.ExtractEmails())
	oE2 = new stzString(cEntities)
	nu = len(oE2.ExtractURLs())
	oE3 = new stzString(cEntities)
	ni = len(oE3.ExtractIPv4Addresses())
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest
		nBest = dt
		cN = "" + ne + "," + nu + "," + ni
	ok
next
? "NER emails+urls+ips : " + floor(nBest) + " ms   (counts=" + cN + ")"

# 5) sentence segmentation (full UAX#29 Sentence_Break)
nBest = 9999999
nSent = 0
for r = 1 to REPS
	t0 = clock()
	oSe = new stzString(cCorpus)
	nSent = oSe.NumberOfSentences()
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest  nBest = dt ok
next
? "sentences (UAX#29)  : " + floor(nBest) + " ms   (n=" + nSent + ")"

# 6) CJK overlapping bigrams (dictionary-free CJK search tokenization)
cCjk = read("cjk.txt")
nBest = 9999999
nBg = 0
for r = 1 to REPS
	t0 = clock()
	oBg = new stzString(cCjk)
	aBg = oBg.WordsForSearch()
	nBg = len(aBg)
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest  nBest = dt ok
next
? "CJK bigrams         : " + floor(nBest) + " ms   (tokens=" + nBg + ")"

# 7) stemming (Snowball English, in place) -- no Python stdlib baseline
nBest = 9999999
for r = 1 to REPS
	t0 = clock()
	oSt = new stzString(cCorpus)
	cSt = oSt.Stemmed()
	dt = ((clock() - t0) / clockspersecond()) * 1000
	if dt < nBest  nBest = dt ok
next
? "stem 600k words     : " + floor(nBest) + " ms"
