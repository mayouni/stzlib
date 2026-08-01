# Are() -- the collective question, in its compound form.
#
# The library's example corpus (list/343,345,351,353_are.ring and
# string/451,994) documented Are([ :Even, :Positive, :Numbers ]) for
# years. The implementation only ever handled a scalar, so every one of
# those calls died with R21 -- `"" + p` raises on a list. The examples
# were the specification; nothing ran them, because they sit outside
# the *_narrated.ring naming convention every sweep filters on.
#
# This guard is that specification, made reachable -- and extended with
# the negative and error cases the examples never state, since a
# collective check that cannot FAIL is not a check.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the scalar form still answers --"
chk("a list of numbers", Q([ 1, 2, 3 ]).Are(:Numbers))
chk("a list of strings", Q([ "one", "two" ]).Are(:Strings))
chk("...and a mixed list is NOT", NOT Q([ 1, "two" ]).Are(:Numbers))
chk("an empty list is nothing collectively", NOT Q([]).Are(:Numbers))

? ""
? "-- Scene 2: a LIST of descriptors reads conjunctively --"
chk("even AND positive AND numbers", Q([ 2, 4, 8 ]).Are([ :Even, :Positive, :Numbers ]))
chk("even AND negative AND numbers", Q([ -2, -4, -8 ]).Are([ :Even, :Negative, :Numbers ]))
chk("uppercase AND latin AND strings",
	Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Latin, :Strings ]))
chk("lowercase AND strings", Q([ "ring", "php" ]).Are([ :Lowercase, :Strings ]))
? "  the last descriptor names the type, the earlier ones are traits --"
? "  but nothing depends on that: it is a plain AND."

? ""
? "-- Scene 3: a one-element list IS the scalar --"
chk("Are([ :Strings ]) = Are(:Strings)",
	Q([ "ONE", "TWO" ]).Are([ :Strings ]) = Q([ "ONE", "TWO" ]).Are(:Strings))

? ""
? "-- Scene 4: ONE false trait fails the whole conjunction --"
chk("not all even", NOT Q([ 2, 3, 4 ]).Are([ :Even, :Numbers ]))
chk("not all positive", NOT Q([ 2, -4 ]).Are([ :Even, :Positive, :Numbers ]))
chk("not all uppercase", NOT Q([ "ONE", "two" ]).Are([ :Uppercase, :Strings ]))
chk("right traits, wrong type", NOT Q([ 2, 4 ]).Are([ :Even, :Strings ]))
# The examples only ever showed TRUE. A conjunction that cannot fail
# would satisfy every one of them and still be worthless.

? ""
? "-- Scene 5: script and direction traits, over real text --"
chk("arabic AND strings", Q([ "واحد", "اثنان", "ثلاثة" ]).Are([ :Arabic, :Strings ]))
chk("arabic-script AND right-to-left AND texts",
	Q([ "واحد", "اثنان" ]).Are([ :ArabicScript, :RightToLeft, :Texts ]))
chk("han-script AND texts", Q([ "你好", "亲", "朋友们" ]).Are([ :HanScript, :Texts ]))
chk("...and latin text is NOT han", NOT Q([ "hello" ]).Are([ :HanScript, :Texts ]))

? ""
? "-- Scene 6: a trait only a CHAR can answer --"
chk("punctuation AND chars", Q([ ",", ";", ")" ]).Are([ :Punctuation, :Chars ]))
chk("...letters are not punctuation", NOT Q([ "a", "b" ]).Are([ :Punctuation, :Chars ]))
# :Punctuation has no predicate on stzString and none on the list --
# it is answered by reading each item through StzCharQ. That is the
# fourth rung of the resolution ladder.

? ""
? "-- Scene 7: :Texts is a TYPE trait, not stzObject.IsText() --"
chk("plain strings ARE texts collectively", Q([ "ab", "cd" ]).Are(:Texts))
chk("...though no plain string IS an stzText", NOT Q("ab").IsText())
# The per-item IsText() asks whether the VALUE is an stzText object.
# The collective :Texts asks whether the items can be READ as texts,
# which every string can. Conflating the two would make every
# [ ..., :Texts ] example in the corpus false.

? ""
? "-- Scene 8: an unanswerable descriptor RAISES, it does not say no --"
bRaised = FALSE
try
	Q([ 1, 2 ]).Are(:Flabbergasted)
catch
	bRaised = TRUE
done
chk("no predicate can judge it, so it refuses to answer", bRaised)
# "Nothing can judge this" and "every item failed" are different facts.
# Returning 0 would report a clean pass as a clean failure -- and would
# have hidden this whole defect, since every broken call would simply
# have looked FALSE instead of raising.

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
