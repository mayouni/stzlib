# R3 (the NLTK offensive, FINAL row) -- CONSTITUENCY PARSE TREES.
# The chunker gave FLAT phrases; stzParseTree gives the NESTED phrase
# structure a real parse is: a cascaded phrase grammar (NP -> PP -> VP)
# where later rules name phrases built by earlier ones, so the tree gains
# real depth (S -> VP -> PP -> NP -> leaf). Covers NLTK's RegexpParser
# cascade with trees -- deterministic, embedded, zero download.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: a sentence parses to a NESTED tree (not flat chunks) --"
o = Q("The quick brown fox jumps over the lazy dog").TextQ()
oTree = o.ParseTreeQ()
chk("the root is a sentence node", oTree.Label() = "S")
chk("the tree is genuinely nested (depth 5, not chunk-flat depth 3)",
	oTree.Height() = 5)
chk("its leaves reconstruct the sentence in order",
	JoinXT(oTree.Leaves(), " ") = "The quick brown fox jumps over the lazy dog")

? ""
? "-- Scene 2: the Penn bracket notation (ParseTree() = data) --"
cBr = o.ParseTree()
? "  " + cBr
chk("ParseTree() returns the bracketed string (data, not an object)",
	isString(cBr) and StzLeft(cBr, 2) = "(S")
chk("the subject NP is bracketed with its leaves tagged",
	StzFindFirst(cBr, "(NP The/DT quick/JJ") > 0)

? ""
? "-- Scene 3: real depth -- a PP nested inside the VP, an NP inside the PP --"
aVP = oTree.Subtrees("VP")
chk("there is one verb phrase", len(aVP) = 1)
oVP = aVP[1]
chk("the VP CONTAINS a prepositional phrase (nesting, not a flat list)",
	len(oVP.Subtrees("PP")) = 1)
oPP = oVP.Subtrees("PP")[1]
chk("the PP in turn contains the object noun phrase",
	len(oPP.Subtrees("NP")) = 1 and oPP.Subtrees("NP")[1].Text() = "the lazy dog")

? ""
? "-- Scene 4: phrase queries over the tree (the chunker-style sugar) --"
chk("NounPhrases reads every NP in the tree",
	len(oTree.NounPhrases()) = 2 and oTree.NounPhrases()[1] = "The quick brown fox")
chk("VerbPhrases reads the predicate",
	oTree.VerbPhrases()[1] = "jumps over the lazy dog")
chk("PrepositionalPhrases reads the PP",
	oTree.PrepositionalPhrases()[1] = "over the lazy dog")

? ""
? "-- Scene 5: a pronoun subject is its own NP (a second NP rule fires) --"
o2 = Q("She reads a book").TextQ()
t2 = o2.ParseTreeQ()
chk("the pronoun 'She' is lifted to an NP", ring_find(t2.NounPhrases(), "She") > 0)
chk("the object 'a book' is an NP too", ring_find(t2.NounPhrases(), "a book") > 0)

? ""
? "-- Scene 6: the grammar is OPEN -- a custom cascade parses too --"
# a minimal grammar: just group determiner+noun into NP, nothing else
t3 = o.ParseTreeWithQ([ [ "NP", "DT JJ* NN+" ] ])
chk("a custom cascade yields its own tree shape",
	t3.Label() = "S" and len(t3.NounPhrases()) = 2)
chk("with no VP/PP rules, there is no verb phrase in this tree",
	len(t3.Subtrees("VP")) = 0)

? ""
? "-- Scene 7: the tree is a first-class object (Show / Bracket) --"
chk("Bracket() is an alias of ToBracket()", oTree.Bracket() = oTree.ToBracket())
chk("an indented rendering is available",
	StzFindFirst(oTree.ToTreeString(), "  NP") > 0)

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
