load "../../stzBase.ring"
load "../_narrated.ring"

# THE COUNTING IDIOM (numeric phase 5, FIRST pass).
#
# WHAT THIS FILE RECORDS IS HISTORY, and still true history: the idiom below really
# was the whole cost of three classes, and retiring it really was 393x. But it was
# NOT the end -- what replaced HasKey was a linear scan, which is the right answer in
# Ring and the wrong answer anywhere with a hash table. All three algorithms have
# since moved into the engine. See numeric_text_mining_narrated (naive Bayes and
# apriori) and the decision-tree notes in stzDecisionTree.ring. The assertions here
# still hold because none of that changed an answer.
#
# The plan said "k-means / KNN / logistic / trees -> engine". Distance and logistic
# regression went, and both were worth it. The tree was next, and it did not go --
# because profiling it found something that had nothing to do with trees, and
# everything to do with a line of Ring that appears all over this library:
#
#     if HasKey(aCounts, key)
#         aCounts[key] = aCounts[key] + 1
#     else
#         aCounts[key] = 1
#     ok
#
# Counting occurrences into a Ring hash-list. It reads like a hash map, and it is
# not one. Measured over 4000 items, 20 passes:
#
#                                  2 distinct keys      50 distinct keys
#     HasKey idiom                     1.515 s              12.858 s
#     parallel lists + ring_find       0.054 s               0.068 s
#                                        28x                  189x
#
# READ THE SECOND COLUMN. Going from 2 distinct keys to 50 makes the linear scan
# 26% slower and the HasKey form EIGHT AND A HALF TIMES slower. Whatever it does on
# a Ring list, it is not a lookup that stays flat as keys accumulate -- writing
# through the key appears to invalidate the index so the next HasKey rebuilds it.
# Which means the idiom is worst exactly where a map is most wanted.
#
# WHERE IT WAS, AND WHAT IT COST. Three classes, all in learning/, all of them
# counting something they must count:
#
#     stzApriori     200 transactions       16.124 s  ->  0.041 s      393x
#     stzApriori     600 transactions       47.589 s  ->  0.099 s      481x
#     stzNaiveBayes  100 documents          12.497 s  ->  0.088 s      142x
#     stzNaiveBayes  600 documents          82.251 s  ->  0.466 s      176x
#     stzDecisionTree 4000 x 8 features      1.434 s  ->  0.308 s      4.7x
#     stzDecisionTree 10000 x 8              3.580 s  ->  1.349 s      2.7x
#
# Apriori is the extreme because its key space IS its answer -- every singleton,
# pair and triple of every transaction. Naive Bayes was next because it ran three
# of these blocks per word. Association rules on two hundred baskets taking sixteen
# seconds is not a slow library; it is an unusable one, and nothing in the suites
# said so because they all use tiny fixtures.
#
# THE ARITHMETIC IS UNTOUCHED IN ALL THREE, which is the claim these scenarios
# exist to hold. Each was checked by dumping its full output before and after the
# change and diffing: trees across five datasets plus a mixed-case one plus every
# training verdict plus Why(); naive Bayes labels, classifications and log-scores
# to ten decimals; apriori itemsets, counts, rules, confidences and their ORDER.
# All three diffs were empty.
#
# TWO SITES WERE DELIBERATELY LEFT. `StzConfusionMatrix` returns a map its callers
# index BY KEY -- `aCM["b->a"]` is its tested contract -- and it holds at most
# labels-squared entries, which is the flat end of the curve above. stzKnn's vote
# tally is bounded by k. Neither is the severe form, and changing a published
# return type to chase a cost that was measured as negligible would be the trade
# backwards.

