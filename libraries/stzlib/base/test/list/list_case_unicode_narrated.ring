# Case ignored, in every script -- the list operations' CS dial.
#
# With case ignored (pCaseSensitive = 0), a list compared its texts by
# folding ASCII letters only: [ "α" ] and [ "Α" ] were two different
# items, while stzString called "α" and "Α" equal. Found 2026-11-08 while
# fixing IsEqualTo (STZLIB-LISTCI-UNICODE-01).
#
# The engine (engine/src/list.zig) now reads every text through one fold,
# Unicode full case folding, for equality, sort order and hashing alike.
# The expectations below come from CaseFolding.txt, written by hand:
#   Α -> α   Σ -> σ   ς -> σ   É -> é   Ί -> ί   ß -> ss   SS -> ss
# A fold is not a normalisation and is not applied when case counts.
#
# Ends on Summary() then shutdown($_zst_fail): the exit code is the
# number of failed assertions.

load "../../stzBase.ring"
load "../_narrated.ring"

nLcuAll = clock()

Scenario("Equality with case ignored")
	Then("[α,β] equals [Β,Α] ignoring case", new stzList([ "α", "β" ]).IsEqualToCS([ "Β", "Α" ], 0), 1)
	Then("but not when case counts", new stzList([ "α", "β" ]).IsEqualToCS([ "Β", "Α" ], 1), 0)
	Then("[straße] is strictly equal to [STRASSE] ignoring case: ß folds to ss",
		new stzList([ "straße" ]).IsStrictlyEqualToCS([ "STRASSE" ], 0), 1)
	Then("[Σοφία, é] is strictly equal to [ΣΟΦΊΑ, É] ignoring case",
		new stzList([ "Σοφία", "é" ]).IsStrictlyEqualToCS([ "ΣΟΦΊΑ", "É" ], 0), 1)
	Then("final sigma and capital sigma are one letter ignoring case",
		new stzList([ "ς" ]).IsEqualToCS([ "Σ" ], 0), 1)
	Then("repeats still count: [α,α] is not [Α,β]", new stzList([ "α", "α" ]).IsEqualToCS([ "Α", "β" ], 0), 0)
	Then("ASCII as before: [a,B] equals [b,A]", new stzList([ "a", "B" ]).IsEqualToCS([ "b", "A" ], 0), 1)
	Then("Hebrew and emoji have no case and compare as they are",
		new stzList([ "שלום", "😀" ]).IsEqualToCS([ "😀", "שלום" ], 0), 1)
EndScenario()

Scenario("Nested lists, with case ignored inside them too")
	Then("[[A,β]] equals [[a,Β]] ignoring case",
		new stzList([ [ "A", "β" ] ]).IsEqualToCS([ [ "a", "Β" ] ], 0), 1)
	Then("but not when case counts",
		new stzList([ [ "A", "β" ] ]).IsEqualToCS([ [ "a", "Β" ] ], 1), 0)
EndScenario()

Scenario("Finding and counting with case ignored")
	oLcu = new stzList([ "α", "Α", "β", "α" ])
	Then("ContainsCS(Α) ignoring case", new stzList([ "α", "β" ]).ContainsCS("Α", 0), 1)
	Then("ContainsCS(Α) with case", new stzList([ "α", "β" ]).ContainsCS("Α", 1), 0)
	Then("ContainsCS(É) finds é", new stzList([ "Σοφία", "é" ]).ContainsCS("É", 0), 1)
	Then("NumberOfOccurrencesCS(α) is 3", oLcu.NumberOfOccurrencesCS("α", 0), 3)
	Then("FindCS(Α) is [1, 2, 4]", @@(oLcu.FindCS("Α", 0)), "[ 1, 2, 4 ]")
EndScenario()

Scenario("Removing duplicates and sorting with case ignored")
	Then("[α,Α,β,ß,SS] without duplicates is [α,β,ß]",
		@@(new stzList([ "α", "Α", "β", "ß", "SS" ]).DuplicatesRemovedCS(0)), '[ "α", "β", "ß" ]')
	Then("[Β,α] sorted ignoring case is [α,Β]: alpha before beta",
		@@(new stzList([ "Β", "α" ]).SortedCS(0)), '[ "α", "Β" ]')
	Then("and with case, by codepoint, capital Beta (U+0392) comes first",
		@@(new stzList([ "Β", "α" ]).SortedCS(1)), '[ "Β", "α" ]')
EndScenario()

? "        [guard took " + ((clock() - nLcuAll) / clockspersecond()) + "s]"
Summary()
shutdown($_zst_fail)
