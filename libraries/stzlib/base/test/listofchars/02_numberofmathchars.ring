# Narrative
# --------
#
# Extracted from stzlistofcharstest.ring, block #2.
#ERR Error (R14) : Calling Method without definition: charsandtheirnames

load "../../stzBase.ring"

pr()

? NumberOfMathChars()
#--> 68

? MathCharsQRT(:stzListOfChars).CharsAndTheirNames()
#--> [
#	[ "¬", "NOT SIGN" ], [ "°", "DEGREE SIGN" ], [ "±", "PLUS-MINUS SIGN" ],
#	[ "¼", "VULGAR FRACTION ONE QUARTER" ], [ "½", "VULGAR FRACTION ONE HALF" ],
#	[ "¾", "VULGAR FRACTION THREE QUARTERS" ], [ "×", "MULTIPLICATION SIGN" ],
#	[ "÷", "DIVISION SIGN" ], [ "Γ", "GREEK CAPITAL LETTER GAMMA" ],
#	[ "Δ", "GREEK CAPITAL LETTER DELTA" ], [ "Θ", "GREEK CAPITAL LETTER THETA" ],
#	[ "Λ", "GREEK CAPITAL LETTER LAMDA" ], [ "Ξ", "GREEK CAPITAL LETTER XI" ],
#	[ "Π", "GREEK CAPITAL LETTER PI" ], [ "Σ", "GREEK CAPITAL LETTER SIGMA" ],
#	[ "Υ", "GREEK CAPITAL LETTER UPSILON" ], [ "Φ", "GREEK CAPITAL LETTER PHI" ],
#	[ "Ψ", "GREEK CAPITAL LETTER PSI" ], [ "Ω", "GREEK CAPITAL LETTER OMEGA" ],
#	[ "α", "GREEK SMALL LETTER ALPHA" ], [ "β", "GREEK SMALL LETTER BETA" ],
#	[ "γ", "GREEK SMALL LETTER GAMMA" ], [ "δ", "GREEK SMALL LETTER DELTA" ],
#	[ "ε", "GREEK SMALL LETTER EPSILON" ], [ "ζ", "GREEK SMALL LETTER ZETA" ],
#	[ "η", "GREEK SMALL LETTER ETA" ], [ "θ", "GREEK SMALL LETTER THETA" ],
#	[ "ι", "GREEK SMALL LETTER IOTA" ], [ "κ", "GREEK SMALL LETTER KAPPA" ],
#	[ "λ", "GREEK SMALL LETTER LAMDA" ], [ "μ", "GREEK SMALL LETTER MU" ],
#	[ "ν", "GREEK SMALL LETTER NU" ], [ "ξ", "GREEK SMALL LETTER XI" ],
#	[ "ο", "GREEK SMALL LETTER OMICRON" ], [ "π", "GREEK SMALL LETTER PI" ],
#	[ "ρ", "GREEK SMALL LETTER RHO" ], [ "σ", "GREEK SMALL LETTER SIGMA" ],
#	[ "τ", "GREEK SMALL LETTER TAU" ], [ "υ", "GREEK SMALL LETTER UPSILON" ],
#	[ "φ", "GREEK SMALL LETTER PHI" ], [ "χ", "GREEK SMALL LETTER CHI" ],
#	[ "ψ", "GREEK SMALL LETTER PSI" ], [ "ω", "GREEK SMALL LETTER OMEGA" ],
#	[ "⅓", "VULGAR FRACTION ONE THIRD" ], [ "⅔", "VULGAR FRACTION TWO THIRDS" ],
#	[ "∀", "FOR ALL" ], [ "∂", "PARTIAL DIFFERENTIAL" ], [ "∃", "THERE EXISTS" ],
#	[ "∅", "EMPTY SET" ], [ "∇", "NABLA" ], [ "∈", "ELEMENT OF" ],
#	[ "∉", "NOT AN ELEMENT OF" ], [ "∏", "N-ARY PRODUCT" ], [ "∑", "N-ARY SUMMATION" ],
#	[ "√", "SQUARE ROOT" ], [ "∝", "PROPORTIONAL TO" ], [ "∞", "INFINITY" ],
#	[ "∠", "ANGLE" ], [ "∧", "LOGICAL AND" ], [ "∨", "LOGICAL OR" ],
#	[ "∫", "INTEGRAL" ], [ "∲", "CLOCKWISE CONTOUR INTEGRAL" ], [ "∴", "THEREFORE" ],
#	[ "≈", "ALMOST EQUAL TO" ], [ "≠", "NOT EQUAL TO" ], [ "≡", "IDENTICAL TO" ],
#	[ "≤", "LESS-THAN OR EQUAL TO" ], [ "≥", "GREATER-THAN OR EQUAL TO" ]
# ]

pf()
# Executed in 1.65 second(s) in Ring 1.21
# Executed in 5.90 second(s) in Ring 1.17
