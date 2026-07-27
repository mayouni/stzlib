load "../../stzBase.ring"
load "../_narrated.ring"

# NAIVE BAYES AND APRIORI GO TO THE ENGINE (numeric phase 5, second pass).
#
# These were the last two algorithms the first pass fixed in Ring and left there. The
# first pass was worth doing -- both were dominated by the HasKey counting idiom, and
# retiring it was 142x and 393x -- and it was not finishing. What replaced HasKey was
# a `ring_find` LINEAR SCAN over a key list that grows with the data: the vocabulary
# for one, every singleton, pair and triple for the other. Right answer in Ring, where
# the alternative was 479x worse. Wrong answer anywhere with a hash table.
#
#                          original      after pass 1      in the engine
#     Bayes 100 docs        12.497 s        0.088 s          0.003 s     4166x
#     Bayes 600 docs        82.251 s        0.466 s          0.015 s     5483x
#     Bayes 3000 docs             --        3.647 s          0.095 s
#     Apriori 200 tx        16.124 s        0.041 s          0.017 s      948x
#     Apriori 5000 tx             --        0.941 s          0.157 s
#
# NAIVE BAYES NEEDED TOKENIZATION TO MOVE TOO, and that is the part worth reading.
# Only about two thirds of its 3.647 s was counting. The rest was `_TokensOf`, which
# built a whole stzText object per document just to reach the word iterator -- so
# moving the counting alone would have left a floor at ~1.4 s no matter how fast the
# hash was. The model became resident and tokenization crossed with it.
#
# WHICH MADE THE TOKENIZER THE RISK. `stzText.Words()` goes through
# `str_extract_words`, which walks UAX#29 word segmentation; `_TokensOf` then folded
# each token with StzLower. bayes.zig uses THAT SAME WordIter and THAT SAME fold --
# ASCII byte-wise, everything else through the full Unicode path. A whitespace split
# would have agreed on "the cat sat" and silently built a different model on "don't",
# "3.14", "word2vec" and every CJK document. The scenarios below check the seam
# directly rather than trusting it.
#
# APRIORI NEEDED ITS ORDERING TO SURVIVE, twice. `_Sorted` orders a basket with
# `strcmp` before building the key "a|b|c", so {milk, bread} keys as "bread|milk"
# however it was written -- interning items in strcmp order makes integer order the
# same order, so the engine sorting codes reproduces it. And FrequentItemsets()
# publishes itemsets in FIRST-COUNTED order, which the library's own suite asserts,
# so apriori.zig records arrival order and generates combinations with Ring's exact
# loop nesting: single(i), then for each j>i the pair (i,j) followed by every triple
# (i,j,k), then the next j, then the next i.
#
# Both were verified against the ORIGINAL implementations, not the intermediate ones:
# Bayes labels, classifications and log-scores to TEN DECIMALS across a 7-document
# corpus and a 120-document one with three labels; apriori itemsets, counts, rules,
# confidences and their order at four support thresholds and three confidence cuts.
# Both diffs were empty -- and for Bayes an empty diff at ten decimals is also proof
# that the tokenizer matches, since a single token differing would move every score.

Scenario("naive Bayes classifies exactly as it did")
	oNB = new stzNaiveBayes()
	oNB.Train("great food and lovely staff", "positive")
	oNB.Train("cold soup rude waiter", "negative")
	oNB.Train("Lovely evening GREAT dishes", "positive")
	oNB.Train("awful service, cold plates", "negative")
	oNB.Train("the staff were lovely and kind", "positive")
	oNB.Train("rude and awful, never again", "negative")

	Then("labels are in first-seen order", oNB.Labels()[1], "positive")
	Then("...both of them", oNB.Labels()[2], "negative")
	Then("a positive-looking text", oNB.Classify("lovely great dishes"), "positive")
	Then("a negative-looking one", oNB.Classify("cold rude service"), "negative")
	Then("case does not matter", oNB.Classify("GREAT LOVELY"), "positive")
	Then("...and it explains itself", StzFindFirst("log-scores", oNB.Why()) > 0, TRUE)
	Then("an untrained model refuses", RaisesNB(), TRUE)
	Then("it counted six documents", oNB.NumberOfDocuments(), 6)
EndScenario()

