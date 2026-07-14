# R4 step 0 ACCEPTANCE -- learning/: the classic-ML floor
# Zero-setup, fully explainable learners (LAW 3): kNN (zero training,
# Why = "the nearest examples were..."), multinomial naive Bayes
# (text, Laplace), TF-IDF (the vectorizer, on stzCorpus).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: kNN -- learning without training --"
oDs = new stzTrainingSet([
	[ [5.1, 3.5], "setosa" ], [ [4.9, 3.0], "setosa" ], [ [4.7, 3.2], "setosa" ],
	[ [7.0, 3.2], "versicolor" ], [ [6.4, 3.2], "versicolor" ], [ [6.9, 3.1], "versicolor" ]
])
chk("the training set holds its examples",
	oDs.NumberOfExamples() = 6 and len(oDs.Labels()) = 2)
oK = new stzKnn(oDs)
oK.SetK(3)
chk("a small flower classifies setosa", oK.Classify([5.0, 3.4]) = "setosa")
chk("a big flower classifies versicolor", oK.Classify([6.8, 3.2]) = "versicolor")
? "  why: " + oK.Why()
chk("Why names the neighbours and the vote",
	len(StzFind("nearest examples", oK.Why())) > 0 and
	len(StzFind("majority", oK.Why())) > 0)
aTT = oDs.Split(0.5)
chk("the split is deterministic head/tail",
	aTT[1].NumberOfExamples() = 3 and aTT[2].NumberOfExamples() = 3)

? ""
? "-- Scene 2: naive Bayes -- the text learner --"
oNB = new stzNaiveBayes()
oNB.Train("great food and lovely staff", "positive")
oNB.Train("wonderful evening, delicious dishes", "positive")
oNB.Train("cold soup and rude waiter", "negative")
oNB.Train("terrible service, awful noise", "negative")
chk("positive text classifies positive",
	oNB.Classify("lovely dishes and great service") = "positive")
chk("negative text classifies negative",
	oNB.Classify("awful cold food") = "negative")
chk("the verdict shows its log-scores",
	len(StzFind("log-scores", oNB.Why())) > 0)

? ""
? "-- Scene 3: TF-IDF -- distinctiveness, not just frequency --"
oC = new stzCorpus([
	"the pizza oven bakes the margherita",
	"the espresso machine brews the coffee",
	"the oven and the machine share the kitchen"
])
chk("a ubiquitous word earns less idf than a rare one",
	oC.IdfOf("the") < oC.IdfOf("pizza"))
chk("tf counts per document", oC.TfOf("the", 1) = 2 and oC.TfOf("pizza", 2) = 0)
aTop = oC.TopTermsOf(1, 3)
bHasPizza = 0
for i = 1 to len(aTop)
	if aTop[i][1] = "pizza"
		bHasPizza = 1
	ok
next
chk("the distinctive term surfaces in the top terms", bHasPizza = 1)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
