# learning/ STRESS -- classifiers, clustering and rule mining under load.
#
# Machine learning fails differently from the rest of the library. A list that
# breaks raises; a CLASSIFIER that breaks returns a confident answer that
# happens to be wrong. So this file checks two things everywhere:
#
#   - the answer is RIGHT on data whose correct answer is known by
#     construction, and
#   - when the model cannot work, that fact is DETECTABLE rather than
#     dressed up as certainty.
#
# The headline case is scene 3. Gradient descent on UNSCALED features
# diverges -- weights explode, the sigmoid saturates, and Probability()
# returns exactly 1.0 for an answer that is simply wrong. Needing scaled
# features is the normal requirement for SGD, not a defect, but nothing
# surfaced the failure until TrainingAccuracy() was added: a diverged model
# scores at chance on data it has already seen.
#
# Multilingual matters here because labels and documents are TEXT: a
# tokenizer or a label comparison that mangles multibyte input corrupts every
# count above it without ever raising.
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

? "-- Scene 1: a training set, and siblings that must agree --"
oTS = new stzTrainingSet([])
nLow = 40
nHigh = 40

for i = 1 to nLow
	oTS.AddExample([ i, i ], cAr)              # multilingual LABEL
next
for i = 60 to 60 + nHigh - 1
	oTS.AddExample([ i, i ], cCJK)
next

chk("every example landed", oTS.NumberOfExamples() = nLow + nHigh)
chk("NumberOfExamples agrees with Examples()",
	oTS.NumberOfExamples() = len(oTS.Examples()))
chk("both multilingual labels are known", len(oTS.Labels()) = 2)
chk("the feature count is right", oTS.NumberOfFeatures() = 2)
chk("a multilingual label survives storage",
	StzFindFirst(cAr, oTS.Labels()) > 0)

? ""
? "-- Scene 2: kNN on data separated by construction --"
oK = new stzKnn(oTS)
oK.SetK(3)
chk("a low point gets the Arabic label", oK.Classify([ 5, 5 ]) = cAr)
chk("a high point gets the CJK label", oK.Classify([ 70, 70 ]) = cCJK)

t0 = clock()
for i = 1 to 50
	v = oK.Classify([ 5, 5 ])
next
tKnn = (clock() - t0) / clockspersecond()
? "  50 classifications in " + tKnn + " s"
chk("kNN stays fast at this size (< 3s)", tKnn < 3)

? ""
? "-- Scene 3: the way logistic regression fails is SILENT --"
# Same data twice: once scaled, once not. The unscaled model does not raise,
# does not return NaN, and reports probability 1.0 -- for the wrong class.
oScaled = new stzTrainingSet([])
for i = 1 to 20
	oScaled.AddExample([ i/100, i/100 ], "low")
next
for i = 60 to 79
	oScaled.AddExample([ i/100, i/100 ], "high")
next

oLS = new stzLogisticRegression(oScaled)
oLS.Train(200)
chk("scaled: a low point reads low", oLS.Classify([ 0.05, 0.05 ]) = "low")
chk("scaled: a high point reads high", oLS.Classify([ 0.70, 0.70 ]) = "high")
chk("scaled: it fits its own training data", oLS.TrainingAccuracy() > 0.9)

oUnscaled = new stzTrainingSet([])
for i = 1 to 20
	oUnscaled.AddExample([ i*1000, i*1000 ], "low")
next
for i = 60 to 79
	oUnscaled.AddExample([ i*1000, i*1000 ], "high")
next

oLU = new stzLogisticRegression(oUnscaled)
oLU.Train(200)
nAccU = oLU.TrainingAccuracy()
? "  unscaled model training accuracy: " + nAccU + " (scaled: " + oLS.TrainingAccuracy() + ")"

chk("unscaled: it does NOT raise and does NOT return a non-number",
	oLU.Probability([ 5000, 5000 ]) >= 0)
chk("unscaled: it is confidently WRONG on a training-range point",
	oLU.Classify([ 5000, 5000 ]) != "low")
chk("...and TrainingAccuracy exposes it as no better than chance", nAccU <= 0.6)
chk("an untrained model reports zero, not a guess",
	(new stzLogisticRegression(oScaled)).TrainingAccuracy() = 0)

? ""
? "-- Scene 4: Naive Bayes on MULTILINGUAL documents --"
oNB = new stzNaiveBayes()
oNB.Train("buy cheap pills now", "spam")
oNB.Train("cheap watches for sale", "spam")
oNB.Train(cAr + " cheap offer " + cAr, "spam")
oNB.Train("meeting tomorrow at noon", "ham")
oNB.Train("lunch with the team", "ham")
oNB.Train(cCJK + " team meeting " + cCJK, "ham")

