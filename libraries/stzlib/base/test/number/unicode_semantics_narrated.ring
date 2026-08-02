# stzNumber.Unicode() -- one meaning, across the whole range.
#
# The method used to answer two different questions depending on the
# value. For 0..9 it read the number AS a codepoint; above 9 it
# decomposed the number's DIGITS, so 65 answered [ 54, 53 ] -- the
# codepoints of '6' and '5' -- rather than 65 ('A').
#
# The library had already settled the convention everywhere else:
# stzChar's init turns a NUMBER into the char at that codepoint, and
# ToUnicodeHexForm() documents itself as "the number in Unicode hex
# form (U+0041)". Unicode() now keeps it too, and the digit reading
# lives under the name that describes it, Unicodes().
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the number IS the codepoint, at every size --"
chk("a single digit", StzNumberQ(5).Unicode() = 5)
chk("an ASCII letter", StzNumberQ(65).Unicode() = 65)
chk("beyond the BMP (an emoji)", StzNumberQ(128512).Unicode() = 128512)
chk("the very last codepoint", StzNumberQ(1114111).Unicode() = 1114111)
? "  65 used to answer [ 54, 53 ] here -- the digits, not the letter."

? ""
? "-- Scene 2: it agrees with the char it names --"
chk("65 names 'A'", StzCharQ(65).Content() = "A")
chk("...and round-trips", StzCharQ(StzNumberQ(65).Unicode()).Content() = "A")
chk("128512 names an emoji", StzCharQ(128512).Unicode() = 128512)
chk("...and ToUnicodeHexForm says the same", StzNumberQ(65).ToUnicodeHexForm() = "U+41")
# Three independent places now give one answer for "what is 65 in
# Unicode": the char, the hex form, and this method.

? ""
? "-- Scene 3: a non-codepoint is REFUSED, not crashed --"
bNeg = FALSE
try
	StzNumberQ(-3).Unicode()
catch
	bNeg = TRUE
done
chk("a negative number is refused", bNeg)

bBig = FALSE
try
	StzNumberQ(1114112).Unicode()
catch
	bBig = TRUE
done
chk("one past the last codepoint is refused", bBig)

bFrac = FALSE
try
	StzNumberQ(6.5).Unicode()
catch
	bFrac = TRUE
done
chk("a fraction is refused", bFrac)
# The range is checked HERE on purpose: StzCharQ(-3) does not raise,
# it PANICS the process out of stz_string.dll, and no try/catch can
# hold that. A guard that turns a crash into a sentence is worth more
# than the check it duplicates.

? ""
? "-- Scene 4: the digit reading still exists, under its own name --"
chk("Unicodes() decomposes the written form",
	@@( StzNumberQ(65).Unicodes() ) = @@([ 54, 53 ]))
chk("...which is the codepoint of '6'", StzCharQ("6").Unicode() = 54)
chk("...and of '5'", StzCharQ("5").Unicode() = 53)
chk("a single digit decomposes to itself as a char",
	@@( StzNumberQ(5).Unicodes() ) = @@([ 53 ]))
# Singular and plural here are NOT the same question at two scales.
# Unicode() reads the number as a codepoint; Unicodes() reads its
# digits as text. Both are useful; only their names suggest otherwise.

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
