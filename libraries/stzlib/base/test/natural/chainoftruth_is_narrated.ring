# _(x).Is(y) -- the chain's type/trait question, in BOTH spellings.
#
# Ring lowercases a :Symbol (`:String` IS the string "string") and
# ring_methods() answers in lowercase -- while Ring's string `=` is
# CASE-SENSITIVE. Is() compared the caller's word against both without
# folding, so it answered correctly for the symbol form and SILENTLY
# 0 for the quoted form:
#
#     _("Ring").Is(:String)._   -> 1
#     _("Ring").Is("String")._  -> 0      # same question, no answer
#
# It never raised; it just said no. This guard pins both spellings and,
# equally important, pins the NEGATIVES -- a predicate that always says
# yes would satisfy every positive example here and be worthless.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the four native types, either spelling --"
chk("symbol :String", _("Ring").Is(:String)._)
chk("quoted 'String'", _("Ring").Is("String")._)
chk("shouting 'STRING'", _("Ring").Is("STRING")._)
chk("symbol :Number on 89", _(89).Is(:Number)._)
chk("quoted 'Number' on 89", _(89).Is("Number")._)
chk("a list is a :List", _([ 1, 2 ]).Is(:List)._)

? ""
? "-- Scene 2: ...and they still say NO when they should --"
chk("'Ring' is not a Number", NOT _("Ring").Is("Number")._)
chk("89 is not a String", NOT _(89).Is("String")._)
chk("a string is not a List", NOT _("Ring").Is(:List)._)
# The bug made everything answer 0. A fix that made everything answer
# 1 would pass Scene 1 and be just as wrong.

? ""
? "-- Scene 3: stz traits, reached through the object's own methods --"
chk("'RING' is Uppercase (quoted)", _("RING").Is("Uppercase")._)
chk("'RING' is Uppercase (symbol)", _("RING").Is(:Uppercase)._)
chk("...but 'ring' is not", NOT _("ring").Is("Uppercase")._)
chk("'ring' is Lowercase", _("ring").Is(:Lowercase)._)
# ring_methods() answers lowercase, so the needle "isUppercase" never
# met the method "isuppercase" -- the same fold, one branch along.

? ""
? "-- Scene 4: the list form, which had never once run --"
oCotA = _([ "A", "B", "C" ])
chk("a list of strings AND of chars, at the same time",
	oCotA.Is([ :AListOfStrings, :AListOfChars ]).AtTheSameTime._)
oCotB = _([ "A", "B", "C" ])
chk("...accepting mixed spelling too",
	oCotB.Is([ :AListOfStrings, "AListOfChars" ]).AtTheSameTime._)
oCotC = _([ "AB", "CD" ])
chk("...and saying NO when one member fails",
	NOT _([ "AB", "CD" ]).Is([ :AListOfStrings, :AListOfChars ]).AtTheSameTime._)
# This branch was unreachable: its guard matched "isAListOfStrings"
# against lowercase method names and never passed. Fixing the fold
# exposed an R13 underneath -- `_(x)` inside this class resolves to the
# magic `_` ATTRIBUTE, not the global constructor.

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