chk("two labels are learned", len(oNB.Labels()) = 2)
chk("an obviously spammy line reads spam", oNB.Classify("cheap offer now") = "spam")
chk("an obviously benign line reads ham", oNB.Classify("team lunch tomorrow") = "ham")
chk("an ARABIC-marked document classifies as trained",
	oNB.Classify(cAr + " " + cAr) = "spam")
chk("a CJK-marked document classifies as trained",
	oNB.Classify(cCJK + " " + cCJK) = "ham")
chk("an unseen multilingual token does not crash the classifier",
	oNB.Classify(cGrUp + " " + cGrUp) != "")

? ""
? "-- Scene 5: KMeans on blobs placed by hand --"
aV = []
for i = 1 to 15
	aV + [ i, i ]
next
for i = 100 to 114
	aV + [ i, i ]
next

oKM = new stzKMeans(aV)
oKM.SetK(2)
oKM.Run(50)
chk("it finds the two blobs", len(oKM.Clusters()) = 2)
chk("a near-origin point lands in one cluster", oKM.ClusterOf([ 2, 2 ]) >= 1)
chk("a far point lands in the OTHER cluster",
	oKM.ClusterOf([ 110, 110 ]) != oKM.ClusterOf([ 2, 2 ]))
chk("inertia is non-negative", oKM.Inertia() >= 0)
chk("it converged in a sane number of iterations", oKM.Iterations() <= 50)

# Degenerate input: every point identical, so there are not two distinct
# centroids to seed. Refusing is the RIGHT answer -- inventing two clusters
# out of one repeated point would be a fabricated result.
bKmRefused = FALSE
try
	oKMD = new stzKMeans([ [1,1], [1,1], [1,1] ])
	oKMD.SetK(2)
	oKMD.Run(10)
catch
	bKmRefused = TRUE
done
chk("identical points are REFUSED, not clustered into a fiction", bKmRefused)

? ""
? "-- Scene 6: a decision tree over a rule we chose --"
oDTS = new stzTrainingSet([])
oDTS.AddExample([ 1, 1 ], "yes")
oDTS.AddExample([ 1, 0 ], "yes")
oDTS.AddExample([ 0, 1 ], "no")
oDTS.AddExample([ 0, 0 ], "no")

oDT = new stzDecisionTree(oDTS)
oDT.Train()
chk("the tree learns the first feature decides", oDT.Classify([ 1, 1 ]) = "yes")
chk("...on both sides", oDT.Classify([ 0, 0 ]) = "no")
chk("it can explain itself", oDT.Why() != "")

? ""
? "-- Scene 7: association rules, and the counting behind them --"
# Rule mining bumps a counter per item, per transaction, per itemset level,
# so the cost of ONE membership test is multiplied enormously. That test used
# to rebuild and re-fold the whole key list on every call.
oAp = new stzApriori([ [ "bread","milk" ],
                       [ "bread","milk","eggs" ],
                       [ "bread","eggs" ],
                       [ "milk","eggs" ] ])
chk("all four transactions are held", oAp.NumberOfTransactions() = 4)

aF = oAp.FrequentItemsets(2)
chk("frequent itemsets are found", len(aF) > 0)
aR = oAp.Rules(2, 0.5)
chk("rules are derived", len(aR) > 0)

nTx = 160
aTx = []
for i = 1 to nTx
	aTx + [ "a"+(i%5), "b"+(i%7), "c"+(i%3), "d"+(i%4) ]
next

oApBig = new stzApriori(aTx)
t0 = clock()
aFB = oApBig.FrequentItemsets(3)
tAp = (clock() - t0) / clockspersecond()
? "  " + nTx + " transactions mined in " + tAp + " s (" + len(aFB) + " itemsets)"
chk("mining stays workable at 160 transactions (< 5s)", tAp < 5)
chk("it found itemsets", len(aFB) > 0)

? ""
? "-- Scene 8: refusals, where refusing is the right answer --"
oOne = new stzTrainingSet([])
oOne.AddExample([ 1, 1 ], "only")

bRefused = FALSE
try
	oBad = new stzLogisticRegression(oOne)
	oBad.Train(10)
catch
	bRefused = TRUE
done
chk("binary logistic REFUSES a single-class training set", bRefused)

oK1 = new stzKnn(oOne)
oK1.SetK(3)
chk("kNN with k larger than the data still answers",
	oK1.Classify([ 9, 9 ]) = "only")

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