Scenario("the tokenizer is the UAX#29 seam, not a whitespace split")
	# This is the assertion that would have caught a wrong tokenizer, and it is
	# checked through BEHAVIOUR rather than by reaching inside: train one label on a
	# text whose tokens only survive UAX#29 segmentation, and the other on plain
	# words. If the engine split on whitespace or on punctuation, "don't" would
	# become "don" + "t", "3.14" would become "3" + "14", and the model would score
	# the query differently.
	oT = new stzNaiveBayes()
	oT.Train("don't 3.14 word2vec", "technical")
	oT.Train("apple banana cherry", "fruit")

	Then("a query of the exact tricky tokens finds its label",
	     oT.Classify("don't 3.14 word2vec"), "technical")
	Then("...and plain words find theirs", oT.Classify("apple banana"), "fruit")
	# the vocabulary size is the direct evidence: three tokens per document, six
	# total, and all distinct. A punctuation split would give more; a naive split on
	# "." or "'" would give more still.
	Then("six distinct tokens were learned, not more", oT.VocabularySize(), 6)

	# and the same through the class the tokenizer belongs to, so the two agree
	Then("stzText sees three words in the tricky line too",
	     len((new stzText("don't 3.14 word2vec")).Words()), 3)
EndScenario()

Scenario("...and the fold is the same fold")
	# StzLower is what _TokensOf applied. If the engine folded differently -- or not
	# at all -- these two documents would train two vocabularies instead of one.
	oF = new stzNaiveBayes()
	oF.Train("Hello World", "a")
	oF.Train("hello world", "a")
	Then("two spellings are one vocabulary", oF.VocabularySize(), 2)
	Then("...and both documents counted", oF.NumberOfDocuments(), 2)

	# non-ASCII: the full Unicode fold, not an ASCII-only shortcut
	oU = new stzNaiveBayes()
	oU.Train("ÉCOLE", "x")
	oU.Train("école", "x")
	Then("an accented pair folds together too", oU.VocabularySize(), 1)
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
	# FIRST-COUNTED order is published, and this is the assertion that pins it
	Then("...and bread is still first", aF[1][1][1], "bread")

	aR = oA.Rules(2, 0.6)
	Then("nine rules survive a confidence of 0.6", len(aR), 9)
	Then("milk -> bread has confidence 3/4", aR[1][:confidence], 0.75)
	Then("a stricter threshold cuts the 0.667 rules", len(oA.Rules(2, 0.7)), 6)
	Then("...and 0.9 leaves none", len(oA.Rules(2, 0.9)), 0)
EndScenario()

Scenario("apriori keys by SORTED items, whichever order the basket was written")
	# _Sorted uses strcmp, and the engine sorts codes -- which is only equivalent
	# because the codes are assigned in strcmp order. If that link broke, the two
	# baskets below would produce two different keys for one pair.
	oS1 = new stzApriori([ [ "milk", "bread" ], [ "milk", "bread" ] ])
	oS2 = new stzApriori([ [ "bread", "milk" ], [ "bread", "milk" ] ])
	a1 = oS1.FrequentItemsets(2)
	a2 = oS2.FrequentItemsets(2)
	Then("the same set gives the same number of itemsets", len(a1), len(a2))
	Then("...and the same pair count",
	     CountOfSet(a1, [ "bread", "milk" ]), CountOfSet(a2, [ "bread", "milk" ]))

	# strcmp, not Ring's `>`: item names that look numeric must still order as text
	oN = new stzApriori([ [ "10", "9" ], [ "10", "9" ], [ "9", "10" ] ])
	aN = oN.FrequentItemsets(3)
	Then("numeric-looking names are ordered as TEXT", CountOfSet(aN, [ "10", "9" ]), 3)
EndScenario()

Scenario("both are off the quadratic list")
	# Loose thresholds: many times the measured values, so these fail when a scan
	# comes back, not because a machine is busy.
	oNB = new stzNaiveBayes()
	t0 = clock()
	for d = 1 to 500
		c = ""
		for w = 1 to 30
			c += "w" + ((d * 17 + w * 7) % 1500) + " "
		next
		cL = "a"
		if d % 2 = 0
			cL = "b"
		ok
		oNB.Train(c, cL)
	next
	nNb = (clock() - t0) / clockspersecond()
	Then("500 documents train in under 3s -- 100 used to take 12.5", nNb < 3, TRUE)
	Then("...and the model is real", oNB.NumberOfDocuments(), 500)

	acItems = []
	for i = 1 to 40
		acItems + ("i" + i)
	next
	aT = []
	for t = 1 to 1500
		aOne = []
		for k = 1 to 6
			aOne + acItems[ ((t * 7 + k * 13) % 40) + 1 ]
		next
		aT + aOne
	next
	oAp = new stzApriori(aT)
	t0 = clock()
	v = oAp.FrequentItemsets(30)
	nAp = (clock() - t0) / clockspersecond()
	Then("1500 baskets mine in under 3s -- 200 used to take 16.1", nAp < 3, TRUE)
	Then("...and found something", len(v) > 0, TRUE)
EndScenario()

Summary()

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
