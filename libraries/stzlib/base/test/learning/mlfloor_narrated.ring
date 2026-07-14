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
? "-- Scene 4: the decision tree -- a model you can READ (and query) --"
oTs2 = new stzTrainingSet([
	[ ["sunny", "high"], "no" ], [ ["sunny", "normal"], "yes" ],
	[ ["overcast", "high"], "yes" ], [ ["overcast", "normal"], "yes" ],
	[ ["rain", "high"], "no" ], [ ["rain", "normal"], "yes" ]
])
oT = new stzDecisionTree(oTs2)
oT.SetFeatureNames([ "outlook", "humidity" ])
oT.Train()
chk("the tree classifies", oT.Classify([ "sunny", "high" ]) = "no")
? "  why: " + oT.Why()
chk("Why narrates the decision PATH", len(StzFind("->", oT.Why())) > 0)
chk("an unseen value falls to the majority default",
	oT.Classify([ "storm", "high" ]) != "")
oG = oT.ToGraph()
chk("the learned model IS a stzGraph (foundations compose)",
	oG.NodesCount() >= 3 and oG.EdgeCount() = oG.NodesCount() - 1)

? ""
? "-- Scene 5: apriori -- rules that read as knowledge --"
oA = new stzApriori([
	[ "bread", "butter" ], [ "bread", "butter", "jam" ],
	[ "bread", "jam" ], [ "butter", "jam" ], [ "bread", "butter" ]
])
chk("frequent itemsets counted",
	len(oA.FrequentItemsets(3)) = 4)
aR = oA.Rules(3, 0.7)
chk("confident rules emerge as IF-THEN", len(aR) = 2)
chk("each rule carries support AND confidence",
	aR[1][:support] = 3 and aR[1][:confidence] >= 0.7)

? ""
? "-- Scene 6: k-means -- unsupervised, deterministic, accountable --"
oKM = new stzKMeans([ [1,1], [1.2,0.9], [0.8,1.1], [8,8], [7.9,8.1], [8.2,7.8] ])
oKM.SetK(2)
oKM.Run(50)
aCl = oKM.Clusters()
chk("two blobs separate cleanly",
	len(aCl[1]) = 3 and len(aCl[2]) = 3)
chk("a new point joins its blob", oKM.ClusterOf([7.5, 8.0]) = 2)
chk("Why reports iterations and inertia",
	len(StzFind("inertia", oKM.Why())) > 0)

? ""
? "-- Scene 7: logistic regression -- the first gradient-trained model --"
oTs3 = new stzTrainingSet([
	[ [0.5], "small" ], [ [1.0], "small" ], [ [1.5], "small" ], [ [2.0], "small" ],
	[ [3.0], "big" ], [ [3.5], "big" ], [ [4.0], "big" ], [ [4.5], "big" ]
])
oLR = new stzLogisticRegression(oTs3)
oLR.SetLearningRate(0.5)
oLR.Train(300)
chk("the boundary is learned (both sides)",
	oLR.Classify([1.0]) = "small" and oLR.Classify([4.0]) = "big")
nP = oLR.Probability([2.5])
chk("mid-boundary probability hovers near 0.5", nP > 0.3 and nP < 0.7)
chk("Why shows probability, weights and bias",
	len(StzFind("weights", oLR.Why())) > 0)

? ""
? "-- Scene 8: evaluation -- scored, confusion NAMED --"
aP = [ "a", "a", "b", "b" ]
aT = [ "a", "b", "b", "b" ]
chk("accuracy computes", StzAccuracy(aP, aT) = 0.75)
aCM = StzConfusionMatrix(aP, aT)
chk("the confusion matrix names each truth->prediction",
	aCM["b->a"] = 1 and aCM["b->b"] = 2)

? ""
? "-- Scene 9: the network you declare like a sentence (LAW 4) --"
oNN = new stzNeuralNetwork([ :Inputs = 2 ])
oNN.AddDenseLayer(4, :Tanh)
oNN.AddDenseLayer(1, :Sigmoid)
chk("the sentence declares the topology",
	oNN.NumberOfLayers() = 2 and oNN.NumberOfInputs() = 2)

oTr = new stzTrainer()
oTr.SetLearningRate(0.5)
oTr.Train(oNN, [ [0,0], [0,1], [1,0], [1,1] ],
              [ [0], [1], [1], [0] ], 3000)
? "  " + oTr.Why()
chk("XOR is LEARNED (the classic non-linear proof)",
	oNN.Predict([0,1])[1] > 0.9 and oNN.Predict([1,0])[1] > 0.9 and
	oNN.Predict([0,0])[1] < 0.1 and oNN.Predict([1,1])[1] < 0.1)
chk("the loss history descends and is reported",
	oTr.FinalLoss() < 0.01 and len(StzFind("loss", oTr.Why())) > 0)

oNN2 = new stzNeuralNetwork([ :Inputs = 2 ])
oNN2.AddDenseLayer(4, :Tanh)
oNN2.AddDenseLayer(1, :Sigmoid)
oTr2 = new stzTrainer()
oTr2.SetLearningRate(0.5)
oTr2.Train(oNN2, [ [0,0], [0,1], [1,0], [1,1] ],
               [ [0], [1], [1], [0] ], 3000)
chk("training is REPRODUCIBLE (same seed, same weights, LAW 3)",
	oNN.Predict([0,1])[1] = oNN2.Predict([0,1])[1])

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