Scenario("the decision tree builds the same tree")
	# The classic weather example, which is what ID3 is usually taught with, so
	# the expected split is checkable by hand: outlook is the root because it
	# carries the most information about play.
	oT = new stzDecisionTree(new stzTrainingSet([
		[ [ "sunny",    "high",   "weak"   ], "no"  ],
		[ [ "sunny",    "high",   "strong" ], "no"  ],
		[ [ "overcast", "high",   "weak"   ], "yes" ],
		[ [ "rain",     "high",   "weak"   ], "yes" ],
		[ [ "rain",     "normal", "weak"   ], "yes" ],
		[ [ "rain",     "normal", "strong" ], "no"  ],
		[ [ "overcast", "normal", "strong" ], "yes" ],
		[ [ "sunny",    "normal", "weak"   ], "yes" ] ]))
	oT.SetFeatureNames([ "outlook", "humidity", "wind" ])
	oT.Train()

	Then("outlook wins the root split", oT.Tree()[:feature], 1)
	Then("overcast is decided without looking further", oT.Classify(["overcast","high","strong"]), "yes")
	Then("sunny + high is a no", oT.Classify(["sunny","high","weak"]), "no")
	Then("rain + normal + strong is a no", oT.Classify(["rain","normal","strong"]), "no")
	Then("...and Why() still narrates the path it took",
	     StzFindFirst("outlook=", oT.Why()) > 0, TRUE)
	Then("an unseen value falls to the majority default",
	     StzFindFirst("unseen value", WhyOf(oT, ["fog","high","weak"])) > 0, TRUE)
EndScenario()

Scenario("...and it still folds case, which is why the fold existed")
	# The fold moved from every node visit to one pass in Train(). It must still
	# fold: "Sunny" and "sunny" are one categorical value, and a tree that split
	# them apart would be a different -- and wrong -- model.
	oM = new stzDecisionTree(new stzTrainingSet([
		[ ["Sunny","High"], "no"  ], [ ["sunny","high"], "no"  ],
		[ ["RAIN","low"],   "yes" ], [ ["rain","LOW"],   "yes" ],
		[ ["Overcast","High"], "yes" ] ]))
	oM.Train()

	Then("an upper-case query finds the lower-case branch", oM.Classify(["SUNNY","HIGH"]), "no")
	Then("...and the reverse", oM.Classify(["rain","low"]), "yes")
	Then("...and a mixed one", oM.Classify(["Overcast","high"]), "yes")
	# 2 outlooks after folding, not 4 -- if the fold were lost this would be 4
	Then("the root has one branch per FOLDED value", len(oM.Tree()[:branches]) < 4, TRUE)
EndScenario()

Scenario("ragged training data is a diagnosis, not an index error")
	# Same trap the logistic slice closed, and it was here too: the width comes
	# from the FIRST example. A narrower row raised a bare Ring "Array Access
	# (Index out of range)" from inside _ValuesOf; a wider one was ignored.
	Then("a narrower row is refused", RaisesTree([
		[ ["a","b","c"], "x" ], [ ["a","b"], "y" ] ]), TRUE)
	Then("a wider row is refused too", RaisesTree([
		[ ["a","b"], "x" ], [ ["a","b","c"], "y" ] ]), TRUE)
	Then("...naming the example", StzFindFirst("Example 2", WhyTree([
		[ ["a","b"], "x" ], [ ["a","b","c"], "y" ] ])) > 0, TRUE)
	Then("an empty set still refuses", RaisesTree([]), TRUE)
EndScenario()

Scenario("naive Bayes classifies exactly as it did")
	oNB = new stzNaiveBayes()
	oNB.Train("great food and lovely staff", "positive")
	oNB.Train("cold soup rude waiter", "negative")
	oNB.Train("Lovely evening GREAT dishes", "positive")
	oNB.Train("awful service, cold plates", "negative")
	oNB.Train("the staff were lovely and kind", "positive")
	oNB.Train("rude and awful, never again", "negative")

	Then("labels come back in first-seen order, as keys() gave them",
	     oNB.Labels()[1], "positive")
	Then("...both of them", oNB.Labels()[2], "negative")
	Then("a positive-looking text", oNB.Classify("lovely great dishes"), "positive")
	Then("a negative-looking one", oNB.Classify("cold rude service"), "negative")
	Then("case does not matter to it", oNB.Classify("GREAT LOVELY"), "positive")
	Then("...and it explains itself", StzFindFirst("log-scores", oNB.Why()) > 0, TRUE)
	Then("an untrained one refuses", RaisesNB(), TRUE)
EndScenario()

Scenario("apriori mines exactly the same rules")
	oA = new stzApriori([
		[ "bread", "milk" ], [ "bread", "milk", "eggs" ], [ "bread", "eggs" ],
		[ "milk", "eggs" ], [ "bread", "milk", "eggs" ] ])

	aF = oA.FrequentItemsets(2)
	Then("seven itemsets clear a support of 2", len(aF), 7)
	Then("bread appears four times", CountOfSet(aF, [ "bread" ]), 4)
	Then("bread+milk three times", CountOfSet(aF, [ "bread", "milk" ]), 3)
	Then("the one triple twice", CountOfSet(aF, [ "bread", "eggs", "milk" ]), 2)
	Then("...and insertion order is preserved -- bread is still first",
	     aF[1][1][1], "bread")

	aR = oA.Rules(2, 0.6)
	Then("nine rules survive a confidence of 0.6", len(aR), 9)
	Then("milk -> bread has confidence 3/4", aR[1][:confidence], 0.75)
	Then("a stricter threshold cuts the 0.667 rules", len(oA.Rules(2, 0.7)), 6)
	Then("...and 0.9 leaves none", len(oA.Rules(2, 0.9)), 0)
EndScenario()

Scenario("the idiom is gone from the hot paths, and the cost with it")
	# A timed guard, deliberately loose. The point is not the exact number -- it
	# is that these three no longer live in a different order of magnitude. Each
	# threshold is many times the measured value, so this fails only if the idiom
	# comes back, not because a machine is busy.
	acItems = []
	for i = 1 to 25
		acItems + ("i" + i)
	next
	aT = []
	for t = 1 to 200
		aOne = []
		for k = 1 to 5
			aOne + acItems[ ((t * 7 + k * 13) % 25) + 1 ]
		next
		aT + aOne
	next
	t0 = clock()
	oAp = new stzApriori(aT)
	v = oAp.FrequentItemsets(10)
	nAp = (clock() - t0) / clockspersecond()
	Then("200 baskets mine in under 2s -- it was 16.1", nAp < 2, TRUE)

	oNB = new stzNaiveBayes()
	t0 = clock()
	for d = 1 to 100
		c = ""
		for w = 1 to 30
			c += "w" + ((d * 17 + w * 7) % 800) + " "
		next
		cL = "a"
		if d % 2 = 0
			cL = "b"
		ok
		oNB.Train(c, cL)
	next
	nNb = (clock() - t0) / clockspersecond()
	Then("100 documents train in under 3s -- it was 12.5", nNb < 3, TRUE)

	aD = []
	for i = 1 to 4000
		aF = []
		s = 0
		for f = 1 to 8
			k = ((i * 37 + f * 11) % 3) + 1
			aF + ("v" + k)
			s += k
		next
		cL = "no"
		if s % 2 = 0
			cL = "yes"
		ok
		aD + [ aF, cL ]
	next
	# TWO STATEMENTS, NOT ONE. `(new stzDecisionTree(...)).Train()` as a single
	# expression does not merely raise here -- it runs, and it runs so slowly that
	# a 0.35 s build did not finish in four minutes. Ring's construct-and-call-in-
	# one-expression trap, and this is a nastier face of it than the R13 the same
	# shape gives on stzMatrix: nothing announces itself.
	oTr = new stzTrainingSet(aD)
	oTree = new stzDecisionTree(oTr)
	t0 = clock()
	oTree.Train()
	nTr = (clock() - t0) / clockspersecond()
	Then("a 4000 x 8 tree builds in under 3s -- it was 1.43 and is now 0.31",
	     nTr < 3, TRUE)
EndScenario()

Summary()

func WhyOf(oT, aF)
	oT.Classify(aF)
	return oT.Why()

func RaisesTree(aD)
	b = FALSE
	try
		o = new stzDecisionTree(new stzTrainingSet(aD))
		o.Train()
	catch
		b = TRUE
	done
	return b

func WhyTree(aD)
	c = ""
	try
		o = new stzDecisionTree(new stzTrainingSet(aD))
		o.Train()
	catch
		c = cCatchError
	done
	return c

func RaisesNB()
	b = FALSE
	try
		o = new stzNaiveBayes()
		v = o.Classify("anything")
	catch
		b = TRUE
	done
	return b

func CountOfSet(aF, acWant)
	nW = len(acWant)
	for i = 1 to len(aF)
		if len(aF[i][1]) = nW
			bAll = TRUE
			for k = 1 to nW
				if ring_find(aF[i][1], acWant[k]) = 0
					bAll = FALSE
				ok
			next
			if bAll
				return aF[i][2]
			ok
		ok
	next
	return 0
